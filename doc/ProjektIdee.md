# Team + Projektidee
Jannik und Noah F.

## Wie werden die Mindestanforderungen umgesetzt?
Wir werden das Ganze wahrscheinlich mit Flutter implementieren und die Datenbank voraussichtlich entweder mit einer SQL-DB oder MariaDB umsetzen

## Welche Features sind ein muss
- Wanderung Tracken
- Gipfel als Ziele mit NFC-Chips
- Belohnungen bei scannen von NFC-Chips auf Gipfel
- Belohnung pro gelaufenen km
- Leaderboard
## Welche Features sind Erweiterungen (nice-to-have), wenn genügend Zeit bleibt
- Nachricht auf NFC-Chip speichern und beim nächsten anzeigen
- Google-Ads
- Skins
- Bei Ankunft auf Berg eigenes Foto auf Sammelkarte
- 3D Karten Belohnung mit Animation

## Wie möchten wir das Ganze grob umsetzen
Also es gibt zwei große Mechaniken die wir umsetzen möchten. Die wären 1. Das Scannen der NFC-Chips und 2. Das Tracken via GPS. Diese Funktionen sollen dann mit einem kleinen Sammel/Belohnungs-Spiel verknüpft werden. Die ganzen Stats, also wie weit, welche Strecken und wie viele Punkte man hat, sollten dann benutzerbezogen in der DB gespeichert werden. Auch sollte es einen Tabelle geben die die Berge bzw. Ziele speichert und die dazugehörigen ID, Belohnungen und andere Infos.