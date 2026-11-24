# INC0001: MPLJ030 / MPSTREAM STEP030 abend S0C7 in PROD

Real ServiceNow number: `INC________`  ·  Caused by Change: CHG0001 (real number: `CHG________`)

| Field | Value |
|---|---|
| Priority | 2 – High (nightly report missing, no customer-facing impact) |
| CI | MPL Interest Accrual Batch |
| Assignment group | Mainframe HOST Delivery |

**Symptom:** STEP030 (PGM=MPINTCLC) abended S0C7. Job log: `CEE3207S ... data exception`. STEP040/045 were bypassed. No report was produced.

**Stakeholder update (send within 15 min of detection):**
> MPL nightly interest accrual failed at 0x:xx in the processing step (S0C7, data exception). The report will be late. Successor jobs are held, so no incorrect data has been sent. Investigating under INCxxxx. Next update by 0x:xx.

**Diagnosis notes:**
- Failing record found with ISPF browse, `HEX ON` on `MPL.PROD.SORTED`: account ________ has X'40' (blanks) in columns 13–23 (balance).
- Root cause: v1.0 has no NUMERIC check, so the blank zoned-decimal balance went into the COMPUTE and caused the data exception.
- Why PAT missed it: the test data had no non-numeric amounts. *(PIR action)*

**Resolution:** Emergency change CHG0002 (v1.1) adds the numeric edits. Restarted from STEP030 using MPRESTRT. PAT against V11PROD passed (RC 0). The bad record is now rejected with `BALANCE NOT NUMERIC` and was sent to the data owner.
