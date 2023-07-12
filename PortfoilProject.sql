SELECT *
FROM PortfoiloProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfoiloProject..CovidVaccinations
ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases,new_cases, total_deaths,population
FROM PortfoiloProject..CovidDeaths
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS DECIMAL)/ CAST(total_cases AS DECIMAL)*100 AS DeathPercentage
FROM PortfoiloProject..CovidDeaths
ORDER BY 1,2

-- Looking A Total Cases Vs Total Deaths
-- Shows Likelihood Of Dying If You Contract COVID In Your Country
SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS DECIMAL)/ CAST(total_cases AS DECIMAL)*100 AS DeathPercentage
FROM PortfoiloProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking A Total Cases Vs Population
-- Shows What Percentage Of Population Got COVID
SELECT location, date,population, total_cases, CAST(total_cases AS DECIMAL)/ CAST(population AS DECIMAL)*100 AS PercentPopulationInfected
FROM PortfoiloProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS DECIMAL)/ CAST(population AS DECIMAL))*100 AS PercentPopulationInfected
FROM PortfoiloProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY 1,2

SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS DECIMAL)/ CAST(population AS DECIMAL))*100 AS PercentPopulationInfected
FROM PortfoiloProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Looking At Total Population Vs Vaccination

SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS DECIMAL)) OVER (PARTITION BY dea.location)
FROM PortfoiloProject..CovidDeaths dea
JOIN PortfoiloProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(DECIMAL, vac.new_vaccinations)) OVER (PARTITION BY dea.location)
FROM PortfoiloProject..CovidDeaths dea
JOIN PortfoiloProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

---USE CTE

With PopvsVac (Continent, Location, Population, NewVaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(DECIMAL, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfoiloProject..CovidDeaths dea
JOIN PortfoiloProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(DECIMAL, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfoiloProject..CovidDeaths dea
JOIN PortfoiloProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--- Creating View To Store Data For Later Visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(DECIMAL, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfoiloProject..CovidDeaths dea
JOIN PortfoiloProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated