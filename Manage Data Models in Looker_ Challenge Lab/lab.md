## Manage Data Models in Looker: Challenge Lab
<div align="center">
  <a href="https://www.cloudskillsboost.google/focuses/33370?parent=catalog" target="_blank" rel="noopener noreferrer">
    <img src="https://img.shields.io/badge/Open_Lab-Cloud_Skills_Boost-4285F4?style=for-the-badge&logo=google&logoColor=white&labelColor=34A853" alt="Open Lab Badge">
  </a>
</div>

---

* Remember to Turn ON Developer Mode.

> ✅ **NOTE:** *Watch Full Video to get Full Scores on Check My Progress.*

## TASK 1

### Open **`order_items.view`** and replace the following LookML code:

```lookml
view: order_items {
  sql_table_name: `cloud-training-demos.looker_ecomm.order_items`
    ;;
  drill_fields: [order_item_id]

  dimension: order_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.delivered_at ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    drill_fields: [detail*]
    value_format_name: usd_0
  }

  measure: order_item_count {
    type: count
    drill_fields: [detail*]
  }

  measure: order_count {
    type: count_distinct
    sql: ${order_id} ;;
  }

  measure: total_revenue {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: total_revenue_from_completed_orders {
    type: sum
    sql: ${sale_price} ;;
    filters: [status: "Complete"]
    value_format_name: usd
  }

  dimension: profit {
    label: "profit"
    description: "sgggf"
    type: number
    sql: ${sale_price} - ${products.cost} ;;
    value_format_name: usd
  }

  measure: total_profit {
    label: "total_profit"
    description: "sgggf sum"
    type: sum
    sql: ${profit} ;;
    value_format_name: usd
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      order_item_id,
      users.last_name,
      users.id,
      users.first_name,
      inventory_items.id,
      inventory_items.product_name
    ]
  }
}
```

### Update the **`training_ecommerce.model`** file by replacing all instances of **NAME_DATAGROUP** with your **NAME**, as specified in the task instructions.
```lookml
connection: "bigquery_public_data_looker"

# Include all the views
include: "/views/*.view"
include: "/z_tests/*.lkml"
include: "/**/*.dashboard"

# Define the default datagroup for caching
datagroup: training_ecommerce_default_datagroup {
  sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

# Set the default datagroup for persistence
persist_with: training_ecommerce_default_datagroup

# Label for the model
label: "E-Commerce Training"

# Explore for order_items with necessary joins
explore: order_items {
  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
  
  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }
  
  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
  
  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

# Explore for events with necessary joins
explore: events {
  join: event_session_facts {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_facts.session_id} ;;
    relationship: many_to_one
  }
  join: event_session_funnel {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_funnel.session_id} ;;
    relationship: many_to_one
  }
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  } 
}

# Define the weekly datagroup for caching with a trigger
datagroup: NAME_DATAGROUP {
  sql_trigger: SELECT DATE_TRUNC(CURRENT_DATE(), WEEK);;
  max_cache_age: "168 hours"
}

# Use the weekly datagroup for persistence
persist_with: NAME_DATAGROUP

# Explore for order_items with an aggregate table
explore: +order_items {
  label: ""
  aggregate_table: weekly_aggregate_revenue_profit {
    query: {
      dimensions: [order_items.created_date]
      measures: [order_items.total_revenue, order_items.total_profit]
    }
    
    materialization: {
      datagroup_trigger: NAME_DATAGROUP
      increment_key: "created_date"
    }
  }
}
```

## TASK 2

### Update the **`training_ecommerce.model`** file:
```
explore: +order_items {

    query: drabhishek {
      dimensions: [created_month]
      measures: [total_profit, total_revenue]
    }
    }
```

## TASK 3

### Create View (Name given in Task 3 Instructions) and add the following LookML code (Replace **VIEW_NAME** with the NAME in Instructions):
```
view: VIEW_NAME {
extension: required

dimension: id {
primary_key: yes
type: number
sql: ${TABLE}.id ;;
}

dimension: email {
type: string
sql: ${TABLE}.email ;;
}

dimension: first_name {
type: string
sql: ${TABLE}.first_name ;;
}

dimension: last_name {
type: string
sql: ${TABLE}.last_name ;;
}

dimension: latitude {
type: number
sql: ${TABLE}.latitude ;;
}

dimension: longitude {
type: number
sql: ${TABLE}.longitude ;;
}
}
```

## TASK 4

### Update the **`user.view`** file (Replace **GROUP_NAME** with the NAME in Instructions):
```
view: users {
  sql_table_name: `cloud-training-demos.looker_ecomm.users`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    hidden: yes
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    group_label:"GROUP_NAME"
    sql: ${TABLE}.age ;;
  }

  dimension: city {
    type: string
    group_label:"GROUP_NAME"
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    group_label:"GROUP_NAME"
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    type: string
    hidden: yes
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    hidden: yes
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    hidden: yes
    sql: ${TABLE}.last_name ;;
  }

  dimension: latitude {
    type: number
    hidden: yes
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    hidden: yes
    sql: ${TABLE}.longitude ;;
  }

  dimension: state {
    type: string
    group_label:"GROUP_NAME"
    sql: ${TABLE}.state ;;
    map_layer_name: us_states
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  measure: count {
    type: count
    drill_fields: [id, last_name, first_name, events.count, order_items.count]
  }
}
```

### Update the **`products.view`** file (Replace **GROUP_NAME** with the NAME in Instructions):
```
view: products {
  sql_table_name: `cloud-training-demos.looker_ecomm.products`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: brand {
    type: string
    group_label:"GROUP_NAME"
    sql: ${TABLE}.brand ;;
  }

  dimension: category {
    type: string
    group_label:"GROUP_NAME"
    sql: ${TABLE}.category ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
  }

  dimension: department {
    type: string
    group_label:"GROUP_NAME"
    sql: ${TABLE}.department ;;
  }

  dimension: distribution_center_id {
    type: string
    # hidden: yes
    sql: ${TABLE}.distribution_center_id ;;
  }

  dimension: name {
    type: string
    group_label:"GROUP_NAME"
    sql: ${TABLE}.name ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name, distribution_centers.name, distribution_centers.id, inventory_items.count]
  }
}
```

---
### Congratulations !!!!

<div style="text-align: center; display: flex; flex-direction: column; align-items: center; gap: 20px;">
  <p>Connect with fellow cloud enthusiasts, ask questions, and share your learning journey.</p>  

  <a href="https://t.me/+gBcgRTlZLyM4OGI1" target="_blank">
    <img src="https://img.shields.io/badge/Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram">
  </a>

  <a href="https://www.youtube.com/@drabhishek.5460?sub_confirmation=1" target="_blank">
    <img src="https://img.shields.io/badge/Subscribe-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="YouTube">
  </a>

  <a href="https://www.instagram.com/drabhishek.5460/" target="_blank">
    <img src="https://img.shields.io/badge/Follow-%23E4405F?style=for-the-badge&logo=instagram&logoColor=white" alt="Instagram">
  </a>
</div>
