# REST-API

## Endpunkte

### GET - get_sammelkarten(userID)
Gibt alle Sammelkarten vom jeweiligen User zurück.

### GET - get_erfolge(userID)
Gibt alle Erfolge vom jeweiligen User zurück und schaut, ob neue dazu gekommen sind (tut sie nur ins return nicht in die DB). Auf der Client Seite werden dann die Lokale und die gerade geholte Liste miteinander verglichen und wenn sie unterschiedlich sind wir mit der POST Methode add_erfolge der neue Erfolg hinzugefügt.

### PUT - update_stats(userID)
Aktualisert die Stats vom User sprich die zurückgelegten km, hoehenmeter, ...

### POST - add_erfolg(userID)

### GET - user_login

### POST - user_register