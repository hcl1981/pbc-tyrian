#!/usr/bin/env python3
"""
hole_daten.py -- laedt die Tyrian-2.1-Daten und entpackt sie.

Die Daten gehoeren nicht zu diesem Projekt und liegen deshalb nicht im
Repository. Dieses Werkzeug holt sie von der Stelle, an der sie veroeffentlicht
sind, und prueft die Pruefsumme.

Aufruf:
    ./hole_daten.py <zielordner>                     nur entpacken
    ./hole_daten.py <zielordner> --uf2 tyrian-data.uf2   auch das Flash-Archiv bauen

GPLv2, wie OpenTyrian.
"""

import argparse
import hashlib
import io
import os
import subprocess
import sys
import urllib.request
import zipfile

URL = "https://camanis.net/tyrian/tyrian21.zip"
SHA256 = "7790d09a2a3addcd33c66ef063d5900eb81cc9c342f4807eb8356364dd1d9277"


def laden():
    print("lade", URL)
    with urllib.request.urlopen(URL, timeout=120) as antwort:
        daten = antwort.read()
    summe = hashlib.sha256(daten).hexdigest()
    if summe != SHA256:
        sys.exit(f"Pruefsumme stimmt nicht: {summe}\nErwartet wird {SHA256}")
    return daten


def entpacken(daten, ziel):
    os.makedirs(ziel, exist_ok=True)
    with zipfile.ZipFile(io.BytesIO(daten)) as archiv:
        for eintrag in archiv.infolist():
            if eintrag.is_dir():
                continue
            # flach entpacken: der Ordner im Archiv spielt keine Rolle
            name = os.path.basename(eintrag.filename)
            with open(os.path.join(ziel, name), "wb") as datei:
                datei.write(archiv.read(eintrag))


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("ziel", help="Ordner fuer die entpackten Daten")
    ap.add_argument("--uf2", help="zusaetzlich das Flash-Archiv als UF2 erzeugen")
    args = ap.parse_args()

    entpacken(laden(), args.ziel)
    print("entpackt nach", args.ziel)

    if args.uf2:
        mkdata = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mkdata.py")
        subprocess.run([sys.executable, mkdata, args.ziel, "-o", args.uf2], check=True)
        print("erzeugt:", args.uf2)


if __name__ == "__main__":
    main()
