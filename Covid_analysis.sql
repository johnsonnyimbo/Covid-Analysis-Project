select * from covid_deaths
	order by 1,2;

  --rates of death per infection 

	select Location,date,total_cases,new_cases,
	total_deaths,(total_deaths/total_cases)*100 as DeathPercantage from covid_deaths
	where continent is not null
	order by 1,6 desc;

	--infection rates
	select Location,date,total_cases,Population
	,(total_cases::numeric/population)*100 as InfectionPercantage from covid_deaths
	where continent is null
	order by 1,2 desc;

	--highest infection rate vs population per country
	select Location,population,max(total_cases)as highestInfectionCount,
	    max((total_cases::numeric/population)*100)as percentageInfected
	 from covid_deaths 
	 where continent is not null
	 group by Location,population
	 order by percentageInfected desc;
	 
--- countries highest death count per continent

select Location, max(total_deaths)as HighestDeathCounts
from covid_deaths	
where continent is not null
group by location
order by HighestDeathCounts desc;

---GLOBAL BREAKDOWN by day
 Select date,sum(new_cases)as totalcases,sum(new_deaths::numeric)as totaldeaths,
 		(sum(new_deaths::numeric)/sum(new_cases)*100)as deathPercentage
from covid_deaths
group by date
HAVING SUM(new_cases) > 0
order by 1,2;

/*select * 
 from covid_deaths dea
 join covid_vaccinations vac
 on dea.location = vac.location 
  AND 	dea.date =vac.date */
  
-----populations vs vaccinations

  select dea.continent, dea.location,dea.date,dea.population,
  Sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)as dailytotalvaccination
 from covid_deaths dea
 join covid_vaccinations vac
 on dea.location = vac.location 
  AND 	dea.date =vac.date
  where dea.continent is not null
  order by 2,3;

  ----percentage of the population that is vaccinated
  with PopVsVac(continen,location,date,population,new_vaccinations,dailytotalvaccination)
  as( select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
  Sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)as dailytotalvaccination
 from covid_deaths dea
 join covid_vaccinations vac
 on dea.location = vac.location 
  AND 	dea.date =vac.date
  where dea.continent is not null)

  select * ,(dailytotalvaccination/population)as percentageVaccinated from PopVsVac;
  
  ---- creating views for data visualization -----
  create view percentagePopulationVaccinated as
  select dea.continent, dea.location,dea.date,dea.population,
  Sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)as dailytotalvaccination
 from covid_deaths dea
 join covid_vaccinations vac
 on dea.location = vac.location 
  AND 	dea.date =vac.date
  where dea.continent is not null

  create view dailydeathPercentage as 
   Select date,sum(new_cases)as totalcases,sum(new_deaths::numeric)as totaldeaths,
 		(sum(new_deaths::numeric)/sum(new_cases)*100)as deathPercentage
from covid_deaths
group by date
HAVING SUM(new_cases) > 0

create view highestDeathPerContinent as
select Location, max(total_deaths)as HighestDeathCounts
from covid_deaths	
where continent is not null
group by location

create view DeathPerInfectionRates as
select Location, max(total_deaths)as HighestDeathCounts
from covid_deaths	
where continent is not null
group by location