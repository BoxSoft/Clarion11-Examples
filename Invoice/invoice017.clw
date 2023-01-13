

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE017.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('INVOICE016.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form Invoice
!!! </summary>
UpdateInvoice PROCEDURE 

                              MAP
TakeCustomerSelected            PROCEDURE
                              END
CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::Inv:Record  LIKE(Inv:RECORD),THREAD
Window               WINDOW('Invoice'),AT(,,316,196),FONT('Segoe UI',10,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,AUTO,CENTER,IMM,MDI,SYSTEM
                       PROMPT('Invoice Number:'),AT(9,3),USE(?Inv:InvoiceNumber:Prompt)
                       ENTRY(@n07),AT(68,3,60,10),USE(Inv:InvoiceNumber),MSG('Invoice number for each order')
                       PROMPT('Date:'),AT(9,16),USE(?Inv:Date:Prompt)
                       ENTRY(@d10),AT(68,17,60,10),USE(Inv:Date),REQ
                       PROMPT('&First Name:'),AT(9,30),USE(?Inv:FirstName:Prompt:2)
                       ENTRY(@s100),AT(68,31,240,10),USE(Inv:FirstName,,?Inv:FirstName:2),MSG('Enter the first' & |
  ' name of customer'),REQ
                       PROMPT('&Last Name:'),AT(9,44),USE(?Inv:LastName:Prompt)
                       ENTRY(@s100),AT(68,44,240,10),USE(Inv:LastName),MSG('Enter the last name of customer'),REQ
                       PROMPT('&Street:'),AT(9,57),USE(?Inv:Street:Prompt)
                       TEXT,AT(68,58,240,48),USE(Inv:Street),MSG('Enter the first line address of customer')
                       PROMPT('&City:'),AT(9,109),USE(?Inv:City:Prompt)
                       ENTRY(@s100),AT(68,110,240,10),USE(Inv:City),MSG('Enter  city of customer')
                       PROMPT('&State:'),AT(9,123),USE(?Inv:State:Prompt)
                       ENTRY(@s100),AT(68,123,240,10),USE(Inv:State),MSG('Enter state of customer')
                       PROMPT('&Zip Code:'),AT(9,136),USE(?Inv:PostalCode:Prompt)
                       ENTRY(@s100),AT(68,137,240,10),USE(Inv:PostalCode),MSG('Enter zipcode of customer'),TIP('Enter zipc' & |
  'ode of customer')
                       PROMPT('Mobile Phone:'),AT(9,150),USE(?Inv:Phone:Prompt)
                       ENTRY(@s100),AT(68,151,240,10),USE(Inv:Phone)
                       PROMPT('Customer Order Number:'),AT(9,164,55,16),USE(?Inv:CustomerOrderNumber:Prompt)
                       ENTRY(@s100),AT(68,164,240,10),USE(Inv:CustomerOrderNumber),REQ
                       CHECK('Order Shipped'),AT(239,3),USE(Inv:OrderShipped),MSG('Checked if order is shipped')
                       BUTTON('&OK'),AT(205,177,50,14),USE(?OK),DEFAULT
                       BUTTON('&Cancel'),AT(258,177,50,14),USE(?Cancel)
                       BUTTON,AT(54,31,10,10),USE(?BUTTON:SelectCustomer),ICON('Lookup.ico'),FLAT
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
? DEBUGHOOK(Invoice:Record)
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
  Window{PROP:Text} = ActionMessage                        ! Display status message in title bar
  PARENT.Ask


ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('UpdateInvoice')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Inv:InvoiceNumber:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(Inv:Record,History::Inv:Record)
  SELF.AddHistoryField(?Inv:InvoiceNumber,3)
  SELF.AddHistoryField(?Inv:Date,4)
  SELF.AddHistoryField(?Inv:FirstName:2,7)
  SELF.AddHistoryField(?Inv:LastName,8)
  SELF.AddHistoryField(?Inv:Street,9)
  SELF.AddHistoryField(?Inv:City,10)
  SELF.AddHistoryField(?Inv:State,11)
  SELF.AddHistoryField(?Inv:PostalCode,12)
  SELF.AddHistoryField(?Inv:Phone,13)
  SELF.AddHistoryField(?Inv:CustomerOrderNumber,5)
  SELF.AddHistoryField(?Inv:OrderShipped,6)
  SELF.AddUpdateFile(Access:Invoice)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:Invoice.SetOpenRelated()
  Relate:Invoice.Open()                                    ! File Invoice used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:Invoice
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
  SELF.Open(Window)                                        ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?Inv:InvoiceNumber{PROP:ReadOnly} = True
    ?Inv:Date{PROP:ReadOnly} = True
    ?Inv:FirstName:2{PROP:ReadOnly} = True
    ?Inv:LastName{PROP:ReadOnly} = True
    ?Inv:City{PROP:ReadOnly} = True
    ?Inv:State{PROP:ReadOnly} = True
    ?Inv:PostalCode{PROP:ReadOnly} = True
    ?Inv:Phone{PROP:ReadOnly} = True
    ?Inv:CustomerOrderNumber{PROP:ReadOnly} = True
    DISABLE(?BUTTON:SelectCustomer)
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateInvoice',Window)                     ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Invoice.Close()
  END
  IF SELF.Opened
    INIMgr.Update('UpdateInvoice',Window)                  ! Save window data to non-volatile store
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
    OF ?BUTTON:SelectCustomer
      ThisWindow.Update()
        GlobalRequest = SelectRecord                       ! Set Action for Lookup
        SelectCustomer                                     ! Call the Lookup Procedure
        IF GlobalResponse = RequestCompleted               ! IF Lookup completed
          TakeCustomerSelected()                           ! Source on Completion
        END                                                ! END (IF Lookup completed)
        GlobalResponse = RequestCancelled                  ! Clear Result
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

TakeCustomerSelected          PROCEDURE
  CODE
  Inv:CustomerGuid = Cus:GUID
  Inv:FirstName    = Cus:FirstName
  Inv:LastName     = Cus:LastName
  Inv:Street       = Cus:Street
  Inv:City         = Cus:City
  Inv:State        = Cus:State
  Inv:PostalCode   = Cus:PostalCode
  Inv:Phone        = Cus:Phone
  
