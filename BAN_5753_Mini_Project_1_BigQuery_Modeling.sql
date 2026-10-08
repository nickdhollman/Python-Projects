-- ============================================================
-- BAN 5753 Mini Project 1
-- Nicholas Hollman
--
-- BigQuery SQL used to create, evaluate, and forecast BTC and
-- ETH time series models, compare forecasted performance,
-- and create a BTC linear regression model for Vertex AI.
-- ============================================================

-- Create Bitcoin time series model for Mini Project 1

CREATE OR REPLACE MODEL `osu-demo-project-2026-508513.crypto_dataset.BTC_TimeSeries_Project_One`
OPTIONS
  (model_type = 'ARIMA_PLUS',
   time_series_timestamp_col = 'TIMESTAMP',
   time_series_data_col = 'BTC_HIGH',
   auto_arima = TRUE,
   data_frequency = 'AUTO_FREQUENCY',
   decompose_time_series = TRUE
  ) AS
SELECT
  TIMESTAMP,
  BTC_HIGH
FROM
  `osu-demo-project-2026-508513.crypto_dataset.crypto_history_combined`
WHERE
  BTC_HIGH IS NOT NULL
  AND ETH_HIGH IS NOT NULL;

-- Evaluate Bitcoin time series model / goodness-of-fit statistics

SELECT
  *
FROM
  ML.EVALUATE(
    MODEL `osu-demo-project-2026-508513.crypto_dataset.BTC_TimeSeries_Project_One`
  );

-- Create Ethereum time series model for Mini Project 1

CREATE OR REPLACE MODEL `osu-demo-project-2026-508513.crypto_dataset.ETH_TimeSeries_Project_One`
OPTIONS
  (model_type = 'ARIMA_PLUS',
   time_series_timestamp_col = 'TIMESTAMP',
   time_series_data_col = 'ETH_HIGH',
   auto_arima = TRUE,
   data_frequency = 'AUTO_FREQUENCY',
   decompose_time_series = TRUE
  ) AS
SELECT
  TIMESTAMP,
  ETH_HIGH
FROM
  `osu-demo-project-2026-508513.crypto_dataset.crypto_history_combined`
WHERE
  BTC_HIGH IS NOT NULL
  AND ETH_HIGH IS NOT NULL;

-- Evaluate Ethereum time series model / goodness-of-fit statistics

SELECT
  *
FROM
  ML.EVALUATE(
    MODEL `osu-demo-project-2026-508513.crypto_dataset.ETH_TimeSeries_Project_One`
  );

-- Run 365-day Bitcoin High forecast for Mini Project 1

SELECT
  *
FROM
  ML.FORECAST(
    MODEL `osu-demo-project-2026-508513.crypto_dataset.BTC_TimeSeries_Project_One`,
    STRUCT(365 AS horizon, 0.8 AS confidence_level)
  );

-- Run 365-day Ethereum High forecast for Mini Project 1

SELECT
  *
FROM
  ML.FORECAST(
    MODEL `osu-demo-project-2026-508513.crypto_dataset.ETH_TimeSeries_Project_One`,
    STRUCT(365 AS horizon, 0.8 AS confidence_level)
  );

-- ============================================================
-- 5. Forecast Performance Comparison
-- Compares the final observed daily High price with the
-- 365-day ARIMA_PLUS forecast for BTC and ETH.
-- ============================================================

CREATE OR REPLACE TABLE
  `osu-demo-project-2026-508513.crypto_dataset.forecast_performance_comparison`
AS

WITH historical_prices AS (
    SELECT
        MAX(TIMESTAMP) AS end_date,

        ARRAY_AGG(
            BTC_HIGH IGNORE NULLS
            ORDER BY TIMESTAMP DESC
            LIMIT 1
        )[OFFSET(0)] AS BTC_last_high,

        ARRAY_AGG(
            ETH_HIGH IGNORE NULLS
            ORDER BY TIMESTAMP DESC
            LIMIT 1
        )[OFFSET(0)] AS ETH_last_high

    FROM
        `osu-demo-project-2026-508513.crypto_dataset.crypto_history_combined`
),

BTC_forecast AS (
    SELECT
        forecast_timestamp,
        forecast_value,
        prediction_interval_lower_bound,
        prediction_interval_upper_bound
    FROM
        `osu-demo-project-2026-508513.crypto_dataset.BTC-365-Day-Forecast-Project-One`
    ORDER BY forecast_timestamp DESC
    LIMIT 1
),

