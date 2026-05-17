
-

CREATE TABLE netflix 
(
	show_id varchar(6),
	type varchar(10),
	title varchar(150),	
	director varchar(208),
	castS varchar(1000),
	country	varchar(150),
	date_added varchar(50),
	release_year INT,	
	rating varchar(10),
	duration varchar(15),
	listed_in varchar(100),
	description varchar(250)

);



SELECT * FROM netflix;


-- 1. Count the number of Movies vs TV Shows

SELECT count(show_id) as number, type 
FROM netflix
group by 2;

-- OR 

with cou as (
SELECT *,
	case 
		when type ='Movie' then 'movie'
		when type ='TV Show' then 'tv_show'
	end as ty
FROM netflix)
select ty,count(*) as count
from cou
group by 2


--2. Find the most common rating for movies and tv shows

with t1 as (
	SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1, 2
			) 
SELECT 
	type,
	rating
FROM t1
 WHERE ranking=1
 
3. List all movies released in a specific year(eg. 2021)

SELECT title
FROM netflix
	WHERE type='Movie'  
	AND
	release_year=2021

4.Find the top 5 countries with the most content on Netflix
SELECT TRIM(UNNEST(STRING_TO_ARRAY(country,','))) as new_country,
	   COUNT(show_id) as tot_content
FROM netflix
GROUP BY 1
ORDER by 2 DESC
limit 5;

5. Identify the longest movie or TV show duration.

SELECT * FROM netflix
WHERE type='Movie'
	  AND
	  duration=(SELECT MAX(duration) FROm netflix)
		
6. Find content added in the last 5 years

SELECT * 
FROM netflix
WHERE TO_DATE(date_added, 'MONTH DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

7. Find all the movies/TV shows by director 'Michael Wech'

SELECT * FROM netflix
WHERE director ILIKE '%Michael Wech%'

8. Count the number of content more than 5 seasons

SELECT * FROM netflix 
WHERE 
	 type='TV Show'
	 AND
	 SPLIT_PART(duration, ' ', 1)::numeric > 5

9. Count the number of content items in each genre

SELECT 
	   UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
	   COUNT(show_id)	   
FROM netflix
GROUP By 1

10. Find each year and the average numbers of content released in United Kingdom on netflix return
top 5 years with highest average content release !

SELECT 
	EXTRACT( YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'United Kingdom') :: numeric * 100, 2) as avg_content_per_year
FROM netflix
WHERE country= 'United Kingdom'
GROUP BY 1

11. List all movies that are documentaries

SELECT *
FROM netflix
WHERE 
	  listed_in ILIKE '%documentaries%'
	  
12. Find alll content without a director

SELECT *
FROM netflix
WHERE director is null
13. Find how many movies actor 'Salman Kkhan' appeared in last 15 years!

SELECT *
FROM netflix
WHERE 
	casts ILIKE 'Salman Khan%'
	AND
	release_year > EXTRACT(YEAR from CURRENT_DATE) - 15
	
14. Find the top 10 actors who gave appeared n the highest number of movies produced  in United Kingdom.

SELECT 
UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
COUNT(*) as total_count
FROM netflix
WHERE country ILIKE '%United Kingdom%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
 
15. Categorize the content based on the prescence of the keywords 'kill' and 'violence' in the description field.
Label content containing these keywords as 'Extreme_content' and all other content as 'Good_content'. Count how many ite,s falll into each cactegory.

WITH new_t AS(
SELECT *,
	CASE
		WHEN 
			description ILIKE '%kill%' OR
			description ILIKE '%kill%' THEN 'Extreme_content'
			ELSE 'Good_content'
		END category
FROM netflix )
SELECT category,
	COUNT(*) as total_content
FROM new_t
GROUP BY 1