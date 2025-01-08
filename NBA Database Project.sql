--- WHO HAD THE BEST 3 YEAR YEAR RUN 'WIN PERCENTAGE-WISE' FROM 2004-2020 
WITH max_standings_per_season AS (
    SELECT 
        "TEAM", 
        "SEASON_ID", 
        MAX("STANDINGSDATE") AS max_date
    FROM 
        public."ranking"
    WHERE 
        "SEASON_ID" BETWEEN 22004 AND 22020
    GROUP BY 
        "TEAM", 
        "SEASON_ID"
),
deduplicated_ranking AS (
    SELECT DISTINCT 
        r."TEAM", 
        r."SEASON_ID", 
        r."W", 
        r."L",
        r."STANDINGSDATE"
    FROM 
        public."ranking" r
    JOIN 
        max_standings_per_season m
    ON 
        r."TEAM" = m."TEAM" 
        AND r."SEASON_ID" = m."SEASON_ID" 
        AND r."STANDINGSDATE" = m.max_date
),
three_season_spans AS (
    SELECT 
        r."TEAM",
        CONCAT(MIN(r."SEASON_ID"), '-', MAX(r."SEASON_ID")) AS season_range,
        SUM(r."W") AS total_wins,
        SUM(r."L") AS total_losses,
        (SUM(r."W")::FLOAT / (SUM(r."W") + SUM(r."L"))) * 100 AS win_pct
    FROM 
        deduplicated_ranking r
    GROUP BY 
        r."TEAM", 
        FLOOR((r."SEASON_ID" - 22004) / 3) -- Groups seasons into rolling 3-season spans
)
SELECT 
    "TEAM",
    season_range,
    total_wins,
    total_losses,
    win_pct
FROM 
    three_season_spans
ORDER BY 
    win_pct DESC;

-- Most wins for teams in the dataset FROM 2004-2020
WITH max_dates_per_season AS (
    SELECT 
        "SEASON_ID", 
        MAX("STANDINGSDATE") AS max_date
    FROM 
        public."ranking"
    WHERE 
        "SEASON_ID" BETWEEN 22004 AND 22020
    GROUP BY 
        "SEASON_ID"
)
SELECT 
    r."TEAM", 
    SUM(r."W") AS total_wins, 
    SUM(r."L") AS total_losses, 
    (SUM(r."W")::FLOAT / (SUM(r."W") + SUM(r."L"))) * 100 AS win_pct
FROM 
    public."ranking" r
JOIN 
    max_dates_per_season m
ON 
    r."SEASON_ID" = m."SEASON_ID" AND r."STANDINGSDATE" = m.max_date
GROUP BY 
    r."TEAM"
	
ORDER BY win_pct DESC;

-- Most wins for teams in the dataset FROM 2014-2020
WITH max_dates_per_season AS (
    SELECT 
        "SEASON_ID", 
        MAX("STANDINGSDATE") AS max_date
    FROM 
        public."ranking"
    WHERE 
        "SEASON_ID" BETWEEN 22014 AND 22020
    GROUP BY 
        "SEASON_ID"
)
SELECT 
    r."TEAM", 
    SUM(r."W") AS total_wins, 
    SUM(r."L") AS total_losses, 
    (SUM(r."W")::FLOAT / (SUM(r."W") + SUM(r."L"))) * 100 AS win_pct
FROM 
    public."ranking" r
JOIN 
    max_dates_per_season m
ON 
    r."SEASON_ID" = m."SEASON_ID" AND r."STANDINGSDATE" = m.max_date
GROUP BY 
    r."TEAM"
	
ORDER BY win_pct DESC;


-- GOOD TEAMS IN 2019 --
SELECT "TEAM" 
FROM public."ranking"
WHERE "STANDINGSDATE" = '2019-04-10' AND "W_PCT" > 0.585;

-- GOOD TEAMS ANY YEAR --
SELECT *
FROM public."ranking"
WHERE "W_PCT" > 0.600 AND "W" >= 50;


-- Player Total Points against "Good Teams" (Above .585 win percentage) in 2018-2019
SELECT gd."PLAYER_NAME", SUM(DISTINCT gd."PTS") AS total_points
FROM public."games_details" AS gd
JOIN public."games" AS g ON gd."GAME_ID" = g."GAME_ID"
JOIN public."ranking" AS r ON r."TEAM_ID" = g."HOME_TEAM_ID"
WHERE g."SEASON" = 2019
  AND r."TEAM" IN (
      SELECT "TEAM"
      FROM public."ranking"
      WHERE "STANDINGSDATE" = '2019-04-10'
        AND "W_PCT" > 0.585
  )
  AND gd."PTS" IS NOT NULL
