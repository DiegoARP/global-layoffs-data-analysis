## Global Layoffs Data Analysis

## Overview
This project focuses on cleaning and analyzing global company layoffs data using SQL. The analysis includes data from various industries and locations, providing insights into worldwide workforce reduction trends.

## Table Structure
The main table contains the following columns:
- Company
- Location
- Industry
- Total Laid Off
- Percentage Laid Off
- Date
- Stage
- Country
- Funds Raised (Millions)

## Data Cleaning Process
The cleaning process involves several key steps:

1. **Duplicate Removal**
   - Identification and removal of duplicate records
   - Use of ROW_NUMBER() for duplicate detection

2. **Data Standardization**
   - Company name cleaning
   - Industry name standardization
   - Country name formatting
   - Date format conversion

3. **NULL Value Handling**
   - Removal of records with no layoff information
   - Industry field standardization
   - Missing value imputation where possible

4. **Schema Optimization**
   - Proper data type conversion
   - Removal of unnecessary columns

## Tech Stack
- MySQL

## Files in Repository
- `Data_Cleaning_Project.sql`: Main SQL cleaning script
- Additional analysis files (coming soon)

## Getting Started
1. Clone the repository
```bash
git clone https://github.com/your-username/global-layoffs-data-analysis.git
```

2. Import the SQL script into your MySQL environment

3. Run the cleaning script
```sql
source Data_Cleaning_Project.sql
```

## Future Enhancements
- Addition of data visualizations
- Time series analysis of layoff trends
- Industry-specific insights
- Regional comparison analysis

## Contributing
Feel free to fork this repository and submit pull requests. All contributions are welcome!

## License
This project is licensed under the MIT License - see the LICENSE file for details.

---
*Note: This project is for educational and analytical purposes only.*
