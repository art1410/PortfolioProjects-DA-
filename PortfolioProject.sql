SELECT * FROM ProjectPortfolio.dbo.CovidDeaths WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * FROM ProjectPortfolio.dbo.CovidVaccinations 
ORDER BY 3,4

SELECT DEATHS.location,DEATHS.date,total_cases,new_cases,total_deaths,population
FROM ProjectPortfolio.dbo.CovidDeaths AS DEATHS
JOIN ProjectPortfolio.dbo.CovidVaccinations AS Vac
ON DEATHS.iso_code = Vac.iso_code

--Looking at Total cases vs Total Deaths.
--Shows likelihood of dying if you contract covid in your country

SELECT
    DEATHS.location,
    DEATHS.date,
    CONVERT(FLOAT, total_cases) AS total_cases_numeric,
    CONVERT(FLOAT, total_deaths) AS total_deaths_numeric,
    (CONVERT(FLOAT, total_deaths) / CONVERT(FLOAT, total_cases)) * 100 AS DeathPercentage
FROM ProjectPortfolio.dbo.CovidDeaths AS DEATHS
JOIN ProjectPortfolio.dbo.CovidVaccinations AS Vac
ON DEATHS.iso_code = Vac.iso_code
WHERE DEATHS.location = 'INDIA' AND total_deaths IS NOT NULL
ORDER BY DEATHS.location,DEATHS.date

--Total cases vs population 
--Shows what percentage of people got covid
SELECT DEATH.location,DEATH.date,Population,total_cases,(total_cases/population)*100 as DeathPercentage
FROM CovidDeaths AS DEATH
Join CovidVaccinations AS Vacc
ON DEATH.iso_code = Vacc.iso_code
--WHERE DEATH.location = 'India'


--Looking at Contries with Highest Infection rate compared to population


SELECT DEATH.location,Population,Max(total_cases) AS HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths AS DEATH
Join CovidVaccinations AS Vacc
ON DEATH.iso_code = Vacc.iso_code
--WHERE DEATH.location = 'India'
Group by DEATH.location,Population
ORDER BY 1,2 DESC

--Show Countries with highest Death count per population

SELECT DEATH.location,Max(total_deaths) AS TotalDeathCount
FROM CovidDeaths AS DEATH
Join CovidVaccinations AS Vacc
ON DEATH.iso_code = Vacc.iso_code
--WHERE DEATH.location = 'India'
GROUP BY DEATH.location
ORDER BY TotalDeathCount DESC

--Breaking things down by continents 

SELECT DEATH.continent,Max(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths AS DEATH
Join CovidVaccinations AS Vacc
ON DEATH.iso_code = Vacc.iso_code
--WHERE DEATH.location = 'India'
WHERE DEATH.continent is not null
GROUP BY DEATH.continent
ORDER BY TotalDeathCount DESC

--Global Numbers
Select SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage  
FROM CovidDeaths 
where continent is not null
order by 1,2
--including date for above case
SELECT date,SUM(new_cases) as Total_Cases,SUM(new_deaths) as Total_Deaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE SUM(cast(new_deaths as int)) / NULLIF(SUM(new_cases), 0) * 100
    END as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--LOOKING at Total Population vs Total Vaccinations
SELECT DEATH.continent,DEATH.location,DEATH.date,VACC.new_vaccinations,SUM(Convert(bigint,VACC.new_vaccinations)) 
OVER (partition by DEATH.location ORDER BY DEATH.location,DEATH.date) as RollingpeopleVaccinations
FROM CovidDeaths as DEATH 
JOIN CovidVaccinations as VACC
	ON DEATH.location = VACC.location
	and DEATH.date = VACC.date
WHERE DEATH.continent is not null 
order by 2,3

--Using CTE
WITH POPvsVACC (contintent,location,date,POPULATION,New_Vaccination,RollingpeopleVaccinations)
As 
(
SELECT DEATH.continent,DEATH.location,DEATH.date,VACC.population,VACC.new_vaccinations,SUM(Convert(bigint,VACC.new_vaccinations)) 
OVER (partition by DEATH.location ORDER BY DEATH.location,DEATH.date) as RollingpeopleVaccinations
FROM CovidDeaths as DEATH 
JOIN CovidVaccinations as VACC
	ON DEATH.location = VACC.location
	and DEATH.date = VACC.date
WHERE DEATH.continent is not null 
)
SELECT *,(RollingpeopleVaccinations/POPULATION)*100  as PopulationVaccinated
FROM POPvsVACC

--Creating View to store data for visualization

Create view PercentPopulationVaccinated as
SELECT DEATH.continent,DEATH.location,DEATH.date,VACC.population,VACC.new_vaccinations,SUM(Convert(bigint,VACC.new_vaccinations)) 
OVER (partition by DEATH.location ORDER BY DEATH.location,DEATH.date) as RollingpeopleVaccinations
FROM CovidDeaths as DEATH 
JOIN CovidVaccinations as VACC
	ON DEATH.location = VACC.location
	and DEATH.date = VACC.date
WHERE DEATH.continent is not null