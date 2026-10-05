-- Run this entire file as one batch. No permanent tables are changed.
SET NOCOUNT ON;

-- Table variables exist only in this batch; Northwind is not changed.
DECLARE @Customers TABLE (CustomerID int PRIMARY KEY, CustomerName varchar(20));
DECLARE @Orders TABLE (OrderID int PRIMARY KEY, CustomerID int NULL);

INSERT INTO @Customers VALUES (1, 'Asha'), (2, 'Ben'), (3, 'Cara');
INSERT INTO @Orders VALUES (101, 1), (102, 1), (103, 2), (104, NULL);

SELECT c.CustomerID, c.CustomerName, o.OrderID
FROM @Customers AS c
INNER JOIN @Orders AS o ON c.CustomerID = o.CustomerID
ORDER BY COALESCE(c.CustomerID, 2147483647), o.OrderID;

SELECT c.CustomerID, c.CustomerName, o.OrderID
FROM @Customers AS c
LEFT JOIN @Orders AS o ON c.CustomerID = o.CustomerID
ORDER BY COALESCE(c.CustomerID, 2147483647), o.OrderID;

SELECT c.CustomerID, c.CustomerName, o.OrderID
FROM @Customers AS c
RIGHT JOIN @Orders AS o ON c.CustomerID = o.CustomerID
ORDER BY COALESCE(c.CustomerID, 2147483647), o.OrderID;

SELECT c.CustomerID, c.CustomerName, o.OrderID
FROM @Customers AS c
FULL JOIN @Orders AS o ON c.CustomerID = o.CustomerID
ORDER BY COALESCE(c.CustomerID, 2147483647), o.OrderID;
