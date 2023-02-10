

   MEMBER('TestInvDev.clw')                                ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('TESTINVDEV001.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('TESTINVDEV002.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('TESTINVDEV003.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('TESTINVDEV004.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Frame
!!! Wizard Application 
!!! </summary>
MainTestDev PROCEDURE 

SQLOpenWindow        WINDOW('Initializing Database'),AT(,,208,26),FONT('Microsoft Sans Serif',8,,FONT:regular),CENTER,GRAY,DOUBLE
                       STRING('This process could take several seconds.'),AT(27,12)
                       IMAGE(Icon:Connect),AT(4,4,23,17)
                       STRING('Please wait while the program connects to the database.'),AT(27,3)
                     END

AppFrame             APPLICATION('Test Dev of Invoice Example'),AT(,,505,318),FONT('Segoe UI',9,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,ICON(ICON:Exclamation),MAX,STATUS(-1,80,120,45),SYSTEM,IMM
                       MENUBAR,USE(?Menubar)
                         MENU('&File'),USE(?FileMenu)
                           ITEM('&Print Setup ...'),USE(?PrintSetup),MSG('Setup printer'),STD(STD:PrintSetup)
                           ITEM,USE(?SEPARATOR1),SEPARATOR
                           ITEM('E&xit'),USE(?Exit),MSG('Exit this application'),STD(STD:Close)
                         END
                         MENU('&Edit'),USE(?EditMenu)
                           ITEM('Cu&t'),USE(?Cut),MSG('Cut Selection To Clipboard'),STD(STD:Cut)
                           ITEM('&Copy'),USE(?Copy),MSG('Copy Selection To Clipboard'),STD(STD:Copy)
                           ITEM('&Paste'),USE(?Paste),MSG('Paste From Clipboard'),STD(STD:Paste)
                         END
                         MENU('&Browse'),USE(?BrowseMenu)
                           ITEM('Browse Customer Company information'),USE(?BrowseCustomerCompany),MSG('Browse Def' & |
  'ault company information')
                           ITEM('Browse Customer''s Information'),USE(?BrowseCustomer),MSG('Browse Customer''s Information')
                           ITEM('Browse Product''s Information'),USE(?BrowseProduct),MSG('Browse Product''s Information')
                           ITEM('Browse Invoice (Customer Orders)'),USE(?BrowseInvoice),MSG('Browse Customer''s Orders')
                           ITEM('Browse Invoice Detail (Product-Order)'),USE(?BrowseInvoiceDetail),MSG('Browse Pro' & |
  'duct-Order detail')
                           ITEM('Browse Program settings and such'),USE(?BrowseConfiguration),MSG('Browse Program ' & |
  'settings and such')
                         END
                         MENU('&Window'),USE(?WindowMenu),STD(STD:WindowList)
                           ITEM('T&ile'),USE(?Tile),MSG('Arrange multiple opened windows'),STD(STD:TileWindow)
                           ITEM('&Cascade'),USE(?Cascade),MSG('Arrange multiple opened windows'),STD(STD:CascadeWindow)
                           ITEM('&Arrange Icons'),USE(?Arrange),MSG('Arrange the icons for minimized windows'),STD(STD:ArrangeIcons)
                         END
                         MENU('&Help'),USE(?HelpMenu)
                           ITEM('&Contents'),USE(?Helpindex),MSG('View the contents of the help file'),STD(STD:HelpIndex)
                           ITEM('&Search for Help On...'),USE(?HelpSearch),MSG('Search for help on a subject'),STD(STD:HelpSearch)
                           ITEM('&How to Use Help'),USE(?HelpOnHelp),MSG('Provides general instructions on using help'), |
  STD(STD:HelpOnHelp)
                         END
                         MENU('TEST DATA'),USE(?TestDataMenu)
                           ITEM('Customer Company - Generate Test Data'),USE(?TestData_CusCompanyGenerate)
                           ITEM('Customer Company - Delete ALL'),USE(?TestData_CusCompanyDeleteALL)
                           ITEM,USE(?SEPARATOR2),SEPARATOR
                           ITEM('Customer - Generate Test Data'),USE(?TestData_CustomerGenerate)
                           ITEM('Customer - Delete ALL'),USE(?TestData_CustomerDeleteALL)
                           ITEM,USE(?SEPARATOR3),SEPARATOR
                           MENU('Import Company & Customer from CSV'),USE(?TestData_ImportMenu)
                             ITEM('Import CSV Test Data'),USE(?TestData_ImportCsvtoSQL)
                             ITEM,USE(?SEPARATOR_i1),SEPARATOR
                             ITEM('Browse CSV for Customer Import'),USE(?TestData_BrowseCsvFile)
                           END
                           ITEM,USE(?SEPARATOR4),SEPARATOR
                           ITEM('Product - Generate Test Data'),USE(?TestData_ProductGenerate)
                           ITEM('Product - Delete ALL'),USE(?TestData_ProductDeleteALL)
                           ITEM,USE(?SEPARATOR5),SEPARATOR
                           ITEM('Invoice - Generate Test Data'),USE(?TestData_InvoiceGenerate)
                           ITEM('Invoice - Delete ALL'),USE(?TestData_InvoiceDeleteALL)
                         END
                         MENU('Tests'),USE(?TestsMenu)
                           ITEM('Scratch Window'),USE(?Tests_ScratchWindow)
                           ITEM('TestMakeGUID_StressTest'),USE(?Test_MakeGUID_StressTest)
                         END
                       END
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass

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
Menu::Menubar ROUTINE                                      ! Code for menu items on ?Menubar
Menu::FileMenu ROUTINE                                     ! Code for menu items on ?FileMenu
Menu::EditMenu ROUTINE                                     ! Code for menu items on ?EditMenu
Menu::BrowseMenu ROUTINE                                   ! Code for menu items on ?BrowseMenu
  CASE ACCEPTED()
  OF ?BrowseCustomerCompany
    START(BrowseCustomerCompany, 050000)
  OF ?BrowseCustomer
    START(BrowseCustomer, 050000)
  OF ?BrowseProduct
    START(BrowseProduct, 050000)
  OF ?BrowseInvoice
    START(BrowseInvoice, 050000)
  OF ?BrowseInvoiceDetail
    START(BrowseInvoiceDetail, 050000)
  OF ?BrowseConfiguration
    START(BrowseConfiguration, 050000)
  END
Menu::WindowMenu ROUTINE                                   ! Code for menu items on ?WindowMenu
Menu::HelpMenu ROUTINE                                     ! Code for menu items on ?HelpMenu
Menu::TestDataMenu ROUTINE                                 ! Code for menu items on ?TestDataMenu
  CASE ACCEPTED()
  OF ?TestData_CusCompanyGenerate
    START(TestGenerate_CustomerCompany, 25000)
  OF ?TestData_CusCompanyDeleteALL
    START(DeleteAll_CustomerCompany, 25000)
  OF ?TestData_CustomerGenerate
    START(TestGenerate_CustomerFile, 25000)
  OF ?TestData_CustomerDeleteALL
    START(DeleteAll_Customer, 25000)
  OF ?TestData_ProductGenerate
    START(TestGenerate_Product, 25000)
  OF ?TestData_ProductDeleteALL
    START(DeleteAll_Product, 25000)
  OF ?TestData_InvoiceGenerate
    START(TestGenerate_Invoices, 25000)
  OF ?TestData_InvoiceDeleteALL
    START(DeleteAll_Invoice, 25000)
  END
Menu::TestData_ImportMenu ROUTINE                          ! Code for menu items on ?TestData_ImportMenu
  CASE ACCEPTED()
  OF ?TestData_ImportCsvtoSQL
    START(TestCsvImportProcessToImport, 25000)
  OF ?TestData_BrowseCsvFile
    START(TestCsvImportCompanyBrowse, 25000)
  END
Menu::TestsMenu ROUTINE                                    ! Code for menu items on ?TestsMenu
  CASE ACCEPTED()
  OF ?Tests_ScratchWindow
    START(TestScratchWindow, 25000)
  OF ?Test_MakeGUID_StressTest
    START(TestMakeGUID_StressTest, 25000)
  END

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  SYSTEM{PROP:MsgModeDefault}=MSGMODE:CANCOPY
  GlobalErrors.SetProcedureName('MainTestDev')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = 1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SETCURSOR(Cursor:Wait)
  OPEN(SQLOpenWindow)
  ACCEPT
    IF EVENT() = Event:OpenWindow
  Relate:CustomerCompany.Open()                            ! File CustomerCompany used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
      POST(EVENT:CloseWindow)
    END
  END
  CLOSE(SQLOpenWindow)
  SETCURSOR()
  SELF.Open(AppFrame)                                      ! Open window
  Do DefineListboxStyle
  INIMgr.Fetch('MainTestDev',AppFrame)                     ! Restore window settings from non-volatile store
  SELF.SetAlerts()
      AppFrame{PROP:TabBarVisible}  = False
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
    INIMgr.Update('MainTestDev',AppFrame)                  ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
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
    CASE ACCEPTED()
    ELSE
      DO Menu::Menubar                                     ! Process menu items on ?Menubar menu
      DO Menu::FileMenu                                    ! Process menu items on ?FileMenu menu
      DO Menu::EditMenu                                    ! Process menu items on ?EditMenu menu
      DO Menu::BrowseMenu                                  ! Process menu items on ?BrowseMenu menu
      DO Menu::WindowMenu                                  ! Process menu items on ?WindowMenu menu
      DO Menu::HelpMenu                                    ! Process menu items on ?HelpMenu menu
      DO Menu::TestDataMenu                                ! Process menu items on ?TestDataMenu menu
      DO Menu::TestData_ImportMenu                         ! Process menu items on ?TestData_ImportMenu menu
      DO Menu::TestsMenu                                   ! Process menu items on ?TestsMenu menu
    END
  ReturnValue = PARENT.TakeAccepted()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue

!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the CustomerCompany file
!!! </summary>
BrowseCustomerCompany PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(CustomerCompany)
                       PROJECT(CusCom:GUID)
                       PROJECT(CusCom:CompanyName)
                       PROJECT(CusCom:Street)
                       PROJECT(CusCom:City)
                       PROJECT(CusCom:State)
                       PROJECT(CusCom:PostalCode)
                       PROJECT(CusCom:Phone)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
CusCom:GUID            LIKE(CusCom:GUID)              !List box control field - type derived from field
CusCom:CompanyName     LIKE(CusCom:CompanyName)       !List box control field - type derived from field
CusCom:Street          LIKE(CusCom:Street)            !List box control field - type derived from field
CusCom:City            LIKE(CusCom:City)              !List box control field - type derived from field
CusCom:State           LIKE(CusCom:State)             !List box control field - type derived from field
CusCom:PostalCode      LIKE(CusCom:PostalCode)        !List box control field - type derived from field
CusCom:Phone           LIKE(CusCom:Phone)             !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the CustomerCompany file'),AT(,,419,198),FONT('Segoe UI',9,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('BrowseCustomerCompany'),SYSTEM
                       LIST,AT(8,23,402,146),USE(?Browse:1),VSCROLL,FORMAT('74L(2)|M~GUID~@s16@80L(2)|M~Compan' & |
  'y Name~@s100@80L(2)|M~Street~@s255@80L(2)|M~City~@s100@20L(2)|M~State~@s100@24L(2)|M' & |
  '~Postal~@s100@80L(2)|M~Phone#~@s100@'),FROM(Queue:Browse:1),IMM,VCR
                       BUTTON('&View'),AT(5,179,49,14),USE(?View:2),LEFT,ICON('WAVIEW.ICO'),FLAT,MSG('View Record'), |
  TIP('View Record')
                       BUTTON('&Insert'),AT(58,179,49,14),USE(?Insert:3),LEFT,ICON('WAINSERT.ICO'),FLAT,MSG('Insert a Record'), |
  TIP('Insert a Record')
                       BUTTON('&Change'),AT(111,179,49,14),USE(?Change:3),LEFT,ICON('WACHANGE.ICO'),DEFAULT,FLAT, |
  MSG('Change the Record'),TIP('Change the Record')
                       BUTTON('&Delete'),AT(164,179,49,14),USE(?Delete:3),LEFT,ICON('WADELETE.ICO'),FLAT,MSG('Delete the Record'), |
  TIP('Delete the Record')
                       SHEET,AT(4,4,408,172),USE(?CurrentTab)
                         TAB('&GuidKey'),USE(?Tab:2)
                         END
                         TAB('&CompanyNameKey'),USE(?Tab:3)
                         END
                       END
                       BUTTON('&Close'),AT(362,179,49,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  IncrementalLocatorClass               ! Default Locator
BRW1::Sort1:Locator  IncrementalLocatorClass               ! Conditional Locator - CHOICE(?CurrentTab) = 2
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
  GlobalErrors.SetProcedureName('BrowseCustomerCompany')
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
  Access:CustomerCompany.UseFile()
  0{PROP:Text}=0{PROP:Text} &' - '& RECORDS(CustomerCompany) &' records'
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,CusCom:CompanyNameKey)                ! Add the sort order for CusCom:CompanyNameKey for sort order 1
  BRW1.AddLocator(BRW1::Sort1:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort1:Locator.Init(,CusCom:CompanyName,1,BRW1)     ! Initialize the browse locator using  using key: CusCom:CompanyNameKey , CusCom:CompanyName
  BRW1.AddSortOrder(,CusCom:GuidKey)                       ! Add the sort order for CusCom:GuidKey for sort order 2
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort0:Locator.Init(,CusCom:GUID,1,BRW1)            ! Initialize the browse locator using  using key: CusCom:GuidKey , CusCom:GUID
  BRW1.AddField(CusCom:GUID,BRW1.Q.CusCom:GUID)            ! Field CusCom:GUID is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:CompanyName,BRW1.Q.CusCom:CompanyName) ! Field CusCom:CompanyName is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:Street,BRW1.Q.CusCom:Street)        ! Field CusCom:Street is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:City,BRW1.Q.CusCom:City)            ! Field CusCom:City is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:State,BRW1.Q.CusCom:State)          ! Field CusCom:State is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:PostalCode,BRW1.Q.CusCom:PostalCode) ! Field CusCom:PostalCode is a hot field or requires assignment from browse
  BRW1.AddField(CusCom:Phone,BRW1.Q.CusCom:Phone)          ! Field CusCom:Phone is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseCustomerCompany',QuickWindow)        ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateCustomerCompany
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
    INIMgr.Update('BrowseCustomerCompany',QuickWindow)     ! Save window data to non-volatile store
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
    UpdateCustomerCompany
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:3
    SELF.ChangeControl=?Change:3
    SELF.DeleteControl=?Delete:3
  END
  SELF.ViewControl = ?View:2                               ! Setup the control used to initiate view only mode


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
!!! Browse the Product file
!!! </summary>
BrowseProduct PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(Product)
                       PROJECT(Pro:GUID)
                       PROJECT(Pro:ProductCode)
                       PROJECT(Pro:ProductName)
                       PROJECT(Pro:Description)
                       PROJECT(Pro:Price)
                       PROJECT(Pro:QuantityInStock)
                       PROJECT(Pro:ReorderQuantity)
                       PROJECT(Pro:Cost)
                       PROJECT(Pro:ImageFilename)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Pro:GUID               LIKE(Pro:GUID)                 !List box control field - type derived from field
