import mariadb
import sys
import connexion
from connexion import FlaskApp
from openapi_server import __main__

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
        print(f"Fehler beim Verbinden zu MariaDB: {e}")
        sys.exit(1)

def init_db():
    conn = get_connection()
    cursor = conn.cursor()

    # Nutzer-Tabelle
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS user (
            id INT AUTO_INCREMENT PRIMARY KEY,
            benutzername VARCHAR(100),
            passwort VARCHAR(100),
            profilbild VARCHAR(255),
            kmgelaufen DOUBLE,
            hoehenmeter DOUBLE
        )
    ''')

    # Ziel-Tabelle
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS ziel (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100),
            hoehe DOUBLE,
            schwierigkeit INT,
            bild VARCHAR(255),
            lat DOUBLE,
            lng DOUBLE
        )
    ''')

    # Erfolg-Tabelle
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS erfolg (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100),
            beschreibung TEXT,
            schwierigkeit INTEGER
        )
    ''')

    # User-Erfolg-Tabelle
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS user_erfolg (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT,
            erfolg_id INT,
            datum DATE,
            FOREIGN KEY (user_id) REFERENCES user(id),
            FOREIGN KEY (erfolg_id) REFERENCES erfolg(id)
        )
    ''')

    # Ziel erreicht Tabelle
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS ziel_erreicht (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT,
            ziel_id INT,
            datum DATE,
            FOREIGN KEY (user_id) REFERENCES user(id),
            FOREIGN KEY (ziel_id) REFERENCES ziel(id)
        )
    ''')

    


    conn.commit()
    conn.close()

if __name__ == "__main__":
    init_db()
    __main__.main()
