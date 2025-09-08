SELECT * FROM task.retail_with_categories;

#for handle and clean all null transitation id's
SELECT 
    COUNT(*) - COUNT(Transaction_ID) AS Null_Count
FROM
    task.retail_with_categories;

#dectect and handle numerical null or invalid value
create view retail_category as
 SELECT 
    SUM(CASE
        WHEN Total_Items IS NULL OR Total_Items <= 0 THEN 1
        ELSE 0
    END) AS invalid_item,
    SUM(CASE
        WHEN Total_Items IS NULL OR Total_Items <= 0 THEN 1
        ELSE 0
    END) AS Invalid_total_Cost,
    SUM(CASE
        WHEN Unit_Price IS NULL OR Unit_Price <= 0 THEN 1
        ELSE 0
    END) AS invalid_Unit_Price,
    SUM(CASE
        WHEN
            Cost_Per_Item IS NULL
                OR Cost_Per_Item <= 0
        THEN
            1
        ELSE 0
    END) AS invalid_Cost_Per_Item,
    SUM(CASE
        WHEN Profit IS NULL OR Profit <= 0 THEN 1
        ELSE 0
    END) AS Invalid_Profit,
    SUM(CASE
        WHEN Customer_ID IS NULL OR Customer_ID <= 0 THEN 1
        ELSE 0
    END) AS Invalid_Customer_ID,
    SUM(CASE
        WHEN Basket_Size IS NULL OR Basket_Size <= 0 THEN 1
        ELSE 0
    END) AS Invalid_Basket_Size
FROM
    task.retail_with_categories;
 
#Fixing Case Sensative 
UPDATE retail_with_categories 
SET 
    Category = LOWER(Category);

#Fixing Startegies for Numerical Columns of 
# 1.Total_Cost
UPDATE retail_with_categories 
SET 
    Total_Cost = Total_Items * Unit_Price
WHERE
    Total_Cost IS NULL OR Total_Cost <= 0;

# 2.Profit
UPDATE retail_with_categories 
SET 
    Profit = (Unit_Price - Cost_Per_Item) * Total_Items
WHERE
    profit IS NULL OR profit <= 0;

#3.Basket_Size
UPDATE retail_with_categories 
SET 
    Basket_Size = (SELECT ROUND(AVG(Basket_Size), 0))
WHERE
    Basket_Size IS NULL OR Basket_Size <= 0;

#4.Total_Items
UPDATE retail_with_categories 
SET 
    Total_Items = (SELECT ROUND(AVG(Total_Items), 0))
WHERE
    Total_Items IS NULL OR Total_Items <= 0;

#5.Unit_price
UPDATE retail_with_categories 
SET 
    Unit_Price = (SELECT ROUND(AVG(Unit_Price), 0))
WHERE
    Unit_Price IS NULL OR Unit_Price <= 0;

# Converting Uppercase in to lower case 
#1.Customer_Name
UPDATE retail_with_categories 
SET 
    Customer_Name = LOWER(Customer_Name);

#2.City
UPDATE retail_with_categories 
SET 
    City = LOWER(City);

#3.Season
UPDATE retail_with_categories 
SET 
    Season = LOWER(Season);

#4.Store_Type
UPDATE retail_with_categories 
SET 
    Store_Type = LOWER(Store_Type);

#5.Payment_Method
UPDATE retail_with_categories 
SET 
    Payment_Method = LOWER(Payment_Method);

#6.Customer_Category
update retail_with_categories set Customer_Category=lower(Customer_Category);

#7.Discount_Applied
update retail_with_categories set Discount_Applied=lower(Discount_Applied);

#8.Product_Category
update retail_with_categories set Product_Category=lower(Product_Category);

#9.Sub_Category
update retail_with_categories set Sub_Category=lower(Sub_Category);

#10.Promotion
update retail_with_categories set Promotion=lower(Promotion);

#11.Product
update retail_with_categories set Product=lower(Product);

#check duplicates transaction
SELECT 
    Transaction_ID, COUNT(*)
FROM
    task.retail_with_categories
GROUP BY Transaction_ID
HAVING COUNT(*) > 1;

# remove extra speaces inconsistent casing
UPDATE task.retail_with_categories 
SET 
    City = TRIM(LOWER(city)),
    Category=TRIM(LOWER(Category));

#remove mrs.,mr like this words from name using trim()
update task.retail_with_categories
set Customer_Name = TRIM(
    replace(
        replace(
            replace(
                replace(Customer_Name, 'mrs. ', ''),
            'mr. ', ''),
        'ms. ', ''),
    'dr. ', '')
);

#also remove ' from product
UPDATE task.retail_with_categories 
SET 
    Product = TRIM(REPLACE(REPLACE(REPLACE(Product, '[', ''),
                '\'',''),
            ']','')
            );

select * from task.retail_with_categories;

#create views 
create view year as
select year(Date) as year from task.retail_with_categories;

create view revenue as
select sum(Total_Cost) as revenue from task.retail_with_categories;

#revenue and profit season wise 
SELECT 
    SUM(total_cost) AS total_revenue,
    SUM(Profit) AS total_profit,
    season
FROM
    task.retail_with_categories
GROUP BY season;

#revenue by product category wise
SELECT 
    SUM(Total_Cost) AS cost,
    SUM(profit) AS total_profit,
    Product,season
FROM
    task.retail_with_categories
GROUP BY product_category , Product,season
ORDER BY cost DESC;

#most selling and profitable product in winter season
SELECT DISTINCT
    (Category), Date, SUM(Total_Items), SUM(profit), season
