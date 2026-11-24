# Automated run of the Maple Host Release Lab, 2026-11-23 21:41

Every job ran on IBM Z Xplore under user Z67944. Full job logs are in this folder.

| Time | Step | Job | Job ID | Result | As expected |
|---|---|---|---|---|---|
| 21:38:00 | Compile v1.0 in DEV | MPCOMPL | JOB06287 | CC 0000 | yes |
| 21:38:10 | Unit run in DEV | MPSTREAM | JOB06288 | CC 0004 | yes |
| 21:38:16 | Promote DEV -> QA | MPPROMOT | JOB06290 | CC 0000 | yes |
| 21:38:26 | QA run, test data | MPSTREAM | JOB06291 | CC 0004 | yes |
| 21:38:31 | PAT v1.0 vs V10TEST | MPPATCMP | JOB06292 | CC 0000 | yes |
| 21:38:37 | Promote QA -> PROD (CHG0001) | MPPROMOT | JOB06293 | CC 0000 | yes |
| 21:38:47 | PROD verification run | MPSTREAM | JOB06294 | CC 0004 | yes |
| 21:38:52 | PROD verification PAT | MPPATCMP | JOB06295 | CC 0000 | yes |
| 21:39:02 | First PROD run, PROD data | MPSTREAM | JOB06297 | CC 0004 | yes |
| 21:39:45 | Compile v1.1 in DEV | MPCOMPL | JOB06300 | CC 0000 | yes |
| 21:39:51 | Promote DEV -> QA | MPPROMOT | JOB06301 | CC 0000 | yes |
| 21:40:01 | QA run on a copy of the failing PROD input | MPSTREAM | JOB06302 | CC 0004 | yes |
| 21:40:06 | Emergency PAT vs V11PROD | MPPATCMP | JOB06303 | CC 0000 | yes |
| 21:40:12 | Promote QA -> PROD (CHG0002) | MPPROMOT | JOB06304 | CC 0000 | yes |
| 21:40:21 | Rerun PROD stream (2 rejects expected) | MPSTREAM | JOB06305 | CC 0004 | yes |
| 21:40:27 | PROD PAT vs V11PROD = resolved | MPPATCMP | JOB06306 | CC 0000 | yes |
| 21:40:42 | Back out QA to v1.0 | MPBACKOT | JOB06310 | CC 0000 | yes |
| 21:40:51 | QA run after backout | MPSTREAM | JOB06311 | CC 0004 | yes |
| 21:40:58 | PAT proves the restore | MPPATCMP | JOB06312 | CC 0000 | yes |
| 21:41:03 | Re-promote v1.1 to QA | MPPROMOT | JOB06313 | CC 0000 | yes |

Still to do by hand: ISPF HEX ON screenshot of the bad record, ServiceNow approvals (as a different user) and closure, the PIR, Wireshark/Test-NetConnection evidence.