ETH_forecast AS (
    SELECT
        forecast_timestamp,
        forecast_value,
        prediction_interval_lower_bound,
        prediction_interval_upper_bound
    FROM
        `osu-demo-project-2026-508513.crypto_dataset.ETH-365-Day-Forecast-Project-One`
    ORDER BY forecast_timestamp DESC
    LIMIT 1
)

SELECT
    'Bitcoin (BTC)' AS cryptocurrency,
    h.end_date AS historical_end_date,
    b.forecast_timestamp AS forecast_date,

    ROUND(h.BTC_last_high, 2) AS last_historical_high,
    ROUND(b.forecast_value, 2) AS forecasted_high,

    ROUND(
        ((b.forecast_value / h.BTC_last_high) - 1) * 100,
        2
    ) AS forecast_change_pct,

    ROUND(b.prediction_interval_lower_bound, 2)
        AS lower_bound,

    ROUND(b.prediction_interval_upper_bound, 2)
        AS upper_bound

FROM historical_prices h
CROSS JOIN BTC_forecast b

UNION ALL

SELECT
    'Ethereum (ETH)' AS cryptocurrency,
    h.end_date AS historical_end_date,
    e.forecast_timestamp AS forecast_date,

    ROUND(h.ETH_last_high, 2) AS last_historical_high,
    ROUND(e.forecast_value, 2) AS forecasted_high,

    ROUND(
        ((e.forecast_value / h.ETH_last_high) - 1) * 100,
        2
    ) AS forecast_change_pct,

    ROUND(e.prediction_interval_lower_bound, 2)
        AS lower_bound,

    ROUND(e.prediction_interval_upper_bound, 2)
        AS upper_bound

FROM historical_prices h
CROSS JOIN ETH_forecast e;

SELECT *
FROM `osu-demo-project-2026-508513.crypto_dataset.forecast_performance_comparison`;

-- Explain Bitcoin forecast and combine with historical data

SELECT
  *
FROM
  ML.EXPLAIN_FORECAST(
    MODEL `osu-demo-project-2026-508513.crypto_dataset.BTC_TimeSeries_Project_One`,
    STRUCT(365 AS horizon, 0.8 AS confidence_level)
  );

-- Explain Ethereum forecast and combine with historical data

SELECT
  *
FROM
  ML.EXPLAIN_FORECAST(
    MODEL `osu-demo-project-2026-508513.crypto_dataset.ETH_TimeSeries_Project_One`,
    STRUCT(365 AS horizon, 0.8 AS confidence_level)
  );

-- Create Bitcoin linear regression model for Mini Project 1

CREATE OR REPLACE MODEL
  `osu-demo-project-2026-508513.crypto_dataset.BTC_LinearReg_Project_One`
OPTIONS
  (
    model_type = 'linear_reg',
    input_label_cols = ['BTC_HIGH']
  ) AS
SELECT
  BTC_HIGH,
  BTC_LOW
FROM
  `osu-demo-project-2026-508513.crypto_dataset.crypto_history_combined`
WHERE
  BTC_HIGH IS NOT NULL
  AND BTC_LOW IS NOT NULL;


WITH BTC_Evaluation AS (
  SELECT
    'BTC' AS Cryptocurrency,
    non_seasonal_p,
    non_seasonal_d,
    non_seasonal_q,
    ROUND(AIC, 2) AS AIC,
    seasonal_periods,
    has_spikes_and_dips,
    has_step_changes
  FROM
    ML.EVALUATE(
      MODEL `osu-demo-project-2026-508513.crypto_dataset.BTC_TimeSeries_Project_One`
    )
  QUALIFY ROW_NUMBER() OVER (ORDER BY AIC) = 1
),

ETH_Evaluation AS (
  SELECT
    'ETH' AS Cryptocurrency,
    non_seasonal_p,
    non_seasonal_d,
    non_seasonal_q,
    ROUND(AIC, 2) AS AIC,
    seasonal_periods,
    has_spikes_and_dips,
    has_step_changes
  FROM
    ML.EVALUATE(
      MODEL `osu-demo-project-2026-508513.crypto_dataset.ETH_TimeSeries_Project_One`
    )
  QUALIFY ROW_NUMBER() OVER (ORDER BY AIC) = 1
)

SELECT * FROM BTC_Evaluation
UNION ALL
SELECT * FROM ETH_Evaluation
ORDER BY Cryptocurrency;