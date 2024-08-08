CREATE DATABASE IF NOT EXISTS mysql_deep_dive;
USE mysql_deep_dive;

CREATE TABLE customer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00 
);

CREATE TABLE booking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    booking_date DATE NOT NULL,
    status VARCHAR(255) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(id)
);

-- Insert some sample data (with balance and status)
INSERT INTO customer (name, email, balance) VALUES
    ('Alice Johnson', 'alice@example.com', 50.00),
    ('Bob Smith', 'bob@example.com', 100.50);

INSERT INTO booking (customer_id, booking_date, status) VALUES
    (1, '2024-08-15', 'CREATED'),
    (2, '2024-09-20', 'CHECK_OUT');