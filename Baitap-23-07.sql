create database StudentTestDB;
use StudentTestDB;
create table Student(
RN int primary key,
Name nvarchar(20),
Age tinyint,
status nvarchar(10)
);
create table Test(
TestID int primary key,
Name nvarchar(20)
);
create table StudentTest(
RN int,
TestID int,
Date Date,
Mark float,
foreign key (RN) references Student(RN),
foreign key (TestID) references Test(TestID)
);
alter table StudentTest
add primary key (RN,TestID);
insert into Student (RN,Name,Age)
value (1,"Nguyen Hong Ha",20),
(2,"Truong Ngoc Anh",30),
(3,"Tuan Minh",25),
(4,"Dan Truong",25);
insert into Test (TestID,Name)
value (1,"EPC"),
(2,"DWMX"),
(3,"SQL1"),
(4,"SQL2");
insert into StudentTest (RN,TestID,Date,Mark)
value (1,1,"2006/07/17",8),
(1,2,"2006/07/18",5),
(1,3,"2006/07/19",7),
(2,1,"2006/07/17",7),
(2,2,"2006/07/18",4),
(2,3,"2006/07/19",2),
(3,1,"2006/07/17",10),
(3,3,"2006/07/18",1);
select * from StudentTest;
select Student.* from Student left join StudentTest on StudentTest.RN = Student.RN
where Student.RN not in (select RN from StudentTest);

select Student.Name as "Student Name", Test.Name as "Test Name", Mark,Date from StudentTest
join Student on Student.RN = StudentTest.RN
join Test on Test.TestID = StudentTest.TestID
where Mark < 5;

select Student.Name as "Student Name", avg(Mark) as Average from StudentTest
join Student on Student.RN = StudentTest.RN
group by StudentTest.RN
order by Average DESC;

select Student.Name as "Student Name", avg(Mark) as Average from StudentTest
join Student on Student.RN = StudentTest.RN
group by StudentTest.RN
having Average > any (select avg(Mark) from StudentTest);

select Test.Name as "Test Name", max(Mark) as "Max" from StudentTest
join Test on Test.TestID = StudentTest.TestID
group by StudentTest.TestID
order by Test.Name;

select Student.Name as "Student Name", Test.Name as "Test Name" from Student
left join StudentTest on Student.RN = StudentTest.RN
left join Test on StudentTest.TestID = Test.TestID;

update Student set Age = Age + 1;

update Student set Status = Case when Age < 30 then "Young" else "Old" end;

create view vwStudentTestList as 
select Student.Name as "Student Name", Test.Name as "Test Name", Mark,Date from StudentTest
join Student on Student.RN = StudentTest.RN
join Test on Test.TestID = StudentTest.TestID
order by Date asc;

Delimiter //
Create Trigger tgSetStatus
before update 
on Student
for each row
begin
set new.Status = case when new.Age < 30 then "Young" else "Old" end;
end;
//

Drop Procedure if exists spViewStatus;
Delimiter //
Create Procedure spViewStatus (in StudentName nvarchar(20),in TestName nvarchar(20))
Begin
If exists(select Student.Name as SName from Student
where Student.Name = StudentName) 
and 
exists (Select Test.Name as TName from Test
where Test.Name = TestName)
then 
	if (select Student.RN from Student
		where Student.Name = StudentName) not in (select RN from StudentTest
        join Test on Test.TestID = StudentTest.TestID
        where Test.Name = TestName)
		then 
			(select Name, "Chua Thi" as Status from Student
			where Name = StudentName);
	else
		select SName, (case when Mark >= 5 then "Do" else "Truot" end) as Status
		from
		(select Student.Name as SName, Test.Name as TName,Mark from Student
		left join StudentTest on Student.RN = StudentTest.RN
		left join Test on StudentTest.TestID = Test.TestID) as T
		where SName = StudentName and TName = TestName;
	end if;
else 
select "Khong Tim Thay";
end if;
End;
//

call spViewStatus ("Nguyen Hong Ha","SQL2")