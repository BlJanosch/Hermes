import connexion
import mariadb
import datetime
from openapi_server.models.ziel_erreicht_user import ZielErreichtUser
from openapi_server.models.erfolg import Erfolg  # noqa: E501
from openapi_server.models.user_erfolg import UserErfolg  # noqa: E501
from openapi_server.models.ziel import Ziel  # noqa: E501
from openapi_server.models.ziel_erreicht import ZielErreicht  # noqa: E501
from datetime import date

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
            today = datetime.datetime.now()
            today = today.date()
            cursor.execute(
                "INSERT INTO user_erfolg (user_id, erfolg_id, datum) VALUES (?, ?, ?)",
                (user_erfolg.uid, user_erfolg.eid, today)
            )
            conn.commit()
            cursor.close()
            conn.close()
            return "Erfolg", 201
        except mariadb.Error as e:
            return {"error": str(e)}, 500
    return {"error": "Invalid input"}, 400

def add_erreichtesziel(body):  # noqa: E501
    """Neues erreichtes Ziel hinzufügen"""
    if connexion.request.is_json:
        ziel_erreicht = ZielErreicht.from_dict(connexion.request.get_json())
        print(ziel_erreicht)
        try:
            conn = get_connection()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM ziel_erreicht WHERE user_id = ? AND ziel_id = ?",
                           (ziel_erreicht.uid, ziel_erreicht.zid))
            existing_entry = cursor.fetchone()
            if existing_entry:
                return {"error": "Ziel bereits erreicht"}, 400
            cursor.execute(
                "INSERT INTO ziel_erreicht (user_id, ziel_id, datum) VALUES (?, ?, ?)",
                (ziel_erreicht.uid, ziel_erreicht.zid, date.today().isoformat(),)
            )
            conn.commit()
            cursor.close()
            conn.close()
            return None, 201
        except mariadb.Error as e:
            return {"error": "Fehler beim Hinzufügen"}, 500
    return {"error": "Invalid input"}, 400

def get_ziele(user_id):  # noqa: E501
    """Alle erreichten Ziele vom jeweiligen User erhalten"""
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT z.id, z.name, z.hoehe, z.schwierigkeit, z.bild, z.lat, z.lng, ze.datum "
            "FROM ziel_erreicht ze "
            "JOIN ziel z ON ze.ziel_id = z.id "
            "WHERE ze.user_id = ?",
            (user_id,)
        )
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        print(rows)

        result = [ZielErreichtUser(
            id=row["id"],
            name=row["name"],
            hoehe=row["hoehe"],
            schwierigkeit=row["schwierigkeit"],
            bild=row["bild"],
            lat=row["lat"],
            lng=row["lng"],
            datum=row["datum"]
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
            "SELECT e.id, e.name, e.beschreibung, e.schwierigkeit "
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
            beschreibung=row["beschreibung"]
        ) for row in rows]

        return result, 200

    except mariadb.Error as e:
        return {"error": str(e)}, 500
    

def get_allerfolge():  # noqa: E501
    """Gibt alle Erfolge zurück"""
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM erfolg;",
        )
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        result = [Erfolg(
            id=row["id"],
            name=row["name"],
            beschreibung=row["beschreibung"]
        ) for row in rows]

        return result, 200

    except mariadb.Error as e:
        return {"error": str(e)}, 500


def check_erfolge(user_id):  # noqa: E501
    """Schaut, ob ein User einen neuen Erfolg erreicht hat, fügt ihn dann auch hinzu und gibt dann entweder True oder False zurück"""
    newErfolg = False
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT user.kmgelaufen, user.hoehenmeter, COUNT(ziel_erreicht.id) AS ziele_erreicht FROM user LEFT JOIN ziel_erreicht ON user.id = ziel_erreicht.user_id WHERE user.id = ? GROUP BY user.kmgelaufen, user.hoehenmeter;",
            (user_id,)
        )
        data = cursor.fetchone()
        cursor.execute(
            "SELECT erfolg_id FROM user_erfolg WHERE user_id = ?",
            (user_id,)
        )
        erfolge = cursor.fetchall()

        print(data)
        print(erfolge)

        if data['kmgelaufen'] >= 100 and not any(eintrag['erfolg_id'] == 2 for eintrag in erfolge):
            newErfolg = True
            cursor.execute("INSERT INTO user_erfolg (user_id, erfolg_id, datum) VALUES (?, ?, ?)", (user_id, 2, date.today().isoformat(),))
            print("Erfolg freigeschaltet: 100 km gelaufen")
        if data['hoehenmeter'] >= 3000 and not any(eintrag['erfolg_id'] == 3 for eintrag in erfolge):
            newErfolg = True
            cursor.execute("INSERT INTO user_erfolg (user_id, erfolg_id, datum) VALUES (?, ?, ?)", (user_id, 3, date.today().isoformat(),))
            print("Erfolg freigeschaltet: 3000 Höhenmeter erklommen")
        if data['ziele_erreicht'] >= 1 and not any(eintrag['erfolg_id'] == 1 for eintrag in erfolge):
            newErfolg = True
            cursor.execute("INSERT INTO user_erfolg (user_id, erfolg_id, datum) VALUES (?, ?, ?)", (user_id, 1, date.today().isoformat(),))
            print("Erfolg freigeschaltet: 1 Ziele erreicht")
        if data['ziele_erreicht'] >= 10 and not any(eintrag['erfolg_id'] == 9 for eintrag in erfolge):
            newErfolg = True
            cursor.execute("INSERT INTO user_erfolg (user_id, erfolg_id, datum) VALUES (?, ?, ?)", (user_id, 9, date.today().isoformat(),))
            print("Erfolg freigeschaltet: 10 Ziele erreicht")

        conn.commit()
        cursor.close()
        conn.close()

        return newErfolg, 200

    except mariadb.Error as e:
        return {"error": str(e)}, 500

def get_ziel(ziel_id):  # noqa: E501
    """Gibt die Infos eines Zieles zurück"""
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM `ziel` WHERE id = ?;",
            (ziel_id,)
        )
        data = cursor.fetchone()
        cursor.close()
        conn.close()

        print(data)

        if data:
            result = Ziel(
                id=data["id"],
                name=data["name"],
                hoehe=data["hoehe"],
                schwierigkeit=data["schwierigkeit"],
                bild=data["bild"],
                lat=data["lat"],
                lng=data["lng"]
            )
            return result, 200
        else:
            return {"error": "Ziel not found"}, 404

    except mariadb.Error as e:
        return {"error": str(e)}, 500