##Instagram User Analytics Project 

## MARKETING ANALYSIS

## Loyal User Rewards: 5 Oldest Users on Instagram

SELECT *
FROM users
ORDER BY created_at ASC
LIMIT 5;

## Inactive User Engagement: Identifying users that have never posted on Instagram

SELECT * FROM users
LEFT JOIN photos
ON users.id=photos.user_id
WHERE photos.user_id IS NULL;

## Checking to see whether these user_id's exist in the photos table

SELECT COUNT(*)
FROM users
WHERE user_id NOT IN (SELECT DISTINCT user_id FROM photos);

## Contest Winner Declaration: Identifying the user with the most likes on a single photo

SELECT photo_id, COUNT(*) FROM likes
GROUP BY photo_id
ORDER BY COUNT(*) DESC
LIMIT 1;

SELECT * FROM photos
INNER JOIN users
ON photos.user_id=users.id
WHERE photos.id=145;

## Hashtag Research: Identifying Top 5 tags used

SELECT tag_name, COUNT(id) FROM tags
GROUP BY tag_name;

## Ad Campaign Launch: Identifying the day of the week most users register on Instagram

SELECT COUNT(id), DAYNAME(created_at) AS day_name
FROM users
GROUP BY day_name;

## Investor Metrics

## User Engagement: Average Photos per User, and total number of photos/number of users on Instagram.

SELECT AVG(photo_count) AS average_photos_per_user
FROM (
    SELECT COUNT(id) AS photo_count
    FROM photos
    GROUP BY user_id
) AS subquery;

SELECT (SUM(photos.id)/ SUM(users.id)) AS photos_per_user  FROM photos
INNER JOIN;

SELECT COUNT(DISTINCT id) FROM users;

SELECT COUNT(DISTINCT id) FROM photos;

## Bots: Identify users that have liked every single photo

SELECT users.username, user_id, COUNT(user_id) FROM likes
INNER JOIN users 
ON likes.user_id=users.id
GROUP BY user_id
ORDER BY COUNT(user_id) DESC
LIMIT 20;





