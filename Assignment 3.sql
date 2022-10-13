CREATE DATABASE ABN_AMRO
GO

USE ABN_AMRO
GO

CREATE TABLE [dbo].[survey_results](
	[ResponseId] [nvarchar](MAX) NULL,
	[MainBranch] [nvarchar](MAX) NULL,
	[Employment] [nvarchar](MAX) NULL,
	[RemoteWork] [nvarchar](MAX) NULL,
	[CodingActivities] [nvarchar](MAX) NULL,
	[EdLevel] [nvarchar](MAX) NULL,
	[LearnCode] [nvarchar](MAX) NULL,
	[LearnCodeOnline] [nvarchar](MAX) NULL,
	[LearnCodeCoursesCert] [nvarchar](MAX) NULL,
	[YearsCode] [nvarchar](MAX) NULL,
	[YearsCodePro] [nvarchar](MAX) NULL,
	[DevType] [nvarchar](MAX) NULL,
	[OrgSize] [nvarchar](MAX) NULL,
	[PurchaseInfluence] [nvarchar](MAX) NULL,
	[BuyNewTool] [nvarchar](MAX) NULL,
	[Country] [nvarchar](MAX) NULL,
	[Currency] [nvarchar](MAX) NULL,
	[CompTotal] [nvarchar](MAX) NULL,
	[CompFreq] [nvarchar](MAX) NULL,
	[LanguageHaveWorkedWith] [nvarchar](MAX) NULL,
	[LanguageWantToWorkWith] [nvarchar](MAX) NULL,
	[DatabaseHaveWorkedWith] [nvarchar](MAX) NULL,
	[DatabaseWantToWorkWith] [nvarchar](MAX) NULL,
	[PlatformHaveWorkedWith] [nvarchar](MAX) NULL,
	[PlatformWantToWorkWith] [nvarchar](MAX) NULL,
	[WebframeHaveWorkedWith] [nvarchar](MAX) NULL,
	[WebframeWantToWorkWith] [nvarchar](MAX) NULL,
	[MiscTechHaveWorkedWith] [nvarchar](MAX) NULL,
	[MiscTechWantToWorkWith] [nvarchar](MAX) NULL,
	[ToolsTechHaveWorkedWith] [nvarchar](MAX) NULL,
	[ToolsTechWantToWorkWith] [nvarchar](MAX) NULL,
	[NEWCollabToolsHaveWorkedWith] [nvarchar](MAX) NULL,
	[NEWCollabToolsWantToWorkWith] [nvarchar](MAX) NULL,
	[OpSysProfessional use] [nvarchar](MAX) NULL,
	[OpSysPersonal use] [nvarchar](MAX) NULL,
	[VersionControlSystem] [nvarchar](MAX) NULL,
	[VCInteraction] [nvarchar](MAX) NULL,
	[VCHostingPersonal use] [nvarchar](MAX) NULL,
	[VCHostingProfessional use] [nvarchar](MAX) NULL,
	[OfficeStackAsyncHaveWorkedWith] [nvarchar](MAX) NULL,
	[OfficeStackAsyncWantToWorkWith] [nvarchar](MAX) NULL,
	[OfficeStackSyncHaveWorkedWith] [nvarchar](MAX) NULL,
	[OfficeStackSyncWantToWorkWith] [nvarchar](MAX) NULL,
	[Blockchain] [nvarchar](MAX) NULL,
	[NEWSOSites] [varchar](900) NULL,
	[SOVisitFreq] [nvarchar](MAX) NULL,
	[SOAccount] [nvarchar](MAX) NULL,
	[SOPartFreq] [nvarchar](MAX) NULL,
	[SOComm] [nvarchar](MAX) NULL,
	[Age] [nvarchar](MAX) NULL,
	[Gender] [nvarchar](MAX) NULL,
	[Trans] [nvarchar](MAX) NULL,
	[Sexuality] [nvarchar](MAX) NULL,
	[Ethnicity] [nvarchar](MAX) NULL,
	[Accessibility] [nvarchar](MAX) NULL,
	[MentalHealth] [nvarchar](MAX) NULL,
	[TBranch] [nvarchar](MAX) NULL,
	[ICorPM] [nvarchar](MAX) NULL,
	[WorkExp] [nvarchar](MAX) NULL,
	[Knowledge_1] [nvarchar](MAX) NULL,
	[Knowledge_2] [nvarchar](MAX) NULL,
	[Knowledge_3] [nvarchar](MAX) NULL,
	[Knowledge_4] [nvarchar](MAX) NULL,
	[Knowledge_5] [nvarchar](MAX) NULL,
	[Knowledge_6] [nvarchar](MAX) NULL,
	[Knowledge_7] [nvarchar](MAX) NULL,
	[Frequency_1] [nvarchar](MAX) NULL,
	[Frequency_2] [nvarchar](MAX) NULL,
	[Frequency_3] [nvarchar](MAX) NULL,
	[TimeSearching] [nvarchar](MAX) NULL,
	[TimeAnswering] [nvarchar](MAX) NULL,
	[Onboarding] [nvarchar](MAX) NULL,
	[ProfessionalTech] [nvarchar](MAX) NULL,
	[TrueFalse_1] [nvarchar](MAX) NULL,
	[TrueFalse_2] [nvarchar](MAX) NULL,
	[TrueFalse_3] [nvarchar](MAX) NULL,
	[SurveyLength] [nvarchar](MAX) NULL,
	[SurveyEase] [nvarchar](MAX) NULL,
	[ConvertedCompYearly] [nvarchar](MAX) NULL
) 
GO
-- Used nvarchar(MAX) because the difference in disk space is not significant.

