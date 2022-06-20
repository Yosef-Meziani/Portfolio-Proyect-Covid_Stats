Select *
from PortfolioProyect ..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProyect ..CovidVaccinations
--order by 3,4

-- Seleccionando los datos para trabajar 


Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProyect ..CovidDeaths
where continent is not null
order by 1,2

-- Total de casos VS total de muertes WW
-- Filtrando por muertes e infectados en Europa 


Select location, date, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPorcentage
from PortfolioProyect ..CovidDeaths
where location like '%Europe%'
and continent is not null
order by 1,2


-- Total de casos VS población total WW
-- Filtrando  infectados en Europa sobre población total


Select location, date, population, new_cases,total_cases, (total_cases/population)*100 as InfectionPorcentage
from PortfolioProyect ..CovidDeaths
where location like '%europe%'
and continent is not null
order by 1,2


-- PAÍSES QUE TIENEN UN % DE INFECCIÓN MÁS ALTO RESPECTO SU POBLACIÓN

Select location, population, MAX(total_cases) as HiguestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProyect ..CovidDeaths
--where location like '%europe%'
group by location, population 
order by PercentPopulationInfected desc


-- Países con mas muertes por poblacion

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProyect ..CovidDeaths
--where location like '%europe%'
Where continent is not null
group by location
order by TotalDeathCount desc


-- Desglosados por Continentes
-- Continentes con más muertes


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProyect ..CovidDeaths
--where location like '%europe%'
Where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS 

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPorcentage
from PortfolioProyect ..CovidDeaths
--where location like '%europe%'
Where continent is not null
Group By date -- SE PUEDES QUITAR LA AGRUPACIÓN POR FECHAS. PARA VER EL GENERAL
order by 1,2


-- DATOS DE VACUNACIÓN 
-- TOTAL DE VACUNADOS VS POBLACIÓN TOTAL

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as Total_Personas_Vacunadas
from PortfolioProyect ..CovidDeaths dea -- se le asigna dea cómo objeto
join PortfolioProyect ..CovidVaccinations vac -- se le asigna vac cómo objeto
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE 
With PopvsVac (Continent, location, date, population, new_Vaccinations, Total_Personas_Vacunadas)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as Total_Personas_Vacunadas
from PortfolioProyect ..CovidDeaths dea -- se le asigna dea cómo objeto
join PortfolioProyect ..CovidVaccinations vac -- se le asigna vac cómo objeto
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select*, (Total_Personas_Vacunadas/population)*100
from PopvsVac



--TEMP TABLE 

DROP table if exists #Percent_Personas_Vacunadas
create Table #Percent_Personas_Vacunadas
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_Personas_Vacunadas numeric
)

Insert into #Percent_Personas_Vacunadas
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as Total_Personas_Vacunadas
from PortfolioProyect ..CovidDeaths dea 
join PortfolioProyect ..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3	

select*, (Total_Personas_Vacunadas/population)*100
from #Percent_Personas_Vacunadas



-- Creating view to store data for later visualizations

CREATE VIEW
Percent_PersonasVacunadas as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as Total_Personas_Vacunadas
from PortfolioProyect ..CovidDeaths dea 
join PortfolioProyect ..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3	

select *
from Percent_PersonasVacunadas

