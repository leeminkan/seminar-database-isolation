#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE TABLE customer (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      balance NUMERIC(10, 2) DEFAULT 0.00 -- Add the balance column with a default value of 0.00
  );

  CREATE TABLE booking (
      id SERIAL PRIMARY KEY,
      customer_id INTEGER REFERENCES customer(id) NOT NULL,
      booking_date DATE NOT NULL,
      status VARCHAR(255) NOT NULL
  );

  -- Example customer data
  INSERT INTO customer (name, email, balance) VALUES
      ('Alice Johnson', 'alice@example.com', 50.00),
      ('Bob Smith', 'bob@example.com', 20.50);

  -- Example booking data
  INSERT INTO booking (customer_id, booking_date, status) VALUES
      (1, '2024-08-15', 'CREATED'),  
      (2, '2024-09-20', 'CHECK_OUT');
EOSQL
