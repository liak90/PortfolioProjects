
-- PURPOSE: Explore COVID19 Data using SQL

-- DATA SOURCE: https://ourworldindata.org/covid-deaths

-- Select the approriate database

USE PortfolioProject

-- DELETE LATER
SELECT DISTINCT continent, location
FROM PortfolioProject..Covid19Deaths$
WHERE continent IS NOT NULL

-- Start by selecting the data fields that we are going to be using.

SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid19Deaths$
ORDER BY continent, location, date

-- It apears that when the continent is null, the location reflects the continent. Therefore, going forward, we will filter out all rows where the continent is null. 

SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid19Deaths$
WHERE continent IS NOT NULL
ORDER BY continent, location, date


-- Global numbers

SELECT SUM(new_cases) AS total_cases, 
	   SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	   SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..Covid19Deaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths by location & date
-- Shows the likelihood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..Covid19Deaths$
WHERE continent IS NOT NULL
ORDER BY location, date

-- Looking at Total Cases vs. Popultion
-- Shows what % of the population contracted covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasesPercentage 
FROM PortfolioProject..Covid19Deaths$
WHERE location LIKE '%israel%' AND continent IS NOT NULL
ORDER BY location, date

-- Looking at countries with highest infection rate compared to population

SELECT location,
	   population, 
	   MAX(total_cases) AS HighestInfectionCount, 
	   MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM PortfolioProject..Covid19Deaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MAX((total_cases/population))*100 DESC

-- Showing the countries with the highest deaths rate per population

SELECT location,
	   population, 
	   MAX(total_deaths) AS HighestDeathsCount, 
	   MAX((total_deaths/population))*100 AS PercentPopulationInfected 
FROM PortfolioProject..Covid19Deaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MAX((total_deaths/population))*100 DESC

-- Break the numbers down by continent
-- Showing the continents with the highest death count

SELECT continent, 
	   MAX(CAST(total_deaths AS INT)) AS HighestDeathsCount 
FROM PortfolioProject..Covid19Deaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MAX(CAST(total_deaths AS INT)) DESC

-- Looking at Total Popultion vs. Vaccinations  

SELECT d.continent, 
	   d.location, 
	   d.date, 
	   d.population, 
	   v.new_vaccinations, 
	   SUM(CAST(v.new_vaccinations AS BIGINT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..Covid19Deaths$ d
JOIN PortfolioProject..Covid19Vaccinations$ v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date

-- Use CTE to calculate rolling vaccintations %

WITH a AS(
SELECT d.continent, 
	   d.location, 
	   d.date, 
	   d.population, 
	   v.new_vaccinations, 
	   SUM(CAST(v.new_vaccinations AS BIGINT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS Rolling_Ppl_Vaccinated
FROM PortfolioProject..Covid19Deaths$ d
JOIN PortfolioProject..Covid19Vaccinations$ v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)

SELECT continent, 
	   location, 
	   date, 
	   population, 
	   new_vaccinations, 
	   Rolling_Ppl_Vaccinated, 
	   (Rolling_Ppl_Vaccinated/population)*100 AS PercentageVaccinated
FROM a

-- Total Vaccinated 

WITH a AS(
SELECT d.continent, 
	   d.location, 
	   d.date, 
	   d.population, 
	   v.new_vaccinations, 
	   SUM(CAST(v.new_vaccinations AS BIGINT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS Rolling_Ppl_Vaccinated
FROM PortfolioProject..Covid19Deaths$ d
JOIN PortfolioProject..Covid19Vaccinations$ v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)

SELECT continent, 
	   location, 
	   MAX(Rolling_Ppl_Vaccinated) AS TotalVaccinations,
	   (MAX(Rolling_Ppl_Vaccinated)/population)*100 AS PercantageVaccinated
FROM a
GROUP BY continent, location, population
ORDER BY continent, location

-- Create a temp table

-- CREATE VIEW PercentPopulationVaccinated AS 

-- DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE VaccinationRate
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Ppl_Vaccinated numeric
)

--you are here 
INSERT INTO VaccinationRate
SELECT d.continent, 
	   d.location, 
	   d.date, 
	   d.population, 
	   v.new_vaccinations, 
	   SUM(CAST(v.new_vaccinations AS BIGINT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS Rolling_Ppl_Vaccinated
FROM PortfolioProject..Covid19Deaths$ d
JOIN PortfolioProject..Covid19Vaccinations$ v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL

-- View the temp table

SELECT *
FROM VaccinationRate

-- Create view to store data for later visualizations

CREATE VIEW visual AS 
SELECT d.continent, 
	   d.location, 
	   d.date, 
	   d.population, 
	   v.new_vaccinations, 
	   SUM(CAST(v.new_vaccinations AS BIGINT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS Rolling_Ppl_Vaccinated
FROM PortfolioProject..Covid19Deaths$ d
JOIN PortfolioProject..Covid19Vaccinations$ v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL

-- View the view

SELECT *
FROM visual
