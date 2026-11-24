# Lab Guide: Maple Host Release Lab (5 days)

You'll play the **Mainframe Change Coordinator** on a fictional bank's HOST delivery team. Over five days you build a COBOL batch job, test it in a PAT stage, raise and get approval for a change, deploy it overnight, handle a production abend with an emergency change, and close everything out with audit evidence.

Plan on about 3–4 hours a day. Save every piece of evidence listed in a **📸 Evidence** box into `/evidence` and log it in `controls/EVIDENCE-LOG.md`. That log is what makes this a portfolio piece and not just a tutorial you followed.

**Notation.** `Z12345` stands for your IBM Z Xplore user ID. The JCL uses `&SYSUID`, so it fills in your ID by itself. You never need to type it into the JCL.

---

## Day 0: Accounts (about 30 min, do it today)

1. Register for **IBM Z Xplore** (ibm.com/z/resources/zxplore). Approval and your user ID come by email.
2. Install **VS Code** and the **Zowe Explorer** extension, plus **IBM Z Open Editor** for COBOL/JCL highlighting.
3. Register at **developer.servicenow.com** and request a **Personal Developer Instance (PDI)**. Log in at least once every few days, because idle instances get reclaimed after about 10 days.
4. Unzip this kit and double-click **`PUBLISH-TO-GITHUB.cmd`** to publish the repo to GitHub. Then check the **Actions** tab. The `cobol-build` check should go green. To learn the same thing by hand, follow **`GIT-STEP-BY-STEP.md`**.

---

## Day 1: Access, ISPF and allocation

**Goal:** get onto z/OS, find your way around ISPF, and build the DEV/QA/PROD stage libraries.

1. **Z Xplore Fundamentals.** Complete the opening challenges in order. They walk you through connecting VS Code/Zowe to the system, data sets and JCL. Finish all of Fundamentals by Day 5 to earn the badge.
2. **Network check (the "general knowledge of network technology" line).** Before you connect, look up the host and port in your Zowe profile (`zowe.config.json`). Then:
   - In PowerShell, run `Test-NetConnection <host> -Port <port>` and screenshot the result.
   - Run **Wireshark** while Zowe connects. Filter on `tcp.port == <port>` and find the TCP handshake and the TLS Client Hello/Server Hello. Write down the TLS version.
   - Fill in the "Lab observations" table in `ops/NETWORK-TOUCHPOINTS.md`.
3. **Allocate.** In VS Code, open `src/jcl/MPALLOC.jcl`, then right-click → **Submit as JCL**. Open the job output in the Zowe **Jobs** view. You need `RC=0000` (shown in Zowe as `CC 0000`).
4. **Load the data.** Submit `src/jcl/MPLOAD.jcl`. Every step should end `CC 0000`.
5. **Upload the members.** In Zowe's **Data Sets** view:
   - Right-click `Z12345.MPL.DEV.SRC` → **Upload Member** → `src/cobol/MPINTCLC.cbl`. Rename the member to `MPINTCLC`.
   - Upload every file in `src/jcl/` into `Z12345.MPL.JCL`. Drop the `.jcl` extension so the members are named `MPSTREAM`, `MPPATCMP` and so on.
6. **ISPF practice.** Use the TSO/ISPF access that the Z Xplore TSO/ISPF challenge sets up:
   - `=3.4`, enter `Z12345.MPL` and list your libraries. Learn the line commands `B` (browse), `E` (edit) and `I` (info), and check RECFM/LRECL on a SRC versus a LOAD library.
   - `=2` (Edit) on `Z12345.MPL.PROD.ACCTIN`. Type `COLS` on a line to show a column ruler, then find which columns hold the balance.

> 📸 **Evidence:** Test-NetConnection result, the Wireshark handshake, MPALLOC/MPLOAD job output (CC 0000), and a 3.4 listing of your MPL libraries.

---

## Day 2: Build v1.0 and run PAT testing

**Goal:** build the original release (v1.0) in DEV, run it in the batch stream and prove it against a signed-off baseline.

1. **Make v1.0 in ISPF.** The source you uploaded is v1.1. Version 1.0 is the same code without the numeric edits, and every v1.1 line is tagged `CHG0002` in columns 73–80, the old mainframe way of marking changed lines.
   - In ISPF, edit `Z12345.MPL.DEV.SRC(MPINTCLC)`.
   - Run `F CHG0002 73 80` (find, limited to columns 73–80). The cursor lands on `PERFORM 2200-NUMERIC-EDITS`.
   - Put `*` in **column 7** of that line to comment it out. Save with `PF3`.
