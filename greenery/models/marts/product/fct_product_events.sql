{{
  config(
    materialized='view'
  )
}}  

SELECT 
  CASE 
    WHEN event_type = "package_shipped" then 1 ELSE 0
  END AS is_shipped, 
  CASE 
    WHEN event_type = "add_to_cart" then 1 ELSE 0
  END AS is_added, 
  CASE 
    WHEN event_type = "page_view" then 1 ELSE 0
  END AS is_viewed, 
  sum(is_viewed) AS no_view,
  sum(is_added) AS no_added,
  sum(is_shipped) AS no_shipped,
  CASE 
    WHEN promo_id IS NOT NULL then 1 ELSE 0
  END AS no_promo_used,
  no_added/no_view AS ratio_added_to_view,
  no_shipped/no_added AS ratio_shipped_to_added
FROM {{ref('int_product_events')}}
LEFT JOIN {{ref('dim_orders_p')}}
ON int_product_events.user_id = dim_orders_p.user_id