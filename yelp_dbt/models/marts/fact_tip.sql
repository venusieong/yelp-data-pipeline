{{ config(
    materialized='table',
    partition_by={
        "field": "tip_month",
        "data_type": "DATE"
    }
) }}

with tip as (
    select * from {{ ref('stg_tip') }}
),
users as (
    select user_id from {{ ref('dim_user') }}
),
business as (
    select business_id from {{ ref('dim_business') }}
)

select
    tip.user_id,
    tip.business_id,
    tip.text,
    tip.date as tip_date,
    date_trunc(cast(tip.date as date), month) as tip_month,
    case when users.user_id is not null then tip.user_id else null end as valid_user_id,
    case when business.business_id is not null then tip.business_id else null end as valid_business_id
from tip
left join users on tip.user_id = users.user_id
left join business on tip.business_id = business.business_id

