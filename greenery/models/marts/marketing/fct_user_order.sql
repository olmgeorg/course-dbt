{{
  config(
    materialized='view'
  )
}}  

SELECT 
  max("dim_users".user_id) as user_id,
  max("dim_users".first_name) AS first_name,
  max("dim_users".last_name) AS last_name,
  max("dim_users".email) AS email, 
  count("dim_users".user_id) AS no_orders,
  count("dim_orders_m".promo_id) AS no_promo_used,
  max("dim_users".created_at) AS user_created, 
  max("dim_orders_m".created_at) AS last_order, 
  clock_timestamp() - max("dim_orders_m".created_at) AS time_since_last_order, 
  sum("dim_orders_m".order_cost) AS total_order_cost, 
  avg("dim_orders_m".order_cost) AS mean_order_cost
FROM {{ref('dim_orders_m')}}
LEFT JOIN {{ref('dim_users')}}
ON dim_orders_m.user_id = dim_users.user_id
GROUP BY "dim_users".user_id
