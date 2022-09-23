Select *
From [Profolio Project]..CovidDeaths
Where continent is not null
order by 3,4




Select Location, date, total_cases, new_cases, total_deaths, population
From [Profolio Project]..CovidDeaths
Where continent is not null
order by 1,2


-- Total Cases Vs Total Deaths
--Presents the likelihood of dying if contracted covid in US
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Profolio Project]..CovidDeaths
Where Location like '%states%'
order by 1,2

---Total Cases vs Population
--Shows what percentage of the population infected with Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Profolio Project]..CovidDeaths
Where Location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Profolio Project]..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

-- Counrties with Highest Death Count per Population
Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From [Profolio Project]..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Continent with Highest Death Count per Population
Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From [Profolio Project]..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Profolio Project]..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
From [Profolio Project]..CovidDeaths dea
Join [Profolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
From [Profolio Project]..CovidDeaths dea
Join [Profolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
From [Profolio Project]..CovidDeaths dea
Join [Profolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to Store Data for Later Visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Profolio Project]..CovidDeaths dea
Join [Profolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From #PercentPopulationVaccinated