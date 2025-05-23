import connexion
import mariadb
import sys
from typing import Dict
from typing import Tuple
from typing import Union

from openapi_server.models.user import User  # noqa: E501
from openapi_server.models.user_bestenliste import UserBestenliste  # noqa: E501
from openapi_server import util

def get_connection():
    try:
        return mariadb.connect(
            user="root",              
            password="dein_passwort",  
            host="localhost",          
            port=3306,
            database="hermes" 
        )
    except mariadb.Error as e:
        print(f"Fehler beim Verbinden zu MariaDB: {e}")
        sys.exit(1)


def bestenliste(user_id, filter):  # noqa: E501
    """Bestenliste nach Filter abrufen

     # noqa: E501

    :param user_id: 
    :type user_id: int
    :param filter: 
    :type filter: str

    :rtype: Union[List[UserBestenliste], Tuple[List[UserBestenliste], int], Tuple[List[UserBestenliste], int, Dict[str, str]]
    """
    conn = get_connection()
    cur = conn.cursor()

    query = """
        SELECT u.id, u.benutzername, s.punkte, s.spiele_gewonnen, s.spiele_verloren
        FROM user u
        JOIN stats s ON u.id = s.user_id
        ORDER BY
    """
    if filter == "punkte":
        query += " s.punkte DESC"
    elif filter == "spiele_gewonnen":
        query += " s.spiele_gewonnen DESC"
    elif filter == "spiele_verloren":
        query += " s.spiele_verloren DESC"
    else:
        query += " s.punkte DESC"

    cur.execute(query)
    rows = cur.fetchall()

    result = []
    for row in rows:
        user_bestenliste = UserBestenliste(
            id=row["id"],
            benutzername=row["benutzername"],
            punkte=row["punkte"],
            spiele_gewonnen=row["spiele_gewonnen"],
            spiele_verloren=row["spiele_verloren"]
        )
        result.append(user_bestenliste)

    cur.close()
    conn.close()

    return result, 200


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

    conn = mariadb.connect(cursorclass=mariadb.cursors.DictCursor)
    cur = conn.cursor()

    cur.execute("SELECT id FROM user WHERE benutzername = ? AND passwort = ?", (benutzername, passwort))
    row = cur.fetchone()
    if row:
        return row['id'], 200
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

    try:
        cur.execute(
        "INSERT INTO user (kmgelaufen, hoehenmeter, passwort, benutzername, userprofilbild) VALUES (?, ?, ?, ?, ?)",
        (0, 0, user.passwort, user.benutzername, user.profilbild)
        )
    except: 
        return "Falsche Daten eingegeben", 400
    conn.commit()
    cur.close()
    conn.close()
    return "Erfolg", 200