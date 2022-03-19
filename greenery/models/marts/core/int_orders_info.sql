{{
  config(
    materialized='view'
  )
}}  

SELECT 
  "dbt_georg_o"."stg_orders".order_id,
  "dbt_georg_o"."stg_orders".created_at,
  "dbt_georg_o"."stg_orders".order_cost, 
  "dbt_georg_o"."stg_orders".shipping_cost,
  "dbt_georg_o"."stg_orders".order_total, 
  "dbt_georg_o"."stg_orders".estimated_delivery_at,
  "dbt_georg_o"."stg_orders".delivered_at,
  "dbt_georg_o"."stg_orders".status,
  "dbt_georg_o"."stg_orders".promo_id,
  "dbt_georg_o"."stg_orderItems".product_id,
  "dbt_georg_o"."stg_orderItems".quantity,
  "dbt_georg_o"."stg_products".name,
  "dbt_georg_o"."stg_products".price, 
  "dbt_georg_o"."stg_products".inventory
FROM {{ ref('stg_orders')}}
LEFT JOIN {{ ref('stg_orderItems') }}
	ON "dbt_georg_o"."stg_orders".order_id = "dbt_georg_o"."stg_orderItems".order_id
LEFT JOIN {{ ref('stg_products') }}
	ON "dbt_georg_o"."stg_orderItems".product_id = "dbt_georg_o"."stg_products".product_id
