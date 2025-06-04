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

def bestenliste(user_id,filter_db):  # noqa: E501
    """Bestenliste nach Filter abrufen (hoehenmeter, kilometer_gelaufen)"""

    print("hallo")
    print("UserID:", user_id)
    print("Filter:", filter_db)
    if not user_id or not filter_db:
        return {"error": "userID und filter sind erforderlich"}, 400

    conn = get_connection()
    cur = conn.cursor(dictionary=True)  # <== wichtig für Spaltennamen

    query = """
    SELECT id, profilbild, benutzername, hoehenmeter, kmgelaufen
    FROM user
    ORDER BY
    """

    valid_filters = ["hoehenmeter", "kmgelaufen"]
    if filter_db not in valid_filters:
        return {"error": "Ungültiger Filterwert"}, 400

    # Entsprechend sortieren
    if filter_db == "hoehenmeter":
        query += " hoehenmeter DESC"
    elif filter_db == "kmgelaufen":
        query += " kmgelaufen DESC"
    else:
        query += " kmgelaufen DESC"  # Fallback, sollte nie erreicht werden

    cur.execute(query)
    rows = cur.fetchall()

    
    aktuelle_platzierung = 0
    result = []
    for row in rows:
        aktuelle_platzierung += 1
        user_bestenliste = UserBestenliste(
            platzierung=aktuelle_platzierung,
            id=row["id"],
            benutzername=row["benutzername"],
            profilbild=row["profilbild"],
            hoehenmeter=row["hoehenmeter"],
            kmgelaufen=row["kmgelaufen"]
        )
        if aktuelle_platzierung <= 10:
            result.append(user_bestenliste)
            print("Aktuelle Platzierung:", aktuelle_platzierung)
            print("(Dazugefügt)", user_bestenliste.id)
        if user_bestenliste.id == user_id:
            if not user_bestenliste in result:
                result.append(user_bestenliste)
                print("Aktueller User gefunden und hinzugefügt:", user_bestenliste.id)
            else:
                print("Aktueller User gefunden, aber bereits in Liste", user_bestenliste.id)
    
    



    cur.close()
    conn.close()

    return result, 200
