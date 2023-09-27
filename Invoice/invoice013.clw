

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('BRWEXT.INC'),ONCE

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
                       PROJECT(Inv:PostalCode)
                       PROJECT(Inv:GUID)
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
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Select Invoice'),AT(,,358,177),FONT('Segoe UI',10,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,ICON('INVOICE.ICO'),IMM,MDI,SYSTEM
                       LIST,AT(8,8,342,146),USE(?Browse:1),HVSCROLL,FORMAT('40R(2)|M~Invoice #~C(0)@n07@80R(2)' & |
  '|M~Date~C(0)@d10@32L(2)|M~Shipped~L(2)@s1@80L(2)|M~First Name~L(2)@s100@80L(2)|M~Las' & |
  't Name~L(2)@s100@80L(2)|M~Street~L(2)@s255@80L(2)|M~City~L(2)@s100@80L(2)|M~State~L(' & |
  '2)@s100@80L(2)|M~Postal Code~L(2)@s100@'),FROM(Queue:Browse:1),IMM,MSG('Browsing the' & |
  ' Invoice file')
                       BUTTON('Select'),AT(246,158,50,14),USE(?Select:2)
                       BUTTON('Cancel'),AT(300,158,50,14),USE(?Close)
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
SetAlerts              PROCEDURE(),DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
SetSort                PROCEDURE(BYTE NewOrder,BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
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
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?Browse:1{PROP:LineHeight} = 11
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,Inv:InvoiceNumberKey)                 ! Add the sort order for Inv:InvoiceNumberKey for sort order 1
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort0:Locator.Init(,Inv:InvoiceNumber,1,BRW1)      ! Initialize the browse locator using  using key: Inv:InvoiceNumberKey , Inv:InvoiceNumber
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
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('SelectInvoice',QuickWindow)                ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
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
    Relate:Invoice.Close()
  !Kill the Sort Header
  BRW1::SortHeader.Kill()
  END
  BRW1::AutoSizeColumn.Kill()
  IF SELF.Opened
    INIMgr.Update('SelectInvoice',QuickWindow)             ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.SetAlerts PROCEDURE

  CODE
  PARENT.SetAlerts
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW1::SortHeader.SetAlerts()


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
  SELF.SelectControl = ?Select:2
  SELF.HideSelect = 1                                      ! Hide the select button when disabled
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)


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
