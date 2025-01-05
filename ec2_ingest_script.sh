#!/bin/bash

sudo yum install mysql nc -y

export DB_HOST=airbnbdb.cfatkqyhlt8k.us-east-1.rds.amazonaws.com
export DB_USER=dbadmin
export DB_PASS='CdIT7Sfr6xKhuLvC2ofcwW5yG40kivdo'
export DB_PORT=3306  # Ensure this matches your RDS instance port

# Test network connectivity to the RDS instance
echo "Testing network connectivity to RDS instance..."
nc -zv $DB_HOST $DB_PORT

# Connect to the MySQL server
echo "Connecting to MySQL server..."
sudo mysql -h $DB_HOST -P $DB_PORT -u $DB_USER --password=$DB_PASS
