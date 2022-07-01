SELECT *
FROM CovidDeaths cd
WHERE location = 'World'

--Total COVID cases in the world--
SELECT location, [date], total_cases, new_cases, total_deaths, population 
FROM CovidDeaths cd
WHERE continent IS NOT NULL 
ORDER BY 1,2

--Looking at total Cases VS Total Deaths
SELECT location, [date], total_cases, total_deaths, (total_deaths*100.0/total_cases) as death_percentage
FROM CovidDeaths cd
WHERE location LIKE '%Dominican Republic' AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Population--
--Shows what percentage of population got COVID--
SELECT location, [date], population, total_cases, (total_cases*100.0/population) as infection_rate
FROM CovidDeaths cd
WHERE location LIKE '%Dominican Republic' AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection rate compare to population--
SELECT
	location,
	population,
	MAX(total_cases) as highest_infection_count,
	MAX((total_cases * 100.00 / population)) AS percent_population_infected
FROM
	CovidDeaths cd
WHERE continent IS NOT NULL
GROUP BY
	location,
	population
ORDER BY
	percent_population_infected DESC

--Looking at total deaths by country---
SELECT location, MAX(total_deaths)AS total_death_count
FROM CovidDeaths cd 
WHERE continent  IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

--Looking at total deaths by continent---
SELECT location, MAX(total_deaths)AS total_death_count
FROM CovidDeaths cd 
WHERE continent  IS NULL
GROUP BY location
ORDER BY total_death_count DESC

-- GLOBAL NUMBERS by date --
SELECT 
	date,
	SUM(new_cases) as total_cases,
	SUM(new_deaths) as total_deaths,
	SUM(total_deaths/total_deaths)*0.01as death_percentage 
FROM
	CovidDeaths cd 
GROUP BY 
	date
ORDER BY 
	1,2
	
--Only World's total--
	SELECT 
	SUM(new_cases) as total_cases,
	SUM(new_deaths) as total_deaths,
	SUM(total_deaths/total_deaths)*0.01as death_percentage 
FROM
	CovidDeaths cd 
ORDER BY 
	1,2
	
--Looking at Total Population vs Vaccination 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) rolling_people_vaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- TEMP TAB--
DROP TABLE IF exists #percent_population_vaccinated

CREATE TABLE #percent_population_vaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT
	INTO
	#percent_population_vaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY
	dea.location,
	dea.date) rolling_people_vaccinated
FROM
	CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON
	dea.location = vac.location
	AND dea.date = vac.date
	--WHERE dea.continent IS NOT NULL 
	--ORDER BY 2,3

SELECT
	*,
	(rolling_people_vaccinated / population)* 100
FROM
	#percent_population_vaccinated

-- Creating View to store data for later visualizations --
	
	CREATE VIEW percentage_population_vaccinated AS
	SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY
	dea.location,
	dea.date) rolling_people_vaccinated
FROM
	CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON
	dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL 
	--ORDER BY 2,3