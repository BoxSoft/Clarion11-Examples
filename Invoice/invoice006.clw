

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('BRWEXT.INC'),ONCE

!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the Invoice file (with select)
!!! </summary>
BrowseInvoice:Window PROCEDURE (<STRING pCustomerGuid>)

                              MAP
SetSelectedCustomer             PROCEDURE
ClearSelectedCustomer           PROCEDURE
                              END
CustomerGuid         STRING(16)                            ! 
CustomerName         STRING(255)                           ! 
BRW1::View:Browse    VIEW(Invoice)
                       PROJECT(Inv:InvoiceNumber)
                       PROJECT(Inv:Date)
                       PROJECT(Inv:OrderShipped)
                       PROJECT(Inv:FirstName)
                       PROJECT(Inv:LastName)
                       PROJECT(Inv:Street)
                       PROJECT(Inv:City)
                       PROJECT(Inv:State)
                       PROJECT(Inv:PostalCode)
                       PROJECT(Inv:GUID)
                       PROJECT(Inv:CustomerGuid)
                     END
InvoiceQueue         QUEUE                            !Queue declaration for browse/combo box using ?InvoiceList
Inv:InvoiceNumber      LIKE(Inv:InvoiceNumber)        !List box control field - type derived from field
Inv:Date               LIKE(Inv:Date)                 !List box control field - type derived from field
Inv:OrderShipped       LIKE(Inv:OrderShipped)         !List box control field - type derived from field
Inv:OrderShipped_Icon  LONG                           !Entry's icon ID
Inv:FirstName          LIKE(Inv:FirstName)            !List box control field - type derived from field
Inv:LastName           LIKE(Inv:LastName)             !List box control field - type derived from field
Inv:Street             LIKE(Inv:Street)               !List box control field - type derived from field
Inv:City               LIKE(Inv:City)                 !List box control field - type derived from field
Inv:State              LIKE(Inv:State)                !List box control field - type derived from field
Inv:PostalCode         LIKE(Inv:PostalCode)           !List box control field - type derived from field
Inv:GUID               LIKE(Inv:GUID)                 !Primary key field - type derived from field
Inv:CustomerGuid       LIKE(Inv:CustomerGuid)         !Browse key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the Invoice file'),AT(,,355,193),FONT('Segoe UI',10,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,ICON('INVOICE.ICO'),GRAY,IMM,MDI,HLP('BrowseInvoice'),SYSTEM
                       LIST,AT(8,20,342,135),USE(?InvoiceList),HVSCROLL,FORMAT('40R(2)|M~Invoice~C(0)@n07@50R(' & |
  '2)|M~Date~C(0)@d10@32L(2)|MJ~Shipped~@n3~Yes~b@80L(2)|M~First Name~@s100@80L(2)|M~La' & |
  'st Name~@s100@80L(2)|M~Street~@s255@80L(2)|M~City~@s100@80L(2)|M~State~@s100@80L(2)|' & |
  'M~Postal Code~@s100@'),FROM(InvoiceQueue),IMM,MSG('Browsing the Invoice file')
                       BUTTON('Insert'),AT(192,158,50,14),USE(?Insert)
                       BUTTON('Change'),AT(246,158,50,14),USE(?Change),DEFAULT
                       BUTTON('Delete'),AT(300,158,50,14),USE(?Delete)
                       BUTTON('Close'),AT(300,175,50,14),USE(?Close)
                       BUTTON,AT(7,7,10,10),USE(?BUTTON:SelectCustomer),ICON('Lookup.ico'),FLAT,TIP('Select cus' & |
  'tomer to filter invoices')
                       BUTTON,AT(21,7,10,10),USE(?BUTTON:SelectCustomer:2),ICON('Cancel16.ico'),FLAT,TIP('Clear cust' & |
  'omer filter')
                       STRING(@s255),AT(35,7),USE(CustomerName),FONT(,,,FONT:regular)
                     END

BRW1::LastSortOrder       BYTE
BRW1::SortHeader  CLASS(SortHeaderClassType) !Declare SortHeader Class
QueueResorted          PROCEDURE(STRING pString),VIRTUAL
                  END
