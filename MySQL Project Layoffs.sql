------ Cleaning

SELECT * 
FROM world_layoffs.layoffs;

# 1. Remove duplicates
# 2. Standardize the Data
# 3. Null values or black values
# 4. Remove any columns

# 1

Create table layoffs_staging
like layoffs;

SELECT * 
FROM layoffs_staging;

insert layoffs_staging
select *
from layoffs;

SELECT *,
row_number() 
over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging ;

with duplicate_cte as
(
SELECT *,
row_number() 
over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
select *
from duplicate_cte
where row_num > 1 ;

select *
from layoffs_staging
where company = "Casper";

with duplicate_cte as
(
SELECT *,
row_number() 
over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
delete 
from duplicate_cte
where row_num > 1 ;

CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging3;

insert into layoffs_staging3
SELECT *,
row_number() 
over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

select *
from layoffs_staging3
where row_num > 1;

delete
from layoffs_staging3
where row_num > 1;

select *
from layoffs_staging3
where row_num > 1;

# 2

select distinct (TRIM(company))
from layoffs_staging3;

select company, TRIM(company)
from layoffs_staging3;

update layoffs_staging3
set company = TRIM(company);

select distinct industry
from layoffs_staging3
order by 1;

select *
from layoffs_staging3
where industry like "crypto%";

update layoffs_staging3
set industry = "Crypto"
where industry like "Crypto%";

select distinct location
from layoffs_staging3
order by 1;

select distinct country
from layoffs_staging3
order by 1;

select distinct country, TRIM(Trailing "." from country)
from layoffs_staging3
order by 1;

Update layoffs_staging3
set country = TRIM(Trailing "." from country)
where country like "United States%";

select *
from layoffs_staging3 ;

select `date`,
str_to_date(`date`, "%m/%d/%Y")
from layoffs_staging3;

update layoffs_staging3
set `date` =  str_to_date(`date`, "%m/%d/%Y");

select `date`
from layoffs_staging3;

alter table layoffs_staging3
modify column `date` DATE;

select *
from layoffs_staging3;

# 3

select *
from layoffs_staging3
where total_laid_off is null
and percentage_laid_off is null ;

select *
from layoffs_staging3
where industry is null
or industry = "";

select *
from layoffs_staging3
where company = "Airbnb";

select t1.industry, t2.industry
from layoffs_staging3 t1
join layoffs_staging3 t2
on t1.company=t2.company
and t1.location=t2.location
where (t1.industry is null or t1.industry="")
and t2.industry is not null ;

update layoffs_staging3 t1
join layoffs_staging3 t2
on t1.company=t2.company
set t1.industry=t2.industry
where (t1.industry is null or t1.industry="")
and t2.industry is not null;

update layoffs_staging3
set industry = null
where industry = "";

select *
from layoffs_staging3
where industry is null;

select *
from layoffs_staging3
where company = "Bally's Interactive";

select *
from layoffs_staging3;

select *
from layoffs_staging3
where total_laid_off is null
and percentage_laid_off is null ;

# 4

delete
from layoffs_staging3
where total_laid_off is null
and percentage_laid_off is null ;

select *
from layoffs_staging3;

alter table layoffs_staging3
drop column row_num;

--------- Exploratoty

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging3;

select *
from layoffs_staging3
where percentage_laid_off = 1
order by total_laid_off desc;

select *
from layoffs_staging3
where percentage_laid_off = 1
order by funds_raised_millions desc;

select company, sum(total_laid_off)
from layoffs_staging3
group by company
order by 2 desc;

select min(`date`), max(`date`)
from layoffs_staging3;

select industry, sum(total_laid_off)
from layoffs_staging3
group by industry
order by 2 desc;

select *
from layoffs_staging3;

select country, sum(total_laid_off)
from layoffs_staging3
group by country
order by 2 desc;

select `date`, sum(total_laid_off)
from layoffs_staging3
group by `date`
order by 1 desc;

select year(`date`), sum(total_laid_off)
from layoffs_staging3
group by year(`date`)
order by 1 desc;

select stage, sum(total_laid_off)
from layoffs_staging3
group by stage
order by 2 desc;

select company, sum(percentage_laid_off)
from layoffs_staging3
group by company
order by 2 desc;

select company, avg(percentage_laid_off)
from layoffs_staging3
group by company
order by 2 desc;

select *
from layoffs_staging3;

select substring(`date`, 6, 2) as `month`, sum(total_laid_off)
from layoffs_staging3
group by `month` ;

select substring(`date`, 1, 7) as `month`, sum(total_laid_off)
from layoffs_staging3
where substring(`date`, 1, 7) is not null
group by `month`
order by 1 asc ;

select *
from layoffs_staging3;

with rolling_total as
(select substring(`date`, 1, 7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging3
where substring(`date`, 1, 7) is not null
group by `month`
order by 1 asc)
select `month`, total_off, sum(total_off) over(order by `month`) as rolling_total 
from rolling_total;

select company, sum(total_laid_off)
from layoffs_staging3
group by company
order by 2 desc;

select company, year(`date`), sum(total_laid_off)
from layoffs_staging3
group by company, year(`date`)
order by company asc;

select company, year(`date`), sum(total_laid_off)
from layoffs_staging3
group by company, year(`date`)
order by 3 desc;

with company_year (company, years, total_laid_off) as
(select company, year(`date`), sum(total_laid_off)
from layoffs_staging3
group by company, year(`date`))
select *, 
dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
order by ranking asc;

with company_year (company, years, total_laid_off) as
(select company, year(`date`), sum(total_laid_off)
from layoffs_staging3
group by company, year(`date`)), company_year_rank as
(select *, 
dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null)
select *
from company_year_rank
where ranking <=5 ;