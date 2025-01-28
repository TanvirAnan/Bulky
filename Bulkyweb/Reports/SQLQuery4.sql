create table Company(
ComId varchar(20),
ComName varchar(20),
Basic tinyint,
Hrent tinyint,
Medical tinyint,
IsInactive bit
Constraint P_K Primary Key(ComId)
);

create table Department(
DeptId varchar(20),
ComId varchar(20),
DeptName varchar(30)
Constraint P_K2 Primary Key(DeptId)
Constraint F_K2 Foreign Key(ComId) references Company(ComId)
);


create table Designation(
DesigId varchar(20),
ComId varchar(20),
DesigName varchar(20),
Constraint P_K3 Primary Key(DesigId),
Constraint F_K3 Foreign Key(ComId) references Company(ComId)
);


create table Shift(
ShiftId varchar(20),
ComId varchar(20),
ShiftName varchar(20),
ShiftIn time(7),
ShiftOut time(7),
ShiftLate time(7),
Constraint P_K4 Primary Key(ShiftId),
Constraint F_K4 Foreign Key(ComId) references Company(ComId)
);



Create table Employee(
EmployeeId varchar(20),
ComId varchar(20),
DeptId varchar(20),
DesigId varchar(20),
ShiftId varchar(20),
EmpCode varchar(20),
EmpName varchar(100),
Gender varchar(100),
Gross money,
Basic money,
Hrent money,
Medical money,
Others money,
dtjoin date,
Constraint P_K5 Primary Key(EmployeeId),
Constraint F_K51 Foreign Key(ComId) references Company(ComId),
Constraint F_K52 Foreign Key(DeptId) references Department(DeptId),
Constraint F_K53 Foreign Key(DesigId) references Designation(DesigId),
Constraint F_K54 Foreign Key(ShiftId) references Shift(ShiftId),
constraint Check_Constraint Check(Gross>10000)
);

Create Trigger inserted_on_employee
ON Employee
For Insert
As
Begin
   Declare @total_update tinyint
   Declare @EmployeeId varchar(20)
   Declare @index int
   Declare @Basic money
   Declare @Hrent money
   Declare @Medical money
   Declare @others money
   Declare @Gross money


   Set @index=1
   print @index

   Select @total_update = count(*) from inserted


   while @total_update>0
   Begin
   
	 SELECT @EmployeeId = EmployeeId,@Basic=Basic,@Hrent=Hrent,@Medical=Medical,@Gross=Gross
     FROM (
     SELECT EmployeeId,Company.Basic As Basic,Company.Hrent as Hrent,Company.Medical As Medical,inserted.Gross as Gross,ROW_NUMBER() OVER (ORDER BY EmployeeId) AS RowNum
     FROM inserted,Company where inserted.ComId=Company.ComId
     ) AS Temp
     WHERE RowNum = @index;


	 Update Employee 
	 Set Basic=(@Gross*@Basic)/100,Hrent=(@Gross*@Hrent)/100,Medical=(@Gross*@Medical)/100,Others=(@Gross-@Gross*((@Basic+@Hrent+@Medical)/100))
	 where EmployeeId=@EmployeeId
	 
	 set @total_update = @total_update-1
	 set @index=@index+1

 
   End
End



Create table Attendance(
 EmployeeId varchar(20),
 ComId varchar(20),
 dtDate smalldatetime,
 Timein time(7),
 Timeout time(7),
 Attstatus varchar(1)
 Constraint P_K6 Primary Key(EmployeeId,ComId,dtDate),
 Constraint F_K61 Foreign Key(ComId) references Company(ComId),
 Constraint F_K62 Foreign Key(EmployeeId) references Employee(EmployeeId),
 CONSTRAINT chk_attendance CHECK (Attstatus IN ('A', 'P','W','L'))
);


Create Table AttendanceSummary(
  EmployeeId varchar(20),
  ComId varchar(20),
  dtMonth varchar(3),
  dtYear varchar(4),
  MonthDays tinyint,
  Present tinyint,
  Late tinyint,
  Absent tinyint,
  Holiday tinyint,
  Constraint P_K7 Primary Key(EmployeeId,ComId,dtMonth,dtYear),
  Constraint F_K71 Foreign Key(ComId) references Company(ComId),
  Constraint F_K72 Foreign Key(EmployeeId) references Employee(EmployeeId),
)


Create Trigger Insert_on_Attendance
ON Attendance 
for insert
As 
Begin
  Declare @Total_inserted tinyint
  Declare @shiftLate Time(7)
  Declare @index int
  Declare @status varchar(1)
  Declare @EmployeeId varchar(20)
  Declare @ComId varchar(20)
  Declare @dtdate smalldatetime
  Declare @shiftin time(7)
  Declare @ShiftId varchar(20)


  Set @Total_inserted=1
  Set @index=1
  Set @status=''

  Select @Total_inserted = count(*) from inserted


  while @Total_inserted>0
  Begin



    Select @shiftId=Temp.ShiftId from (Select Employee.ShiftId as ShiftId, ROW_NUMBER() over(Order by inserted.employeeId,inserted.comId,inserted.dtDate) As RowNum 
    from inserted inner join Employee on inserted.EmployeeId = Employee.EmployeeId) as Temp where RowNum=@index

	select @shiftLate=shift.ShiftLate from shift where shiftid=@ShiftId
    
    Select @shiftin=Temp.ShiftIn, @EmployeeId=temp.EmployeeId , @ComId=temp.ComId , @dtDate=Temp.dtDate
    from (Select dtDate ,Timein as ShiftIn ,EmployeeId, ComId , 
	ROW_NUMBER() over(Order by inserted.employeeId,inserted.comId,inserted.dtDate) As RowNum 
    from inserted )as temp where RowNum=@index;
	
    
	print @EmployeeId
	print @Shiftin
	print @shiftlate
	print @index
	
	
    If @shiftIn>=@shiftLate
    Begin
	   print @EmployeeId
       set @status='L'
    End
    Else 
    Begin
       set @status='P'
    End
    DECLARE @CheckDate DATE = @dtDate
    IF DATEPART(WEEKDAY, @CheckDate) = 6
    Begin
      set @status='W'
    End
        

    Update Attendance
    set Attstatus=@status 
    where Attendance.EmployeeId = @EmployeeId and ComId = @ComId and dtDate = @dtDate
	

    set @index=@index+1
    Set @Total_inserted=@Total_inserted-1

   
  End
