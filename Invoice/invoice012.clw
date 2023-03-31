

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE012.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Form Product
!!! </summary>
UpdateProduct PROCEDURE 

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::Pro:Record  LIKE(Pro:RECORD),THREAD
QuickWindow          WINDOW('Form Product'),AT(,,358,174),FONT('Segoe UI',10,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,AUTO,CENTER,GRAY,IMM,MDI,HLP('UpdateProduct'),SYSTEM
                       SHEET,AT(4,4,350,148),USE(?CurrentTab)
                         TAB('Tab'),USE(?Tab:1)
                           PROMPT('Product Code:'),AT(8,20),USE(?Pro:ProductCode:Prompt),TRN
                           ENTRY(@s100),AT(84,20,266,10),USE(Pro:ProductCode),MSG('User defined Product Number'),REQ
                           PROMPT('Product Name:'),AT(8,34),USE(?Pro:ProductName:Prompt),TRN
                           ENTRY(@s100),AT(84,34,266,10),USE(Pro:ProductName),REQ
                           PROMPT('Description:'),AT(8,48),USE(?Pro:Description:Prompt),TRN
                           TEXT,AT(84,48,266,30),USE(Pro:Description),MSG('Enter Product''s Description'),REQ
                           PROMPT('Price:'),AT(8,82),USE(?Pro:Price:Prompt),TRN
                           ENTRY(@n15.2),AT(84,82,64,10),USE(Pro:Price),DECIMAL(12),MSG('Enter Product''s Price')
                           PROMPT('Quantity In Stock:'),AT(8,96),USE(?Pro:QuantityInStock:Prompt),TRN
                           ENTRY(@n-14),AT(84,96,64,10),USE(Pro:QuantityInStock),RIGHT(1),MSG('Enter quantity of p' & |
  'roduct in stock')
                           PROMPT('Reorder Quantity:'),AT(8,110),USE(?Pro:ReorderQuantity:Prompt),TRN
                           ENTRY(@n13),AT(84,110,56,10),USE(Pro:ReorderQuantity),RIGHT(1),MSG('Enter product''s qu' & |
  'antity for re-order')
                           PROMPT('Cost:'),AT(8,124),USE(?Pro:Cost:Prompt),TRN
                           ENTRY(@n-15.2),AT(84,124,68,10),USE(Pro:Cost),MSG('Enter product''s cost')
                           PROMPT('Image Filename:'),AT(8,138),USE(?Pro:ImageFilename:Prompt),TRN
                           ENTRY(@s255),AT(84,138,266,10),USE(Pro:ImageFilename)
                         END
                       END
                       BUTTON('&OK'),AT(250,156,50,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,MSG('Accept dat' & |
  'a and close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(304,156,50,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel operation'), |
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
? DEBUGHOOK(Product:Record)
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
  GlobalErrors.SetProcedureName('UpdateProduct')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Pro:ProductCode:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(Pro:Record,History::Pro:Record)
  SELF.AddHistoryField(?Pro:ProductCode,2)
  SELF.AddHistoryField(?Pro:ProductName,3)
  SELF.AddHistoryField(?Pro:Description,4)
  SELF.AddHistoryField(?Pro:Price,5)
  SELF.AddHistoryField(?Pro:QuantityInStock,6)
  SELF.AddHistoryField(?Pro:ReorderQuantity,7)
  SELF.AddHistoryField(?Pro:Cost,8)
  SELF.AddHistoryField(?Pro:ImageFilename,9)
  SELF.AddUpdateFile(Access:Product)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:Product.Open()                                    ! File Product used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:Product
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
    ?Pro:ProductCode{PROP:ReadOnly} = True
    ?Pro:ProductName{PROP:ReadOnly} = True
    ?Pro:Price{PROP:ReadOnly} = True
    ?Pro:QuantityInStock{PROP:ReadOnly} = True
    ?Pro:ReorderQuantity{PROP:ReadOnly} = True
    ?Pro:Cost{PROP:ReadOnly} = True
    ?Pro:ImageFilename{PROP:ReadOnly} = True
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateProduct',QuickWindow)                ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Product.Close()
  END
  IF SELF.Opened
    INIMgr.Update('UpdateProduct',QuickWindow)             ! Save window data to non-volatile store
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

