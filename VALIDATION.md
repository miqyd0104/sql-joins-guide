# Validation

Checked on **5 October 2026** against the existing **Northwind** database in the local SQL Server 2022 Docker training environment.

## Execution checks

- All 15 exercise queries completed successfully on SQL Server with error checking enabled.
- The fictional table-variable examples returned exactly 3 INNER, 4 LEFT, 4 RIGHT and 5 FULL JOIN rows, matching the guide and diagram.
- The Markdown exercise code blocks match the runnable SQL file.
- The JOIN diagram was rendered and visually checked for readability.
- No permanent tables or records were changed.

## Correctness checks

- Independently recalculated discounted totals from the source order lines using decimal arithmetic. Every order total, customer total, category total and customer average matched the SQL output at two decimal places.
- Unrounded order, customer and category totals reconciled with each other.
- Customer and employee order counts each reconciled with the total number of orders.
- The top-five customer ranking and most popular product were checked against independent calculations.
- Customers without orders had zero orders, zero spend and NULL average order value.
- Queries for products never ordered and employees without orders completed successfully. Empty result sets are valid when every relevant record has an order.

Totals are rounded at the reporting level. Adding already-rounded displayed rows can therefore differ slightly between reports; compare unrounded aggregates when reconciling reports.

Results depend on the data present when queries run. These checks validate the current training setup; they do not guarantee identical results for a different or modified database.

Only query definitions and fictional teaching examples are published. Database row data, customer spending results, validation logs and connection credentials are excluded from this repository.
