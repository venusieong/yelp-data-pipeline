{{ config(materialized='table') }}

with src as (
    select * from {{ ref('stg_business') }}
),

renamed as (
    select
        business_id,
        name,
        address,
        city,
        state,
        postal_code,
        latitude,
        longitude,
        stars,
        review_count,
        is_open,
        categories,

        -- Business hours
        hours_monday,
        hours_tuesday,
        hours_wednesday,
        hours_thursday,
        hours_friday,
        hours_saturday,
        hours_sunday,
        {{ cast_to_boolean('is_by_appointment_only') }} as is_by_appointment_only,
        {{ cast_to_boolean('accepts_credit_cards') }} as accepts_credit_cards,
        has_happy_hour,
        good_for_groups,
        accepts_bitcoin,
        good_for_dancing,
        accepts_insurance,
        has_corkage,
        is_open_24_hours,
        has_counter_service,
        {{ cast_to_boolean('has_bike_parking') }} as has_bike_parking,
        {{ cast_to_boolean('offers_delivery') }} as offers_delivery,
        {{ cast_to_boolean('is_wheelchair_accessible') }} as is_wheelchair_accessible,
        {{ cast_to_boolean('has_outdoor_seating') }} as has_outdoor_seating,
        {{ cast_to_boolean('has_tv') }} as has_tv,
        {{ cast_to_boolean('accepts_reservations') }} as accepts_reservations,
        {{ cast_to_boolean('allows_dogs') }} as allows_dogs,
        {{ cast_to_boolean('is_good_for_kids') }} as is_good_for_kids,
        {{ cast_to_boolean('has_drive_thru') }} as has_drive_thru,
        {{ cast_to_boolean('has_coat_check') }} as has_coat_check,
        {{ cast_to_boolean('offers_takeout') }} as offers_takeout,
        {{ cast_to_boolean('offers_catering') }} as offers_catering,
        price_range,
        wifi,
        business_parking,
        alcohol,
        attire,
        ambience,
        noise_level,
        good_for_meal,
        best_nights,
        byob,
        byob_corkage,
        hair_specialty,
        ages_allowed,
        dietary_restrictions

    from src
)

select * from renamed

