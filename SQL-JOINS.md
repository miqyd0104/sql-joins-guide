# SQL JOINs

These notes cover the main JOIN types and some exercises using the Northwind database in SQL Server.

## What is a JOIN?

A JOIN brings related data from different tables into one result. For example, Northwind stores customer names in `Customers` and order information in `Orders`. A JOIN lets us see who placed each order.

The tables are usually linked through an ID. `Customers.CustomerID` identifies a customer, and `Orders.CustomerID` tells us which customer an order belongs to.

## How does it work?

```sql
SELECT c.CompanyName, o.OrderID
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID;
```

The `ON` line is the matching condition. Here, SQL matches a customer to any orders with the same `CustomerID`. The `SELECT` line chooses the columns to display.

`c` and `o` are aliases, which are shorter names for the tables. `dbo` is the schema the tables belong to. If a customer has three orders, their name appears on three result rows. That is expected because each row represents a different order.

## The four JOIN types

For the examples below, imagine these two small tables.

**Customers**

| CustomerID | CustomerName |
| --- | --- |
| 1 | Asha |
| 2 | Ben |
| 3 | Cara |

**Orders**

| OrderID | CustomerID |
| --- | --- |
| 101 | 1 |
| 102 | 1 |
| 103 | 2 |
| 104 | NULL |

Asha has two orders, Ben has one and Cara has none. Order 104 is an example of an order that has not been assigned to a customer. `NULL` means a missing or unknown value.

![Examples of INNER, LEFT, RIGHT and FULL JOIN results](images/sql-joins.svg)

The diagram shows which rows each JOIN includes. Without `ORDER BY`, SQL does not guarantee the order in which result rows appear.

To try the examples, run this setup and the queries together in one batch. The `@` tables only last for that batch, so they will not change the Northwind tables. The complete example is also in [simple-joins.sql](sql/simple-joins.sql).

```sql
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
```

### INNER JOIN

An INNER JOIN returns only the rows that match in both tables.

```sql
SELECT c.CustomerName, o.OrderID
FROM @Customers AS c
INNER JOIN @Orders AS o
    ON c.CustomerID = o.CustomerID;
```

This returns Asha with orders 101 and 102, and Ben with order 103. Cara and order 104 are left out because they have no match.

### LEFT JOIN

A LEFT JOIN keeps every row from the left table, plus any matching rows from the right table. Here, Customers is the left table because it comes before `JOIN`.

```sql
SELECT c.CustomerName, o.OrderID
FROM @Customers AS c
LEFT JOIN @Orders AS o
    ON c.CustomerID = o.CustomerID;
```

This returns the same matches as the INNER JOIN, plus Cara with a `NULL` OrderID. It is useful when a report needs every customer, including those who have never ordered.

### RIGHT JOIN

A RIGHT JOIN keeps every row from the right table, plus any matching rows from the left table.

```sql
SELECT c.CustomerName, o.OrderID
FROM @Customers AS c
RIGHT JOIN @Orders AS o
    ON c.CustomerID = o.CustomerID;
```

Orders is now the side being kept. Order 104 appears with a `NULL` customer name. Cara is left out. Swapping the tables and using a LEFT JOIN would also keep all the orders.

### FULL JOIN

A FULL JOIN keeps matches and unmatched rows from both tables.

```sql
SELECT c.CustomerName, o.OrderID
FROM @Customers AS c
FULL JOIN @Orders AS o
    ON c.CustomerID = o.CustomerID;
```

Both Cara and order 104 appear, as well as the matching rows. This can help when comparing two lists and checking what is missing from either one.

`LEFT OUTER JOIN`, `RIGHT OUTER JOIN` and `FULL OUTER JOIN` mean the same as the shorter versions above. The word `OUTER` is optional.

## Why use JOINs?

Keeping information in separate tables avoids repeating the same details everywhere. A customer's address can be stored once instead of copied into every order. JOINs let us bring those tables together when we need a report.

