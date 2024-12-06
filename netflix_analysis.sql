-- counting the number of movies vs tv shows

select typee, count(*) as total_contnet
from netflix
group by (typee);

-- Find the most common rating for movies and TV shows
select typee, rating
from(
select typee,rating,count(*),
rank() over(partition by typee order by count(*) desc) as ranking
from netflix
group by 1,2)as t1
where ranking = 1 ;


-- 3. List all movies released in a specific year (e.g., 2020)

select title, typee, release_year
from netflix
where typee = 'Movie' and release_year = 2020;

--  Find the top 5 countries with the most content on Netflix


select *
from(
select unnest(string_to_array(country,',')) as country,
count(*) as total_content
from netflix
group by 1) as t1
where country is not null
order by total_content desc
limit 5;

-- Finding content added in the last 5 years
select * 
from netflix
where to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years';

select count(*) 
from netflix
where to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years';


-- Find all the movies/TV shows by director 'Rajiv Chilaka'!

select *
from(

select * , unnest(string_to_array(director, ','))as director_name
from netflix
)
where director_name = 'Rajiv Chilaka';


 -- Listing all TV shows with more than 5 seasons

select *
from netflix
where typee = 'TV Show'
and
split_part(duration,' ',1)::int > 5;


-- Count the number of content items in each genre
select unnest(string_to_array(listed_in, ',')) as genre,
count(*) as total_content
from netflix
group by 1;


select * from netflix;

-- Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

select country,
release_year,
count(show_id) as total_release
from netflix
where country = 'India'
group by country, 2
order by total_release desc
limit 5;


SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5;


-- list all movies that are documentaries
select * from netflix
where listed_in like '%Documentaries';
select count(*) from netflix
where listed_in like '%Documentaries';

--  Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix
where 
	casts like '%Salman Khan%'
	and 
	release_year> extract(year from current_date) - 10;
select * from netflix
where 
	casts like '%Shah Rukh Khan%'
	and 
	release_year> extract(year from current_date) - 10;
	
-- find the top 10 actors who have appeared 
-- in the highest number of movies produced in Inida
select unnest(string_to_array(casts,',')) as actor,
count(*) as appearance
from netflix
where country = 'India'
group by actor
order by appearance desc
limit 10;

-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

select category, typee,
count(*) as contnent_count
from(
select *,
case
	when description like '%kill' or description like '%violence%' then 'Bad'
	else 'Good'
	end as category
	from netflix
) as categorized_content
group by 1,2
order by 2;