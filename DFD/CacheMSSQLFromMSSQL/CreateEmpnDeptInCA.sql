USE CA;
SET QUOTED_IDENTIFIER ON
CREATE TABLE dbo.employee(
   EmpNumber CHAR(10),
   FirstName CHAR(20),
   LastName CHAR(20),
   Department INT,
   CONSTRAINT "Key" PRIMARY KEY (EmpNumber))

CREATE INDEX DeptKey ON dbo.employee(Department)

CREATE INDEX NameKey ON dbo.employee(LastName,FirstName)


CREATE TABLE dbo.department(
   Department INT,
   Description CHAR(30),
   CONSTRAINT Key2 PRIMARY KEY (Department),
   CONSTRAINT DescKey UNIQUE (Description))


ALTER TABLE dbo.employee ADD
   CONSTRAINT DeptKey FOREIGN KEY (Department)
   REFERENCES dbo.department(Department)


