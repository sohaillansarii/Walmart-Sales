select * from walmart;


--BUSINESS PROBLEMS--
--Q.1 Find different payment method and number of transactions, number of qty sold
select 
 payment_method,
 count(*) as transactions,
 sum(quantity) as quantity_sold
from walmart
group by 1;

--Q2 Identify the highest-rated category in each branch, displaying the branch, category,avg rating
select * 
from
(
   select 
        branch,
        category,
	    avg(rating) as avg_rating,
	    rank() over (partition by branch order by avg(rating) desc) as rank
   from walmart 
   group by 1,2
)
where rank =1;

-- Q.3 Identify the busiest day for each branch based on the number of transactions
select *
from
(
   select 
       branch,
       to_char(to_date(date, 'DD/MM/YY'), 'Day') as day_name,
       count(*) as transactions,
	   rank() over(partition by branch order by count(*) desc) as rank
  from walmart
  group by 1,2
)
where rank = 1;

-- Q. 4  Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
select 
	payment_method,
	count(*),
	sum(quantity) as total_quantity
from walmart
group by 1;

--
-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.
select
      city,
	  category,
	  avg(rating) as avg_rating,
	  max(rating) as max_rating,
	  min(rating) as min_rating
from walmart
group by 1,2;

-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.
select
       category,
	   sum(total) as total_revenue,
	   sum(total * profit_margin) as total_profit
from walmart
group by 1

-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
With ranked_payment_method
as
(
select 
          branch,
	      payment_method,
	      count(*),
	      rank() over(partition by branch order by count(*)) as rank
  from walmart
  group by 1,2
)
select *
from ranked_payment_method
where rank = 1;

-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices
select
     branch,
case
	      when extract (hour from(time::time))  < 12 then 'Morning'
		  when extract (hour from(time::time) ) between 12 and  17 then 'Afternoon'
		  else 'Evening'
      end day_time,
	  count(*)
from walmart
group by 1,2
order by 1,3 desc

-- #Q9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

with revenue_2022
as
(
select 
      branch,
	  sum(total) as revenue
from walmart
where extract(year from to_date(date, 'DD-MM-YY')) = 2022
group by 1
),

revenue_2023
as
(
select 
      branch,
	  sum(total) as revenue
from walmart
where extract(year from to_date(date, 'DD-MM-YY')) = 2023
group by 1
)
select 
     ls.branch,
	 ls.revenue as last_year_revenue,
	 cs.revenue as current_year_revenue,
	 round((ls.revenue - cs.revenue)::numeric/
	 ls.revenue::numeric * 100,2) 
	 as ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on cs.branch = ls.branch
where 
     ls.revenue > cs.revenue 
order by  4 desc

limit 5;

--Q10Find the total sales, total quantity sold, and average rating for each category in each city.
-- Only include categories where total sales exceed 10,000.

select 
       city,
	   category,
       sum(total) as total_sales,
	   sum(quantity) as quantity_sold,
	   avg(rating) as avg_rating
from  walmart
group by 1,2
having sum(total) > 10000
order by 1,2;




CREATE OR REPLACE FUNCTION github_pgsql_check()
RETURNS void AS $$
BEGIN
  RAISE NOTICE 'PLpgSQL detected';
END;
$$ LANGUAGE plpgsql;


