! This program demonstrates replacing the Report Preview Engine when
! printing a report via C%V%PRLB%X%.DLL

   PROGRAM

   MAP
   END

   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABREPORT.INC'),ONCE
   INCLUDE('RWPRLIB.INC'),ONCE

C  CLASS(ReportEngine)
PrintHook   PROCEDURE(),SIGNED,DERIVED,DLL   ! to handle print preview
   END



S_RECORDSCOMPLETED EQUATE(' Demo Records Completed')
S_PCCOMPLETED      EQUATE('% Of Demo Completed')
S_GENERATINGREPORT EQUATE('Generating Demo Report ')


  CODE
    IF C.LoadReportLibrary('rwdemo1.txr') THEN
      C.SetPreview()
      C.PrintReport('Report1')
    END


C.PrintHook PROCEDURE()
! Main procedure that previews and prints a report

RecordsPerCycle      EQUATE(25)
RecordsToProcess     LONG,AUTO
RecordsProcessed     LONG(0)
PreviewPages         LONG(0)
ReportStarted        BYTE(False)
Percentile           BYTE(0)
NewPercentile        BYTE,AUTO
PrintPreviewQueue    PreviewQueue
PrtPrev              PrintPreviewClass
Ok                   BYTE(True)
DoPrint              BYTE(True)

ProgressWindow WINDOW('Demo Progress...'),AT(,,142,59),CENTER,TIMER(10),GRAY,DOUBLE
       PROGRESS,USE(Percentile),AT(15,15,111,12),RANGE(0,100)
       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
       BUTTON('Cancel'),AT(45,42,50,15),USE(?Progress:Cancel)
     END

  CODE
    PUSHBIND(1)                                 ! non-destructive PUSHBIND

    IF SELF.PagesToPreview<>0 THEN              ! previewing enabled
      IF SELF.PagesToPreview>0 THEN             ! previewing enabled
        PreviewPages = SELF.PagesToPreview
      ELSE
        PreviewPages = 100000000;               ! i.e. all
      END
    END

    OPEN(ProgressWindow)                        ! Open Progress bar

    ProgressWindow{Prop:Text} = S_GENERATINGREPORT & SELF.ReportName
    ?Progress:UserString{Prop:Text}=''

Aloop ACCEPT
      CASE EVENT()
      OF Event:Timer
        IF NOT ReportStarted THEN               ! Initialize Report
          IF SELF.PagesToPreview<>0 THEN
            SELF.Report{Prop:Preview} = PrintPreviewQueue.Filename
          END
          RecordsToProcess = SELF.Reset()       ! Reset files/view
          ReportStarted = TRUE
        END
        LOOP RecordsPerCycle TIMES
          CASE SELF.Next()                      ! Record fetch
          OF Level:Notify
            POST(Event:CloseWindow)             ! Finished (ok)
            BREAK
          OF Level:Fatal
            POST(Event:CloseWindow)             ! Finished (failed)
            Ok = False
            BREAK
          END

          SELF.PrintAction()                    ! Print detail(s)
          RecordsProcessed += 1

          IF PreviewPages<>0 THEN
            IF (RECORDS(PrintPreviewQueue) >= PreviewPages) THEN
              PreviewPages = 0                  ! Preview limit reached
                                                ! NB there may be more pages than asked for!
              DO PrintPreview                   ! So start preview
              IF NOT DoPrint THEN
                BREAK ALoop                     ! Cancel (i.e. no print wanted)
              END                               ! Otherwise continue loop
            END
          END

        END
        DO UpdateProgress
      END
      CASE FIELD()
      OF ?Progress:Cancel
        CASE Event()
        OF Event:Accepted
          POST(Event:CloseWindow)               ! Progress window cancelled
          DoPrint = FALSE                       ! so abort print
          PreviewPages = 0
        END
      END
    END
    CLOSE(ProgressWindow)                       ! Close progress window
    IF Ok THEN
      ENDPAGE(SELF.Report)                      ! Flush buffers
      IF PreviewPages<>0 THEN
        DO PrintPreview
      END
      IF SELF.PagesToPreview<>0 AND DoPrint THEN
        SELF.Report{PROP:FlushPreview} = True   ! Flush previewed pages to
                                                ! printer if required
      END
    END
    SELF.EndReport()                   ! must close report before freeing queue
    IF SELF.PagesToPreview<>0 THEN
      FREE(PrintPreviewQueue)                   ! free preview queue
    END
    POPBIND
    RETURN Ok


UpdateProgress ROUTINE                          ! update percentage progress
  IF RecordsProcessed>0 THEN
    IF RecordsToProcess <=0 THEN
      ?Progress:PctText{PROP:Text}=RecordsProcessed & S_RECORDSCOMPLETED
      DISPLAY()
      Percentile += 5
      IF Percentile >= 100
        Percentile = 5
      END
    ELSE
      NewPercentile = (RecordsProcessed / RecordsToProcess)*100
      IF NewPercentile > 100
        NewPercentile = 100
      END
      IF NewPercentile <> Percentile THEN
        Percentile = NewPercentile
        ?Progress:PctText{Prop:Text} = Percentile & S_PCCOMPLETED
        DISPLAY()
      END
    END
  END

PrintPreview   ROUTINE
  PrtPrev.Init(PrintPreviewQueue)  ! initialize the previewer
  PrtPrev.AllowUserZoom=True       ! allow zoom
  PrtPrev.Maximize=True            ! start up maximized
  DoPrint = PrtPrev.Display()      ! run previewer
  PrtPrev.Kill                     ! kill previewer
