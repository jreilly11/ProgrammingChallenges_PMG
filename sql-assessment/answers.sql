/* ############################### NOTES ###############################
1. I completed this assignment in MySQL, as I only currently have access to MySQL Workbench on my school laptop.
2. To create the DB schema, I did not write code, but instead did so by right-clicking in the schema menu and selecting
   "create schema"
3. I imported the csv data to populate the shell tables through the Table Data Import Wizard
*/
-- ############################### DATABASE SETUP ###############################

-- Code to create shell table for campaign_info (copied from assignment)
create table campaign_info (
 id int not null primary key auto_increment,
 name varchar(50),
 status varchar(50),
 last_updated_date datetime
);

-- Testing that data was properly imported
select * from campaign_info;

-- Code to create shell table for website_revenue (copied from assignment)
create table website_revenue (
 date datetime,
 campaign_id varchar(50),
 state varchar(2),
 revenue float
);

-- Testing that data was properly imported
select * from website_revenue;

-- Code ran to create shell table for marketing_performance (copied from assignment)
create table marketing_performance (
 date datetime,
 campaign_id varchar(50),
 geo varchar(50),
 cost float,
 impressions float,
 clicks float,
 conversions float
);

-- Testing that data was properly imported
select * from marketing_performance;

-- ############################### SQL CHALLENGE QUERIES ###############################

-- #1: Sum of impressions by day (ordered to have most recent dates at top of table)
SELECT date as 'Day', sum(impressions) as Total_Impressions
FROM marketing_performance
GROUP BY date
ORDER BY date DESC;

-- #2: Top 3 revenue-generating states ordered from best to worst
SELECT state, sum(revenue) as Revenue_Generated
FROM website_revenue
GROUP BY state
ORDER BY Revenue_Generated DESC
LIMIT 3;
/*
 Answer: The third best revenue-generating state, Ohio, generated $37,577 in revenue
 */
 
-- #3: Name, total cost, impressions, clicks, and revenue of each campaign 
SELECT c.name as Campaign, sum(m.cost) as Total_Cost, sum(m.impressions) as Total_Impressions, 
sum(m.clicks) as Total_Clicks, sum(w.revenue) as Total_Revenue 
FROM campaign_info c JOIN marketing_performance m ON c.id = m.campaign_id
JOIN website_revenue w ON c.id=w.campaign_id
GROUP BY Campaign
ORDER BY Campaign;

-- #4: Campaign5 conversions by state
SELECT c.name, m.geo, sum(m.conversions) as Total_Conversions
FROM campaign_info c JOIN marketing_performance m ON c.id = m.campaign_id
GROUP BY c.name, m.geo
HAVING c.name = 'Campaign5';
/*
Answer: Georgia was the state that generated the most conversions for Campaign5
*/

-- #5: The most efficient campaign
/*
To measure the efficiency of the campaigns, I will look at:
 - CTR (Click-through rate)
 - Impression to conversion rate
 */
SELECT c.name as Campaign, avg(m.clicks/m.impressions) as CTR,
avg(m.conversions/m.impressions) as Impression_to_Conversion_Rate
FROM campaign_info c JOIN marketing_performance m ON c.id = m.campaign_id
GROUP BY c.name
ORDER BY CTR DESC, Impression_to_Conversion_Rate DESC;
 /*
Given that Campaign5 has the highest CTR and Impression_to_Conversion Rate,
I would argue that it is the most efficient campaign. 

However, in addition to evaluating conversion funnel metrics, it is also important
to consider the cost efficiency of each campaign.
 */
 
SELECT c.name as Campaign, (avg(w.revenue)/avg(m.cost)) as Cost_Efficiency
FROM campaign_info c JOIN marketing_performance m ON c.id = m.campaign_id
JOIN website_revenue w on c.id = w.campaign_id
GROUP BY Campaign
ORDER BY Cost_Efficiency DESC;
 /*
Although it is the most efficient with regards to the conversion funnel metrics,
Campaign5 is actually the least cost efficient campaign when looking at the respective
Revenue to Cost ratios of the campaigns. 

In light of this, I will still say that Campaign5 is the most efficient as I am assuming that the question
is getting at conversion funnel metrics, however it is just as important to consider other forms of efficiency (as
this then gives insight on potential areas of improvement)
 
-- #6 (Bonus): Best day of the week to run ads 
To evaluate the best day of the week to run ads, I will once again look at the CTR and impression_to_conversion
ratio for each day of the week
*/
-- Adding a shell day_of_week column to label each observation with its respective day of the week
ALTER TABLE marketing_performance
ADD COLUMN day_of_week char(10);

-- Populating the day_of_week column with the respective weekday name for each observation
UPDATE marketing_performance
SET day_of_week = dayname(date)
WHERE date is NOT NULL;

-- Creating query to evaluate CTR and impression_to_conversion ratio and grouping it by day of the week
SELECT m.day_of_week, avg(m.clicks/m.impressions) as CTR,
avg(m.conversions/m.impressions) as Impression_to_Conversion_Rate
FROM marketing_performance m
GROUP BY m.day_of_week
ORDER BY CTR DESC, Impression_to_Conversion_Rate DESC;

/*
Given the results of the above query, it is clear that Wednesday is the best day of the week to run ads
as the CTR and Impression_to_Conversion_Rate is highest on Wednesday
*/