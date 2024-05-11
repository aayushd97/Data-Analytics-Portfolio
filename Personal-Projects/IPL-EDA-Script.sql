--SQL DATA ANALYSIS PROJECT (IPL DATA 2008-2020)

drop table if exists #ipls;
create table #ipls
(
id float, 
inning float, 
overr float, 
ball float,
batsman nvarchar(255),
non_striker nvarchar(255),
bowler nvarchar(255),
batsman_runs float,
extra_runs float,
total_runs float,
non_boundary float,
is_wicket float,
dismissal_kind nvarchar(255),
player_dismissed nvarchar(255),
fielder nvarchar(255),
extras_type nvarchar(255),
batting_team nvarchar(255),
bowling_team nvarchar(255),
)

--Combining tables ipl1,ipl2,ipl3,ipl4
insert into #ipls
select * from dbo.ipl1
UNION
select * from dbo.ipl2
UNION
select * from dbo.ipl3
UNION
select * from dbo.ipl4;

--QUESTION 1: How many games were played in each year?
--Step 1: Altering the 'date' column data type in table 'customers'
ALTER TABLE customers
ALTER COLUMN date DATE;
--Step 2: Counting the # of matches per year
SELECT YEAR(date) AS Year,
       COUNT(DISTINCT id) AS GamesPlayed
FROM customers
GROUP BY YEAR(date)
ORDER BY Year;
--Comment: It seems that there were extra games played in 2011 and 2012, after which there were exactly 59 or 60 games played
--each year until 2020.

--QUESTION 2: Which players got the most player of the match awards? 
SELECT TOP(10) player_of_match, COUNT(*) AS number_of_pom
FROM customers
GROUP BY player_of_match
ORDER BY number_of_pom DESC;
--Comment: AB De Villiers and Chris Gayle are the two cricketers with most player of the match awards with 23 and 22 respectively. 

--QUESTION 3: Which players got the most player of the match awards by season? 
SELECT * FROM
(SELECT player_of_match, yr, number_of_pom, rank()
OVER (PARTITION BY yr ORDER BY number_of_pom DESC) rnk FROM 
(SELECT player_of_match, year(date) yr, COUNT(player_of_match) number_of_pom
FROM customers
GROUP BY player_of_match, year(date)
)a)b
WHERE rnk=1;
--Comment: Here, we used subqueries to find the players that won the most player of the match awards in each season. It can be seen
--that in some seasons, multiple players got the most player of the match awards. 

--QUESTION 4: What is the percentage of total runs scored by each batsman?
--We have to use a running sum model to calculate this percentage
SELECT  *,
total_runs/sum(total_runs) OVER (ORDER BY total_runs rows BETWEEN unbounded preceding AND unbounded following) runs FROM
(SELECT batsman, sum(total_runs)total_runs FROM #ipls GROUP BY batsman)a;

SELECT batsman, sum(total_runs) FROM #ipls GROUP BY batsman ORDER BY sum(total_runs) DESC;
--Comment: Virat Kohli has scored the highest percentage of total runs in IPL, by scoring a total of 6081 runs, which is 2.4% of the
--total runs scored in IPL from 2008-2020. 

--QUESTION 5: Who scored and conceded the most number of sixes in IPL?
SELECT TOP(10) batsman, COUNT(batsman_runs) AS no_of_sixes FROM #ipls 
WHERE batsman_runs=6 GROUP BY batsman ORDER BY no_of_sixes DESC;

SELECT TOP(10) bowler, COUNT(batsman_runs) AS no_of_sixes FROM #ipls 
WHERE batsman_runs=6 GROUP BY bowler ORDER BY no_of_sixes DESC;
--Comment: Therefore, Chris Gayle is the player that has hit the most sixes in IPL with a whopping 349 sixes. AB De Villiers comes in
--2nd with 235, and MS Dhoni comes in 3rd with 216. This is interesting because Chris Gayle has hit 114 sixes more than the 2nd highest.
--Also, the bowlers that have conceded the most sixes are PP Chawla (181), A Mishra (172) and RA Jadeja (148). 

--QUESTION 6: Out of all players that have scored more than 3000 runs, which ones have the highest strike rate? 
--Strike rate is the total number of runs scored divided by the total number of balls faced. 
SELECT batsman, batsman_runs, strike_rate FROM  
(SELECT batsman, batsman_runs, ((batsman_runs*1.0)/total_balls)*100 strike_rate FROM
(SELECT batsman, sum(batsman_runs) batsman_runs, COUNT(batsman) total_balls FROM #ipls GROUP BY batsman )a)b
WHERE batsman_runs>3000 ORDER BY strike_rate DESC;
--Comment: From the results, there are only 17 players who have scored more than 3000 runs in IPL, with AB de Villiers having the
--highest strike rate (148.56), with the 2nd player being KA Pollard having a strike rate of 143.47. It is getting clearer and clearer
--to see why AB De Villiers is one of the best batsman in the world. 

--QUESTION 7:  Which bowlers, who have bowled at least 50 overs (300 balls), have the lowest economy rate? 
--Economy rate is the total number of runs conceded, divided by the total number of balls bowled. 
SELECT TOP(10) bowler, runs_conceded/no_of_balls economy_rate FROM 
(SELECT bowler, COUNT(bowler) no_of_balls, SUM(total_runs) runs_conceded  FROM #ipls
GROUP BY bowler)a
WHERE no_of_balls>300
ORDER BY economy_rate ASC; 
--Comment: Therefore, the players with the lowest economy rate i.e. the players that have conceded the least amount of runs in the most
--amount of balls are Rashid Khan(1.06), Anil Kumble (1.11), and GD McGrath (1.11). 

--QUESTION 8: Which team has won the most amount of games in IPL from 2008-2020?
SELECT winner, COUNT(winner) AS no_of_wins FROM customers 
GROUP BY winner ORDER BY no_of_wins DESC;
--Comment: Mumbai Indians are the team with the highest number of wins (120), with Chennai Super Kings coming in 2nd (106) and Kolkata
--Knight Riders coming in 3rd (99). 

--THANK YOU SO MUCH
--Aayush Damani

