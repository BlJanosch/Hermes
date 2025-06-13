# Dokumentation - Hermes

## Projekttagebuch

| Aufgabe | Zuständiger | Datum |
|-|-|-|
Erster Entwurf von ERM/RM | Jannik & Noah | 30. April |
ERM/RM überarbeitet | Jannik & Noah | 2. Mai |
Klassendiagramm erstellt | Jannik & Noah | 2. Mai |
Entwurf von REST-API (Endpunkte) | Jannik & Noah | 5. Mai |
REST-API Endpunkte, Klassendiagramm und ERM/RM überarbeitet | Jannik & Noah | 6. Mai |
Logo erstellt | Jannik & Noah | 6. Mai
Klassendiagramm und ERM/RM überarbeitet | Jannik & Noah | 7. Mai |
Klassen hinzugefügt zu Flutter | Jannik | 8. Mai |
BottomNavBar designed und zum Projekt hinzugefügt | Jannik | 8. Mai |
Map zur HomePage hinzugefügt (OpenStreetMap) | Jannik | 9. Mai |
Collection Page (Sammelkarten-Seite) hinzugefügt | Noah | 9. Mai |
Location Permition hinzugefügt | Jannik | 9. Mai |
Funktion zum Zoomen zur aktuellen Position hinzugefügt | Jannik | 17. Mai |
Erste Version von Tracking hinzugefügt | Jannik | 17. Mai |
Login- und Settingspage hinzugefügt | Jannik | 17. Mai |
Schriftart geändert | Noah | 19. Mai |
ERM/RM überarbeitet | Jannik & Noah | 21. Mai |
BottomNavBar responsive gemacht | Jannik | 21. Mai |
Problem beim Wechseln der Seiten behoben, da noch auf Widgets in der alten Page zugegriffen wurde | Jannik | 21. Mai |
BottomNavBar verändert | Jannik | 21. Mai |
Appbar zur Einstellungsseite hinzugefügt | Jannik | 21. Mai | 
Backend und Yaml hinzugefügt | Jannik | 21. Mai |
Erfolgcircle hinzugefügt (kleinen Erfolge in der Einstellungsseite) | Jannik | 21. Mai |
Endpunkte ausprogrammiert - Bestenliste und UpdateUser | Noah | 21. Mai |
BenutzerController fertiggestellt | Noah | 23. Mai |
Background-Tracking hinzugefügt | Jannik | 28. Mai |
Tracking wird beim Wechseln der Seiten fortgesetzt | Jannik | 28. Mai |
Login Page responsive gemacht | Jannik | 28. Mai |
BackgroundTracking gefixed | Jannik | 29. Mai |
Login- und Regestrierungsfunktion hinzugefügt | Jannik | 29. Mai |
Chaching hinzugefügt bei Login und Register (shared_preferences) | Jannik | 29. Mai |
SideBar in Einstellungsseite hinzugefügt | Jannik | 29. Mai |
Alle Endpunkte prototypmäßig ausprogrammiert | Noah | 30. Mai |
Daten in Einstellungsseite laden und anzeigen | Jannik | 30. Mai |
Endpunkte umbenannt und DB verbessert | Noah | 1. Juni |
add_erfolg Endpunkt aktualisiert | Noah | 1. Juni |
Freigeschaltete und nicht Freigeschaltete Erfolge zur Einstellungsseite hinzugefügt | Jannik | 1. Juni |
Gelaufene Distand und Berge/Ziele in DB speichern (also wenn man seine Wanderung trackt und dann beendet wird die Distanz in die DB geschrieben) | Jannik | 1. Juni |
Erfolge in der Einstellungsseite responsive gemacht | Jannik | 2. Juni |
Passwort aus dem Cache entfernt | Jannik | 2. Juni |
Bestenliste_Controller fertig gemacht (10 Plätze und den eingeloggten User, wenn er nicht unter den Top 10 ist) | Noah | 4. Juni |
NFC-Reader (Klasse) hinzugefügt | Jannik | 4. Juni |
Hinzufügen Button zur Sammelkarten-Seite hinzugefügt | Noah | 4. Juni |
NFC-Reader in Sammelkarten-Seite integriert | Jannik | 4. Juni |
Hinzufügen Button in Sammelkarten-Seite geändert | Noah | 4. Juni |
Login- und Regestrierungsfunktion in UserManager integriert | Jannik | 4. Juni |
LoadUserData, Erfolge, ... in UserManager integriert | Jannik | 4. Juni |
System erkennt wenn neuer Erfolg freigeschaltet wurde und zeigt diesen an (Settingsseite) | Jannik | 4. Juni |
Globale Variable ServerIP hinzugefügt (Connection via Tailscale) | Jannik | 5. Juni |
Beim Hinzufügen von Sammelkarten wird nun geprüft ob man sich in der Nähe vom Ziel befindet (500 m) | Jannik | 5. Juni |
NFC-Reader Funktion von Klasse in Sammelkarten-Seite integriert | Noah | 5. Juni |
ValidierungsManager in Sammelkarten-Seite integriert (Hinzufügen von Zielen/Sammelkarten) | Noah | 5. Juni |
Erfolg-Abschnitt in Settings-Seite responsive gemacht | Jannik | 5. Juni |
Login Page responsive gemacht | Jannik | 6. Juni |
App prüft bevor dem Starten ob der Server erreichbar ist | Jannik | 6. Juni |
Fixed Bug (CircularProgressIndicator ging nicht weg) | Jannik | 6. Juni |
Leaderboard-Seite hinzugefügt | Jannik | 6. Juni |
Logging zu UserManger und ValidierungsManager hinzugefügt | Jannik | 6. Juni |
Logging zu TrackingService hinzugefügt | Jannik | 6. Juni |
Logging zu Main, ServerOffline und Settings hinzugefügt | Jannik | 6. Juni |
Scrollbar zur Sammelkarten-Seite hinzugefügt | Noah | 6. Juni |
Änderungen am Backend | Noah | 9. Juni |
Sammelkarten-Seite fertig gemacht (coole Effekte, Schwirigkeit und Bilder) | Noah | 9. Juni |
Erster Entwurf von UnitTests | Jannik | 9. Juni |
Filter-Funktion in Sammelkarten-Seite hinzugefügt | Noah | 9. Juni |
Fixed Bug (Platzierung im Leaderboard) | Jannik | 9. Juni |
Logging zu Sammelkarten-Seite hinzugefügt | Jannik | 9. Juni |
Logging zu ErfolgController hinzugefügt | Jannik | 9. Juni |
Logging zu BestenlisteController hinzugefügt | Jannik | 9. Juni |
Logging zu BenutzerController hinzugefügt | Jannik | 9. Juni |
UnitTests für UserManager, ValidierungsManager (KI) | Jannik | 9. Juni |
 
## Projektplanung
Keine Ahnung was hier her kommt

## Umsetzungsdetails#

### Softwarevoraussetzungen (Versionen)
- flutter_map: ^6.0.0
- flutter_svg: ^2.0.0
- latlong2: ^0.9.0
- pdf : ^3.10.6
- path_provider: ^2.1.2
- flutter_map: ^6.0.0    
- flutter_svg: ^2.0.0
- latlong2: ^0.9.0
- pdf: ^3.10.6
- path_provider: ^2.1.2
- cupertino_icons: ^1.0.8
- google_nav_bar: ^5.0.6
- geolocator: ^10.0.0
- flutter_map_location_marker: any
- flutter_background_service: ^5.0.1
- location: ^5.0.0
- http: ^1.2.0
- shared_preferences: ^2.2.2
- flutter_nfc_kit: ^3.3.1
- logger: ^2.0.2

### Umsetzung

#### Tracking


#### Sammelkarten

#### Leaderboard

#### Login/Registrierung

#### Einstellungen

### Probleme und Lösungen

## Softwaretests 

## Bedienungsanleiten
siehe readme.md

## Quellen