They are useful for finding out who bought a product, how much an order was worth, or which customers have never placed an order. The tables stay separate; the query combines their data in the result.

## Northwind exercises

The selected exercises are **1, 2, 3, 4, 6, 8, 11 and 15** from the task sheet. The remaining exercises are not included.

Run these with the Northwind database selected in VS Code. The same queries are in [northwind-exercises.sql](sql/northwind-exercises.sql).

```sql
USE Northwind;
```

`[Order Details]` stores the products on each order, including quantity, price and discount. The brackets are needed because the table name contains a space.

### 1. Customers and their orders

Use a LEFT JOIN so customers without orders are included. Their OrderID will be NULL.

```sql
SELECT c.CustomerID, c.CompanyName, o.OrderID
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON c.CustomerID = o.CustomerID
ORDER BY c.CustomerID, o.OrderID;
```

### 2. Orders with customer names

Match each order to its customer to show the order date and company name.

```sql
SELECT o.OrderID, o.OrderDate, c.CompanyName
FROM dbo.Orders AS o
INNER JOIN dbo.Customers AS c ON o.CustomerID = c.CustomerID
ORDER BY o.OrderID;
```

### 3. Orders with product names

Order Details has the ProductID and quantity. Joining it to Products adds the product name.

```sql
SELECT od.OrderID, p.ProductName, od.Quantity
FROM dbo.[Order Details] AS od
INNER JOIN dbo.Products AS p ON od.ProductID = p.ProductID
ORDER BY od.OrderID, p.ProductID;
```

### 4. Order totals

Add up the items on each order, including their discounts. Use the price from Order Details because it is the price charged on that order.

```sql
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
```

For example, three items at 10.00 each with a 10% discount cost `10 × 3 × 0.90 = 27.00`.

`SUM` adds the line values, and `GROUP BY` gives one total per order. The first `CAST` converts the discount to a decimal for the calculation. The final `CAST` gives the total two decimal places. `COALESCE(..., 0)` gives an order with no lines a total of zero. Freight and tax are not included.

### 6. Customers with no orders

Keep every customer first, then look for a missing order. Use IS NULL to check for a missing value.

```sql
SELECT c.CustomerID, c.CompanyName
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL
ORDER BY c.CustomerID;
```

### 8. Orders per employee

Group the results by employee and count their orders. COUNT(o.OrderID) ignores NULL, so an employee without orders gets zero.

```sql
SELECT e.EmployeeID, e.FirstName, e.LastName,
       COUNT(o.OrderID) AS NumberOfOrders
FROM dbo.Employees AS e
LEFT JOIN dbo.Orders AS o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY e.EmployeeID;
```

### 11. Full order breakdown

This joins four tables to show the customer and product information for each order line. An order with several products appears on several rows.

```sql
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
```

### 15. Orders with the shipping company

ShipVia holds the shipper ID. A LEFT JOIN keeps orders even if a shipper has not been assigned yet.

```sql
SELECT o.OrderID, s.CompanyName AS ShipperName
FROM dbo.Orders AS o
LEFT JOIN dbo.Shippers AS s ON o.ShipVia = s.ShipperID
ORDER BY o.OrderID;
```

## Things to remember

- Check the join condition carefully. The columns need to represent the same relationship.
- More result rows do not always mean an error. One customer can match several orders.
- Use `IS NULL`, not `= NULL`, when checking for missing values.
- `COUNT(*)` counts result rows. After a LEFT JOIN, use the matching table's ID if you want to count actual matches.
- A filter in `WHERE` that requires a value from the right table can remove the unmatched rows from a LEFT JOIN.

## References

- [Microsoft Learn: SQL Server JOINs](https://learn.microsoft.com/en-us/sql/relational-databases/performance/joins?view=sql-server-ver17)

Prepared with AI assistance. The examples and selected exercises were checked against SQL Server.
