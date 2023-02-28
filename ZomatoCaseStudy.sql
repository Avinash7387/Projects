--create database Zomato;
--use zomato;


--checking wether table already exist in database & creating table
--drop table if exists goldusers_signup;
--CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 


--Inserting data into the table name goldusers_signup
--INSERT INTO goldusers_signup(userid,gold_signup_date) 
--values (1,'09-22-2017'),
--(3,'04-21-2017');


--drop table if exists users;
--CREATE TABLE users(userid integer,signup_date date); 

--INSERT INTO users(userid,signup_date) 
-- VALUES (1,'09-02-2014'),
--(2,'01-15-2015'),
--(3,'04-11-2014');

--drop table if exists sales;
--CREATE TABLE sales(userid integer,created_date date,product_id integer); 

--INSERT INTO sales(userid,created_date,product_id) 
 --VALUES (1,'04-19-2017',2),
--(3,'12-18-2019',1),
--(2,'07-20-2020',3),
--(1,'10-23-2019',2),
--(1,'03-19-2018',3),
--(3,'12-20-2016',2),
--(1,'11-09-2016',1),
--(1,'05-20-2016',3),
--(2,'09-24-2017',1),
--(1,'03-11-2017',2),
--(1,'03-11-2016',1),
--(3,'11-10-2016',1),
--(3,'12-07-2017',2),
--(3,'12-15-2016',2),
--(2,'11-08-2017',2),
--(2,'09-10-2018',3);


--drop table if exists product;
--CREATE TABLE product(product_id integer,product_name text,price integer); 

--INSERT INTO product(product_id,product_name,price) 
 --VALUES
--(1,'p1',980),
--(2,'p2',870),
--(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;


1.How much amount is each customer spends on zomato? 
select 
  s.userid, 
  sum(price) AmtSpendPerCust 
from 
  sales s 
  inner join product p on s.product_id = p.product_id 
group by 
  s.userid





2.How many days each customer visited zomato? 
select 
  userid, 
  count(distinct created_date) NoTimesVisited 
from 
  sales 
group by 
  userid




3.What was first product purchased by each customer? 

with cte as 
(
select * dense_rank() over ( partition by userid order by created_date ) ranks 
from sales
 ) 
select * from cte 
where 
  ranks = 1



4.What is most purchased item 
and how many times it was purchased by each customer? 
select 
  userid, 
  count(*) CntMostOrderedProd 
from 
  sales 
where 
  product_id =(
    select 
      top 1 product_id 
    from 
      sales 
    group by 
      product_id 
    order by 
      count(*) desc
  ) 
group by 
  userid



5.Which item was most popular for each customer? 

with cte as
(
  select 
    userid, 
    product_id, 
    count(*) TotalOrder, 
    dense_rank() over(
      partition by userid 
      order by 
        count(*) desc
    ) ranks 
  from 
    sales 
  group by 
    userid, 
    product_id
) 
select 
  * 
from 
  cte 
where 
  ranks = 1






6.Which item was first ordered by customer when they become a member? 

with cte as 
(
  select 
    s.userid, 
    created_date, 
    gold_signup_date, 
    s.product_id, 
    dense_rank() over(
      partition by s.userid 
      order by 
        created_date
    ) ranks 
  from 
    sales s 
    inner join goldusers_signup g on s.userid = g.userid 
  where 
    created_date >= gold_signup_date
) 
select 
  userid, 
  created_date, 
  product_id, 
  gold_signup_date, 
  ranks 
from 
  cte 
where 
  ranks = 1




7.What is total orders 
and amount spent for each member before they become a member? 

select 
  s.userid, 
  sum(price) AmtSpent 
from 
  sales s 
  inner join product p on p.product_id = s.product_id 
  inner join goldusers_signup g on s.userid = g.userid 
where 
  created_date <= gold_signup_date 
group by 
  s.userid



8.If buying each product generates points for e.g.5rs - 2 zomato pts 
and each product has different purchasing points for e.g.for p1 5rs = 1 zomato pt, 
for p2 10rs = 1 zomato pt, 
for p3 5rs = 1 zomato pt, 
calculate pts collected by each customers 
and for which product most pts have been given till now.


select 
  *, 
  dense_rank() over(
    partition by userid 
    order by 
      pts_earned desc
  ) ranks 
from 
  (
    select 
      userid, 
      product_id, 
      price, 
      (price / pts) pts_earned 
    from 
      (
        select 
          userid, 
          product_id, 
          price, 
          (
            case when product_id = 1 then 5 when product_id = 2 then 10 when product_id = 3 then 5 end
          ) pts 
        from 
          (
            select 
              a.userid, 
              a.product_id, 
              sum(price) price 
            from 
              sales a 
              inner join product b on a.product_id = b.product_id 
            group by 
              a.userid, 
              a.product_id
          ) c
      ) d
  ) e 
group by 
  product_id




9.If buying each product generates points for eg 5yrs = 2 zomato point 
and each product has different purchasing points for eg for p1 5rs = 1 zomato point, 
p2 10rs = 5 zomato point 
and p3 5rs = 1 zomato point, 
calculate points collected by each customers 
and for which product most points have been given till now.


select 
  userid, 
  sum(total_points)* 2.5_total_money_earned 
from 
  (
    select 
      e.*, 
      amt / points total_points 
    from 
      (
        select 
          d.*, 
          case when product_id = 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points 
        from 
          (
            select 
              c.userid, 
              c.product_id, 
              sum(price) amt 
            from 
              (
                select 
                  a.*, 
                  b.price 
                from 
                  sales a 
                  inner join product b on a.product_id = b.product_id
              ) c 
            group by 
              userid, 
              product_id
          ) d
      ) e
  ) f 
group by 
  userid;






10.In the first one year after a customer joins the gold program (including thier join date) irrespective of what the customer has purchased the;
y earn 5 zomato points for every 10 rs spent who earned more 1 
or 3 and what was their points earning s in their first yr ? 

select 
  c.*, 
  d.price * 0.5 total_points_earned 
from 
  (
    select 
      a.userid, 
      a.created_date, 
      a.product_id, 
      b.gold_signup_date 
    from 
      sales a 
      inner join goldusers_signup b on a.userid = b.userid 
      and created_date >= gold_signup_date 
      and created_date <= Dateadd(year, 1, gold_signup_date)
  ) c 
  inner join product d on c.product_id = d.product_id;





11.Rank all the transaction of the customers 

select 
  *, 
  dense_rank() over(
    partition by userid 
    order by 
      created_date
  ) as rank_ 
from 
  sales




12.Rank all the transaction for each member whenever they are a zomato gold member for every non gold memeber transaction mark as na.

select 
( s.userid, 
  created_date, 
  product_id, 
  gold_signup_date, 
  case when gold_signup_date is null then 0 else rank() over(
    partition by s.userid 
    order by 
      created_date desc
  ) end as rank_ 
from 
  sales s 
  left join goldusers_signup g on s.userid = g.userid 
  and s.created_date >= g.gold_signup_date



*********************END*********************************

