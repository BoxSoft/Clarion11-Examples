

   MEMBER('TestInvDev.clw')                                ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('TESTINVDEV002.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Select a Product Record
!!! </summary>
SelectProduct PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(Product)
                       PROJECT(Pro:ProductCode)
                       PROJECT(Pro:ProductName)
                       PROJECT(Pro:Description)
                       PROJECT(Pro:Price)
                       PROJECT(Pro:QuantityInStock)
                       PROJECT(Pro:ReorderQuantity)
                       PROJECT(Pro:Cost)
                       PROJECT(Pro:ImageFilename)
                       PROJECT(Pro:GUID)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Pro:ProductCode        LIKE(Pro:ProductCode)          !List box control field - type derived from field
Pro:ProductName        LIKE(Pro:ProductName)          !List box control field - type derived from field
Pro:Description        LIKE(Pro:Description)          !List box control field - type derived from field
Pro:Price              LIKE(Pro:Price)                !List box control field - type derived from field
Pro:QuantityInStock    LIKE(Pro:QuantityInStock)      !List box control field - type derived from field
Pro:ReorderQuantity    LIKE(Pro:ReorderQuantity)      !List box control field - type derived from field
Pro:Cost               LIKE(Pro:Cost)                 !List box control field - type derived from field
Pro:ImageFilename      LIKE(Pro:ImageFilename)        !List box control field - type derived from field
Pro:GUID               LIKE(Pro:GUID)                 !Primary key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Select a Product Record'),AT(,,358,198),FONT('Segoe UI',9,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('SelectProduct'),SYSTEM
                       LIST,AT(9,22,341,148),USE(?Browse:1),HVSCROLL,FORMAT('80L(2)|M~Product Code~L(2)@s100@8' & |
  '0L(2)|M~Product Name~L(2)@s100@80L(2)|M~Description~L(2)@s255@64D(28)|M~Price~C(0)@n' & |
  '15.2@72R(2)|M~Quantity In Stock~C(0)@n-14@68R(2)|M~Reorder Quantity~C(0)@n13@68D(32)' & |
  '|M~Cost~C(0)@n-15.2@80L(2)|M~Image~L(2)@s255@'),FROM(Queue:Browse:1),IMM,MSG('Browsing t' & |
  'he Product file')
                       BUTTON('&Select'),AT(4,180,49,14),USE(?Select:2),LEFT,ICON('WASELECT.ICO'),FLAT,MSG('Select the Record'), |
  TIP('Select the Record')
                       SHEET,AT(4,4,350,172),USE(?CurrentTab)
                         TAB('&GuidKey'),USE(?Tab:2)
                         END
                         TAB('&ProductCodeKey'),USE(?Tab:3)
                         END
                         TAB('&ProductNameKey'),USE(?Tab:4)
                         END
                       END
                       BUTTON('&Close'),AT(305,180,49,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort1:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 2
BRW1::Sort2:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 3
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
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

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('SelectProduct')
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
  Relate:Product.Open()                                    ! File Product used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Product,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,Pro:ProductCodeKey)                   ! Add the sort order for Pro:ProductCodeKey for sort order 1
  BRW1.AddLocator(BRW1::Sort1:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort1:Locator.Init(,Pro:ProductCode,1,BRW1)        ! Initialize the browse locator using  using key: Pro:ProductCodeKey , Pro:ProductCode
  BRW1.AddSortOrder(,Pro:ProductNameKey)                   ! Add the sort order for Pro:ProductNameKey for sort order 2
  BRW1.AddLocator(BRW1::Sort2:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort2:Locator.Init(,Pro:ProductName,1,BRW1)        ! Initialize the browse locator using  using key: Pro:ProductNameKey , Pro:ProductName
  BRW1.AddSortOrder(,Pro:GuidKey)                          ! Add the sort order for Pro:GuidKey for sort order 3
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 3
  BRW1::Sort0:Locator.Init(,Pro:GUID,1,BRW1)               ! Initialize the browse locator using  using key: Pro:GuidKey , Pro:GUID
  BRW1.AddField(Pro:ProductCode,BRW1.Q.Pro:ProductCode)    ! Field Pro:ProductCode is a hot field or requires assignment from browse
  BRW1.AddField(Pro:ProductName,BRW1.Q.Pro:ProductName)    ! Field Pro:ProductName is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Description,BRW1.Q.Pro:Description)    ! Field Pro:Description is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Price,BRW1.Q.Pro:Price)                ! Field Pro:Price is a hot field or requires assignment from browse
  BRW1.AddField(Pro:QuantityInStock,BRW1.Q.Pro:QuantityInStock) ! Field Pro:QuantityInStock is a hot field or requires assignment from browse
  BRW1.AddField(Pro:ReorderQuantity,BRW1.Q.Pro:ReorderQuantity) ! Field Pro:ReorderQuantity is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Cost,BRW1.Q.Pro:Cost)                  ! Field Pro:Cost is a hot field or requires assignment from browse
  BRW1.AddField(Pro:ImageFilename,BRW1.Q.Pro:ImageFilename) ! Field Pro:ImageFilename is a hot field or requires assignment from browse
  BRW1.AddField(Pro:GUID,BRW1.Q.Pro:GUID)                  ! Field Pro:GUID is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('SelectProduct',QuickWindow)                ! Restore window settings from non-volatile store
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
    INIMgr.Update('SelectProduct',QuickWindow)             ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  SELF.SelectControl = ?Select:2
  SELF.HideSelect = 1                                      ! Hide the select button when disabled
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)


