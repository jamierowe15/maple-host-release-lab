# CA 11 restart and rerun runbook: MPL nightly accrual

> **Lab status: modeled and practised.** CA 11 Workload Automation Restart and Tracking (Broadcom) is licensed software. In the lab you do the same thing with the native JCL `RESTART=` parameter (`MPRESTRT`) and with `DISP=(NEW,CATLG,DELETE)` so an abending step cleans up after itself.

## What CA 11 does

CA 11 adds a tracking step (its RMS step, program U11RMS) to the front of production jobs. It records every step's outcome and the data sets each step created. When you request a restart from a step, CA 11 **cleans up automatically**: it scratches or uncatalogs data sets the failed step left behind and fixes GDG generations, so the restart doesn't fail with a duplicate data set. Without CA 11, an analyst has to do that cleanup by hand, which is what you practise on Day 3.

## Restart decision table for this stream

| Failure point | Restart from | Cleanup before restart | Notes |
|---|---|---|---|
| STEP010 | Rerun whole job | None | Only deletes, so it's always safe to rerun |
| STEP020 SORT | STEP010 (rerun job) | None | Sorted output is deleted on abend |
| STEP030 abend (e.g. S0C7) | **STEP030** | None (RPT/REJ are deleted on abend) | Fix the data or code first, under an INC or emergency CHG |
| STEP030 RC > 4 | STEP030 | Delete `MPL.<DATA>.RPT` and `.REJ` | Outputs were cataloged at normal end |
| STEP040/045 | STEP040 | None | Read-only print |

## Restart procedure (lab)

1. Find the failing step and the reason in the job log: the abend code, the `CEE` message or the RC.
2. Open or update the **incident**. Don't restart a production job without a ticket.
3. Fix the cause. Data fixes go through the data owner. Code fixes need an **emergency change** (see CHG0002).
4. Clean up according to the table above.
5. Make sure `MPRESTRT` has the same `ENV`/`DATA` values as the failed run, then submit it. In CA 7 / CA 11 this would be a `RESTART` of the job from STEP030.
6. Verify: check the step RCs and run PAT/reconciliation (`MPPATCMP`).
7. Record the restart in the incident work notes, including the time and the person who approved it.

## Lab notes (fill in on Day 3 and Day 5)

- Why the first `MPRESTRT` on Day 3 failed:
- What CA 11 would have done automatically:
- Day 5 restart result:
