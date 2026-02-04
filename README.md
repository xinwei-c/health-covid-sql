# health-covid-sql
### Introduction
This project is written in MySQL and is based on the portfolio SQL tutorials by Alex The Analyst on YouTube. The original tutorials use SQL Server, so certain queries and functions have been adapted to MySQL syntax to achieve equivalent results.

### Datasets
This project uses two datasets:
- CovidDeaths — country-level COVID-19 cases, deaths, population, and related metrics
- CovidVaccinations — vaccination data, including daily vaccination counts and cumulative measures
Both datasets are joined on location and date for analysis.


```sql
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM health_project.coviddeaths
WHERE location like '%states%' -- the location contains "states"
ORDER BY 1,2;
```
