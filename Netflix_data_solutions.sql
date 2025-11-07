
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(7),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT * FROM netflix

-- Task 1. Count the Number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY type

-- Task 2. Find the Most Common Rating for Movies and TV Shows

WITH RatingCounts AS (
	SELECT 
		type,
		rating,
		COUNT(*) as rating_count
	FROM netflix
	GROUP BY type, rating
),
RankedRatings AS (
	SELECT
		type,
		rating,
		rating_count,
		RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS ranking
	FROM RatingCoufnts
)
SELECT 
	type,
	rating AS most_frequent_rating
FROM RankedRatings
WHERE ranking = 1;

-- Task 3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * FROM netflix
WHERE 
	type = 'Movie' 
	AND 
	release_year = 2020

-- Task 4. Find the Top 5 Countries with the Most Content on Netflix
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5

-- Task 5. Identify the Longest Movie

SELECT
	*
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1

-- Task 6. Find Content Added in the Last 5 Years

SELECT 
	*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- Task 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'

-- Task 8. List All TV Shows with More Than 5 Seasons

SELECT *
FROM netflix
WHERE type = 'TV Show'
	AND SPLIT_PART(duration, ' ', 1)::INT > 5

-- Task 9. Count the Number of Content Items in Each Genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_count
FROM netflix
GROUP BY 1

-- Task 10. Find each year and the average numbers of content release in United States on netflix.

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as dates,
	COUNT(*),
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'United States') * 100
	,2)	as avg_content_per_year
FROM netflix
WHERE country = 'United States'
GROUP BY 1

-- Task 11. List All Movies that are Documentaries
SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%'

-- Task 12. Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL

-- Task 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%' 
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- Task 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in United States

SELECT
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
	COUNT(*)
FROM netflix
WHERE
	country = 'United States'
GROUP BY actors
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Task 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
-- Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. 
-- Count the number of items in each category.

WITH good_bad_content
AS
(

SELECT 
*,
	CASE
	WHEN 
		description ILIKE '%kill%' OR 
		description ILIKE '%violence%' THEN 'Bad Content'
		ELSE 'Good Content'
	END category
FROM netflix
)
SELECT
	category,
	COUNT(*) as total_content
FROM good_bad_content
GROUP BY 1

-- End Project