2. **Compile.** Submit the `MPCOMPL` member. You need `CC 0000` or `CC 0004`. Read the COBOL listing in the job output.
3. **Run in DEV.** Submit `MPSTREAM` with the defaults `ENV=DEV` and `DATA=TEST`. Then:
   - Find the `MPINTCLC I100–I104` messages in STEP030's SYSOUT. Those are your control totals.
   - STEP030 should end **CC 0004**, because one record has a bad account type. Read STEP045's output to see the reject.
4. **PAT compare.** Submit `MPPATCMP` with `ACTUAL=TEST` and `EXPECT=V10TEST`. **CC 0000** means the report matches the baseline exactly, which is a PAT pass. Then try a fail on purpose: set `EXPECT=V11PROD`, resubmit, and look at the differences SuperC lists. Set it back afterwards.
5. **Db2 reconciliation.** Using the Db2 access from the Z Xplore Db2 challenge, run `db2/01`, `02` and then `03`. Your totals must match the COBOL trailer: **8 / 639,353.84 / 65.54**.
   - If your Z Xplore ID isn't allowed to create tables, run the same scripts in free **Db2 Community Edition** (Docker on Windows). Record which one you used. Don't claim the mainframe if you used Docker.
6. **Promote DEV → QA.** Submit `MPPROMOT` with `FROM=DEV` and `TO=QA`. BACKUP may end CC 0004 the first time, because the target is still empty. PROMOTE must end CC 0000.
7. **Run PAT in QA.** Run `MPSTREAM` with `ENV=QA` and `DATA=TEST`, then `MPPATCMP` with `EXPECT=V10TEST`. A pass here (CC 0000) is your **PAT sign-off for CHG0001**.

> 📸 **Evidence:** compile listing summary, the MPSTREAM step return codes, the PAT compare (pass and the deliberate fail), the Db2 reconciliation result, the promotion output, and the QA PAT pass.

---

## Day 3: Scheduling and restart (CA 7 and CA 11 concepts)

**Goal:** understand how a scheduler runs this job stream and how restarts work. CA 7 and CA 11 aren't available outside a licensed shop, so you'll practise the same mechanics with native z/OS features and document how CA 7 and CA 11 would handle each one.

1. Read `scheduling/CA7-JOB-NETWORK.md`. Then set up a **job trigger**:
   - In `MPSTREAM`, uncomment the four `STEP050` lines.
   - Make sure `MPPATCMP` is in `Z12345.MPL.JCL` with `ACTUAL=TEST` and `EXPECT=V10TEST`.
   - Submit `MPSTREAM`. When it finishes, `MPPATCMP` should appear in your job list on its own, submitted through the internal reader. That's a successor job triggered by its predecessor completing successfully.
2. **Find out why STEP020 is guarded by `IF STEP020.RC = 0`.** Temporarily change `SORTIN` to a data set name that doesn't exist. Submit, and see that this gives a **JCL error**: the job fails before any step runs. Then put the name back. Add the difference between a JCL error, a non-zero return code and an abend to your notes.
3. Read `scheduling/CA11-RESTART-RUNBOOK.md`. Then practise a restart:
   - Submit `MPRESTRT` with `DATA=TEST`. It starts at STEP030 and skips cleanup and the sort. It fails if the outputs from the last full run still exist.
   - Read the error, then delete `Z12345.MPL.TEST.RPT` and `.REJ` (in Zowe, right-click → Delete) and resubmit. Your notes should explain why the runbook lists cleanup before restart.
4. Fill in the "Lab notes" section at the bottom of both scheduling documents in your own words.

> 📸 **Evidence:** the triggered `MPPATCMP` job, the JCL error, the failed and then successful restart.

---

## Day 4: Change management and the overnight deployment (ServiceNow)

**Goal:** take v1.0 to production under a properly approved Normal change.

1. **Set up the PDI** by following `change/SERVICENOW-PDI-SETUP.md`. You'll create the users, groups and CI. Approvals must come from a different user than the one who implements: that's segregation of duties.
2. **Raise CHG0001 (Normal).** Copy the fields from `change/CHG0001-normal-change.md` into the change form. Attach the Day 2 PAT evidence.
3. **Move it through the states.** New → Assess → Authorize. To approve, impersonate `cab.approver` and approve the change with a comment, then end the impersonation. Then Scheduled, with a planned window of **Saturday 01:00–03:00**. Write down the real change number ServiceNow gives you.
4. **Implement during the window.** Do steps 4–6 at the time you scheduled. A Friday night is ideal, because overnight support is part of this job.
   - Move the change to **Implement**.
   - Submit `MPPROMOT` with `FROM=QA` and `TO=PROD`.
   - **Post-implementation verification:** run `MPSTREAM` with `ENV=PROD` and `DATA=TEST`, then `MPPATCMP` with `EXPECT=V10TEST`. You need CC 0000.
