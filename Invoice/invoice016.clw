

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('BRWEXT.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE016.INC'),ONCE        !Local module procedure declarations
                     END


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
QuickWindow          WINDOW('Select a Customer Record'),AT(,,358,198),FONT('Segoe UI',10,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('SelectCustomer'),SYSTEM
                       LIST,AT(8,30,342,124),USE(?Browse:1),HVSCROLL,FORMAT('68L(2)|M~Company Guid~L(2)@s16@80' & |
  'L(2)|M~First Name~L(2)@s100@80L(2)|M~Last Name~L(2)@s100@80L(2)|M~Street~L(2)@s255@8' & |
  '0L(2)|M~City~L(2)@s100@80L(2)|M~State~L(2)@s100@80L(2)|M~Postal Code~L(2)@s100@80L(2' & |
  ')|M~Phone#~L(2)@s100@80L(2)|M~Phone#~L(2)@s100@'),FROM(Queue:Browse:1),IMM,MSG('Browsing t' & |
  'he Customer file')
                       BUTTON('&Select'),AT(300,158,50,14),USE(?Select:2),LEFT,ICON('WASELECT.ICO'),FLAT,MSG('Select the Record'), |
  TIP('Select the Record')
                       SHEET,AT(4,4,350,172),USE(?CurrentTab)
                         TAB('Tab'),USE(?Tab:2)
                         END
                         TAB('Tab'),USE(?Tab:3)
                         END
                         TAB('Tab'),USE(?Tab:4)
                         END
                         TAB('Tab'),USE(?Tab:5)
                         END
                         TAB('Tab'),USE(?Tab:6)
                         END
                         TAB('Tab'),USE(?Tab:7)
                         END
                       END
                       BUTTON('&Close'),AT(304,180,50,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
                     END

BRW1::AutoSizeColumn CLASS(AutoSizeColumnClassType)
               END
ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
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
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?Browse:1{PROP:LineHeight} = 11
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
  BRW1::AutoSizeColumn.Init()
  BRW1::AutoSizeColumn.AddListBox(?Browse:1,Queue:Browse:1)
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Customer.Close()
  END
  BRW1::AutoSizeColumn.Kill()
  IF SELF.Opened
    INIMgr.Update('SelectCustomer',QuickWindow)            ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
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

