{{
  config(
    materialized='view'
  )
}}  

SELECT 
  dim_events.event_id, 
  dim_events.session_id, 
  dim_events.user_id,
  dim_products.product_id
FROM {{ref('dim_events')}}
LEFT JOIN {{ref('dim_products')}}
ON dim_events.product_id = dim_products.product_id