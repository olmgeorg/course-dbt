{{
  config(
    materialized='view'
  )
}}  


SELECT 
  session_id,
  event_id,
  event_type,
  "dim_events".order_id AS o_id1,
  "dim_events".product_id AS p_id1,
  is_checkout, 
  is_add_to_cart, 
  is_page_view, 
  quarter,
  CASE 
    WHEN "dim_events".product_id IS NULL THEN "dim_ordersItems".product_id ELSE "dim_events".product_id
  END AS product_id
FROM {{ref('dim_events')}}
LEFT JOIN {{ref('dim_ordersItems')}}
ON "dim_events".order_id = "dim_ordersItems".order_id
