--Checking tables
SELECT * 
FROM Portfolio..CovidDeaths;

SELECT *
FROM Portfolio..CovidVaccinations;


--**********************************DATA EXPLORATION*****************************


--Selecting the data we are goign to be using:

SELECT location, date, ROUND(total_cases,0), new_cases, ROUND(total_deaths,0), population
FROM Portfolio..CovidDeaths
WHERE location = 'Tunisia'
ORDER BY 2,3 ASC;

--total cases VS total deaths in Tunisia;
--likelihood of dying if you get covid in Tunisia at the time:
SELECT location, date, ROUND(total_cases,0) AS TotalCases, ROUND(total_deaths,0) AS TotalDeaths, ROUND(((total_deaths/total_cases)*100),2) AS DeathsPercentage
FROM Portfolio..CovidDeaths
WHERE location = 'Tunisia'
ORDER BY date;


--total cases VS population in Tunisia:
--Percentage of population that got infected by Covid 
SELECT location, date, ROUND(population,0) as Population, ROUND(total_cases,0) as TotalCases, ROUND(((total_cases/population)*100),2) AS InfectionPercentage
FROM Portfolio..CovidDeaths
WHERE location = 'Tunisia'
ORDER BY date ASC;

----------------DELETE EVERYTHING ABOUT THE TERRORISTS----------------
DELETE FROM Portfolio..CovidDeaths
WHERE location = 'Israel';

DELETE FROM Portfolio..CovidVaccinations
WHERE location = 'Israel';
----------------------------------------------------------------------

--Countries with highest infection rate compared to thier population:
SELECT location, population, MAX(ROUND(total_cases,0)) AS Highest_Infection_Count, MAX(ROUND(((total_cases/population)*100),2)) AS Percentage_of_Population_Infected
FROM Portfolio..CovidDeaths
GROUP BY location, population
ORDER BY Percentage_of_Population_Infected DESC;

--Countries with highest Death Count
SELECT location, MAX(ROUND(total_deaths,0)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
GROUP BY location
ORDER BY TotalDeathCount DESC;


--***By continent***
--Continents with highest Death Count
SELECT continent, MAX(ROUND(total_deaths,0)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--******Global Numbers*****
--Global death Percentage grouped by date
SELECT date, SUM(new_cases) AS Total_new_cases, SUM(new_deaths) AS total_new_deaths, ROUND(((SUM(total_deaths)/SUM(total_cases))*100),2) AS DeathPercentage
FROM Portfolio..CovidDeaths
GROUP BY date
ORDER BY 1,2;

--Looking at total population VS vaccinations:
SELECT dea.continent, dea.location, CAST(dea.date AS DATE) AS date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--**********************************
--Using CTE
--Population Vaccination Rate

WITH PopulationVaccinationRate (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinted)
AS
(
SELECT dea.continent, dea.location, CAST(dea.date AS DATE) AS date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinted/Population)*100 AS PopulationVaccinationPercentage
FROM PopulationVaccinationRate;
--WHERE location = 'Tunisia';

--*****************

-----TEMP TABLE-----

DROP TABLE IF EXISTS #PercentageOfPeopleVaccinated;
CREATE TABLE #PercentageOfPeopleVaccinated(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_people_vaccinated NUMERIC
)

INSERT INTO #PercentageOfPeopleVaccinated

SELECT dea.continent, dea.location, CAST(dea.date AS DATE) AS date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, ROUND(((rolling_people_vaccinated/population)*100),2) AS PopulationVaccinationPercentage
FROM #PercentageOfPeopleVaccinated;


----CREATING VIEWS FOR VISUALIZATIONS----------

--VIEW for Percentage of population already vaccinated:
CREATE VIEW PercentageOfPopulationVaccinate AS
SELECT dea.continent, dea.location, CAST(dea.date AS DATE) AS date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT * FROM PercentageOfPopulationVaccinated;

---VIEW for countries with highest death rate
CREATE VIEW CountriesWithHighestDeathRate AS
SELECT location, MAX(ROUND(total_deaths,0)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
GROUP BY location

---VIEW for continents wih highest infection rate:
CREATE VIEW ContinentsWithHighestInfectionRate AS
SELECT continent, MAX(ROUND(total_cases,0)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent



;
