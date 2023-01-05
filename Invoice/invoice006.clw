

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('BRWEXT.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE006.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('INVOICE016.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('INVOICE017.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the Invoice file (with select)
!!! </summary>
BrowseInvoice PROCEDURE 

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
                       PROJECT(Inv:PostalCode)
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
Inv:PostalCode         LIKE(Inv:PostalCode)           !List box control field - type derived from field
Inv:GUID               LIKE(Inv:GUID)                 !Primary key field - type derived from field
Inv:CustomerGuid       LIKE(Inv:CustomerGuid)         !Browse key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the Invoice file'),AT(,,358,198),FONT('Segoe UI',10,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,ICON('INVOICE.ICO'),GRAY,IMM,MDI,HLP('BrowseInvoice'),SYSTEM
                       LIST,AT(8,8,342,147),USE(?Browse:1),HVSCROLL,FORMAT('40R(2)|M~Invoice~C(0)@n07@80R(2)|M' & |
  '~Date~C(0)@d10@32L(2)|M~Shipped~@s1@80L(2)|M~First Name~@s100@80L(2)|M~Last Name~@s1' & |
  '00@80L(2)|M~Street~@s255@80L(2)|M~City~@s100@80L(2)|M~State~@s100@80L(2)|M~Postal Code~@s100@'), |
  FROM(Queue:Browse:1),IMM,MSG('Browsing the Invoice file')
                       BUTTON('Insert'),AT(192,158,50,14),USE(?Insert)
                       BUTTON('Change'),AT(246,158,50,14),USE(?Change),DEFAULT
                       BUTTON('Delete'),AT(300,158,50,14),USE(?Delete)
                       BUTTON('Select Customer'),AT(8,158,75,14),USE(?SelectCustomer)
                       BUTTON('Close'),AT(304,180,50,14),USE(?Close)
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
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
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
  GlobalErrors.SetProcedureName('BrowseInvoice')
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
  Relate:Customer.SetOpenRelated()
  Relate:Customer.Open()                                   ! File Customer used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Invoice,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?Browse:1{PROP:LineHeight} = 11
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,Inv:CustomerKey)                      ! Add the sort order for Inv:CustomerKey for sort order 1
  BRW1.AddRange(Inv:CustomerGuid,Relate:Invoice,Relate:Customer) ! Add file relationship range limit for sort order 1
  BRW1.AddSortOrder(,Inv:GuidKey)                          ! Add the sort order for Inv:GuidKey for sort order 2
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort0:Locator.Init(,Inv:GUID,1,BRW1)               ! Initialize the browse locator using  using key: Inv:GuidKey , Inv:GUID
  BRW1.AddField(Inv:InvoiceNumber,BRW1.Q.Inv:InvoiceNumber) ! Field Inv:InvoiceNumber is a hot field or requires assignment from browse
  BRW1.AddField(Inv:Date,BRW1.Q.Inv:Date)                  ! Field Inv:Date is a hot field or requires assignment from browse
  BRW1.AddField(Inv:OrderShipped,BRW1.Q.Inv:OrderShipped)  ! Field Inv:OrderShipped is a hot field or requires assignment from browse
  BRW1.AddField(Inv:FirstName,BRW1.Q.Inv:FirstName)        ! Field Inv:FirstName is a hot field or requires assignment from browse
  BRW1.AddField(Inv:LastName,BRW1.Q.Inv:LastName)          ! Field Inv:LastName is a hot field or requires assignment from browse
  BRW1.AddField(Inv:Street,BRW1.Q.Inv:Street)              ! Field Inv:Street is a hot field or requires assignment from browse
  BRW1.AddField(Inv:City,BRW1.Q.Inv:City)                  ! Field Inv:City is a hot field or requires assignment from browse
  BRW1.AddField(Inv:State,BRW1.Q.Inv:State)                ! Field Inv:State is a hot field or requires assignment from browse
  BRW1.AddField(Inv:PostalCode,BRW1.Q.Inv:PostalCode)      ! Field Inv:PostalCode is a hot field or requires assignment from browse
  BRW1.AddField(Inv:GUID,BRW1.Q.Inv:GUID)                  ! Field Inv:GUID is a hot field or requires assignment from browse
  BRW1.AddField(Inv:CustomerGuid,BRW1.Q.Inv:CustomerGuid)  ! Field Inv:CustomerGuid is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseInvoice',QuickWindow)                ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateInvoice
  SELF.SetAlerts()
  BRW1::AutoSizeColumn.Init()
  BRW1::AutoSizeColumn.AddListBox(?Browse:1,Queue:Browse:1)
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW1::SortHeader.Init(Queue:Browse:1,?Browse:1,'','',BRW1::View:Browse,Inv:GuidKey)
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
    INIMgr.Update('BrowseInvoice',QuickWindow)             ! Save window data to non-volatile store
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
    OF ?SelectCustomer
      ThisWindow.Update()
      GlobalRequest = SelectRecord
      SelectCustomer()
      ThisWindow.Reset
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


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert
    SELF.ChangeControl=?Change
    SELF.DeleteControl=?Delete
  END


BRW1.ResetSort PROCEDURE(BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  IF x#= 2
    RETURN SELF.SetSort(1,Force)
  ELSE
    RETURN SELF.SetSort(2,Force)
  END
  ReturnValue = PARENT.ResetSort(Force)
  RETURN ReturnValue


BRW1.SetSort PROCEDURE(BYTE NewOrder,BYTE Force)

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

BRW1::SortHeader.QueueResorted       PROCEDURE(STRING pString)
  CODE
    IF pString = ''
       BRW1.RestoreSort()
       BRW1.ResetSort(True)
    ELSE
       BRW1.ReplaceSort(pString,BRW1::Sort0:Locator)
       BRW1.SetLocatorFromSort()
    END
