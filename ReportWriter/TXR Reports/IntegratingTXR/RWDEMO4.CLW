! This program demonstrates how to use an already open file when calling the
! C%V%PRLB%X% DLL

  PROGRAM

  MAP
    StopOnError
  END

  INCLUDE('RWPRLIB.INC'),ONCE

demofile FILE,PRE(demo),DRIVER('TOPSPEED'),CREATE,NAME('rwdemo4.tps')
KeyStudentNumber KEY(demo:Number),NOCASE,OPT
MajorKey  KEY(demo:Major,demo:LastName,demo:FirstName),DUP,NOCASE,OPT
KeyLastName KEY(demo:LastName),DUP,NOCASE
KeyGradYear KEY(-demo:GradYear,demo:LastName,demo:FirstName),DUP,NOCASE,OPT
Photo     MEMO(64000),BINARY
__Record  RECORD
Number      LONG
FirstName   STRING(20)
LastName    STRING(20)
Address     STRING(20)
Address2    STRING(20)
City        STRING(20)
State       STRING(2)
Zip         LONG
Telephone   STRING(12)
Major       LONG
GradYear    LONG
          END
        END


C CLASS(ReportEngine)
AttachOpenFile   PROCEDURE(STRING label),*FILE,DERIVED ! To attach my own file
  END

  CODE

    CREATE(demofile)                    ! Create a demo file
    StopOnError
    OPEN(demofile,12H)
    StopOnError
    demo:FirstName = 'Tiny'
    demo:LastName = 'Montgomery'
    demo:Major = 5
    ADD(demofile)
    StopOnError
    demo:FirstName = 'Crackity'
    demo:LastName = 'Jones'
    demo:Major = 3
    ADD(demofile)
    StopOnError
    demo:FirstName = 'Sebastian'
    demo:LastName = 'Belle'
    demo:Major = 2
    ADD(demofile)
    StopOnError
    demo:FirstName = 'Anne'
    demo:LastName = 'Cecelia'
    demo:Major = 2
    ADD(demofile)
    StopOnError


    C.LoadReportLibrary('rwdemo2.txr')  ! Load report library
    StopOnError
    C.SetPreview()
    StopOnError

    ! Override the report order
    C.SetReportOrder('Report1','UPPER(demo:FirstName)')
    ! Override the report filter
    C.SetReportFilter('Report1','demo:Major<<=3')


    C.PrintReport('Report1')                    ! Print report
    StopOnError
    C.UnloadReportLibrary
    StopOnError

    CLOSE(demofile)                     ! close after report printed
    StopOnError

StopOnError PROCEDURE
  CODE
    IF ERRORCODE() = 90 THEN
      STOP(CLIP(FILEERROR()) & ' (' & CLIP(FILEERRORCODE()) & ')')
    ELSIF ERRORCODE()<>0 THEN
      STOP(CLIP(ERROR()) & ' (' & ERRORCODE() & ')')
    END

C.AttachOpenFile  PROCEDURE (STRING label)
! This attaches my file (demofile) students rather than the file STUDENTS.TPS
! Note that you the file must be open
  CODE
    IF label='students' THEN                ! file we which to override

      BIND('stu:Major',demo:Major)          ! NB These require to be bound as they are used
      BIND('stu:LastName',demo:LastName)    ! in formula within this report
                                            ! and they have a different prefix

      RETURN demofile                       ! My file

    END
    RETURN Parent.AttachOpenFile(label)     ! leave others default

