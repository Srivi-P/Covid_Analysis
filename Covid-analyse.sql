u# Covid_Analysis
SELECT  * FROM `sql-learning-test.Covid_Analyze.Covid_Vaccine` 
where continent is not null
order by 3,4;

SELECT * FROM sql-learning-test.Covid_Analyze.Covid_Death
where continent is not null
ORDER BY 3,4;

-- select data that we are using 

select location,date,total_cases,new_cases,total_deaths,population 
from sql-learning-test.Covid_Analyze.Covid_Death
order by 1,2;

-- finding total cases vs total deaths 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage 
from sql-learning-test.Covid_Analyze.Covid_Death
where continent is not null
order by 1,2;

-- finding total cases vs. population United States
-- shows infected population percentage 
select location,date,total_cases, population,(total_cases/population)*100 as population_percentage 
from sql-learning-test.Covid_Analyze.Covid_Death
--where location like "%States"
order by 1,2;

-- finding the highest infection rate of a country comparing with its population

select location,population,max(total_cases) as Highest_infection_count,max((total_deaths/total_cases)*100) as Percentagepupulationinfected
from sql-learning-test.Covid_Analyze.Covid_Death
where continent is not null
group by location,population
order by Percentagepupulationinfected desc;

--finding highest deaths count per population by country 
select location,max(total_deaths) as Highest_death_count,
from sql-learning-test.Covid_Analyze.Covid_Death
where continent is not null
group by location
order by Highest_death_count desc;

-- highest deaths by continets 
--Location wise
select location,max(total_deaths) as Highest_death_count
from sql-learning-test.Covid_Analyze.Covid_Death
where continent is null
group by location
order by Highest_death_count desc;

--continent wise
select continent,max(total_deaths) as Highest_death_count
from sql-learning-test.Covid_Analyze.Covid_Death
where continent is not null
group by continent
order by Highest_death_count desc;

-- Highest deaths by continent per population- VisualView
select continent,max(total_deaths) as Highest_death_count
from sql-learning-test.Covid_Analyze.Covid_Death
where continent is null
group by continent
order by Highest_death_count desc;

--GLOBAL NUMBERS

select date,sum(new_cases) as tot_Newcases, sum(new_deaths)as Tot_Newdeaths,
from sql-learning-test.Covid_Analyze.Covid_Death
where continent is not null
group by date
order by 1,2;

--New Death percentage
create or replace view sql-learning-test.dataset.DeathPercentage as
(select sum(new_cases) as tot_Newcases, sum(new_deaths)as Tot_Newdeaths,(sum(new_deaths)/sum(new_cases)*100) as New_deathPercentage
from sql-learning-test.Covid_Analyze.Covid_Death
where continent is not null);

select * from sql-learning-test.Covid_Analyze.Covid_Vaccine;

--Joining two tables 

select * from
sql-learning-test.Covid_Analyze.Covid_Death as D
join sql-learning-test.Covid_Analyze.Covid_Vaccine as V
on D.location=V.location and D.date=V.date;

--Finding total population vs total vaccination
select D.continent,D.location,D.date,D.population,V.new_vaccinations
from sql-learning-test.Covid_Analyze.Covid_Death as D
join sql-learning-test.Covid_Analyze.Covid_Vaccine as V
on D.location=V.location and D.date=V.date
where D.continent is not null
order by 2,3;

--finding a running total of total new vaccinations 
select D.continent,D.location,D.date,D.population,V.new_vaccinations,
sum(V.new_vaccinations) over (partition by D.location order by D.location,D.date) as running_tot
from sql-learning-test.Covid_Analyze.Covid_Death as D
join sql-learning-test.Covid_Analyze.Covid_Vaccine as V
on D.location=V.location and D.date=V.date
where D.continent is not null
order by 2,3; 

--Using CTE (common table expressions)
WITH PopVsVac 
--(Continent,Location,Population,New_vaccinations,RunningTotal)
as
  (
  select D.continent,D.location,D.date,D.population,V.new_vaccinations,
  sum(V.new_vaccinations) over (partition by D.location order by D.location,D.date) as running_tot
  from sql-learning-test.Covid_Analyze.Covid_Death as D
  join sql-learning-test.Covid_Analyze.Covid_Vaccine as V
  on D.location=V.location and D.date=V.date
  where D.continent is not null
)
select *, ((running_tot/population)*100) as vaccinatedPercentage from PopvsVac
order by vaccinatedPercentage desc;



--*** Creating view for visualization

--total cases vs total deaths
create or replace view sql-learning-test.dataset.TotCaseVsTotDeaths as
(
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage 
from sql-learning-test.Covid_Analyze.Covid_Death
where continent is not null
order by 1,2);

--Death Percentage
create or replace view sql-learning-test.dataset.DeathPercentage as
(select sum(new_cases) as tot_Newcases, sum(new_deaths)as Tot_Newdeaths,(sum(new_deaths)/sum(new_cases)*100) as New_deathPercentage
from sql-learning-test.Covid_Analyze.Covid_Death
where continent is not null);

-- finding highest infection rate of country comapring with its population
create or replace view sql-learning-test.dataset.HighestInfectionRate as
(
select location,population,max(total_cases) as Highest_infection_count,max((total_deaths/total_cases)*100) as Percentagepupulationinfected
from sql-learning-test.Covid_Analyze.Covid_Death
where continent is not null
group by location,population
order by Percentagepupulationinfected desc);

--finding highest deaths count per population by country 
create or replace view sql-learning-test.dataset.HighestDeathPerCoutry as
(
select location,max(total_deaths) as Highest_death_count,
from sql-learning-test.Covid_Analyze.Covid_Death
where continent is not null
group by location
order by Highest_death_count desc);

--Percent Population vaccinated
create view sql-learning-test.dataset.PercentPopulationvacinated as
(
select D.continent,D.location,D.date,D.population,V.new_vaccinations,
  sum(V.new_vaccinations) over (partition by D.location order by D.location,D.date) as running_tot
  from sql-learning-test.Covid_Analyze.Covid_Death as D
  join sql-learning-test.Covid_Analyze.Covid_Vaccine as V
  on D.location=V.location and D.date=V.date
  where D.continent is not null);

