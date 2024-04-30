use payrollmgmt
go

----SP1:Calculate_LOP

CREATE PROCEDURE dbo.Calculate_LOP1
AS
BEGIN
SET NOCOUNT ON

    DECLARE @StartDate DATE = '2024-01-01'
    DECLARE @EndDate DATE = '2024-03-31'
    DECLARE @EmployeeId INT = 1
    
    --temp table:
    CREATE TABLE #LOP_Details (
        Employee_Id INT,
        Month DATE,
        LOP DECIMAL(10, 2)
    )

    WHILE @EmployeeId <= 100
    BEGIN
        DECLARE @CurrentMonth DATE = @StartDate
        
        WHILE @CurrentMonth <= @EndDate
        BEGIN
            DECLARE @TotalWorkDays DECIMAL(5, 2) = 0
            DECLARE @TotalLeaveDays DECIMAL(5, 2) = 0
            DECLARE @TotalWage DECIMAL(18, 2) = 0
            DECLARE @LOP DECIMAL(10, 2) = 0

            -- total working days 
            SELECT @TotalWorkDays = ISNULL(SUM(CASE WHEN Hours_Worked > 0 THEN 1 ELSE 0 END), 0)
            FROM dbo.Employee_Attendance
            WHERE YEAR(AttendanceDate) = YEAR(@CurrentMonth) AND 
			MONTH(AttendanceDate) = MONTH(@CurrentMonth) AND 
			Employee_Id = @EmployeeId

            -- total leave days
            SELECT @TotalLeaveDays = ISNULL(COUNT(Leave_date), 0)
            FROM dbo.Employee_Leave
            WHERE YEAR(Leave_date) = YEAR(@CurrentMonth) AND 
			MONTH(Leave_date) = MONTH(@CurrentMonth) AND 
			Employee_Id = @EmployeeId AND 
			IsApproved = 1

            -- total wage 
            SELECT @TotalWage = Salary
            FROM dbo.Employee_Salary
            WHERE Employee_Id = @EmployeeId

            --  LOP for the employee for the current month
            IF @TotalWorkDays > 0
            BEGIN
                SET @LOP = ((@TotalWage / @TotalWorkDays) * @TotalLeaveDays)
            END

            -- Insert 
            INSERT INTO #LOP_Details (Employee_Id, Month, LOP)
            VALUES (@EmployeeId, @CurrentMonth, @LOP)
            
            SET @CurrentMonth = DATEADD(MONTH, 1, @CurrentMonth); -- Move to the next month
        END

        SET @EmployeeId = @EmployeeId + 1
    END
    SELECT * FROM #LOP_Details
END
----------------
EXEC dbo.Calculate_LOP
----------------

----SP2:GetEmployeeLOP

CREATE PROCEDURE dbo.GetEmployeeLOP
    @EmployeeId INT,
    @Month DATE = NULL
AS
BEGIN
    -- Check @Month parameter is in
    IF @Month IS NOT NULL
    BEGIN
        -- specific employee for  month
        SELECT Employee_Id, Month, LOP
        FROM dbo.LOP_Details
        WHERE Employee_Id = @EmployeeId
        AND Month = @Month
    END
    ELSE
    BEGIN
        -- specific employee for all months
        SELECT Employee_Id, Month, LOP
        FROM dbo.LOP_Details
        WHERE Employee_Id = @EmployeeId
    END
END

-------------
EXEC dbo.GetEmployeeLOP @EmployeeId = 100;--one employee for 3 months
--------------
EXEC dbo.GetEmployeeLOP @EmployeeId = 5, @Month = '2024-01-01';--one employee for 1 months
-------------

----SP3:EmployeePayroll

create PROCEDURE dbo.EmployeePayroll
    @EmployeeID INT = NULL, 
    @MonthYear VARCHAR(10) 
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        p.Employee_ID,
        e.First_Name + ' ' + e.Last_Name AS Employee_Name,
		d.Department_Name,
        p.MonthYear,
		a.Account_Number,
		e.Email,
        p.[Basic],
        p.HRA,
        p.DA,
        p.PF,
        p.TotalSalary,
        p.LOPAmount,            
        p.Deductions,            
        p.NetSalary
    FROM 
        dbo.Payroll p
    INNER JOIN 
        dbo.Employee e ON p.Employee_ID = e.Employee_Id
	INNER JOIN 
		dbo.Employee_Department d ON p.Employee_ID = d.Employee_Id
	INNER JOIN 
		dbo.Employee_AccountDetails a ON a.Employee_ID = e.Employee_Id
    WHERE 
        (@EmployeeID IS NULL OR p.Employee_ID = @EmployeeID)
        AND p.MonthYear = @MonthYear
END

--------------------------------
EXEC dbo.EmployeePayroll @EmployeeID = NULL, @MonthYear = '2024-01-01'; --all employees 
--------------------------------
EXEC dbo.EmployeePayroll @EmployeeID = 1, @MonthYear = '2024-01-01'; --one employee
--------------------------------

