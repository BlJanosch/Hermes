"""
@file
@brief enthält den Controller für die Bestenliste-Funktionalität.
"""

import connexion
import mariadb
import sys
from typing import Dict, Tuple, Union, List

from openapi_server.models.user_bestenliste import UserBestenliste  # noqa: E501
from openapi_server import util
import logging

logging.basicConfig(level=logging.INFO)

def get_connection():
    try:
        return mariadb.connect(
            user="app",
            password="hermes", 
            host="localhost",          
            port=3306,
            database="hermes" 
        )
    except mariadb.Error as e:
        logging.error(f"Fehler beim Verbinden zu MariaDB: {e}")
        sys.exit(1)

# Logging included
def bestenliste(user_id,filter_db):  # noqa: E501
    """
    @brief Ruft eine Liste von Usern ab sortiert nach Hoehenmeter, kmgelaufen oder Anzahl Berge.
    @param user_id: ID des aktiven Benutzers
    @param filter_db: String, der angibt, nach welchem Kriterium die Bestenliste sortiert werden soll. Mögliche Werte sind "hoehenmeter", "kmgelaufen" oder "berge".
    @return Gibt eine Liste zurück, die die 10 besten User enthält, sortiert nach dem angegebenen Kriterium. Falls der aktive User nicht unter den Top 10 ist, wird er zu einem weiteren Eintrag am Ende der Liste.
    """

    if not user_id or not filter_db:
        logging.error("userID und filter sind erforderlich")
        return {"error": "userID und filter sind erforderlich"}, 400

    conn = get_connection()
    cur = conn.cursor(dictionary=True) 

    query = """
    SELECT id, profilbild, benutzername, hoehenmeter, kmgelaufen
    FROM user
    ORDER BY
    """

    valid_filters = ["hoehenmeter", "kmgelaufen", "berge"]
    if filter_db not in valid_filters:
        logging.error(f"Ungültiger Filterwert: {filter_db}")
        return {"error": "Ungültiger Filterwert"}, 400

    if filter_db == "hoehenmeter":
        logging.info("Sortiere nach Hoehenmeter")
        query += " hoehenmeter DESC"
    elif filter_db == "kmgelaufen":
        logging.info("Sortiere nach Kilometer gelaufen")
        query += " kmgelaufen DESC"
    elif filter_db == "berge":
        logging.info("Sortiere nach Anzahl Berge")
        query = "SELECT ziel_erreicht.user_id as id, user.benutzername as benutzername, user.profilbild as profilbild, user.hoehenmeter as hoehenmeter, user.kmgelaufen as kmgelaufen, COUNT(ziel_erreicht.user_id) AS anzahlBerge FROM ziel_erreicht JOIN user ON ziel_erreicht.user_id = user.id GROUP BY ziel_erreicht.user_id, user.benutzername, user.profilbild, user.kmgelaufen, user.hoehenmeter ORDER BY anzahlBerge DESC;"
    else:
        query += " kmgelaufen DESC" 

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
            kmgelaufen=row["kmgelaufen"],
            anzahlBerge=row["anzahlBerge"] if "anzahlBerge" in row else None
        )
        if aktuelle_platzierung <= 10:
            result.append(user_bestenliste)
            logging.info(f"User {user_bestenliste.id} hinzugefügt mit Platzierung {aktuelle_platzierung}")
            print("Aktuelle Platzierung:", aktuelle_platzierung)
            print("(Dazugefügt)", user_bestenliste.id)
        if user_bestenliste.id == user_id:
            if not user_bestenliste in result:
                result.append(user_bestenliste)
                logging.info("Aktueller User gefunden und hinzugefügt:", user_bestenliste.id)
            else:
                logging.info("Aktueller User gefunden, aber bereits in Liste:", user_bestenliste.id) 

    cur.close()
    conn.close()

    logging.info(f"Bestenliste erfolgreich abgerufen mit {len(result)} Einträgen")
    return result, 200
