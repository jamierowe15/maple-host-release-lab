# CHG0002: Emergency change: MPINTCLC v1.1, add numeric edits (fix for INC0001)

Real ServiceNow number: `CHG________`  ·  Linked incident: `INC________`

| Field | Value |
|---|---|
| Type | Emergency |
| Approval | Emergency CAB (change.manager), recorded in the tool. Retrospective full-CAB review at the next meeting |
| Risk | Moderate: a small, contained code change. The alternative (no report, or wrong numbers) is worse |
| Window | Immediately, during the batch window |

**Change:** Activate the `PERFORM 2200-NUMERIC-EDITS` paragraph (lines tagged CHG0002 in columns 73–80). Records with a non-numeric balance or rate are written to REJOUT with a reason, and the run ends RC 4 instead of abending.

**Implementation plan:** Rebuild in DEV (MPCOMPL) → MPPROMOT DEV→QA → MPSTREAM with ENV=QA DATA=PROD → MPPATCMP with ACTUAL=PROD EXPECT=V11PROD (RC 0) → MPPROMOT QA→PROD → MPRESTRT with ENV=PROD DATA=PROD → MPPATCMP (RC 0) → release successors.

**Test evidence:** The QA run on a copy of the failing production input processed 10 records, accepted 8 and rejected 2, and matched baseline V11PROD. The CI regression suite also passed.

**Backout:** MPBACKOT with TO=PROD restores v1.0. Backing out brings the abend back, so the only reason to do it would be if v1.1 itself failed. In that case the stream stays on hold and the business is told the report won't run until it's fixed.