BRW1.ResetSort PROCEDURE(BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  IF CHOICE(?CurrentTab) = 2
    RETURN SELF.SetSort(1,Force)
  ELSIF CHOICE(?CurrentTab) = 3
    RETURN SELF.SetSort(2,Force)
  ELSE
    RETURN SELF.SetSort(3,Force)
  END
  ReturnValue = PARENT.ResetSort(Force)
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Window
!!! Form InvoiceDetail
!!! </summary>
UpdateInvoiceDetail PROCEDURE 

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::InvDet:Record LIKE(InvDet:RECORD),THREAD
QuickWindow          WINDOW('Form InvoiceDetail'),AT(,,336,169),FONT('Segoe UI',9,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  CENTER,GRAY,IMM,MDI,HLP('UpdateInvoiceDetail'),SYSTEM
                       PROMPT('Line Number:'),AT(10,6),USE(?InvDet:LineNumber:Prompt),TRN
                       ENTRY(@n-14),AT(58,6,64,10),USE(InvDet:LineNumber),RIGHT
                       PROMPT('Quantity:'),AT(23,20),USE(?InvDet:Quantity:Prompt),TRN
                       SPIN(@n-14),AT(58,20,67,10),USE(InvDet:Quantity),RIGHT(1),RANGE(1,99999)
                       PROMPT('Price:'),AT(35,35),USE(?InvDet:Price:Prompt),TRN
                       ENTRY(@n-15.2),AT(58,34,67,10),USE(InvDet:Price),RIGHT,MSG('Enter Product''s Price')
                       PROMPT('Tax Rate:'),AT(25,48),USE(?InvDet:TaxRate:Prompt),TRN
                       ENTRY(@n7.4B),AT(58,48,40,10),USE(InvDet:TaxRate),RIGHT,MSG('Enter Consumer''s Tax rate')
                       PROMPT('Tax Paid:'),AT(25,62),USE(?InvDet:TaxPaid:Prompt),TRN
                       ENTRY(@n-15.2),AT(58,62,67,10),USE(InvDet:TaxPaid),RIGHT,MSG('Enter Product''s Price')
                       PROMPT('Discount Rate:'),AT(8,76),USE(?InvDet:DiscountRate:Prompt),TRN
                       ENTRY(@n7.4B),AT(58,76,40,10),USE(InvDet:DiscountRate),RIGHT,MSG('Enter discount rate')
                       PROMPT('Discount:'),AT(23,90),USE(?InvDet:Discount:Prompt),TRN
                       ENTRY(@n-15.2),AT(58,90,67,10),USE(InvDet:Discount),RIGHT,MSG('Enter Product''s Price')
                       PROMPT('Total:'),AT(35,105),USE(?InvDet:Total:Prompt),TRN
                       ENTRY(@n-15.2),AT(58,104,67,10),USE(InvDet:Total),RIGHT,SKIP
                       PROMPT('Note:'),AT(159,6),USE(?InvDet:Note:Prompt),TRN
                       TEXT,AT(159,17,166,41),USE(InvDet:Note),VSCROLL
                       PROMPT('This Detail GUID:'),AT(159,68),USE(?InvDet:GUID:Prompt),TRN
                       ENTRY(@s16),AT(213,68,81,10),USE(InvDet:GUID),SKIP
                       PROMPT('Invoice Guid:'),AT(158,82),USE(?InvDet:InvoiceGuid:Prompt)
                       ENTRY(@s16),AT(213,83,81),USE(InvDet:InvoiceGuid),SKIP
                       PROMPT('Product Guid:'),AT(158,99),USE(?InvDet:ProductGuid:Prompt),TRN
                       ENTRY(@s16),AT(213,99,81,10),USE(InvDet:ProductGuid)
                       BUTTON('&OK'),AT(117,136,49,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,MSG('Accept dat' & |
  'a and close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(170,136,49,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel operation'), |
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
CurCtrlFeq          LONG
FieldColorQueue     QUEUE
Feq                   LONG
OldColor              LONG
                    END

  CODE
? DEBUGHOOK(InvoiceDetail:Record)
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
  SELF.FirstField = ?InvDet:LineNumber:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(InvDet:Record,History::InvDet:Record)
  SELF.AddHistoryField(?InvDet:LineNumber,4)
  SELF.AddHistoryField(?InvDet:Quantity,5)
  SELF.AddHistoryField(?InvDet:Price,6)
  SELF.AddHistoryField(?InvDet:TaxRate,7)
  SELF.AddHistoryField(?InvDet:TaxPaid,8)
  SELF.AddHistoryField(?InvDet:DiscountRate,9)
  SELF.AddHistoryField(?InvDet:Discount,10)
  SELF.AddHistoryField(?InvDet:Total,11)
  SELF.AddHistoryField(?InvDet:Note,12)
  SELF.AddHistoryField(?InvDet:GUID,1)
  SELF.AddHistoryField(?InvDet:InvoiceGuid,2)
  SELF.AddHistoryField(?InvDet:ProductGuid,3)
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
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?InvDet:Price{PROP:ReadOnly} = True
    ?InvDet:TaxRate{PROP:ReadOnly} = True
    ?InvDet:TaxPaid{PROP:ReadOnly} = True
    ?InvDet:DiscountRate{PROP:ReadOnly} = True
    ?InvDet:Discount{PROP:ReadOnly} = True
    ?InvDet:GUID{PROP:ReadOnly} = True
    ?InvDet:InvoiceGuid{PROP:ReadOnly} = True
    ?InvDet:ProductGuid{PROP:ReadOnly} = True
  END
  INIMgr.Fetch('UpdateInvoiceDetail',QuickWindow)          ! Restore window settings from non-volatile store
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
    OF ?InvDet:LineNumber
      IF Access:InvoiceDetail.TryValidateField(4)          ! Attempt to validate InvDet:LineNumber in InvoiceDetail
        SELECT(?InvDet:LineNumber)
        QuickWindow{PROP:AcceptAll} = False
        CYCLE
      ELSE
        FieldColorQueue.Feq = ?InvDet:LineNumber
        GET(FieldColorQueue, FieldColorQueue.Feq)
        IF ERRORCODE() = 0
          ?InvDet:LineNumber{PROP:FontColor} = FieldColorQueue.OldColor
          DELETE(FieldColorQueue)
        END
      END
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

!!! <summary>
!!! Generated from procedure template - Window
!!! Select a Customer Record
!!! </summary>
SelectCustomer PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(Customer)
                       PROJECT(Cus:CompanyGuid)
                       PROJECT(Cus:FirstName)
                       PROJECT(Cus:LastName)
                       PROJECT(Cus:Street)
                       PROJECT(Cus:City)
                       PROJECT(Cus:State)
                       PROJECT(Cus:PostalCode)
                       PROJECT(Cus:Phone)
                       PROJECT(Cus:MobilePhone)
                       PROJECT(Cus:GUID)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Cus:CompanyGuid        LIKE(Cus:CompanyGuid)          !List box control field - type derived from field
Cus:FirstName          LIKE(Cus:FirstName)            !List box control field - type derived from field
Cus:LastName           LIKE(Cus:LastName)             !List box control field - type derived from field
Cus:Street             LIKE(Cus:Street)               !List box control field - type derived from field
Cus:City               LIKE(Cus:City)                 !List box control field - type derived from field
Cus:State              LIKE(Cus:State)                !List box control field - type derived from field
Cus:PostalCode         LIKE(Cus:PostalCode)           !List box control field - type derived from field
Cus:Phone              LIKE(Cus:Phone)                !List box control field - type derived from field
Cus:MobilePhone        LIKE(Cus:MobilePhone)          !List box control field - type derived from field
Cus:GUID               LIKE(Cus:GUID)                 !Primary key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Select a Customer Record'),AT(,,358,198),FONT('Segoe UI',9,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('SelectCustomer'),SYSTEM
                       LIST,AT(8,23,342,148),USE(?Browse:1),HVSCROLL,FORMAT('40L(2)|M~Co. Guid~@s16@80L(2)|M~F' & |
  'irst Name~@s100@80L(2)|M~Last Name~@s100@80L(2)|M~Street~@s255@80L(2)|M~City~@s100@8' & |
  '0L(2)|M~State~@s100@80L(2)|M~Postal Code~@s100@80L(2)|M~Phone#~@s100@80L(2)|M~Phone#~@s100@'), |
  FROM(Queue:Browse:1),IMM,MSG('Browsing the Customer file')
                       BUTTON('&Select'),AT(4,180,49,14),USE(?Select:2),LEFT,ICON('WASELECT.ICO'),FLAT,MSG('Select the Record'), |
  TIP('Select the Record')
                       SHEET,AT(4,4,350,172),USE(?CurrentTab)
                         TAB('&GuidKey'),USE(?Tab:2)
                         END
                         TAB('&CompanyKey'),USE(?Tab:3)
                         END
                         TAB('&LastFirstNameKey'),USE(?Tab:4)
                         END
                         TAB('&FirstLastNameKey_Copy'),USE(?Tab:5)
                         END
                         TAB('&PostalCodeKey'),USE(?Tab:6)
                         END
                         TAB('&StateKey'),USE(?Tab:7)
                         END
                       END
                       BUTTON('&Close'),AT(305,180,49,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort1:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 2
BRW1::Sort2:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 3
BRW1::Sort3:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 4
BRW1::Sort4:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 5
BRW1::Sort5:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 6
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
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

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('SelectCustomer')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse:1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  BIND('Cus:FirstName',Cus:FirstName)                      ! Added by: BrowseBox(ABC)
  BIND('Cus:LastName',Cus:LastName)                        ! Added by: BrowseBox(ABC)
  BIND('Cus:Street',Cus:Street)                            ! Added by: BrowseBox(ABC)
  BIND('Cus:State',Cus:State)                              ! Added by: BrowseBox(ABC)
  BIND('Cus:PostalCode',Cus:PostalCode)                    ! Added by: BrowseBox(ABC)
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  Relate:Customer.Open()                                   ! File Customer used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Customer,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,Cus:CompanyKey)                       ! Add the sort order for Cus:CompanyKey for sort order 1
  BRW1.AddLocator(BRW1::Sort1:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort1:Locator.Init(,Cus:CompanyGuid,1,BRW1)        ! Initialize the browse locator using  using key: Cus:CompanyKey , Cus:CompanyGuid
  BRW1.AddSortOrder(,Cus:LastFirstNameKey)                 ! Add the sort order for Cus:LastFirstNameKey for sort order 2
  BRW1.AddLocator(BRW1::Sort2:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort2:Locator.Init(,Cus:LastName,1,BRW1)           ! Initialize the browse locator using  using key: Cus:LastFirstNameKey , Cus:LastName
  BRW1.AddSortOrder(,Cus:FirstLastNameKey_Copy)            ! Add the sort order for Cus:FirstLastNameKey_Copy for sort order 3
  BRW1.AddLocator(BRW1::Sort3:Locator)                     ! Browse has a locator for sort order 3
  BRW1::Sort3:Locator.Init(,Cus:FirstName,1,BRW1)          ! Initialize the browse locator using  using key: Cus:FirstLastNameKey_Copy , Cus:FirstName
  BRW1.AddSortOrder(,Cus:PostalCodeKey)                    ! Add the sort order for Cus:PostalCodeKey for sort order 4
  BRW1.AddLocator(BRW1::Sort4:Locator)                     ! Browse has a locator for sort order 4
  BRW1::Sort4:Locator.Init(,Cus:PostalCode,1,BRW1)         ! Initialize the browse locator using  using key: Cus:PostalCodeKey , Cus:PostalCode
  BRW1.AddSortOrder(,Cus:StateKey)                         ! Add the sort order for Cus:StateKey for sort order 5
  BRW1.AddLocator(BRW1::Sort5:Locator)                     ! Browse has a locator for sort order 5
  BRW1::Sort5:Locator.Init(,Cus:State,1,BRW1)              ! Initialize the browse locator using  using key: Cus:StateKey , Cus:State
  BRW1.AddSortOrder(,Cus:GuidKey)                          ! Add the sort order for Cus:GuidKey for sort order 6
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 6
  BRW1::Sort0:Locator.Init(,Cus:GUID,1,BRW1)               ! Initialize the browse locator using  using key: Cus:GuidKey , Cus:GUID
  BRW1.AddField(Cus:CompanyGuid,BRW1.Q.Cus:CompanyGuid)    ! Field Cus:CompanyGuid is a hot field or requires assignment from browse
  BRW1.AddField(Cus:FirstName,BRW1.Q.Cus:FirstName)        ! Field Cus:FirstName is a hot field or requires assignment from browse
  BRW1.AddField(Cus:LastName,BRW1.Q.Cus:LastName)          ! Field Cus:LastName is a hot field or requires assignment from browse
  BRW1.AddField(Cus:Street,BRW1.Q.Cus:Street)              ! Field Cus:Street is a hot field or requires assignment from browse
  BRW1.AddField(Cus:City,BRW1.Q.Cus:City)                  ! Field Cus:City is a hot field or requires assignment from browse
  BRW1.AddField(Cus:State,BRW1.Q.Cus:State)                ! Field Cus:State is a hot field or requires assignment from browse
  BRW1.AddField(Cus:PostalCode,BRW1.Q.Cus:PostalCode)      ! Field Cus:PostalCode is a hot field or requires assignment from browse
  BRW1.AddField(Cus:Phone,BRW1.Q.Cus:Phone)                ! Field Cus:Phone is a hot field or requires assignment from browse
  BRW1.AddField(Cus:MobilePhone,BRW1.Q.Cus:MobilePhone)    ! Field Cus:MobilePhone is a hot field or requires assignment from browse
  BRW1.AddField(Cus:GUID,BRW1.Q.Cus:GUID)                  ! Field Cus:GUID is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('SelectCustomer',QuickWindow)               ! Restore window settings from non-volatile store
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
    INIMgr.Update('SelectCustomer',QuickWindow)            ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  SELF.SelectControl = ?Select:2
  SELF.HideSelect = 1                                      ! Hide the select button when disabled
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)


BRW1.ResetSort PROCEDURE(BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  IF CHOICE(?CurrentTab) = 2
    RETURN SELF.SetSort(1,Force)
  ELSIF CHOICE(?CurrentTab) = 3
    RETURN SELF.SetSort(2,Force)
  ELSIF CHOICE(?CurrentTab) = 4
    RETURN SELF.SetSort(3,Force)
  ELSIF CHOICE(?CurrentTab) = 5
    RETURN SELF.SetSort(4,Force)
  ELSIF CHOICE(?CurrentTab) = 6
    RETURN SELF.SetSort(5,Force)
  ELSE
    RETURN SELF.SetSort(6,Force)
  END
  ReturnValue = PARENT.ResetSort(Force)
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Window
!!! Form Invoice
!!! </summary>
UpdateInvoice PROCEDURE 

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::Inv:Record  LIKE(Inv:RECORD),THREAD
QuickWindow          WINDOW('Form Invoice'),AT(,,359,251),FONT('Segoe UI',9,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('UpdateInvoice'),SYSTEM
                       PROMPT('Invoice Number:'),AT(8,7),USE(?Inv:InvoiceNumber:Prompt),TRN
                       ENTRY(@n07),AT(72,7,40,10),USE(Inv:InvoiceNumber),MSG('Invoice number for each order')
                       PROMPT('Date:'),AT(8,21),USE(?Inv:Date:Prompt),TRN
                       ENTRY(@d10),AT(72,21,104,10),USE(Inv:Date),REQ
                       CHECK('Order Shipped'),AT(72,35,70,8),USE(Inv:OrderShipped),MSG('Checked if order is shipped')
                       PROMPT('&First Name:'),AT(8,47),USE(?Inv:FirstName:Prompt),TRN
                       ENTRY(@s100),AT(72,47,278,10),USE(Inv:FirstName),MSG('Enter the first name of customer'),REQ
                       PROMPT('&Last Name:'),AT(8,61),USE(?Inv:LastName:Prompt),TRN
                       ENTRY(@s100),AT(72,61,278,10),USE(Inv:LastName),MSG('Enter the last name of customer'),REQ
                       PROMPT('&Street:'),AT(8,75),USE(?Inv:Street:Prompt),TRN
                       TEXT,AT(72,75,278,30),USE(Inv:Street),MSG('Enter the first line address of customer')
                       PROMPT('&City:'),AT(8,109),USE(?Inv:City:Prompt),TRN
                       ENTRY(@s100),AT(72,109,278,10),USE(Inv:City),MSG('Enter  city of customer')
                       PROMPT('&State:'),AT(8,123),USE(?Inv:State:Prompt),TRN
                       ENTRY(@s100),AT(72,123,278,10),USE(Inv:State),MSG('Enter state of customer')
                       PROMPT('&Zip Code:'),AT(8,137),USE(?Inv:PostalCode:Prompt),TRN
                       ENTRY(@s100),AT(72,137,278,10),USE(Inv:PostalCode),MSG('Enter zipcode of customer'),TIP('Enter zipc' & |
  'ode of customer')
                       PROMPT('Mobile Phone:'),AT(8,151),USE(?Inv:Phone:Prompt),TRN
                       ENTRY(@s100),AT(72,151,278,10),USE(Inv:Phone)
                       PROMPT('Total (calulated):'),AT(8,166),USE(?Inv:Total:Prompt),TRN
                       ENTRY(@n-15.2),AT(72,166,68,10),USE(Inv:Total),SKIP
                       PROMPT('Note:'),AT(8,180),USE(?Inv:Note:Prompt),TRN
                       TEXT,AT(72,180,278,30),USE(Inv:Note)
                       BUTTON('&OK'),AT(129,224,49,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,MSG('Accept dat' & |
  'a and close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(181,224,49,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel operation'), |
  TIP('Cancel operation')
                       PROMPT('Invoice GUID:'),AT(225,5),USE(?Inv:GUID:Prompt),TRN
                       ENTRY(@s16),AT(271,5,60,10),USE(Inv:GUID),SKIP
                       PROMPT('Customer GUID:'),AT(217,19),USE(?Inv:CustomerGuid:Prompt),TRN
                       ENTRY(@s16),AT(271,19,60,10),USE(Inv:CustomerGuid),SKIP
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
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
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
  SELF.AddHistoryField(?Inv:GUID,1)
  SELF.AddHistoryField(?Inv:CustomerGuid,2)
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
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?Inv:InvoiceNumber{PROP:ReadOnly} = True
    ?Inv:Date{PROP:ReadOnly} = True
    ?Inv:FirstName{PROP:ReadOnly} = True
    ?Inv:LastName{PROP:ReadOnly} = True
    ?Inv:City{PROP:ReadOnly} = True
    ?Inv:State{PROP:ReadOnly} = True
    ?Inv:PostalCode{PROP:ReadOnly} = True
    ?Inv:Phone{PROP:ReadOnly} = True
    ?Inv:GUID{PROP:ReadOnly} = True
    ?Inv:CustomerGuid{PROP:ReadOnly} = True
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

!!! <summary>
!!! Generated from procedure template - Window
!!! Select a CustomerCompany Record
!!! </summary>
SelectCustomerCompany PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(CustomerCompany)
                       PROJECT(CusCom:CompanyName)
                       PROJECT(CusCom:Street)
                       PROJECT(CusCom:City)
                       PROJECT(CusCom:State)
                       PROJECT(CusCom:PostalCode)
                       PROJECT(CusCom:Phone)
                       PROJECT(CusCom:GUID)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
CusCom:CompanyName     LIKE(CusCom:CompanyName)       !List box control field - type derived from field
CusCom:Street          LIKE(CusCom:Street)            !List box control field - type derived from field
CusCom:City            LIKE(CusCom:City)              !List box control field - type derived from field
CusCom:State           LIKE(CusCom:State)             !List box control field - type derived from field
CusCom:PostalCode      LIKE(CusCom:PostalCode)        !List box control field - type derived from field
CusCom:Phone           LIKE(CusCom:Phone)             !List box control field - type derived from field
CusCom:GUID            LIKE(CusCom:GUID)              !Primary key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Select a CustomerCompany Record'),AT(,,358,198),FONT('Segoe UI',9,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('SelectCustomerCompany'),SYSTEM
                       LIST,AT(8,30,342,124),USE(?Browse:1),HVSCROLL,FORMAT('80L(2)|M~Company Name~L(2)@s100@8' & |
  '0L(2)|M~Street~L(2)@s255@80L(2)|M~City~L(2)@s100@80L(2)|M~State~L(2)@s100@80L(2)|M~P' & |
  'ostal Code~L(2)@s100@80L(2)|M~Phone#~L(2)@s100@'),FROM(Queue:Browse:1),IMM,MSG('Browsing t' & |
  'he CustomerCompany file')
                       BUTTON('&Select'),AT(301,158,49,14),USE(?Select:2),LEFT,ICON('WASELECT.ICO'),FLAT,MSG('Select the Record'), |
  TIP('Select the Record')
                       SHEET,AT(4,4,350,172),USE(?CurrentTab)
                         TAB('&GuidKey'),USE(?Tab:2)
                         END
                         TAB('&CompanyNameKey'),USE(?Tab:3)
                         END
                       END
                       BUTTON('&Close'),AT(305,180,49,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort1:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 2
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END


  CODE
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
  GlobalErrors.SetProcedureName('SelectCustomerCompany')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse:1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  BIND('CusCom:CompanyName',CusCom:CompanyName)            ! Added by: BrowseBox(ABC)
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  Relate:CustomerCompany.Open()                            ! File CustomerCompany used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:CustomerCompany,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,CusCom:CompanyNameKey)                ! Add the sort order for CusCom:CompanyNameKey for sort order 1
  BRW1.AddLocator(BRW1::Sort1:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort1:Locator.Init(,CusCom:CompanyName,1,BRW1)     ! Initialize the browse locator using  using key: CusCom:CompanyNameKey , CusCom:CompanyName
  BRW1.AddSortOrder(,CusCom:GuidKey)                       ! Add the sort order for CusCom:GuidKey for sort order 2
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort0:Locator.Init(,CusCom:GUID,1,BRW1)            ! Initialize the browse locator using  using key: CusCom:GuidKey , CusCom:GUID
  BRW1.AddField(CusCom:CompanyName,BRW1.Q.CusCom:CompanyName) ! Field CusCom:CompanyName is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:Street,BRW1.Q.CusCom:Street)        ! Field CusCom:Street is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:City,BRW1.Q.CusCom:City)            ! Field CusCom:City is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:State,BRW1.Q.CusCom:State)          ! Field CusCom:State is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:PostalCode,BRW1.Q.CusCom:PostalCode) ! Field CusCom:PostalCode is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:Phone,BRW1.Q.CusCom:Phone)          ! Field CusCom:Phone is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:GUID,BRW1.Q.CusCom:GUID)            ! Field CusCom:GUID is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('SelectCustomerCompany',QuickWindow)        ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:CustomerCompany.Close()
  END
  IF SELF.Opened
    INIMgr.Update('SelectCustomerCompany',QuickWindow)     ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  SELF.SelectControl = ?Select:2
  SELF.HideSelect = 1                                      ! Hide the select button when disabled
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)


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
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Window
!!! Form Customer
!!! </summary>
UpdateCustomer PROCEDURE 

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::Cus:Record  LIKE(Cus:RECORD),THREAD
QuickWindow          WINDOW('Form Customer'),AT(,,361,225),FONT('Segoe UI',9,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('UpdateCustomer'),SYSTEM
                       PROMPT('GUID:'),AT(8,7),USE(?Cus:Guid:Prompt),TRN
                       ENTRY(@s16),AT(64,7,80,10),USE(Cus:GUID),SKIP
                       PROMPT('Co Number:'),AT(8,21),USE(?Cus:GuidKey:Prompt:2),TRN
                       ENTRY(@n-11),AT(64,21,80,10),USE(Cus:CustomerNumber),SKIP
                       PROMPT('Company Guid:'),AT(8,35),USE(?Cus:CompanyGuid:Prompt),TRN
                       ENTRY(@s16),AT(64,35,80,10),USE(Cus:CompanyGuid),MSG('Enter the customer''s company'),SKIP
                       PROMPT('&First Name:'),AT(8,48),USE(?Cus:FirstName:Prompt),TRN
                       ENTRY(@s100),AT(64,48,286,10),USE(Cus:FirstName),MSG('Enter the first name of customer'),REQ
                       PROMPT('&Last Name:'),AT(8,62),USE(?Cus:LastName:Prompt),TRN
                       ENTRY(@s100),AT(64,62,286,10),USE(Cus:LastName),MSG('Enter the last name of customer'),REQ
                       PROMPT('&Street Address:'),AT(8,76),USE(?Cus:Street:Prompt),TRN
                       TEXT,AT(64,76,286,30),USE(Cus:Street),MSG('Enter the first line address of customer')
                       PROMPT('&City:'),AT(8,110),USE(?Cus:City:Prompt),TRN
                       ENTRY(@s100),AT(64,110,286,10),USE(Cus:City),MSG('Enter  city of customer')
                       PROMPT('&State:'),AT(8,124),USE(?Cus:State:Prompt),TRN
                       ENTRY(@s100),AT(64,123,286,10),USE(Cus:State),MSG('Enter state of customer')
                       PROMPT('&Zip Code:'),AT(8,137),USE(?Cus:PostalCode:Prompt),TRN
                       ENTRY(@s100),AT(64,137,286,10),USE(Cus:PostalCode),MSG('Enter zipcode of customer'),TIP('Enter zipc' & |
  'ode of customer')
                       PROMPT('Mobile Phone:'),AT(8,150),USE(?Cus:Phone:Prompt),TRN
                       ENTRY(@s100),AT(64,150,286,10),USE(Cus:Phone)
                       PROMPT('Mobile Phone:'),AT(8,164),USE(?Cus:MobilePhone:Prompt),TRN
                       ENTRY(@s100),AT(64,163,286,10),USE(Cus:MobilePhone)
                       PROMPT('Email:'),AT(8,177),USE(?Cus:Email:Prompt),TRN
                       ENTRY(@s100),AT(64,177,286,10),USE(Cus:Email)
                       BUTTON('&OK'),AT(125,199,49,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,MSG('Accept dat' & |
  'a and close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(186,199,49,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel operation'), |
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
  SELF.FirstField = ?Cus:Guid:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(Cus:Record,History::Cus:Record)
  SELF.AddHistoryField(?Cus:GUID,1)
  SELF.AddHistoryField(?Cus:CustomerNumber,2)
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
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?Cus:GUID{PROP:ReadOnly} = True
    ?Cus:CustomerNumber{PROP:ReadOnly} = True
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

!!! <summary>
!!! Generated from procedure template - Window
!!! Form Configuration
!!! </summary>
UpdateConfiguration PROCEDURE 

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::Cfg:Record  LIKE(Cfg:RECORD),THREAD
QuickWindow          WINDOW('Form Configuration'),AT(,,358,146),FONT('Segoe UI',9,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('UpdateConfiguration'),SYSTEM
                       PROMPT('Company Name:'),AT(8,20),USE(?Cfg:CompanyName:Prompt),TRN
                       ENTRY(@s100),AT(64,20,286,10),USE(Cfg:CompanyName)
                       PROMPT('&Street:'),AT(8,34),USE(?Cfg:Street:Prompt),TRN
                       TEXT,AT(64,34,286,30),USE(Cfg:Street),MSG('Enter the first line address of customer')
                       PROMPT('&City:'),AT(8,68),USE(?Cfg:City:Prompt),TRN
                       ENTRY(@s100),AT(64,68,286,10),USE(Cfg:City),MSG('Enter  city of customer')
                       PROMPT('&State:'),AT(8,82),USE(?Cfg:State:Prompt),TRN
                       ENTRY(@s100),AT(64,82,286,10),USE(Cfg:State),MSG('Enter state of customer')
                       PROMPT('&Zip Code:'),AT(8,96),USE(?Cfg:PostalCode:Prompt),TRN
                       ENTRY(@s100),AT(64,96,286,10),USE(Cfg:PostalCode),MSG('Enter zipcode of customer'),TIP('Enter zipc' & |
  'ode of customer')
                       PROMPT('Mobile Phone:'),AT(8,110),USE(?Cfg:Phone:Prompt),TRN
                       ENTRY(@s100),AT(64,110,286,10),USE(Cfg:Phone)
                       BUTTON('&OK'),AT(252,128,49,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,MSG('Accept dat' & |
  'a and close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(305,128,49,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel operation'), |
  TIP('Cancel operation')
                       PROMPT('GUID:'),AT(8,6),USE(?Cfg:GUID:Prompt),TRN
                       ENTRY(@s16),AT(64,6,60,10),USE(Cfg:GUID),SKIP
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
? DEBUGHOOK(Configuration:Record)
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
  GlobalErrors.SetProcedureName('UpdateConfiguration')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Cfg:CompanyName:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(Cfg:Record,History::Cfg:Record)
  SELF.AddHistoryField(?Cfg:CompanyName,2)
  SELF.AddHistoryField(?Cfg:Street,3)
  SELF.AddHistoryField(?Cfg:City,4)
  SELF.AddHistoryField(?Cfg:State,5)
  SELF.AddHistoryField(?Cfg:PostalCode,6)
  SELF.AddHistoryField(?Cfg:Phone,7)
  SELF.AddHistoryField(?Cfg:GUID,1)
  SELF.AddUpdateFile(Access:Configuration)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:Configuration.Open()                              ! File Configuration used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:Configuration
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
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?Cfg:CompanyName{PROP:ReadOnly} = True
    ?Cfg:City{PROP:ReadOnly} = True
    ?Cfg:State{PROP:ReadOnly} = True
    ?Cfg:PostalCode{PROP:ReadOnly} = True
    ?Cfg:Phone{PROP:ReadOnly} = True
    ?Cfg:GUID{PROP:ReadOnly} = True
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateConfiguration',QuickWindow)          ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Configuration.Close()
  END
  IF SELF.Opened
    INIMgr.Update('UpdateConfiguration',QuickWindow)       ! Save window data to non-volatile store
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
!!! Select a Invoice Record
!!! </summary>
SelectInvoice PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(Invoice)
                       PROJECT(Inv:InvoiceNumber)
                       PROJECT(Inv:Date)
                       PROJECT(Inv:OrderShipped)
                       PROJECT(Inv:FirstName)
                       PROJECT(Inv:LastName)
                       PROJECT(Inv:Street)
                       PROJECT(Inv:City)
                       PROJECT(Inv:State)
                       PROJECT(Inv:GUID)
                       PROJECT(Inv:CustomerGuid)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Inv:InvoiceNumber      LIKE(Inv:InvoiceNumber)        !List box control field - type derived from field
Inv:Date               LIKE(Inv:Date)                 !List box control field - type derived from field
Inv:OrderShipped       LIKE(Inv:OrderShipped)         !List box control field - type derived from field
Inv:FirstName          LIKE(Inv:FirstName)            !List box control field - type derived from field
Inv:LastName           LIKE(Inv:LastName)             !List box control field - type derived from field
Inv:Street             LIKE(Inv:Street)               !List box control field - type derived from field
Inv:City               LIKE(Inv:City)                 !List box control field - type derived from field
Inv:State              LIKE(Inv:State)                !List box control field - type derived from field
Inv:GUID               LIKE(Inv:GUID)                 !List box control field - type derived from field
Inv:CustomerGuid       LIKE(Inv:CustomerGuid)         !Browse key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Select a Invoice Record'),AT(,,358,198),FONT('Segoe UI',9,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('SelectInvoice'),SYSTEM
                       LIST,AT(8,21,342,149),USE(?Browse:1),HVSCROLL,FORMAT('40R(2)|M~Invoice #~C(0)@n07@44R(2' & |
  ')|M~Date~C(0)@d10@32L(2)|M~Shipped~@s1@44L(2)|M~First Name~@s100@44L(2)|M~Last Name~' & |
  '@s100@80L(2)|M~Street~@s255@80L(2)|M~City~@s100@20L(2)|M~State~@s100@64L(2)|M~GUID~L' & |
  '(0)S(2)@s16@'),FROM(Queue:Browse:1),IMM,MSG('Browsing the Invoice file')
                       BUTTON('&Select'),AT(4,180,49,14),USE(?Select:2),LEFT,ICON('WASELECT.ICO'),FLAT,MSG('Select the Record'), |
  TIP('Select the Record')
                       SHEET,AT(4,4,350,172),USE(?CurrentTab)
                         TAB('&GuidKey'),USE(?Tab:2)
                         END
                         TAB('&CustomerKey'),USE(?Tab:3)
                         END
                         TAB('&DateKey'),USE(?Tab:4)
                         END
                       END
                       BUTTON('&Close'),AT(305,180,49,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort1:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 2
BRW1::Sort2:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 3
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
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

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('SelectInvoice')
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
  Relate:Invoice.SetOpenRelated()
  Relate:Invoice.Open()                                    ! File Invoice used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Invoice,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,Inv:CustomerKey)                      ! Add the sort order for Inv:CustomerKey for sort order 1
  BRW1.AddLocator(BRW1::Sort1:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort1:Locator.Init(,Inv:CustomerGuid,1,BRW1)       ! Initialize the browse locator using  using key: Inv:CustomerKey , Inv:CustomerGuid
  BRW1.AddSortOrder(,Inv:DateKey)                          ! Add the sort order for Inv:DateKey for sort order 2
  BRW1.AddLocator(BRW1::Sort2:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort2:Locator.Init(,Inv:Date,1,BRW1)               ! Initialize the browse locator using  using key: Inv:DateKey , Inv:Date
  BRW1.AddSortOrder(,Inv:GuidKey)                          ! Add the sort order for Inv:GuidKey for sort order 3
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 3
  BRW1::Sort0:Locator.Init(,Inv:GUID,1,BRW1)               ! Initialize the browse locator using  using key: Inv:GuidKey , Inv:GUID
  BRW1.AddField(Inv:InvoiceNumber,BRW1.Q.Inv:InvoiceNumber) ! Field Inv:InvoiceNumber is a hot field or requires assignment from browse
  BRW1.AddField(Inv:Date,BRW1.Q.Inv:Date)                  ! Field Inv:Date is a hot field or requires assignment from browse
  BRW1.AddField(Inv:OrderShipped,BRW1.Q.Inv:OrderShipped)  ! Field Inv:OrderShipped is a hot field or requires assignment from browse
  BRW1.AddField(Inv:FirstName,BRW1.Q.Inv:FirstName)        ! Field Inv:FirstName is a hot field or requires assignment from browse
  BRW1.AddField(Inv:LastName,BRW1.Q.Inv:LastName)          ! Field Inv:LastName is a hot field or requires assignment from browse
  BRW1.AddField(Inv:Street,BRW1.Q.Inv:Street)              ! Field Inv:Street is a hot field or requires assignment from browse
  BRW1.AddField(Inv:City,BRW1.Q.Inv:City)                  ! Field Inv:City is a hot field or requires assignment from browse
  BRW1.AddField(Inv:State,BRW1.Q.Inv:State)                ! Field Inv:State is a hot field or requires assignment from browse
  BRW1.AddField(Inv:GUID,BRW1.Q.Inv:GUID)                  ! Field Inv:GUID is a hot field or requires assignment from browse
  BRW1.AddField(Inv:CustomerGuid,BRW1.Q.Inv:CustomerGuid)  ! Field Inv:CustomerGuid is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('SelectInvoice',QuickWindow)                ! Restore window settings from non-volatile store
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
    INIMgr.Update('SelectInvoice',QuickWindow)             ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  SELF.SelectControl = ?Select:2
  SELF.HideSelect = 1                                      ! Hide the select button when disabled
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)


BRW1.ResetSort PROCEDURE(BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  IF CHOICE(?CurrentTab) = 2
    RETURN SELF.SetSort(1,Force)
  ELSIF CHOICE(?CurrentTab) = 3
    RETURN SELF.SetSort(2,Force)
  ELSE
    RETURN SELF.SetSort(3,Force)
  END
  ReturnValue = PARENT.ResetSort(Force)
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Window
!!! Form CustomerCompany
!!! </summary>
UpdateCustomerCompany PROCEDURE 

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::CusCom:Record LIKE(CusCom:RECORD),THREAD
QuickWindow          WINDOW('Form CustomerCompany'),AT(,,358,167),FONT('Segoe UI',9,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('UpdateCustomerCompany'),SYSTEM
                       SHEET,AT(4,4,350,137),USE(?CurrentTab)
                         TAB('&General'),USE(?Tab:1)
                           PROMPT('Company Name:'),AT(8,34),USE(?CusCom:CompanyName:Prompt),TRN
                           ENTRY(@s100),AT(64,34,286,10),USE(CusCom:CompanyName)
                           PROMPT('&Street:'),AT(8,48),USE(?CusCom:Street:Prompt),TRN
                           TEXT,AT(64,48,286,30),USE(CusCom:Street),MSG('Enter the first line address of customer')
                           PROMPT('&City:'),AT(8,82),USE(?CusCom:City:Prompt),TRN
                           ENTRY(@s100),AT(64,82,286,10),USE(CusCom:City),MSG('Enter  city of customer')
                           PROMPT('&State:'),AT(8,96),USE(?CusCom:State:Prompt),TRN
                           ENTRY(@s100),AT(64,96,286,10),USE(CusCom:State),MSG('Enter state of customer')
                           PROMPT('&Zip Code:'),AT(8,110),USE(?CusCom:PostalCode:Prompt),TRN
                           ENTRY(@s100),AT(64,110,286,10),USE(CusCom:PostalCode),MSG('Enter zipcode of customer'),TIP('Enter zipc' & |
  'ode of customer')
                           PROMPT('Mobile Phone:'),AT(8,124),USE(?CusCom:Phone:Prompt),TRN
                           ENTRY(@s100),AT(64,124,286,10),USE(CusCom:Phone)
                           PROMPT('GUID:'),AT(9,22),USE(?CusCom:GUID:Prompt),TRN
                           ENTRY(@s16),AT(64,21,78,10),USE(CusCom:GUID),SKIP
                         END
                       END
                       BUTTON('&OK'),AT(247,147,49,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,MSG('Accept dat' & |
  'a and close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(300,147,49,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel operation'), |
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
? DEBUGHOOK(CustomerCompany:Record)
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
  GlobalErrors.SetProcedureName('UpdateCustomerCompany')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?CusCom:CompanyName:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.HistoryKey = CtrlH
  SELF.AddHistoryFile(CusCom:Record,History::CusCom:Record)
  SELF.AddHistoryField(?CusCom:CompanyName,2)
  SELF.AddHistoryField(?CusCom:Street,3)
  SELF.AddHistoryField(?CusCom:City,4)
  SELF.AddHistoryField(?CusCom:State,5)
  SELF.AddHistoryField(?CusCom:PostalCode,6)
  SELF.AddHistoryField(?CusCom:Phone,7)
  SELF.AddHistoryField(?CusCom:GUID,1)
  SELF.AddUpdateFile(Access:CustomerCompany)
  SELF.AddItem(?Cancel,RequestCancelled)                   ! Add the cancel control to the window manager
  Relate:CustomerCompany.Open()                            ! File CustomerCompany used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Primary &= Relate:CustomerCompany
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
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?CusCom:CompanyName{PROP:ReadOnly} = True
    ?CusCom:City{PROP:ReadOnly} = True
    ?CusCom:State{PROP:ReadOnly} = True
    ?CusCom:PostalCode{PROP:ReadOnly} = True
    ?CusCom:Phone{PROP:ReadOnly} = True
    ?CusCom:GUID{PROP:ReadOnly} = True
  END
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('UpdateCustomerCompany',QuickWindow)        ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:CustomerCompany.Close()
  END
  IF SELF.Opened
    INIMgr.Update('UpdateCustomerCompany',QuickWindow)     ! Save window data to non-volatile store
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
          Message('DUPLICATE(CustomerCompany)=' & DUPLICATE(CustomerCompany) & |
                  '|DUPLICATE(CusCom:CompanyNameKey)=' & DUPLICATE(CusCom:CompanyNameKey) & |
                  '|DUPLICATE(CusCom:GuidKey)=' & DUPLICATE(CusCom:GuidKey) ,'Dup?') 
          
          IF DUPLICATE(CusCom:CompanyNameKey) THEN
             SELECT(?CusCom:CompanyName)
             Message('Name must be unique','error')
             CYCLE
          END
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
!!! Form Product
!!! </summary>
UpdateProduct PROCEDURE 

CurrentTab           STRING(80)                            ! 
ActionMessage        CSTRING(40)                           ! 
History::Pro:Record  LIKE(Pro:RECORD),THREAD
QuickWindow          WINDOW('Form Product'),AT(,,341,168),FONT('Segoe UI',9,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,GRAY,IMM,MDI,HLP('UpdateProduct'),SYSTEM
                       PROMPT('Product Code:'),AT(8,20),USE(?Pro:ProductCode:Prompt),TRN
                       ENTRY(@s100),AT(65,20,266,10),USE(Pro:ProductCode),MSG('User defined Product Number'),REQ
                       PROMPT('Product Name:'),AT(8,34),USE(?Pro:ProductName:Prompt),TRN
                       ENTRY(@s100),AT(65,34,266,10),USE(Pro:ProductName),REQ
                       PROMPT('Description:'),AT(8,48),USE(?Pro:Description:Prompt),TRN
                       TEXT,AT(65,48,266,30),USE(Pro:Description),MSG('Enter Product''s Description'),REQ
                       PROMPT('Price:'),AT(39,90),USE(?Pro:Price:Prompt),TRN
                       ENTRY(@n-15.2),AT(65,89,68,10),USE(Pro:Price),RIGHT,MSG('Enter Product''s Price')
                       PROMPT('Quantity In Stock:'),AT(159,89),USE(?Pro:QuantityInStock:Prompt),TRN
                       ENTRY(@n-14),AT(219,89,68,10),USE(Pro:QuantityInStock),RIGHT(1),MSG('Enter quantity of ' & |
  'product in stock')
                       PROMPT('Reorder Quantity:'),AT(159,106),USE(?Pro:ReorderQuantity:Prompt),TRN
                       ENTRY(@n13),AT(219,105,68,10),USE(Pro:ReorderQuantity),RIGHT(1),MSG('Enter product''s q' & |
  'uantity for re-order')
                       PROMPT('Cost:'),AT(39,106),USE(?Pro:Cost:Prompt),TRN
                       ENTRY(@n-15.2),AT(65,105,68,10),USE(Pro:Cost),RIGHT,MSG('Enter product''s cost')
                       PROMPT('Image Filename:'),AT(8,127),USE(?Pro:ImageFilename:Prompt),TRN
                       ENTRY(@s255),AT(65,127,266,10),USE(Pro:ImageFilename)
                       BUTTON('&OK'),AT(227,145,49,14),USE(?OK),LEFT,ICON('WAOK.ICO'),DEFAULT,FLAT,MSG('Accept dat' & |
  'a and close the window'),TIP('Accept data and close the window')
                       BUTTON('&Cancel'),AT(281,145,49,14),USE(?Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel operation'), |
  TIP('Cancel operation')
                       PROMPT('Product GUID:'),AT(9,7),USE(?Pro:GUID:Prompt),TRN
                       ENTRY(@s16),AT(65,6,86,10),USE(Pro:GUID),READONLY,SKIP
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
  SELF.AddHistoryField(?Pro:GUID,1)
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
  Do DefineListboxStyle
  IF SELF.Request = ViewRecord                             ! Configure controls for View Only mode
    ?Pro:ProductCode{PROP:ReadOnly} = True
    ?Pro:ProductName{PROP:ReadOnly} = True
    ?Pro:Price{PROP:ReadOnly} = True
    ?Pro:QuantityInStock{PROP:ReadOnly} = True
    ?Pro:ReorderQuantity{PROP:ReadOnly} = True
    ?Pro:Cost{PROP:ReadOnly} = True
    ?Pro:ImageFilename{PROP:ReadOnly} = True
    ?Pro:GUID{PROP:ReadOnly} = True
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

