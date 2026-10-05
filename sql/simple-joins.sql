-- Run this whole file together in one batch.
-- These table variables do not change the Northwind tables.
SET NOCOUNT ON;

DECLARE @Customers TABLE (
    CustomerID int,
    CustomerName varchar(20)
);

DECLARE @Orders TABLE (
    OrderID int,
    CustomerID int
);

INSERT INTO @Customers VALUES (1, 'Asha'), (2, 'Ben'), (3, 'Cara');
INSERT INTO @Orders VALUES (101, 1), (102, 1), (103, 2), (104, NULL);

-- INNER JOIN
SELECT c.CustomerName, o.OrderID
FROM @Customers AS c
INNER JOIN @Orders AS o
    ON c.CustomerID = o.CustomerID;

-- LEFT JOIN
SELECT c.CustomerName, o.OrderID
FROM @Customers AS c
LEFT JOIN @Orders AS o
    ON c.CustomerID = o.CustomerID;

-- RIGHT JOIN
SELECT c.CustomerName, o.OrderID
FROM @Customers AS c
RIGHT JOIN @Orders AS o
    ON c.CustomerID = o.CustomerID;

-- FULL JOIN
SELECT c.CustomerName, o.OrderID
FROM @Customers AS c
FULL JOIN @Orders AS o
    ON c.CustomerID = o.CustomerID;
