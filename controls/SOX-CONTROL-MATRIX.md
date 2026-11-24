# SOX-style IT general controls: what this lab demonstrates

Banks are audited on IT general controls (ITGCs) for systems that feed financial reporting. External auditors test these every year, and change management is one of the main areas. The lab practises the change-management and operations controls. Each control is paired with the **evidence an auditor would ask for**.

| # | Control | How the lab meets it | Evidence (in `/evidence`) |
|---|---|---|---|
| C1 | Every production change has an approved change record **before** implementation | CHG0001 reaches Authorize/Scheduled before MPPROMOT to PROD runs | Change PDF with approval timestamp earlier than the job's run time |
| C2 | **Segregation of duties**: the implementer doesn't approve their own change | `jamie.rowe` implements, `cab.approver` / `change.manager` approve | Approval record showing a different user |
| C3 | Changes are **tested** before production, with documented results | PAT in QA with SuperC against signed-off baselines; CI regression | MPPATCMP output RC 0, GitHub Actions run |
| C4 | Production gets the **same build** that was tested | Built only in DEV, then promoted (IEBCOPY) | MPCOMPL output (DEV only), promotion listings |
| C5 | **Backout** capability exists and is tested | BACKUP step before each promotion, MPBACKOT drill | Backup listing, backout drill PAT pass |
| C6 | Emergency changes are approved (ECAB) and **reviewed afterwards** | CHG0002 approved by change.manager, then a PIR | Emergency approval, PIR document |
| C7 | Batch failures are tracked and resolved through incidents | INC0001 with root cause and resolution, linked to its change | Incident PDF |
| C8 | Job **completeness and accuracy** are checked | Control totals reconciled against independent Db2 SQL | I100–I104 messages and the Db2 result |
