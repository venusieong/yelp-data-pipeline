with source as (
    select * from {{ source('yelp_dataset', 'tip') }}
),

renamed as (
    select
        user_id,
        business_id,
        text,
        date,
        compliment_count
    from source
)

select * from renamed
