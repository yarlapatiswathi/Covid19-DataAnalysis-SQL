--Introducing tables 
SELECT * FROM PortfolioProject..CovidDeaths order by population desc;
SELECT * FROM PortfolioProject..CovidVaccinations;

/********************************************************************************/

--Population vs Total cases vs Total Deaths  based on Location and its percentage
SELECT location,date,total_deaths,total_cases,
((total_cases*100.00)/population) AS InfectedPercentage, 
((total_deaths*100.00)/total_cases) AS InfectedDeathPercentage  
FROM PortfolioProject..CovidDeaths 
WHERE total_cases!=0 AND continent is NOT NULL
ORDER BY location,date;

/**********************************************************************************/

--Total cases vs population

SELECT Location,date,total_cases,population
,(total_cases*100.00/population) AS InfectedPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is NOT NULL --and location like '%states%'
ORDER BY location,date;

/*******************************************************************************/

--Countries with Highest Infected Percentage
SELECT Location,continent,MAX(total_cases) AS Infected,population,
MAX(total_cases*100.00/population) AS InfectedPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is NOT NULL
GROUP BY continent,Location,population
ORDER BY InfectedPercentage DESC;

/*****************************************************************************/

--Countries with Highest Death Percentage

SELECT Location,MAX(total_deaths) AS DeathCount,
MAX(total_deaths*100.00/population) AS DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY DeathPercentage DESC;

/*******************************************************************************/
-- Death Count of continents vs population

SELECT location,MAX(total_deaths) AS DeathCount,
MAX(total_deaths*100.00/population) AS DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is NULL AND location NOT LIKE '%income'
GROUP BY location
ORDER BY DeathPercentage DESC;

/***************************************************************************************/
--Global Numbers -> Death Percentage per day all over world

SELECT SUM(new_cases) as TotalCases,SUM(new_deaths) AS TotalDeaths
,SUM(new_deaths)*100.00/SUM(new_cases) AS InfectedDeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is NOT NULL;


SELECT location,population,total_cases,total_deaths,
--total_deaths*100.00/total_cases as InfecteddeathPercentage,
total_cases*100.00/population as worlddeathpercentage
FROM PortfolioProject..CovidDeaths 
WHERE location='world' and date='2023-02-10 00:00:00.000';

/*********************************************************************************************/
--Covid Vaccinations-> total populations vs Vaccinated

SELECT cdea.continent,cdea.location,cdea.date,cdea.population,cvac.new_vaccinations,
SUM(cvac.new_vaccinations) OVER (PARTITION BY cdea.location ORDER BY cdea.location,cdea.Date) 
AS vaccinations_till_date
FROM PortfolioProject..CovidDeaths cdea
JOIN PortfolioProject..CovidVaccinations cvac
ON cdea.location=cvac.location and cdea.date=cvac.date
WHERE cdea.continent IS NOT NULL 
ORDER BY cdea.location,cdea.date

/*************************************************************************************************/

-- Vaccinated Percentage

WITH cte_vaccinated_percentage(location,continent,date,population,
new_vaccinations,vaccinations_till_date)
AS ( 
SELECT cdea.location,cdea.continent,cdea.date,cdea.population,cvac.new_vaccinations,
SUM(cvac.new_vaccinations) OVER (PARTITION BY cdea.location ORDER BY cdea.location,cdea.Date) 
AS vaccinations_till_date
FROM PortfolioProject..CovidDeaths cdea
JOIN PortfolioProject..CovidVaccinations cvac
ON cdea.location=cvac.location and cdea.date=cvac.date
WHERE cdea.continent IS NOT NULL)
SELECT *,(vaccinations_till_date*100.00)/population AS vaccinated_percentgae FROM cte_vaccinated_percentage

--Using Temp tables

DROP TABLE IF EXISTS #percentage_population_vaccinated

CREATE TABLE #percentage_population_vaccinated(
location nvarchar(100),continent nvarchar(100),Date datetime,
population numeric,new_vaccinations numeric,vaccinations_till_date numeric)

INSERT INTO #percentage_population_vaccinated
SELECT cdea.location,cdea.continent,cdea.date,cdea.population,cvac.new_vaccinations,
SUM(cvac.new_vaccinations) OVER (PARTITION BY cdea.location ORDER BY cdea.location,cdea.Date) 
AS vaccinations_till_date
FROM PortfolioProject..CovidDeaths cdea
JOIN PortfolioProject..CovidVaccinations cvac
ON cdea.location=cvac.location and cdea.date=cvac.date
WHERE cdea.continent IS NOT NULL
SELECT *,(vaccinations_till_date*100.00/population) AS vaccinated_percentage 
FROM #percentage_population_vaccinated

/*******************************************************************************************/
-- Creating View for vaccinations_till_date
SELECT cdea.location,cdea.continent,cdea.date,cdea.population,cvac.new_vaccinations,
SUM(cvac.new_vaccinations) OVER (PARTITION BY cdea.location ORDER BY cdea.location,cdea.Date) 
AS vaccinations_till_date
FROM PortfolioProject..CovidDeaths cdea
JOIN PortfolioProject..CovidVaccinations cvac
ON cdea.location=cvac.location and cdea.date=cvac.date
WHERE cdea.continent IS NOT NULL
