# Tandem / HPE NonStop primer (concepts only)

> **Lab status: concept.**

**HPE NonStop**, still called Tandem, is a fault-tolerant platform built so that no single failure stops the system. Banks use it for **real-time payments, ATM and point-of-sale authorization**, where downtime means declined cards.

- **Architecture**: many independent processors with no shared memory. Software runs as **process pairs**: if the primary fails, the backup takes over.
- **Guardian / OSS**: the native OS personality, and a Unix-like one.
- **TACL**: the command interpreter, like a shell.
- **Pathway (TS/MP)**: the transaction-processing environment that manages server classes.
- **Enscribe and NonStop SQL**: the file system and the database.
- **Typical bank flow**: an ATM or POS message arrives at a switch on NonStop, which authorizes it in real time. During the nightly batch, files move to and from the **mainframe** for posting and settlement. That's the "mainframe and tandem application requirements and workload" line in the posting.

**Change-coordination angle:** NonStop changes are usually rolling changes to keep the system available, often one process pair or CPU at a time. They have to be coordinated with mainframe batch windows when files or interfaces change.

## Interview questions to answer in your own words

1. Why would a bank put card authorization on NonStop and posting on the mainframe?
2. What has to be coordinated when a change touches the interface file between them?
