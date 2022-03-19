# Analytics engineering with dbt

Template repository for the projects and environment of the course: Analytics engineering with dbt

> Please note that this sets some environment variables so if you create some new terminals please load them again.

## License

Apache 2.0

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

Who? 
  - Age
  - Place
  - Gender

Why? 
  - Promo Codes, are people tempted by special promotions? 
  - Conversion: Are people who visit the site often more likely to buy somethin? (events data)

What? 
  - Are some products more likely to be bought multiple times? 
  - Price

**Questions 3**: Creating Data Marts

What Metrics are useful for each business unit? 

**Core**: The core business is the essential activity in our company and the way to generate money. Greenery's core business is selling and delivering flowers and houseplants. A reasonable question would be, how much are we selling and are we delivering in time. So in a stricter sense I'm not directly interested in who is buying, what is selling best and how are promotions going. So the focus lies on questions like informations about orders, repeated orders, time to delivery and events happening until an order has been completed. Therefore orders, order_items and events are data we are interested in. 

fct_orders
dim_user
dim_products

**Marketing**:
Who are our customers and how are they behaving on our platform 
fct_UserOrder

**Product**: What are the products being sold? 
grain: A product being sold
Dimensions: orders, products, promos

fct_ProductOrder
dim_order
dim_product
dim_promo


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