5. Fill in the work notes with timestamps. Copy the "implementation log" format from `CHG0001-normal-change.md`.
6. Move to **Review** and close with the close code **Successful**.

> 📸 **Evidence:** the approval record showing a different approver, the change in Scheduled with its window, the production promotion output, the verification PAT pass, and the closed change.

---

## Day 5: Production abend, emergency change and PIR

**Goal:** handle a real-looking production incident from start to finish.

1. **First production night.** Run `MPSTREAM` with `ENV=PROD` and `DATA=PROD`. STEP030 should **abend S0C7**. In the job log, look for `CEE3207S ... data exception` and the abend code. STEP040 and STEP045 are bypassed because of the abend.
   - On some compiler settings the program won't abend. Instead it prints a nonsense balance for account 1000100010. That's the same defect showing up as wrong numbers that nobody notices, which is worse. Treat it as the incident either way.
2. **Raise the incident.** Use the INC template in `change/INC0001-s0c7-abend.md`. Set **Caused by Change** to your CHG0001 number. Send the stakeholder update in the template; this is the "promptly communicate, escalate and resolve" accountability.
3. **Find the root cause.** Browse `Z12345.MPL.PROD.SORTED` in ISPF. Turn on `HEX ON` and find the record whose balance columns are `40` (blanks) where they should be `F0`–`F9` (digits). Screenshot it.
4. **Raise CHG0002 (Emergency).** Use `change/CHG0002-emergency-change.md`. Get approval from `change.manager` acting as the ECAB.
5. **Fix and test.** Re-upload the original v1.1 `MPINTCLC.cbl` to `MPL.DEV.SRC`, so the `CHG0002` line is active again. Then:
   - Submit `MPCOMPL`.
   - Promote DEV → QA, then run `MPSTREAM` with `ENV=QA` and `DATA=PROD`.
   - Submit `MPPATCMP` with `ACTUAL=PROD` and `EXPECT=V11PROD`. You need CC 0000. This is the emergency PAT.
6. **Deploy and restart.** Promote QA → PROD. Then submit `MPRESTRT` with `ENV=PROD` and `DATA=PROD`. It restarts at STEP030 and reuses the sorted file from the failed run.
   - STEP030 should end **CC 0004** with two rejects.
   - If there was no abend in step 1, the outputs already exist. Run the full `MPSTREAM` instead.
   - Then submit `MPPATCMP` with `ACTUAL=PROD` and `EXPECT=V11PROD`. CC 0000 means **resolved**.
7. **Backout drill.** This proves the backout plan works, and you run it in **QA**:
   - Submit `MPBACKOT` with `TO=QA`. QA now holds v1.0 again.
   - Run `MPSTREAM` with `ENV=QA` and `DATA=TEST`, then `MPPATCMP` with `EXPECT=V10TEST`. It should pass, which proves the restore.
   - Re-promote DEV → QA to put QA back on v1.1.
8. **Close out.** Resolve the INC. Close CHG0002. Write the PIR in `change/PIR-CHG0002.md`, then fill in `controls/SOX-CONTROL-MATRIX.md` and `controls/EVIDENCE-LOG.md`.
9. **Read the primers.** Go through `ops/IMS-PRIMER.md` and `ops/TANDEM-PRIMER.md`, and answer the interview questions at the end of each in your own words.
10. Commit everything, tag the release as `v1.1`, and push (`GIT-STEP-BY-STEP.md`, Part C).

> 📸 **Evidence:** the S0C7 job log, the HEX view of the bad record, the INC with its CHG link, the emergency approval, the QA PAT pass, the restarted production run, the backout drill, and the PIR.

---

## When you're done

- Update the README with your real change numbers, dates and badge name. Use the resume wording in the README and only claim what you completed.
- Earn the **Z Xplore Fundamentals badge** and add it to LinkedIn.
- **Practise telling the Day 5 story out loud in 2 minutes: abend, incident, root cause, emergency change, restart, PIR.** That's the interview answer for this role.
