{{
  config(
    materialized='view'
  )
}}  


SELECT 
  max("int_product_events".product_id) AS product_id,
  max("dim_products".name) AS name,
  max("dim_products".price) AS price,
  sum(is_page_view) AS no_view,
  sum(is_add_to_cart) AS no_added,
  sum(is_checkout) AS no_shipped,
  cast(sum(is_add_to_cart) as decimal)/cast(sum(is_page_view) as decimal) AS ratio_added_to_view,
  cast(sum(is_checkout) as decimal)/cast(sum(is_add_to_cart) as decimal) AS ratio_shipped_to_added
FROM {{ref('int_product_events')}}
LEFT JOIN {{ref('dim_products')}}
ON "int_product_events".product_id = "dim_products".product_id
WHERE "int_product_events".product_id IS NOT NULL
GROUP BY "int_product_events".product_id
