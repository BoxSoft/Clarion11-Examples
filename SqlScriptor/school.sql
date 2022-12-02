CREATE TABLE Students(
   Number INTEGER NOT NULL,
   FirstName CHAR(20),
   LastName CHAR(20),
   Address CHAR(20),
   Address2 CHAR(20),
   City CHAR(20),
   State CHAR(2),
   Zip INTEGER,
   Telephone CHAR(12),
   Major INTEGER,
   GradYear INTEGER,
   Photograph CLOB,
   CONSTRAINT KeyStudentNumber PRIMARY KEY (Number));
CREATE INDEX MajorKey ON Students(Major,LastName,FirstName);
CREATE INDEX KeyLastName ON Students(LastName);
CREATE INDEX KeyGradYear ON Students(GradYear,LastName,FirstName);

CREATE TABLE Teachers(
   Number INTEGER,
   FirstName CHAR(20),
   LastName CHAR(20),
   Address CHAR(20),
   City CHAR(20),
   State CHAR(2),
   Zip INTEGER,
   Telephone CHAR(12),
   Department INTEGER,
   CONSTRAINT KeyTeacherNumber PRIMARY KEY (Number));
CREATE INDEX KeyLastName2 ON Teachers(LastName);
CREATE INDEX KeyDepartment ON Teachers(Department);

CREATE TABLE Classes(
   ClassNumber INTEGER NOT NULL,
   CourseNumber INTEGER,
   TeacherNumber INTEGER,
   RoomNumber INTEGER NOT NULL,
   ScheduledTime CHAR(20) NOT NULL,
   CONSTRAINT KeyClassNumber PRIMARY KEY (ClassNumber));
CREATE INDEX KeyCourseNumber ON Classes(CourseNumber,ClassNumber);
CREATE INDEX KeyTeacherNumber2 ON Classes(TeacherNumber);

CREATE TABLE Enrollment(
   StudentNumber INTEGER,
   ClassNumber INTEGER,
   MidtermExam SMALLINT,
   FinalExam SMALLINT,
   TermPaper SMALLINT,
   CONSTRAINT StuSeq UNIQUE (StudentNumber,ClassNumber),
   CONSTRAINT SeqStu UNIQUE (ClassNumber,StudentNumber));

CREATE TABLE Courses(
   Number INTEGER,
   Description CHAR(40),
   CompleteDescription CLOB,
   CONSTRAINT KeyNumber PRIMARY KEY (Number));
CREATE INDEX KeyDescription ON Courses(Description);

CREATE TABLE majors(
   Number INTEGER,
   Description CHAR(20),
   CONSTRAINT KeyNumber2 PRIMARY KEY (Number),
   CONSTRAINT KeyDescription2 UNIQUE (Description));

