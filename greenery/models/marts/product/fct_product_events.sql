{{
  config(
    materialized='view'
  )
}}  


SELECT 
  "int_product_events".product_id AS product_id,
  max("dim_products".name) AS name,
  max("dim_products".price) AS price,
  count(distinct session_id) AS no_view,
  cast(sum(is_add_to_cart) as decimal)/cast(count(distinct session_id) as decimal) AS add_to_cart_rate,
  sum(is_add_to_cart) AS no_added_to_cart,
  cast(sum(is_checkout) as decimal)/cast(sum(is_add_to_cart) as decimal) AS ratio_shipped_if_added,
  sum(is_checkout) AS no_shipped,
  cast(sum(is_checkout) as decimal)/cast(count(distinct session_id) as decimal) AS conversion_rate, 
  "int_product_events".quarter AS quarter
FROM {{ref('int_product_events')}}
LEFT JOIN {{ref('dim_products')}}
ON "int_product_events".product_id = "dim_products".product_id
WHERE "int_product_events".product_id IS NOT NULL
GROUP BY "int_product_events".product_id, "int_product_events".quarter
    