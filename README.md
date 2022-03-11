# Analytics engineering with dbt

Template repository for the projects and environment of the course: Analytics engineering with dbt

> Please note that this sets some environment variables so if you create some new terminals please load them again.

## License

Apache 2.0


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

