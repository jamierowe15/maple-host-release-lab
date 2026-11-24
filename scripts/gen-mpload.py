"""Regenerate src/jcl/MPLOAD.jcl from the files in /data.

Run after changing test data or after refreshing expected results:
    python scripts/gen-mpload.py
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SETS = [
    ("TEST.ACCTIN", "data/TESTDATA.txt", "TEST INPUT - 9 RECORDS (1 BAD ACCOUNT TYPE), UNSORTED"),
    ("PROD.ACCTIN", "data/PRODDATA.txt", "PRODUCTION INPUT - ADDS 1 RECORD WITH A BLANK BALANCE"),
    ("EXP.V10TEST", "data/expected/v1.0-TESTDATA/report.txt", "EXPECTED REPORT: V1.0 PROGRAM ON TEST DATA"),
    ("EXP.V11TEST", "data/expected/v1.1-TESTDATA/report.txt", "EXPECTED REPORT: V1.1 PROGRAM ON TEST DATA"),
    ("EXP.V11PROD", "data/expected/v1.1-PRODDATA/report.txt", "EXPECTED REPORT: V1.1 PROGRAM ON PROD DATA"),
]

out = [
    "//MPLOAD   JOB 1,NOTIFY=&SYSUID",
    "//*-------------------------------------------------------------------",
    "//* LOAD LAB DATA: TEST + PRODUCTION INPUT FILES AND THE SIGNED-OFF",
    "//* EXPECTED REPORTS USED AS PAT BASELINES.  SAFE TO RERUN - EACH",
    "//* DATA SET IS DELETED (IF PRESENT) AND RECREATED.",
    "//* GENERATED FROM /data BY scripts/gen-mpload.py - DO NOT HAND EDIT.",
    "//*-------------------------------------------------------------------",
]
for i, (dsn, src, desc) in enumerate(SETS, 1):
    n = f"{i:02d}"
    out += [
        f"//* {desc}",
        f"//DEL{n}    EXEC PGM=IEFBR14",
        f"//DD1      DD DSN=&SYSUID..MPL.{dsn},DISP=(MOD,DELETE),",
        "//            SPACE=(TRK,(1,1))",
        f"//LOAD{n}   EXEC PGM=IEBGENER",
        "//SYSPRINT DD SYSOUT=*",
        "//SYSIN    DD DUMMY",
        f"//SYSUT2   DD DSN=&SYSUID..MPL.{dsn},DISP=(NEW,CATLG,DELETE),",
        "//            SPACE=(TRK,(1,1)),RECFM=FB,LRECL=80",
        "//SYSUT1   DD *",
    ]
    for line in (ROOT / src).read_text().rstrip("\n").split("\n"):
        if line.startswith(("//", "/*")) or len(line) > 80:
            raise SystemExit(f"{src}: line cannot go in-stream: {line!r}")
        out.append(line.rstrip())
    out.append("/*")

(ROOT / "src/jcl/MPLOAD.jcl").write_text("\n".join(out) + "\n")
print("Wrote src/jcl/MPLOAD.jcl")
