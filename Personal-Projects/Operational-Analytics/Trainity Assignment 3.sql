## Trainity Assignment 3: Operational Analytics and Investigating Metric Spikes

USE restaurant_db;

##Case Study 1: Job Data Analysis

## Task A: Jobs Reviewed Over Time 

SELECT 
    EXTRACT(DAY FROM STR_TO_DATE(ds, '%m/%d/%Y')) AS date_day,
    (COUNT(job_id) / 24) AS no_of_jobs_reviewed_per_hour
FROM
    job_data
GROUP BY date_day;

## Task B: Throughput Analysis

SELECT 
    event_date,
    throughput_per_day,
    AVG(throughput_per_day) OVER (
        ORDER BY event_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_avg_throughput
FROM (
    SELECT
        DATE(STR_TO_DATE(ds, '%m/%d/%Y')) AS event_date,
        COUNT(*) AS events_per_day,
        SUM(time_spent) AS total_time_spent,
        COUNT(*) / NULLIF(SUM(time_spent), 0) AS throughput_per_day
    FROM 
        job_data
    GROUP BY 
        event_date
) AS daily_throughput
ORDER BY 
    event_date;
    
## Task C: Language Share Analysis

SELECT
    language,
    COUNT(*) AS event_count,
    (COUNT(*) / (SELECT COUNT(*) FROM job_data)) * 100 AS percentage_share
FROM
    job_data
GROUP BY
    language
ORDER BY
    percentage_share DESC;
    
## Task D: Duplicate Count

SELECT
    job_id, actor_id, event, language, time_spent, org, ds,
    COUNT(*) AS duplicate_count
FROM
    job_data
GROUP BY
    job_id, actor_id, event, language, time_spent, org, ds
HAVING
    COUNT(*) > 1
ORDER BY
    duplicate_count DESC;    

## Case Study 2: Investigating Metric Spike

## Task A: Weekly User Engagement
    
SELECT
    YEAR(STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i')) AS year,
    WEEK(STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i')) AS week,
    COUNT(event_type) AS user_engagement
FROM
    events
WHERE
    event_type = 'engagement'
GROUP BY
    YEAR(STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i')),
    WEEK(STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i'))
ORDER BY
    year,
    week;
    
## Task B: User Growth Rate
        
    
SELECT year, month, new_active_user,
       SUM(new_active_user) OVER (ORDER BY year, month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
       AS cumulative_active_users
FROM 
( 
SELECT 
		YEAR(STR_TO_DATE(activated_at, '%d-%m-%Y %H:%i')) AS year,
        MONTH(STR_TO_DATE(activated_at, '%d-%m-%Y %H:%i')) AS month,
        COUNT(DISTINCT user_id) AS new_active_user
FROM users WHERE state = "active"
GROUP BY year, month) a;

    
## Task C: Weekly Retention Rate

SELECT WEEK(STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i')) AS weeks, 
COUNT(DISTINCT user_id) as no_of_users FROM events
WHERE event_type="signup_flow" AND event_name="complete_signup" 
GROUP BY weeks 
ORDER BY weeks;

## Task D: Weekly Engagement Per Device

SELECT 
		YEAR(STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i')) AS year,
        WEEK(STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i')) AS week,
        device, COUNT(DISTINCT user_id) AS user_count
FROM events WHERE event_type = "engagement"
GROUP BY year, week, device
ORDER BY year, week, device;

## Task E: Email Engagement Analytics

SELECT user_id, emails_sent, emails_opened, emails_clicked,
        ROUND(SUM(emails_opened)/SUM(emails_sent),2)*100 AS open_rate,
        ROUND(SUM(emails_clicked)/SUM(emails_opened),2)*100 AS click_through_rate
        FROM (
	SELECT user_id,
		SUM(CASE WHEN `action` = "sent_weekly_digest" THEN 1 ELSE 0 END) AS emails_sent,
		SUM(CASE WHEN `action` = "email_open" THEN 1 ELSE 0 END) AS emails_opened,
		SUM(CASE WHEN `action` = "email_clickthrough" THEN 1 ELSE 0 END ) AS emails_clicked
	FROM email_events
	GROUP BY user_id
    ) AS email_engagement
GROUP BY user_id;

