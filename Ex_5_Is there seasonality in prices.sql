-- 2. Is there seasonality?

-- Links to documentation
-- BigQuery EXTRACT documentation:
-- https://cloud.google.com/bigquery/docs/reference/standard-sql/timestamp_functions#extract

SELECT
    -- Extract month number to correctly order January through December
    EXTRACT(MONTH FROM TIMESTAMP) AS MONTH_NUMBER,

    -- Format timestamp to display full month name
    FORMAT_TIMESTAMP('%B', TIMESTAMP) AS MONTH,

    -- Bitcoin Opening Price
    ROUND(AVG(BTC_OPEN),3) AS BTC_MEAN_OPEN,
    --ROUND(APPROX_QUANTILES(BTC_OPEN, 4)[OFFSET(2)],3) AS BTC_MEDIAN_OPEN,

    -- Bitcoin Closing Price
    ROUND(AVG(BTC_CLOSE),3) AS BTC_MEAN_CLOSE,
    --ROUND(APPROX_QUANTILES(BTC_CLOSE, 4)[OFFSET(2)],3) AS BTC_MEDIAN_CLOSE,

    -- Bitcoin Daily Range
    ROUND(AVG(BTC_RANGE),3) AS BTC_MEAN_RANGE,
    --ROUND(APPROX_QUANTILES(BTC_RANGE, 4)[OFFSET(2)],3) AS BTC_MEDIAN_RANGE,

    -- Ethereum Opening Price
    -- IGNORE NULLS excludes dates where Ethereum data is unavailable
    ROUND(AVG(ETH_OPEN),3) AS ETH_MEAN_OPEN,
    --ROUND(APPROX_QUANTILES(ETH_OPEN, 4 IGNORE NULLS)[OFFSET(2)],3) AS ETH_MEDIAN_OPEN,

    -- Ethereum Closing Price
    ROUND(AVG(ETH_CLOSE),3) AS ETH_MEAN_CLOSE,
    --ROUND(APPROX_QUANTILES(ETH_CLOSE, 4 IGNORE NULLS)[OFFSET(2)],3) AS ETH_MEDIAN_CLOSE,

    -- Ethereum Daily Range
    ROUND(AVG(ETH_RANGE),3) AS ETH_MEAN_RANGE,
    --ROUND(APPROX_QUANTILES(ETH_RANGE, 4 IGNORE NULLS)[OFFSET(2)],3) AS ETH_MEDIAN_RANGE

FROM
    `osu-demo-project-2026-508513.crypto_dataset.crypto_history_combined`

GROUP BY
    MONTH_NUMBER,
    MONTH

ORDER BY
    MONTH_NUMBER;