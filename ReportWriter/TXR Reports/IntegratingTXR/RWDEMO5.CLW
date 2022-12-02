! This progran demonstrates how the file handling of C%V%PRLB%X% can be
! completely overridden (the example prints from a queue rather than a file)

  PROGRAM
  MAP
    StopOnError
  END

  INCLUDE('RWPRLIB.INC'),ONCE
  INCLUDE('ABERROR.INC'),ONCE

Q QUEUE,PRE(Q)
Title  STRING(40),NAME('BookTitle')
Author STRING(30),NAME('BookAuthor')
  END

QPos SHORT


C CLASS(ReportEngine)
Reset        PROCEDURE(),LONG,DERIVED ! returns records to process
Next         PROCEDURE(),BYTE,DERIVED ! returns 0 if finished
  END

  CODE

    Q:Title = 'Valis'
    Q:Author = 'Philip K. Dick'
    ADD(Q)
    Q:Title = 'At Swim Two Birds'
    Q:Author = 'Flann O''Brien'
    ADD(Q)
    Q:Title = 'Roads to Freedom'
    Q:Author = 'John Paul Sartre'
    ADD(Q)
    Q:Title = 'The Painted Bird'
    Q:Author = 'Jerzy Kosinski'
    ADD(Q)
    Q:Title = 'Staring at the Sun'
    Q:Author = 'Julian Barnes'
    ADD(Q)

    BIND(Q)

    C.LoadReportLibrary('rwdemo2.txr')  ! Load report library
    C.SetPreview()
    C.PrintReport('Report2')                    ! Print report
    StopOnError
    C.UnloadReportLibrary
    StopOnError


StopOnError PROCEDURE
  CODE
    IF ERRORCODE() = 90 THEN
      STOP(CLIP(FILEERROR()) & ' (' & CLIP(FILEERRORCODE()) & ')')
    ELSIF ERRORCODE()<>0 THEN
      STOP(CLIP(ERROR()) & ' (' & ERRORCODE() & ')')
    END

C.Reset PROCEDURE
  CODE
    QPos = 0
    RETURN RECORDS(Q)

C.Next  PROCEDURE
  CODE
    QPos += 1
    IF QPos>RECORDS(Q) THEN
      RETURN Level:Notify
    END
    GET(Q,QPos)
    RETURN Level:Benign
