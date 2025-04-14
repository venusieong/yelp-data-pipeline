{{ config(
    materialized='table',
    partition_by={
        "field": "review_month",
        "data_type": "date"
    }
) }}

with reviews as (
    select * 
    from {{ ref('stg_review') }}
    where cast(date as date) >= '2018-01-01'
),

fact as (
    select
        review_id,
        user_id,
        business_id,
        stars,
        useful,
        funny,
        cool,
        date as review_date,
        DATE_TRUNC(cast(date as date), MONTH) as review_month,
        text
    from reviews
)

select * from fact



