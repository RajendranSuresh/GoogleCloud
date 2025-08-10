<div align="center" style="padding: 25px; background: #f2f2f2; border-radius: 15px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; box-shadow: 0px 0px 10px rgba(0,0,0,0.1);">

<h1 style="color: #2F80ED;">🚀Getting Started with Liquid to Customize the Looker User Experience | GSP933 </h1>


<br/>

<a href="https://www.cloudskillsboost.google/focuses/21217?catalog_rank=%7B%22rank%22%3A1%2C%22num_filters%22%3A0%2C%22has_search%22%3Atrue%7D&parent=catalog&search_id=46519940" target="_blank" style="margin: 10px;">
  <img src="https://img.shields.io/badge/Access_Lab-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" alt="Access Lab">
</a>
<br/>
</div>
### 📊 Step 1: Update the `user` View

Modify the `user` view with the following configuration:

```lookml
view: users {
  sql_table_name: `cloud-training-demos.looker_ecomm.users`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: city_link {
    type: string
    sql: ${TABLE}.city ;;
    link: {
      label: "Search the web"
      url: "http://www.google.com/search?q={{ value | url_encode }}"
      icon_url: "http://www.google.com/s2/favicons?domain=www.{{ value | url_encode }}.com"
    }
  }

  dimension: order_history_button {
    label: "Order History"
    sql: ${TABLE}.id ;;
    html: <a href="/explore/training_ecommerce/order_items?fields=order_items.order_item_id, users.first_name, users.last_name, users.id, order_items.order_item_count, order_items.total_revenue&f[users.id]={{ value }}"><button>Order History</button></a> ;;
  }

  dimension: country {
    type: string
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
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
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

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
    map_layer_name: us_states
  }
  
  dimension: state_link {
    type: string
    sql: ${TABLE}.state ;;
    map_layer_name: us_states
    html: {% if _explore._name == "order_items" %}
          <a href="/explore/training_ecommerce/order_items?fields=order_items.detail*&f[users.state]= {{ value }}">{{ value }}</a>
        {% else %}
          <a href="/explore/training_ecommerce/users?fields=users.detail*&f[users.state]={{ value }}">{{ value }}</a>
        {% endif %} ;;
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

### 📝 Step 2: Update the `order_items` View File

Modify the `order_items` view file with the following configuration:

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
  
    measure: total_revenue_conditional {
      type: sum
      sql: ${sale_price} ;;
      value_format_name: usd
      html: {% if value > 1300.00 %}
            <p style="color: white; background-color: ##FFC20A; margin: 0; border-radius: 5px; text-align:center">{{ rendered_value }}</p>
            {% elsif value > 1200.00 %}
            <p style="color: white; background-color: #0C7BDC; margin: 0; border-radius: 5px; text-align:center">{{ rendered_value }}</p>
            {% else %}
            <p style="color: white; background-color: #6D7170; margin: 0; border-radius: 5px; text-align:center">{{ rendered_value }}</p>
            {% endif %}
            ;;
    }
  
    measure: total_revenue_from_completed_orders {
      type: sum
      sql: ${sale_price} ;;
      filters: [status: "Complete"]
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

Connect with fellow cloud enthusiasts, ask questions, and share your learning journey.  

[![Telegram](https://img.shields.io/badge/Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/+gBcgRTlZLyM4OGI1)  
[![YouTube](https://img.shields.io/badge/Subscribe-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@drabhishek.5460?sub_confirmation=1)  
[![Instagram](https://img.shields.io/badge/Follow-%23E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/drabhishek.5460/) 
