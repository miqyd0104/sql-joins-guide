-- Selected exercises from the task sheet: 1, 2, 3, 4, 6, 8, 11 and 15.
USE Northwind;
SET NOCOUNT ON;

-- 1. Customers and their orders
PRINT 'Exercise 1';
SELECT c.CustomerID, c.CompanyName, o.OrderID
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON c.CustomerID = o.CustomerID
ORDER BY c.CustomerID, o.OrderID;

-- 2. Orders with customer names
PRINT 'Exercise 2';
SELECT o.OrderID, o.OrderDate, c.CompanyName
FROM dbo.Orders AS o
INNER JOIN dbo.Customers AS c ON o.CustomerID = c.CustomerID
ORDER BY o.OrderID;

-- 3. Orders with product names
PRINT 'Exercise 3';
SELECT od.OrderID, p.ProductName, od.Quantity
FROM dbo.[Order Details] AS od
INNER JOIN dbo.Products AS p ON od.ProductID = p.ProductID
ORDER BY od.OrderID, p.ProductID;

-- 4. Order totals
PRINT 'Exercise 4';
SELECT o.OrderID,
       CAST(
           COALESCE(SUM(
               od.UnitPrice * od.Quantity
               * (1 - CAST(od.Discount AS decimal(5, 4)))
           ), 0)
           AS decimal(19, 2)
       ) AS OrderTotal
FROM dbo.Orders AS o
LEFT JOIN dbo.[Order Details] AS od ON o.OrderID = od.OrderID
GROUP BY o.OrderID
ORDER BY o.OrderID;

-- 6. Customers with no orders
PRINT 'Exercise 6';
SELECT c.CustomerID, c.CompanyName
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL
ORDER BY c.CustomerID;

-- 8. Orders per employee
PRINT 'Exercise 8';
SELECT e.EmployeeID, e.FirstName, e.LastName,
       COUNT(o.OrderID) AS NumberOfOrders
FROM dbo.Employees AS e
LEFT JOIN dbo.Orders AS o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY e.EmployeeID;

-- 11. Full order breakdown
PRINT 'Exercise 11';
SELECT o.OrderID,
       c.CompanyName AS CustomerName,
       p.ProductName,
       od.Quantity,
       od.UnitPrice
FROM dbo.Orders AS o
INNER JOIN dbo.Customers AS c ON o.CustomerID = c.CustomerID
INNER JOIN dbo.[Order Details] AS od ON o.OrderID = od.OrderID
INNER JOIN dbo.Products AS p ON od.ProductID = p.ProductID
ORDER BY o.OrderID, p.ProductID;

-- 15. Orders with the shipping company
PRINT 'Exercise 15';
SELECT o.OrderID, s.CompanyName AS ShipperName
FROM dbo.Orders AS o
LEFT JOIN dbo.Shippers AS s ON o.ShipVia = s.ShipperID
ORDER BY o.OrderID;
