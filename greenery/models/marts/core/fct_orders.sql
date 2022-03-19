{{
  config(
    materialized='view'
  )
}}  

SELECT 
  CASE 
    WHEN promo_id IS NOT NULL THEN 1 ELSE 0
  END AS Is_Promo, 
  estimated_delivery_at - created_at AS Order_duration, 
  delivered_at - estimated_delivery_at AS Delivery_deviation, 
  sum(quantity) AS no_products,
  AVG(order_cost) AS order_cost,
  no_products / order_cost AS mean_product_cost, 
  avg(shipping_cost) AS shipping_cost,
  avg(order_total) AS order_total
FROM {{ref('int_orders_info')}}
GROUP BY order_id