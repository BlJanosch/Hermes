import connexion
import mariadb
import sys
from typing import Dict, Tuple, Union, List

from openapi_server.models.user_bestenliste import UserBestenliste  # noqa: E501
from openapi_server import util

def get_connection():
    try:
        return mariadb.connect(
            user="root",              
            password="Hermes!1234",  
            host="localhost",          
            port=3306,
            database="hermes" 
        )
    except mariadb.Error as e:
        print(f"Fehler beim Verbinden zu MariaDB: {e}")
        sys.exit(1)

def bestenliste(user_id,filter):  # noqa: E501
    """Bestenliste nach Filter abrufen (hoehenmeter, kilometer_gelaufen)"""

    print("hallo")
    print(user_id, filter)
    if not user_id or not filter:
        return {"error": "userID und filter sind erforderlich"}, 400

    conn = get_connection()
    cur = conn.cursor(dictionary=True)  # <== wichtig für Spaltennamen

    query = """
        SELECT u.id, u.benutzername, s.hoehenmeter, s.kilometer_gelaufen
        FROM user u
        JOIN stats s ON u.id = s.user_id
        ORDER BY
    """

    valid_filters = ["hoehenmeter", "kmgelaufen"]
    if filter not in valid_filters:
        return {"error": "Ungültiger Filterwert"}, 400


    if filter == "hoehenmeter":
        query += " s.hoehenmeter DESC"
    elif filter == "kmgelaufen":
        query += " s.kmgelaufen DESC"
    else:
        query += " s.kmgelaufen DESC"  # Default sort

    cur.execute(query)
    rows = cur.fetchall()

    result = []
    for row in rows:
        user_bestenliste = UserBestenliste(
            id=row["id"],
            benutzername=row["benutzername"],
            hoehenmeter=row["hoehenmeter"],
            kilometer_gelaufen=row["kilometer_gelaufen"]
        )
        result.append(user_bestenliste)

    cur.close()
    conn.close()

    return result, 200
