

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE017.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form Invoice
!!! </summary>
UpdateInvoice PROCEDURE 

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::Inv:Record  LIKE(Inv:RECORD),THREAD
QuickWindow          WINDOW('Form Invoice'),AT(,,358,186),FONT('Segoe UI',10,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,AUTO,CENTER,GRAY,IMM,MDI,HLP('UpdateInvoice'),SYSTEM
                       SHEET,AT(4,4,350,160),USE(?CurrentTab)
                         TAB('Tab'),USE(?Tab:1)
                           PROMPT('Invoice Number:'),AT(8,20),USE(?Inv:InvoiceNumber:Prompt),TRN
                           STRING(@n07),AT(72,20,40,10),USE(Inv:InvoiceNumber),TRN
                           PROMPT('Date:'),AT(8,34),USE(?Inv:Date:Prompt),TRN
                           STRING(@d10),AT(72,34,104,10),USE(Inv:Date),TRN
                           CHECK('Order Shipped'),AT(72,48,70,8),USE(Inv:OrderShipped),MSG('Checked if order is shipped'),TRN
                           PROMPT('&First Name:'),AT(8,60),USE(?Inv:FirstName:Prompt),TRN
                           ENTRY(@s100),AT(72,60,278,10),USE(Inv:FirstName),MSG('Enter the first name of customer'),REQ
                           PROMPT('&Last Name:'),AT(8,74),USE(?Inv:LastName:Prompt),TRN
                           ENTRY(@s100),AT(72,74,278,10),USE(Inv:LastName),MSG('Enter the last name of customer'),REQ
                           PROMPT('&Street:'),AT(8,88),USE(?Inv:Street:Prompt),TRN
                           TEXT,AT(72,88,278,30),USE(Inv:Street),MSG('Enter the first line address of customer')
                           PROMPT('&City:'),AT(8,122),USE(?Inv:City:Prompt),TRN
                           ENTRY(@s100),AT(72,122,278,10),USE(Inv:City),MSG('Enter  city of customer')
                           PROMPT('&State:'),AT(8,136),USE(?Inv:State:Prompt),TRN
                           ENTRY(@s100),AT(72,136,278,10),USE(Inv:State),MSG('Enter state of customer')
                           PROMPT('&Zip Code:'),AT(8,150),USE(?Inv:PostalCode:Prompt),TRN
                           ENTRY(@s100),AT(72,150,278,10),USE(Inv:PostalCode),MSG('Enter zipcode of customer'),TIP('Enter zipc' & |
  'ode of customer')
                         END
                         TAB('Tab'),USE(?Tab:2)
                           PROMPT('Mobile Phone:'),AT(8,20),USE(?Inv:Phone:Prompt),TRN
                           ENTRY(@s100),AT(72,20,278,10),USE(Inv:Phone)
                           PROMPT('Total:'),AT(8,34),USE(?Inv:Total:Prompt),TRN
                           STRING(@n-15.2),AT(72,34,68,10),USE(Inv:Total),TRN
                           PROMPT('Note:'),AT(8,48),USE(?Inv:Note:Prompt),TRN
                           TEXT,AT(72,48,278,30),USE(Inv:Note)
                         END
                       END
                       BUTTON('&OK'),AT(250,168,50,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,MSG('Accept dat' & |
  'a and close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(304,168,50,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel operation'), |
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
  QuickWindow{PROP:Text} = ActionMessage                   ! Display status message in title bar
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
  SELF.AddHistoryField(?Inv:OrderShipped,6)
  SELF.AddHistoryField(?Inv:FirstName,7)
  SELF.AddHistoryField(?Inv:LastName,8)
  SELF.AddHistoryField(?Inv:Street,9)
  SELF.AddHistoryField(?Inv:City,10)
  SELF.AddHistoryField(?Inv:State,11)
  SELF.AddHistoryField(?Inv:PostalCode,12)
  SELF.AddHistoryField(?Inv:Phone,13)
  SELF.AddHistoryField(?Inv:Total,14)
  SELF.AddHistoryField(?Inv:Note,15)
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
  SELF.Open(QuickWindow)                                   ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?Inv:FirstName{PROP:ReadOnly} = True
    ?Inv:LastName{PROP:ReadOnly} = True
    ?Inv:City{PROP:ReadOnly} = True
    ?Inv:State{PROP:ReadOnly} = True
    ?Inv:PostalCode{PROP:ReadOnly} = True
    ?Inv:Phone{PROP:ReadOnly} = True
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateInvoice',QuickWindow)                ! Restore window settings from non-volatile store
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
    INIMgr.Update('UpdateInvoice',QuickWindow)             ! Save window data to non-volatile store
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

