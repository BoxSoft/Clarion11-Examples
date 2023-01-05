

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('BRWEXT.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE008.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('INVOICE018.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('INVOICE019.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the Customer file (with select)
!!! </summary>
BrowseCustomer PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(Customer)
                       PROJECT(Cus:FirstName)
                       PROJECT(Cus:LastName)
                       PROJECT(Cus:Street)
                       PROJECT(Cus:City)
                       PROJECT(Cus:State)
                       PROJECT(Cus:PostalCode)
                       PROJECT(Cus:Phone)
                       PROJECT(Cus:MobilePhone)
                       PROJECT(Cus:GUID)
                       PROJECT(Cus:CompanyGuid)
                       JOIN(CusCom:GuidKey,Cus:CompanyGuid)
                         PROJECT(CusCom:CompanyName)
                         PROJECT(CusCom:GUID)
                       END
                     END
Queue:Browse         QUEUE                            !Queue declaration for browse/combo box using ?Browse
CusCom:CompanyName     LIKE(CusCom:CompanyName)       !List box control field - type derived from field
Cus:FirstName          LIKE(Cus:FirstName)            !List box control field - type derived from field
Cus:LastName           LIKE(Cus:LastName)             !List box control field - type derived from field
Cus:Street             LIKE(Cus:Street)               !List box control field - type derived from field
Cus:City               LIKE(Cus:City)                 !List box control field - type derived from field
Cus:State              LIKE(Cus:State)                !List box control field - type derived from field
Cus:PostalCode         LIKE(Cus:PostalCode)           !List box control field - type derived from field
Cus:Phone              LIKE(Cus:Phone)                !List box control field - type derived from field
Cus:MobilePhone        LIKE(Cus:MobilePhone)          !List box control field - type derived from field
Cus:GUID               LIKE(Cus:GUID)                 !Primary key field - type derived from field
Cus:CompanyGuid        LIKE(Cus:CompanyGuid)          !Browse key field - type derived from field
CusCom:GUID            LIKE(CusCom:GUID)              !Related join file key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse Customers'),AT(,,358,198),FONT('Segoe UI',10,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,CENTER,ICON('CUSTOMER.ICO'),IMM,MDI,SYSTEM
                       LIST,AT(8,8,342,146),USE(?Browse),HVSCROLL,FORMAT('100L(2)|M~Company Name~@s100@80L(2)|' & |
  'M~First Name~@s100@80L(2)|M~Last Name~@s100@80L(2)|M~Street~@s255@80L(2)|M~City~@s10' & |
  '0@80L(2)|M~State~@s100@80L(2)|M~Postal Code~@s100@80L(2)|M~Phone~@s100@80L(2)|M~Mobi' & |
  'le Phone~@s100@'),FROM(Queue:Browse),IMM
                       BUTTON('Insert'),AT(192,158,50,14),USE(?Insert)
                       BUTTON('Change'),AT(246,158,50,14),USE(?Change),DEFAULT
                       BUTTON('Delete'),AT(300,158,50,14),USE(?Delete)
                       BUTTON('Select Company'),AT(7,158,75,14),USE(?SelectCustomerCompany)
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
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse
Q                      &Queue:Browse                  !Reference to browse queue
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
  GlobalErrors.SetProcedureName('BrowseCustomer')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse
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
  Relate:Customer.Open()                                   ! File Customer used by this procedure, so make sure it's RelationManager is open
  Access:CustomerCompany.UseFile()                         ! File referenced in 'Other Files' so need to inform it's FileManager
  SELF.FilesOpened = True
  BRW1.Init(?Browse,Queue:Browse.ViewPosition,BRW1::View:Browse,Queue:Browse,Relate:Customer,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?Browse{PROP:LineHeight} = 11
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,Cus:CompanyKey)                       ! Add the sort order for Cus:CompanyKey for sort order 1
  BRW1.AddRange(Cus:CompanyGuid,Relate:Customer,Relate:CustomerCompany) ! Add file relationship range limit for sort order 1
  BRW1.AddSortOrder(,Cus:GuidKey)                          ! Add the sort order for Cus:GuidKey for sort order 2
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort0:Locator.Init(,Cus:GUID,1,BRW1)               ! Initialize the browse locator using  using key: Cus:GuidKey , Cus:GUID
  BRW1.AddField(CusCom:CompanyName,BRW1.Q.CusCom:CompanyName) ! Field CusCom:CompanyName is a hot field or requires assignment from browse
  BRW1.AddField(Cus:FirstName,BRW1.Q.Cus:FirstName)        ! Field Cus:FirstName is a hot field or requires assignment from browse
  BRW1.AddField(Cus:LastName,BRW1.Q.Cus:LastName)          ! Field Cus:LastName is a hot field or requires assignment from browse
  BRW1.AddField(Cus:Street,BRW1.Q.Cus:Street)              ! Field Cus:Street is a hot field or requires assignment from browse
  BRW1.AddField(Cus:City,BRW1.Q.Cus:City)                  ! Field Cus:City is a hot field or requires assignment from browse
  BRW1.AddField(Cus:State,BRW1.Q.Cus:State)                ! Field Cus:State is a hot field or requires assignment from browse
  BRW1.AddField(Cus:PostalCode,BRW1.Q.Cus:PostalCode)      ! Field Cus:PostalCode is a hot field or requires assignment from browse
  BRW1.AddField(Cus:Phone,BRW1.Q.Cus:Phone)                ! Field Cus:Phone is a hot field or requires assignment from browse
  BRW1.AddField(Cus:MobilePhone,BRW1.Q.Cus:MobilePhone)    ! Field Cus:MobilePhone is a hot field or requires assignment from browse
  BRW1.AddField(Cus:GUID,BRW1.Q.Cus:GUID)                  ! Field Cus:GUID is a hot field or requires assignment from browse
  BRW1.AddField(Cus:CompanyGuid,BRW1.Q.Cus:CompanyGuid)    ! Field Cus:CompanyGuid is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:GUID,BRW1.Q.CusCom:GUID)            ! Field CusCom:GUID is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseCustomer',QuickWindow)               ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateCustomer
  SELF.SetAlerts()
  BRW1::AutoSizeColumn.Init()
  BRW1::AutoSizeColumn.AddListBox(?Browse,Queue:Browse)
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW1::SortHeader.Init(Queue:Browse,?Browse,'','',BRW1::View:Browse,Cus:GuidKey)
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
    INIMgr.Update('BrowseCustomer',QuickWindow)            ! Save window data to non-volatile store
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
    UpdateCustomer
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
    OF ?SelectCustomerCompany
      ThisWindow.Update()
      GlobalRequest = SelectRecord
      SelectCustomerCompany()
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
  IF X#=2
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
