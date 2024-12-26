/*
Layoffs Data Cleaning and Analysis
---------------------------------
This script performs comprehensive data cleaning on a layoffs dataset including:
1. Duplicate removal
2. Data standardization
3. Handling NULL values
4. Schema optimization

Database: world_layoffs
Main Table: layoffs
*/

-- Initial data exploration
SELECT *
FROM layoffs;

-- Create staging table for data cleaning
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

/*
STEP 1: Duplicate Detection and Removal
-------------------------------------
First identify duplicates using a CTE, then remove them using a proper MySQL approach
*/

-- Identify duplicates first
WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY 
            company, 
            location,
            industry, 
            total_laid_off, 
            percentage_laid_off, 
            `date`, 
            stage,
            country, 
            funds_raised_millions
    ) as row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Create new staging table for clean data
CREATE TABLE `layoffs_staging2` (
    `company` text,
    `location` text,
    `industry` text,
    `total_laid_off` int DEFAULT NULL,
    `percentage_laid_off` text,
    `date` text,
    `stage` text,
    `country` text,
    `funds_raised_millions` int DEFAULT NULL,
    `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert data with row numbers to identify duplicates
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY 
        company, 
        location,
        industry, 
        total_laid_off, 
        percentage_laid_off, 
        `date`, 
        stage,
        country, 
        funds_raised_millions
) as row_num
FROM layoffs_staging;

-- Remove duplicates
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Verify duplicates are removed
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

/*
STEP 2: Data Standardization
--------------------------
Clean and standardize text fields and data formats
*/

-- Clean company names
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry names
SELECT *
FROM layoffs_staging2
WHERE industry LIKE "Crypto%";

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Review distinct industries after standardization
SELECT DISTINCT industry
FROM layoffs_staging2;

-- Clean country names
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert dates to proper format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

/*
STEP 3: Handle NULL and Empty Values
---------------------------------
Clean up NULL values and empty strings
*/

-- Identify rows with no layoff information
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Check for NULL or empty industries
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Sample check for a specific company
SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Find companies with missing industries where we have the info in other rows
SELECT * 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Standardize empty industries to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Fill in missing industries from other records of the same company
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Verify updates for specific company
SELECT * 
FROM layoffs_staging2
WHERE company LIKE 'Airbnb';

-- Remove rows with no layoff information
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

/*
STEP 4: Final Cleanup
-------------------
Remove temporary columns and final verification
*/

-- Remove row_num column used for duplicate detection
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final verification query
SELECT *
FROM layoffs_staging2
ORDER BY date DESC;

/*
Additional Notes:
- The cleaned dataset is now in layoffs_staging2
- All dates are in standard DATE format
- Industry names are standardized
- Duplicates have been removed
- NULL values have been handled appropriately
*/
