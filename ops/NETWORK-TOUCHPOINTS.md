# Network touchpoints for mainframe delivery

A change coordinator doesn't configure the network, but deployments fail on network issues all the time: a firewall rule, an expired certificate, a file transfer that can't connect. These are the paths that matter.

| Path | Protocol / usual port | What uses it | Typical deployment issue |
|---|---|---|---|
| 3270 terminal (TSO/ISPF, CICS) | TN3270 over TCP, 23 (plain) or 992 (TLS) | Operators, developers | TLS/cert errors, a session dropping during a long window |
| Zowe / z/OSMF REST | HTTPS (TLS), site-defined port | VS Code, automation, DevOps pipelines | Expired certificates, proxy or firewall blocking |
| File transfer | FTPS / SFTP (22), Connect:Direct, MFT | Feeds into and out of batch (e.g. `ACCTIN`) | Late or missing file → data-set requirement never met → job stuck in CA 7 request queue |
| Messaging | IBM MQ, usually 1414 | Mainframe ↔ distributed apps, Tandem/NonStop switches | Channel down after a change |
| DB access | Db2 DRDA, site-defined port (often 446 / 50000) | Distributed apps, reconciliation tools | Port or firewall changes |

**Pre-deployment check:** for any change that adds a new feed or partner, confirm the firewall rule, certificate and transfer job definition are **in the same change or a linked change**, and test connectivity (`Test-NetConnection host -Port n`) before the window.

## Lab observations (Day 1)

| Item | Value |
|---|---|
| Z Xplore host (from your Zowe profile) | |
| Port | |
| Test-NetConnection result | |
| TLS version seen in Wireshark | |
| Why the payload isn't readable in Wireshark | |
