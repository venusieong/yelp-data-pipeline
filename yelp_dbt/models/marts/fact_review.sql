{{ config(
    materialized='table',
    partition_by={
        "field": "review_month",
        "data_type": "DATE"
    }
) }}

with reviews as (
    select * from {{ ref('stg_review') }}
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
        date_trunc(cast(date as date), month) as review_month,
        text
    from reviews
)

select * from fact


