

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE019.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form Customer
!!! </summary>
UpdateCustomer PROCEDURE 

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::Cus:Record  LIKE(Cus:RECORD),THREAD
QuickWindow          WINDOW('Form Customer'),AT(,,358,188),FONT('Segoe UI',10,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('UpdateCustomer'),SYSTEM
                       SHEET,AT(4,4,350,162),USE(?CurrentTab)
                         TAB('Tab'),USE(?Tab:1)
                           PROMPT('&Company:'),AT(8,20),USE(?Cus:CompanyGuid:Prompt),TRN
                           ENTRY(@s16),AT(64,20,68,10),USE(Cus:CompanyGuid),CAP,MSG('Enter the customer''s company')
                           PROMPT('&First Name:'),AT(8,34),USE(?Cus:FirstName:Prompt),TRN
                           ENTRY(@s100),AT(64,34,286,10),USE(Cus:FirstName),CAP,MSG('Enter the first name of customer'), |
  REQ
                           PROMPT('&Last Name:'),AT(8,48),USE(?Cus:LastName:Prompt),TRN
                           ENTRY(@s100),AT(64,48,286,10),USE(Cus:LastName),CAP,MSG('Enter the last name of customer'), |
  REQ
                           PROMPT('&Street:'),AT(8,62),USE(?Cus:Street:Prompt),TRN
                           TEXT,AT(64,62,286,30),USE(Cus:Street),MSG('Enter the first line address of customer')
                           PROMPT('&City:'),AT(8,96),USE(?Cus:City:Prompt),TRN
                           ENTRY(@s100),AT(64,96,286,10),USE(Cus:City),CAP,MSG('Enter  city of customer')
                           PROMPT('&State:'),AT(8,110),USE(?Cus:State:Prompt),TRN
                           ENTRY(@s100),AT(64,110,286,10),USE(Cus:State),UPR,MSG('Enter state of customer')
                           PROMPT('&Zip Code:'),AT(8,124),USE(?Cus:PostalCode:Prompt),TRN
                           ENTRY(@s100),AT(64,124,286,10),USE(Cus:PostalCode),MSG('Enter zipcode of customer'),TIP('Enter zipc' & |
  'ode of customer')
                           PROMPT('Mobile Phone:'),AT(8,138),USE(?Cus:Phone:Prompt),TRN
                           ENTRY(@s100),AT(64,138,286,10),USE(Cus:Phone)
                           PROMPT('Mobile Phone:'),AT(8,152),USE(?Cus:MobilePhone:Prompt),TRN
                           ENTRY(@s100),AT(64,152,286,10),USE(Cus:MobilePhone)
                         END
                         TAB('Tab'),USE(?Tab:2)
                           PROMPT('Email:'),AT(8,20),USE(?Cus:Email:Prompt),TRN
                           ENTRY(@s100),AT(64,20,286,10),USE(Cus:Email)
                         END
                       END
                       BUTTON('&OK'),AT(250,170,50,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,MSG('Accept dat' & |
  'a and close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(304,170,50,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel operation'), |
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
? DEBUGHOOK(Customer:Record)
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
    ActionMessage = 'Record Will Be Added'
  OF ChangeRecord
    ActionMessage = 'Record Will Be Changed'
  END
  QuickWindow{PROP:Text} = ActionMessage                   ! Display status message in title bar
  PARENT.Ask


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('UpdateCustomer')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Cus:CompanyGuid:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(Cus:Record,History::Cus:Record)
  SELF.AddHistoryField(?Cus:CompanyGuid,3)
  SELF.AddHistoryField(?Cus:FirstName,4)
  SELF.AddHistoryField(?Cus:LastName,5)
  SELF.AddHistoryField(?Cus:Street,6)
  SELF.AddHistoryField(?Cus:City,7)
  SELF.AddHistoryField(?Cus:State,8)
  SELF.AddHistoryField(?Cus:PostalCode,9)
  SELF.AddHistoryField(?Cus:Phone,10)
  SELF.AddHistoryField(?Cus:MobilePhone,11)
  SELF.AddHistoryField(?Cus:Email,12)
  SELF.AddUpdateFile(Access:Customer)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:Customer.Open()                                   ! File Customer used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:Customer
  IF SELF.Request = ViewRecord AND NOT SELF.BatchProcessing ! Setup actions for ViewOnly Mode
    SELF.InsertAction = Insert:None
    SELF.DeleteAction = Delete:None
    SELF.ChangeAction = Change:None
    SELF.CancelAction = Cancel:Cancel
    SELF.OkControl = 0
  ELSE
    SELF.ChangeAction = Change:Caller                      ! Changes allowed
    SELF.CancelAction = Cancel:Cancel+Cancel:Query         ! Confirm cancel
    SELF.OkControl = ?OK
    IF SELF.PrimeUpdate() THEN RETURN Level:Notify.
  END
  SELF.Open(QuickWindow)                                   ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?Cus:CompanyGuid{PROP:ReadOnly} = True
    ?Cus:FirstName{PROP:ReadOnly} = True
    ?Cus:LastName{PROP:ReadOnly} = True
    ?Cus:City{PROP:ReadOnly} = True
    ?Cus:State{PROP:ReadOnly} = True
    ?Cus:PostalCode{PROP:ReadOnly} = True
    ?Cus:Phone{PROP:ReadOnly} = True
    ?Cus:MobilePhone{PROP:ReadOnly} = True
    ?Cus:Email{PROP:ReadOnly} = True
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateCustomer',QuickWindow)               ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
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
    INIMgr.Update('UpdateCustomer',QuickWindow)            ! Save window data to non-volatile store
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

