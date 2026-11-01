# OpenTyrian für den PicoBoy Color Plus

Portierung von [OpenTyrian](https://github.com/opentyrian/opentyrian) — dem
quelloffenen Nachbau des Weltraum-Schützen *Tyrian* (1995) — auf den PicoBoy
Color Plus. Einzelspieler und Zweispieler über ein USB-C-Kabel.

```bash
./build.sh          # -> build-out/tyrian-komplett.uf2, dist/tyrian.uf2
```

> **Stand:** Läuft auf dem Gerät. 229 KB Firmware, 468 KB von 512 KB
> statischem RAM, rund 41 KB Heap. Was beim Portieren anzupassen war und wo
> noch Luft ist, steht in [`pbc-tyrian/README.md`](pbc-tyrian/README.md).

## Aufbau

| Ordner | Inhalt |
|---|---|
| `pbc-tyrian/` | die Portierung: Quelltext, CMake, Werkzeuge |
| `data/tyrian21/` | die Spieldaten von Tyrian 2.1, entsteht erst beim Bauen |
| `shots/` | Bildschirmfotos, unter anderem zum Vergleich der Skalierungsverfahren |

## Firmware und Daten

Wie bei Doom liegen die Spieldaten nicht bei. Tyrian 2.1 ist Freeware, die
Weitergabe durch andere Seiten ist aber nicht eindeutig erlaubt.
`pbc-tyrian/tools/hole_daten.py` lädt die Daten deshalb direkt von
[camanis.net](https://camanis.net/tyrian/tyrian21.zip) und prüft die Prüfsumme.

**Selbst bauen:** `./build.sh` lädt die Daten beim ersten Mal und erzeugt
`build-out/tyrian-komplett.uf2` mit Firmware und Daten in einer Datei. Sie ist nur
für dich; bitte nicht weitergeben.

**Nur flashen:** Dafür reicht Python 3:

```bash
python3 pbc-tyrian/tools/hole_daten.py daten --uf2 tyrian-data.uf2
```

Dann erst `tyrian.uf2` und danach `tyrian-data.uf2` per BOOTSEL auf das Gerät
kopieren.

```
0x10000000  Firmware        269 KB
0x10100000  Datenarchiv    8,86 MB
0x10FF8000  Spielstände      16 KB
0x10FFFF00  SDK-Zusatzblock 256 B   <- muss frei bleiben
```

Wer an der Firmware arbeitet, flasht nur `tyrian.uf2`. Das Datenarchiv liegt an einer anderen Adresse und bleibt dabei liegen — das
spart bei jedem Durchlauf das Übertragen von fast 9 MB.

## Lizenz

GPL-2.0, wie OpenTyrian. Die Datei `usblink.c` stammt aus der
rp2040-doom-Portierung für dasselbe Gerät und ist ebenfalls GPL-2.0. Die
Tyrian-Daten sind Freeware von Jason Emery, gehören nicht zu diesem Projekt und
fallen nicht unter die GPL. Siehe `LICENSE`.

## Herkunft und Download

Teil der Sammlung für den PicoBoy Color Plus; Übersicht und
Hardware-Referenz: [pbc-plus](https://github.com/hcl1981/pbc-plus). Die fertige Firmware
(tyrian.uf2, ohne Spieldaten) liegt unter **Releases**. `./build.sh` baut nach `dist/`;
Werkzeuge und SDK siehe [`docs/BAUEN.md`](docs/BAUEN.md).
