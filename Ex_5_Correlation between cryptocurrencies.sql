-- 3. Is Ethereum price correlated to Bitcoin price in USD?

-- Links to documentation
-- BigQuery CORR documentation:
-- https://cloud.google.com/bigquery/docs/reference/standard-sql/statistical_aggregate_functions#corr

SELECT
    -- Pearson correlation between Bitcoin and Ethereum opening prices
    ROUND(CORR(BTC_OPEN, ETH_OPEN),3) AS BTC_ETH_OPEN_CORRELATION,

    -- Pearson correlation between Bitcoin and Ethereum closing prices
    ROUND(CORR(BTC_CLOSE, ETH_CLOSE),3) AS BTC_ETH_CLOSE_CORRELATION,

    -- Pearson correlation between Bitcoin and Ethereum daily price ranges
    ROUND(CORR(BTC_RANGE, ETH_RANGE),3) AS BTC_ETH_RANGE_CORRELATION

FROM
    `osu-demo-project-2026-508513.crypto_dataset.crypto_history_combined`

-- Only include dates where both Bitcoin and Ethereum prices are available
WHERE
    BTC_OPEN IS NOT NULL
    AND ETH_OPEN IS NOT NULL
    AND BTC_CLOSE IS NOT NULL
    AND ETH_CLOSE IS NOT NULL
    AND BTC_RANGE IS NOT NULL
    AND ETH_RANGE IS NOT NULL;