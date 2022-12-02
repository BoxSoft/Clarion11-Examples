

   MEMBER('SqlScriptor.clw')                               ! This is a MEMBER module


   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('SQLSCRIPTOR001.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
Main                 PROCEDURE                             ! Declare Procedure
dbFile               STRING(255)                           !Name of the SQLite database file that the script is run against

  CODE
  GlobalErrors.SetProcedureName('Main')
  ! Replace this code with code to get the OWNER attribute to use
  ! this code with a different SQL driver
  IF NOT FILEDIALOG('Select SQLite Database (type new name to create)', |
                    dbFile, 'SQLite Files (*.sqlite)|*.sqlite|All Files|*.*', |
                    FILE:NoError + FILE:LongName)
    RETURN
  END
  sqlTable{PROP:Owner} = dbFile
  ! If the file does not exist, then create the SQLite Database
  IF NOT EXISTS(sqlTable{PROP:Owner})
    sqlTable{PROP:CreateDb}
  END
  RunScript()
!!! <summary>
!!! Generated from procedure template - Window
!!! Window
!!! </summary>
RunScript PROCEDURE 

scriptFile           STRING(255)                           !Name of the file holding the SQL script
Progress:Thermometer SHORT                                 !
statement            LONG(1)                               !
statements           LONG,AUTO                             !
executor             SQLExecutor                           !
ProgressWindow       WINDOW('Running SQL Script'),AT(,,142,59),FONT('Microsoft Sans Serif',8,,FONT:regular+FONT:underline, |
  CHARSET:DEFAULT),DOUBLE,CENTER,GRAY,TIMER(1)
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,100)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel Process'), |
  TIP('Cancel Process')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeWindowEvent        PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END


  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('RunScript')
  IF NOT FILEDIALOG('Select SQL script file', |
    scriptFile, 'Script Files (*.sql)|*.sql|All Files|*.*', |
    FILE:LongName)
    RETURN Level:Notify
  END
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Progress:Thermometer
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  Relate:sqlTable.Open                                     ! File sqlTable used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  Access:sqlTable.UseFile
  SELF.Open(ProgressWindow)                                ! Open window
  Do DefineListboxStyle
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('RunScript',ProgressWindow)                 ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:sqlTable.Close
  END
  IF SELF.Opened
    INIMgr.Update('RunScript',ProgressWindow)              ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.TakeWindowEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all window specific events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeWindowEvent()
    CASE EVENT()
    OF EVENT:OpenWindow
      ! Change the ';' to something else if your scripts have a different delimiter
      executor.Init(GlobalErrors, sqlTable, ';')
      IF executor.Load(scriptFile) <> Level:Benign
        BREAK
      END
      statements = executor.StatementCount()
    OF EVENT:Timer
      IF executor.ExecuteStatement(statement) <> Level:Benign
        BREAK
      END
      statement += 1
      Progress:Thermometer = statement / statements * 100
      DISPLAY(?Progress:Thermometer)
      IF statement > statements
        MESSAGE('The Script ran without errors')
        BREAK
      END
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

