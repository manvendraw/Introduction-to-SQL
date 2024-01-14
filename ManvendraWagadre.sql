USE orders;
show tables;
describe online_customer;
select * from online_customer;

/* Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), both first name and
last name are in upper case, customer_email, customer_creation_year and display customer’s category
after applying below categorization rules:
i. if CUSTOMER_CREATION_DATE year <2005 then category A
ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B
iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C*/ 

SELECT CONCAT(B.TITLE, ' ', B.CUSTOMER_FNAME, ' ', B.CUSTOMER_LNAME) 'CUSTOMER FULL NAME', A.CUSTOMER_EMAIL, A.CUSTOMER_CREATION_DATE, B.CUSTOMER_CATEGORY
FROM ONLINE_CUSTOMER A
INNER JOIN 
		(SELECT
		CASE WHEN CUSTOMER_GENDER = 'F'
		THEN 'Ms'
		ELSE 'Mr'
		END AS Title,
		CUSTOMER_ID,
		UPPER(CUSTOMER_FNAME) CUSTOMER_FNAME,
		UPPER(CUSTOMER_LNAME) CUSTOMER_LNAME,
		CASE 
		WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005
		THEN 'Category A'
		WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011
		THEN 'Category B'
		WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2011
		THEN 'Category C'
		ELSE 'UNKNOWN CATEGORY'
		END AS CUSTOMER_CATEGORY
		FROM online_customer) B
ON A.CUSTOMER_ID = B.CUSTOMER_ID

/* Q2. Write a query to display the following information for the products which have not been sold:
product_id, product_desc, product_quantity_avail, product_price,
inventory values (product_quantity_avail * product_price), New_Price after applying discount as per
below criteria. Sort the output with respect to decreasing value of Inventory_Value.
i) If Product Price > 20,000 then apply 20% discount
ii) If Product Price > 10,000 then apply 15% discount
iii) if Product Price =< 10,000 then apply 10% discount */

SELECT
p.PRODUCT_ID,
p.PRODUCT_DESC,
p.PRODUCT_QUANTITY_AVAIL,
p.PRODUCT_PRICE,
(p.PRODUCT_QUANTITY_AVAIL*p.PRODUCT_PRICE) 'INVENTORY VALUE',
CASE 
WHEN p.PRODUCT_PRICE > 20000
THEN (p.PRODUCT_PRICE - (p.PRODUCT_PRICE * 0.20))
WHEN p.PRODUCT_PRICE > 10000
THEN (p.PRODUCT_PRICE - (p.PRODUCT_PRICE * 0.15))
WHEN PRODUCT_PRICE <= 10000
THEN (p.PRODUCT_PRICE - (p.PRODUCT_PRICE * 0.10))
END AS NEW_PRICE
FROM product p
LEFT JOIN ORDER_ITEMS o
ON p.PRODUCT_ID = o.PRODUCT_ID
WHERE o.ORDER_ID IS NULL
ORDER BY PRODUCT_QUANTITY_AVAIL DESC

/* Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each
product class, Inventory Value (p.product_quantity_avail*p.product_price). Information should be
displayed for only those product_class_code which have more than 1,00,000 Inventory Value. Sort the
output with respect to decreasing value of Inventory_Value. */

SELECT
pr.PRODUCT_CLASS_CODE,
pc.PRODUCT_CLASS_DESC,
COUNT(pr.PRODUCT_CLASS_CODE) 'PRODUCT CLASS COUNT',
(pr.PRODUCT_QUANTITY_AVAIL*pr.PRODUCT_PRICE) 'INVENTORY VALUE'
FROM PRODUCT pr
INNER JOIN PRODUCT_CLASS pc
ON pr.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
WHERE (pr.PRODUCT_QUANTITY_AVAIL*pr.PRODUCT_PRICE) > 100000
GROUP BY pr.PRODUCT_CLASS_CODE, pc.PRODUCT_CLASS_DESC, pr.PRODUCT_QUANTITY_AVAIL, pr.PRODUCT_PRICE
ORDER BY (pr.PRODUCT_QUANTITY_AVAIL*pr.PRODUCT_PRICE) DESC

