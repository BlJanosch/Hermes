# REST-API

## Endpunkte

### GET - get_erreichteziele(userID)
Gibt alle erreichten Ziele und somit auch die Sammelkarten vom jeweiligen User zurück.

### POST - add_erreichtesziel(userID)
Fügt ein neues erreichtes Ziel hinzu und somit auch eine Sammelkarte.

### GET - get_erfolge(userID)
Gibt alle Erfolge vom jeweiligen User zurück und schaut, ob neue dazu gekommen sind (tut sie nur ins return nicht in die DB). Auf der Client Seite werden dann die Lokale und die gerade geholte Liste miteinander verglichen und wenn sie unterschiedlich sind wir mit der POST Methode add_erfolge der neue Erfolg hinzugefügt.

### PUT - update_stats(userID)
Aktualisert die Stats vom User sprich die zurückgelegten km, hoehenmeter, ...

### POST - add_erfolg(userID)
Neuer Erfolg wird bei einem User hinzugefügt.

### GET - user_login
Prüft, ob ein User existiert oder nicht und gibt dann dementsprechend true oder false zurück.

### POST - user_register
Prüft ob der User bereits existiert und falls nicht, wird ein neuer User angelegt.

### GET - bestenliste(userID, filter)
Gibt die 10 besten aus der jeweiligen Kateogrie und die eigene Position zurück.