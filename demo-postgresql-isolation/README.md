# Get started

- Make Script Executable: Run chmod +x init-db.sh to make the script executable.

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
    psql -h localhost -p 5432 -U postgres-deep-dive -d postgres-deep-dive
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

# Transaction Isolation Levels

| Isolation Level  | Dirty Read             | Nonrepeatable Read         | Phantom Read           | Serialization Anomaly |
| ---------------- | ---------------------- | -------------------------- | ---------------------- | --------------------- |
| Read uncommitted | Allowed, but not in PG | Possible Possible Possible |
| Read committed   | Not possible           | Possible                   | Possible               | Possible              |
| Repeatable read  | Not possible           | Not possible               | Allowed, but not in PG | Possible              |
| Serializable     | Not possible           | Not possible               | Not possible           | Not possible          |

# Scenario 1: Dirty read / non-repeatable read

Session 1: Starts a transaction and updates a customer's balance.
Session 2:

- For dirty read test, attempts to read the same customer's balance under different isolation levels.
- For non-repeatable read test, attempts to update and read the same customer's balance under different isolation levels.

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
    -- Read Committed
    BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SELECT * FROM customer WHERE id = 1;

    UPDATE customer SET balance = balance + 100 WHERE id = 1; -- If session 1 rollback => dirty write
    SELECT * FROM customer WHERE id = 1; -- Check non-repeatable read

    COMMIT;
```

```
    -- Repeatable Read
    BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    SELECT * FROM customer WHERE id = 1;

    UPDATE customer SET balance = balance + 100 WHERE id = 1; -- Raise error immediately
    COMMIT;
```

```
    -- Serializable
    BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    SELECT * FROM customer WHERE id = 1;

    UPDATE customer SET balance = balance + 100 WHERE id = 1; -- Wait until Session 1's transaction is complete, then raise error
    COMMIT;
```

## Observations

- Read Uncommitted: Same behavior with Read Committed
- Read Committed:
  - Session 2 won't see the update until Session 1 commits the transaction.
  - Session 2 is able to update the balance
- Repeatable Read:
  - Session 2 will see the same balance it initially read, even after Session 1 commits.
  - Session 2 is not able to update the balance, raise error immediately
- Serializable:
  - Session 2 will see the same balance it initially read, even after Session 1 commits.
  - Session 2 will wait until Session 1's transaction is complete before updating, ensuring a consistent view.

# Scenario 2: Phantom read

Session 1: Starts a transaction and queries for customers with a balance over $50.
Session 2: Inserts a new customer with a balance of $100.
Session 1: Repeats the same query and observes a new result that wasn't present in the initial query.

## Queries

- Session 1 (Run these one by one, under different isolation levels)

```
    BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- Adjust isolation level as needed

    SELECT * FROM customer WHERE balance > 50;

    -- Leave the transaction open for now
```

- Session 2

```
    -- Read Committed
    BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

    INSERT INTO customer (name, email, balance) VALUES ('David Lee', 'david@example.com', 100.00);

    COMMIT;
```

- Session 1

```
    SELECT * FROM customer WHERE balance > 50;
```

## Observations

- In Session 1,
  - For Read Uncommitted/Read Committed, the second query will now return an additional row for David Lee, even though this customer was not present in the initial result set. This is the hallmark of a phantom read.
  - For Repeatable Read/Serializable, the second query will return that same result with previous query.

# Scenario 3: Serialization anomaly

- https://dev.to/tlphat/locking-mechanism-serializable-and-deadlock-17l2
- https://dba.stackexchange.com/questions/315343/is-a-serialization-anomaly-only-possible-with-sum-count
