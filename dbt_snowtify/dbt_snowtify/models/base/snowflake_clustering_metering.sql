
with source_cte as (

  select *
  from {{ source('snowflake', 'automatic_clustering_history') }}

)

select *
from source_cte
