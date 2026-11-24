# CHG0001: Normal change: deploy MPINTCLC v1.0 (new nightly interest accrual batch)

Real ServiceNow number: `CHG________`  ·  Lab dates: ________

| Field | Value |
|---|---|
| Type | Normal |
| Category | Software |
| Configuration item | MPL Interest Accrual Batch |
| Assignment group / Assigned to | Mainframe HOST Delivery / Jamie Rowe |
| Risk / Impact | Moderate / 3 – Low (new job, no existing process changed) |
| Planned window | Sat 01:00–03:00 ET (outside the nightly batch at 23:30, no online impact) |
| Short description | Deploy new COBOL batch MPINTCLC v1.0 and job stream MPSTREAM to PROD |

**Description / Justification:** The business needs a nightly daily-interest accrual report by account, with control totals for reconciliation. This change installs the new program load module and source in the PROD libraries.

**Implementation plan:**
1. 00:55 Confirm there are no active MPL jobs. Stream on HOLD (in a CA 7 shop: `HOLD` MPLJ010).
2. 01:00 Move the change to Implement and post a start note.
3. 01:05 Submit MPPROMOT with FROM=QA TO=PROD. BACKUP RC ≤ 4, PROMOTE RC 0.
4. 01:15 Confirm the PROD.LOAD member date and size match QA (ISPF 3.4 → member list).
5. 01:20 Verification run: MPSTREAM with ENV=PROD DATA=TEST, then MPPATCMP with EXPECT=V10TEST. RC 0 required.
6. 01:40 Release the stream (CA 7: `RELEASE`, and confirm the job definition points at the PROD JCL member). Post a completion note.

**Test plan / PAT evidence:** QA PAT pass on Day 2 (MPPATCMP RC 0 against baseline V10TEST), Db2 reconciliation 8 / 639,353.84 / 65.54, and the CI build passing on GitHub. Attached.

**Backout plan:** Submit MPBACKOT with TO=PROD to restore `MPL.BKUPPROD.*` (taken in step 3), rerun the verification, and notify the business that the report is delayed. Decision point: if step 5 isn't RC 0 by 02:30, back out.

**Risk and impact analysis:** It's a new job with no downstream consumers yet. The main risk is bad input data, and the program writes rejects instead of failing. *(Day 5 shows this assumption was wrong for non-numeric fields. Keep that in mind for the PIR.)*

## Implementation log (copy into work notes with real times)

| Time | Step | Result |
|---|---|---|
| | | |
