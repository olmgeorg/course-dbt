{{
  config(
    materialized='view'
  )
}}  

SELECT 
  event_id,
  session_id,
  event_type,
  order_id,
  product_id,
  CASE 
    WHEN event_type = 'package_shipped' then 1 ELSE 0
  END AS is_shipped, 
  CASE 
    WHEN event_type = 'add_to_cart' then 1 ELSE 0
  END AS is_added, 
  CASE 
    WHEN event_type = 'page_view' then 1 ELSE 0
  END AS is_viewed
FROM {{ref('stg_events')}}