/*
Q4. Write a query to display customer_id, full name, customer_email, customer_phone and country of
customers who have cancelled all the orders placed by them.
*/
SELECT 
oc.CUSTOMER_ID, 
CONCAT(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) 'FULL NAME', 
oc.CUSTOMER_EMAIL, 
oc.CUSTOMER_PHONE,
ad.COUNTRY
FROM ONLINE_CUSTOMER oc
INNER JOIN ADDRESS ad
ON oc.ADDRESS_ID = ad.ADDRESS_ID
INNER JOIN ORDER_HEADER oh
ON oc.CUSTOMER_ID = oh.CUSTOMER_ID
WHERE oh.ORDER_STATUS = 'CANCELLED'

/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the
shipper in the city , number of consignment delivered to that city for Shipper DHL*/

SELECT 
sh.SHIPPER_NAME,
ad.CITY,
COUNT(oh.CUSTOMER_ID) 'CUSTOMER CATERED',
COUNT(oh.ORDER_STATUS) 'CONSIGMENTS DELIVERED'
FROM SHIPPER sh
INNER JOIN ORDER_HEADER oh
ON sh.SHIPPER_ID = oh.SHIPPER_ID
INNER JOIN ONLINE_CUSTOMER oc
ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
INNER JOIN ADDRESS ad
ON oc.ADDRESS_ID = ad.ADDRESS_ID
WHERE oh.ORDER_STATUS = 'SHIPPED'
AND sh.SHIPPER_NAME = 'DHL'
GROUP BY  sh.SHIPPER_NAME, ad.CITY

/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and show
inventory Status of products as per below condition: */
SELECT 
pr.PRODUCT_ID,
pr.PRODUCT_DESC,
pr.PRODUCT_QUANTITY_AVAIL,
po.QUANTITY_SOLD,
CASE 
WHEN pc.PRODUCT_CLASS_DESC IN('ELECTRONICS', 'COMPUTER')
THEN
	CASE WHEN po.QUANTITY_SOLD = 0
    THEN 'No Sales in past, give discount to reduce inventory'
    WHEN pr.PRODUCT_QUANTITY_AVAIL < (po.QUANTITY_SOLD * 0.10)
	THEN  'Low inventory, need to add inventory'
	WHEN pr.PRODUCT_QUANTITY_AVAIL >= (po.QUANTITY_SOLD * 0.50)
	THEN 'Sufficient inventory'
    END
WHEN pc.PRODUCT_CLASS_DESC IN('MOBILES', 'WATCHES')
THEN
	CASE WHEN po.QUANTITY_SOLD = 0
    THEN 'No Sales in past, give discount to reduce inventory'
	WHEN pr.PRODUCT_QUANTITY_AVAIL < (po.QUANTITY_SOLD * 0.20)
	THEN  'Low inventory, need to add inventory'
	WHEN pr.PRODUCT_QUANTITY_AVAIL >= (po.QUANTITY_SOLD * 0.60)
	THEN 'Sufficient inventory'
    END
ELSE
	CASE WHEN po.QUANTITY_SOLD = 0
    THEN 'No Sales in past, give discount to reduce inventory'
	WHEN pr.PRODUCT_QUANTITY_AVAIL < (po.QUANTITY_SOLD * 0.30)
	THEN  'Low inventory, need to add inventory'
	WHEN pr.PRODUCT_QUANTITY_AVAIL >= (po.QUANTITY_SOLD * 0.70)
	THEN 'Sufficient inventory'
    END
END INVENTORY_STATUS
FROM PRODUCT pr
INNER JOIN (
			SELECT
			pr.PRODUCT_ID,
			pr.PRODUCT_DESC,
			SUM(COALESCE(oi.PRODUCT_QUANTITY,0)) QUANTITY_SOLD
			FROM PRODUCT pr
			LEFT JOIN ORDER_ITEMS oi
			ON pr.PRODUCT_ID = oi.PRODUCT_ID
			GROUP BY pr.PRODUCT_ID, pr.PRODUCT_DESC) po
ON pr.PRODUCT_ID = po.PRODUCT_ID
INNER JOIN PRODUCT_CLASS pc
ON pr.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE

/*Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in
carton id 10 .
*/

