

--Select Data that we are going to be using
Select [location],date, [total_cases],[new_cases],[total_deaths],[population]
from CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths Globally
Select [location],date, [total_cases],[total_deaths],round((total_deaths/total_cases)*100, 2) as PercentDeath
from CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths in the United States
Select [location],date, [total_cases],[total_deaths],round((total_deaths/total_cases)*100, 2) as PercentDeath
from CovidDeaths
where location like '%States%'
order by 2
desc


--Looking at the total cases vs Population
Select [location],date,population, [total_cases],round((total_cases/population)*100, 2) as PercentIntectedPopulation
from CovidDeaths
where location like '%States%'
order by 1,2



----Looking at Countries with highes infection rate as compaired to population
Select [location],[population], max([total_cases]),round(max((total_cases/population)*100), 2) as PercentIntectedPopulation
from CovidDeaths
group by location,population
order by 4
desc


----Looking at Countries with highest death count as compaired to population
Select [location], max([total_deaths]) as TotalDeathCount
from CovidDeaths
group by location 
order by 2 desc



--
alter table [dbo].[CovidDeaths]
alter column[total_deaths] float



--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent Is not Null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

--Looking at the total cases vs Population
Select  sum(new_cases) as total_cases, sum(cast(new_deaths as float)) as total_deaths, round(sum(cast(new_deaths as float))/ SUM(cast(new_cases as float))*100, 2) as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2

--- lOOKING AT TOTAL POPULATION VS VACCINATION
SELECT cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,Sum(cast(cv.new_vaccinations as float) )over (partition by cd.location order by cd.location, cd.date)as RollingPeopleVcacinated
from [dbo].[CovidDeaths] AS cd
	JOIN [dbo].[CovidVaccinations] AS cv
	ON CD.location= Cv.location
	AND CD.DATE = Cv.date
where cd.continent is not null
order by 1,2,3

--USE CTE
WITH POPVSVAC (continent,location,date,population,new_vaccinations,RollingPeopleVcacinated)
as
(
SELECT cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,Sum(cast(cv.new_vaccinations as float) )over (partition by cd.location order by cd.location, cd.date)as RollingPeopleVcacinated
from [dbo].[CovidDeaths] AS cd
	JOIN [dbo].[CovidVaccinations] AS cv
	ON CD.location= Cv.location
	AND CD.DATE = Cv.date
where cd.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVcacinated/population)*100
from POPVSVAC

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVcacinated numeric
)
insert into #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,Sum(cast(cv.new_vaccinations as float) )over (partition by cd.location order by cd.location, cd.date)as RollingPeopleVcacinated
from [dbo].[CovidDeaths] AS cd
	JOIN [dbo].[CovidVaccinations] AS cv
	ON CD.location= Cv.location
	AND CD.DATE = Cv.date
where cd.continent is not null
--order by 2,3

select *, (RollingPeopleVcacinated/population)*100
from #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE view  PercentPopulationVaccinated as
SELECT cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,Sum(cast(cv.new_vaccinations as float) )over (partition by cd.location order by cd.location, cd.date)as RollingPeopleVcacinated
from [dbo].[CovidDeaths] AS cd
	JOIN [dbo].[CovidVaccinations] AS cv
	ON CD.location= Cv.location
	AND CD.DATE = Cv.date
where cd.continent is not null
--order by 2,3
