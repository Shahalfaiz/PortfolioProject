select *
from SQLproject..covidDeath$
where continent is not null
order by 3,4 

--select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from SQLproject..covidDeath$
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from SQLproject..covidDeath$
where location like '%state%'
and where continent is not null
order by 1,2

--loking total case vs population
--shows what percentage of population got covid

select location, date,  population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from SQLproject..covidDeath$
--where location like '%state%'
where continent is not null
order by 1,2


--looking at countries with hightest Infection Rate compared to Population

select location,  population, max(total_cases) as HighestInfectionCount ,
max((total_cases/population))*100 as PercentagePopulationInfected
from SQLproject..covidDeath$
--where location like '%state%'
where continent is not null
group by location, population
order by  PercentagePopulationInfected desc

--LET'S BREAK THINKGS DOWN BY CONTINENT

select continent,  max(cast(total_deaths as int)) as TotalDeathCount
from SQLproject..covidDeath$
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount  desc

--showing contintents with the highest death count per population

select continent,  max(cast(total_deaths as int)) as TotalDeathCount
from SQLproject..covidDeath$
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount  desc

--GLOBAL NUMBERS

select sum(new_cases) as total_cases,sum(cast( new_deaths as int)) as total_death , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from SQLproject..covidDeath$
--where location like '%state%'
where continent is not null
--group by date
order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location) as RollingPeipleVaccinated
--,(RollingPeipleVaccinated/population)*100
from SQLproject..covidDeath$ dea
join SQLproject..covidVaccined vac
  on dea.location = vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac (continent , location ,date , population , new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location) as RollingPeipleVaccinated
--,(RollingPeipleVaccinated/population)*100
from SQLproject..covidDeath$ dea
join SQLproject..covidVaccined vac
  on dea.location = vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100
from PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinted
create Table #PercentPopulationVaccinted
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinted
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location) as RollingPeopleVaccinated
--,(RollingPeipleVaccinated/population)*100
from SQLproject..covidDeath$ dea
join SQLproject..covidVaccined vac
  on dea.location = vac.location
  and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinted


--creating view to store data for later visualizations

Create View PercentPopulationVaccinted as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location) as RollingPeopleVaccinated
--,(RollingPeipleVaccinated/population)*100
from SQLproject..covidDeath$ dea
join SQLproject..covidVaccined vac
  on dea.location = vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinted












