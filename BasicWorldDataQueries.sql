-- Basic Constraints --
-- Use /* */ to comment entire queries --

-- How many countries start with the letter _? --

/*SELECT DISTINCT COUNT(*) AS Total FROM world.country
WHERE Name LIKE 'A%';*/

-- Which countries are _ letters long? --

/*SELECT DISTINCT * FROM world.country
WHERE LENGTH(Name) = 5;*/

-- Which country comes after _________ ? 10 after? 2 before? --

/* SELECT * FROM world.country
WHERE Name >= 'United States'
ORDER BY Name ASC
LIMIT 1 OFFSET 1; */

/* SELECT * FROM world.country
WHERE Name <= 'United States'
ORDER BY Name DESC
LIMIT 1 OFFSET 2; */

-- Average life expectancy of all countries? --

/* SELECT AVG(LifeExpectancy) FROM world.country; */

-- Average length of country name? --

/* SELECT AVG(LENGTH(Name)) FROM world.country; */

-- Domini-query: Percent difference GNP and GNPOld of all countries that end in 'a' --

/* SELECT Name, ((GNP-GNPOld)/GNPOld)*100 AS PercentDifference FROM world.country
WHERE Name LIKE '%a'; */

-- Domini-query: Capital is even, Goverment Form is Republic, LifeExpectancy between 60-70, Name ends in 'a' --

/* SELECT Name, LifeExpectancy, GovernmentForm, Capital FROM world.country
WHERE Name LIKE '%a'
AND LifeExpectancy BETWEEN 60 AND 70
AND GovernmentForm = 'Republic'
AND Capital % 2 = 0; */

-- JOINS and other stuff --

-- Population of Spain? --

/* SELECT world.country.Name, world.country.Code, world.city.Population FROM world.country
LEFT JOIN world.city
	ON world.country.Code = world.city.CountryCode
WHERE world.country.Name = 'Spain'
GROUP BY world.city.CountryCode; */

-- MANUAL CHECK -- 

/* SELECT CountryCode, Population FROM world.city
WHERE CountryCode = 'ESP'
GROUP BY CountryCode; */

-- What are all the slovak speaking countries? --

/* SELECT world.country.Name, world.countrylanguage.Language FROM world.country
LEFT JOIN world.countrylanguage
	ON world.country.Code = world.countrylanguage.CountryCode
WHERE world.countrylanguage.Language = 'Slovak'
GROUP BY world.country.Code; */

-- Manual Check --

/* SELECT * FROM world.countrylanguage
WHERE Language LIKE 'Slovak'; */


-- Next Level --

-- A dood wants to live in a Chinese speaking city in a country with a life expectancy of at least 80 years. Where can they go? --

/* SELECT world.city.Name, world.country.Name, world.country.LifeExpectancy, world.countrylanguage.Language FROM world.country
LEFT JOIN world.city
	ON world.country.Code = world.city.CountryCode
LEFT JOIN world.countrylanguage
	ON world.countrylanguage.CountryCode = world.city.CountryCode
WHERE world.countrylanguage.Language = 'Chinese'
AND world.country.LifeExpectancy > 80.5; */



/* SELECT * FROM world.country; */


