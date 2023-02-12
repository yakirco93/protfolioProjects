Use ProtfolioProject
select location, date, total_cases,new_cases,  total_deaths, population 
from CovidDeaths
order by 1,2

--Total cases vs total deaths

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage, population 
from CovidDeaths
where location like '%states'
order by 1,2
-- Percentage of population got Covid:
select location, date, total_cases, population ,(total_cases/population)*100 as PercentageOfCovid
from CovidDeaths
where location like '%states'
order by 1,2

-- Contries with Highest infection rate compard to population:
select location, population , MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as PercentageOfCovid
from CovidDeaths
group by location, population
order by PercentageOfCovid desc


-- Countries with the Highest Death count per population
select location, population , MAX(cast(total_deaths as int)) as TotalDeathsCount , MAX((cast(total_deaths as int)/population))*100 as HighDeathPercentage
from CovidDeaths
where continent is not null
group by location, population
order by HighDeathPercentage desc

-- By Continent
select location,  MAX(cast(total_deaths as int)) as TotalDeathsCount , MAX((cast(total_deaths as int)/population))*100 as HighDeathPercentage
from CovidDeaths
where continent is null
group by location
order by HighDeathPercentage desc

-- Global Numbers
select  sum(new_cases) as 'total cases' ,sum(cast(new_deaths as int)) as 'total death', SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date

--TTotal population vs vaccinations
select de.continent, de.location, de.date, de.population,va.new_vaccinations
, SUM(cast (new_vaccinations as bigint)) over (partition by de.location order by de.location , de.date) as RollingPeopleVaccinated
from CovidDeaths de
JOIN CovidVaccianations va
on de.date= va.date and de.location=va.location
where de.continent is not null
order by 2,3
 
--USE CTE
with PopVsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated) as
(
select de.continent, de.location, de.date, de.population,va.new_vaccinations
, SUM(cast (new_vaccinations as bigint)) over (partition by de.location order by de.location , de.date) as RollingPeopleVaccinated
from CovidDeaths de
JOIN CovidVaccianations va
on de.date= va.date and de.location=va.location
where de.continent is not null
)
select * , (RollingPeopleVaccinated/population)*100 as pre
from PopVsVac

--Temp table
DROP Table if exists  #PrecentPopulationVaccinated
Create Table #PrecentPopulationVaccinated
 (
 continent nvarchar (255),
 location nvarchar (255), 
 date datetime, 
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric) 

 Insert into #PrecentPopulationVaccinated

select de.continent, de.location, de.date, de.population,va.new_vaccinations
, SUM(cast (new_vaccinations as bigint)) over (partition by de.location order by de.location , de.date) as RollingPeopleVaccinated
from CovidDeaths de
JOIN CovidVaccianations va
on de.date= va.date and de.location=va.location
where de.continent is not null

select * , (RollingPeopleVaccinated/population)*100 as pre
from #PrecentPopulationVaccinated

--Creating view to stoe data later visualizations

Create View PrecentPopulationVaccinated as
select de.continent, de.location, de.date, de.population,va.new_vaccinations
, SUM(cast (new_vaccinations as bigint)) over (partition by de.location order by de.location , de.date) as RollingPeopleVaccinated
from CovidDeaths de
JOIN CovidVaccianations va
on de.date= va.date and de.location=va.location
where de.continent is not null