BRW1::AutoSizeColumn CLASS(AutoSizeColumnClassType)
               END
ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
SetAlerts              PROCEDURE(),DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
InvoiceBrowse        CLASS(BrowseClass)                    ! Browse using ?InvoiceList
Q                      &InvoiceQueue                  !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
SetQueueRecord         PROCEDURE(),DERIVED
SetSort                PROCEDURE(BYTE NewOrder,BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END


  CODE
? DEBUGHOOK(Customer:Record)
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
  GlobalErrors.SetProcedureName('BrowseInvoice:Window')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?InvoiceList
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
  Relate:Customer.SetOpenRelated()
  Relate:Customer.Open()                                   ! File Customer used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  InvoiceBrowse.Init(?InvoiceList,InvoiceQueue.ViewPosition,BRW1::View:Browse,InvoiceQueue,Relate:Invoice,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  IF pCustomerGuid = ''
    ClearSelectedCustomer()
  ELSE
    Cus:GUID = pCustomerGuid
    IF Access:Customer.Fetch(Cus:GuidKey) = Level:Benign
      SetSelectedCustomer()
    ELSE
      ClearSelectedCustomer()
    END
  END
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?InvoiceList{PROP:LineHeight} = 11
  Do DefineListboxStyle
  InvoiceBrowse.Q &= InvoiceQueue
  InvoiceBrowse.RetainRow = 0
  InvoiceBrowse.AddSortOrder(,Inv:CustomerKey)             ! Add the sort order for Inv:CustomerKey for sort order 1
  InvoiceBrowse.AddRange(Inv:CustomerGuid,CustomerGuid)    ! Add single value range limit for sort order 1
  InvoiceBrowse.AddSortOrder(,Inv:DateKey)                 ! Add the sort order for Inv:DateKey for sort order 2
  InvoiceBrowse.AddLocator(BRW1::Sort0:Locator)            ! Browse has a locator for sort order 2
  BRW1::Sort0:Locator.Init(,Inv:Date,1,InvoiceBrowse)      ! Initialize the browse locator using  using key: Inv:DateKey , Inv:Date
  InvoiceBrowse.AddResetField(CustomerGuid)                ! Apply the reset field
  ?InvoiceList{PROP:IconList,1} = '~BOXCHECK.ICO'
  ?InvoiceList{PROP:IconList,2} = '~BOXEMPTY.ICO'
  InvoiceBrowse.AddField(Inv:InvoiceNumber,InvoiceBrowse.Q.Inv:InvoiceNumber) ! Field Inv:InvoiceNumber is a hot field or requires assignment from browse
  InvoiceBrowse.AddField(Inv:Date,InvoiceBrowse.Q.Inv:Date) ! Field Inv:Date is a hot field or requires assignment from browse
  InvoiceBrowse.AddField(Inv:OrderShipped,InvoiceBrowse.Q.Inv:OrderShipped) ! Field Inv:OrderShipped is a hot field or requires assignment from browse
  InvoiceBrowse.AddField(Inv:FirstName,InvoiceBrowse.Q.Inv:FirstName) ! Field Inv:FirstName is a hot field or requires assignment from browse
  InvoiceBrowse.AddField(Inv:LastName,InvoiceBrowse.Q.Inv:LastName) ! Field Inv:LastName is a hot field or requires assignment from browse
  InvoiceBrowse.AddField(Inv:Street,InvoiceBrowse.Q.Inv:Street) ! Field Inv:Street is a hot field or requires assignment from browse
  InvoiceBrowse.AddField(Inv:City,InvoiceBrowse.Q.Inv:City) ! Field Inv:City is a hot field or requires assignment from browse
  InvoiceBrowse.AddField(Inv:State,InvoiceBrowse.Q.Inv:State) ! Field Inv:State is a hot field or requires assignment from browse
  InvoiceBrowse.AddField(Inv:PostalCode,InvoiceBrowse.Q.Inv:PostalCode) ! Field Inv:PostalCode is a hot field or requires assignment from browse
  InvoiceBrowse.AddField(Inv:GUID,InvoiceBrowse.Q.Inv:GUID) ! Field Inv:GUID is a hot field or requires assignment from browse
  InvoiceBrowse.AddField(Inv:CustomerGuid,InvoiceBrowse.Q.Inv:CustomerGuid) ! Field Inv:CustomerGuid is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseInvoice:Window',QuickWindow)         ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  InvoiceBrowse.AskProcedure = 1                           ! Will call: UpdateInvoice
  SELF.SetAlerts()
  BRW1::AutoSizeColumn.Init()
  BRW1::AutoSizeColumn.AddListBox(?InvoiceList,InvoiceQueue)
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW1::SortHeader.Init(InvoiceQueue,?InvoiceList,'','',BRW1::View:Browse,Inv:GuidKey)
  BRW1::SortHeader.UseSortColors = False
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Customer.Close()
  !Kill the Sort Header
  BRW1::SortHeader.Kill()
  END
  BRW1::AutoSizeColumn.Kill()
  IF SELF.Opened
    INIMgr.Update('BrowseInvoice:Window',QuickWindow)      ! Save window data to non-volatile store
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
    UpdateInvoice
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


ThisWindow.SetAlerts PROCEDURE

  CODE
  PARENT.SetAlerts
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW1::SortHeader.SetAlerts()


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
    OF ?BUTTON:SelectCustomer
      ThisWindow.Update()
        GlobalRequest = SelectRecord                       ! Set Action for Lookup
        SelectCustomer                                     ! Call the Lookup Procedure
        IF GlobalResponse = RequestCompleted               ! IF Lookup completed
          SetSelectedCustomer()                            ! Source on Completion
        END                                                ! END (IF Lookup completed)
        GlobalResponse = RequestCancelled                  ! Clear Result
        SELECT(?InvoiceList)
    OF ?BUTTON:SelectCustomer:2
      ThisWindow.Update()
      ClearSelectedCustomer()
      SELECT(?InvoiceList)
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  !Take Sort Headers Events
  IF BRW1::SortHeader.TakeEvents()
     RETURN Level:Notify
  END
  IF BRW1::AutoSizeColumn.TakeEvents()
     RETURN Level:Notify
  END
  ReturnValue = PARENT.TakeEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


InvoiceBrowse.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert
    SELF.ChangeControl=?Change
    SELF.DeleteControl=?Delete
  END


InvoiceBrowse.ResetSort PROCEDURE(BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  IF CustomerGuid <> ''
    RETURN SELF.SetSort(1,Force)
  ELSE
    RETURN SELF.SetSort(2,Force)
  END
  ReturnValue = PARENT.ResetSort(Force)
  RETURN ReturnValue


InvoiceBrowse.SetQueueRecord PROCEDURE

  CODE
  PARENT.SetQueueRecord
  
  IF (Inv:OrderShipped)
    SELF.Q.Inv:OrderShipped_Icon = 1                       ! Set icon from icon list
  ELSE
    SELF.Q.Inv:OrderShipped_Icon = 2                       ! Set icon from icon list
  END


InvoiceBrowse.SetSort PROCEDURE(BYTE NewOrder,BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.SetSort(NewOrder,Force)
  IF BRW1::LastSortOrder<>NewOrder THEN
     BRW1::SortHeader.ClearSort()
  END
  BRW1::LastSortOrder=NewOrder
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window
  SELF.SetStrategy(?CustomerName, Resize:FixLeft+Resize:FixTop, Resize:LockHeight) ! Override strategy for ?CustomerName

BRW1::SortHeader.QueueResorted       PROCEDURE(STRING pString)
  CODE
    IF pString = ''
       InvoiceBrowse.RestoreSort()
       InvoiceBrowse.ResetSort(True)
    ELSE
       InvoiceBrowse.ReplaceSort(pString,BRW1::Sort0:Locator)
       InvoiceBrowse.SetLocatorFromSort()
    END
SetSelectedCustomer           PROCEDURE
  CODE
  CustomerGuid = Cus:GUID
  CustomerName = LEFT(CLIP(Cus:FirstName) &' '& Cus:LastName)

ClearSelectedCustomer         PROCEDURE
  CODE
  CustomerGuid = ''
  CustomerName = 'ALL CUSTOMERS'
