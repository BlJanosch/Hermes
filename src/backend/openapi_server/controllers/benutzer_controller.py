import connexion
import mariadb
import sys
from typing import Dict
from typing import Tuple
from typing import Union

from openapi_server.models.user import User  # noqa: E501
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
        return user, 200
    else:
        return {"message": "User not found"}, 401
    

def update_stats(body):  # noqa: E501
    """Aktualisiert die Statistiken eines Benutzers, man muss ein Json mitgeben

     # noqa: E501

    :param user: 
    :type user: dict | bytes

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    user = body
    if connexion.request.is_json:
        user = User.from_dict(connexion.request.get_json())  # noqa: E501

    if not isinstance(user, User):
        return {"message": "Wrong input: user object json expected"}, 400

    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
    "UPDATE user SET kmgelaufen = ?, hoehenmeter = ?, passwort = ?, benutzername = ?, profilbild = ? WHERE id = ?",
    (user.kmgelaufen, user.hoehenmeter, user.passwort, user.benutzername, user.profilbild, user.id)
    )

    conn.commit()
    cur.close()

    return "Erfolg", 200


def user_login(benutzername, passwort):  # noqa: E501
    """Prüft, ob ein User existiert, gibt Integer ID zurück (-1, wenn User nicht vorhanden)

     # noqa: E501

    :param benutzername: 
    :type benutzername: str
    :param passwort: 
    :type passwort: str

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    print("hallo")
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("SELECT id FROM user WHERE benutzername = ? AND passwort = ?", (benutzername, passwort))
    row = cur.fetchone()
    if row:
        return row[0], 200
    else:
        return -1, 404


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
        return {"message": "Wrong input: user object json expected"}, 400

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("SELECT id FROM user WHERE benutzername = ? AND passwort = ?", (user.benutzername, user.passwort))
    row = cur.fetchone()
    print(row[0])
    if (row[0] != -1):
        return "User existiert bereits", 409

    try:
        cur.execute(
        "INSERT INTO user (kmgelaufen, hoehenmeter, passwort, benutzername, profilbild) VALUES (?, ?, ?, ?, ?)",
        (0, 0, user.passwort, user.benutzername, user.profilbild)
        )
    except: 
        return "Falsche Daten eingegeben", 400
    conn.commit()
    cur.close()
    conn.close()
    return "Erfolg", 200