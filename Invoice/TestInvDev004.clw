

   MEMBER('TestInvDev.clw')                                ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABREPORT.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('TESTINVDEV004.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form TestCompanyCSV
!!! </summary>
TestCsvImportCompanyForm PROCEDURE 

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::ImpCo:Record LIKE(ImpCo:RECORD),THREAD
QuickWindow          WINDOW('Form TestCompanyCSV'),AT(,,308,182),FONT('Segoe UI',9,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('UpdateTestCompanyCSV'),SYSTEM
                       SHEET,AT(4,4,300,156),USE(?CurrentTab)
                         TAB('&General'),USE(?Tab:1)
                           PROMPT('company name:'),AT(8,20),USE(?ImpCo:company_name:Prompt),TRN
                           ENTRY(@s53),AT(84,20,216,10),USE(ImpCo:company_name)
                           PROMPT('address 1:'),AT(8,34),USE(?ImpCo:address1:Prompt),TRN
                           ENTRY(@s24),AT(84,34,100,10),USE(ImpCo:address1)
                           PROMPT('address 2:'),AT(8,48),USE(?ImpCo:address2:Prompt),TRN
                           ENTRY(@s9),AT(84,48,40,10),USE(ImpCo:address2)
                           PROMPT('city:'),AT(8,62),USE(?ImpCo:city:Prompt),TRN
                           ENTRY(@s16),AT(84,62,68,10),USE(ImpCo:city)
                           PROMPT('state:'),AT(8,76),USE(?ImpCo:state:Prompt),TRN
                           ENTRY(@s2),AT(84,76,40,10),USE(ImpCo:state)
                           PROMPT('zip 5:'),AT(8,90),USE(?ImpCo:zip5:Prompt),TRN
                           ENTRY(@s5),AT(84,90,40,10),USE(ImpCo:zip5)
                           PROMPT('zip 4:'),AT(8,104),USE(?ImpCo:zip4:Prompt),TRN
                           ENTRY(@s4),AT(84,104,40,10),USE(ImpCo:zip4),RIGHT(1)
                           PROMPT('county name:'),AT(8,118),USE(?ImpCo:county_name:Prompt),TRN
                           ENTRY(@s15),AT(84,118,64,10),USE(ImpCo:county_name)
                           PROMPT('employee size:'),AT(8,132),USE(?ImpCo:employee_size:Prompt),TRN
                           ENTRY(@n6),AT(84,132,40,10),USE(ImpCo:employee_size)
                           PROMPT('url:'),AT(8,146),USE(?ImpCo:url:Prompt),TRN
                           ENTRY(@s35),AT(84,146,144,10),USE(ImpCo:url)
                         END
                         TAB('&General (cont.)'),USE(?Tab:2)
                           PROMPT('telephone:'),AT(8,20),USE(?ImpCo:telephone:Prompt),TRN
                           ENTRY(@s13),AT(84,20,56,10),USE(ImpCo:telephone)
                           PROMPT('telephone 2:'),AT(8,34),USE(?ImpCo:telephone2:Prompt),TRN
                           ENTRY(@s13),AT(84,34,56,10),USE(ImpCo:telephone2)
                           PROMPT('toll free number:'),AT(8,48),USE(?ImpCo:toll_free_number:Prompt),TRN
                           ENTRY(@s13),AT(84,48,56,10),USE(ImpCo:toll_free_number)
                           PROMPT('contact name:'),AT(8,62),USE(?ImpCo:contact_name:Prompt),TRN
                           ENTRY(@s27),AT(84,62,112,10),USE(ImpCo:contact_name)
                           PROMPT('prefix:'),AT(8,76),USE(?ImpCo:prefix:Prompt),TRN
                           ENTRY(@s3),AT(84,76,40,10),USE(ImpCo:prefix)
                           PROMPT('first name:'),AT(8,90),USE(?ImpCo:first_name:Prompt),TRN
                           ENTRY(@s9),AT(84,90,40,10),USE(ImpCo:first_name)
                           PROMPT('middle name:'),AT(8,104),USE(?ImpCo:middle_name:Prompt),TRN
                           ENTRY(@s7),AT(84,104,40,10),USE(ImpCo:middle_name)
                           PROMPT('surname:'),AT(8,118),USE(?ImpCo:surname:Prompt),TRN
                           ENTRY(@s14),AT(84,118,60,10),USE(ImpCo:surname)
                           PROMPT('suffix:'),AT(8,132),USE(?ImpCo:suffix:Prompt),TRN
                           ENTRY(@s2),AT(84,132,40,10),USE(ImpCo:suffix)
                           PROMPT('gender:'),AT(8,146),USE(?ImpCo:gender:Prompt),TRN
                           ENTRY(@s1),AT(84,146,40,10),USE(ImpCo:gender)
                         END
                         TAB('&General (cont. 2)'),USE(?Tab:3)
                           PROMPT('contact address 1:'),AT(8,20),USE(?ImpCo:contact_address1:Prompt),TRN
                           ENTRY(@s21),AT(84,20,88,10),USE(ImpCo:contact_address1)
                           PROMPT('contact address 2:'),AT(8,34),USE(?ImpCo:contact_address2:Prompt),TRN
                           ENTRY(@s7),AT(84,34,40,10),USE(ImpCo:contact_address2)
                           PROMPT('contact city:'),AT(8,48),USE(?ImpCo:contact_city:Prompt),TRN
                           ENTRY(@s13),AT(84,48,56,10),USE(ImpCo:contact_city)
                           PROMPT('contact state:'),AT(8,62),USE(?ImpCo:contact_state:Prompt),TRN
                           ENTRY(@s2),AT(84,62,40,10),USE(ImpCo:contact_state)
                           PROMPT('contact zip 5:'),AT(8,76),USE(?ImpCo:contact_zip5:Prompt),TRN
                           ENTRY(@n13),AT(84,76,56,10),USE(ImpCo:contact_zip5)
                           PROMPT('contact zip 4:'),AT(8,90),USE(?ImpCo:contact_zip4:Prompt),TRN
                           ENTRY(@n6),AT(84,90,40,10),USE(ImpCo:contact_zip4)
                           PROMPT('contact telephone:'),AT(8,104),USE(?ImpCo:contact_telephone:Prompt),TRN
                           ENTRY(@n-26.0),AT(84,104,112,10),USE(ImpCo:contact_telephone)
                           PROMPT('orig title 1:'),AT(8,118),USE(?ImpCo:orig_title1:Prompt),TRN
                           ENTRY(@s25),AT(84,118,104,10),USE(ImpCo:orig_title1)
                         END
                       END
                       BUTTON('&OK'),AT(202,164,49,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,MSG('Accept dat' & |
  'a and close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(255,164,49,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel operation'), |
  TIP('Cancel operation')
                     END

ThisWindow           CLASS(WindowManager)
Ask                    PROCEDURE(),DERIVED
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END

CurCtrlFeq          LONG
FieldColorQueue     QUEUE
Feq                   LONG
OldColor              LONG
                    END

  CODE
? DEBUGHOOK(TestCompanyCSV:Record)
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
    GlobalErrors.Throw(Msg:InsertIllegal)
    RETURN
  OF ChangeRecord
    GlobalErrors.Throw(Msg:UpdateIllegal)
    RETURN
  OF DeleteRecord
    GlobalErrors.Throw(Msg:DeleteIllegal)
    RETURN
  END
  QuickWindow{PROP:Text} = ActionMessage                   ! Display status message in title bar
  PARENT.Ask


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('TestCsvImportCompanyForm')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?ImpCo:company_name:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(ImpCo:Record,History::ImpCo:Record)
  SELF.AddHistoryField(?ImpCo:company_name,1)
  SELF.AddHistoryField(?ImpCo:address1,2)
  SELF.AddHistoryField(?ImpCo:address2,3)
  SELF.AddHistoryField(?ImpCo:city,4)
  SELF.AddHistoryField(?ImpCo:state,5)
  SELF.AddHistoryField(?ImpCo:zip5,6)
  SELF.AddHistoryField(?ImpCo:zip4,7)
  SELF.AddHistoryField(?ImpCo:county_name,8)
  SELF.AddHistoryField(?ImpCo:employee_size,9)
  SELF.AddHistoryField(?ImpCo:url,10)
  SELF.AddHistoryField(?ImpCo:telephone,11)
  SELF.AddHistoryField(?ImpCo:telephone2,12)
  SELF.AddHistoryField(?ImpCo:toll_free_number,13)
  SELF.AddHistoryField(?ImpCo:contact_name,14)
  SELF.AddHistoryField(?ImpCo:prefix,15)
  SELF.AddHistoryField(?ImpCo:first_name,16)
  SELF.AddHistoryField(?ImpCo:middle_name,17)
  SELF.AddHistoryField(?ImpCo:surname,18)
  SELF.AddHistoryField(?ImpCo:suffix,19)
  SELF.AddHistoryField(?ImpCo:gender,20)
  SELF.AddHistoryField(?ImpCo:contact_address1,21)
  SELF.AddHistoryField(?ImpCo:contact_address2,22)
  SELF.AddHistoryField(?ImpCo:contact_city,23)
  SELF.AddHistoryField(?ImpCo:contact_state,24)
  SELF.AddHistoryField(?ImpCo:contact_zip5,25)
  SELF.AddHistoryField(?ImpCo:contact_zip4,26)
  SELF.AddHistoryField(?ImpCo:contact_telephone,27)
  SELF.AddHistoryField(?ImpCo:orig_title1,28)
  SELF.AddUpdateFile(Access:TestCompanyCSV)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:TestCompanyCSV.Open()                             ! File TestCompanyCSV used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:TestCompanyCSV
  IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing ! Setup actions for ViewOnly Mode
    SELF.InsertAction = Insert:None
    SELF.DeleteAction = Delete:None
    SELF.ChangeAction = Change:None
    SELF.CancelAction = Cancel:Cancel
    SELF.OkControl = 0
  ELSE
    SELF.InsertAction = Insert:None                        ! Inserts not allowed
    SELF.DeleteAction = Delete:None                        ! Deletes not allowed
    SELF.ChangeAction = Change:None                        ! Changes not allowed
    SELF.CancelAction = Cancel:Cancel+Cancel:Query         ! Confirm cancel
    SELF.OkControl = ?OK
    IF SELF.PrimeUpdate() THEN RETURN Level:Notify.
  END
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?ImpCo:company_name{PROP:ReadOnly} = True
    ?ImpCo:address1{PROP:ReadOnly} = True
    ?ImpCo:address2{PROP:ReadOnly} = True
    ?ImpCo:city{PROP:ReadOnly} = True
    ?ImpCo:state{PROP:ReadOnly} = True
    ?ImpCo:zip5{PROP:ReadOnly} = True
    ?ImpCo:zip4{PROP:ReadOnly} = True
    ?ImpCo:county_name{PROP:ReadOnly} = True
    ?ImpCo:employee_size{PROP:ReadOnly} = True
    ?ImpCo:url{PROP:ReadOnly} = True
    ?ImpCo:telephone{PROP:ReadOnly} = True
    ?ImpCo:telephone2{PROP:ReadOnly} = True
    ?ImpCo:toll_free_number{PROP:ReadOnly} = True
    ?ImpCo:contact_name{PROP:ReadOnly} = True
    ?ImpCo:prefix{PROP:ReadOnly} = True
    ?ImpCo:first_name{PROP:ReadOnly} = True
    ?ImpCo:middle_name{PROP:ReadOnly} = True
    ?ImpCo:surname{PROP:ReadOnly} = True
    ?ImpCo:suffix{PROP:ReadOnly} = True
    ?ImpCo:gender{PROP:ReadOnly} = True
    ?ImpCo:contact_address1{PROP:ReadOnly} = True
    ?ImpCo:contact_address2{PROP:ReadOnly} = True
    ?ImpCo:contact_city{PROP:ReadOnly} = True
    ?ImpCo:contact_state{PROP:ReadOnly} = True
    ?ImpCo:contact_zip5{PROP:ReadOnly} = True
    ?ImpCo:contact_zip4{PROP:ReadOnly} = True
    ?ImpCo:contact_telephone{PROP:ReadOnly} = True
    ?ImpCo:orig_title1{PROP:ReadOnly} = True
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('TestCsvImportCompanyForm',QuickWindow)     ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:TestCompanyCSV.Close()
  END
  IF SELF.Opened
    INIMgr.Update('TestCsvImportCompanyForm',QuickWindow)  ! Save window data to non-volatile store
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
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the TestCompanyCSV file
!!! </summary>
TestCsvImportCompanyBrowse PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(TestCompanyCSV)
                       PROJECT(ImpCo:company_name)
                       PROJECT(ImpCo:address1)
                       PROJECT(ImpCo:address2)
                       PROJECT(ImpCo:city)
                       PROJECT(ImpCo:state)
                       PROJECT(ImpCo:zip5)
                       PROJECT(ImpCo:contact_name)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
ImpCo:company_name     LIKE(ImpCo:company_name)       !List box control field - type derived from field
ImpCo:address1         LIKE(ImpCo:address1)           !List box control field - type derived from field
ImpCo:address2         LIKE(ImpCo:address2)           !List box control field - type derived from field
ImpCo:city             LIKE(ImpCo:city)               !List box control field - type derived from field
ImpCo:state            LIKE(ImpCo:state)              !List box control field - type derived from field
ImpCo:zip5             LIKE(ImpCo:zip5)               !List box control field - type derived from field
ImpCo:contact_name     LIKE(ImpCo:contact_name)       !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the TestCompanyCSV file'),AT(,,441,198),FONT('Segoe UI',9,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('TestCsvImportBrowseCompany'),SYSTEM
                       LIST,AT(5,6,432,172),USE(?Browse:1),VSCROLL,FORMAT('80L(2)|M~Company Name~@s53@80L(2)|M' & |
  '~Address 1~@s24@40L(2)|M~Address 2~@s9@68L(2)|M~City~@s16@24L(2)|M~State~@s2@24L(2)|' & |
  'M~Zip~@s5@108L(2)|M~Contact Name~@s27@'),FROM(Queue:Browse:1),IMM,MSG('Browsing the ' & |
  'TestCompanyCSV file')
                       BUTTON('&View'),AT(5,180,49,14),USE(?View:2),LEFT,ICON('WAVIEW.ICO'),FLAT,MSG('View Record'), |
  TIP('View Record')
                       BUTTON('&Insert'),AT(58,180,49,14),USE(?Insert:3),LEFT,ICON('WAINSERT.ICO'),DISABLE,FLAT,HIDE, |
  MSG('Insert a Record'),TIP('Insert a Record')
                       BUTTON('&Close'),AT(389,180,49,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
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
SetAlerts              PROCEDURE(),DERIVED
TakeKey                PROCEDURE(),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:StepClass StepClass                            ! Default Step Manager
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END


  CODE
? DEBUGHOOK(TestCompanyCSV:Record)
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
  GlobalErrors.SetProcedureName('TestCsvImportCompanyBrowse')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse:1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  Relate:TestCompanyCSV.Open()                             ! File TestCompanyCSV used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:TestCompanyCSV,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,)                                     ! Add the sort order for  for sort order 1
  BRW1.AddField(ImpCo:company_name,BRW1.Q.ImpCo:company_name) ! Field ImpCo:company_name is a hot field or requires assignment from browse
  BRW1.AddField(ImpCo:address1,BRW1.Q.ImpCo:address1)      ! Field ImpCo:address1 is a hot field or requires assignment from browse
  BRW1.AddField(ImpCo:address2,BRW1.Q.ImpCo:address2)      ! Field ImpCo:address2 is a hot field or requires assignment from browse
  BRW1.AddField(ImpCo:city,BRW1.Q.ImpCo:city)              ! Field ImpCo:city is a hot field or requires assignment from browse
  BRW1.AddField(ImpCo:state,BRW1.Q.ImpCo:state)            ! Field ImpCo:state is a hot field or requires assignment from browse
  BRW1.AddField(ImpCo:zip5,BRW1.Q.ImpCo:zip5)              ! Field ImpCo:zip5 is a hot field or requires assignment from browse
  BRW1.AddField(ImpCo:contact_name,BRW1.Q.ImpCo:contact_name) ! Field ImpCo:contact_name is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('TestCsvImportCompanyBrowse',QuickWindow)   ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: TestCsvImportCompanyForm
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:TestCompanyCSV.Close()
  END
  IF SELF.Opened
    INIMgr.Update('TestCsvImportCompanyBrowse',QuickWindow) ! Save window data to non-volatile store
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
    TestCsvImportCompanyForm
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:3
  END
  SELF.ViewControl = ?View:2                               ! Setup the control used to initiate view only mode


BRW1.SetAlerts PROCEDURE

  CODE
  SELF.EditViaPopup = False
  PARENT.SetAlerts


BRW1.TakeKey PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  IF KEYCODE()=MouseLeft2 THEN 
     POST(EVENT:Accepted,?View:2)  
     RETURN ReturnValue
  END 
  ReturnValue = PARENT.TakeKey()
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Process
!!! Process the TestCompanyCSV File
!!! </summary>
TestCsvImportProcessToImport PROCEDURE 

UniqueCustNumber    LONG 
Progress:Thermometer BYTE                                  ! 
AbortAllFlag         BYTE                                  ! 
RecordNo             LONG                                  ! 
Process:View         VIEW(TestCompanyCSV)
                     END
ProgressWindow       WINDOW('Process TestCompanyCSV'),AT(,,142,59),FONT('Microsoft Sans Serif',8,,FONT:regular, |
  CHARSET:DEFAULT),DOUBLE,CENTER,GRAY,TIMER(1)
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,100)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel Process'), |
  TIP('Cancel Process')
                     END

ThisWindow           CLASS(ReportManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
                     END

ThisProcess          CLASS(ProcessClass)                   ! Process Manager
TakeRecord             PROCEDURE(),BYTE,PROC,DERIVED
                     END

ProgressMgr          StepClass                             ! Progress Manager
DOO     CLASS
ImportRtn       PROCEDURE() 
ImportCompany   PROCEDURE(),BOOL   !FYI will Import Customer Too
ImportCustomer  PROCEDURE(),BOOL,PROC
        END 

  CODE
? DEBUGHOOK(Customer:Record)
? DEBUGHOOK(CustomerCompany:Record)
? DEBUGHOOK(TestCompanyCSV:Record)
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
  GlobalErrors.SetProcedureName('TestCsvImportProcessToImport')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Progress:Thermometer
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  Relate:Customer.Open()                                   ! File Customer used by this procedure, so make sure it's RelationManager is open
  Relate:TestCompanyCSV.Open()                             ! File TestCompanyCSV used by this procedure, so make sure it's RelationManager is open
  Access:CustomerCompany.UseFile()                         ! File referenced in 'Other Files' so need to inform it's FileManager
  SELF.FilesOpened = True
    Access:Customer.UseFile()
    SET(Cus:CustomerNumberKey)      !This Key is Autonumbered by the Templates
    PREVIOUS(Customer)
    UniqueCustNumber = CHOOSE(~ERRORCODE(), Cus:CustomerNumber,110)
  SELF.Open(ProgressWindow)                                ! Open window
  Do DefineListboxStyle
  INIMgr.Fetch('TestCsvImportProcessToImport',ProgressWindow) ! Restore window settings from non-volatile store
  ProgressWindow{Prop:Timer} = 10                          ! Assign timer interval
  ThisProcess.Init(Process:View, Relate:TestCompanyCSV, ?Progress:PctText, Progress:Thermometer)
  ThisProcess.AddSortOrder()
  ProgressWindow{Prop:Text} = 'Processing Records'
  ?Progress:PctText{Prop:Text} = '0% Completed'
  SELF.Init(ThisProcess)
  ?Progress:UserString{Prop:Text}=''
  SELF.AddItem(?Progress:Cancel, RequestCancelled)
  SEND(TestCompanyCSV,'QUICKSCAN=on')
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Customer.Close()
    Relate:TestCompanyCSV.Close()
  END
  IF SELF.Opened
    INIMgr.Update('TestCsvImportProcessToImport',ProgressWindow) ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue

DOO.ImportRtn   PROCEDURE()
    CODE
    RecordNo += 1
    IF ~DOO.ImportCompany() THEN RETURN.
    Doo.ImportCustomer()
    RETURN
DOO.ImportCompany   PROCEDURE()  
    CODE
    IF ~ImpCo:state THEN ImpCo:state='WA' ; ImpCo:zip5='91234' .
    GET(CustomerCompany,0)
    CLEAR(CustomerCompany)
    CusCom:GUID = MakeGUID()
    CusCom:CompanyName  = ImpCo:company_name
    CusCom:Street=CLIP(ImpCo:address1) & CHOOSE(~ImpCo:address2,'','<13,10>' & ImpCo:address2 )
    CusCom:City        = ImpCo:city
    CusCom:State       = ImpCo:state
    CusCom:PostalCode  = ImpCo:zip5 & CHOOSE(~ImpCo:zip4,'','-'& ImpCo:zip4)
    CusCom:Phone        = TestDataPhone() 
    
    ADD(CustomerCompany)
    IF ~ERRORCODE() THEN RETURN True.

    CASE Message('AddOneRtn ADD(CustomerCompany) '& Err4Msg() & |
         '<13,10>={40}' & |
         '<13,10>POINTER(Csv)=' & POINTER(TestCompanyCSV) & |
         '<13,10>RecordNo=' & RecordNo & |
         '<13,10>CusCom:GUID=' & CusCom:GUID & |
         '<13,10>CusCom:CompanyName=' & CusCom:CompanyName & |
         '<13,10><13,10>DUPLICATE(CustomerCompany)=' & DUPLICATE(CustomerCompany) & |
         '<13,10>DUPLICATE(CusCom:GuidKey)=' & DUPLICATE(CusCom:GuidKey) & |
         '<13,10>DUPLICATE(CusCom:CompanyNameKey)=' & DUPLICATE(CusCom:CompanyNameKey) & |
         '<13,10>Error() again at Bottom: ' & ErrorCode()&' '& Error() & |
         '','AddOne Error',,'Continue|Abort All Adds')
    OF 1              
    OF 2 ; AbortAllFlag=True 
    END 

    RETURN False 

  OMIT('**END**')
    CustomerCompany      FILE,DRIVER('SQLite'),OWNER(Glo:Owner),NAME('CustomerCompany'),PRE(CusCom),BINDABLE,CREATE,THREAD ! Default company information
    CusCom:GuidKey                  KEY(CusCom:GUID),NAME('CustomerCompany_GuidKey'),NOCASE,PRIMARY !                     
    CusCom:CompanyNameKey           KEY(CusCom:CompanyName),NAME('CustomerCompany_CompanyNameKey'),NOCASE !                     
    CusCom:Record                   RECORD,PRE()
    CusCom:GUID        =    ! STRING(16) 
    CusCom:CompanyName =    ! STRING(100)
    CusCom:Street      =    ! STRING(255)
    CusCom:City        =    ! STRING(100)
    CusCom:State       =    ! STRING(100)
    CusCom:PostalCode  =    ! STRING(100)
    CusCom:Phone       =    ! STRING(100)
                         END
                     END   
  !end of OMIT('**END**')
DOO.ImportCustomer  PROCEDURE()
    CODE

    IF ~ImpCo:contact_address1 THEN     !Some import data is blank 
        ImpCo:contact_address1 = ImpCo:address1
        ImpCo:contact_address2 = ImpCo:address2
    END
    IF ~ImpCo:contact_city  THEN   ImpCo:contact_city   = ImpCo:city.
    IF ~ImpCo:contact_state THEN   ImpCo:contact_state  = ImpCo:state.
    IF ~ImpCo:contact_zip5  THEN   ImpCo:contact_zip5   = ImpCo:zip5.
    
 
    GET(Customer,0)
    CLEAR(Customer)
    Cus:GUID = MakeGUID()
    UniqueCustNumber += 1
    Cus:CustomerNumber = UniqueCustNumber

    Cus:CompanyGuid = CusCom:GUID
    Cus:FirstName   = ImpCo:first_name
    Cus:LastName    = ImpCo:surname
    Cus:Street      = CLIP(ImpCo:contact_address1) & |
                      CHOOSE(~ImpCo:contact_address2 ,'','<13,10>'& ImpCo:contact_address2)
    Cus:City        = ImpCo:contact_city
    Cus:State       = ImpCo:contact_state
    Cus:PostalCode  = ImpCo:contact_zip5 
    IF ImpCo:contact_telephone >= 1000000000
       Cus:Phone = ImpCo:contact_telephone    
       Cus:Phone=SUB(Cus:Phone,1,3) &'-'& SUB(Cus:Phone,4,3) &'-'& SUB(Cus:Phone,7,4) &'  '& SUB(Cus:Phone,11,100)
    ELSE 
       !Cus:Phone = TestDataPhone() 
    END 
    Cus:MobilePhone = TestDataPhone() 
    Cus:Email = CLIP(Cus:FirstName) &'.'&  CLIP(Cus:LastName) &'@'& |  ! CLIP(SUB(CusCom:CompanyName,1,16)) &'.com' 
                SUB(ImpCo:url,4,99)
                !CHOOSE(RANDOM(1,3),'Gmail.con','Yahoo.con','HotMail.con')   !use con not com incase we use this data
    SmashSpaces(Cus:Email)

    ADD(Customer)

    IF ~ERRORCODE() THEN RETURN True. 

    CASE Message('AddOneRtn ADD(Customer) '& Err4Msg() & |
         '<13,10>={40}' & |
         '<13,10>RecordNo=' & RecordNo & |
         '<13,10>Cus:GUID=' & Cus:GUID & |
         '<13,10>Cus:CustomerNumber=' & Cus:CustomerNumber & |
         '<13,10>Cus:FirstName=' & Cus:FirstName & |
         '<13,10>Cus:LastName=' & Cus:LastName & |
         '<13,10>Error() again at Bottom: ' & ErrorCode()&' '& Error() & |
         '','AddOne Error',,'Continue|Abort All Adds')
    OF 1              
    OF 2 ; AbortAllFlag=True ; RETURN False
    END 
 
    GET(Customer,Cus:GuidKey)      !Is it a GUID duplicate?
    IF ~ERRORCODE() THEN
        Message('Last ADD(Customer) was GUID duplicate! '&  |
         '<13,10>Found below GUID already in the File!' & |
         '<13,10>Cus:GUID=' & Cus:GUID & |
         '<13,10>Cus:FirstName=' & Cus:FirstName & |
         '<13,10>Cus:LastName=' & Cus:LastName & |
         '','AddOneRtn')  
    END 
    
    RETURN  False 
    

ThisProcess.TakeRecord PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.TakeRecord()
  DOO.ImportRtn() 
  
  IF AbortAllFlag THEN RETURN Level:Fatal .
  RETURN ReturnValue

!!! <summary>
!!! Generated from procedure template - Window
!!! </summary>
TestScratchWindow PROCEDURE 

Window               WINDOW('Caption'),AT(,,395,224),FONT('Segoe UI',9),RESIZE,GRAY,MDI,SYSTEM
                       BUTTON('&OK'),AT(297,201,41,14),USE(?OkButton),DEFAULT
                       BUTTON('&Cancel'),AT(342,201,41,14),USE(?CancelButton),STD(STD:Close)
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass

  CODE
? DEBUGHOOK(Customer:Record)
? DEBUGHOOK(CustomerCompany:Record)
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
  GlobalErrors.SetProcedureName('TestScratchWindow')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?OkButton
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  Relate:Customer.Open()                                   ! File Customer used by this procedure, so make sure it's RelationManager is open
  Access:CustomerCompany.UseFile()                         ! File referenced in 'Other Files' so need to inform it's FileManager
  SELF.FilesOpened = True
  SELF.Open(Window)                                        ! Open window
  Do DefineListboxStyle
  INIMgr.Fetch('TestScratchWindow',Window)                 ! Restore window settings from non-volatile store
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Customer.Close()
  END
  IF SELF.Opened
    INIMgr.Update('TestScratchWindow',Window)              ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue

