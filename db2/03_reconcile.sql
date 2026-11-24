-- Control-total reconciliation: must match the MPINTCLC trailer
-- (job log messages I101, I103, I104).
-- Expected: ACCEPTED = 8, TOTAL_BALANCE = 639353.84, TOTAL_INTEREST = 65.54
SELECT COUNT(*)                                      AS ACCEPTED,
       SUM(BALANCE)                                  AS TOTAL_BALANCE,
       SUM(ROUND(BALANCE * RATE / 100 / 365, 2))     AS TOTAL_INTEREST
  FROM MPL_ACCRUAL;

-- Interest by branch (what an operations analyst would send to the business)
SELECT BRANCH,
       COUNT(*)                                      AS ACCOUNTS,
       SUM(ROUND(BALANCE * RATE / 100 / 365, 2))     AS DAILY_INTEREST
  FROM MPL_ACCRUAL
 GROUP BY BRANCH
 ORDER BY DAILY_INTEREST DESC;
