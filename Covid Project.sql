--SELECT *
--FROM CovidSQL..CovidDeaths$
--ORDER BY 3, 4

--SELECT *
--FROM CovidSQL..CovidVaccinations$
--ORDER BY 3, 4

/*
Isolate data
*/

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM CovidSQL..CovidDeaths$
--ORDER BY 1, 2

/*
Total Cases vs Total Deaths in the United States
*/

--ALTER TABLE CovidSQL..CovidDeaths$
--ALTER COLUMN total_deaths float

--CREATE VIEW TotalCasesvsTotalDeathsinUS AS

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
--FROM CovidSQL..CovidDeaths$
--WHERE location like '%United States' AND total_deaths IS NOT NULL
--ORDER BY 2

/*
Total Cases vs Population in the United Stats
*/

--CREATE VIEW TotalCasesvsPopulationinUS AS

--SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
--FROM CovidSQL..CovidDeaths$
--WHERE location like '%United States' AND total_deaths IS NOT NULL
--ORDER BY 2

/*
Countries with highest infection to population rate
*/

--ALTER TABLE CovidSQL..CovidDeaths$
--ALTER COLUMN total_cases float

--CREATE VIEW InfectiontoPopulationRate AS

--SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
--FROM CovidSQL..CovidDeaths$
--WHERE continent IS NOT NULL
--GROUP BY location, population
--ORDER BY 4 DESC

/*
Countries with highest Death Count per Population
*/

--CREATE VIEW DeathCountperPopula AS

--SELECT location, population, MAX(CAST(total_deaths AS int)) as TotalDeathCount
--FROM CovidSQL..CovidDeaths$
--WHERE continent IS NOT NULL
--GROUP BY location, population
--ORDER BY 3 DESC

-- Continents

--SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
--FROM CovidSQL..CovidDeaths$
--WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY 2 DESC

--CREATE VIEW TotalDeathsperContinent AS

--SELECT location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
--FROM CovidSQL..CovidDeaths$
--WHERE continent IS NULL AND location NOT LIKE '%income'
--GROUP BY location
--ORDER BY 2 DESC

--CREATE VIEW TotalDeathsperIncomeClass AS

--SELECT location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
--FROM CovidSQL..CovidDeaths$
--WHERE continent IS NULL AND location LIKE '%income'
--GROUP BY location
--ORDER BY 2 DESC

/*
Global Stats
*/

--CREATE VIEW TotalDeathsperNewCasesGlobal AS

--SELECT date, SUM(new_cases) AS TotalNew, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS GlobalDeathPercentage
--FROM CovidSQL..CovidDeaths$
--WHERE continent IS NOT NULL AND new_cases IS NOT NULL
--GROUP BY date
--ORDER BY 1

--CREATE VIEW TotalDeathsGlobally AS

--SELECT SUM(new_cases) AS TotalNew, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS GlobalDeathPercentage
--FROM CovidSQL..CovidDeaths$
--WHERE continent IS NOT NULL AND new_cases IS NOT NULL

/*
Total population vs Vaccinations per country
*/

--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--FROM CovidSQL..CovidDeaths$ dea
--JOIN CovidSQL..CovidVaccinations$ vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

--CREATE VIEW TotalVaccinatedtoDate AS

--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
--	AS TotalVaccinatedtoDate
--FROM CovidSQL..CovidDeaths$ dea
--JOIN CovidSQL..CovidVaccinations$ vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

--More Numbers

--WITH PopvsVac (continent, location, date, population, New_Vaccinations, TotalVaccinatedtoDate)
--AS (
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
--	AS TotalVaccinatedtoDate
--FROM CovidSQL..CovidDeaths$ dea
--JOIN CovidSQL..CovidVaccinations$ vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--)
--SELECT *, (TotalVaccinatedtoDate/population)*100
--FROM PopvsVac

--Different method

--DROP TABLE IF EXISTS #PercentVaccinated
--CREATE TABLE #PercentVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric,
--NewVaccinations numeric,
--TotalVaccinatedtoDate numeric
--)
--INSERT INTO #PercentVaccinated
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
--	AS TotalVaccinatedtoDate
--FROM CovidSQL..CovidDeaths$ dea
--JOIN CovidSQL..CovidVaccinations$ vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

--SELECT *, (TotalVaccinatedtoDate/population)*100
--FROM #PercentVaccinated

/*
Create view for visualizations
*/

--CREATE VIEW PercentPopulationVaccinated AS
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
--	AS TotalVaccinatedtoDate
--FROM CovidSQL..CovidDeaths$ dea
--JOIN CovidSQL..CovidVaccinations$ vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL