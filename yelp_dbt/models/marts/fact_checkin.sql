{{ config(
    materialized='table',
    partition_by={
        "field": "checkin_month",
        "data_type": "DATE"
    }
) }}

with checkins as (
    select * from {{ ref('stg_checkin') }}
),

split_checkins as (
    select
        business_id,
        split(checkin_timestamps, ',') as checkin_array
    from checkins
),

unnested as (
    select
        business_id,
        trim(dt) as checkin_time_str
    from split_checkins,
    unnest(checkin_array) as dt
),

parsed as (
    select
        business_id,
        parse_timestamp('%Y-%m-%d %H:%M:%S', checkin_time_str) as checkin_timestamp,
        date_trunc(cast(parse_timestamp('%Y-%m-%d %H:%M:%S', checkin_time_str) as date), month) as checkin_month,
        format_date('%A', parse_timestamp('%Y-%m-%d %H:%M:%S', checkin_time_str)) as checkin_day,
        format_time('%H:%M', time(parse_timestamp('%Y-%m-%d %H:%M:%S', checkin_time_str))) as checkin_time
    from unnested
    where checkin_time_str is not null
)

select * from parsed

