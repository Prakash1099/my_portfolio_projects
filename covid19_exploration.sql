/*
COVID 19 DATA EXPLORATION IN SQL
TOOL: MS SQL SERVER
SKILLS USED: JOINS, CTE'S, TEMP TABLES, WINDOW FUNCTIONS, AGGREGATE FUNCITONS, CREATING VIEW, CONVERTING DATA TYPES
DATASETS: CovidDeaths, CovidVaccinations
		  BOTH THE DATASET CONTAINS DATA FROM 2020-02-24 to 2021-04-30
*/ 



-- SELECTING DATA THAT WE ARE GOING TO WORK

SELECT location
	,  date
	,  total_cases
	,  total_deaths
	,  population
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL			
ORDER BY location, date;



-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- WE CAN ADD WHERE CLAUSE FILTER SPECIFIC COUNTRIES
-- CHANCES OF DYING IF YOU ARE INFECTED

SELECT location
	,  date
	,  total_cases
	,  total_deaths
	,  (total_deaths/total_cases)*100 AS death_percentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
--	AND location LIKE '%india%'
ORDER BY 1, 2;



-- LOOKING AT THE TOTAL CASES VS THE POPULATION
-- WE CAN ADD WHERE CLAUSE FILTER SPECIFIC COUNTRIES
-- SHOWS THE PERCENTAGE OF POPULATION INFECTED WITH COVID

SELECT location
	,  date
	,  population
	,  total_cases
	,  (total_cases/population)*100 AS infected_percentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
--	AND location like '%india%'
ORDER BY 1, 2;



-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location
	,  population
	,  MAX(total_cases) AS highest_cases
	,  MAX(total_cases/population)*100 AS highest_case_percent
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_case_percent DESC;



--SHOWING THE COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULAITON

SELECT location
	,  MAX(CAST(total_deaths AS INT)) AS max_total_deaths   --BECAUSE ITS IN NVARCHAR(255)
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_total_deaths DESC;



-- EXPLORING AT  CONTINENT LEVEL
-- SHOWING CONTINENTS WITH HIGHEST DEATH COUNT

SELECT continent
	,  MAX(CAST(total_deaths AS INT)) AS max_total_deaths
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL  
GROUP BY continent
ORDER BY max_total_deaths DESC;


--EXPLORING GLOBALLY

--TOTAL CASES VS TOTAL DEATHS DAILY

SELECT date
	,  SUM(new_cases) Total_cases
	,  SUM(CAST(new_deaths AS int)) tatal_deaths
	,  SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS death_percent
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date


--TOTAL CASES, TOTAL DEATHS, PERCENT DEATH

SELECT SUM(new_cases) total_cases
	,  SUM(CAST(new_deaths AS int)) total_deaths
	,  SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS death_percent
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL



--TOTAL VACCINATIONS VS TOTAL POPULATION EACH DAY

SELECT d.continent
	,  d.location
	,  d.date
	,  d.population
	,  v.new_vaccinations
	,  SUM(CAST(v.new_vaccinations AS INT)) 
			OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
FROM ProjectPortfolio..CovidDeaths d
JOIN ProjectPortfolio..CovidVaccinations v
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3


--USING CTE TO FIND PERCENT PEOPLE VACCINATED
--TOTAL POPULATION VS TOTAL PEOPLE VACCINATED


with popvsvac(continent, location, date,population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT d.continent
	,  d.location
	,  d.date
	,  d.population
	,  v.new_vaccinations
	,  SUM(CAST(v.new_vaccinations AS INT)) 
			OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM ProjectPortfolio..CovidDeaths d
JOIN ProjectPortfolio..CovidVaccinations v
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *
	,  (rolling_people_vaccinated/population)*100 AS percent_population_vaccinated
from popvsvac


--USING TEMP TEABLE FOR THE SAME

DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #percent_population_vaccinated
SELECT d.continent
	,  d.location
	,  d.date
	,  d.population
	,  v.new_vaccinations
	,  SUM(CAST(v.new_vaccinations AS INT)) 
			OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM ProjectPortfolio..CovidDeaths d
JOIN ProjectPortfolio..CovidVaccinations v
	ON d.location = v.location 
	AND d.date = v.date
ORDER BY 2,3

-- SELECT * FROM #percent_population_vaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW percent_population_vaccinated AS
SELECT d.continent
	,  d.location
	,  d.date
	,  d.population
	,  v.new_vaccinations
	,  SUM(CONVERT(INT, v.new_vaccinations)) 
			OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM ProjectPortfolio..CovidDeaths d
JOIN ProjectPortfolio..CovidVaccinations v
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL

	

























