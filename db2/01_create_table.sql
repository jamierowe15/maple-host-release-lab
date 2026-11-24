-- Maple Host Release Lab - Db2 reconciliation table
-- Holds the accepted accounts from the nightly run so control totals
-- can be checked independently of the COBOL report (a SOX-style control).
-- On IBM Z Xplore, use the Db2 connection from the Db2 challenge and
-- prefix the table with the schema you were given if CREATE needs one.
CREATE TABLE MPL_ACCRUAL (
    ACCT_NO     CHAR(10)      NOT NULL,
    ACCT_TYPE   CHAR(2)       NOT NULL,
    BALANCE     DECIMAL(11,2) NOT NULL,
    RATE        DECIMAL(5,4)  NOT NULL,
    BRANCH      CHAR(5)       NOT NULL,
    PRIMARY KEY (ACCT_NO)
);
