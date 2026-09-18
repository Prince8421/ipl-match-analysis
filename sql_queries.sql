-- 1 Total matches played per season
SELECT Season, COUNT(*) as total_matches
FROM matches
GROUP BY Season
ORDER BY total_matches ;
-- INSIGHTS: IPL grew from 58 matches in 2008 to 74 matches in 2022.
-- Season 2020-2021 had least matches due to COVID .

-- 2 Which team won most matches overall
SELECT WinningTeam, COUNT(*) as total_wins
FROM matches
WHERE WinningTeam IS NOT NULL
GROUP BY WinningTeam
ORDER BY total_wins DESC;
-- Insights: Mumbai Indians leads with 131 wins showing consistent dominance.
-- Clear gap between top 3 and remaining teams.

-- 3 Toss decision preference 
SELECT TossDecision, COUNT(*) as times_chosen
FROM matches
GROUP BY TossDecision;
-- Insights:(63%)captains chose fielding first showing trams prefer chasing in T20 format due to dew factor. 

-- 4 Top 10 player of the Match winners
SELECT Player_of_Match, COUNT(*) as match_winners
FROM matches
WHERE Player_of_Match IS NOT NULL
GROUP BY Player_of_Match
ORDER BY match_winners DESC
LIMIT 10;
-- Insights: AB de Viliers won most awards 25 times showing consistent match winning impact across multiple seasons.

-- 5 Most matches hosted by each city
SELECT City, COUNT(*) as matches_hosted
FROM matches
WHERE City IS NOT NULL
GROUP BY City
ORDER BY matches_hosted DESC;
-- Insights: Mumbai hosted most matches with 159 games.
-- Top 3 cities hosted 35% of all matches

-- 6 Did toss winner win the match
SELECT 
CASE
   WHEN TossWinner = WinningTeam THEN 'Toss Winner Won'
   ELSE 'Toss Winner Lost'
   END AS result,
   COUNT(*) as total
   FROM matches
   WHERE WinningTeam is NOT NULL
   GROUP BY result;
  -- Insights: Toss winner won approx 52% of matches showing toss give slight advantage
  -- but skill matters more.
  
-- 7 Top 10 run scorers all time 
SELECT batter, SUM(batsman_run) as total_runs
FROM deliveries
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 10;
-- Insights: V Kohli leads with 6634 runs showing remarkable consistency.
-- Top 3 batters crossed 5500 runs

-- 8 Top 10 wicket takers
SELECT bowler, COUNT(*) as total_wickets
FROM deliveries
WHERE isWicketDelivery = 1
AND kind NOT IN ('run out','retired hurt')
GROUP BY bowler
ORDER BY total_wickets DESC
LIMIT 10;
-- Insights: DJ Bravo leads with 183 wickets .
-- IN top 10 six of them are spinners showing more effective in IPL.

-- 9 Most Boundries By Batter
SELECT batter,
SUM(CASE WHEN batsman_run  = 4 THEN 1 ELSE 0 END)AS fours,
SUM(CASE WHEN batsman_run = 6 THEN 1 ELSE 0 END) AS sixes
FROM deliveries
GROUP BY batter
Order by (fours + sixes)DESC
LIMIT 10;
-- Insights: S Dhawan hit most boundries with 701 fours and 137 sixes
-- showing  most aggressive batting style.

-- 10 Average runs per match by each team 
SELECT BattingTeam, ROUND(avg(total_run_per_match), 2) as avg_runs
FROM(
     SELECT ID, BattingTeam,
     SUM(total_run) as total_run_per_match
     FROM deliveries
     GROUP BY ID, BattingTeam) as team_scores
     GROUP BY BattingTeam
     ORDER BY avg_runs DESC;
     -- Insights: Lucknow Super Giants has highest 169.87 runs per match.
     -- 34.08 runs gap between best and worst averaging team.
     
-- 11 Wins per team per season using window function 
SELECT Season, WinningTeam,
COUNT(*) as season_wins,
SUM(COUNT(*)) OVER(partition by WinningTeam ORDER BY Season) AS cumulative_wins
FROM matches
WHERE WinningTeam IS NOT NULL
GROUP BY Season, WinningTeam;
-- Insights: Chennai Super Kings shows steepest cumulative growth showing 
-- dominance across most seasons. Some teams show flat phases.

-- 12 Rank teams by wins each season
SELECT Season, WinningTeam, total_wins,
RANK() OVER(PARTITION BY Season order by total_wins DESC) as rank_in_season 
FROM (
SELECT Season , WinningTeam, count(*) AS total_wins
FROM matches
WHERE WinningTeam IS NOT NULL
GROUP BY Season, WinningTeam) AS season_summary;
-- Insights: Rajasthan Royals achieved rank 1 in most seasons.
-- Different winners each season show IPL is highly competitive.

-- 13 Best powerplay teams(first 6 overs)
SELECT BattingTeam,
round(AVG(powerplay_runs), 2) as avg_powerplay_score
FROM(
SELECT ID, BattingTeam,
SUM(total_run) as powerplay_runs
FROM deliveries
WHERE overs <= 6
GROUP BY ID, BattingTeam)as pp
GROUP BY BattingTeam
ORDER BY avg_powerplay_score DESC; 
-- Insights: Gujarat Lions averages 60.60 runs in powerplay showing
-- most aggressive opening strategy among all franchises.

-- 14 Most consistent batters using CTE	
WITH batter_stats AS (
SELECT batter, ID,
SUM(batsman_run) as match_runs
FROM deliveries
GROUP BY batter,ID
)
SELECT batter,
ROUND(avg(match_runs), 2) as avg_runs,
COUNT(ID) as matches_played
FROM batter_stats
GROUP BY batter 
HAVING matches_played > 20 
ORDER BY avg_runs DESC
LIMIT 10 ;
-- Insights: KL Rahul averages 39.34 runs per match across
-- 99 games showing best consistency among regular players.

-- 15 Death over economy of bowlers(overs 16-20)
SELECT bowler,
ROUND(SUM(total_run)* 6.0 / COUNT(*), 2) as death_economy
FROM deliveries
WHERE overs BETWEEN 16 AND 20
GROUP BY bowler
HAVING COUNT(*) > 100
ORDER BY death_economy ASC
LIMIT 10 ;
-- Insights : Rashid Khan has best death economy of 7.18 
-- showing best pressure performance in last 5 overs.

SELECT 
round(SUM(total_run)/(COUNT(*)/6),2)AS avg_run_rate 
FROM deliveries ;

