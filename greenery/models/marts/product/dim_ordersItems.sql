{{
  config(
    materialized='view'
  )
}}  

SELECT
  order_id,
  product_id,
  quantity
FROM {{ref('stg_orderItems')}}