FROM
    task.retail_with_categories
WHERE
    season = 'winter'
GROUP BY season , Category , profit , date;

#best selling product in 2020 in all season
  SELECT 
    SUM(Total_Items) AS total_item,
    SUM(profit) AS total_profit,
    Product_Category,
    city,
    season
FROM
    task.retail_with_categories
WHERE
    season = 'winter' OR YEAR(date) = '2020'
GROUP BY Product_Category , city , season;
  
# best selling product in 2020 
SELECT 
    Season, Sub_Category, Total_Items
FROM
    task.retail_with_categories
WHERE
    YEAR(Date) = '2020'
        OR (SELECT 
            SUM(Total_Items) AS tot_item
        FROM
            task.retail_with_categories)
GROUP BY Sub_Category , Total_Items , Season
ORDER BY Total_Items DESC
LIMIT 10;
  
# products more orderd than avg of total_items in 2020 and 2021 
SELECT DISTINCT
    Date,Category, Total_Items AS avg_of_item
FROM
    task.retail_with_categories
WHERE
    Total_Items > (SELECT 
            AVG(Total_Items) AS avg_item
        FROM
            task.retail_with_categories)
        OR Date = (SELECT 
            YEAR(Date)
        FROM
            task.retail_with_categories
        HAVING YEAR(Date) IN ('2020' , '2021'))
        ORDER BY Total_Items DESC;
        
#which product catageory genrate most revenue    
	SELECT 
    Product_Category,
    SUM(Total_Items) AS Total_Item,
    SUM(Profit) AS Total_profit
FROM
    task.retail_with_categories 
GROUP BY Product_Category
ORDER BY Total_profit DESC;

#Top 10 product by sales
SELECT 
    SUM(Total_Items) AS total_item,Product
FROM
    task.retail_with_categories  
GROUP BY product
ORDER BY total_item DESC
LIMIT 10;

# sales by season
select season,sum(Total_cost) as Revenue,sum(Profit) as Profit from task.retail_with_categories group by season order by revenue desc;

#Payment method Analysis
select Payment_method,count(*) as Transaction_count,sum(Total_Cost) as revenue from task.retail_with_categories group by Payment_method order by Revenue desc;

#Store performance
select store_type, sum(Total_cost) as revenue,sum(Profit) as Profit from task.retail_with_categories group by Store_type order by revenue desc;
  
  #avavrage basket size and value
  select avg(basket_size) as Avg_basket_si,avg(TOtal_cost) as Avg_Tot_Cost from task.retail_with_categories;
  
#discount impact on sale
select discount_Applied,count(*) as orders,sum(Total_cost) as revenue,avg(Total_cost) as Avg_tot_cost from task.retail_with_categories group by Discount_Applied;

#avg profit margin by cataegeory
select Product_category,round(avg(profit/total_cost) * 100) as Avg_profit_margin from task.retail_with_categories group by 
Product_Category order by Avg_profit_margin desc;

##revenue contribution by customer category
select customer_category,sum(total_cost) as revenue,round(sum(total_cost)*100/(select sum(total_cost) from task.retail_with_categories),2) as Contribution_percent 
from task.retail_with_categories group by Customer_category order by revenue desc;

#most profitable subcategory
select sub_category,sum(profit) as revenue from task.retail_with_categories group by Sub_category order by revenue desc limit 15;

#Avg_basket_size by store type
select store_type,avg(Basket_size) as Avg_Basket_Size from task.retail_with_categories group by Store_Type order by Avg_Basket_Size desc;

#customer with higest baskeet size
select customer_name, max(Basket_size) as max_bas_size from task.retail_with_categories group by Customer_Name order by max_bas_size desc limit 5;

#revenue by promotion type
select promotion,sum(Total_Cost) as revenue,count(*) as orders from task.retail_with_categories group by Promotion order by revenue desc;

# dectet Anomalies :- ubusally high sales
select * from task.retail_with_categories where Total_Cost > (select avg(Total_cost)+3*stddev(total_cost) from task.retail_with_categories);

#yearly growth analysis
select year(str_to_date(Date,'%Y-%m-%d')) as year,sum(Total_cost) as revenue from task.retail_with_categories group by year order by year asc;

#here i use windows function fro profitable product oer season wise
select season,sub_category,profit from (select season,sub_category,sum(profit) as profit,rank() over (partition by season order by sum(profit) desc) as rnk from
task.retail_with_categories group by Season,Sub_Category) a where rnk<=5;

#seasonl trend analysis for year to year growth(YoY) using windows function
select season,year(Date) as Year,sum(total_cost) as revenue, lag(sum(total_cost),1)over(partition by season order by year(date)) as prev_year_revenue,round(((sum(total_cost)-lag(sum(total_cost)
,1)over (partition by season order by year(date))) / lag(sum(total_cost),1)over (partition by season order by year(date))) * 100 ,2) as YoY_growth from task.retail_with_categories
group by season,year order by season,year;

# Seasonal best sealler using stored procedure
Delimiter 
create procedure BestSel(in season_name char(20)) begin
select sub_category,sum(total_items) as Total_Sold from task.retail_with_categories where season=season_name group by sub_category order by Total_sold desc limit 1;
end; 

# calculate profit margin using function
Delimiter 
create function Cal_margin(unit_price Decimal(10,2),cost decimal(10,2)) returns decimal(5,2) deterministic begin 
return round(((unit_price- cost) / unit_price)* 100,2);
end ;

