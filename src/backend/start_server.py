import mariadb
import sys
import swagger_server.__main__ as server

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

def init_db():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute('''CREATE TABLE IF NOT EXISTS user (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        benutzername VARCHAR(100),
                        passwort VARCHAR(100),
                        profilbild VARCHAR(255),
                        kmgelaufen DOUBLE,
                        hoehenmeter DOUBLE
                      )''')

    cursor.execute('''CREATE TABLE IF NOT EXISTS ziel (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        name VARCHAR(100),
                        hoehe DOUBLE,
                        schwierigkeit INT,
                        bild VARCHAR(255),
                        lat DOUBLE,
                        lng DOUBLE
                      )''')

    conn.commit()
    conn.close()

init_db()
server.main()
