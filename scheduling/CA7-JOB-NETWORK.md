# CA 7 job network model: MPL nightly accrual

> **Lab status: modeled.** CA 7 Workload Automation (Broadcom) is licensed software with no free sandbox. This file shows how the lab's stream would be defined in CA 7. The dependency logic itself runs for real in the lab, using `IF/THEN` return-code checks and an internal-reader trigger (`MPSTREAM` STEP050).

## What CA 7 does

CA 7 holds the **database of jobs** (where the JCL lives, which CPU, who owns it), **schedules** (which days and times, based on calendars), and **dependencies**. It moves each job through queues: **request** (waiting on requirements) → **ready** → **active** → **prior-run**. It submits JCL only when every requirement is met. If a job ends badly, CA 7 holds the successors so bad data doesn't flow downstream.

## Lab stream as it would run in production (split into jobs)

| Job | Purpose | Lab equivalent | Starts when | Good end |
|---|---|---|---|---|
| MPLJ010 | Clean up prior outputs | STEP010 | Schedule: business days 23:30 (calendar `MPLBUS`) | RC 0 |
| MPLJ020 | Sort the extract | STEP020 | **Job trigger** on MPLJ010 ending normally, plus a **data-set requirement** on `MPL.PROD.ACCTIN` being created by the upstream feed | RC 0 |
| MPLJ030 | MPINTCLC accrual | STEP030 | Triggered by MPLJ020 | RC ≤ 4 (4 = rejects, alert ops) |
| MPLJ040 | Print and distribute | STEP040/045 | Triggered by MPLJ030 | RC 0 |
| MPLJ050 | Reconciliation / PAT check | `MPPATCMP` via INTRDR (STEP050) | Triggered by MPLJ030 | RC 0 |

**Condition-code handling:** MPLJ030 is defined so that RC 4 counts as successful and triggers MPLJ040, but it also sends a console/ServiceNow alert so someone reviews the rejects. Anything above 4, or an abend, holds MPLJ040 and MPLJ050 and pages on-call.

## Operator commands to know (verify against Broadcom docs on the job)

| Command | Use |
|---|---|
| `LQ` / `LRDY` / `LACT` | List jobs in the request / ready / active queues |
| `LREQ` | Show which requirements a waiting job still needs |
| `DEMAND` / `DEMANDH` | Run a job on request (H = put it in hold first) |
| `HOLD` / `RELEASE` | Stop a job from being submitted / let it go |
| `CANCEL` | Remove a job from the queues |
| `RESTART` | Resubmit a failed job from the request queue, usually with CA 11 step restart |

## Change-coordination angle (the part this role owns)

A release that adds or renames a job, or changes a step or condition code, needs a **CA 7 database change in the same change record**. Forgetting it is a classic deployment failure: the new program is in PROD but the scheduler still runs the old JCL. On CHG0001 that's why the implementation plan includes "confirm the schedule and JCL member in the CA 7 job definition." In a real shop you'd also **HOLD** the stream before the window and **RELEASE** it after verification.

## Lab notes (fill in on Day 3)

- What happened when STEP050 triggered MPPATCMP:
- Difference between a JCL error, an RC > 4 and an abend, and how CA 7 would treat each:
