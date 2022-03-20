{{
  config(
    materialized='view'
  )
}}  

SELECT 
  max(order_id) as order_id,
  CASE 
    WHEN count(promo_id) > 0 THEN 1 ELSE 0
  END AS Is_Promo, 
  max(estimated_delivery_at) - max(created_at) AS Order_duration, 
  max(delivered_at) - max(estimated_delivery_at) AS Delivery_deviation, 
  sum(quantity) AS no_products,
  AVG(order_cost) AS order_cost,
  sum(quantity) / AVG(order_cost) AS mean_product_cost, 
  avg(shipping_cost) AS shipping_cost,
  avg(order_total) AS order_total
FROM {{ref('int_orders_info')}}
GROUP BY order_id