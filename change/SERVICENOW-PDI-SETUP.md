# ServiceNow PDI setup (Day 4, about 45 min)

All of this happens in **your own free Personal Developer Instance**. Nothing in it is real or connected to any bank.

## 1. Check you have admin and Change Management

- Log in as `admin`. If you can't find **Change** in the navigator, check **System Definition → Plugins** for *Change Management – Core* (`com.snc.change_management`).
- If your instance came with a limited role instead of admin, or Change is missing, reset the instance from the developer site.

## 2. Users (User Administration → Users)

| User ID | Name | Roles | Plays |
|---|---|---|---|
| `jamie.rowe` | Jamie Rowe | `itil` | Change requester and implementer (you) |
| `cab.approver` | Casey Approver | `itil`, `approver_user` | CAB approver (Normal changes) |
| `change.manager` | Morgan Manager | `itil`, `change_manager` | Change manager / ECAB (Emergency changes) |

## 3. Groups (User Administration → Groups)

- **Mainframe HOST Delivery**: member `jamie.rowe`. This is the assignment group.
- **Technology CAB**: member `cab.approver`.
- **Emergency CAB**: member `change.manager`.

## 4. Configuration item (Configuration → Applications, or create a `cmdb_ci_appl` record)

- Name: **MPL Interest Accrual Batch**
- Short description: Nightly COBOL batch MPINTCLC, job stream MPSTREAM
- Support group: Mainframe HOST Delivery

## 5. Working the change

- Create it as `jamie.rowe`. Use **Impersonate User** from the user menu.
- When it reaches *Authorize*, impersonate `cab.approver` (Normal) or `change.manager` (Emergency) and approve under **Approvals**, with a comment.
- That record is your **segregation-of-duties evidence**: the implementer didn't approve their own change.
- Export each closed change to PDF (right-click the form header → Export → PDF) and save it in `/evidence`.

Normal change states: **New → Assess → Authorize → Scheduled → Implement → Review → Closed**.
