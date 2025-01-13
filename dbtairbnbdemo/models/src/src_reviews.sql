WITH raw_reviews AS (
    SELECT * FROM {{ source('airbnb', 'reviews') }}
)
SELECT
    listing_id,
    id AS review_id,
    date AS review_date,
    reviewer_id,
    reviewer_name,
    comments AS review_text
FROM
    raw_reviews
