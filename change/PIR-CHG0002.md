# Post-implementation review: INC0001 / CHG0001 / CHG0002

**Summary:** A new batch program went into production without validation on numeric input fields. On its first production run, a blank balance from the upstream feed caused an S0C7. Successor jobs were held, so no incorrect data went downstream. An emergency change added the edits, and the job was restarted from the failed step.

## Timeline (fill in with real times)

| Time | Event |
|---|---|
| | Abend detected |
| | Incident raised, stakeholders notified |
| | Root cause found (HEX browse) |
| | CHG0002 approved by ECAB |
| | QA PAT pass |
| | PROD promotion, restart from STEP030 |
| | Incident resolved |

## What went well

- The abend stopped the stream before successors ran, so no bad data went downstream.
- The backup step made backout available at every point.
- Restarting from STEP030 avoided rerunning the sort.

## What to improve, and actions

| # | Action | Owner |
|---|---|---|
| 1 | Add a non-numeric/blank case to every PAT data set for programs that read zoned-decimal fields | HOST Delivery |
| 2 | Add a "field-level input validation reviewed" item to the change checklist | Change coordinator |
| 3 | Ask the upstream feed owner to validate the balance before sending | Data owner |
| 4 | Retrospective review of CHG0002 at the next full CAB | Change manager |
