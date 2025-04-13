with source as (
    select * from {{ source('yelp_dataset', 'checkin') }}
),

renamed as (
    select
        business_id,
        date as checkin_timestamps
    from source
)

select * from renamed
