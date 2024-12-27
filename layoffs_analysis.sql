/*
Consolidated Layoffs Data Analysis
--------------------------------.
*/

/*
SECTION 1: Overview Statistics
----------------------------
*/

-- Basic statistics
SELECT 
    COUNT(DISTINCT company) as total_companies,
    COUNT(DISTINCT industry) as total_industries,
    COUNT(DISTINCT country) as total_countries,
    SUM(total_laid_off) as total_layoffs,
    AVG(funds_raised_millions) as avg_funds_raised
FROM layoffs_staging2;

-- Maximum values check
SELECT 
    MAX(total_laid_off) as max_layoffs, 
    MAX(percentage_laid_off) as max_percentage
FROM layoffs_staging2;

/*
SECTION 2: Temporal Analysis
--------------------------
*/

-- Date range analysis
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;  -- Result: 2020-03-11 to 2023-03-06

-- Yearly analysis
SELECT 
    YEAR(`date`) as year,
    COUNT(DISTINCT company) as companies_affected,
    SUM(total_laid_off) as total_layoffs
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY year DESC;

-- Monthly analysis with running total
WITH Rolling_Total AS (
    SELECT 
        SUBSTRING(`date`,1,7) AS `MONTH`,
        SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`,1,7) IS NOT NULL
    GROUP BY `MONTH`
    ORDER BY `MONTH` ASC
)
SELECT 
    `MONTH`,
    total_off,
    SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

/*
SECTION 3: Company Analysis
-------------------------
*/

-- Total layoffs by company
SELECT 
    company,
    SUM(total_laid_off) as total_layoffs,
    AVG(funds_raised_millions) as avg_funding
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 20;  -- Top 20 for visualization

-- Companies with 100% layoffs
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

/*
SECTION 4: Geographic Analysis
---------------------------
*/

-- Country-level analysis
SELECT 
    country,
    COUNT(DISTINCT company) as companies_affected,
    SUM(total_laid_off) as total_layoffs,
    AVG(funds_raised_millions) as avg_funding
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;

/*
SECTION 5: Industry Analysis
--------------------------
*/

-- Industry trends over time
SELECT 
    industry,
    YEAR(`date`) as year,
    COUNT(DISTINCT company) as companies_affected,
    SUM(total_laid_off) as total_layoffs
FROM layoffs_staging2
WHERE industry IS NOT NULL
GROUP BY industry, YEAR(`date`)
ORDER BY year DESC, total_layoffs DESC;

/*
SECTION 6: Stage and Funding Analysis
----------------------------------
*/

-- Stage analysis
SELECT 
    stage,
    COUNT(DISTINCT company) as company_count,
    SUM(total_laid_off) as total_layoffs,
    AVG(funds_raised_millions) as avg_funding
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;

/*
SECTION 7: Advanced Analytics
--------------------------
*/

-- Top 5 companies by year
WITH Company_Year AS (
    SELECT 
        company,
        YEAR(`date`) as years,
        SUM(total_laid_off) as total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
), 
Company_Year_Rank AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY years 
            ORDER BY total_laid_off DESC
        ) AS Ranking
    FROM Company_Year
    WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
ORDER BY years DESC, Ranking;

/*
To-Do: Queries for Visualization
------------------------------
*/

-- Time series data for line charts
SELECT 
    DATE_FORMAT(`date`, '%Y-%m') as month,
    SUM(total_laid_off) as monthly_layoffs,
    COUNT(DISTINCT company) as companies_affected
FROM layoffs_staging2
GROUP BY DATE_FORMAT(`date`, '%Y-%m')
ORDER BY month;

-- Geographic data for maps
SELECT 
    country,
    SUM(total_laid_off) as total_layoffs,
    COUNT(DISTINCT company) as company_count,
    AVG(percentage_laid_off) as avg_percentage
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;