Pro:ProductCode        LIKE(Pro:ProductCode)          !List box control field - type derived from field
Pro:ProductName        LIKE(Pro:ProductName)          !List box control field - type derived from field
Pro:Description        LIKE(Pro:Description)          !List box control field - type derived from field
Pro:Price              LIKE(Pro:Price)                !List box control field - type derived from field
Pro:QuantityInStock    LIKE(Pro:QuantityInStock)      !List box control field - type derived from field
Pro:ReorderQuantity    LIKE(Pro:ReorderQuantity)      !List box control field - type derived from field
Pro:Cost               LIKE(Pro:Cost)                 !List box control field - type derived from field
Pro:ImageFilename      LIKE(Pro:ImageFilename)        !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the Product file'),AT(,,433,198),FONT('Segoe UI',9,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('BrowseProduct'),SYSTEM
                       LIST,AT(8,22,414,149),USE(?Browse:1),VSCROLL,FORMAT('42L(2)|M~GUID~@s16@71L(2)|M~Produc' & |
  't Code~@s100@80L(2)|M~Product Name~@s100@80L(2)|M~Description~@s255@40R(2)|M~Price~C' & |
  '(0)@n-11.2@40R(2)|M~Qty In Stock~C(0)@n-12@40R(2)|M~Reorder Qty~C(0)@n13@40R(2)|M~Co' & |
  'st~C(0)@n-11.2@80L(2)|M~Image~@s255@'),FROM(Queue:Browse:1),IMM
                       BUTTON('&View'),AT(5,180,49,14),USE(?View:2),LEFT,ICON('WAVIEW.ICO'),FLAT,MSG('View Record'), |
  TIP('View Record')
                       BUTTON('&Insert'),AT(58,180,49,14),USE(?Insert:3),LEFT,ICON('WAINSERT.ICO'),FLAT,MSG('Insert a Record'), |
  TIP('Insert a Record')
                       BUTTON('&Change'),AT(111,180,49,14),USE(?Change:3),LEFT,ICON('WACHANGE.ICO'),DEFAULT,FLAT, |
  MSG('Change the Record'),TIP('Change the Record')
                       BUTTON('&Delete'),AT(164,180,49,14),USE(?Delete:3),LEFT,ICON('WADELETE.ICO'),FLAT,MSG('Delete the Record'), |
  TIP('Delete the Record')
                       SHEET,AT(4,4,427,172),USE(?CurrentTab)
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
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  IncrementalLocatorClass               ! Default Locator
BRW1::Sort1:Locator  IncrementalLocatorClass               ! Conditional Locator - CHOICE(?CurrentTab) = 2
BRW1::Sort2:Locator  IncrementalLocatorClass               ! Conditional Locator - CHOICE(?CurrentTab) = 3
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
  GlobalErrors.SetProcedureName('BrowseProduct')
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
    Access:Product.UseFile()
  0{PROP:Text}=0{PROP:Text} &' - '& RECORDS(Product) &' records'
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
  BRW1.AddField(Pro:GUID,BRW1.Q.Pro:GUID)                  ! Field Pro:GUID is a hot field or requires assignment from browse
  BRW1.AddField(Pro:ProductCode,BRW1.Q.Pro:ProductCode)    ! Field Pro:ProductCode is a hot field or requires assignment from browse
  BRW1.AddField(Pro:ProductName,BRW1.Q.Pro:ProductName)    ! Field Pro:ProductName is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Description,BRW1.Q.Pro:Description)    ! Field Pro:Description is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Price,BRW1.Q.Pro:Price)                ! Field Pro:Price is a hot field or requires assignment from browse
  BRW1.AddField(Pro:QuantityInStock,BRW1.Q.Pro:QuantityInStock) ! Field Pro:QuantityInStock is a hot field or requires assignment from browse
  BRW1.AddField(Pro:ReorderQuantity,BRW1.Q.Pro:ReorderQuantity) ! Field Pro:ReorderQuantity is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Cost,BRW1.Q.Pro:Cost)                  ! Field Pro:Cost is a hot field or requires assignment from browse
  BRW1.AddField(Pro:ImageFilename,BRW1.Q.Pro:ImageFilename) ! Field Pro:ImageFilename is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseProduct',QuickWindow)                ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateProduct
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
    INIMgr.Update('BrowseProduct',QuickWindow)             ! Save window data to non-volatile store
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
    UpdateProduct
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:3
    SELF.ChangeControl=?Change:3
    SELF.DeleteControl=?Delete:3
  END
  SELF.ViewControl = ?View:2                               ! Setup the control used to initiate view only mode


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
!!! Browse the InvoiceDetail file
!!! </summary>
BrowseInvoiceDetail PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(InvoiceDetail)
                       PROJECT(InvDet:GUID)
                       PROJECT(InvDet:LineNumber)
                       PROJECT(InvDet:Quantity)
                       PROJECT(InvDet:Price)
                       PROJECT(InvDet:TaxRate)
                       PROJECT(InvDet:TaxPaid)
                       PROJECT(InvDet:DiscountRate)
                       PROJECT(InvDet:Discount)
                       PROJECT(InvDet:Total)
                       PROJECT(InvDet:InvoiceGuid)
                       PROJECT(InvDet:ProductGuid)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
