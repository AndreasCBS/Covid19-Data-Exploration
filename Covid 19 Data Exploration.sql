/*
Covid 19 Data Exploration 
*/

Select *
From Project..CovidDeaths

Select *
From Project..CovidVaccinations

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Project..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project..CovidDeaths
Where Location like 'Indonesia' and Continent is not Null
Order By 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, total_cases, Population, (total_cases/Population)*100 as PercentPopulationInfected
From Project..CovidDeaths
Where Location like 'Indonesia' and Continent is not Null
Order By 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestCases,  MAX((total_cases/Population))*100 as PercentPopulationInfected
From Project..CovidDeaths
Where Continent is not Null
Group By Location, Population
Order By PercentPopulationInfected Desc

-- Countries with Highest Death Count per Population
Select Location, MAX(total_deaths) as TotalDeaths
From Project..CovidDeaths
Where Continent is not Null
Group By Location
Order By TotalDeaths Desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select Continent, MAX(total_deaths) as TotalDeaths
From Project..CovidDeaths
Where Continent is not Null
Group By Continent
Order By TotalDeaths Desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From Project..CovidDeaths
where continent is not null 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- Using CTE to perform Calculation on Partition By in previous query
WITH CTE_Vac (continent, location, date, population, new_vaccinations, TotalVaccinations) 
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition By dea.Location Order by dea.location,dea.date) as TotalVaccinations
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
)
Select *, (TotalVaccinations/population)*100 as VaccinationsPercentage
From CTE_Vac

-- Using Temp Table to perform Calculation on Partition By in previous query
Drop Table if Exists #PercentPopulationVaccinations
Create table #PercentPopulationVaccinations
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population int,
new_vaccinations int,
TotalVaccinations int
)

Insert Into #PercentPopulationVaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition By dea.Location Order by dea.location,dea.date) as TotalVaccinations
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null


Select *, (TotalVaccinations/population)*100 as VaccinationsPercentage
From #PercentPopulationVaccinations

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
From Project..PercentPopulationVaccinated
