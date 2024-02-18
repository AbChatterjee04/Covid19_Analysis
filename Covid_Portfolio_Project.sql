/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM COVID19_ANALYSIS..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM COVID19_ANALYSIS..CovidVaccinations
--ORDER BY 3,4

-- Setting data 

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM COVID19_ANALYSIS..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows Survival Percentage

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM COVID19_ANALYSIS..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Let's check it for india


SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM COVID19_ANALYSIS..CovidDeaths
WHERE continent IS NOT NULL AND location = 'India'
ORDER BY 1,2


-- Checking for Us

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM COVID19_ANALYSIS..CovidDeaths
WHERE continent IS NOT NULL AND location LIKE '%States%'
ORDER BY 1,2


-- Total Cases Vs Population
-- Shows Infection Percentage of Population

SELECT location,date,population,total_cases,(total_cases/population)*100 AS InfectionPercentage
FROM COVID19_ANALYSIS..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- SHOWING Countries with Highest Infection Rate compared to Population

SELECT location,population,MAX(total_cases) AS HighestInfectionRate
,MAX((total_cases/population))*100 AS InfectionPercentage
FROM COVID19_ANALYSIS..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY InfectionPercentage DESC
 

-- Showing Countries with Highest Death Numbers

SELECT location,MAX(CAST(total_deaths AS INT)) AS HighestDeathRate
FROM COVID19_ANALYSIS..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathRate DESC



-- Getting Continentwise Highest Death Numbers

SELECT continent,MAX(CAST(total_deaths AS INT)) AS HighestDeathRate
FROM COVID19_ANALYSIS..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathRate DESC        -- Not precise


--Instead

SELECT location,MAX(CAST(total_deaths AS INT)) AS HighestDeathRate
FROM COVID19_ANALYSIS..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathRate DESC


-- Global Numbers

SELECT date,SUM(new_cases) AS NewCases,SUM(CAST(new_deaths AS INT)) AS NewDeath
,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 As DeathPercentage
FROM COVID19_ANALYSIS..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2



SELECT SUM(new_cases) AS NewCases,SUM(CAST(new_deaths AS INT)) AS NewDeath
,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 As DeathPercentage
FROM COVID19_ANALYSIS..CovidDeaths
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2


-- Joing 2 Tables

SELECT * 
FROM COVID19_ANALYSIS..CovidDeaths  dea
JOIN COVID19_ANALYSIS..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date


-- Looking at Total Population vs Vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS
RollingPeopleVaccinated
FROM COVID19_ANALYSIS..CovidDeaths  dea
JOIN COVID19_ANALYSIS..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- will CTE or Temp table to get (RollingPeopleVaccinated/dea.population) * 100 = vaccinated percentage

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS
RollingPeopleVaccinated --,(RollingPeopleVaccinated/dea.population) * 100
FROM COVID19_ANALYSIS..CovidDeaths  dea
JOIN COVID19_ANALYSIS..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE

WITH PopvsVac (Continent, Location, Date, Population,New_Vaccination,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS
RollingPeopleVaccinated 
FROM COVID19_ANALYSIS..CovidDeaths  dea
JOIN COVID19_ANALYSIS..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccinated/Population) * 100
FROM PopvsVac



-- Using TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS
RollingPeopleVaccinated 
FROM COVID19_ANALYSIS..CovidDeaths  dea
JOIN COVID19_ANALYSIS..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later Visualizations


CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)  AS
RollingPeopleVaccinated 
FROM COVID19_ANALYSIS..CovidDeaths dea
JOIN COVID19_ANALYSIS..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentagePopulationVaccinated
