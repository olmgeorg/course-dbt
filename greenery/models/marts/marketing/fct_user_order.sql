{{
  config(
    materialized='view'
  )
}}  

SELECT 
  "dim_orders_m".user_id
  "dim_users".first_name,
  "dim_users".last_name, 
  "dim_users".email, 
  "dim_users".created_at AS user_created, 
  max("dim_orders_m".created_at) AS last_order, 
  last_order - user_created AS diff_creation_lastOrder, 
  CASE 
    WHEN "dim_orders_m".promo_id IS NOT NULL THEN 1 ELSE 0
  END AS is_promo_used,
  sum("dim_orders_m".order_cost) AS total_order_cost, 
  avg("dim_orders_m".order_cost) AS mean_order_cost
FROM {{ref('dim_orders_m')}}
LEFT JOIN {{ref('dim_users')}}
ON dim_orders_m.user_id = dim_users.user_id
GROUP BY user_id
