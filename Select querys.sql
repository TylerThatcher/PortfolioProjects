-- Total Cases vs Total Deaths
-- Calculates death percentage (roughly)
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from CovidDeaths
where continent is not null
order by location,date

-- Total Cases vs Population
-- Shows percentage of population with Covid
select location, date, Population, total_cases,(total_cases/population)*100 as infection_percentage
from CovidDeaths
where continent is not null
order by location,date

-- Countries with Highest Infection Rate compared to population
select location, Population, MAX(total_cases) as highest_infectioncount,MAX((total_cases/population))*100 as infection_percentage
from CovidDeaths
where continent is not null
Group by population, location
order by infection_percentage desc

-- Countries with Highest Death Rate compared to population
select location, Population, MAX(cast(total_deaths as int)) as total_deathcount,MAX((total_deaths/population))*100 as death_percentage
from CovidDeaths
where continent is not null
Group by population, location
order by total_deathcount desc

-- Continents with the highest death count
select location,  MAX(cast(total_deaths as int)) as total_deathcount,MAX((total_deaths/population))*100 as death_percentage
from CovidDeaths
where continent is null
Group by location
order by total_deathcount desc

-- Global Numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from CovidDeaths
where continent is not null
order by 1,2

--Total Population vs Vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations as bigint)) OVER (partition by d.location order by d.location, d.date) as people_vaccinated
from CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by 2,3

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, people_vaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations as bigint)) OVER (partition by d.location order by d.location, d.date) as people_vaccinated
from CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)
Select *,(people_vaccinated/Population)*100 as percentage_vaccinated
from PopvsVac

-- View for data later visuals

Create View PercentagePopulationVaccinated as 
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, people_vaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations as bigint)) OVER (partition by d.location order by d.location, d.date) as people_vaccinated
from CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)
Select *,(people_vaccinated/Population)*100 as percentage_vaccinated
from PopvsVac

select * from PercentagePopulationVaccinated