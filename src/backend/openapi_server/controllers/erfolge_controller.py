import connexion
import mariadb
from openapi_server.models.erfolg import Erfolg  # noqa: E501
from openapi_server.models.user_erfolg import UserErfolg  # noqa: E501
from openapi_server.models.ziel import Ziel  # noqa: E501
from openapi_server.models.ziel_erreicht import ZielErreicht  # noqa: E501

def get_connection():
    try:
        return mariadb.connect(
            user="root",
            password="Hermes!1234",
            host="127.0.0.1",
            port=3306,
            database="hermes"
        )
    except mariadb.Error as e:
        print(f"DB Verbindung Fehler: {e}")
        raise

def add_erfolg(body):  # noqa: E501
    """Neuen Erfolg zum User hinzufügen"""
    if connexion.request.is_json:
        user_erfolg = UserErfolg.from_dict(connexion.request.get_json())
        try:
            conn = get_connection()
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO user_erfolg (user_id, erfolg_id, datum) VALUES (?, ?, ?)",
                (user_erfolg.user_id, user_erfolg.erfolg_id, user_erfolg.datum)
            )
            conn.commit()
            cursor.close()
            conn.close()
            return None, 201
        except mariadb.Error as e:
            return {"error": str(e)}, 500
    return {"error": "Invalid input"}, 400

def add_erreichtesziel(body):  # noqa: E501
    """Neues erreichtes Ziel hinzufügen"""
    if connexion.request.is_json:
        ziel_erreicht = ZielErreicht.from_dict(connexion.request.get_json())
        try:
            conn = get_connection()
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO ziel_erreicht (user_id, ziel_id, datum) VALUES (?, ?, ?)",
                (ziel_erreicht.user_id, ziel_erreicht.ziel_id, ziel_erreicht.datum)
            )
            conn.commit()
            cursor.close()
            conn.close()
            return None, 201
        except mariadb.Error as e:
            return {"error": str(e)}, 500
    return {"error": "Invalid input"}, 400

def erfolg_get(user_id):  # noqa: E501
    """Alle erreichten Ziele vom jeweiligen User erhalten"""
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT z.id, z.name, z.hoehe, z.schwierigkeit, z.bild, z.lat, z.lng "
            "FROM ziel_erreicht ze "
            "JOIN ziel z ON ze.ziel_id = z.id "
            "WHERE ze.user_id = ?",
            (user_id,)
        )
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        result = [Ziel(
            id=row["id"],
            name=row["name"],
            hoehe=row["hoehe"],
            schwierigkeit=row["schwierigkeit"],
            bild=row["bild"],
            lat=row["lat"],
            lng=row["lng"]
        ) for row in rows]

        return result, 200

    except mariadb.Error as e:
        return {"error": str(e)}, 500

def get_erfolge(user_id):  # noqa: E501
    """Gibt alle Erfolge vom jeweiligen User zurück"""
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT e.id, e.name, e.beschreibung, e.bild "
            "FROM user_erfolg ue "
            "JOIN erfolg e ON ue.erfolg_id = e.id "
            "WHERE ue.user_id = ?",
            (user_id,)
        )
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        result = [Erfolg(
            id=row["id"],
            name=row["name"],
            beschreibung=row["beschreibung"],
            bild=row["bild"]
        ) for row in rows]

        return result, 200

    except mariadb.Error as e:
        return {"error": str(e)}, 500
