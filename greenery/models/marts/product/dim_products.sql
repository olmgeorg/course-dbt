{{
  config(
    materialized='view'
  )
}}  

SELECT *
FROM {{ref('stg_products')}}