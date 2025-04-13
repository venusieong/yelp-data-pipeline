{{ config(materialized='table') }}

with source as (
    select * from {{ ref('stg_user') }}
),

cleaned as (
    select
        user_id,
        name,
        yelping_since,
        review_count,
        useful,
        funny,
        cool,
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
        compliment_photos,
        split(friends, ', ') as friend_list, -- convert friends string to array
        array_length(split(friends, ', ')) as total_friends -- useful metric
    from source
)

select * from cleaned
