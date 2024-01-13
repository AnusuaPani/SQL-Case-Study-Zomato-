
create database zomato;
use zomato;
create table users(
user_id int not null primary key,
u_name varchar(20),
email varchar(30),
u_pass varchar(20));
select * from orders;
create table restaurants(
r_id int not null primary key,
r_name varchar(20),
cuisine varchar(20));
create table food(
f_id int not null primary key,
f_name varchar(20),
f_type varchar(10));
create table menu(
menu_id int not null primary key,
f_id int not null,
r_id int not null,
foreign key(f_id) references food(f_id),
foreign key(r_id) references restaurants(r_id),
price int);
create table orders(
o_id int not null primary key,
user_id int,
r_id int,
amount int,
o_date date,
partner_id int,
deliverytime int,
delivery_training int,
restarant_training int,
foreign key (user_id) references users(user_id),
foreign key(r_id) references restaurants(r_id));
create table order_details(
id int not null primary key,
o_id int,
f_id int,
foreign key(o_id) references orders(o_id),
foreign key(f_id) references food(f_id));
/*users who ordered nothing ever*/
select u_name from users where user_id not in(select user_id from orders);
/*Average price per food item*/
select f.f_name,avg(price) as avgprice_dish from menu m join food f on f.f_id=m.f_id group by(m.f_id) order by avgprice_dish desc;
/*top restaurant in terms of orders for a given month*/
 select r.r_name,monthname(o_date) as 'month', count(o_id) over(partition by o.r_id) as totalorders from orders o join restaurants r on r.r_id=o.r_id where monthname(o_date)='May' order by totalorders desc limit 1;
/*restaurants having monthly sales >500 in a given month*/
select r.r_name,sum(amount) from orders o join restaurants r on r.r_id=o.r_id where monthname(o_date)='July' group by(o.r_id) having sum(amount)>700;
/*order details of a given user for a given time interval*/
select f.f_name,o.o_date,r.r_name from orders o join restaurants r on r.r_id=o.r_id join order_details od on od.o_id=o.o_id join food f on f.f_id=od.f_id where user_id =(select user_id from users where u_name='Khushboo') and (o_date>'2022-06-10'and o_date<'2022-07-10');
/*Find restaurants with maximum repeated customers*/
/*FIRST ADD A NEW COLUMN NAMED 'Visits' then using it find out loyal customers*/
select r.r_name,u.u_name as 'loyal customers' from (select r_id ,user_id,count(o_id) as 'Visits' from orders o group by r_id,user_id having Visits>1) t join restaurants r on r.r_id=t.r_id join users u on t.user_id=u.user_id;
/*month over month revenue growth of zomato*/
select Months ,((Revenue-previous)/previous)*100 from(
With Sales as(
select sum(amount) as Revenue,monthname(o_date) as Months from orders group by(Months))
select Revenue,Months,lag(Revenue,1) over() as previous from Sales) t;
/*Month over month revenue growth of a given restaurant*/
select Months, ((revenue-previous)/previous)*100 as growth from(
with sales as
(select monthname(o_date) as Months,sum(amount) as revenue from orders where r_id=3 group by(Months))
select Months,revenue, lag(revenue,1) over() as previous from sales) t;


