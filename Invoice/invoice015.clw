

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE015.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form InvoiceDetail
!!! </summary>
UpdateInvoiceDetail PROCEDURE 

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::InvDet:Record LIKE(InvDet:RECORD),THREAD
QuickWindow          WINDOW('Form InvoiceDetail'),AT(,,158,168),FONT('Segoe UI',10,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('UpdateInvoiceDetail'),SYSTEM
                       SHEET,AT(4,4,150,142),USE(?CurrentTab)
                         TAB('Tab'),USE(?Tab:1)
                           PROMPT('Product Guid:'),AT(8,20),USE(?InvDet:ProductGuid:Prompt),TRN
                           ENTRY(@s16),AT(68,20,68,10),USE(InvDet:ProductGuid),DECIMAL(14)
                           PROMPT('Line Number:'),AT(8,34),USE(?InvDet:LineNumber:Prompt),TRN
                           STRING(@n-14),AT(68,34,64,10),USE(InvDet:LineNumber),RIGHT(1),TRN
                           PROMPT('Quantity:'),AT(8,48),USE(?InvDet:Quantity:Prompt),TRN
                           SPIN(@n-14),AT(68,48,79,10),USE(InvDet:Quantity),RIGHT(1),RANGE(1,99999)
                           PROMPT('Price:'),AT(8,62),USE(?InvDet:Price:Prompt),TRN
                           ENTRY(@n-15.2),AT(68,62,68,10),USE(InvDet:Price),DECIMAL(12),MSG('Enter Product''s Price')
                           PROMPT('Tax Rate:'),AT(8,76),USE(?InvDet:TaxRate:Prompt),TRN
                           ENTRY(@n7.4B),AT(68,76,40,10),USE(InvDet:TaxRate),MSG('Enter Consumer''s Tax rate')
                           PROMPT('Tax Paid:'),AT(8,90),USE(?InvDet:TaxPaid:Prompt),TRN
                           ENTRY(@n-15.2),AT(68,90,68,10),USE(InvDet:TaxPaid),DECIMAL(12),MSG('Enter Product''s Price')
                           PROMPT('Discount Rate:'),AT(8,104),USE(?InvDet:DiscountRate:Prompt),TRN
                           ENTRY(@n7.4B),AT(68,104,40,10),USE(InvDet:DiscountRate),MSG('Enter discount rate')
                           PROMPT('Discount:'),AT(8,118),USE(?InvDet:Discount:Prompt),TRN
                           ENTRY(@n-15.2),AT(68,118,68,10),USE(InvDet:Discount),DECIMAL(12),MSG('Enter Product''s Price')
                           PROMPT('Total:'),AT(8,132),USE(?InvDet:Total:Prompt),TRN
                           STRING(@n-15.2),AT(68,132,68,10),USE(InvDet:Total),TRN
                         END
                         TAB('Tab'),USE(?Tab:2)
                           PROMPT('Note:'),AT(8,20),USE(?InvDet:Note:Prompt),TRN
                           TEXT,AT(68,20,82,30),USE(InvDet:Note)
                         END
                       END
                       BUTTON('&OK'),AT(50,150,50,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,MSG('Accept dat' & |
  'a and close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(104,150,50,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel operation'), |
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
  GlobalErrors.SetProcedureName('UpdateInvoiceDetail')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?InvDet:ProductGuid:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(InvDet:Record,History::InvDet:Record)
  SELF.AddHistoryField(?InvDet:ProductGuid,3)
  SELF.AddHistoryField(?InvDet:LineNumber,4)
  SELF.AddHistoryField(?InvDet:Quantity,5)
  SELF.AddHistoryField(?InvDet:Price,6)
  SELF.AddHistoryField(?InvDet:TaxRate,7)
  SELF.AddHistoryField(?InvDet:TaxPaid,8)
  SELF.AddHistoryField(?InvDet:DiscountRate,9)
  SELF.AddHistoryField(?InvDet:Discount,10)
  SELF.AddHistoryField(?InvDet:Total,11)
  SELF.AddHistoryField(?InvDet:Note,12)
  SELF.AddUpdateFile(Access:InvoiceDetail)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:InvoiceDetail.SetOpenRelated()
  Relate:InvoiceDetail.Open()                              ! File InvoiceDetail used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:InvoiceDetail
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
    ?InvDet:ProductGuid{PROP:ReadOnly} = True
    ?InvDet:Price{PROP:ReadOnly} = True
    ?InvDet:TaxRate{PROP:ReadOnly} = True
    ?InvDet:TaxPaid{PROP:ReadOnly} = True
    ?InvDet:DiscountRate{PROP:ReadOnly} = True
    ?InvDet:Discount{PROP:ReadOnly} = True
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateInvoiceDetail',QuickWindow)          ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:InvoiceDetail.Close()
  END
  IF SELF.Opened
    INIMgr.Update('UpdateInvoiceDetail',QuickWindow)       ! Save window data to non-volatile store
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
    OF ?InvDet:Quantity
      IF Access:InvoiceDetail.TryValidateField(5)          ! Attempt to validate InvDet:Quantity in InvoiceDetail
        SELECT(?InvDet:Quantity)
        QuickWindow{PROP:AcceptAll} = False
        CYCLE
      ELSE
        FieldColorQueue.Feq = ?InvDet:Quantity
        GET(FieldColorQueue, FieldColorQueue.Feq)
        IF ERRORCODE() = 0
          ?InvDet:Quantity{PROP:FontColor} = FieldColorQueue.OldColor
          DELETE(FieldColorQueue)
        END
      END
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