End


Create Trigger insert_on_AttendanceSummary
ON AttendanceSummary
For Insert 
As
Begin
    Declare @Total_inserted tinyint=1
    Declare @employeeId varchar(20)
    Declare @comId varchar(20)
    Declare @MonthName varchar(3)
    Declare @dtYear varchar(4)
    Declare @MonthDays tinyint
    DECLARE @MonthNumber INT;
    Declare @Present INT
    Declare @late Int
    Declare @Holiday Int=0
    Declare @absent INT
     Declare @Weekend Int
    Declare @startDate smalldatetime
    Declare @endDate smalldatetime
    
    Select @Total_inserted = count(*) from inserted
    Declare @index INT =1



    while @Total_inserted>0
    Begin
        Select @employeeId=temp.employeeId, @comId=comId, @MonthName=dtMonth, @dTyear=dTyear 
        from (Select *,ROW_NUMBER() over (order by inserted.employeeId) as RowNum from inserted )as temp where RowNum=@index
         SET @MonthNumber = CASE 
            WHEN @MonthName = 'Jan' THEN 1
            WHEN @MonthName = 'Feb' THEN 2
            WHEN @MonthName = 'Mar' THEN 3
            WHEN @MonthName = 'Apr' THEN 4
            WHEN @MonthName = 'May' THEN 5
            WHEN @MonthName = 'Jun' THEN 6
            WHEN @MonthName = 'Jul' THEN 7
            WHEN @MonthName = 'Aug' THEN 8
            WHEN @MonthName = 'Sep' THEN 9
            WHEN @MonthName = 'Oct' THEN 10
            WHEN @MonthName = 'Nov' THEN 11
            WHEN @MonthName = 'Dec' THEN 12
            ELSE NULL
        END;
        DECLARE @Date DATE = CAST(@dTyear + '-' + RIGHT('0' + CAST(@MonthNumber AS VARCHAR), 2) + '-01' AS DATE);
        SELECT @MonthDays=DAY(EOMONTH(@Date));

        Update AttendanceSummary
        Set MonthDays = @MonthDays where EmployeeId=@employeeId and dtMonth=@MonthName and dtYear=@dTyear  
		set @startDate=CAST(@dTyear + '-' + RIGHT('0' + CAST(@MonthNumber AS VARCHAR), 2) + '-01' AS smalldatetime);
		SET @endDate = CAST(@dTyear + '-' + RIGHT('0' + CAST(@MonthNumber AS VARCHAR), 2) + '-' + RIGHT('0' + CAST(@MonthDays AS VARCHAR), 2) AS smalldatetime);
	    Select @Present=count(*) from Attendance where Attendance.employeeId=@employeeId and dtdate between @startDate and @endDate and Attstatus='P'
        Select @Late=count(*) from Attendance where Attendance.employeeId=@employeeId and dtdate between @startDate and @endDate and Attstatus='L'
        Select @Weekend=count(*) from Attendance where Attendance.employeeId=@employeeId and dtdate between @startDate and @endDate and Attstatus='W'
        
        Declare @i int=@MonthDays
        DECLARE @CheckDate DATE = @startDate
        Declare @j int=1
		while @i>0
        Begin
            IF DATEPART(WEEKDAY, @CheckDate) = 6
            Begin
                set @Holiday=@Holiday+1
				print @holiday
            END
            set @CheckDate=CAST(@dTyear + '-' + RIGHT('0' + CAST(@MonthNumber AS VARCHAR), 2) + '-' +RIGHT('0' + CAST(@J AS VARCHAR), 2) AS smalldatetime);
			SET @i=@i-1
            set @j=@j+1

        END 
		If @MonthDays-@Present-@Holiday-@Weekend-@late>0
		Begin
		   Set @Absent=@MonthDays-@Present-@Holiday-@Weekend-@late
		End
		else
		Begin
		   Set @absent=0
		End

		
		print @Holiday
		Update AttendanceSummary
        set present=@present
        where employeeId=@employeeId and dtMonth=@MonthName and dtYear=@dtYear
        Update AttendanceSummary
        set Late=@late
        where employeeId=@employeeId and dtMonth=@MonthName and dtYear=@dtYear

        Update AttendanceSummary
        set absent=@absent
        where employeeId=@employeeId and dtMonth=@MonthName and dtYear=@dtYear
		
        Update AttendanceSummary
        set Holiday=@Holiday
        where employeeId=@employeeId and dtMonth=@MonthName and dtYear=@dtYear
     
        
        


        set @index=@index+1
        set @Total_inserted=@Total_inserted-1




       


    End
    
  

END


Create table Salary(
  EmployeeId varchar(20),
  ComId varchar(20),
  dtMonth varchar(3),
  dtYear varchar(4),
  Gross money,
  Basic money,
  Hrent money,
  Medical money,
  Others money,
  AbsentAmount money,
  PaymentAmount money,
  IsPaid bit,
  PaidAmount money,
  Constraint P_K8 Primary Key(EmployeeId,ComId,dtMonth,dtYear),
  Constraint F_K81 Foreign Key(ComId) references Company(ComId),
  Constraint F_K82 Foreign Key(EmployeeId) references Employee(EmployeeId)

)


