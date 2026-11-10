-- Shiptivity task 3 queries (SQLite)
-- timestamps are unix seconds, so I use date(x, 'unixepoch')
-- release date = 2018-06-02 (from the README)

-- a. daily active users (distinct users who logged in each day)
SELECT date(login_timestamp, 'unixepoch') AS day,
       COUNT(DISTINCT user_id) AS dau
FROM login_history
GROUP BY day
ORDER BY day;

-- b. average DAU before vs after the release
-- days with no logins are not in the table so they are not counted
WITH daily AS (
  SELECT date(login_timestamp, 'unixepoch') AS day,
         COUNT(DISTINCT user_id) AS dau
  FROM login_history
  GROUP BY day
)
SELECT CASE WHEN day < '2018-06-02' THEN 'before' ELSE 'after' END AS period,
       COUNT(*) AS num_days,
       ROUND(AVG(dau), 2) AS avg_dau
FROM daily
GROUP BY period
ORDER BY period DESC;

-- c1. status changes per card per day
-- skip the first row of each card (oldStatus is NULL), that is just the card being created
SELECT cardID,
       date(timestamp, 'unixepoch') AS day,
       COUNT(*) AS status_changes
FROM card_change_history
WHERE oldStatus IS NOT NULL
GROUP BY cardID, day
ORDER BY cardID, day;

-- c2. total status changes per card (used for the bar chart)
-- left join so cards with 0 changes still show up
SELECT c.id AS cardID,
       COUNT(h.id) AS status_changes
FROM card c
LEFT JOIN card_change_history h
  ON h.cardID = c.id AND h.oldStatus IS NOT NULL
GROUP BY c.id
ORDER BY status_changes DESC, c.id;

-- c3. total status changes per day
SELECT date(timestamp, 'unixepoch') AS day,
       COUNT(*) AS status_changes
FROM card_change_history
WHERE oldStatus IS NOT NULL
GROUP BY day
ORDER BY day;
