# Analytics engineering with dbt

## Week 4

**Part 2:** Modeling challenge

The Funnel Model is very similar to the work I already did in Week 2, so I was able to build upon that. Small adaptions to my fct_product_events.sql made for a good solution. 

I needed to correct a mistake in the calculation of total pages views and in order to to consider for tracking our quarterly goals over the long term, I extracted and grouped by quarter the events happen. Now we can compare our conversion rate per product and quarter.  
Below, you can see a snippet of the resulting table. 

![](/greenery/models/fct_prodcut_events_scrsht.png)

My model `fct_product_events` was also marked as exposed to the public, as can be seen in the documentation and the following screenshot.

![](/greenery/models/dbt-dag-2.png)


**Part 3:** Reflection questions -- please answer 3A or 3B, or both!

**3A.** I'm currently not employed, so I don't need to convince anybody of using DBT. But in my old company it would resolve a lot problems we had in building our data foundation. It improves documentation and makes handling many models and many variants of models way easier.

I loved how we were immediately confronted with proven best practices of using DBT, were able to utilise it and create our own repository of a DBT project. These things will prove useful, when I finally can use DBT in my next project. 

I plan to move into analytics engineering and this course provided valuable insights in how an analytics team works and thinks. 

**3B.** From what I saw, I would focus on using DBT core and implement it in a broader landscape of tools. Here I am valuing the flexibitliy and open community of an open source DBT Core. I want to utilize the strength of a tool and thereby prefer an orchestration tool like airflow/dagster over DBT Cloud. 


## Week 3

**Part 1**

What is our overall conversion rate?
**0.62**

What is our conversion rate by product?
Can be found in `fct_conversion.sql`

```sql 
with checkout_per_session as (
    SELECT 
        session_id, 
        max(product_id) as product_id,
        max(is_checkout) as checkout_in_session
    FROM {{ref('int_product_events')}}
    GROUP BY session_id
),

total_conversion_rate as (
    SELECT 
        cast(sum(checkout_in_session) as decimal)/cast(count(session_id) as decimal) as total_conversion_rate
    from checkout_per_session
)


SELECT 
  product_id,
  sum(checkout_in_session) as no_checkout, 
  count(session_id) no_viewed,
  cast(sum(checkout_in_session) as decimal)/cast(count(session_id) as decimal) as product_conversion_rate,
  max("total_conversion_rate".total_conversion_rate) as total_conversion_rate
FROM checkout_per_session
LEFT JOIN total_conversion_rate ON 1=1
GROUP BY product_id
```
**Part 2**

Create a macro to simplify part of a model

Old Query
```sql
SELECT 
   CASE 
     WHEN event_type = 'package_shipped' then 1 ELSE 0
   END AS is_shipped, 
   CASE 
     WHEN event_type = 'add_to_cart' then 1 ELSE 0
   END AS is_added, 
   CASE 
     WHEN event_type = 'page_view' then 1 ELSE 0
   END AS is_viewed
FROM {{ref('stg_events')}}
```

New Query
```sql
{% set event_type_state = dbt_utils.get_column_values(table=ref('stg_events'), column='event_type') %}

SELECT 
  {% for event_type in event_type_state %}
    case when event_type = '{{event_type}}' then 1 else 0 end as is_{{event_type}},
  {% endfor %}
FROM {{ref('stg_events')}}
```

**Part 3**

Create Hooks
```yml
models:
  greenery:
    # Config indicated by + and applies to all files under models/example/
    example:
      +materialized: view
    post-hook: "GRANT SELECT ON {{ this }} TO reporting"

on-run-end:
  - "GRANT USAGE ON SCHEMA {{ schema }} TO reporting"
```

**Part 4**
Install Packages

```yml
packages:
  - package: dbt-labs/dbt_utils
    version: 0.8.2
```
`dbt deps`

```sql 
{% set event_type_state = dbt_utils.get_column_values(table=ref('stg_events'), column='event_type') %}
```

**Part 5**
Updated DAG

![](/greenery/models/dbt-dag.png)

## Week 2

**Part 1**
**Questions 1**: What is our user repeat rate?

```sql 
SELECT /* Calculate the rate of repeting buyers to all buyers - Repeat Rate*/
  cast(no_repeater AS FLOAT) / cast(no_users AS FLOAT) as Repeat_rate
  FROM(  
    SELECT/* Count number of users and those who repeatedly buy*/
      COUNT( 
        CASE WHEN repeat_type = 'repeater' THEN 1 END
        ) AS no_repeater, 
      COUNT(*) AS no_users
      FROM (   
        SELECT /* categorize user in buyer groups*/
          no_orders, 
          user_id,
          case
            when no_orders > 1 then 'repeater'
            when no_orders = 1 then 'singular'
          END as repeat_type
        FROM (SELECT /* Number of orders per User_id*/
               count(order_id) as no_orders, 
               user_id
              FROM dbt.dbt_georg_o.orders_model
              GROUP BY user_id) as a 
        ) as b
      )as c
```
Output: **0.798**