Create Trigger Insert_on_Salary
ON Salary
For Insert,Update
As
Begin
	Declare @Total_Inserted int
	DEclare @index int=1
	Declare @AbsentAmount Money
	Declare @AbsentDays int
	Declare @PaymentAmount money
	Declare @EmployeeID Varchar(20)
	Declare @Comid varchar(20)
	DEclare @dtMonth varchar(3)
	Declare @dTYear varchar(4)
	Declare @Ispaid bit
	Declare @PaidAmount money=0
	Select @Total_inserted = count(*) from inserted
	while @Total_Inserted>0
	Begin
	Select @employeeId=temp.employeeId, @comId=comId, @dtMonth=dtMonth, @dTyear=dTyear ,@Ispaid=IsPaid
        from (Select *,ROW_NUMBER() over (order by inserted.employeeId) as RowNum from inserted )as temp where RowNum=@index


	Update Salary 
    Set Gross = (Select gross from employee where Employee.EmployeeId=@employeeId )
	where @employeeId=EmployeeId and @ComId=ComID and @dtMonth=dtMonth and @dTYear=dtYear
    Update Salary 
    Set Basic = (Select basic from employee where Employee.EmployeeId=@employeeId)
	where @employeeId=EmployeeId and @ComId=ComID and @dtMonth=dtMonth and @dTYear=dtYear

    Update Salary 
    Set Hrent = (Select Hrent from employee where Employee.EmployeeId=@employeeId)
	where @employeeId=EmployeeId and @ComId=ComID and @dtMonth=dtMonth and @dTYear=dtYear
    Update Salary 
    Set Medical = (Select Medical from employee where Employee.EmployeeId=@employeeId)
	where @employeeId=EmployeeId and @ComId=ComID and @dtMonth=dtMonth and @dTYear=dtYear
    Update Salary 
    Set Others = (Select Others from employee where Employee.EmployeeId=@employeeId)
	where @employeeId=EmployeeId and @ComId=ComID and @dtMonth=dtMonth and @dTYear=dtYear



	Set @AbsentAmount=(Select basic from employee where Employee.EmployeeId=@employeeId)/30
	print @absentAmount
	Set @AbsentDays=(Select Absent from AttendanceSummary where @employeeId=AttendanceSummary.EmployeeId and @ComId=AttendanceSummary.ComID
	                 and @dtMonth=AttendanceSummary.dtMonth and @dTYear=AttendanceSummary.dtYear)
    Print @absentDays
	Set @AbsentAmount=@AbsentDays*@AbsentAmount
	set @PaymentAmount=(Select Gross from employee where Employee.EmployeeId=@employeeId)-@AbsentAmount
	set @PaidAmount=0

	If @Ispaid=1
	Begin
	 set @paidAmount=@paymentAmount
	End
	Update Salary 
	set AbsentAmount=@AbsentAmount
	where @employeeId=EmployeeId and @ComId=ComID and @dtMonth=dtMonth and @dTYear=dtYear
	Update Salary 
	Set PaymentAmount=@PaymentAmount
	where @employeeId=EmployeeId and @ComId=ComID and @dtMonth=dtMonth and @dTYear=dtYear
	Update Salary 
	Set PaidAmount=@PaidAmount
	where @employeeId=EmployeeId and @ComId=ComID and @dtMonth=dtMonth and @dTYear=dtYear
	

	set @Total_Inserted=@Total_Inserted-1
	set @index=@index+1
	End

   

END


Create Procedure Employee_List
@DeptName Varchar(30) = '',
@DesigName varchar(20) = ''
AS
Begin
   IF @DeptName='' and @DesigName=''
   Begin
       Select e.Employeeid,e.Comid,e.DeptID,e.DesigID,e.EmpCode,e.EmpName,e.Gender,DeptName,DesigName from employee e,Department d,Designation de
       where e.DeptID=D.DeptID and e.DesigId=De.DesigID
   End
   Else if @DeptName <> '' and @DesigName <> ''
   Begin 
        Select * From (Select e.Employeeid,e.Comid,e.DeptID,e.DesigID,e.EmpCode,e.EmpName,e.Gender,DeptName as DeptName,DesigName as DesigName from employee e,Department d,Designation de
       where e.DeptID=D.DeptID and e.DesigId=De.DesigID) as temp where Deptname=@DeptName and DesigName=@DesigName

   End
   Else if @DeptName <> '' and @DesigName = ''
   Begin 
        Select * From (Select e.Employeeid,e.Comid,e.DeptID,e.DesigID,e.EmpCode,e.EmpName,e.Gender,DeptName as DeptName,DesigName as DesigName from employee e,Department d,Designation de
       where e.DeptID=D.DeptID and e.DesigId=De.DesigID) as temp where Deptname=@DeptName

   End
   Else if @DeptName = '' and @DesigName <> ''
   Begin 
        Select * From (Select e.Employeeid,e.Comid,e.DeptID,e.DesigID,e.EmpCode,e.EmpName,e.Gender,DeptName as DeptName,DesigName as DesigName from employee e,Department d,Designation de
       where e.DeptID=D.DeptID and e.DesigId=De.DesigID) as temp where DesigName=@DesigName

   End

END



Create Procedure Employee_Count
AS 

Begin
	Select Count(*) from Employee
End


Exec Employee_Count


Create Procedure Attendance_List
@dtDate smalldatetime='',
@deptname varchar(30)=''


AS
Begin
  

    Select * from (Select e.Employeeid,e.Comid,e.DeptID,e.DesigID,e.EmpCode,e.EmpName,e.Gender,a.Dtdate,a.Attstatus,d.deptname from employee e,Attendance a,department d
    where e.EmployeeID=a.EmployeeID and e.DeptId=d.deptid) as temp where dtDate=@dtDate and Attstatus='P' and deptname=@deptname



	Select * from (Select e.Employeeid,e.Comid,e.DeptID,e.DesigID,e.EmpCode,e.EmpName,e.Gender,a.Dtdate,a.Attstatus,d.DeptName from employee e,Attendance a,department d
    where e.EmployeeID=a.EmployeeID and e.DeptId=d.deptid) as temp where dtDate=@dtDate and Attstatus='L' and deptname=@deptname


  
  
	Select e.Employeeid,e.Comid,e.DeptID,e.DesigID,e.EmpCode,e.EmpName,e.Gender,d.DeptName from employee e,department d
	where e.DeptId=d.deptid and d.deptname=@deptname and e.employeeId not in (Select e.Employeeid from employee e,Attendance a,department d
    where e.EmployeeID=a.EmployeeID and e.DeptId=d.deptid and a.dtDate=@dtDate and deptname=@deptname)
	
End


create procedure monthly_attendance_summary 
@deptname varchar(30),
@dtMonth varchar(3),
@dtYear varchar(4)
as
Begin
	Select e.Employeeid,e.Comid,e.DeptID,e.DesigID,e.EmpCode,e.EmpName,e.Gender,d.deptname,a.present,a.absent,a.late,a.dtMonth,a.dtYear
	from Employee e,Department d ,AttendanceSummary a where e.deptId=d.DeptId and e.employeeId=a.employeeID and a.dtMonth=@dtMonth and
	a.dtYear=@dtYear and d.deptname=@deptname

