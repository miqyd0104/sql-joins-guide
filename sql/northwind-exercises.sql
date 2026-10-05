-- Microsoft SQL Server / Northwind. Read-only exercise queries.
USE Northwind;
SET NOCOUNT ON;

-- 1. Customers Orders List
PRINT 'Exercise 1: Customers Orders List';
SELECT c.CustomerID, c.CompanyName, o.OrderID
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON c.CustomerID = o.CustomerID
ORDER BY c.CustomerID, o.OrderID;

-- 2. Orders with Customer Names
PRINT 'Exercise 2: Orders with Customer Names';
SELECT o.OrderID, o.OrderDate, c.CompanyName
FROM dbo.Orders AS o
INNER JOIN dbo.Customers AS c ON o.CustomerID = c.CustomerID
ORDER BY o.OrderID;

-- 3. Orders with Product Names
PRINT 'Exercise 3: Orders with Product Names';
SELECT od.OrderID, p.ProductName, od.Quantity
FROM dbo.[Order Details] AS od
INNER JOIN dbo.Products AS p ON od.ProductID = p.ProductID
ORDER BY od.OrderID, p.ProductID;

-- 4. Order Totals
PRINT 'Exercise 4: Order Totals';
SELECT o.OrderID,
       CAST(COALESCE(SUM(od.UnitPrice * od.Quantity * (1 - CAST(od.Discount AS decimal(5, 4)))), 0) AS decimal(19, 2)) AS OrderTotal
FROM dbo.Orders AS o
LEFT JOIN dbo.[Order Details] AS od ON o.OrderID = od.OrderID
GROUP BY o.OrderID
ORDER BY o.OrderID;

-- 5. Total Spend per Customer
PRINT 'Exercise 5: Total Spend per Customer';
SELECT c.CustomerID, c.CompanyName,
       CAST(COALESCE(SUM(od.UnitPrice * od.Quantity * (1 - CAST(od.Discount AS decimal(5, 4)))), 0) AS decimal(19, 2)) AS TotalSpend
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON c.CustomerID = o.CustomerID
LEFT JOIN dbo.[Order Details] AS od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY c.CustomerID;

-- 6. Customers with No Orders
PRINT 'Exercise 6: Customers with No Orders';
SELECT c.CustomerID, c.CompanyName
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL
ORDER BY c.CustomerID;

-- 7. Products Never Ordered
PRINT 'Exercise 7: Products Never Ordered';
SELECT p.ProductID, p.ProductName
FROM dbo.Products AS p
LEFT JOIN dbo.[Order Details] AS od ON p.ProductID = od.ProductID
WHERE od.ProductID IS NULL
ORDER BY p.ProductID;

-- 8. Orders per Employee
PRINT 'Exercise 8: Orders per Employee';
SELECT e.EmployeeID, e.FirstName, e.LastName,
       COUNT(o.OrderID) AS NumberOfOrders
FROM dbo.Employees AS e
LEFT JOIN dbo.Orders AS o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY e.EmployeeID;

-- 9. Top 5 Customers by Spend
PRINT 'Exercise 9: Top 5 Customers by Spend';
SELECT TOP (5) c.CustomerID, c.CompanyName,
       CAST(COALESCE(SUM(od.UnitPrice * od.Quantity * (1 - CAST(od.Discount AS decimal(5, 4)))), 0) AS decimal(19, 2)) AS TotalSpend
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o ON c.CustomerID = o.CustomerID
INNER JOIN dbo.[Order Details] AS od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - CAST(od.Discount AS decimal(5, 4)))) DESC, c.CustomerID;

-- 10. Revenue by Category
PRINT 'Exercise 10: Revenue by Category';
SELECT cat.CategoryID, cat.CategoryName,
       CAST(COALESCE(SUM(od.UnitPrice * od.Quantity * (1 - CAST(od.Discount AS decimal(5, 4)))), 0) AS decimal(19, 2)) AS Revenue
FROM dbo.Categories AS cat
LEFT JOIN dbo.Products AS p ON cat.CategoryID = p.CategoryID
LEFT JOIN dbo.[Order Details] AS od ON p.ProductID = od.ProductID
GROUP BY cat.CategoryID, cat.CategoryName
ORDER BY cat.CategoryID;

-- 11. Full Order Breakdown
PRINT 'Exercise 11: Full Order Breakdown';
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

-- 12. Average Order Value per Customer
PRINT 'Exercise 12: Average Order Value per Customer';
WITH OrderTotals AS (
    SELECT o.OrderID, o.CustomerID,
           COALESCE(SUM(od.UnitPrice * od.Quantity * (1 - CAST(od.Discount AS decimal(5, 4)))), 0) AS OrderTotal
    FROM dbo.Orders AS o
    LEFT JOIN dbo.[Order Details] AS od ON o.OrderID = od.OrderID
    GROUP BY o.OrderID, o.CustomerID
)
SELECT c.CustomerID, c.CompanyName,
       COUNT(ot.OrderID) AS NumberOfOrders,
       CAST(COALESCE(SUM(ot.OrderTotal), 0) AS decimal(19, 2)) AS TotalSpend,
       CAST(AVG(ot.OrderTotal) AS decimal(19, 2)) AS AverageOrderValue
FROM dbo.Customers AS c
LEFT JOIN OrderTotals AS ot ON c.CustomerID = ot.CustomerID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY c.CustomerID;

-- 13. Employees with No Orders
PRINT 'Exercise 13: Employees with No Orders';
SELECT e.EmployeeID, e.FirstName, e.LastName
FROM dbo.Employees AS e
LEFT JOIN dbo.Orders AS o ON e.EmployeeID = o.EmployeeID
WHERE o.OrderID IS NULL
ORDER BY e.EmployeeID;

-- 14. Most Popular Product
PRINT 'Exercise 14: Most Popular Product';
SELECT TOP (1) WITH TIES p.ProductID, p.ProductName,
       SUM(od.Quantity) AS TotalQuantityOrdered
FROM dbo.Products AS p
INNER JOIN dbo.[Order Details] AS od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY SUM(od.Quantity) DESC;

-- 15. Orders with Shipping Company
PRINT 'Exercise 15: Orders with Shipping Company';
SELECT o.OrderID, s.CompanyName AS ShipperName
FROM dbo.Orders AS o
LEFT JOIN dbo.Shippers AS s ON o.ShipVia = s.ShipperID
ORDER BY o.OrderID;
