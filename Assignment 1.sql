USE ABN_AMRO

CREATE TABLE dbo.GDP_countries (
	Dataflow nvarchar(50) NOT NULL,
	LAST_UPDATE datetime2(7) NOT NULL,
	freq nvarchar(50) NOT NULL,
	unit nvarchar(50) NOT NULL,
	na_item nvarchar(50) NOT NULL,
	geo nvarchar(50) NOT NULL,
	TIME_PERIOD smallint NOT NULL,
	OBS_VALUE int NOT NULL,
	OBS_FLAG nvarchar(50) NULL
)

BULK INSERT dbo.GDP_countries
from 'C:\Users\rsturm\OneDrive - Capgemini\Desktop\Answers assignment ABN\sdg_08_10_page_linear.csv'
with 
   (firstrow = 2,
    CODEPAGE = '65001',
    FIELDTERMINATOR=',',
	FORMAT = 'CSV',
    ROWTERMINATOR = '0x0a',
    MAXERRORS = 10,
    TABLOCK
   );
--33 rows inserted (only the 2021 values). OBS value = Real GDP per capita

SELECT COUNT(*) FROM dbo.GDP_countries
SELECT * FROM GDP_countries
-- Data quality check. Data looks fine

CREATE TABLE temp_table (
	country nvarchar(240) NOT NULL,
	YearsCode numeric(4, 2) NOT NULL,
);

INSERT INTO temp_table
SELECT sr.Country, sr.YearsCode
FROM (SELECT country, yearscode FROM survey_results WHERE yearscode NOT IN ('More than 50 years', 'Less than 1 year', 'NA'))
AS sr
INNER JOIN GDP_EU_countries AS gec
ON sr.country = gec.COUNTRY_NAME
-- Filtering out non-numerical values. 22088 rows inserted in the new table. 

SELECT country, ROUND(AVG(YearsCode), 2) AS avg
INTO temp_table_2
FROM temp_table
GROUP BY country
--Calculating per country the average age participants start coding. 27 rows inserted

SELECT tt2.country, tt2.avg, gc.OBS_VALUE AS GDP
INTO avg_age_per_country
FROM temp_table_2 AS tt2
INNER JOIN eu_countries AS ec
ON tt2.country = ec.COUNTRY_NAME
INNER JOIN GDP_countries AS gc
ON gc.geo = ec.CODE
--Exported this table. Continued the assignment in Python