! Demonstration on how to call the Clarion RW print engine DLL (C%V%PRLB%X%.DLL)
! from a program

  PROGRAM

  MAP
  END

  INCLUDE('RWPRLIB.INC'),ONCE


C ReportEngine

  CODE

    IF C.LoadReportLibrary('rwdemo1.txr') THEN   ! first load the report
      C.SetPreview(5)                            ! set preview to 5 pages
      IF NOT C.PrintReport('Report1') THEN       ! run preview/print (report1)
        message('Print 1 failed')
      END
      IF NOT C.PrintReport('Report2') THEN       ! run preview/print (report2)
        message('Print 2 failed')
      END
      C.UnloadReportLibrary
    ELSE
      message('Load failed')
    END
    IF C.LoadReportLibrary('rwdemo2.txr') then   ! load new report library
      C.SetPreview()                             ! preview all pages
      C.PrintReport(1)                           ! run preview/print (1st report)
      C.UnloadReportLibrary
    ELSE
      message('Load failed')
    END