**Questions 2**: What are good indicators of a user who will likely purchase again?

Why? 
  - Promo Codes, are people tempted by special promotions?
  - Conversion: Are people who visit the site often more likely to buy somethin? (events data)
  - How long is the customer active? 
  - What is the time from the last purchase?

What? 
  - Are some products more likely to be bought multiple times? 
  - Importance of price
  - What products are looked at, but not bought and vice versa.

**Questions 3**: Creating Data Marts

What Metrics are useful for each business unit? 

**Core**: The core business is the essential activity in our company and the way to generate money. Greenery's core business is selling and delivering flowers and houseplants. A reasonable question would be, how much are we selling and are we delivering in time. So in a stricter sense I'm not directly interested in who is buying, what is selling best and how are promotions going. So the focus lies on questions like informations about orders, repeated orders, time to delivery and events happening until an order has been completed. Therefore orders, order_items and product information are data we are interested in. 

**The following source tables will be used**: 
stg_orders
stg_orderItems
stg_products

**These are questions that can be answered**: 
was the order based on a promotion? 
How long were delivery times and what are costs per product?

**Marketing**:
Who are our customers and how are they behaving on our platform. Here i'm aggregating order informations on a user level. 

**Tables used**: 

stg_orders

stg_users

**Questions answered**: 
Who is the user? 
How much was ordered per user? 
How much of it was influenced by promotion codes?
What was the time since the last order?

**Product**: In this Mart we are at the intersection between the products we sell (plants) and the product we create (the platform). So I was interested in how is each plant performing in terms of the events, happening on our site. 

**Tables used**: 
stg_events
stg_orderItems
stg_products 

**Questions answered:** 
What is our product? 
How much is it viewed, added to cart and finally shipped. 
Calculating the ratios between these factors. 


**Part 2**

_What assumptions are you making about each model?_ 
I focues on test abou non NULL values and uniqueness of a values. 

Primary Keys are supposed to be unique, and not NULL, so I applied these test for all primary Keys. Further there are some columns I expect to be not NULL. For Example should every Order be associated with a produt in the stg_orderItems table. 

*Did you find any “bad” data as you added and ran tests on your models?* 

I found some misconceptions between my test and the data, but most of the time my assumptions were wrong so I adapted the testing schema. As I have some calculated columns in the fact tables, I should improve my testing schema to check my assumptions before calculating new columns. 

*Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.*

These test should be run, before a new build process is started. The building process can only start, when all test are passed. This means, the test should be run regularly to identify errors in the data early, before mistakes get through to the end user, who relies on the report being correct. 

## WEEK 1

Question 1: 
How many users do we have?

```sql
SELECT count(
  distinct user_id)
FROM dbt.dbt_georg_o.users_model
```
output: **130**

Question 2: 
On average, how many orders do we receive per hour?

```sql
SELECT avg(number_of_orders) as average_order_per_hour
FROM (
  SELECT 
    count(*) as number_of_orders, 
    to_char(created_at,'YYYY-MM-DD HH24') as order_hour 
  FROM dbt.dbt_georg_o.orders_model
  GROUP BY order_hour
) as a
```
output: **7.520**

Question 3: 
On average, how long does an order take from being placed to being delivered?

```sql 
SELECT /* Calculate avergae delivery time*/
    AVG(delivery_duration) average_delivery_time
FROM ( 
  SELECT /* Calculate duration of delivery per order*/
    order_id, 
    (delivered_at - created_at) as delivery_duration
  FROM dbt.dbt_georg_o.orders_model
  WHERE status = 'delivered') as a
```
output: **3 days 21:24:11**

Question 4: 
How many users have only made one purchase? Two purchases? Three+ purchases?

```sql 
SELECT /* count no. of users per purchase group*/
  count(user_id) as no_users, 
  order_group
FROM(
  SELECT /*Define purchase groups, based on no. of purchases*/
    a.no_orders,
    a.user_id,
    CASE WHEN a.no_orders = 1 THEN 'one purchase'
         WHEN a.no_orders = 2 THEN 'two purchases'
         WHEN a.no_orders >= 3 THEN 'three+ purchases'
         END AS order_group
  FROM (SELECT /* Query number of orders per user as a*/
          count(order_id) as no_orders, 
          user_id
        FROM dbt.dbt_georg_o.orders_model
        GROUP BY user_id) as a
        ) as b
GROUP BY order_group

```
output: 

|no_users|order_group|
|---|---|
|28|two puchases|
|25|one purchase|
|71|three+ purchases|

Question 5: 
On average, how many unique sessions do we have per hour?

```sql 
SELECT 
  AVG(no_session_per_hour)
FROM (
  SELECT 
    count(distinct session_id) as no_session_per_hour,
    to_char(created_at,'YYYY-MM-DD HH24') as session_hour
  From dbt.dbt_georg_o.events_model
  GROUP BY session_hour) as a
```
output: **16.327**

## License

Apache 2.0