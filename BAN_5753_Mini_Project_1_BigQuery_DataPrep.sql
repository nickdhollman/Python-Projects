-- ============================================================
-- BAN 5753 Mini Project 1
-- Nicholas Hollman
--
-- BigQuery SQL used to create supporting analytical tables
-- for the Bitcoin (BTC) and Ethereum (ETH) comparison.
-- ============================================================


-- ============================================================
-- 1. Historical Return Comparison
-- Creates 1-year, 3-year, and 5-year historical return metrics
-- for BTC and ETH using common investment periods.
-- ============================================================

CREATE OR REPLACE TABLE
  `osu-demo-project-2026-508513.crypto_dataset.historical_return_comparison`
AS

WITH prices AS (
    SELECT
        DATE(TIMESTAMP) AS price_date,
        BTC_CLOSE,
        ETH_CLOSE
    FROM `osu-demo-project-2026-508513.crypto_dataset.crypto_history_combined`
    WHERE BTC_CLOSE IS NOT NULL
      AND ETH_CLOSE IS NOT NULL
),

end_date AS (
    SELECT MAX(price_date) AS max_date
    FROM prices
),

periods AS (
    SELECT 1 AS period_order, '1 Year' AS period,
           DATE_SUB(max_date, INTERVAL 1 YEAR) AS target_date
    FROM end_date

    UNION ALL

    SELECT 2, '3 Years',
           DATE_SUB(max_date, INTERVAL 3 YEAR)
    FROM end_date

    UNION ALL

    SELECT 3, '5 Years',
           DATE_SUB(max_date, INTERVAL 5 YEAR)
    FROM end_date
),

starting_prices AS (
    SELECT
        p.period_order,
        p.period,
        ARRAY_AGG(
            STRUCT(
                d.price_date,
                d.BTC_CLOSE,
                d.ETH_CLOSE
            )
            ORDER BY ABS(DATE_DIFF(d.price_date, p.target_date, DAY))
            LIMIT 1
        )[OFFSET(0)] AS start
    FROM periods p
    CROSS JOIN prices d
    GROUP BY p.period_order, p.period
),

ending_prices AS (
    SELECT
        price_date,
        BTC_CLOSE,
        ETH_CLOSE
    FROM prices
    ORDER BY price_date DESC
    LIMIT 1
)

SELECT
    s.period_order,
    s.period,
    s.start.price_date AS start_date,
    e.price_date AS end_date,

    ROUND(s.start.BTC_CLOSE, 2) AS BTC_start_price,
    ROUND(e.BTC_CLOSE, 2) AS BTC_end_price,
    ROUND(
        ((e.BTC_CLOSE / s.start.BTC_CLOSE) - 1) * 100,
        2
    ) AS BTC_return_pct,

    ROUND(s.start.ETH_CLOSE, 2) AS ETH_start_price,
    ROUND(e.ETH_CLOSE, 2) AS ETH_end_price,
    ROUND(
        ((e.ETH_CLOSE / s.start.ETH_CLOSE) - 1) * 100,
        2
    ) AS ETH_return_pct

FROM starting_prices s
CROSS JOIN ending_prices e;


-- ============================================================
-- 2. Normalized Growth Comparison
-- Normalizes BTC and ETH closing prices to a common starting
-- value of 100 for comparison of relative historical growth.
-- ============================================================

CREATE OR REPLACE TABLE
  `osu-demo-project-2026-508513.crypto_dataset.normalized_growth_comparison`
AS

WITH prices AS (
    SELECT
        DATE(TIMESTAMP) AS price_date,
        BTC_CLOSE,
        ETH_CLOSE
    FROM `osu-demo-project-2026-508513.crypto_dataset.crypto_history_combined`
    WHERE BTC_CLOSE IS NOT NULL
      AND ETH_CLOSE IS NOT NULL
),

starting_prices AS (
    SELECT
        price_date AS start_date,
        BTC_CLOSE AS BTC_start_price,
        ETH_CLOSE AS ETH_start_price
    FROM prices
    ORDER BY price_date
    LIMIT 1
)

