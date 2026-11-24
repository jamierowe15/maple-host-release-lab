# Endevor promotion model: how the lab maps to it

> **Lab status: modeled.** Endevor (Broadcom) is licensed software. The lab gives you the same controls with stage libraries, IEBCOPY promotion jobs and Git.

## Endevor concepts

- **Environments and stages**, for example DEV (stages 1 and 2) → QA → PROD. Code only moves *up* the map.
- **Elements**: a COBOL program, a JCL member or a copybook. Each is stored with full version history.
- **Systems / subsystems**: how elements are grouped by application.
- **Actions**:
  - RETRIEVE (check out to work on)
  - SIGNOUT/SIGNIN (lock, so two people don't change the same element)
  - ADD/UPDATE
  - **GENERATE** (compile and link using a processor, so the build is always done the same way)
  - **MOVE** (promote to the next stage)
- **Packages**: a group of actions that must be **cast** (frozen), **approved** by the right approver group, then **executed**. Packages can be **backed out**. This is how Endevor enforces SOX change control.

## Lab mapping

| Endevor | This lab |
|---|---|
| Environment / stage | `MPL.DEV.*` → `MPL.QA.*` → `MPL.PROD.*` libraries |
| GENERATE processor | `MPCOMPL` (always builds in DEV, never in QA or PROD) |
| MOVE | `MPPROMOT` (FROM → TO, copies source **and** load together) |
| Package backout | `MPPROMOT` BACKUP step → `MPL.BKUP<stage>.*`, restored by `MPBACKOT` |
| Package approval | ServiceNow CAB / ECAB approval by a different user |
| Change-line tags | `CHG0002` in columns 73–80 of the source |
| Version history | Git commits and tags `v1.0`, `v1.1` |

## The rule worth memorising

**Build once, promote the same binary.** The load module PAT-tested in QA is the exact one that reaches PROD. Recompiling in PROD would mean shipping something nobody tested.
