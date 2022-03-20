{{
  config(
    materialized='view'
  )
}}  

SELECT 
  max("int_product_events".product_id) AS product_id,
  max("dim_products".name) AS name,
  max("dim_products".price) AS price,
  sum(is_viewed) AS no_view,
  sum(is_added) AS no_added,
  sum(is_shipped) AS no_shipped,
  cast(sum(is_added) as decimal)/cast(sum(is_viewed) as decimal) AS ratio_added_to_view,
  cast(sum(is_shipped) as decimal)/cast(sum(is_added) as decimal) AS ratio_shipped_to_added
FROM {{ref('int_product_events')}}
LEFT JOIN {{ref('dim_products')}}
ON "int_product_events".product_id = "dim_products".product_id
WHERE "int_product_events".product_id IS NOT NULL
GROUP BY "int_product_events".product_id