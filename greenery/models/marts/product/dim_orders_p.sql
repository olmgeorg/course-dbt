{{
  config(
    materialized='view'
  )
}}  

SELECT *
FROM {{ref('stg_orders')}}