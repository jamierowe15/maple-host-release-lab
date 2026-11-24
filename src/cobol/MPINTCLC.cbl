       IDENTIFICATION DIVISION.
       PROGRAM-ID. MPINTCLC.
      *----------------------------------------------------------------
      * MAPLE HOST RELEASE LAB - DAILY INTEREST ACCRUAL BATCH
      * READS THE SORTED ACCOUNT EXTRACT, VALIDATES EACH RECORD,
      * CALCULATES ONE DAY OF INTEREST AND WRITES A REPORT PLUS A
      * REJECT FILE.  CONTROL TOTALS GO TO SYSOUT FOR RECONCILIATION.
      *
      * RETURN CODES:  0 = CLEAN RUN
      *                4 = RUN COMPLETED, REJECTS WRITTEN
      *               16 = FILE OPEN ERROR
      *
      * CHANGE LOG (DETAIL IN /change):
      *   V1.0 CHG0001  INITIAL RELEASE
      *   V1.1 CHG0002  EMERGENCY FIX - NUMERIC EDITS ON BALANCE/RATE
      *                 (LINES TAGGED CHG0002 IN COLUMNS 73-80)
      *----------------------------------------------------------------
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCT-FILE ASSIGN TO ACCTIN
               FILE STATUS IS WS-ACCT-STATUS.
           SELECT RPT-FILE  ASSIGN TO RPTOUT
               FILE STATUS IS WS-RPT-STATUS.
           SELECT REJ-FILE  ASSIGN TO REJOUT
               FILE STATUS IS WS-REJ-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  ACCT-FILE RECORDING MODE F.
       01  ACCT-REC.
           05 AR-ACCT-NO         PIC X(10).
           05 AR-ACCT-TYPE       PIC X(02).
              88 AR-TYPE-VALID          VALUE 'CH' 'SV'.
              88 AR-TYPE-SAVINGS        VALUE 'SV'.
           05 AR-BALANCE         PIC 9(9)V99.
           05 AR-RATE            PIC 9V9999.
           05 AR-BRANCH          PIC X(05).
           05 FILLER             PIC X(47).
       FD  RPT-FILE RECORDING MODE F.
       01  RPT-REC               PIC X(80).
       FD  REJ-FILE RECORDING MODE F.
       01  REJ-REC               PIC X(80).
       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS.
           05 WS-ACCT-STATUS     PIC XX.
           05 WS-RPT-STATUS      PIC XX.
           05 WS-REJ-STATUS      PIC XX.
       01  WS-SWITCHES.
           05 WS-EOF-SW          PIC X VALUE 'N'.
              88 END-OF-FILE            VALUE 'Y'.
           05 WS-VALID-SW        PIC X VALUE 'Y'.
              88 RECORD-VALID           VALUE 'Y'.
              88 RECORD-INVALID         VALUE 'N'.
       01  WS-COUNTERS.
           05 WS-READ-CNT        PIC 9(7) COMP-3 VALUE 0.
           05 WS-GOOD-CNT        PIC 9(7) COMP-3 VALUE 0.
           05 WS-REJ-CNT         PIC 9(7) COMP-3 VALUE 0.
       01  WS-AMOUNTS.
           05 WS-DAILY-INT       PIC 9(9)V99   COMP-3 VALUE 0.
           05 WS-TOT-BAL         PIC 9(11)V99  COMP-3 VALUE 0.
           05 WS-TOT-INT         PIC 9(11)V99  COMP-3 VALUE 0.
       01  WS-REJ-REASON         PIC X(20).
       01  WS-DISP-CNT           PIC Z,ZZZ,ZZ9.
       01  WS-DISP-AMT           PIC ZZ,ZZZ,ZZZ,ZZ9.99.
      *---------------------------- REPORT LINES ----------------------
       01  HDR-LINE-1.
           05 FILLER PIC X(44)
              VALUE 'MAPLE HOST LAB - DAILY INTEREST ACCRUAL RPT'.
           05 FILLER PIC X(36) VALUE 'PGM: MPINTCLC'.
       01  HDR-LINE-2.
           05 FILLER PIC X(12) VALUE 'ACCOUNT'.
           05 FILLER PIC X(06) VALUE 'TYPE'.
           05 FILLER PIC X(16) VALUE '       BALANCE'.
           05 FILLER PIC X(08) VALUE '  RATE'.
           05 FILLER PIC X(38) VALUE '  DAILY INTEREST'.
       01  DTL-LINE.
           05 DL-ACCT-NO         PIC X(10).
           05 FILLER             PIC X(02) VALUE SPACES.
           05 DL-ACCT-TYPE       PIC X(02).
           05 FILLER             PIC X(04) VALUE SPACES.
           05 DL-BALANCE         PIC ZZZ,ZZZ,ZZ9.99.
           05 FILLER             PIC X(02) VALUE SPACES.
           05 DL-RATE            PIC 9.9999.
           05 FILLER             PIC X(05) VALUE SPACES.
           05 DL-INTEREST        PIC ZZ,ZZZ,ZZ9.99.
           05 FILLER             PIC X(22) VALUE SPACES.
       01  TRL-COUNT-LINE.
           05 TC-LABEL           PIC X(20).
           05 TC-VALUE           PIC Z,ZZZ,ZZ9.
           05 FILLER             PIC X(51) VALUE SPACES.
       01  TRL-AMT-LINE.
           05 TA-LABEL           PIC X(20).
           05 TA-VALUE           PIC ZZ,ZZZ,ZZZ,ZZ9.99.
           05 FILLER             PIC X(43) VALUE SPACES.
       01  REJ-LINE.
           05 RJ-REASON          PIC X(20).
           05 RJ-DATA            PIC X(60).
       PROCEDURE DIVISION.
       0000-MAINLINE.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-PROCESS-RECORD UNTIL END-OF-FILE
           PERFORM 3000-FINALIZE
           STOP RUN.
      *----------------------------------------------------------------
       1000-INITIALIZE.
           OPEN INPUT  ACCT-FILE
                OUTPUT RPT-FILE
                OUTPUT REJ-FILE
           IF WS-ACCT-STATUS NOT = '00' OR WS-RPT-STATUS NOT = '00'
              OR WS-REJ-STATUS NOT = '00'
              DISPLAY 'MPINTCLC E001 FILE OPEN ERROR  ACCTIN='
                      WS-ACCT-STATUS ' RPTOUT=' WS-RPT-STATUS
                      ' REJOUT=' WS-REJ-STATUS
              MOVE 16 TO RETURN-CODE
              STOP RUN
           END-IF
           WRITE RPT-REC FROM HDR-LINE-1
           WRITE RPT-REC FROM HDR-LINE-2
           PERFORM 8000-READ-ACCT.
      *----------------------------------------------------------------
       2000-PROCESS-RECORD.
           SET RECORD-VALID TO TRUE
           PERFORM 2100-VALIDATE
           IF RECORD-VALID
              PERFORM 2300-CALC-AND-REPORT
           ELSE
              PERFORM 2400-WRITE-REJECT
           END-IF
           PERFORM 8000-READ-ACCT.
      *----------------------------------------------------------------
       2100-VALIDATE.
           IF AR-ACCT-NO = SPACES
              SET RECORD-INVALID TO TRUE
              MOVE 'MISSING ACCOUNT NO' TO WS-REJ-REASON
           END-IF
           IF RECORD-VALID AND NOT AR-TYPE-VALID
              SET RECORD-INVALID TO TRUE
              MOVE 'INVALID ACCT TYPE' TO WS-REJ-REASON
           END-IF
           PERFORM 2200-NUMERIC-EDITS                                   CHG0002
           .
      *----------------------------------------------------------------
      * CHG0002: WITHOUT THESE EDITS A BLANK OR NON-NUMERIC BALANCE
      * REACHES THE COMPUTE BELOW AND ABENDS S0C7 (DATA EXCEPTION).
       2200-NUMERIC-EDITS.
           IF RECORD-VALID AND AR-BALANCE NOT NUMERIC
              SET RECORD-INVALID TO TRUE
              MOVE 'BALANCE NOT NUMERIC' TO WS-REJ-REASON
           END-IF
           IF RECORD-VALID AND AR-RATE NOT NUMERIC
              SET RECORD-INVALID TO TRUE
              MOVE 'RATE NOT NUMERIC' TO WS-REJ-REASON
           END-IF.
      *----------------------------------------------------------------
       2300-CALC-AND-REPORT.
           COMPUTE WS-DAILY-INT ROUNDED =
                   AR-BALANCE * AR-RATE / 100 / 365
           ADD 1            TO WS-GOOD-CNT
           ADD AR-BALANCE   TO WS-TOT-BAL
           ADD WS-DAILY-INT TO WS-TOT-INT
           MOVE AR-ACCT-NO   TO DL-ACCT-NO
           MOVE AR-ACCT-TYPE TO DL-ACCT-TYPE
           MOVE AR-BALANCE   TO DL-BALANCE
           MOVE AR-RATE      TO DL-RATE
           MOVE WS-DAILY-INT TO DL-INTEREST
           WRITE RPT-REC FROM DTL-LINE.
      *----------------------------------------------------------------
       2400-WRITE-REJECT.
           ADD 1 TO WS-REJ-CNT
           MOVE WS-REJ-REASON  TO RJ-REASON
           MOVE ACCT-REC(1:60) TO RJ-DATA
           WRITE REJ-REC FROM REJ-LINE.
      *----------------------------------------------------------------
       3000-FINALIZE.
           MOVE SPACES TO RPT-REC
           WRITE RPT-REC
           MOVE 'RECORDS READ'        TO TC-LABEL
           MOVE WS-READ-CNT           TO TC-VALUE
           WRITE RPT-REC FROM TRL-COUNT-LINE
           MOVE 'RECORDS ACCEPTED'    TO TC-LABEL
           MOVE WS-GOOD-CNT           TO TC-VALUE
           WRITE RPT-REC FROM TRL-COUNT-LINE
           MOVE 'RECORDS REJECTED'    TO TC-LABEL
           MOVE WS-REJ-CNT            TO TC-VALUE
           WRITE RPT-REC FROM TRL-COUNT-LINE
           MOVE 'TOTAL BALANCE'       TO TA-LABEL
           MOVE WS-TOT-BAL            TO TA-VALUE
           WRITE RPT-REC FROM TRL-AMT-LINE
           MOVE 'TOTAL INTEREST'      TO TA-LABEL
           MOVE WS-TOT-INT            TO TA-VALUE
           WRITE RPT-REC FROM TRL-AMT-LINE
           MOVE WS-READ-CNT TO WS-DISP-CNT
           DISPLAY 'MPINTCLC I100 RECORDS READ     ' WS-DISP-CNT
           MOVE WS-GOOD-CNT TO WS-DISP-CNT
           DISPLAY 'MPINTCLC I101 RECORDS ACCEPTED ' WS-DISP-CNT
           MOVE WS-REJ-CNT  TO WS-DISP-CNT
           DISPLAY 'MPINTCLC I102 RECORDS REJECTED ' WS-DISP-CNT
           MOVE WS-TOT-BAL  TO WS-DISP-AMT
           DISPLAY 'MPINTCLC I103 TOTAL BALANCE    ' WS-DISP-AMT
           MOVE WS-TOT-INT  TO WS-DISP-AMT
           DISPLAY 'MPINTCLC I104 TOTAL INTEREST   ' WS-DISP-AMT
           CLOSE ACCT-FILE RPT-FILE REJ-FILE
           IF WS-REJ-CNT > 0
              MOVE 4 TO RETURN-CODE
           ELSE
              MOVE 0 TO RETURN-CODE
           END-IF.
      *----------------------------------------------------------------
       8000-READ-ACCT.
           READ ACCT-FILE
              AT END SET END-OF-FILE TO TRUE
              NOT AT END ADD 1 TO WS-READ-CNT
           END-READ.
