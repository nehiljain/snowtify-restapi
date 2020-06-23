-- depends_on: {{ ref('snowflake_qrt_irrelevant_query_filters') }}

{%- call statement('result', fetch_result=True) -%}

    select distinct
    column_name, value
    from {{ ref(var('qrt_query_filters')) }}

{%- endcall -%}

{% set results = load_result('result').table %}

WITH snowflake_query_history AS (

    SELECT *
    FROM {{ref('snowflake_query_history')}}

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

), irrelevant_queries AS (

    SELECT
        snowflake_query_id
    FROM snowflake_query_history
    where False
        or contains(trim(lower(query_text)), trim(lower('Autocommit')))
        or contains(trim(lower(query_text)), trim(lower('select ')))
        or contains(trim(lower(query_text)), trim(lower('rollback')))
        or contains(trim(lower(query_text)), trim(lower('commit')))
        or contains(trim(lower(query_text)), trim(lower('begin')))
        or contains(trim(lower(query_text)), trim(lower('select system')))

), relevant_queries AS (

    SELECT *
    FROM snowflake_query_history
    WHERE
        snowflake_query_id NOT IN (
            SELECT * FROM irrelevant_queries
        )
        and warehouse_id is not null

), date_details_with_history AS (

    SELECT
        relevant_queries.*,
        TIMESTAMPDIFF('second',
                      relevant_queries.query_start_time,
                      relevant_queries.query_end_time
                      )/60                                                   AS query_execution_time_mins,
        (query_bytes_spillover_local + query_bytes_spillover_remote)/1000000 AS query_total_spillover_mb,
        date_details.date_day                                                AS query_execution_date,
        date_details.month_actual                                            AS query_execution_month,
        date_details.year_actual                                             AS query_execution_year,
        date_details.first_day_of_month                                      AS query_execution_first_day_of_month
    FROM relevant_queries
    INNER JOIN date_details
    ON date_trunc('day', relevant_queries.query_start_time) = date_details.date_day

)


SELECT *
FROM date_details_with_history

