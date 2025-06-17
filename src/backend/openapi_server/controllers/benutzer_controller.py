"""
@file
@brief enthält den Controller für jegliche Benutzer-Funktionalität.
"""


import connexion
import mariadb
import sys
from typing import Dict
from typing import Tuple
from typing import Union

from openapi_server.models.user import User  # noqa: E501
from openapi_server import util
import logging
import bcrypt

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
        print(f"Fehler beim Verbinden zu MariaDB: {e}")
        sys.exit(1)

# Logging included
def user_get(user_id):  # noqa: E501
    """Gibt die Daten eines Benutzers anhand der ID zurück

    :param id:
    :type id: int

    :rtype: Union[User, Tuple[User, int], Tuple[User, int, Dict[str, str]]]
    """
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("SELECT id, kmgelaufen, hoehenmeter, passwort, benutzername, profilbild FROM user WHERE id = ?", (user_id,))
    row = cur.fetchone()
    cur.close()
    conn.close()

    if row:
        user = User(
            id=row[0],
            kmgelaufen=row[1],
            hoehenmeter=row[2],
            passwort=row[3],
            benutzername=row[4],
            profilbild=row[5]
        )
        logging.info(f"User mit ID {user_id} gefunden: {user.benutzername}")
        return user, 200
    else:
        logging.error(f"User mit ID {user_id} nicht gefunden")
        return {"message": "User not found"}, 401
    
# Logging included
def update_userdata(body):  # noqa: E501
    """Aktualisiert die Daten eines Benutzers, man muss ein Json mitgeben

     # noqa: E501

    :param user: 
    :type user: dict | bytes

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    user = body
    if connexion.request.is_json:
        user = User.from_dict(connexion.request.get_json())  # noqa: E501

    if not isinstance(user, User):
        logging.error("Falsche Eingabe: User-Objekt im JSON-Format erwartet")
        return {"message": "Wrong input: user object json expected"}, 400

    conn = get_connection()
    cur = conn.cursor()
    if (user.passwort != ""):
        cur.execute(
        "UPDATE user SET kmgelaufen = ?, hoehenmeter = ?, passwort = ?, benutzername = ?, profilbild = ? WHERE id = ?",
        (user.kmgelaufen, user.hoehenmeter, bcrypt.hashpw(user.passwort.encode(), bcrypt.gensalt()), user.benutzername, user.profilbild, user.id)
        )
    else:
        print("tesktk")
        cur.execute(
        "UPDATE user SET kmgelaufen = ?, hoehenmeter = ?, benutzername = ?, profilbild = ? WHERE id = ?",
        (user.kmgelaufen, user.hoehenmeter, user.benutzername, user.profilbild, user.id)
        )

    conn.commit()
    cur.close()

    logging.info(f"User-Daten für ID {user.id} aktualisiert: {user.benutzername}")
    logging.debug(f"Neue Daten: kmgelaufen={user.kmgelaufen}, hoehenmeter={user.hoehenmeter}, benutzername={user.benutzername}, profilbild={user.profilbild}")
    return "Erfolg", 200

# Logging included
def update_stats(body):  # noqa: E501
    """Aktualisiert die Statistiken eines Benutzers. Erwartet JSON mit id, kmgelaufen und hoehenmeter.

    :param body: JSON-Daten mit den Feldern 'id', 'kmgelaufen', 'hoehenmeter'
    :type body: dict | bytes

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]]
    """
    if not connexion.request.is_json:
        logging.error("Falsche Eingabe: JSON erwartet")
        return {"message": "JSON erwartet"}, 400

    data = connexion.request.get_json()

    if not all(k in data for k in ("id", "kmgelaufen", "hoehenmeter")):
        logging.error("Felder 'id', 'kmgelaufen' und 'hoehenmeter' sind erforderlich")
        return {"message": "Felder 'id', 'kmgelaufen' und 'hoehenmeter' sind erforderlich"}, 400

    try:
        user_id = int(data["id"])
        kmgelaufen = float(data["kmgelaufen"])
        hoehenmeter = float(data["hoehenmeter"])
    except (ValueError, TypeError):
        logging.error("Ungültige Datentypen für 'id', 'kmgelaufen' oder 'hoehenmeter'")
        return {"message": "Ungültige Datentypen für 'id', 'kmgelaufen' oder 'hoehenmeter'"}, 400

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("SELECT kmgelaufen, hoehenmeter FROM user WHERE id = ?", (user_id,))
    row = cur.fetchone()

    cur.execute(
        "UPDATE user SET kmgelaufen = ?, hoehenmeter = ? WHERE id = ?",
        (row[0] + kmgelaufen, row[1] + hoehenmeter, user_id)
    )

    conn.commit()
    cur.close()

    logging.info(f"Statistiken für User ID {user_id} aktualisiert: kmgelaufen={row[0] + kmgelaufen}, hoehenmeter={row[1] + hoehenmeter}")
    return "Erfolg", 200

# Logging included
def user_login(benutzername, passwort):  # noqa: E501
    """Prüft, ob ein User existiert, gibt Integer ID zurück (-1, wenn User nicht vorhanden)

     # noqa: E501

    :param benutzername: 
    :type benutzername: str
    :param passwort: 
    :type passwort: str

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT passwort FROM user WHERE benutzername = ?", (benutzername,))
    currentPasswort = cur.fetchone()[0]
    print(passwort)
    print(currentPasswort)
    if (bcrypt.checkpw(passwort.encode(), currentPasswort.encode())):
        cur.execute("SELECT id FROM user WHERE benutzername = ?", (benutzername,))
    else:
        logging.warning(f"Login fehlgeschlagen für User {benutzername}: Passwort ist falsch!")
        return -1, 404
    row = cur.fetchone()
    if row:
        logging.info(f"User {benutzername} erfolgreich eingeloggt, ID: {row[0]}")
        return row[0], 200
    else:
        logging.warning(f"Login fehlgeschlagen für User {benutzername}")
        return -1, 404

# Logging included
def user_register(body):  # noqa: E501
    """Neuen Benutzer registrieren

     # noqa: E501

    :param user: 
    :type user: dict | bytes

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    user = body
    if connexion.request.is_json:
        user = User.from_dict(connexion.request.get_json())  # noqa: E501

    if not isinstance(user, User):
        logging.error("Falsche Eingabe: User-Objekt im JSON-Format erwartet")
        return {"message": "Wrong input: user object json expected"}, 400

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("SELECT id FROM user WHERE benutzername = ?", (user.benutzername,))
    row = cur.fetchone()
    try:
        if (row[0] != -1):
            logging.warning(f"User {user.benutzername} existiert bereits")
            return "User existiert bereits", 409
    except:
        pass

    try:
        cur.execute(
        "INSERT INTO user (kmgelaufen, hoehenmeter, passwort, benutzername, profilbild) VALUES (?, ?, ?, ?, ?)",
        (0, 0, bcrypt.hashpw(user.passwort.encode(), bcrypt.gensalt()), user.benutzername, user.profilbild)
        )
    except: 
        logging.error("Fehler beim Einfügen des Benutzers in die Datenbank")
        return "Falsche Daten eingegeben", 400
    conn.commit()
    cur.close()
    conn.close()
    logging.info(f"User {user.benutzername} erfolgreich registriert")
    return "Erfolg", 200