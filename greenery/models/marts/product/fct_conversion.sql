{{
  config(
    materialized='view'
  )
}}  

with checkout_per_session as (
    SELECT 
        session_id, 
        product_id,
        quarter,
        sum(is_checkout) as checkout_in_session
    FROM {{ref('int_product_events')}}
    GROUP BY session_id, product_id, quarter
),

total_conversion_rate as (
    SELECT 
        cast(sum(checkout_in_session) as decimal)/cast(count(session_id) as decimal) as total_conversion_rate
    from checkout_per_session
)


SELECT 
  product_id,
  quarter,
  sum(checkout_in_session) as no_checkout, 
  count(session_id) no_viewed,
  cast(sum(checkout_in_session) as decimal)/cast(count(session_id) as decimal) as product_conversion_rate,
  max("total_conversion_rate".total_conversion_rate) as total_conversion_rate
FROM checkout_per_session
LEFT JOIN total_conversion_rate ON 1=1
GROUP BY product_id, quarter
