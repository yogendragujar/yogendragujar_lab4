use `order-directory`;
#show tables;

#3)	Display the total number of customers based on gender who have placed orders of worth at least Rs.3000.
select count(t2.cus_gender) as NumOfCustomers, t2.cus_gender from
(select t1.cus_id, t1.cus_gender, t1.ord_amount, t1.cus_name from 
(select `order`.*, customer.cus_gender, customer.cus_name from `order` inner join customer where `order`.cus_id=customer.cus_id having `order`.ord_amount >= 3000)
as t1 group by t1.cus_id) as t2 group by t2.cus_gender;

#4)	Display all the orders along with product name ordered by a customer having Customer_Id=2
select `order`.ORD_DATE,`order`.ORD_AMOUNT, product.PRO_NAME, product.PRO_DESC from `order`
left join supplier_pricing on supplier_pricing.PRICING_ID = `order`.PRICING_ID
left join product on product.PRO_ID = supplier_pricing.PRO_ID
where `order`.CUS_ID=2;


#5)	Display the Supplier details who can supply more than one product.
select supplier.SUPP_ID, supplier.SUPP_NAME, supplier.SUPP_PHONE, supplier.SUPP_CITY, count(supplier_pricing.PRO_ID) as Count from supplier
left join supplier_pricing on supplier_pricing.SUPP_ID = supplier.SUPP_ID group by supplier_pricing.SUPP_ID
having count(supplier_pricing.PRO_ID) > 1;

#6)	Find the least expensive product from each category and print the table with category id, name, product name and price of the product
select category.CAT_ID, category.CAT_NAME, product.PRO_NAME, supplier_pricing.SUPP_PRICE from category
left join product on product.CAT_ID = category.CAT_ID 
left join supplier_pricing on supplier_pricing.PRO_ID = product.PRO_ID where supplier_pricing.SUPP_PRICE = all(select min(supplier_pricing.SUPP_PRICE) from supplier_pricing);

#7)	Display the Id and Name of the Product ordered after “2021-10-05”.
select product.PRO_ID as Product_Id, product.PRO_NAME as Product_Name from product
left join supplier_pricing on supplier_pricing.PRO_ID = product.PRO_ID
left join `order` on `order`.PRICING_ID = supplier_pricing.PRICING_ID 
where `order`.ORD_DATE >= '2021-10-05'
group by product.PRO_ID;

#8)	Display customer name and gender whose names start or end with character 'A'.
select customer.CUS_NAME, customer.CUS_GENDER from customer
where customer.CUS_NAME like 'A%' or customer.CUS_NAME like '%A';

#9)	Create a stored procedure to display supplier id, name, rating and Type_of_Service. For Type_of_Service, If rating =5, print “Excellent Service”,If rating >4 print “Good Service”, If rating >2 print “Average Service” else print “Poor Service”.
drop procedure if exists rating_svc;
DELIMITER //
create procedure rating_svc() 
BEGIN
	select supplier.SUPP_ID as Supplier_Id, supplier.SUPP_NAME as Supplier_Name, rating.RAT_RATSTARS as Ratings,
    CASE 
     WHEN rating.RAT_RATSTARS = 5 then 'Excellent Service'
     WHEN rating.RAT_RATSTARS >= 4 then 'Good Service'
     WHEN rating.RAT_RATSTARS > 2 then 'Average Service'
     ELSE 'Poor Service'
	END as Type_Of_Service
     from rating
     left join `order` on `order`.ORD_ID = rating.ORD_ID
     left join supplier_pricing on supplier_pricing.PRICING_ID=`order`.PRICING_ID
     left join supplier on supplier.SUPP_ID = supplier_pricing.SUPP_ID 
     group by supplier_pricing.SUPP_ID 
     order by rating.RAT_RATSTARS DESC;
END //
DELIMITER ;

call rating_svc();