End








-- Insert first record
INSERT INTO Company (ComId, ComName, Basic, Hrent, Medical, IsInactive)
VALUES ('C1', 'TechCorp', 50, 20, 10, 0);

-- Insert second record
INSERT INTO Company (ComId, ComName, Basic, Hrent, Medical, IsInactive)
VALUES ('C2', 'HealthInc', 60, 10, 20, 0);

-- Insert third record
INSERT INTO Company (ComId, ComName, Basic, Hrent, Medical, IsInactive)
VALUES ('C3', 'EduSystems', 40, 30, 20, 1);





INSERT INTO Department (DeptId, ComId, DeptName)
VALUES ('D1', 'C1', 'Research and Development');

INSERT INTO Department (DeptId, ComId, DeptName)
VALUES ('D2', 'C1', 'Marketing');

INSERT INTO Department (DeptId, ComId, DeptName)
VALUES ('D3', 'C1', 'Human Resources');

INSERT INTO Department (DeptId, ComId, DeptName)
VALUES ('D4', 'C2', 'Marketing');

INSERT INTO Department (DeptId, ComId, DeptName)
VALUES ('D5', 'C2', 'Human Resources');

INSERT INTO Department (DeptId, ComId, DeptName)
VALUES ('D6', 'C3', 'Marketing');

INSERT INTO Department (DeptId, ComId, DeptName)
VALUES ('D7', 'C3', 'Human Resources');



INSERT INTO Designation (DesigId, ComId, DesigName)
VALUES ('De1', 'C1', 'Manager');

INSERT INTO Designation (DesigId, ComId, DesigName)
VALUES ('De2', 'C1', 'Developer');

INSERT INTO Designation (DesigId, ComId, DesigName)
VALUES ('De3', 'C1', 'Analyst');

INSERT INTO Designation (DesigId, ComId, DesigName)
VALUES ('De4', 'C1', 'Consultant');

INSERT INTO Designation (DesigId, ComId, DesigName)
VALUES ('De5', 'C2', 'Support');

INSERT INTO Designation (DesigId, ComId, DesigName)
VALUES ('De6', 'C2', 'Consultant');

INSERT INTO Designation (DesigId, ComId, DesigName)
VALUES ('De7', 'C3', 'Support');

INSERT INTO Designation (DesigId, ComId, DesigName)
VALUES ('De8', 'C3', 'Consultant');





INSERT INTO Shift (ShiftId, ComId, ShiftName, ShiftIn, ShiftOut, ShiftLate)
VALUES ('S1', 'C1', 'Morning', '08:00:00', '17:00:00', '08:05:00');


INSERT INTO Shift (ShiftId, ComId, ShiftName, ShiftIn, ShiftOut, ShiftLate)
VALUES ('S2',  'C1', 'Weekend', '09:00:00', '17:00:00', '09:05:00');


INSERT INTO Shift (ShiftId, ComId, ShiftName, ShiftIn, ShiftOut, ShiftLate)
VALUES ('S3', 'C2', 'Morning', '09:00:00', '18:00:00', '09:03:00');


INSERT INTO Shift (ShiftId, ComId, ShiftName, ShiftIn, ShiftOut, ShiftLate)
VALUES ('S4',  'C2', 'Weekend', '10:00:00', '18:00:00', '10:03:00');

INSERT INTO Shift (ShiftId, ComId, ShiftName, ShiftIn, ShiftOut, ShiftLate)
VALUES ('S5', 'C3', 'Morning', '8:30:00', '18:00:00', '08:31:00');


INSERT INTO Shift (ShiftId, ComId, ShiftName, ShiftIn, ShiftOut, ShiftLate)
VALUES ('S6',  'C3', 'Weekend', '09:30:00', '18:00:00', '09:31:00');








INSERT INTO Employee (EmployeeId, ComId, DeptId, DesigId, ShiftId, EmpCode, EmpName, Gender, Gross, dtjoin) VALUES
('E1', 'C1', 'D1', 'De1', 'S1', 'EMP001', 'John Doe', 'Male', 50000, '2020-06-18'),
('E2', 'C1', 'D1', 'De2', 'S1', 'EMP002', 'Jane Smith', 'Female', 52000, '2020-06-19'),
('E3', 'C1', 'D2', 'De3', 'S1', 'EMP003', 'Michael Johnson', 'Male', 48000, '2020-06-20'),
('E4', 'C1', 'D2', 'De4', 'S1', 'EMP004', 'Emily Davis', 'Female', 47000, '2020-06-21'),
('E5', 'C1', 'D3', 'De1', 'S1', 'EMP005', 'Chris Brown', 'Male', 51000, '2020-06-22'),
('E6', 'C1', 'D3', 'De2', 'S1', 'EMP006', 'Anna Wilson', 'Female', 53000, '2020-06-23'),
('E7', 'C1', 'D1', 'De3', 'S1', 'EMP007', 'David Moore', 'Male', 49000, '2020-06-24'),
('E8', 'C1', 'D1', 'De4', 'S1', 'EMP008', 'Emma Taylor', 'Female', 46000, '2020-06-25'),
('E9', 'C1', 'D2', 'De1', 'S1', 'EMP009', 'Daniel Anderson', 'Male', 50000, '2020-06-26'),
('E10', 'C1', 'D2', 'De2', 'S1', 'EMP010', 'Sophia Thomas', 'Female', 52000, '2020-06-27'),
('E11', 'C1', 'D3', 'De3', 'S1', 'EMP011', 'Matthew Jackson', 'Male', 48000, '2020-06-28'),
('E12', 'C1', 'D3', 'De4', 'S1', 'EMP012', 'Olivia White', 'Female', 47000, '2020-06-29'),
('E13', 'C1', 'D1', 'De1', 'S1', 'EMP013', 'Joseph Harris', 'Male', 51000, '2020-06-30'),
('E14', 'C1', 'D1', 'De2', 'S1', 'EMP014', 'Ava Martin', 'Female', 53000, '2020-07-01'),
('E15', 'C1', 'D2', 'De3', 'S1', 'EMP015', 'William Lee', 'Male', 49000, '2020-07-02');



