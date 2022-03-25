{{
  config(
    materialized='view'
  )
}}  

{% set event_type_bool = ["page_view", "add_to_cart", "checkout"] %}

SELECT 
  event_id,
  session_id,
  event_type,
  order_id,
  {% for event_type in event_type_bool %}
    case when event_type = '{{event_type}}' then 1 else 0 end as is_{{event_type}},
  {% endfor %}
  product_id
FROM {{ref('stg_events')}}