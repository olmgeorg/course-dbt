{{
  config(
    materialized='view'
  )
}}  

{% set event_type_state = dbt_utils.get_column_values(table=ref('stg_events'), column='event_type') %}

SELECT 
  event_id,
  session_id,
  event_type,
  order_id,
  date_trunc('quarter', created_at) AS quarter,
  created_at,
  {% for event_type in event_type_state %}
    case when event_type = '{{event_type}}' then 1 else 0 end as is_{{event_type}},
  {% endfor %}
  product_id
FROM {{ref('stg_events')}}