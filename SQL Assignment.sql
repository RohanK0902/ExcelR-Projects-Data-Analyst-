use classicmodels;
-- Q1.(a) SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)

select * from employees;
select employeenumber,firstname,lastname from employees where jobtitle="Sales Rep" and reportsto="1102";

-- Q1.(b)
select * from products;
select distinct productline from products where productline like '%car%';

-- Q2.(a) CASE STATEMENTS for Segmentation

select * from customers;
select customernumber,customername, case 
when country='USA' or country='Canada' then 'North America'
when country='UK' or country='France' or country='Germany' then 'Europe'
else "Others"
end as "Customer Segment" from customers;

-- Q3.a Group By with Aggregation functions and Having clause, Date and Time functions

select * from orderdetails;
select productcode,sum(quantityOrdered) as top_ordered from orderdetails group by productcode order by top_ordered desc limit 10;

-- b.Company wants to analyse payment frequency by month. Extract the month name from the payment date to count the total number of payments for each month and 
-- include only those months with a payment count exceeding 20.Sort the results by total number of payments in descending order.  (Refer Payments table). 

select * from payments;
select monthname(paymentDate) as payment_month, count(*) num_payments from payments
	group by payment_month having num_payments > 20 order by num_payments desc;

-- Q4.(a) CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
create database Customers_Orders;
use Customers_Orders;
create table customer (customer_id int primary key auto_increment,
		first_name varchar(50) not null,
        last_name varchar(50) not null,
        email varchar(255) unique,
        phone_number varchar(20));
desc customer;

-- b.	Create a table named Orders to store information about customer orders. Include the following columns:

use customers_orders;
create table Orders (order_id int primary key auto_increment,
		customer_id int , foreign key (customer_id) references Customer(customer_id),
       order_date date ,
        total_amount decimal(10,2), check (total_amount>0));
desc orders;

-- Q5. JOINS
-- a. List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)

select * from Customers;
select * from Orders;

select c.country,count(o.ordernumber) as order_count from customers c join orders o on 
c.customernumber=o.customernumber group by c.country order by order_count desc limit 5;


-- Q6. SELF JOIN
-- a. Create a table project with below fields.
 create table project (EmployeeID int primary key auto_increment,
						FullName varchar(50) not null,
                        Gender enum("Male","Female"),
                        MangerID int);
desc project;
insert into project values (1,"Pranaya","Male",3),
							(2,"Priyanka","Female",1),
							(3,"Preety","Female",null),
                            (4,"Anurag","Male",1),
                            (5,"Sambit","Male",1),
                            (6,"Rajesh","Male",3),
                            (7,"Hina","Female",3);

select * from project;
select mgr.FullName as Mgr_name , emp.FullName as Emp_name
from project as emp join project as mgr on emp.MangerID = mgr.EmployeeID order by mgr.FullName;

-- Q7. DDL Commands: Create, Alter, Rename
create table facility (Facility_ID int,
						Name varchar(100),
                        State varchar(100),
                        Country varchar(100));
alter table facility modify column Facility_ID int primary key auto_increment;
alter table facility add column City varchar(100) not null after Name;
desc facility;

-- Q8. Views in SQL

use classicmodels;
select * from products;
select * from productlines;
select * from orders;
select * from orderdetails;

create view product_category_sales as 
select pl.productline as productLine, sum(od.quantityOrdered*od.priceEach) as total_sales ,count(distinct o.ordernumber) as number_of_orders
from products p join productlines pl on p.productline=pl.productline 
join orderdetails od on p.productcode=od.productcode 
join orders o on od.ordernumber=o.ordernumber 
group by pl.productline;

select * from product_category_sales;

-- Q9. Stored Procedures in SQL with parameters

use classicmodels;
select * from Customers;
select * from Payments;

-- CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_country_payments`(in input_year int,in input_country varchar(50))
-- BEGIN
-- select year(p.paymentdate) as Year,c.country as country,
-- concat(format(sum(p.amount)/1000,2),"K") as total_amount
-- from Payments p join customers c on p.customernumber= c.customernumber
-- where year(p.paymentdate)=input_year and c.country= input_country
-- group by Year,country;
-- END

call Get_country_payments(2003,"France");

-- Q10. Window functions - Rank, dense_rank, lead and lag
-- a) Using customers and orders tables, rank the customers based on their order frequency

select * from customers;
select * from orders;
select c.customername,count(o.ordernumber) as Order_count, dense_rank() over (order by count(o.ordernumber) desc) as order_frequency_rnk from customers c
join orders o on c.customernumber=o.customernumber group by c.customername order by order_count desc;

-- b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. 
select * from orders;
select year(orderdate) as Year, monthname(orderdate) as Month,count(ordernumber) as Total_orders,
		concat(round(((count(ordernumber)-lag(count(ordernumber),1)
        over ())/lag(count(ordernumber),1) over ())*100),"%") as "% YoY Change" from orders 
        group by Year,month;

-- Q11.a Subqueries and their applications

use classicmodels;
select * from products;
select productline,count(*) as Total from products where buyprice > (select avg(buyprice) from products) group by productline order by Total desc;

-- Q12. ERROR HANDLING in SQL
use classicmodels;
create table Emp_EH (EmpID int primary key auto_increment,EmpName varchar(30) not null,EmailAddress varchar(30) not null);
desc Emp_EH;
call handler("Jaypal","chauhanjaypalji2002@gmail.com");
call handler(null,null);
select * from emp_eh;

-- Procedure code
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `handler`(in p_EmpName varchar(50),in p_EmailAddress varchar(100))
-- BEGIN
-- declare exit handler for sqlexception
-- begin
-- rollback;
-- select "Error occurred" as ErrorMessage;
-- end;
-- start transaction;
--	insert into Emp_EH (EmpName,EmailAddress) values(p_EmpName,p_EmailAddress);
-- commit;
-- END



-- Q13. TRIGGERS
create table Emp_BIT(Name varchar(30),Occupation varchar(30),Working_date date,Working_hours int);
desc Emp_BIT;
insert into Emp_BIT values ('Robin', 'Scientist', '2020-10-04', 12),
							('Warner', 'Engineer', '2020-10-04', 10),
                            ('Peter', 'Actor', '2020-10-04', 13),
                            ('Marco', 'Doctor', '2020-10-04', 14),
                            ('Brayden', 'Teacher', '2020-10-04', 12),
                            ('Antonio', 'Business', '2020-10-04', 11);
insert into Emp_BIT values ('Jaypal','Engineer','2024-09-10',-10);
select * from Emp_BIT;

-- Triggers
-- CREATE DEFINER=`root`@`localhost` TRIGGER `emp_bit_BEFORE_INSERT` BEFORE INSERT ON `emp_bit` FOR EACH ROW BEGIN
-- if new.working_hours <0 then set new.working_hours = -new.working_hours;
-- end if;
-- END







