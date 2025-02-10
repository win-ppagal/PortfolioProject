/*

Data Cleaning in SQL Server

*/
-- Check data
SELECT * FROM HRDB_v14;

-- Trim spaces from string fields
UPDATE HRDB_v14
SET Employee_Name = LTRIM(RTRIM(Employee_Name)),
    Position = LTRIM(RTRIM(Position)), 
    State = LTRIM(RTRIM(State)),
    Zip = LTRIM(RTRIM(Zip)),
    MaritalDesc = LTRIM(RTRIM(MaritalDesc)),
    CitizenDesc = LTRIM(RTRIM(CitizenDesc)),
    RaceDesc = LTRIM(RTRIM(RaceDesc)),
    EmploymentStatus = LTRIM(RTRIM(EmploymentStatus)),
    Department = LTRIM(RTRIM(Department)),
    ManagerName = LTRIM(RTRIM(ManagerName)),
    RecruitmentSource = LTRIM(RTRIM(RecruitmentSource)),
    PerformanceScore = LTRIM(RTRIM(PerformanceScore));

-- Convert dates
UPDATE HRDB_v14
SET DOB = CONVERT(DATE, DOB, 101), -- Standardization of dates
    DateofHire = CONVERT(DATE, DateofHire, 101),
    DateofTermination = CONVERT(DATE, DateofTermination, 101),
    LastPerformanceReview_Date = CONVERT(DATE, LastPerformanceReview_Date, 101);

-- Handle NULL values or standardize text where necessary
UPDATE HRDB_v14
SET TermReason = CASE WHEN TermReason IS NULL OR TermReason = 'N/A' THEN 'Unknown' ELSE TermReason END;

UPDATE HRDB_v14
SET EngagementSurvey = ROUND(EngagementSurvey, 2);

-- Remove duplicates
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY EmpID ORDER BY EmpID) AS RN
    FROM HRDB_v14
)
DELETE FROM CTE WHERE RN > 1;

-- Check data
SELECT TOP 10 * FROM HRDB_v14;

-- Business Questions

-- 1. Which department has the highest average salary?

SELECT TOP 1 Department, AVG(Salary) AS AvgSalary
FROM HRDB_v14
GROUP BY Department
ORDER BY AvgSalary DESC;

-- 2. What is the distribution of employees by gender across departments?

SELECT Department, Sex, COUNT(*) AS EmployeeCount
FROM HRDB_v14
GROUP BY Department, Sex;

-- 3. How many employees have been with the company for more than 5 years?

SELECT COUNT(*) AS EmployeesOver5Years
FROM HRDB_v14
WHERE DATEDIFF(YEAR, DateofHire, GETDATE()) > 5;

-- 4. What's the average performance score for each job title?

SELECT Position, AVG(CASE 
    WHEN PerformanceScore = 'Exceeds' THEN 3 
    WHEN PerformanceScore = 'Fully Meets' THEN 2 
    WHEN PerformanceScore = 'Needs Improvement' THEN 1 
    ELSE 0 END) AS AvgPerformanceScore
FROM HRDB_v14
GROUP BY Position;

-- 5. Which employee has the highest salary per department?

SELECT Department, Employee_Name, MAX(Salary) AS HighestSalary
FROM HRDB_v14
GROUP BY Department, Employee_Name;

-- 6. How many employees left the company in the last year?

SELECT COUNT(*) AS EmployeesLeftLastYear
FROM HRDB_v14
WHERE DateofTermination IS NOT NULL 
  AND DateofTermination >= DATEADD(YEAR, -1, GETDATE());

-- 7. What is the age distribution of employees?

SELECT DATEDIFF(YEAR, DOB, GETDATE()) AS Age, COUNT(*) AS EmployeeCount
FROM HRDB_v14
GROUP BY DATEDIFF(YEAR, DOB, GETDATE());

-- 8. What's the average tenure by department?

SELECT Department, AVG(DATEDIFF(YEAR, DateofHire, ISNULL(DateofTermination, GETDATE()))) AS AvgTenureYears
FROM HRDB_v14
GROUP BY Department;

-- 9. How does salary correlate with performance score?

SELECT PerformanceScore, AVG(Salary) AS AverageSalary
FROM HRDB_v14
GROUP BY PerformanceScore;

-- 10. Who are the top 5 highest-paid employees?

SELECT TOP 5 Employee_Name, Salary
FROM HRDB_v14
ORDER BY Salary DESC;
