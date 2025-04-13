with source as (
    select * from {{ source('yelp_dataset', 'business') }}
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
        hours_Monday as hours_monday,
        hours_Tuesday as hours_tuesday,
        hours_Wednesday as hours_wednesday,
        hours_Thursday as hours_thursday,
        hours_Friday as hours_friday,
        hours_Saturday as hours_saturday,
        hours_Sunday as hours_sunday,

        -- Cleaned attributes
        attributes_ByAppointmentOnly as is_by_appointment_only,
        attributes_BusinessAcceptsCreditCards as accepts_credit_cards,
        attributes_BikeParking as has_bike_parking,
        attributes_RestaurantsPriceRange2 as price_range,
        attributes_CoatCheck as has_coat_check,
        attributes_RestaurantsTakeOut as offers_takeout,
        attributes_RestaurantsDelivery as offers_delivery,
        attributes_Caters as offers_catering,
        attributes_WiFi as wifi,
        attributes_BusinessParking as business_parking,
        attributes_WheelchairAccessible as is_wheelchair_accessible,
        cast(attributes_HappyHour as boolean) as has_happy_hour,
        attributes_OutdoorSeating as has_outdoor_seating,
        attributes_HasTV as has_tv,
        attributes_RestaurantsReservations as accepts_reservations,
        attributes_DogsAllowed as allows_dogs,
        attributes_Alcohol as alcohol,
        attributes_GoodForKids as is_good_for_kids,
        attributes_RestaurantsAttire as attire,
        attributes_Ambience as ambience,
        cast(attributes_RestaurantsGoodForGroups as boolean) as good_for_groups,
        attributes_DriveThru as has_drive_thru,
        attributes_NoiseLevel as noise_level,
        attributes_GoodForMeal as good_for_meal,
        cast(attributes_BusinessAcceptsBitcoin as boolean) as accepts_bitcoin,
        attributes_Smoking as smoking,
        attributes_Music as music,
        cast(attributes_GoodForDancing as boolean) as good_for_dancing,
        cast(attributes_AcceptsInsurance as boolean) as accepts_insurance,
        attributes_BestNights as best_nights,
        attributes_BYOB as byob,
        cast(attributes_Corkage as boolean) as has_corkage,
        attributes_BYOBCorkage as byob_corkage,
        attributes_HairSpecializesIn as hair_specialty,
        cast(attributes_Open24Hours as boolean) as is_open_24_hours,
        cast(attributes_RestaurantsCounterService as boolean) as has_counter_service,
        attributes_AgesAllowed as ages_allowed,
        attributes_DietaryRestrictions as dietary_restrictions,

        -- Original nested string attributes if still needed
        attributes

    from source
)

select * from renamed

