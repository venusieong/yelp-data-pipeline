{{ config(materialized='table') }}

with source as (
    select business_id, categories
    from {{ ref('stg_business') }}
),

split_categories as (
    select
        business_id,
        trim(category) as category
    from source,
    unnest(split(categories, ',')) as category
    where categories is not null
)

select * from split_categories
