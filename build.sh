#!/usr/bin/env bash
#
# Baut OpenTyrian für den PicoBoy Color Plus.
#
# Zwei Schritte: erst die Firmware, dann das Datenarchiv aus den
# Tyrian-2.1-Daten. Die Daten liegen nicht im Repository, sondern werden beim
# ersten Bau von camanis.net geladen (pbc-tyrian/tools/hole_daten.py). Firmware
# und Daten liegen an verschiedenen Flash-Adressen (0x10000000 bzw. 0x10100000).
#
# Aufruf:   ./build.sh          bauen
#           ./build.sh clean    Bauordner löschen und neu bauen
#
# Ergebnis: dist/tyrian.uf2                nur die Firmware, weitergebbar
#           build-out/tyrian-komplett.uf2   Firmware + Daten, nur für dich:
#                                           die Datei enthält die Spieldaten
#                                           und gehört nicht in Repo oder Release
#
# Wer nur an der Firmware arbeitet, flasht tyrian.uf2 — das Datenarchiv liegt an
# einer anderen Flash-Adresse und bleibt dabei unangetastet.
#
set -uo pipefail
HIER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${HIER}/tools/pbc_build.sh"

PROJ="${HIER}/pbc-tyrian"
OUT="${HIER}/build-out"

[ "${1:-}" = clean ] && rm -rf "${PROJ}/build" "${OUT}"

pbc_head "tyrian — OpenTyrian, Firmware + Spieldaten"
pbc_need cmake git python3 arm-none-eabi-gcc gcc || exit 1
pbc_sdk || exit 1

if [ ! -d "${HIER}/data/tyrian21" ]; then
    pbc_info "Spieldaten von camanis.net laden"
    if ! python3 "${PROJ}/tools/hole_daten.py" "${HIER}/data/tyrian21"; then
        pbc_err "Die Tyrian-Daten liessen sich nicht laden."
        echo "  Ohne sie lässt sich nur die Firmware bauen, und die zeigt ohne" >&2
        echo "  Daten nichts an." >&2
        exit 1
    fi
fi

pbc_cmake_build "${PROJ}" "${PROJ}/build" || exit 1

mkdir -p "${OUT}"
pbc_info "Spieldaten ins Flash-Archiv packen"
if ! python3 "${PROJ}/tools/mkdata.py" "${HIER}/data/tyrian21" -o "${OUT}/tyrian-data.uf2" >/dev/null; then
    pbc_err "mkdata.py konnte die Spieldaten nicht packen."
    echo "  Prüfe, ob data/tyrian21 vollständig ist." >&2
    exit 1
fi

pbc_info "Firmware und Daten zu einer Datei verschmelzen"
if ! python3 "${PROJ}/tools/merge_uf2.py" "${PROJ}/build/tyrian.uf2" "${OUT}/tyrian-data.uf2" \
        -o "${OUT}/tyrian-komplett.uf2" >/dev/null; then
    pbc_err "merge_uf2.py ist fehlgeschlagen."
    exit 1
fi

pbc_collect "${PROJ}/build/tyrian.uf2" "tyrian.uf2" || exit 1

pbc_verify_dist "tyrian.uf2" || exit 1
pbc_ok "Zum Flashen: ${OUT}/tyrian-komplett.uf2 (nicht weitergeben)"
