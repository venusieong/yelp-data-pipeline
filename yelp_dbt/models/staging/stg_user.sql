with source as (
    select * from {{ source('yelp_dataset', 'user') }}
),

renamed as (
    select
        user_id,
        name,
        review_count,
        yelping_since,
        useful,
        funny,
        cool,
        elite,
        friends,
        fans,
        average_stars,
        compliment_hot,
        compliment_more,
        compliment_profile,
        compliment_cute,
        compliment_list,
        compliment_note,
        compliment_plain,
        compliment_cool,
        compliment_funny,
        compliment_writer,
        compliment_photos
    from source
)

select * from renamed
