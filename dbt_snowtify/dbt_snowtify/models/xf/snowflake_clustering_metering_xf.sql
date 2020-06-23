WITH base AS (

	SELECT *
	FROM {{ ref('snowflake_clustering_metering') }}


), contract_rates AS (

    SELECT *
    FROM {{ ref('snowflake_amortized_rates') }}

), date_spine AS (

  {{ dbt_utils.date_spine(
      start_date="to_date('11/01/2009', 'mm/dd/yyyy')",
      datepart="day",
      end_date="dateadd(year, 40, current_date)"
     )
  }}

), date_details AS (

    SELECT  date_day,
            DATE_PART(month, date_day) AS month_actual,
            DATE_PART(year, date_day) AS year_actual,
            FIRST_VALUE(date_day) OVER (PARTITION BY year_actual, month_actual ORDER BY date_day) AS first_day_of_month
    FROM date_spine

), usage AS (

        SELECT

          database_name,
          database_id,
          schema_name,
          schema_id,
          table_name,
          table_id,
          start_time,
          end_time,
          date_details.first_day_of_month              AS usage_month,
          date_details.date_day                        AS usage_day,
          datediff(hour, start_time, end_time)         AS usage_length,
          contract_rates.rate                          AS credit_rate,
          credits_used,
          round(credits_used * contract_rates.rate, 2) AS dollars_spent

        FROM base
        INNER JOIN date_details
        ON date_trunc('day', end_time) = date_details.date_day
        LEFT JOIN contract_rates ON date_trunc('day', end_time) = contract_rates.date_day

)

SELECT *
FROM usage
