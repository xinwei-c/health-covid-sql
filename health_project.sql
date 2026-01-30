-- CREATE DATABASE health_project;
USE health_project;
SHOW TABLES;

-- check the tables
-- Select *
-- FROM health_project.covidvaccinations
-- order by 3,4;

-- Select *
-- FROM health_project.coviddeaths
-- order by 3,4;

SELECT * FROM coviddeaths LIMIT 100;

SET SQL_SAFE_UPDATES = 0;
UPDATE health_project.coviddeaths
SET date = STR_TO_DATE(date, '%m/%d/%y')
WHERE date LIKE '%/%/%';

UPDATE health_project.covidvaccinations
SET date = STR_TO_DATE(date, '%m/%d/%y')
WHERE date LIKE '%/%/%';

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM health_project.coviddeaths
order by 1,2;

-- look at total cases and total deaths
-- likelihood of dying 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM health_project.coviddeaths
WHERE location like '%states%' -- the location contains "states"
ORDER BY 1,2;

-- looking at total cases vs the population
-- what percentage of population got covid

SELECT location, date, total_cases, population ,(total_cases/population)*100 AS CasePercentage
FROM health_project.coviddeaths
WHERE location like '%states%' -- the location contains "states"
ORDER BY CasePercentage DESC;

-- look at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases) / population * 100 AS PercentagePopulationInfected
FROM health_project.coviddeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC;

-- show countries with highest death count per population
SELECT location, 
		MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM health_project.coviddeaths
WHERE continent IS NOT NULL -- filter continent
  AND location NOT LIKE '%World%'
  AND location NOT LIKE '%Europe%'
  AND location NOT LIKE '%America%'
  AND location NOT LIKE '%Asia%'
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- break down to continent
SELECT continent,
		MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM health_project.coviddeaths
WHERE continent IS NOT NULL
  AND continent <> '' -- null and "" not the same
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- reverse
SELECT location,
		MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM health_project.coviddeaths
WHERE continent = ''
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- show the continents with the highest deaths count per population

-- global numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS SIGNED)) AS total_deaths, SUM(cast(new_deaths AS SIGNED))/ SUM(new_cases) * 100 AS DeathPercentage
FROM health_project.coviddeaths
WHERE continent is NOT NULL 
 AND continent != ''
GROUP BY date
order BY 1,2 ;

-- join tables
SELECT *
FROM health_project.coviddeaths dea
JOIN health_project.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date;

-- SELECT *
-- FROM health_project.covidvaccinations
-- LIMIT 100;

-- look at total population and vac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM health_project.coviddeaths dea
JOIN health_project.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is NOT NULL
	AND dea.continent != ""
ORDER BY 2,3; 


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS SIGNED)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population) *100 AS RollingPercentage
FROM health_project.coviddeaths dea
JOIN health_project.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is NOT NULL
	AND dea.continent != ""
ORDER BY 2,3; 

--  USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS SIGNED)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population) *100 AS RollingPercentage
FROM health_project.coviddeaths dea
JOIN health_project.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is NOT NULL
	AND dea.continent != "")
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac;

-- temp table
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
  continent VARCHAR(255),
  location VARCHAR(255),
  date DATE,
  population BIGINT,
  new_vaccinations BIGINT,
  RollingPeopleVaccinated BIGINT
);


INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, COALESCE(NULLIF(dea.population, ''), 0) AS population,
    COALESCE(NULLIF(vac.new_vaccinations, ''), 0) AS new_vaccinations,
    SUM(
        COALESCE(NULLIF(vac.new_vaccinations, ''), 0)
    ) OVER (
        PARTITION BY dea.location
        ORDER BY dea.date
    ) AS RollingPeopleVaccinated
FROM health_project.coviddeaths dea
JOIN health_project.covidvaccinations vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT * FROM PercentPopulationVaccinated;

DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

SELECT * FROM health_project.coviddeaths;
SELECT * FROM health_project.covidvaccinations;


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date,
    COALESCE(NULLIF(dea.population, ''), 0) AS population,
    COALESCE(NULLIF(vac.new_vaccinations, ''), 0) AS new_vaccinations,
    SUM( COALESCE(NULLIF(vac.new_vaccinations, ''), 0)) OVER (PARTITION BY dea.location
ORDER BY dea.date) AS RollingPeopleVaccinated
FROM health_project.coviddeaths dea
JOIN health_project.covidvaccinations vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;