bulk insert [dbo].[survey_results]
from 'C:\Users\rsturm\OneDrive - Capgemini\Desktop\copy_stack overflow\survey_results_public.csv'
with 
   (firstrow = 2,
    CODEPAGE = '65001',
    FIELDTERMINATOR=',',
	FORMAT = 'CSV',
    ROWTERMINATOR = '0x0a',
    MAXERRORS = 10,
    TABLOCK
   );

SELECT COUNT(*) FROM dbo.survey_results
SELECT TOP 100 * FROM dbo.survey_results
-- Data looks fine

CREATE TABLE eu_countries (
	AREA nvarchar(50) NOT NULL,
	CODE nvarchar(50) NOT NULL,
	COUNTRY_NAME nvarchar(50) NOT NULL
) 
GO

BULK INSERT eu_countries
from 'C:\Users\rsturm\OneDrive - Capgemini\Desktop\Answers assignment ABN\Country_codes.txt'
with 
   (firstrow = 2,
    CODEPAGE = '65001',
    FIELDTERMINATOR='\t',
	FORMAT = 'CSV',
    ROWTERMINATOR = '\n',
    MAXERRORS = 10,
    TABLOCK
   );

/*
I made the assumption that we are focused only on countries which are a member of the European Union (instead of members of the European continent)
Source: 'https://ec.europa.eu/eurostat/statistics-explained/images/9/9f/Country_Codes_and_Names.xlsx'
*/

SELECT sr.country, sr.LanguageHaveWorkedWith
INTO survey_results_filtered_eu
FROM survey_results AS sr
INNER JOIN eu_countries AS ec
ON sr.Country = ec.COUNTRY_NAME
-- This query filters on EU-countries. 21770 rows in the new table

SELECT country, value AS language
INTO survey_results_splitted
FROM survey_results_filtered_eu
	CROSS APPLY STRING_SPLIT(survey_results_filtered_eu.LanguageHaveWorkedWith, ';');
-- This query splits the (programming) language column. 115668 rows in the new table.

SELECT TOP 3 language, COUNT(language) AS count
FROM survey_results_splitted
GROUP BY language
ORDER BY count DESC
-- Most popular languages are: javascript, HTML/CSS, SQL

SELECT country, 
	COUNT('JavaScript') AS JavaScript, 
	COUNT('HTML/CSS') AS [HTML/CSS], 
	COUNT('SQL') AS SQL
FROM survey_results_splitted
GROUP BY country
ORDER BY Country
--Final answer