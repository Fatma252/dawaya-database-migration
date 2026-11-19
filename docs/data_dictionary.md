# Data Dictionary - Dawaya `flat_sales_export.csv`

Dawaya keeps every sale in one shared spreadsheet that staff at all branches update by hand. This export covers **1 July - 30 September 2026** for the six branches that were open in that period: 573 rows. It is a random sample of transactions taken from the sheet for this project (the full sheet is far larger).

| Column | Type | Meaning |
| :--- | :--- | :--- |
| `transaction_id` | Text | One checkout. A transaction with several products appears on several rows. |
| `transaction_date` | Date and time | Local Cairo time, `YYYY-MM-DD HH:MM`. |
| `branch_id / branch_name / branch_address` | Text | The branch where the sale happened (`BR-01` to `BR-06` in this export). |
| `pharmacist_id / pharmacist_name` | Text | The pharmacist who served the customer (`PH-` + 4 digits). |
| `customer_id / customer_name / customer_phone` | Text | Loyalty customer. Empty for guest checkouts. Phone numbers are Egyptian mobiles. |
| `payment_method` | Text | Cash, Card or InstaPay. One payment method per transaction. |
| `product_id` | Text | Internal SKU. The SKU is the reliable product identifier. |
| `product_name / category_name` | Text | Typed by staff at the till. |
| `unit_price` | Decimal (EGP) | Price of one unit at the time of sale. Some prices changed on the official list on 15 Aug 2026. |
| `quantity_sold` | Integer | Units of this product in this transaction (at least 1). |
| `total_line_price` | Decimal (EGP) | unit_price x quantity_sold, typed into the sheet (not a formula). |

## Known problems reported by staff

- The same product, branch or pharmacist is sometimes typed in different ways.
- Phone numbers are written in more than one format.
- Some prices were overridden by hand at the till, and some line totals were typed wrongly.
- A few lines may have been pasted twice.

Decide how your design and your load script deal with each of these, and say so in your report.

## Reference data that is not in the export

Dawaya New Capital opened on 1 October 2026, so it has no sales in this export. Add it to your database:

| branch_id | branch_name | branch_address | pharmacist_id | pharmacist_name |
| :--- | :--- | :--- | :--- | :--- |
| BR-07 | Dawaya New Capital | Downtown Mall, R7, New Administrative Capital | PH-0113 | Mai Hossam |
