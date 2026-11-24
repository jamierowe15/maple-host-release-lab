#!/usr/bin/env bash
# Maple Host Release Lab - local build + regression test with GnuCOBOL.
# Used by GitHub Actions (.github/workflows/cobol-build.yml); also runs in WSL/Linux.
#
#   scripts/local-build.sh v1.1 PRODDATA   -> current source vs data/PRODDATA.txt
#   scripts/local-build.sh v1.0 TESTDATA   -> CHG0002 lines commented out (original release)
#
# It compares the report and rejects against data/expected/ and exits non-zero on any difference.
set -euo pipefail
VERSION="${1:-v1.1}"
DATA="${2:-PRODDATA}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$ROOT/build/$VERSION-$DATA"
rm -rf "$WORK" && mkdir -p "$WORK"

SRC="$WORK/MPINTCLC.cbl"
if [ "$VERSION" = "v1.0" ]; then
  # Recreate the original release: comment out every line tagged CHG0002 in columns 73-80
  sed -E '/^.{72}CHG0002/ s/^(.{6})./\1*/' "$ROOT/src/cobol/MPINTCLC.cbl" > "$SRC"
else
  cp "$ROOT/src/cobol/MPINTCLC.cbl" "$SRC"
fi

cobc -x -std=ibm -o "$WORK/mpintclc" "$SRC"

# z/OS datasets are fixed-length 80-byte records with no line feeds; rebuild that layout.
sort "$ROOT/data/$DATA.txt" | while IFS= read -r l; do printf '%-80.80s' "$l"; done > "$WORK/ACCTIN"

set +e
( cd "$WORK" && DD_ACCTIN="$WORK/ACCTIN" DD_RPTOUT="$WORK/RPTOUT" DD_REJOUT="$WORK/REJOUT" ./mpintclc | tee SYSOUT.txt )
RC=${PIPESTATUS[0]}
set -e
echo "MPINTCLC ended RC=$RC"

fold -w 80 "$WORK/RPTOUT" | sed 's/ *$//' > "$WORK/report.txt"
if [ -s "$WORK/REJOUT" ]; then fold -w 80 "$WORK/REJOUT" | sed 's/ *$//' > "$WORK/rejects.txt"; else : > "$WORK/rejects.txt"; fi

EXP="$ROOT/data/expected/$VERSION-$DATA"
if [ "${UPDATE_EXPECTED:-0}" = "1" ]; then
  mkdir -p "$EXP"; cp "$WORK/report.txt" "$WORK/rejects.txt" "$EXP/"; echo "$RC" > "$EXP/rc.txt"
  echo "Expected results updated in $EXP"; exit 0
fi
diff -u "$EXP/report.txt"  "$WORK/report.txt"
diff -u "$EXP/rejects.txt" "$WORK/rejects.txt"
[ "$RC" = "$(cat "$EXP/rc.txt")" ] || { echo "RC mismatch: expected $(cat "$EXP/rc.txt") got $RC"; exit 1; }
echo "PAT REGRESSION PASSED: $VERSION against $DATA (RC=$RC)"