INSERT INTO Employee (EmployeeId, ComId, DeptId, DesigId, ShiftId, EmpCode, EmpName, Gender, Gross, dtjoin) VALUES
('E16', 'C2', 'D4', 'De5', 'S3', 'EMP016', 'Liam King', 'Male', 60000, '2021-01-01'),
('E17', 'C2', 'D4', 'De6', 'S3', 'EMP017', 'Emma Scott', 'Female', 61000, '2021-01-02'),
('E18', 'C2', 'D5', 'De5', 'S3', 'EMP018', 'Noah Allen', 'Male', 62000, '2021-01-03'),
('E19', 'C2', 'D5', 'De6', 'S3', 'EMP019', 'Olivia Wright', 'Female', 63000, '2021-01-04'),
('E20', 'C2', 'D4', 'De5', 'S3', 'EMP020', 'William Hill', 'Male', 64000, '2021-01-05'),
('E21', 'C2', 'D4', 'De6', 'S3', 'EMP021', 'Sophia Green', 'Female', 65000, '2021-01-06'),
('E22', 'C2', 'D5', 'De5', 'S3', 'EMP022', 'James Baker', 'Male', 66000, '2021-01-07'),
('E23', 'C2', 'D5', 'De6', 'S3', 'EMP023', 'Isabella Adams', 'Female', 67000, '2021-01-08'),
('E24', 'C2', 'D4', 'De5', 'S3', 'EMP024', 'Benjamin Nelson', 'Male', 68000, '2021-01-09'),
('E25', 'C2', 'D4', 'De6', 'S3', 'EMP025', 'Charlotte Carter', 'Female', 69000, '2021-01-10'),
('E26', 'C2', 'D5', 'De5', 'S3', 'EMP026', 'Lucas Mitchell', 'Male', 70000, '2021-01-11'),
('E27', 'C2', 'D5', 'De6', 'S3', 'EMP027', 'Amelia Perez', 'Female', 71000, '2021-01-12'),
('E28', 'C2', 'D4', 'De5', 'S3', 'EMP028', 'Henry Roberts', 'Male', 72000, '2021-01-13'),
('E29', 'C2', 'D4', 'De6', 'S3', 'EMP029', 'Mia Turner', 'Female', 73000, '2021-01-14'),
('E30', 'C2', 'D5', 'De5', 'S3', 'EMP030', 'Alexander Phillips', 'Male', 74000, '2021-01-15');

INSERT INTO Employee (EmployeeId, ComId, DeptId, DesigId, ShiftId, EmpCode, EmpName, Gender, Gross, dtjoin) VALUES
('E31', 'C3', 'D6', 'De7', 'S5', 'EMP031', 'Ethan Davis', 'Male', 75000, '2022-01-01'),
('E32', 'C3', 'D6', 'De8', 'S5', 'EMP032', 'Ava Brown', 'Female', 76000, '2022-01-02'),
('E33', 'C3', 'D7', 'De7', 'S5', 'EMP033', 'Mason Wilson', 'Male', 77000, '2022-01-03'),
('E34', 'C3', 'D7', 'De8', 'S5', 'EMP034', 'Sophia Martinez', 'Female', 78000, '2022-01-04'),
('E35', 'C3', 'D6', 'De7', 'S5', 'EMP035', 'Logan Anderson', 'Male', 79000, '2022-01-05'),
('E36', 'C3', 'D6', 'De8', 'S5', 'EMP036', 'Isabella Thomas', 'Female', 80000, '2022-01-06'),
('E37', 'C3', 'D7', 'De7', 'S5', 'EMP037', 'Lucas Taylor', 'Male', 81000, '2022-01-07'),
('E38', 'C3', 'D7', 'De8', 'S5', 'EMP038', 'Mia Harris', 'Female', 82000, '2022-01-08'),
('E39', 'C3', 'D6', 'De7', 'S5', 'EMP039', 'Oliver Clark', 'Male', 83000, '2022-01-09'),
('E40', 'C3', 'D6', 'De8', 'S5', 'EMP040', 'Charlotte Lewis', 'Female', 84000, '2022-01-10'),
('E41', 'C3', 'D7', 'De7', 'S5', 'EMP041', 'Elijah Lee', 'Male', 85000, '2022-01-11'),
('E42', 'C3', 'D7', 'De8', 'S5', 'EMP042', 'Amelia Walker', 'Female', 86000, '2022-01-12'),
('E43', 'C3', 'D6', 'De7', 'S5', 'EMP043', 'James Hall', 'Male', 87000, '2022-01-13'),
('E44', 'C3', 'D6', 'De8', 'S5', 'EMP044', 'Harper Allen', 'Female', 88000, '2022-01-14'),
('E45', 'C3', 'D7', 'De7', 'S5', 'EMP045', 'Sebastian Young', 'Male', 89000, '2022-01-15');





















INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E1', 'C1', '2024-06-01', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-02', '08:05:00', '17:05:00'),
('E1', 'C1', '2024-06-03', '08:10:00', '17:10:00'),
('E1', 'C1', '2024-06-04', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-05', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-06', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-08', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-09', '08:05:00', '17:05:00'),
('E1', 'C1', '2024-06-12', '08:10:00', '17:10:00'),
('E1', 'C1', '2024-06-13', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-15', '08:20:00', '17:20:00'),
('E1', 'C1', '2024-06-16', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-17', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-18', '08:05:00', '17:05:00'),
('E1', 'C1', '2024-06-20', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-21', '08:15:00', '17:15:00'),
('E1', 'C1', '2024-06-22', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-23', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-24', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-26', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-27', '08:00:00', '17:00:00'),
('E1', 'C1', '2024-06-29', '08:10:00', '17:10:00'),
('E1', 'C1', '2024-06-30', '08:00:00', '17:00:00');

INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E3', 'C1', '2024-06-01', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-02', '08:05:00', '17:05:00'), -- Present
('E3', 'C1', '2024-06-03', '08:10:00', '17:10:00'), -- Present
('E3', 'C1', '2024-06-04', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-05', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-06', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-08', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-09', '08:05:00', '17:05:00'), -- Present
('E3', 'C1', '2024-06-12', '08:10:00', '17:10:00'), -- Present
('E3', 'C1', '2024-06-13', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-15', '08:20:00', '17:20:00'), -- Present
('E3', 'C1', '2024-06-16', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-17', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-18', '08:05:00', '17:05:00'), -- Present
('E3', 'C1', '2024-06-20', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-21', '08:15:00', '17:15:00'), -- Present
('E3', 'C1', '2024-06-22', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-23', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-24', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-26', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-27', '08:00:00', '17:00:00'), -- Present
('E3', 'C1', '2024-06-29', '08:10:00', '17:10:00'), -- Present
('E3', 'C1', '2024-06-30', '08:00:00', '17:00:00') -- Present
INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E4', 'C1', '2024-06-01', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-02', '08:05:00', '17:05:00'), -- Present
('E4', 'C1', '2024-06-03', '08:10:00', '17:10:00'), -- Present
('E4', 'C1', '2024-06-04', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-05', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-06', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-08', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-09', '08:05:00', '17:05:00'), -- Present
('E4', 'C1', '2024-06-12', '08:10:00', '17:10:00'), -- Present
('E4', 'C1', '2024-06-13', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-15', '08:20:00', '17:20:00'), -- Present
('E4', 'C1', '2024-06-16', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-17', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-18', '08:05:00', '17:05:00'), -- Present
('E4', 'C1', '2024-06-20', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-21', '08:15:00', '17:15:00'), -- Present
('E4', 'C1', '2024-06-22', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-23', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-24', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-26', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-27', '08:00:00', '17:00:00'), -- Present
('E4', 'C1', '2024-06-29', '08:10:00', '17:10:00'), -- Present
('E4', 'C1', '2024-06-30', '08:00:00', '17:00:00') -- Present
INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E5', 'C1', '2024-06-01', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-02', '08:05:00', '17:05:00'), -- Present
('E5', 'C1', '2024-06-03', '08:10:00', '17:10:00'), -- Present
('E5', 'C1', '2024-06-04', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-05', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-06', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-08', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-09', '08:05:00', '17:05:00'), -- Present
('E5', 'C1', '2024-06-12', '08:10:00', '17:10:00'), -- Present
('E5', 'C1', '2024-06-13', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-15', '08:20:00', '17:20:00'), -- Present
('E5', 'C1', '2024-06-16', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-17', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-18', '08:05:00', '17:05:00'), -- Present
('E5', 'C1', '2024-06-20', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-21', '08:15:00', '17:15:00'), -- Present
('E5', 'C1', '2024-06-22', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-23', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-24', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-26', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-27', '08:00:00', '17:00:00'), -- Present
('E5', 'C1', '2024-06-29', '08:10:00', '17:10:00'), -- Present
('E5', 'C1', '2024-06-30', '08:00:00', '17:00:00') -- Present











-- Attendance records for Employee E16 (Company C1, Shift 2)
INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E16', 'C2', '2024-06-01', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-02', '09:05:00', '18:05:00'), -- Present
('E16', 'C2', '2024-06-03', '09:10:00', '18:10:00'), -- Present
('E16', 'C2', '2024-06-04', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-05', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-06', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-08', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-09', '09:05:00', '18:05:00'), -- Present
('E16', 'C2', '2024-06-12', '09:10:00', '18:10:00'), -- Present
('E16', 'C2', '2024-06-13', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-15', '09:20:00', '18:20:00'), -- Present
('E16', 'C2', '2024-06-16', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-17', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-18', '09:05:00', '18:05:00'), -- Present
('E16', 'C2', '2024-06-20', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-21', '09:15:00', '18:15:00'), -- Present
('E16', 'C2', '2024-06-22', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-23', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-24', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-26', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-27', '09:00:00', '18:00:00'), -- Present
('E16', 'C2', '2024-06-29', '09:10:00', '18:10:00'), -- Present
('E16', 'C2', '2024-06-30', '09:00:00', '18:00:00') -- Present


-- Attendance records for Employee E17 (Company C1, Shift 2)
INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E17', 'C2', '2024-06-01', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-02', '09:05:00', '18:05:00'), -- Present
('E17', 'C2', '2024-06-03', '09:10:00', '18:10:00'), -- Present
('E17', 'C2', '2024-06-04', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-05', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-06', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-08', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-09', '09:05:00', '18:05:00'), -- Present
('E17', 'C2', '2024-06-12', '09:10:00', '18:10:00'), -- Present
('E17', 'C2', '2024-06-13', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-15', '09:20:00', '18:20:00'), -- Present
('E17', 'C2', '2024-06-16', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-17', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-18', '09:05:00', '18:05:00'), -- Present
('E17', 'C2', '2024-06-20', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-21', '09:15:00', '18:15:00'), -- Present
('E17', 'C2', '2024-06-22', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-23', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-24', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-26', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-27', '09:00:00', '18:00:00'), -- Present
('E17', 'C2', '2024-06-29', '09:10:00', '18:10:00'), -- Present
('E17', 'C2', '2024-06-30', '09:00:00', '18:00:00') -- Present


-- Attendance records for Employee E18 (Company C1, Shift 2)
INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E18', 'C2', '2024-06-01', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-02', '09:05:00', '18:05:00'), -- Present
('E18', 'C2', '2024-06-03', '09:10:00', '18:10:00'), -- Present
('E18', 'C2', '2024-06-04', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-05', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-06', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-08', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-09', '09:05:00', '18:05:00'), -- Present
('E18', 'C2', '2024-06-12', '09:10:00', '18:10:00'), -- Present
('E18', 'C2', '2024-06-13', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-15', '09:20:00', '18:20:00'), -- Present
('E18', 'C2', '2024-06-16', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-17', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-18', '09:05:00', '18:05:00'), -- Present
('E18', 'C2', '2024-06-20', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-21', '09:15:00', '18:15:00'), -- Present
('E18', 'C2', '2024-06-22', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-23', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-24', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-26', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-27', '09:00:00', '18:00:00'), -- Present
('E18', 'C2', '2024-06-29', '09:10:00', '18:10:00'), -- Present
('E18', 'C2', '2024-06-30', '09:00:00', '18:00:00') -- Present


-- Attendance records for Employee E19 (Company C1, Shift 2)
INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E19', 'C2', '2024-06-01', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-02', '09:05:00', '18:05:00'), -- Present
('E19', 'C2', '2024-06-03', '09:10:00', '18:10:00'), -- Present
('E19', 'C2', '2024-06-04', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-05', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-06', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-08', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-09', '09:05:00', '18:05:00'), -- Present
('E19', 'C2', '2024-06-12', '09:10:00', '18:10:00'), -- Present
('E19', 'C2', '2024-06-13', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-15', '09:20:00', '18:20:00'), -- Present
('E19', 'C2', '2024-06-16', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-17', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-18', '09:05:00', '18:05:00'), -- Present
('E19', 'C2', '2024-06-20', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-21', '09:15:00', '18:15:00'), -- Present
('E19', 'C2', '2024-06-22', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-23', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-24', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-26', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-27', '09:00:00', '18:00:00'), -- Present
('E19', 'C2', '2024-06-29', '09:10:00', '18:10:00'), -- Present
('E19', 'C2', '2024-06-30', '09:00:00', '18:00:00') -- Present


-- Attendance records for Employee E20 (Company C1, Shift 2)
INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E20', 'C2', '2024-06-01', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-02', '09:05:00', '18:05:00'), -- Present
('E20', 'C2', '2024-06-03', '09:10:00', '18:10:00'), -- Present
('E20', 'C2', '2024-06-04', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-05', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-06', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-08', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-09', '09:05:00', '18:05:00'), -- Present
('E20', 'C2', '2024-06-12', '09:10:00', '18:10:00'), -- Present
('E20', 'C2', '2024-06-13', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-15', '09:20:00', '18:20:00'), -- Present
('E20', 'C2', '2024-06-16', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-17', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-18', '09:05:00', '18:05:00'), -- Present
('E20', 'C2', '2024-06-20', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-21', '09:15:00', '18:15:00'), -- Present
('E20', 'C2', '2024-06-22', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-23', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-24', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-26', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-27', '09:00:00', '18:00:00'), -- Present
('E20', 'C2', '2024-06-29', '09:10:00', '18:10:00'), -- Present
('E20', 'C2', '2024-06-30', '09:00:00', '18:00:00') -- Present











-- Attendance records for Employee E31 (Company C1, Shift 5)
INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E31', 'C3', '2024-06-01', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-02', '08:35:00', '18:05:00'), -- Present
('E31', 'C3', '2024-06-03', '08:40:00', '18:10:00'), -- Present
('E31', 'C3', '2024-06-04', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-05', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-06', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-08', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-09', '08:35:00', '18:05:00'), -- Present
('E31', 'C3', '2024-06-12', '08:40:00', '18:10:00'), -- Present
('E31', 'C3', '2024-06-13', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-15', '08:50:00', '18:20:00'), -- Present
('E31', 'C3', '2024-06-16', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-17', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-18', '08:35:00', '18:05:00'), -- Present
('E31', 'C3', '2024-06-20', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-21', '08:45:00', '18:15:00'), -- Present
('E31', 'C3', '2024-06-22', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-23', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-24', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-26', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-27', '08:30:00', '18:00:00'), -- Present
('E31', 'C3', '2024-06-29', '08:40:00', '18:10:00'), -- Present
('E31', 'C3', '2024-06-30', '08:30:00', '18:00:00') -- Present


-- Attendance records for Employee E32 (Company C1, Shift 5)
INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E32', 'C3', '2024-06-01', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-02', '08:35:00', '18:05:00'), -- Present
('E32', 'C3', '2024-06-03', '08:40:00', '18:10:00'), -- Present
('E32', 'C3', '2024-06-04', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-05', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-06', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-08', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-09', '08:35:00', '18:05:00'), -- Present
('E32', 'C3', '2024-06-12', '08:40:00', '18:10:00'), -- Present
('E32', 'C3', '2024-06-13', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-15', '08:50:00', '18:20:00'), -- Present
('E32', 'C3', '2024-06-16', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-17', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-18', '08:35:00', '18:05:00'), -- Present
('E32', 'C3', '2024-06-20', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-21', '08:45:00', '18:15:00'), -- Present
('E32', 'C3', '2024-06-22', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-23', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-24', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-26', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-27', '08:30:00', '18:00:00'), -- Present
('E32', 'C3', '2024-06-29', '08:40:00', '18:10:00'), -- Present
('E32', 'C3', '2024-06-30', '08:30:00', '18:00:00') -- Present


-- Attendance records for Employee E33 (Company C1, Shift 5)
INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E33', 'C3', '2024-06-01', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-02', '08:35:00', '18:05:00'), -- Present
('E33', 'C3', '2024-06-03', '08:40:00', '18:10:00'), -- Present
('E33', 'C3', '2024-06-04', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-05', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-06', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-08', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-09', '08:35:00', '18:05:00'), -- Present
('E33', 'C3', '2024-06-12', '08:40:00', '18:10:00'), -- Present
('E33', 'C3', '2024-06-13', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-15', '08:50:00', '18:20:00'), -- Present
('E33', 'C3', '2024-06-16', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-17', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-18', '08:35:00', '18:05:00'), -- Present
('E33', 'C3', '2024-06-20', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-21', '08:45:00', '18:15:00'), -- Present
('E33', 'C3', '2024-06-22', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-23', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-24', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-26', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-27', '08:30:00', '18:00:00'), -- Present
('E33', 'C3', '2024-06-29', '08:40:00', '18:10:00'), -- Present
('E33', 'C3', '2024-06-30', '08:30:00', '18:00:00') -- Present


-- Attendance records for Employee E34 (Company C1, Shift 5)
INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E34', 'C3', '2024-06-01', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-02', '08:35:00', '18:05:00'), -- Present
('E34', 'C3', '2024-06-03', '08:40:00', '18:10:00'), -- Present
('E34', 'C3', '2024-06-04', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-05', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-06', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-08', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-09', '08:35:00', '18:05:00'), -- Present
('E34', 'C3', '2024-06-12', '08:40:00', '18:10:00'), -- Present
('E34', 'C3', '2024-06-13', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-15', '08:50:00', '18:20:00'), -- Present
('E34', 'C3', '2024-06-16', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-17', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-18', '08:35:00', '18:05:00'), -- Present
('E34', 'C3', '2024-06-20', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-21', '08:45:00', '18:15:00'), -- Present
('E34', 'C3', '2024-06-22', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-23', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-24', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-26', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-27', '08:30:00', '18:00:00'), -- Present
('E34', 'C3', '2024-06-29', '08:40:00', '18:10:00'), -- Present
('E34', 'C3', '2024-06-30', '08:30:00', '18:00:00')-- Present


-- Attendance records for Employee E35 (Company C1, Shift 5)
INSERT INTO Attendance (EmployeeId, ComId, dtDate, Timein, Timeout)
VALUES 
('E35', 'C3', '2024-06-01', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-02', '08:35:00', '18:05:00'), -- Present
('E35', 'C3', '2024-06-03', '08:40:00', '18:10:00'), -- Present
('E35', 'C3', '2024-06-04', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-05', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-06', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-08', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-09', '08:35:00', '18:05:00'), -- Present
('E35', 'C3', '2024-06-12', '08:40:00', '18:10:00'), -- Present
('E35', 'C3', '2024-06-13', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-15', '08:50:00', '18:20:00'), -- Present
('E35', 'C3', '2024-06-16', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-17', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-18', '08:35:00', '18:05:00'), -- Present
('E35', 'C3', '2024-06-20', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-21', '08:45:00', '18:15:00'), -- Present
('E35', 'C3', '2024-06-22', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-23', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-24', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-26', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-27', '08:30:00', '18:00:00'), -- Present
('E35', 'C3', '2024-06-29', '08:40:00', '18:10:00'), -- Present
('E35', 'C3', '2024-06-30', '08:30:00', '18:00:00') -- Present




INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E1', 'C1', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E2', 'C1', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E3', 'C1', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E4', 'C1', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E5', 'C1', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E16', 'C2', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E17', 'C2', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E18', 'C2', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E19', 'C2', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E20', 'C2', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E31', 'C3', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E32', 'C3', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E33', 'C3', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E34', 'C3', 'Jun', '2024');
    INSERT INTO AttendanceSummary (EmployeeId, ComId, dtMonth, dtYear)
VALUES 
    ('E35', 'C3', 'Jun', '2024');






    

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E1', 'C1', 'Jun', '2024',0);
    INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E2', 'C1', 'Jun', '2024',0);

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E3', 'C1', 'Jun', '2024',0);

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E4', 'C1', 'Jun', '2024',0);

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E5', 'C1', 'Jun', '2024',0);

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E16', 'C2', 'Jun', '2024',0);

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E17', 'C2', 'Jun', '2024',0);

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E18', 'C2', 'Jun', '2024',0);

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E19', 'C2', 'Jun', '2024',0);

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E20', 'C2', 'Jun', '2024',0);

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E31', 'C3', 'Jun', '2024',0);

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E32', 'C3', 'Jun', '2024',0);
INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E33', 'C3', 'Jun', '2024',0);

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E34', 'C3', 'Jun', '2024',0);

INSERT INTO Salary (EmployeeId, ComId, dtMonth, dtYear,ispaid)
VALUES 
    ('E35', 'C3', 'Jun', '2024',0);




exec employee_list
Exec employee_list @DeptName = 'Marketing';
Exec employee_list @DeptName = 'Marketing',@DesigName='Support';


Create Procedure Employee_Count
AS 

Begin
	Select Count(*) from Employee
End


Exec Employee_Count

Exec employee_list @DeptName = 'Marketing';
Exec Attendance_List '2024-06-01','Marketing';





Exec employee_list @DeptName = 'Research and Development';
exec monthly_attendance_summary 'Research and Development','Jun','2024'



INSERT INTO Company (ComId, ComName, Basic, Hrent, Medical, IsInactive)
VALUES ('C4', 'GTR', 50, 30, 10, 1);
INSERT INTO Department (DeptId, ComId, DeptName)
VALUES ('D8', 'C4', 'Human Resources');

INSERT INTO Designation (DesigId, ComId, DesigName)
VALUES ('De9', 'C4', 'Consultant');



INSERT INTO Shift (ShiftId, ComId, ShiftName, ShiftIn, ShiftOut, ShiftLate)
VALUES ('S7',  'C4', 'Morning', '09:30:00', '18:00:00', '09:31:00');

INSERT INTO Employee (EmployeeId, ComId, DeptId, DesigId, ShiftId, EmpCode, EmpName, Gender, Gross, dtjoin) VALUES
('E46', 'C4', 'D8', 'De9', 'S7', 'EMP046', 'John Doe', 'Male', 12000, '2020-06-18')

select * from Employee where EmployeeId='E46' 


Update Salary 
Set Ispaid=1
Where  EmployeeId='E1' and ComID='C1' and dtMonth='Jun' and dtYear='2024'



Create Procedure Salary_Dept
@deptname varchar(30)=''

As 
Begin
  Select e.Employeeid,e.Comid,e.DeptID,e.DesigID,e.EmpCode,e.EmpName,e.Gender,d.deptname,s.gross,s.basic,s.hrent,s.Medical,s.others 
  from employee as e,department as d,salary as s 
  where e.deptId=d.deptId and e.employeeID=s.employeeID and d.deptname=@deptname

End


Salary_Dept 'Marketing'








Alter procedure Salary_summary_deptwise
@deptname varchar(30)='',
@Comid Varchar(20)=''
As 
Begin
    If @deptname=''
    Begin
    Select Sum(s.gross),d.deptname,e.comId from salary s ,department d,employee e 
    where e.deptId=d.deptId and s.employeeID=e.employeeID and e.comId=@comId
    group by d.deptname,e.comId

    End
    else
    Begin
		Select * from salary s,department d,employee e 
        where e.deptId=d.deptId and s.employeeID=e.employeeID and d.deptname=@deptname and e.comId=@comId
        Select Sum(s.Gross) from salary s,department d,employee e 
        where e.deptId=d.deptId and s.employeeID=e.employeeID and d.deptname=@deptname and e.comId=@comId
    End

End



Salary_summary_deptwise @deptname='Marketing', @comid='c1'



