with source as (
    select * from {{ source('yelp_dataset', 'review') }}
),

renamed as (
    select
        review_id,
        user_id,
        business_id,
        stars,
        useful,
        funny,
        cool,
        text,
        date
    from source
)

select * from renamed
