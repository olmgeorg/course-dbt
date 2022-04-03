{% snapshot delivery_snapshot %}

  {{
    config(
      target_schema='snapshots',
      unique_key='order_id',
      strategy='check',
      check_cols=['estimated_delivery_at', 'delivered_at', 'status'],
    )
  }}

  SELECT * 
  FROM {{ source('source', 'orders') }}

{% endsnapshot %}