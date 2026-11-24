# Maple Host Release Lab

![cobol-build](https://github.com/jamierowe15/maple-host-release-lab/actions/workflows/cobol-build.yml/badge.svg)

A hands-on **mainframe change and release management lab**. A COBOL batch program goes from build through PAT testing, change approval, an overnight production deployment, a production abend, an emergency fix, a step restart and a post-implementation review. The mainframe work runs on real IBM z/OS through **IBM Z Xplore**, and the change management runs in a **ServiceNow** developer instance.

*Maple is a fictional bank. No real bank systems, data or procedures are used.*

## The scenario

The HOST delivery team is releasing **MPINTCLC**, a nightly COBOL batch that calculates daily interest by account, writes a report and a reject file, and produces control totals.

1. **v1.0** is built in DEV, PAT-tested in QA against a signed-off baseline, approved through CAB (CHG0001) and deployed in a Saturday 01:00 window.
2. On its first production run, a record with a blank balance causes an **S0C7 abend**.
3. The issue goes through an incident (INC0001), root cause in a hex dump, an **emergency change** (CHG0002, v1.1), an emergency PAT, promotion, a **restart from the failed step** and a PIR.

## How it maps to the job requirements

| Requirement | Where in the lab | Level |
|---|---|---|
| PAT environment testing | `MPPATCMP` (SuperC against signed-off baselines in QA), CI regression suite | **Hands-on** |
| Change creation and coordination | CHG0001 Normal + CHG0002 Emergency in ServiceNow, CAB/ECAB approvals | **Hands-on** |
| Deployment and release management | `MPPROMOT` DEV→QA→PROD, backup before every move, `MPBACKOT` backout drill | **Hands-on** |
| SOX audit controls and change procedures | `controls/SOX-CONTROL-MATRIX.md`, segregation of duties, evidence log | **Hands-on** |
| Overnight/weekend deployment support | Deployment run in a scheduled Sat 01:00–03:00 window | **Hands-on** (simulated window) |
| JCL | 8 jobs: allocation, data load, compile, batch stream with IF/THEN, PAT compare, promote, backout, restart | **Hands-on** |
| COBOL | `src/cobol/MPINTCLC.cbl`: validation, packed-decimal maths, control totals, return codes | **Hands-on** |
| ISPF | 3.4 data set lists, column-limited FIND, editing source, HEX browse for root cause | **Hands-on** |
| Db2 | Control-total reconciliation SQL (`db2/`) | **Hands-on** |
| ServiceNow | Change, incident, CMDB CI, approvals | **Hands-on** |
| CA 7 | Job network model + a working predecessor/successor trigger through the internal reader | **Modeled** (CA 7 is licensed) |
| CA 11 | Restart runbook + practised `RESTART=` step restart with cleanup rules | **Modeled** (CA 11 is licensed) |
| Endevor | Stage/promotion model mapped to libraries, IEBCOPY moves, approvals and tags | **Modeled** (Endevor is licensed) |
| IMS | `ops/IMS-PRIMER.md` | Concept |
| Network technology | Port testing, Wireshark TLS capture, delivery network touchpoints | **Hands-on** |
| Mainframe + Tandem workload | `ops/TANDEM-PRIMER.md` | Concept |
| Communicate, escalate, resolve | Incident stakeholder update, timeline, PIR actions | **Hands-on** |

## Repository layout

```
src/cobol/      MPINTCLC.cbl (v1.1; CHG0002 lines tagged in columns 73-80)
src/jcl/        MPALLOC MPLOAD MPCOMPL MPSTREAM MPRESTRT MPPATCMP MPPROMOT MPBACKOT
data/           test + production input, signed-off expected results
db2/            reconciliation table, rows and queries
scheduling/     CA 7 job network, CA 11 restart runbook
endevor/        promotion model
change/         ServiceNow setup, CHG0001, INC0001, CHG0002, PIR
controls/       SOX control matrix, evidence log
ops/            network touchpoints, IMS and Tandem primers
scripts/        local GnuCOBOL build + regression, data-load JCL generator
PUBLISH-TO-GITHUB.cmd   one-click publish (double-click on Windows)
GIT-STEP-BY-STEP.md     the same process by hand, plus the daily lab Git workflow
evidence/       your screenshots and exports
```

**Build gate:** every push compiles the program with GnuCOBOL and checks it against the expected results (`.github/workflows/cobol-build.yml`). Run it locally in WSL or Linux with `scripts/local-build.sh v1.1 PRODDATA`.

Start with **[LAB-GUIDE.md](LAB-GUIDE.md)**.

## Results (run on IBM Z Xplore, 2026-11-23)

- Every job ran on real z/OS; full job logs and a step-by-step table are in evidence/auto-run (AUTO-RUN-SUMMARY.md)
- PAT: QA v1.0 vs V10TEST CC 0000 · production verification CC 0000 · emergency PAT v1.1 vs V11PROD CC 0000 · backout drill PAT CC 0000
- Production defect: on this system's COBOL settings v1.0 did not abend - it accepted a blank balance as 0.00 for account 1000100010 and ended RC 4 with totals that still balanced (evidence/D5-v10-wrong-balance.png). v1.1 rejects it as BALANCE NOT NUMERIC
- Detection lesson: the Ops Automation Lab's message monitor classed the run as RC 4 / NOTIFY - only the PAT comparison against a signed-off baseline exposed the data defect
- IBM Z Xplore: VSC1 complete; Fundamentals badge in progress
- ServiceNow records: to be added


