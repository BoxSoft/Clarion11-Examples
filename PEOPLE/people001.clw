

   MEMBER('people.clw')                                    ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABREPORT.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('MENUStyle.INC'),ONCE

!!! <summary>
!!! Generated from procedure template - Window
!!! Update the people File
!!! </summary>
Updatepeople PROCEDURE 

CurrentTab           STRING(80)                            ! 
FilesOpened          BYTE                                  ! 
ActionMessage        CSTRING(40)                           ! 
History::PEO:Record  LIKE(PEO:RECORD),THREAD
QuickWindow          WINDOW('Update the people File'),AT(,,193,103),FONT('MS Sans Serif',8,COLOR:Black),RESIZE, |
  CENTER,GRAY,IMM,MDI,HLP('Updatepeople'),SYSTEM
                       SHEET,AT(1,0,191,102),USE(?CurrentTab)
                         TAB('General'),USE(?Tab:1)
                           PROMPT('&Id:'),AT(8,20),USE(?PEO:Id:Prompt),TRN
                           STRING(@S10),AT(55,20,44,10),USE(PEO:Id),RIGHT(1),TRN
                           PROMPT('&First Name:'),AT(8,34),USE(?PEO:FirstName:Prompt),TRN
                           ENTRY(@S30),AT(55,34,124,10),USE(PEO:FirstName)
                           PROMPT('&Last Name:'),AT(8,48),USE(?PEO:LastName:Prompt),TRN
                           ENTRY(@S30),AT(55,48,124,10),USE(PEO:LastName)
                           PROMPT('&Gender:'),AT(8,62),USE(?PEO:Gender:Prompt),TRN
                           ENTRY(@S1),AT(55,62,40,10),USE(PEO:Gender)
                         END
                       END
                       BUTTON('OK'),AT(11,82,45,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT
                       BUTTON('Cancel'),AT(133,82,47,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT
                     END

ThisWindow           CLASS(WindowManager)
Ask                    PROCEDURE(),DERIVED
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
ToolbarForm          ToolbarUpdateClass                    ! Form Toolbar Manager
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END

CurCtrlFeq          LONG
FieldColorQueue     QUEUE
Feq                   LONG
OldColor              LONG
                    END

  CODE
? DEBUGHOOK(people:Record)
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Ask PROCEDURE

  CODE
  CASE SELF.Request                                        ! Configure the action message text
  OF ViewRecord
    ActionMessage = 'View Record'
  OF InsertRecord
    ActionMessage = 'Adding a people Record'
  OF ChangeRecord
    ActionMessage = 'Changing a people Record'
  END
  QuickWindow{PROP:Text} = ActionMessage                   ! Display status message in title bar
  PARENT.Ask


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('Updatepeople')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?PEO:Id:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  SELF.HistoryKey = 734
  SELF.AddHistoryFile(PEO:Record,History::PEO:Record)
  SELF.AddHistoryField(?PEO:Id,1)
  SELF.AddHistoryField(?PEO:FirstName,2)
  SELF.AddHistoryField(?PEO:LastName,3)
  SELF.AddHistoryField(?PEO:Gender,4)
  SELF.AddUpdateFile(Access:people)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:people.Open()                                     ! File people used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:people
  IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing ! Setup actions for ViewOnly Mode
    SELF.InsertAction = Insert:None
    SELF.DeleteAction = Delete:None
    SELF.ChangeAction = Change:None
    SELF.CancelAction = Cancel:Cancel
    SELF.OkControl = 0
  ELSE
    SELF.ChangeAction = Change:Caller                      ! Changes allowed
    SELF.OkControl = ?OK
    IF SELF.PrimeUpdate() THEN RETURN Level:Notify.
  END
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  SELF.AddItem(ToolbarForm)
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:people.Close()
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run()
  IF SELF.Request = ViewRecord                             ! In View Only mode always signal RequestCancelled
    ReturnValue = RequestCancelled
  END
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?OK
      ThisWindow.Update()
      IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing THEN
         POST(EVENT:CloseWindow)
      END
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.DeferMoves = False
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the people File
!!! </summary>
Browsepeople PROCEDURE 

CurrentTab           STRING(80)                            ! 
FilesOpened          BYTE                                  ! 
BRW1::View:Browse    VIEW(people)
                       PROJECT(PEO:Id)
                       PROJECT(PEO:FirstName)
                       PROJECT(PEO:LastName)
                       PROJECT(PEO:Gender)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
PEO:Id                 LIKE(PEO:Id)                   !List box control field - type derived from field
PEO:FirstName          LIKE(PEO:FirstName)            !List box control field - type derived from field
PEO:LastName           LIKE(PEO:LastName)             !List box control field - type derived from field
PEO:Gender             LIKE(PEO:Gender)               !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the people File'),AT(,,263,207),FONT('MS Sans Serif',8,COLOR:Black),RESIZE, |
  CENTER,GRAY,IMM,MDI,HLP('Browsepeople'),SYSTEM
                       SHEET,AT(1,1,259,204),USE(?CurrentTab)
                         TAB('PEO:KeyId'),USE(?Tab:2)
                         END
                         TAB('PEO:KeyLastName'),USE(?Tab:3)
                         END
                       END
                       LIST,AT(8,20,247,142),USE(?Browse:1),HVSCROLL,FORMAT('44L(2)|M~Id~@S10@71L(2)|M~First N' & |
  'ame~@S30@87L(2)|M~Last Name~@S30@28L(11)|M~Gender~L(2)@S1@'),FROM(Queue:Browse:1),IMM,MSG('Browsing Records')
                       BUTTON('&Insert'),AT(52,166,41,14),USE(?Insert:2),LEFT,ICON('WAINSERT.ICO'),FLAT
                       BUTTON('&Change'),AT(101,166,51,14),USE(?Change:2),LEFT,ICON('WACHANGE.ICO'),DEFAULT,FLAT
                       BUTTON('&Delete'),AT(160,166,45,14),USE(?Delete:2),LEFT,ICON('WADELETE.ICO'),FLAT
                       BUTTON('&Print'),AT(9,185,39,13),USE(?Print),LEFT,ICON(ICON:Print1),FLAT
                       BUTTON('Close'),AT(209,185,45,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort2:Locator  FilterLocatorClass                    ! Conditional Locator - CHOICE(?CurrentTab) = 2
BRW1::EIPManager     BrowseEIPManager                      ! Browse EIP Manager for Browse using ?Browse:1
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END


  CODE
? DEBUGHOOK(people:Record)
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
  GlobalErrors.SetProcedureName('Browsepeople')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse:1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  Relate:people.Open()                                     ! File people used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:people,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.FileLoaded = 1                                      ! This is a 'file loaded' browse
  BRW1.AddSortOrder(,PEO:KeyLastName)                      ! Add the sort order for PEO:KeyLastName for sort order 1
  BRW1.AddLocator(BRW1::Sort2:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort2:Locator.Init(,PEO:LastName,1,BRW1)           ! Initialize the browse locator using  using key: PEO:KeyLastName , PEO:LastName
  BRW1::Sort2:Locator.FloatRight = 1
  BRW1.AddSortOrder(,PEO:KeyId)                            ! Add the sort order for PEO:KeyId for sort order 2
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort0:Locator.Init(,PEO:Id,1,BRW1)                 ! Initialize the browse locator using  using key: PEO:KeyId , PEO:Id
  BRW1.AddField(PEO:Id,BRW1.Q.PEO:Id)                      ! Field PEO:Id is a hot field or requires assignment from browse
  BRW1.AddField(PEO:FirstName,BRW1.Q.PEO:FirstName)        ! Field PEO:FirstName is a hot field or requires assignment from browse
  BRW1.AddField(PEO:LastName,BRW1.Q.PEO:LastName)          ! Field PEO:LastName is a hot field or requires assignment from browse
  BRW1.AddField(PEO:Gender,BRW1.Q.PEO:Gender)              ! Field PEO:Gender is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  BRW1.AddToolbarTarget(Toolbar)                           ! Browse accepts toolbar control
  BRW1.PrintProcedure = 2
  BRW1.PrintControl = ?Print
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:people.Close()
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE(USHORT Number,BYTE Request)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run(Number,Request)
  IF SELF.Request = ViewRecord
    ReturnValue = RequestCancelled                         ! Always return RequestCancelled if the form was opened in ViewRecord mode
  ELSE
    GlobalRequest = Request
    EXECUTE Number
      Updatepeople
      PrintPEO:KeyLastName
    END
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  SELF.EIP &= BRW1::EIPManager                             ! Set the EIP manager
  SELF.AddEditControl(,1) ! PEO:Id Disable
  SELF.DeleteAction = EIPAction:Always
  SELF.ArrowAction = EIPAction:Default+EIPAction:Remain+EIPAction:RetainColumn
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:2
    SELF.ChangeControl=?Change:2
    SELF.DeleteControl=?Delete:2
  END


BRW1.ResetSort PROCEDURE(BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  IF CHOICE(?CurrentTab) = 2
    RETURN SELF.SetSort(1,Force)
  ELSE
    RETURN SELF.SetSort(2,Force)
  END
  ReturnValue = PARENT.ResetSort(Force)
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.DeferMoves = False
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Frame
!!! Example EIP Application
!!! </summary>
Main PROCEDURE 

FilesOpened          BYTE                                  ! 
MenuStyleMgr MenuStyleManager
AppFrame             APPLICATION('Application'),AT(,,421,269),FONT('MS Sans Serif',8,COLOR:Black),RESIZE,CENTER, |
  MAX,STATUS(-1,80,120,45),SYSTEM,IMM
                       MENUBAR,USE(?MENUBAR1),FONT(,,COLOR:MENUTEXT)
                         MENU('&File'),USE(?FileMenu)
                           ITEM('&Print Setup ...'),USE(?PrintSetup),MSG('Setup printer'),STD(STD:PrintSetup)
                           ITEM,USE(?SEPARATOR1),SEPARATOR
                           ITEM('E&xit'),USE(?Exit),MSG('Exit this application'),STD(STD:Close)
                         END
                         MENU('&Edit'),USE(?EditMenu)
                           ITEM('Cu&t'),USE(?Cut),MSG('Remove item to Windows Clipboard'),STD(STD:Cut)
                           ITEM('&Copy'),USE(?Copy),MSG('Copy item to Windows Clipboard'),STD(STD:Copy)
                           ITEM('&Paste'),USE(?Paste),MSG('Paste contents of Windows Clipboard'),STD(STD:Paste)
                         END
                         MENU('&Browse'),USE(?BrowseMenu)
                           ITEM('Browse the people file'),USE(?Browsepeople),MSG('Browse people')
                         END
                         MENU('&Reports'),USE(?ReportMenu),MSG('Report data')
                           MENU('Report the people file'),USE(?Printpeople)
                             ITEM('New Style Report'),USE(?PrintPEO:KeyId),MSG('Print ordered by the PEO:KeyId key')
                             ITEM('Print by PEO:KeyLastName key'),USE(?PrintPEO:KeyLastName),MSG('Print ordered by t' & |
  'he PEO:KeyLastName key')
                           END
                         END
                         MENU('&Window'),USE(?WindowMenu),MSG('Create and Arrange windows'),STD(STD:WindowList)
                           ITEM('T&ile'),USE(?Tile),MSG('Make all open windows visible'),STD(STD:TileWindow)
                           ITEM('&Cascade'),USE(?Cascade),MSG('Stack all open windows'),STD(STD:CascadeWindow)
                           ITEM('&Arrange Icons'),USE(?Arrange),MSG('Align all window icons'),STD(STD:ArrangeIcons)
                         END
                         MENU('&Help'),USE(?HelpMenu),MSG('Windows Help')
                           ITEM('&Contents'),USE(?Helpindex),MSG('View the contents of the help file'),STD(STD:HelpIndex)
                           ITEM('&Search for Help On...'),USE(?HelpSearch),MSG('Search for help on a subject'),STD(STD:HelpSearch)
                           ITEM('&How to Use Help'),USE(?HelpOnHelp),MSG('How to use Windows Help'),STD(STD:HelpOnHelp)
                         END
                       END
                       TOOLBAR,AT(0,1,421,22),USE(?TOOLBAR1)
                         BUTTON,AT(4,2,16,14),USE(?Toolbar:Top, Toolbar:Top),ICON('VCRFIRST.ICO'),DISABLE,FLAT,TIP('Go to the ' & |
  'First Page')
                         BUTTON,AT(20,2,16,14),USE(?Toolbar:PageUp, Toolbar:PageUp),ICON('VCRPRIOR.ICO'),DISABLE,FLAT, |
  TIP('Go to the Prior Page')
                         BUTTON,AT(36,2,16,14),USE(?Toolbar:Up, Toolbar:Up),ICON('VCRUP.ICO'),DISABLE,FLAT,TIP('Go to the ' & |
  'Prior Record')
                         BUTTON,AT(52,2,16,14),USE(?Toolbar:Locate, Toolbar:Locate),ICON('FIND.ICO'),DISABLE,FLAT,TIP('Locate record')
                         BUTTON,AT(68,2,16,14),USE(?Toolbar:Down, Toolbar:Down),ICON('VCRDOWN.ICO'),DISABLE,FLAT,TIP('Go to the ' & |
  'Next Record')
                         BUTTON,AT(84,2,16,14),USE(?Toolbar:PageDown, Toolbar:PageDown),ICON('VCRNEXT.ICO'),DISABLE, |
  FLAT,TIP('Go to the Next Page')
                         BUTTON,AT(100,2,16,14),USE(?Toolbar:Bottom, Toolbar:Bottom),ICON('VCRLAST.ICO'),DISABLE,FLAT, |
  TIP('Go to the Last Page')
                         BUTTON,AT(120,2,16,14),USE(?Toolbar:Select, Toolbar:Select),ICON('MARK.ICO'),DISABLE,FLAT, |
  TIP('Select This Record')
                         BUTTON,AT(136,2,16,14),USE(?Toolbar:Insert, Toolbar:Insert),ICON('INSERT.ICO'),DISABLE,FLAT, |
  TIP('Insert a New Record')
                         BUTTON,AT(152,2,16,14),USE(?Toolbar:Change, Toolbar:Change),ICON('EDIT.ICO'),DISABLE,FLAT, |
  TIP('Edit This Record')
                         BUTTON,AT(168,2,16,14),USE(?Toolbar:Delete, Toolbar:Delete),ICON('DELETE.ICO'),DISABLE,FLAT, |
  TIP('Delete This Record')
                         BUTTON,AT(188,2,16,14),USE(?Toolbar:History, Toolbar:History),ICON('DITTO.ICO'),DISABLE,FLAT, |
  TIP('Previous value')
                         BUTTON,AT(204,2,16,14),USE(?Toolbar:Help, Toolbar:Help),ICON('HELP.ICO'),DISABLE,FLAT,TIP('Get Help')
                       END
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass

  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------
Menu::MENUBAR1 ROUTINE                                     ! Code for menu items on ?MENUBAR1
Menu::FileMenu ROUTINE                                     ! Code for menu items on ?FileMenu
Menu::EditMenu ROUTINE                                     ! Code for menu items on ?EditMenu
Menu::BrowseMenu ROUTINE                                   ! Code for menu items on ?BrowseMenu
  CASE ACCEPTED()
  OF ?Browsepeople
    START(Browsepeople, 050000)
  END
Menu::ReportMenu ROUTINE                                   ! Code for menu items on ?ReportMenu
Menu::Printpeople ROUTINE                                  ! Code for menu items on ?Printpeople
  CASE ACCEPTED()
  OF ?PrintPEO:KeyId
    START(PrintPEO:KeyId, 050000)
  OF ?PrintPEO:KeyLastName
    START(PrintPEO:KeyLastName, 050000)
  END
Menu::WindowMenu ROUTINE                                   ! Code for menu items on ?WindowMenu
Menu::HelpMenu ROUTINE                                     ! Code for menu items on ?HelpMenu

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('Main')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = 1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  SELF.Open(AppFrame)                                      ! Open window
  Do DefineListboxStyle
  SELF.SetAlerts()
      AppFrame{PROP:TabBarVisible}  = False
      MenuStyleMgr.Init(?MENUBAR1)
      MenuStyleMgr.SuspendRefresh()
      MenuStyleMgr.SetThemeColors('XPLunaBlue')
      MenuStyleMgr.SetImageBar(False)
      MenuStyleMgr.ApplyTheme()
      MenuStyleMgr.Refresh(TRUE)
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE ACCEPTED()
    OF ?Toolbar:Top
    OROF ?Toolbar:PageUp
    OROF ?Toolbar:Up
    OROF ?Toolbar:Locate
    OROF ?Toolbar:Down
    OROF ?Toolbar:PageDown
    OROF ?Toolbar:Bottom
    OROF ?Toolbar:Select
    OROF ?Toolbar:Insert
    OROF ?Toolbar:Change
    OROF ?Toolbar:Delete
    OROF ?Toolbar:History
    OROF ?Toolbar:Help
      IF SYSTEM{PROP:Active} <> THREAD()
        POST(EVENT:Accepted,ACCEPTED(),SYSTEM{Prop:Active} )
        CYCLE
      END
    ELSE
      DO Menu::MENUBAR1                                    ! Process menu items on ?MENUBAR1 menu
      DO Menu::FileMenu                                    ! Process menu items on ?FileMenu menu
      DO Menu::EditMenu                                    ! Process menu items on ?EditMenu menu
      DO Menu::BrowseMenu                                  ! Process menu items on ?BrowseMenu menu
      DO Menu::ReportMenu                                  ! Process menu items on ?ReportMenu menu
      DO Menu::Printpeople                                 ! Process menu items on ?Printpeople menu
      DO Menu::WindowMenu                                  ! Process menu items on ?WindowMenu menu
      DO Menu::HelpMenu                                    ! Process menu items on ?HelpMenu menu
    END
  ReturnValue = PARENT.TakeAccepted()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue

!!! <summary>
!!! Generated from procedure template - Report
!!! People File Cockpit
!!! </summary>
PrintPEO:KeyId PROCEDURE 

Progress:Thermometer BYTE                                  ! 
TotalRecordsPrinted  LONG                                  ! 
RecordsPrinted       LONG                                  ! 
FilesOpened          BYTE                                  ! 
Process:View         VIEW(people)
                       PROJECT(PEO:FirstName)
                       PROJECT(PEO:Gender)
                       PROJECT(PEO:Id)
                       PROJECT(PEO:LastName)
                     END
ProgressWindow       WINDOW('Progress...'),AT(,,142,147),DOUBLE,CENTER,GRAY,TIMER(1)
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,100)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       LIST,AT(16,40,110,9),USE(?List1),DROP(3),FROM('All|Male|Female')
                       LIST,AT(16,60,110,9),USE(?List2),DROP(10),FROM('By ID|By Last Name|By First Name|By Gender')
                       LIST,AT(16,80,110,9),USE(?List3),DROP(10),FROM('Normal|2 Pass|2-up')
                       BUTTON('Cancel'),AT(19,115,50,15),USE(?Progress:Cancel)
                       BUTTON('Pause'),AT(75,115,50,15),USE(?Pause)
                     END

report               REPORT,AT(1000,1540,6000,7458),PRE(RPT),FONT('Arial',10,COLOR:Black),THOUS
                       HEADER,AT(1000,1000,6000,542)
                         STRING('Print the people File'),AT(0,21,2292,219),FONT(,,,FONT:bold),CENTER
                         BOX,AT(0,260,6000,280),COLOR(COLOR:Black),FILL(COLOR:Silver)
                         LINE,AT(1500,260,0,280),COLOR(COLOR:Black)
                         LINE,AT(3000,260,0,280),COLOR(COLOR:Black)
                         LINE,AT(4500,260,0,280),COLOR(COLOR:Black)
                         STRING('Id'),AT(50,310,1400,170),TRN
                         STRING('First Name'),AT(1550,310,1400,170),TRN
                         STRING('Last Name'),AT(3050,310,1400,170),TRN
                         STRING('Gender'),AT(4550,310,1400,170),TRN
                       END
detail                 DETAIL,AT(,,6000,281)
                         LINE,AT(1500,0,0,280),COLOR(COLOR:Black)
                         LINE,AT(3000,0,0,280),COLOR(COLOR:Black)
                         LINE,AT(4500,0,0,280),COLOR(COLOR:Black)
                         STRING(@S10),AT(50,50,1400,170),USE(PEO:Id),RIGHT(1)
                         STRING(@S30),AT(1550,50,1400,170),USE(PEO:FirstName)
                         STRING(@S30),AT(3050,50,1400,170),USE(PEO:LastName)
                         STRING(@S1),AT(4550,50,1400,170),USE(PEO:Gender)
                         LINE,AT(50,280,5900,0),COLOR(COLOR:Black)
                       END
                       FOOTER,AT(1000,9000,6000,219)
                         STRING(@pPage <<<#p),AT(5250,30,700,135),USE(?PageCount),FONT('Arial',8,COLOR:Black,FONT:regular), |
  PAGENO
                       END
                     END
report1 REPORT,AT(1000,1540,6000,7458),PRE(RPT1),FONT('Arial',10,,),THOUS
detail DETAIL,AT(,,6000,281)
         LINE,AT(1500,0,0,280),COLOR(00H)
         LINE,AT(3000,0,0,280),COLOR(00H)
         LINE,AT(4500,0,0,280),COLOR(00H)
         STRING(@S30),AT(1550,50,1400,170),USE(PEO:FirstName,,?S2)
         STRING(@S30),AT(3050,50,1400,170),USE(PEO:LastName,,?S3)
         STRING(@S1),AT(4550,50,1400,170),USE(PEO:Gender,,?S4)
         STRING(@n4),AT(63,73),USE(RecordsPrinted),TRN
         STRING(@n4),AT(917,52),USE(TotalRecordsPrinted),TRN
         STRING('Of'),AT(583,42,240,208),USE(?String6),TRN
         LINE,AT(50,280,5900,0),COLOR(00H)
       END
     END
report2               REPORT,AT(1000,1540,6000,7460),PRE(RPT2),FONT('Arial',10,,),THOUS
detail                 DETAIL,AT(,,3000,280)
                         STRING(@S30),AT(0,50,1400,170),USE(PEO:FirstName,,?S5)
                         STRING(@S30),AT(1550,50,1400,170),USE(PEO:LastName,,?S6)
                       END
                       FOOTER,AT(1000,9000,6000,219)
                         STRING(@pPage <<<#p),AT(5250,30,700,135),PAGENO,USE(?PageCount1),FONT('Arial',8,,FONT:regular)
                       END
                     END

ThisWindow           CLASS(ReportManager)
AskPreview             PROCEDURE(),DERIVED
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
OpenReport             PROCEDURE(),BYTE,PROC,DERIVED
Paused                 BYTE
Timer                  LONG
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
Cancelled              BYTE
TakeWindowEvent        PROCEDURE(),BYTE,PROC,DERIVED
PrePass                BYTE
                     END

ThisReport           CLASS(ProcessClass)                   ! Process Manager
TakeRecord             PROCEDURE(),BYTE,PROC,DERIVED
                     END

Previewer            PrintPreviewClass                     ! Print Previewer

  CODE
? DEBUGHOOK(people:Record)
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.AskPreview PROCEDURE

  CODE
  IF ~SELF.PrePass
  PARENT.AskPreview
  END


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('PrintPEO:KeyId')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Progress:Thermometer
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  Relate:people.Open()                                     ! File people used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Open(ProgressWindow)                                ! Open window
  Do DefineListboxStyle
  ?List1{PROP:SelStart} = 1
  ?List2{PROP:SelStart} = 1
  ?List3{PROP:SelStart} = 1
  ThisReport.Init(Process:View, Relate:people, ?Progress:PctText, Progress:Thermometer, 25)
  ThisReport.AddSortOrder()
  SELF.AddItem(?Progress:Cancel,RequestCancelled)
  SELF.Init(ThisReport,report,Previewer)
  ?Progress:UserString{PROP:Text} = ''
  Relate:people.SetQuickScan(1,Propagate:OneMany)
  ProgressWindow{PROP:Timer} = 10                          ! Assign timer interval
  SELF.SkipPreview = False
  Previewer.SetINIManager(INIMgr)
  Previewer.AllowUserZoom = True
  SELF.DeferWindow = 0
  SELF.WaitCursor = 1
  ASSERT(~SELF.DeferWindow) ! A hidden Go button is not smart ...
  SELF.KeepVisible = 1
  SELF.DeferOpenReport = 1
  SELF.Timer = TARGET{PROP:Timer}
  TARGET{PROP:Timer} = 0
  ?Pause{PROP:Text} = 'Go'
  SELF.Paused = 1
  ?Progress:Cancel{PROP:Key} = EscKey
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:people.Close()
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.OpenReport PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  SELF.Process.SetFilter(CHOOSE(CHOICE(?List1),'','PEO:Gender=''M''','PEO:Gender=''F'''))
  SELF.Process.SetOrder(CHOOSE(CHOICE(?List2),'PEO:Id','PEO:LastName','PEO:FirstName','PEO:Gender'))
  EXECUTE(CHOICE(?List3))
    SELF.Report &= Report
    BEGIN
      SELF.Report &= Report1
      RecordsPrinted = 0
      SELF.PrePass = 1 - SELF.PrePass
    END
    SELF.Report &= Report2
  END
  ReturnValue = PARENT.OpenReport()
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE ACCEPTED()
    OF ?Pause
      IF SELF.Paused
        TARGET{PROP:Timer} = SELF.Timer
        ?Pause{PROP:Text} = 'Pause'
      ELSE
        SELF.Timer = TARGET{PROP:Timer}
        TARGET{PROP:Timer} = 0
        ?Pause{PROP:Text} = 'Restart'
      END
      SELF.Paused = 1 - SELF.Paused
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?Progress:Cancel
      ThisWindow.Update()
      SELF.Cancelled = 1
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
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
    CASE EVENT()
    OF EVENT:CloseWindow
      SELF.KeepVisible = 1
    OF EVENT:Timer
      IF SELF.Paused THEN RETURN Level:Benign .
    END
  ReturnValue = PARENT.TakeWindowEvent()
    CASE EVENT()
    OF EVENT:CloseWindow
      IF ~SELF.Cancelled
        Progress:Thermometer = 0
        ?Progress:PctText{PROP:Text} = '0% Completed'
        SELF.DeferOpenReport = 1
        TARGET{PROP:Timer} = 0
        ?Pause{PROP:Text} = 'Go'
        SELF.Paused = 1
        SELF.Process.Close
        SELF.Response = RequestCancelled
        IF SELF.PrePass THEN
          POST(EVENT:Accepted,?Pause)
          TotalRecordsPrinted = RecordsPrinted
        .
        DISPLAY
        RETURN Level:Notify
      END
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisReport.TakeRecord PROCEDURE

ReturnValue          BYTE,AUTO

SkipDetails BYTE
  CODE
  ReturnValue = PARENT.TakeRecord()
  CASE CHOICE(?List3)
  OF 1
  PRINT(RPT:detail)
  OF 2
    RecordsPrinted += 1
    IF ~ThisWindow.PrePass
      PRINT(RPT1:Detail)
    END
  OF 3
    PRINT(RPT2:Detail)
  END
  RETURN ReturnValue

!!! <summary>
!!! Generated from procedure template - Report
!!! Print the people File by PEO:KeyLastName
!!! </summary>
PrintPEO:KeyLastName PROCEDURE 

Progress:Thermometer BYTE                                  ! 
FilesOpened          BYTE                                  ! 
Process:View         VIEW(people)
                       PROJECT(PEO:FirstName)
                       PROJECT(PEO:Gender)
                       PROJECT(PEO:Id)
                       PROJECT(PEO:LastName)
                     END
ProgressWindow       WINDOW('Progress...'),AT(,,142,59),DOUBLE,CENTER,GRAY,TIMER(1)
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,100)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(45,42,50,15),USE(?Progress:Cancel)
                     END

report               REPORT,AT(1000,1540,6000,7460),PRE(RPT),FONT('Arial',10,COLOR:Black),THOUS
                       HEADER,AT(1000,1000,6000,540)
                         STRING('Print the people File by PEO:KeyLastName'),AT(0,20,6000,220),FONT(,,COLOR:Black,FONT:bold), |
  CENTER
                         BOX,AT(0,260,6000,280),COLOR(COLOR:Black),FILL(COLOR:Silver)
                         LINE,AT(1500,260,0,280),COLOR(COLOR:Black)
                         LINE,AT(3000,260,0,280),COLOR(COLOR:Black)
                         LINE,AT(4500,260,0,280),COLOR(COLOR:Black)
                         STRING('Id'),AT(50,310,1400,170),TRN
                         STRING('First Name'),AT(1550,310,1400,170),TRN
                         STRING('Last Name'),AT(3050,310,1400,170),TRN
                         STRING('Gender'),AT(4550,310,1400,170),TRN
                       END
detail                 DETAIL,AT(,,6000,280)
                         LINE,AT(1500,0,0,280),COLOR(COLOR:Black)
                         LINE,AT(3000,0,0,280),COLOR(COLOR:Black)
                         LINE,AT(4500,0,0,280),COLOR(COLOR:Black)
                         STRING(@S10),AT(50,50,1400,170),USE(PEO:Id),RIGHT(1)
                         STRING(@S30),AT(1550,50,1400,170),USE(PEO:FirstName)
                         STRING(@S30),AT(3050,50,1400,170),USE(PEO:LastName)
                         STRING(@S1),AT(4550,50,1400,170),USE(PEO:Gender)
                         LINE,AT(50,280,5900,0),COLOR(COLOR:Black)
                       END
                       FOOTER,AT(1000,9000,6000,219)
                         STRING(@pPage <<<#p),AT(5250,30,700,135),USE(?PageCount),FONT('Arial',8,COLOR:Black,FONT:regular), |
  PAGENO
                       END
                     END
ThisWindow           CLASS(ReportManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
                     END

ThisReport           CLASS(ProcessClass)                   ! Process Manager
TakeRecord             PROCEDURE(),BYTE,PROC,DERIVED
                     END

ProgressMgr          StepStringClass                       ! Progress Manager
Previewer            PrintPreviewClass                     ! Print Previewer

  CODE
? DEBUGHOOK(people:Record)
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
  GlobalErrors.SetProcedureName('PrintPEO:KeyLastName')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Progress:Thermometer
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  Relate:people.Open()                                     ! File people used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Open(ProgressWindow)                                ! Open window
  Do DefineListboxStyle
  ProgressMgr.Init(ScrollSort:AllowAlpha+ScrollSort:AllowNumeric,ScrollBy:RunTime)
  ThisReport.Init(Process:View, Relate:people, ?Progress:PctText, Progress:Thermometer, ProgressMgr, PEO:LastName)
  ThisReport.CaseSensitiveValue = FALSE
  ThisReport.AddSortOrder(PEO:KeyLastName)
  SELF.AddItem(?Progress:Cancel,RequestCancelled)
  SELF.Init(ThisReport,report,Previewer)
  ?Progress:UserString{PROP:Text} = ''
  Relate:people.SetQuickScan(1,Propagate:OneMany)
  ProgressWindow{PROP:Timer} = 10                          ! Assign timer interval
  SELF.SkipPreview = False
  Previewer.SetINIManager(INIMgr)
  Previewer.AllowUserZoom = True
  SELF.DeferWindow = 0
  SELF.WaitCursor = 1
  IF SELF.OriginalRequest = ProcessRecord
    CLEAR(SELF.DeferWindow,1)
    ThisReport.AddRange(PEO:LastName)        ! Overrides any previous range
  END
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:people.Close()
  END
  ProgressMgr.Kill()
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisReport.TakeRecord PROCEDURE

ReturnValue          BYTE,AUTO

SkipDetails BYTE
  CODE
  ReturnValue = PARENT.TakeRecord()
  PRINT(RPT:detail)
  RETURN ReturnValue

