# Get started

- Start Containers:

```
    docker-compose up -d
```

- To remove container and clear volume

```
    docker-compose down -v
```

- Connect to database

```
    mysql -h 127.0.0.1 -P 3306 -u mysql_deep_dive -p
```

- Command for transaction

```
BEGIN;

INSERT INTO customer (name, email, balance) VALUES ('Charlie Brown', 'charlie@example.com'), 30.00;

UPDATE customer SET balance = balance + 100.00 WHERE id = 1;

SELECT * FROM customer WHERE balance > 0;

DELETE FROM customer WHERE id = 3;

COMMIT;
ROLLBACK;
```

# Scenario 1

Session 1: Starts a transaction and updates a customer's balance.
Session 2: Attempts to read the same customer's balance under different isolation levels.

## Queries

- Session 1

```
    BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- Adjust isolation level as needed

    SELECT * FROM customer WHERE id = 1; -- Check initial balance
    UPDATE customer SET balance = balance + 100 WHERE id = 1; -- Update balance

    -- Leave the transaction open for now
```

- Session 2 (Run these one by one, under different isolation levels)

```
    -- Read Uncommitted
    BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SELECT * FROM customer WHERE id = 1;
    COMMIT;
```

```
    -- Read Committed
    BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SELECT * FROM customer WHERE id = 1;
    COMMIT;
```

```
    -- Repeatable Read
    BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    SELECT * FROM customer WHERE id = 1;
    COMMIT;
```

```
    -- Serializable
    BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    SELECT * FROM customer WHERE id = 1;
    COMMIT;
```

## Observations

- Read Uncommitted: Session 2 will likely see the uncommitted updated balance immediately.
- Read Committed: Session 2 won't see the update until Session 1 commits the transaction.
- Repeatable Read: Session 2 will see the same balance it initially read, even after Session 1 commits.
- Serializable: Session 2 will wait until Session 1's transaction is complete before reading, ensuring a consistent view.
