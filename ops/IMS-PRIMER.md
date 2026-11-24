# IMS primer (concepts only)

> **Lab status: concept.** There's no free IMS sandbox in this lab. If you find an IMS challenge in your Z Xplore list, complete it and update this note.

**IMS** is IBM's hierarchical database and transaction manager. Banks have run core account systems on it for decades.

- **IMS DB**: data is stored as a **tree of segments**. For example, a CUSTOMER root segment has ACCOUNT children, and each ACCOUNT has TRANSACTION children. This is unlike Db2's tables of rows.
- **DL/I calls**: programs read and update the data with calls such as GU (get unique), GN (get next), GNP (get next within parent), ISRT, REPL and DLET.
- **DBD and PSB**: the DBD describes the database structure. The PSB, made of PCBs, says which segments a program can see and what it's allowed to do with them. A PSB or DBD change is a change item in its own right, with an ACBGEN step.
- **IMS TM**: handles online transactions using message queues (MPP regions).
- **BMP**: a batch program that runs alongside online IMS and takes **checkpoints**, so it can restart from its last checkpoint instead of from the beginning.

**Why it matters for change coordination:** an IMS release often includes the program, a PSB/DBD change with ACBGEN, and sometimes an online change (OLC) to apply it without bringing IMS down. All of these have to be sequenced in the implementation plan.

## Interview questions to answer in your own words

1. How is a hierarchical database different from Db2?
2. If MPINTCLC were an IMS BMP, how would restart work differently from the CA 11 step restart in this lab?
3. Why might a program change also need a PSB change?