SELECT
    p.price_date,

    ROUND(p.BTC_CLOSE, 2) AS BTC_close,
    ROUND(p.ETH_CLOSE, 2) AS ETH_close,

    ROUND(
        (p.BTC_CLOSE / s.BTC_start_price) * 100,
        2
    ) AS BTC_normalized_growth,

    ROUND(
        (p.ETH_CLOSE / s.ETH_start_price) * 100,
        2
    ) AS ETH_normalized_growth

FROM prices p
CROSS JOIN starting_prices s

ORDER BY p.price_date;


-- ============================================================
-- 3. Daily Percentage Return Comparison
-- Calculates the daily percentage change in closing price for
-- BTC and ETH using the previous day's closing price.
-- ============================================================

CREATE OR REPLACE TABLE
  `osu-demo-project-2026-508513.crypto_dataset.daily_return_comparison`
AS

WITH prices AS (
    SELECT
        DATE(TIMESTAMP) AS price_date,
        BTC_CLOSE,
        ETH_CLOSE,

        LAG(BTC_CLOSE) OVER (
            ORDER BY TIMESTAMP
        ) AS previous_BTC_close,

        LAG(ETH_CLOSE) OVER (
            ORDER BY TIMESTAMP
        ) AS previous_ETH_close

    FROM `osu-demo-project-2026-508513.crypto_dataset.crypto_history_combined`

    WHERE BTC_CLOSE IS NOT NULL
      AND ETH_CLOSE IS NOT NULL
)

SELECT
    price_date,

    ROUND(BTC_CLOSE, 2) AS BTC_close,
    ROUND(previous_BTC_close, 2) AS previous_BTC_close,

    ROUND(
        ((BTC_CLOSE / previous_BTC_close) - 1) * 100,
        2
    ) AS BTC_daily_return_pct,

    ROUND(ETH_CLOSE, 2) AS ETH_close,
    ROUND(previous_ETH_close, 2) AS previous_ETH_close,

    ROUND(
        ((ETH_CLOSE / previous_ETH_close) - 1) * 100,
        2
    ) AS ETH_daily_return_pct

FROM prices

WHERE previous_BTC_close IS NOT NULL
  AND previous_ETH_close IS NOT NULL

ORDER BY price_date;


-- ============================================================
-- 4. Risk Comparison
-- Creates 1-year, 3-year, and 5-year average daily price
-- change metrics for BTC and ETH using absolute daily returns.
-- ============================================================

-- Create BTC vs. ETH risk comparison table

CREATE OR REPLACE TABLE
  `osu-demo-project-2026-508513.crypto_dataset.risk_comparison`
AS

WITH end_date AS (
    SELECT MAX(price_date) AS max_date
    FROM `osu-demo-project-2026-508513.crypto_dataset.daily_return_comparison`
),

periods AS (
    SELECT
        1 AS period_order,
        '1 Year' AS period,
        DATE_SUB(max_date, INTERVAL 1 YEAR) AS start_date,
        max_date AS end_date
    FROM end_date

    UNION ALL

    SELECT
        2,
        '3 Years',
        DATE_SUB(max_date, INTERVAL 3 YEAR),
        max_date
    FROM end_date

    UNION ALL

    SELECT
        3,
        '5 Years',
        DATE_SUB(max_date, INTERVAL 5 YEAR),
        max_date
    FROM end_date
)

SELECT
    p.period_order,
    p.period,
    p.start_date,
    p.end_date,

    ROUND(AVG(ABS(d.BTC_daily_return_pct)), 2)
        AS BTC_avg_daily_change_pct,

    ROUND(AVG(ABS(d.ETH_daily_return_pct)), 2)
        AS ETH_avg_daily_change_pct

FROM periods p

JOIN `osu-demo-project-2026-508513.crypto_dataset.daily_return_comparison` d
    ON d.price_date BETWEEN p.start_date AND p.end_date

GROUP BY
    p.period_order,
    p.period,
    p.start_date,
    p.end_date

ORDER BY p.period_order;