
with source_cte as (

  select *
  from {{ source('snowflake','pipe_usage_history') }}

), base_cte as (

  select
    pipe_id,
    pipe_name,
    start_time,
    end_time,
    credits_used,
    bytes_inserted,
    files_inserted
  from source_cte

)

select * from base_cte
