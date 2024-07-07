SELECT * FROM CovidProject.CovidDeaths;

#Delete from CovidProject.CovidDeaths limit 1;

select location, date, total_cases, new_cases, total_deaths, population
from CovidProject.CovidDeaths
order by 1,2;

-- Death Rate
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidProject.CovidDeaths
order by 1,2;

-- likelihood of dying if you track your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidProject.CovidDeaths
where location like '%kong' 
order by 1,2;

-- what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as death_percentage
from CovidProject.CovidDeaths
-- where location like '%china' 
order by 1,2;

-- what country has highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from CovidProject.CovidDeaths
group by location, population
order by PercentPopulationInfected desc;

-- what country has highest death rate per population
-- sum(cast(total_deaths as int))  
select location, population, MAX(total_deaths) as TotalDeathCount, max(total_deaths/population)*100 as PercentPopulationDeath
from CovidProject.CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc;

-- break it down by continent
select continent, MAX(total_deaths) as TotalDeathCount
from CovidProject.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- showing continents with highest death count per population
select continent, MAX(total_deaths/population) as TotalDeathCount
from CovidProject.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;
-- compare death rate of different continent
select continent, sum(total_deaths)/sum(population) as TotalDeathCount
from CovidProject.CovidDeaths
group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

select sum(new_cases_smoothed) total_cases, sum(new_deaths_smoothed) total_deaths, sum(new_deaths_smoothed)/sum(new_cases_smoothed)*100 as death_percentage
from CovidProject.CovidDeaths
-- group by date 
order by 1,2;


-- looking at total population vs vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingVaccination
from CovidProject.CovidDeaths cd
join CovidProject.CovidVaccinations cv
on cd.location = cv.location
and cd.date=cv.date
order by 2,3;

-- use CET
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingVaccination
from CovidProject.CovidDeaths cd
join CovidProject.CovidVaccinations cv
on cd.location = cv.location
and cd.date=cv.date
order by 2,3;

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccination)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingVaccination
from CovidProject.CovidDeaths cd
join CovidProject.CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date
)
Select *, (RollingVaccination/Population)*100
from PopvsVac;

-- Temp Table
DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
);

Insert Into PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidProject.CovidDeaths cd
join CovidProject.CovidVaccinations cv
on cd.location = cv.location and cd.date=cv.date;

Select *, (RollingPeopleVaccinated/Population)*100
from PercentPopulationVaccinated;


-- Create View to store data for visulization
Create View PercentPopulationVaccinated as 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidProject.CovidDeaths cd
join CovidProject.CovidVaccinations cv
on cd.locatiopercentpopulationvaccinatedn = cv.location and cd.date=cv.date
order by 2,3;

Select *
from PercentPopulationVaccinated;