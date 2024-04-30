
use payrollmgmt
go

--1.Employee: --- select * from dbo.Employee
CREATE TABLE dbo.Employee(
  Employee_Id INT IDENTITY(1,1) PRIMARY KEY,
  First_Name VARCHAR(50) NOT NULL,
  Last_Name VARCHAR(50) NOT NULL,
  Gender VARCHAR(10) NOT NULL,
  DateOfBirth DATE NOT NULL,
  Age TINYINT,
  [Address] VARCHAR(50),
  Email VARCHAR(50) NOT NULL UNIQUE,
  PhoneNo VARCHAR(15) NOT NULL,
  JoiningDate DATE NOT NULL,
  IsActive BIT NOT NULL,
);

--2.Employee_Department: --- select * from dbo.Employee_Department
CREATE TABLE dbo.Employee_Department(
	Department_Id INT  primary key IDENTITY(1001,1),
	Department_Name VARCHAR(50) NOT NULL,
	Employee_Id INT,
	FOREIGN KEY (Employee_Id) REFERENCES dbo.Employee(Employee_Id)
);

--3.Employee_Attendance: --- select * from dbo.Employee_Attendance
CREATE TABLE dbo.Employee_Attendance(   
    Attendance_Id INT PRIMARY KEY IDENTITY(101,1) ,
	AttendanceDate DATE,
    StartTime TIME,
    EndTime TIME,
    Hours_Worked DECIMAL(5, 2), 
    IsLate BIT, 
    IsHoliday BIT,
	Employee_Id INT,
    CONSTRAINT FK_Attendance_Employee FOREIGN KEY (Employee_Id) REFERENCES dbo.Employee(Employee_Id)
);

--4.Employee_Leave:  --- select * from dbo.Employee_Leave
CREATE TABLE dbo.Employee_Leave(
    Leave_Id INT PRIMARY KEY IDENTITY(201,1),
    Employee_Id INT,
    Leave_date DATE,
	Leave_Type VARCHAR(50),
    IsApproved BIT, 
    CONSTRAINT FK_Leave_Employee FOREIGN KEY (Employee_Id) REFERENCES dbo.Employee(Employee_Id)
);

--5.Employee_AccountDetails: --- select * from dbo.Employee_AccountDetails
CREATE TABLE dbo.Employee_AccountDetails(
    Account_Id INT PRIMARY KEY,
    Bank_Name VARCHAR(50),
    Account_Number VARCHAR(50) UNIQUE ,
	IFSC_Code VARCHAR(20),--Indian Financial System Code
    Employeer_Id INT,
    FOREIGN KEY (Employee_Id) REFERENCES dbo.Employee(Employee_Id)
);

--6.Employee_Salary: --- select * from dbo.Employee_Salary
CREATE TABLE dbo.Employee_Salary (
    Salary_Id INT PRIMARY KEY IDENTITY(501,1),
    Salary DECIMAL(10, 2),
	PerDay_Pay DECIMAL(10, 2),
    Hourly_Pay DECIMAL(10, 2),
    Account_Id INT,
    Employee_Id INT,
    FOREIGN KEY (Account_Id) REFERENCES dbo.Employee_AccountDetails(Account_Id)
);

--7.Payroll: --- select * from dbo.Payroll
CREATE TABLE dbo.Payroll (
    PayrollID INT PRIMARY KEY IDENTITY(1,1),
    Employee_ID INT,
    MonthYear VARCHAR(10),
    [Basic] DECIMAL(10, 2),
    HRA DECIMAL(10, 2),--House Rent Allowancer
    DA DECIMAL(10, 2),--Dearness Allowance
	OtherAllowances DECIMAL(10, 2),-- Additional allowances apart from Basic, HRA, DA
	TotalEarnings DECIMAL(10, 2),-- Total earnings before deductions (TotalEarnings = Basic + HRA + DA + OtherAllowances)
    PF DECIMAL(10, 2),--Provident Fund
    TotalSalary DECIMAL(10, 2),--(TotalEarnings-PF)
    LOPAmount DECIMAL(10, 2),--Loss of pay	
    Deductions DECIMAL(10, 2),-- Total deductions from the salary (LOPAmount + PF)
    NetSalary DECIMAL(10, 2),-- Net salary after deductions( Basic + HRA + DA - PF + OtherAllowances - (LOPAmount + PF))
    CONSTRAINT FK_Salary_Employee FOREIGN KEY (Employee_ID) REFERENCES dbo.Employee(Employee_Id)
);