#!/bin/bash

# Install PostgreSQL client
sudo amazon-linux-extras install postgresql12 -y
sudo yum install postgresql12 -y

# PostgreSQL connection details (TO BE UPDATED)
export DB_HOST=airbnbdb.cfatkqyhlt8k.us-east-1.rds.amazonaws.com
export DB_PORT=5432
export LOCAL_DB_HOST=localhost
export LOCAL_DB_PORT=5433

aws ssm start-session \
    --target i-0a876644a869cf1ef \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters "{\"host\":[\"$DB_HOST\"],\"portNumber\":[\"$DB_PORT\"], \"localPortNumber\":[\"$LOCAL_DB_PORT\"]}"

export DB_USER=dbadmin # TODO: read from Secrets Manager
export DB_PASS='xxx'
export DB_NAME=airbnbdb

# Connect to the MySQL server
echo "Connecting to PostgreSQL server..."
PGPASSWORD=$DB_PASS psql -h $LOCAL_DB_HOST -p $LOCAL_DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT version();"

# Go to the home directory
cd ~

# Download the CSV files
echo "Downloading CSV files..."
wget -q https://data.insideairbnb.com/belgium/vlg/antwerp/2024-09-26/data/calendar.csv.gz
wget -q https://data.insideairbnb.com/belgium/vlg/antwerp/2024-09-26/data/listings.csv.gz
wget -q https://data.insideairbnb.com/belgium/vlg/antwerp/2024-09-26/data/reviews.csv.gz

# Extract the CSV files
echo "Extracting CSV files..."
gunzip -f calendar.csv.gz
gunzip -f listings.csv.gz
gunzip -f reviews.csv.gz

# Create tables and import data into PostgreSQL
echo "Creating tables and importing data..."

# Create and import calendar table
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
DROP TABLE IF EXISTS calendar;
CREATE TABLE calendar (
    listing_id BIGINT,
    date DATE,
    available BOOLEAN,
    price TEXT,
    adjusted_price TEXT,
    minimum_nights INTEGER,
    maximum_nights INTEGER
);"
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\copy calendar FROM 'calendar.csv' DELIMITER ',' CSV HEADER;"

# Create and import listings table
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
DROP TABLE IF EXISTS listings;
CREATE TABLE listings (
    id BIGINT,
    listing_url TEXT,
    scrape_id BIGINT,
    last_scraped DATE,
    source TEXT,
    name TEXT,
    description TEXT,
    neighborhood_overview TEXT,
    picture_url TEXT,
    host_id BIGINT,
    host_url TEXT,
    host_name TEXT,
    host_since DATE,
    host_location TEXT,
    host_about TEXT,
    host_response_time TEXT,
    host_response_rate TEXT,
    host_acceptance_rate TEXT,
    host_is_superhost BOOLEAN,
    host_thumbnail_url TEXT,
    host_picture_url TEXT,
    host_neighbourhood TEXT,
    host_listings_count INTEGER,
    host_total_listings_count INTEGER,
    host_verifications TEXT,
    host_has_profile_pic BOOLEAN,
    host_identity_verified BOOLEAN,
    neighbourhood TEXT,
    neighbourhood_cleansed TEXT,
    neighbourhood_group_cleansed TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    property_type TEXT,
    room_type TEXT,
    accommodates INTEGER,
    bathrooms NUMERIC,
    bathrooms_text TEXT,
    bedrooms INTEGER,
    beds INTEGER,
    amenities TEXT,
    price TEXT,
    minimum_nights INTEGER,
    maximum_nights INTEGER,
    minimum_minimum_nights INTEGER,
    maximum_minimum_nights INTEGER,
    minimum_maximum_nights INTEGER,
    maximum_maximum_nights INTEGER,
    minimum_nights_avg_ntm NUMERIC,
    maximum_nights_avg_ntm NUMERIC,
    calendar_updated TEXT,
    has_availability BOOLEAN,
    availability_30 INTEGER,
    availability_60 INTEGER,
    availability_90 INTEGER,
    availability_365 INTEGER,
    calendar_last_scraped DATE,
    number_of_reviews INTEGER,
    number_of_reviews_ltm INTEGER,
    number_of_reviews_l30d INTEGER,
    first_review DATE,
    last_review DATE,
    review_scores_rating NUMERIC,
    review_scores_accuracy NUMERIC,
    review_scores_cleanliness NUMERIC,
    review_scores_checkin NUMERIC,
    review_scores_communication NUMERIC,
    review_scores_location NUMERIC,
    review_scores_value NUMERIC,
    license TEXT,
    instant_bookable BOOLEAN,
    calculated_host_listings_count INTEGER,
    calculated_host_listings_count_entire_homes INTEGER,
    calculated_host_listings_count_private_rooms INTEGER,
    calculated_host_listings_count_shared_rooms INTEGER,
    reviews_per_month NUMERIC
);"
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\copy listings FROM 'listings.csv' DELIMITER ',' CSV HEADER;"

# Create and import reviews table
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
    listing_id BIGINT,
    id BIGINT,
    date DATE,
    reviewer_id INTEGER,
    reviewer_name TEXT,
    comments TEXT
);"
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\copy reviews FROM 'reviews.csv' DELIMITER ',' CSV HEADER;"

echo "DATA INGESTION COMPLETED!"