GROUP BY gd."PLAYER_NAME"
ORDER BY total_points DESC;

-- Player Total Points against "Good Teams" (Above .585 win percentage) in 2017-2018
SELECT gd."PLAYER_NAME", SUM(DISTINCT gd."PTS") AS total_points
FROM public."games_details" AS gd
JOIN public."games" AS g ON gd."GAME_ID" = g."GAME_ID"
JOIN public."ranking" AS r ON r."TEAM_ID" = g."HOME_TEAM_ID"
WHERE g."SEASON" = 2018
  AND r."TEAM" IN (
      SELECT "TEAM"
      FROM public."ranking"
      WHERE "STANDINGSDATE" = '2019-04-10'
        AND "W_PCT" > 0.585
  )
  AND gd."PTS" IS NOT NULL
GROUP BY gd."PLAYER_NAME"
ORDER BY total_points DESC;


-- INCORRECT POINTS -- Player Total Points against "Good Teams" (Above .600 win percentage) from 2004-2020 
SELECT 
    gd."PLAYER_NAME", 
    SUM(gd."PTS") AS total_points
FROM 
    public."games_details" AS gd
JOIN 
    public."games" AS g 
    ON gd."GAME_ID" = g."GAME_ID"
JOIN 
    public."ranking" AS r 
    ON r."TEAM_ID" = g."HOME_TEAM_ID"
WHERE 
    g."SEASON" BETWEEN 2004 AND 2020
    AND r."TEAM" IN (
        SELECT "TEAM" 
        FROM public."ranking"
        WHERE "W_PCT" > 0.600 
          AND "W" >= 50
    )
    AND gd."PTS" IS NOT NULL
GROUP BY 
    gd."PLAYER_NAME"
ORDER BY 
    total_points DESC;

--- Player Total Points against "Good Teams" (Above .600 win percentage) from 2004-2020
WITH deduplicated_games_details AS (
    SELECT DISTINCT
        gd."PLAYER_NAME", 
        gd."GAME_ID", 
        gd."PTS"
    FROM 
        public."games_details" AS gd
    WHERE 
        gd."PTS" IS NOT NULL
),
filtered_teams AS (
    SELECT DISTINCT 
        r."TEAM"
    FROM 
        public."ranking" AS r
    WHERE 
        r."W_PCT" > 0.600 
        AND r."W" >= 50
),
filtered_games AS (
    SELECT DISTINCT
        g."GAME_ID", 
        g."SEASON",
        g."HOME_TEAM_ID"
    FROM 
        public."games" AS g
    WHERE 
        g."SEASON" BETWEEN 2004 AND 2020
)
SELECT 
    gd."PLAYER_NAME", 
    SUM(gd."PTS") AS total_points
FROM 
    deduplicated_games_details AS gd
JOIN 
    filtered_games AS g 
    ON gd."GAME_ID" = g."GAME_ID"
JOIN 
    public."ranking" AS r 
    ON r."TEAM_ID" = g."HOME_TEAM_ID"
JOIN 
    filtered_teams AS ft 
    ON r."TEAM" = ft."TEAM"
GROUP BY 
    gd."PLAYER_NAME"
ORDER BY 
    total_points DESC;


-- How many 60+ point games in the NBA - ALL DATA 2003-2022
SELECT "PLAYER_NAME", COUNT(DISTINCT "GAME_ID") as count
FROM public."games_details"
WHERE "PTS" > 59
GROUP BY "PLAYER_NAME"
ORDER BY count DESC;

-- Most wins for teams in the dataset FROM 2004-2019
WITH max_dates_per_season AS (
    SELECT 
        "SEASON_ID", 
        MAX("STANDINGSDATE") AS max_date
    FROM 
        public."ranking"
    WHERE 
        "SEASON_ID" BETWEEN 22004 AND 22019
    GROUP BY 
        "SEASON_ID"
)
SELECT 
    r."TEAM", 
    SUM(r."W") AS total_wins, 
    SUM(r."L") AS total_losses, 
    (SUM(r."W")::FLOAT / (SUM(r."W") + SUM(r."L"))) * 100 AS win_pct
FROM 
    public."ranking" r
JOIN 
    max_dates_per_season m
ON 
    r."SEASON_ID" = m."SEASON_ID" AND r."STANDINGSDATE" = m.max_date
GROUP BY 
    r."TEAM"
	
ORDER BY win_pct DESC;