InvDet:GUID            LIKE(InvDet:GUID)              !List box control field - type derived from field
InvDet:LineNumber      LIKE(InvDet:LineNumber)        !List box control field - type derived from field
InvDet:Quantity        LIKE(InvDet:Quantity)          !List box control field - type derived from field
InvDet:Price           LIKE(InvDet:Price)             !List box control field - type derived from field
InvDet:TaxRate         LIKE(InvDet:TaxRate)           !List box control field - type derived from field
InvDet:TaxPaid         LIKE(InvDet:TaxPaid)           !List box control field - type derived from field
InvDet:DiscountRate    LIKE(InvDet:DiscountRate)      !List box control field - type derived from field
InvDet:Discount        LIKE(InvDet:Discount)          !List box control field - type derived from field
InvDet:Total           LIKE(InvDet:Total)             !List box control field - type derived from field
InvDet:InvoiceGuid     LIKE(InvDet:InvoiceGuid)       !List box control field - type derived from field
InvDet:ProductGuid     LIKE(InvDet:ProductGuid)       !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the InvoiceDetail file'),AT(,,446,198),FONT('Segoe UI',9,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('BrowseInvoiceDetail'),SYSTEM
                       LIST,AT(8,22,432,149),USE(?Browse:1),HVSCROLL,FORMAT('68L(2)|M~Detail GUID~@s16@26R(2)|' & |
  'M~Line #~C(0)@n4@30R(2)|M~Quantity~C(0)@n-14@45R(2)|M~Price~C(0)@n-15.2@36R(2)|M~Tax' & |
  ' Rate~C(0)@n7.4B@44R(2)|M~Tax Paid~C(0)@n-15.2@39R(2)|M~Discount %~C(0)@n7.4B@44R(2)' & |
  '|M~Discount~C(0)@n-15.2@44R(2)|M~Total~C(0)@n-15.2@44L(2)|M~Invoice GUID~C(0)@s16@44' & |
  'L(2)|M~Product GUID~C(0)@s16@'),FROM(Queue:Browse:1),IMM,MSG('Browsing the InvoiceDetail file')
                       BUTTON('&View'),AT(119,180,49,14),USE(?View:2),LEFT,ICON('WAVIEW.ICO'),FLAT,MSG('View Record'), |
  TIP('View Record')
                       BUTTON('&Insert'),AT(172,180,49,14),USE(?Insert:3),LEFT,ICON('WAINSERT.ICO'),FLAT,MSG('Insert a Record'), |
  TIP('Insert a Record')
                       BUTTON('&Change'),AT(225,180,49,14),USE(?Change:3),LEFT,ICON('WACHANGE.ICO'),DEFAULT,FLAT, |
  MSG('Change the Record'),TIP('Change the Record')
                       BUTTON('&Delete'),AT(278,180,49,14),USE(?Delete:3),LEFT,ICON('WADELETE.ICO'),FLAT,MSG('Delete the Record'), |
  TIP('Delete the Record')
                       SHEET,AT(4,4,438,172),USE(?CurrentTab)
                         TAB('&GuidKey'),USE(?Tab:2)
                         END
                         TAB('One Invoice'),USE(?Tab:3)
                           BUTTON('Select Invoice'),AT(8,180,,14),USE(?SelectInvoice),LEFT,ICON('WAPARENT.ICO'),FLAT, |
  MSG('Select Parent Field'),TIP('Select Parent Field')
                         END
                         TAB('One Product'),USE(?Tab:4)
                           BUTTON('Select Product'),AT(8,180,,14),USE(?SelectProduct),LEFT,ICON('WAPARENT.ICO'),FLAT, |
  MSG('Select Parent Field'),TIP('Select Parent Field')
                         END
                         TAB('InvoiceKey'),USE(?Tab:5)
                         END
                         TAB('ProductKey'),USE(?Tab:6)
                         END
                       END
                       BUTTON('&Close'),AT(391,180,49,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort1:Locator  IncrementalLocatorClass               ! Conditional Locator - CHOICE(?CurrentTab) = 2
BRW1::Sort3:Locator  IncrementalLocatorClass               ! Conditional Locator - CHOICE(?CurrentTab) = 4
BRW1::Sort4:Locator  IncrementalLocatorClass               ! Conditional Locator - CHOICE(?CurrentTab) = 5
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END


  CODE
? DEBUGHOOK(Invoice:Record)
? DEBUGHOOK(InvoiceDetail:Record)
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
  GlobalErrors.SetProcedureName('BrowseInvoiceDetail')
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
  Access:Product.UseFile()                                 ! File referenced in 'Other Files' so need to inform it's FileManager
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:InvoiceDetail,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,InvDet:InvoiceKey)                    ! Add the sort order for InvDet:InvoiceKey for sort order 1
  BRW1.AddRange(InvDet:InvoiceGuid,Relate:InvoiceDetail,Relate:Invoice) ! Add file relationship range limit for sort order 1
  BRW1.AddLocator(BRW1::Sort1:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort1:Locator.Init(,InvDet:LineNumber,1,BRW1)      ! Initialize the browse locator using  using key: InvDet:InvoiceKey , InvDet:LineNumber
  BRW1.AddSortOrder(,InvDet:ProductKey)                    ! Add the sort order for InvDet:ProductKey for sort order 2
  BRW1.AddRange(InvDet:ProductGuid,Relate:InvoiceDetail,Relate:Product) ! Add file relationship range limit for sort order 2
  BRW1.AddSortOrder(,InvDet:InvoiceKey)                    ! Add the sort order for InvDet:InvoiceKey for sort order 3
  BRW1.AddLocator(BRW1::Sort3:Locator)                     ! Browse has a locator for sort order 3
  BRW1::Sort3:Locator.Init(,InvDet:InvoiceGuid,1,BRW1)     ! Initialize the browse locator using  using key: InvDet:InvoiceKey , InvDet:InvoiceGuid
  BRW1.AddSortOrder(,InvDet:ProductKey)                    ! Add the sort order for InvDet:ProductKey for sort order 4
  BRW1.AddLocator(BRW1::Sort4:Locator)                     ! Browse has a locator for sort order 4
  BRW1::Sort4:Locator.Init(,InvDet:ProductGuid,1,BRW1)     ! Initialize the browse locator using  using key: InvDet:ProductKey , InvDet:ProductGuid
  BRW1.AddSortOrder(,InvDet:GuidKey)                       ! Add the sort order for InvDet:GuidKey for sort order 5
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 5
  BRW1::Sort0:Locator.Init(,InvDet:GUID,1,BRW1)            ! Initialize the browse locator using  using key: InvDet:GuidKey , InvDet:GUID
  BRW1.AddField(InvDet:GUID,BRW1.Q.InvDet:GUID)            ! Field InvDet:GUID is a hot field or requires assignment from browse
  BRW1.AddField(InvDet:LineNumber,BRW1.Q.InvDet:LineNumber) ! Field InvDet:LineNumber is a hot field or requires assignment from browse
  BRW1.AddField(InvDet:Quantity,BRW1.Q.InvDet:Quantity)    ! Field InvDet:Quantity is a hot field or requires assignment from browse
  BRW1.AddField(InvDet:Price,BRW1.Q.InvDet:Price)          ! Field InvDet:Price is a hot field or requires assignment from browse
  BRW1.AddField(InvDet:TaxRate,BRW1.Q.InvDet:TaxRate)      ! Field InvDet:TaxRate is a hot field or requires assignment from browse
  BRW1.AddField(InvDet:TaxPaid,BRW1.Q.InvDet:TaxPaid)      ! Field InvDet:TaxPaid is a hot field or requires assignment from browse
  BRW1.AddField(InvDet:DiscountRate,BRW1.Q.InvDet:DiscountRate) ! Field InvDet:DiscountRate is a hot field or requires assignment from browse
  BRW1.AddField(InvDet:Discount,BRW1.Q.InvDet:Discount)    ! Field InvDet:Discount is a hot field or requires assignment from browse
  BRW1.AddField(InvDet:Total,BRW1.Q.InvDet:Total)          ! Field InvDet:Total is a hot field or requires assignment from browse
  BRW1.AddField(InvDet:InvoiceGuid,BRW1.Q.InvDet:InvoiceGuid) ! Field InvDet:InvoiceGuid is a hot field or requires assignment from browse
  BRW1.AddField(InvDet:ProductGuid,BRW1.Q.InvDet:ProductGuid) ! Field InvDet:ProductGuid is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseInvoiceDetail',QuickWindow)          ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateInvoiceDetail
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
    INIMgr.Update('BrowseInvoiceDetail',QuickWindow)       ! Save window data to non-volatile store
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
    UpdateInvoiceDetail
    ReturnValue = GlobalResponse
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
    OF ?SelectInvoice
      ThisWindow.Update()
      GlobalRequest = SelectRecord
      SelectInvoice()
      ThisWindow.Reset
    OF ?SelectProduct
      ThisWindow.Update()
      GlobalRequest = SelectRecord
      SelectProduct()
      ThisWindow.Reset
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:3
    SELF.ChangeControl=?Change:3
    SELF.DeleteControl=?Delete:3
  END
  SELF.ViewControl = ?View:2                               ! Setup the control used to initiate view only mode


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
  ELSE
    RETURN SELF.SetSort(5,Force)
  END
  ReturnValue = PARENT.ResetSort(Force)
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the Invoice file
!!! </summary>
BrowseInvoice PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(Invoice)
                       PROJECT(Inv:GUID)
                       PROJECT(Inv:CustomerGuid)
                       PROJECT(Inv:InvoiceNumber)
                       PROJECT(Inv:Date)
                       PROJECT(Inv:OrderShipped)
                       PROJECT(Inv:Total)
                       PROJECT(Inv:FirstName)
                       PROJECT(Inv:LastName)
                       PROJECT(Inv:Street)
                       PROJECT(Inv:City)
                       PROJECT(Inv:State)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Inv:GUID               LIKE(Inv:GUID)                 !List box control field - type derived from field
Inv:CustomerGuid       LIKE(Inv:CustomerGuid)         !List box control field - type derived from field
Inv:InvoiceNumber      LIKE(Inv:InvoiceNumber)        !List box control field - type derived from field
Inv:Date               LIKE(Inv:Date)                 !List box control field - type derived from field
Inv:OrderShipped       LIKE(Inv:OrderShipped)         !List box control field - type derived from field
Inv:Total              LIKE(Inv:Total)                !List box control field - type derived from field
Inv:FirstName          LIKE(Inv:FirstName)            !List box control field - type derived from field
Inv:LastName           LIKE(Inv:LastName)             !List box control field - type derived from field
Inv:Street             LIKE(Inv:Street)               !List box control field - type derived from field
Inv:City               LIKE(Inv:City)                 !List box control field - type derived from field
Inv:State              LIKE(Inv:State)                !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the Invoice file'),AT(,,442,198),FONT('Segoe UI',9,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('BrowseInvoice'),SYSTEM
                       LIST,AT(8,22,424,147),USE(?Browse:1),HVSCROLL,FORMAT('32L(2)|M~GUID~C(0)@s16@32L(2)|M~C' & |
  'us. Guid~C(0)@s16@35R(2)|M~Invoice #~C(0)@n07@40R(2)|M~Date~C(0)@d10@32L(2)|M~Shippe' & |
  'd~@s1@41R(2)|M~Total~C(0)@n-11.2@40L(2)|M~First Name~@s100@40L(2)|M~Last Name~@s100@' & |
  '80L(2)|M~Street~@s255@80L(2)|M~City~@s100@21L(2)|M~State~@s100@'),FROM(Queue:Browse:1), |
  IMM,MSG('Browsing the Invoice file')
                       BUTTON('&View'),AT(117,180,49,14),USE(?View:2),LEFT,ICON('WAVIEW.ICO'),FLAT,MSG('View Record'), |
  TIP('View Record')
                       BUTTON('&Insert'),AT(170,180,49,14),USE(?Insert:3),LEFT,ICON('WAINSERT.ICO'),FLAT,MSG('Insert a Record'), |
  TIP('Insert a Record')
                       BUTTON('&Change'),AT(223,180,49,14),USE(?Change:3),LEFT,ICON('WACHANGE.ICO'),DEFAULT,FLAT, |
  MSG('Change the Record'),TIP('Change the Record')
                       BUTTON('&Delete'),AT(276,180,49,14),USE(?Delete:3),LEFT,ICON('WADELETE.ICO'),FLAT,MSG('Delete the Record'), |
  TIP('Delete the Record')
                       SHEET,AT(4,4,436,172),USE(?CurrentTab)
                         TAB('&GuidKey'),USE(?Tab:2)
                         END
                         TAB('&One Customer'),USE(?Tab:3)
                           BUTTON('Select Customer'),AT(8,180,,14),USE(?SelectCustomer),LEFT,ICON('WAPARENT.ICO'),FLAT, |
  MSG('Select Parent Field'),TIP('Select Parent Field')
                         END
                         TAB('&DateKey'),USE(?Tab:4)
                         END
                         TAB('All Customers'),USE(?Tab:AllCustomer)
                         END
                         TAB('Invoice #'),USE(?Tab:InvNumber)
                         END
                       END
                       BUTTON('&Close'),AT(383,180,49,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort2:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 3
BRW1::Sort3:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 4
BRW1::Sort4:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 5
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
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Invoice,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Access:Invoice.UseFile()
  0{PROP:Text}=0{PROP:Text} &' - '& RECORDS(Invoice) &' records'
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,Inv:CustomerKey)                      ! Add the sort order for Inv:CustomerKey for sort order 1
  BRW1.AddRange(Inv:CustomerGuid,Relate:Invoice,Relate:Customer) ! Add file relationship range limit for sort order 1
  BRW1.AddSortOrder(,Inv:DateKey)                          ! Add the sort order for Inv:DateKey for sort order 2
  BRW1.AddLocator(BRW1::Sort2:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort2:Locator.Init(,Inv:Date,1,BRW1)               ! Initialize the browse locator using  using key: Inv:DateKey , Inv:Date
  BRW1.AddSortOrder(,Inv:CustomerKey)                      ! Add the sort order for Inv:CustomerKey for sort order 3
  BRW1.AddLocator(BRW1::Sort3:Locator)                     ! Browse has a locator for sort order 3
  BRW1::Sort3:Locator.Init(,Inv:CustomerGuid,1,BRW1)       ! Initialize the browse locator using  using key: Inv:CustomerKey , Inv:CustomerGuid
  BRW1.AddSortOrder(,Inv:InvoiceNumberKey)                 ! Add the sort order for Inv:InvoiceNumberKey for sort order 4
  BRW1.AddLocator(BRW1::Sort4:Locator)                     ! Browse has a locator for sort order 4
  BRW1::Sort4:Locator.Init(,Inv:InvoiceNumber,1,BRW1)      ! Initialize the browse locator using  using key: Inv:InvoiceNumberKey , Inv:InvoiceNumber
  BRW1.AddSortOrder(,Inv:GuidKey)                          ! Add the sort order for Inv:GuidKey for sort order 5
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 5
  BRW1::Sort0:Locator.Init(,Inv:GUID,1,BRW1)               ! Initialize the browse locator using  using key: Inv:GuidKey , Inv:GUID
  BRW1.AddField(Inv:GUID,BRW1.Q.Inv:GUID)                  ! Field Inv:GUID is a hot field or requires assignment from browse
  BRW1.AddField(Inv:CustomerGuid,BRW1.Q.Inv:CustomerGuid)  ! Field Inv:CustomerGuid is a hot field or requires assignment from browse
  BRW1.AddField(Inv:InvoiceNumber,BRW1.Q.Inv:InvoiceNumber) ! Field Inv:InvoiceNumber is a hot field or requires assignment from browse
  BRW1.AddField(Inv:Date,BRW1.Q.Inv:Date)                  ! Field Inv:Date is a hot field or requires assignment from browse
  BRW1.AddField(Inv:OrderShipped,BRW1.Q.Inv:OrderShipped)  ! Field Inv:OrderShipped is a hot field or requires assignment from browse
  BRW1.AddField(Inv:Total,BRW1.Q.Inv:Total)                ! Field Inv:Total is a hot field or requires assignment from browse
  BRW1.AddField(Inv:FirstName,BRW1.Q.Inv:FirstName)        ! Field Inv:FirstName is a hot field or requires assignment from browse
  BRW1.AddField(Inv:LastName,BRW1.Q.Inv:LastName)          ! Field Inv:LastName is a hot field or requires assignment from browse
  BRW1.AddField(Inv:Street,BRW1.Q.Inv:Street)              ! Field Inv:Street is a hot field or requires assignment from browse
  BRW1.AddField(Inv:City,BRW1.Q.Inv:City)                  ! Field Inv:City is a hot field or requires assignment from browse
  BRW1.AddField(Inv:State,BRW1.Q.Inv:State)                ! Field Inv:State is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseInvoice',QuickWindow)                ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateInvoice
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


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:3
    SELF.ChangeControl=?Change:3
    SELF.DeleteControl=?Delete:3
  END
  SELF.ViewControl = ?View:2                               ! Setup the control used to initiate view only mode


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
  ELSE
    RETURN SELF.SetSort(5,Force)
  END
  ReturnValue = PARENT.ResetSort(Force)
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the Customer file
!!! </summary>
BrowseCustomer PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(Customer)
                       PROJECT(Cus:GUID)
                       PROJECT(Cus:CompanyGuid)
                       PROJECT(Cus:CustomerNumber)
                       PROJECT(Cus:FirstName)
                       PROJECT(Cus:LastName)
                       PROJECT(Cus:Street)
                       PROJECT(Cus:City)
                       PROJECT(Cus:State)
                       PROJECT(Cus:PostalCode)
                       PROJECT(Cus:Phone)
                       PROJECT(Cus:MobilePhone)
                       PROJECT(Cus:Email)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Cus:GUID               LIKE(Cus:GUID)                 !List box control field - type derived from field
Cus:CompanyGuid        LIKE(Cus:CompanyGuid)          !List box control field - type derived from field
Cus:CustomerNumber     LIKE(Cus:CustomerNumber)       !List box control field - type derived from field
Cus:FirstName          LIKE(Cus:FirstName)            !List box control field - type derived from field
Cus:LastName           LIKE(Cus:LastName)             !List box control field - type derived from field
Cus:Street             LIKE(Cus:Street)               !List box control field - type derived from field
Cus:City               LIKE(Cus:City)                 !List box control field - type derived from field
Cus:State              LIKE(Cus:State)                !List box control field - type derived from field
Cus:PostalCode         LIKE(Cus:PostalCode)           !List box control field - type derived from field
Cus:Phone              LIKE(Cus:Phone)                !List box control field - type derived from field
Cus:MobilePhone        LIKE(Cus:MobilePhone)          !List box control field - type derived from field
Cus:Email              LIKE(Cus:Email)                !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the Customer file'),AT(,,446,198),FONT('Segoe UI',9,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('BrowseCustomer'),SYSTEM
                       LIST,AT(8,22,426,149),USE(?Browse:1),VSCROLL,FORMAT('36L(2)|M~GUID~@s16@36L(2)|M~Compan' & |
  'y~@s16@29R(2)|M~Number~L(2)@n_7@53L(2)|M~First Name~@s100@55L(2)|M~Last Name~@s100@8' & |
  '0L(2)|M~Street~@s255@54L(2)|M~City~@s100@21L(2)|M~State~@s100@27L(2)|M~Postal~@s100@' & |
  '45L(2)|M~Phone#~@s100@45L(2)|M~Mobile~@s100@400L(2)|M~Email~L(0)@s100@'),FROM(Queue:Browse:1), |
  IMM,VCR
                       BUTTON('&View'),AT(8,180,49,14),USE(?View:2),LEFT,ICON('WAVIEW.ICO'),FLAT,MSG('View Record'), |
  TIP('View Record')
                       BUTTON('&Insert'),AT(61,180,49,14),USE(?Insert:3),LEFT,ICON('WAINSERT.ICO'),FLAT,MSG('Insert a Record'), |
  TIP('Insert a Record')
                       BUTTON('&Change'),AT(114,180,49,14),USE(?Change:3),LEFT,ICON('WACHANGE.ICO'),DEFAULT,FLAT, |
  MSG('Change the Record'),TIP('Change the Record')
                       BUTTON('&Delete'),AT(167,180,49,14),USE(?Delete:3),LEFT,ICON('WADELETE.ICO'),FLAT,MSG('Delete the Record'), |
  TIP('Delete the Record')
                       SHEET,AT(4,4,441,172),USE(?CurrentTab)
                         TAB('&GuidKey'),USE(?Tab:1)
                         END
                         TAB('&Company GUID'),USE(?Tab:2)
                           BUTTON('Select CustomerCompany'),AT(8,158,118,14),USE(?SelectCustomerCompany),LEFT,ICON('WAPARENT.ICO'), |
  FLAT,MSG('Select Parent Field'),TIP('Select Parent Field')
                         END
                         TAB('&LastFirstName'),USE(?Tab:3)
                         END
                         TAB('Customer &Number'),USE(?Tab:4)
                         END
                         TAB('&Postal Code'),USE(?Tab:5)
                         END
                         TAB('&State'),USE(?Tab:6)
                         END
                       END
                       BUTTON('&Close'),AT(305,180,49,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  IncrementalLocatorClass               ! Default Locator
BRW1::Sort1:Locator  IncrementalLocatorClass               ! Conditional Locator - CHOICE(?CurrentTab) = 2
BRW1::Sort2:Locator  IncrementalLocatorClass               ! Conditional Locator - CHOICE(?CurrentTab) = 3
BRW1::Sort3:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 4
BRW1::Sort4:Locator  IncrementalLocatorClass               ! Conditional Locator - CHOICE(?CurrentTab) = 5
BRW1::Sort5:Locator  IncrementalLocatorClass               ! Conditional Locator - CHOICE(?CurrentTab) = 6
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
  Access:CustomerCompany.UseFile()                         ! File referenced in 'Other Files' so need to inform it's FileManager
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Customer,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Access:Customer.UseFile()
  0{PROP:Text}=0{PROP:Text} &' - '& RECORDS(Customer) &' records'
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,Cus:CompanyKey)                       ! Add the sort order for Cus:CompanyKey for sort order 1
  BRW1.AddRange(Cus:CompanyGuid,Relate:Customer,Relate:CustomerCompany) ! Add file relationship range limit for sort order 1
  BRW1.AddLocator(BRW1::Sort1:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort1:Locator.Init(,Cus:CompanyGuid,1,BRW1)        ! Initialize the browse locator using  using key: Cus:CompanyKey , Cus:CompanyGuid
  BRW1.AddSortOrder(,Cus:LastFirstNameKey)                 ! Add the sort order for Cus:LastFirstNameKey for sort order 2
  BRW1.AddLocator(BRW1::Sort2:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort2:Locator.Init(,Cus:LastName,1,BRW1)           ! Initialize the browse locator using  using key: Cus:LastFirstNameKey , Cus:LastName
  BRW1.AddSortOrder(,Cus:CustomerNumberKey)                ! Add the sort order for Cus:CustomerNumberKey for sort order 3
  BRW1.AddLocator(BRW1::Sort3:Locator)                     ! Browse has a locator for sort order 3
  BRW1::Sort3:Locator.Init(,Cus:CustomerNumber,1,BRW1)     ! Initialize the browse locator using  using key: Cus:CustomerNumberKey , Cus:CustomerNumber
  BRW1.AddSortOrder(,Cus:PostalCodeKey)                    ! Add the sort order for Cus:PostalCodeKey for sort order 4
  BRW1.AddLocator(BRW1::Sort4:Locator)                     ! Browse has a locator for sort order 4
  BRW1::Sort4:Locator.Init(,Cus:PostalCode,1,BRW1)         ! Initialize the browse locator using  using key: Cus:PostalCodeKey , Cus:PostalCode
  BRW1.AddSortOrder(,Cus:StateKey)                         ! Add the sort order for Cus:StateKey for sort order 5
  BRW1.AddLocator(BRW1::Sort5:Locator)                     ! Browse has a locator for sort order 5
  BRW1::Sort5:Locator.Init(,Cus:State,1,BRW1)              ! Initialize the browse locator using  using key: Cus:StateKey , Cus:State
  BRW1.AddSortOrder(,Cus:GuidKey)                          ! Add the sort order for Cus:GuidKey for sort order 6
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 6
  BRW1::Sort0:Locator.Init(,Cus:GUID,1,BRW1)               ! Initialize the browse locator using  using key: Cus:GuidKey , Cus:GUID
  BRW1.AddField(Cus:GUID,BRW1.Q.Cus:GUID)                  ! Field Cus:GUID is a hot field or requires assignment from browse
  BRW1.AddField(Cus:CompanyGuid,BRW1.Q.Cus:CompanyGuid)    ! Field Cus:CompanyGuid is a hot field or requires assignment from browse
  BRW1.AddField(Cus:CustomerNumber,BRW1.Q.Cus:CustomerNumber) ! Field Cus:CustomerNumber is a hot field or requires assignment from browse
  BRW1.AddField(Cus:FirstName,BRW1.Q.Cus:FirstName)        ! Field Cus:FirstName is a hot field or requires assignment from browse
  BRW1.AddField(Cus:LastName,BRW1.Q.Cus:LastName)          ! Field Cus:LastName is a hot field or requires assignment from browse
  BRW1.AddField(Cus:Street,BRW1.Q.Cus:Street)              ! Field Cus:Street is a hot field or requires assignment from browse
  BRW1.AddField(Cus:City,BRW1.Q.Cus:City)                  ! Field Cus:City is a hot field or requires assignment from browse
  BRW1.AddField(Cus:State,BRW1.Q.Cus:State)                ! Field Cus:State is a hot field or requires assignment from browse
  BRW1.AddField(Cus:PostalCode,BRW1.Q.Cus:PostalCode)      ! Field Cus:PostalCode is a hot field or requires assignment from browse
  BRW1.AddField(Cus:Phone,BRW1.Q.Cus:Phone)                ! Field Cus:Phone is a hot field or requires assignment from browse
  BRW1.AddField(Cus:MobilePhone,BRW1.Q.Cus:MobilePhone)    ! Field Cus:MobilePhone is a hot field or requires assignment from browse
  BRW1.AddField(Cus:Email,BRW1.Q.Cus:Email)                ! Field Cus:Email is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseCustomer',QuickWindow)               ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateCustomer
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


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:3
    SELF.ChangeControl=?Change:3
    SELF.DeleteControl=?Delete:3
  END
  SELF.ViewControl = ?View:2                               ! Setup the control used to initiate view only mode


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
!!! Browse the Configuration file
!!! </summary>
BrowseConfiguration PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(Configuration)
                       PROJECT(Cfg:GUID)
                       PROJECT(Cfg:CompanyName)
                       PROJECT(Cfg:Street)
                       PROJECT(Cfg:City)
                       PROJECT(Cfg:State)
                       PROJECT(Cfg:PostalCode)
                       PROJECT(Cfg:Phone)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Cfg:GUID               LIKE(Cfg:GUID)                 !List box control field - type derived from field
Cfg:CompanyName        LIKE(Cfg:CompanyName)          !List box control field - type derived from field
Cfg:Street             LIKE(Cfg:Street)               !List box control field - type derived from field
Cfg:City               LIKE(Cfg:City)                 !List box control field - type derived from field
Cfg:State              LIKE(Cfg:State)                !List box control field - type derived from field
Cfg:PostalCode         LIKE(Cfg:PostalCode)           !List box control field - type derived from field
Cfg:Phone              LIKE(Cfg:Phone)                !List box control field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the Configuration file'),AT(,,358,198),FONT('Segoe UI',9,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('BrowseConfiguration'),SYSTEM
                       LIST,AT(8,22,342,149),USE(?Browse:1),HVSCROLL,FORMAT('43L(2)|M~GUID~@s16@80L(2)|M~Compa' & |
  'ny Name~@s100@80L(2)|M~Street~@s255@80L(2)|M~City~@s100@80L(2)|M~State~@s100@80L(2)|' & |
  'M~Postal Code~@s100@80L(2)|M~Phone#~@s100@'),FROM(Queue:Browse:1),IMM,MSG('Browsing t' & |
  'he Configuration file')
                       BUTTON('&View'),AT(4,180,49,14),USE(?View:2),LEFT,ICON('WAVIEW.ICO'),FLAT,MSG('View Record'), |
  TIP('View Record')
                       BUTTON('&Insert'),AT(57,180,49,14),USE(?Insert:3),LEFT,ICON('WAINSERT.ICO'),FLAT,MSG('Insert a Record'), |
  TIP('Insert a Record')
                       BUTTON('&Change'),AT(110,180,49,14),USE(?Change:3),LEFT,ICON('WACHANGE.ICO'),DEFAULT,FLAT, |
  MSG('Change the Record'),TIP('Change the Record')
                       BUTTON('&Delete'),AT(163,180,49,14),USE(?Delete:3),LEFT,ICON('WADELETE.ICO'),FLAT,MSG('Delete the Record'), |
  TIP('Delete the Record')
                       SHEET,AT(4,4,350,172),USE(?CurrentTab)
                         TAB('&GuidKey'),USE(?Tab:2)
                         END
                       END
                       BUTTON('&Close'),AT(305,180,49,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
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

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('BrowseConfiguration')
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
  Relate:Configuration.Open()                              ! File Configuration used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Configuration,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,Cfg:GuidKey)                          ! Add the sort order for Cfg:GuidKey for sort order 1
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort0:Locator.Init(,Cfg:GUID,1,BRW1)               ! Initialize the browse locator using  using key: Cfg:GuidKey , Cfg:GUID
  BRW1.AddField(Cfg:GUID,BRW1.Q.Cfg:GUID)                  ! Field Cfg:GUID is a hot field or requires assignment from browse
  BRW1.AddField(Cfg:CompanyName,BRW1.Q.Cfg:CompanyName)    ! Field Cfg:CompanyName is a hot field or requires assignment from browse
  BRW1.AddField(Cfg:Street,BRW1.Q.Cfg:Street)              ! Field Cfg:Street is a hot field or requires assignment from browse
  BRW1.AddField(Cfg:City,BRW1.Q.Cfg:City)                  ! Field Cfg:City is a hot field or requires assignment from browse
  BRW1.AddField(Cfg:State,BRW1.Q.Cfg:State)                ! Field Cfg:State is a hot field or requires assignment from browse
  BRW1.AddField(Cfg:PostalCode,BRW1.Q.Cfg:PostalCode)      ! Field Cfg:PostalCode is a hot field or requires assignment from browse
  BRW1.AddField(Cfg:Phone,BRW1.Q.Cfg:Phone)                ! Field Cfg:Phone is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseConfiguration',QuickWindow)          ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateConfiguration
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
    INIMgr.Update('BrowseConfiguration',QuickWindow)       ! Save window data to non-volatile store
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
    UpdateConfiguration
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:3
    SELF.ChangeControl=?Change:3
    SELF.DeleteControl=?Delete:3
  END
  SELF.ViewControl = ?View:2                               ! Setup the control used to initiate view only mode


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
MakeGUID             PROCEDURE                             ! Declare Procedure
Alphabet               STRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')
X                      LONG
Guid                   STRING(16)        

  CODE
  LOOP X = 1 TO SIZE(Guid)
    Guid[X] = Alphabet[RANDOM(1, SIZE(Alphabet))]
  END
  !Guid=Guid[1:8] & '----------------'       !Cause more DUPs
  RETURN Guid
    
