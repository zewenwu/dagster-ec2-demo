WITH raw_calendar AS (
    SELECT * FROM {{ source('airbnb', 'calendar') }}
)
SELECT
    listing_id,
    date,
    available,
    price,
    adjusted_price,
    minimum_nights,
    maximum_nights
FROM
    raw_calendar
