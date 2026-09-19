-- 1. What day of week tends to have highest fluctuation in price?

-- Links to documentation
-- BigQuery FORMAT_TIMESTAMP documentation:
-- https://cloud.google.com/bigquery/docs/reference/standard-sql/timestamp_functions#format_timestamp

-- BigQuery APPROX_QUANTILES documentation:
-- https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/approximate_aggregate_functions

-- BigQuery IGNORE NULLS documentation:
-- https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/aggregate-function-calls

-- BigQuery OFFSET documentation:
-- https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/operators

SELECT
    FORMAT_TIMESTAMP('%A', TIMESTAMP) AS DAY_OF_WEEK,

    -- Bitcoin Summary Stats
    ROUND(AVG(BTC_RANGE),3) AS BTC_MEAN_RANGE,

    -- APPROX_QUANTILES divides the data into 4 quantiles and returns:
    -- [minimum, Q1 (25%), median (50%), Q3 (75%), maximum]
    -- OFFSET uses zero-based indexing to select the desired quantile.
    ROUND(APPROX_QUANTILES(BTC_RANGE, 4)[OFFSET(1)],3) AS BTC_Q1,
    ROUND(APPROX_QUANTILES(BTC_RANGE, 4)[OFFSET(2)],3) AS BTC_MEDIAN,
    ROUND(APPROX_QUANTILES(BTC_RANGE, 4)[OFFSET(3)],3) AS BTC_Q3,

    -- IQR = Q3 - Q1
    ROUND(APPROX_QUANTILES(BTC_RANGE, 4)[OFFSET(3)]
        - APPROX_QUANTILES(BTC_RANGE, 4)[OFFSET(1)],3) AS BTC_IQR,

    -- Ethereum
    ROUND(AVG(ETH_RANGE),3) AS ETH_MEAN_RANGE,

    -- IGNORE NULLS excludes dates where Ethereum data is unavailable.
    -- This is needed because the LEFT JOIN preserved BTC dates that do not have corresponding ETH dates
    ROUND(APPROX_QUANTILES(ETH_RANGE, 4 IGNORE NULLS)[OFFSET(1)],3) AS ETH_Q1,
    ROUND(APPROX_QUANTILES(ETH_RANGE, 4 IGNORE NULLS)[OFFSET(2)],3) AS ETH_MEDIAN,
    ROUND(APPROX_QUANTILES(ETH_RANGE, 4 IGNORE NULLS)[OFFSET(3)],3) AS ETH_Q3,

    -- IQR = Q3 - Q1
    ROUND(APPROX_QUANTILES(ETH_RANGE, 4 IGNORE NULLS)[OFFSET(3)]
        - APPROX_QUANTILES(ETH_RANGE, 4 IGNORE NULLS)[OFFSET(1)],3) AS ETH_IQR

FROM
    `osu-demo-project-2026-508513.crypto_dataset.crypto_history_combined`

GROUP BY
    DAY_OF_WEEK

ORDER BY
    BTC_MEAN_RANGE DESC;