SELECT 
		oi.ORDER_ID,
		MAX(pr.LEN * pr.WIDTH * pr.HEIGHT) VOLUME
		FROM PRODUCT pr
		INNER JOIN ORDER_ITEMS oi
		ON pr.PRODUCT_ID = oi.PRODUCT_ID
        LEFT JOIN CARTON c
        ON pr.LEN <= c.LEN
        AND pr.WIDTH <= c.WIDTH
        AND pr.HEIGHT <= c.HEIGHT
		WHERE c.CARTON_ID = 10
		GROUP BY oi.ORDER_ID
        ORDER BY MAX(pr.LEN * pr.WIDTH * pr.HEIGHT) DESC
        LIMIT 1
        
/*Q8. Write a query to display customer id, customer full name, total quantity and total value
(quantity*price) shipped where mode of payment is Cash and customer last name starts with 'G'*/

SELECT 
oh.CUSTOMER_ID, 
CONCAT(oc.CUSTOMER_FNAME, ' ',oc.CUSTOMER_LNAME) FULL_NAME,
SUM(oi.PRODUCT_QUANTITY) 'TOTAL QUANTITY',
(SUM(oi.PRODUCT_QUANTITY) * pr.PRODUCT_PRICE) 'TOTAL VALUE'
FROM ORDER_HEADER oh
INNER JOIN ORDER_ITEMS oi
ON oh.ORDER_ID = oi.ORDER_ID
INNER JOIN PRODUCT pr
ON oi.PRODUCT_ID = pr.PRODUCT_ID
INNER JOIN ONLINE_CUSTOMER oc
ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
WHERE oh.ORDER_STATUS = 'SHIPPED'
AND oh.PAYMENT_MODE = 'CASH'
AND oc.CUSTOMER_LNAME LIKE 'G%'
GROUP BY oh.CUSTOMER_ID, pr.PRODUCT_PRICE

/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold
together with product id 201 and are not shipped to city Bangalore and New Delhi.*/

SELECT
po.PRODUCT_ID,
pr.PRODUCT_DESC,
po.TOTAL_QUANTITY
FROM(
	SELECT 
	oi.PRODUCT_ID,
	SUM(oi.PRODUCT_QUANTITY) TOTAL_QUANTITY
	FROM ORDER_ITEMS oi
    INNER JOIN ORDER_HEADER oh
    ON oi.ORDER_ID = oh.ORDER_ID
    INNER JOIN ONLINE_CUSTOMER oc
    ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
    INNER JOIN ADDRESS ad
    ON oc.ADDRESS_ID = ad.ADDRESS_ID
    WHERE oi.ORDER_ID IN(SELECT ORDER_ID FROM ORDER_ITEMS WHERE PRODUCT_ID = 201)
    AND ad.CITY NOT IN('BANGALORE', 'NEW DELHI')
	GROUP BY oi.PRODUCT_ID
) po
INNER JOIN PRODUCT  pr
ON po.PRODUCT_ID = pr.PRODUCT_ID
ORDER BY po.TOTAL_QUANTITY DESC

/*Q10. Write a query to display the order_id, customer_id and customer fullname, total quantity of products
shipped for order ids which are even and shipped to address where pincode is not starting with "5"
*/

SELECT 
oca.ORDER_ID,
oc.CUSTOMER_ID, 
CONCAT(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) 'FULL NAME',
oca.TOTAL_QUANTITY
FROM (
		SELECT oh.ORDER_ID,oh.CUSTOMER_ID,
			   SUM(oi.PRODUCT_QUANTITY) TOTAL_QUANTITY
		FROM ORDER_HEADER oh
        INNER JOIN ORDER_ITEMS oi
        ON oh.ORDER_ID = oi.ORDER_ID
        INNER JOIN ONLINE_CUSTOMER oc
        ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
        INNER JOIN ADDRESS ad
        ON oc.ADDRESS_ID = ad.ADDRESS_ID
        WHERE oh.ORDER_STATUS = 'SHIPPED'
        AND  oh.ORDER_ID % 2 = 0
        AND ad.PINCODE LIKE '5%'
        GROUP BY oh.ORDER_ID, oh.CUSTOMER_ID
        ) oca
INNER JOIN ONLINE_CUSTOMER oc
ON oca.CUSTOMER_ID = oc.CUSTOMER_ID
