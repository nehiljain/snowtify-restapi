WITH base AS (

	SELECT *
	FROM {{ ref('snowflake_warehouse_metering') }}


), contract_rates AS (

    SELECT *
    FROM {{ ref('snowflake_amortized_rates') }}

), date_details AS (

    SELECT  date_day,
            DATE_PART(month, date_day) AS month_actual,
            DATE_PART(year, date_day) AS year_actual,
            FIRST_VALUE(date_day) OVER (PARTITION BY year_actual, month_actual ORDER BY date_day) AS first_day_of_month
    FROM date_spine

), usage AS (

        SELECT warehouse_id,
               warehouse_name,
               start_time,
               end_time,
               date_details.first_day_of_month              AS usage_month,
               date_details.date_day                        AS usage_day,
               datediff(hour, start_time, end_time)         AS usage_length,
               contract_rates.rate                          AS credit_rate,
               round(credits_used * contract_rates.rate, 2) AS dollars_spent
        FROM base
        INNER JOIN date_details
        ON date_trunc('day', end_time) = date_details.date_day
        LEFT JOIN contract_rates ON date_trunc('day', end_time) = contract_rates.date_day

)

SELECT *
FROM usage
