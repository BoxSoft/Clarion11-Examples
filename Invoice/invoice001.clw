

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE001.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('INVOICE002.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('INVOICE003.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('INVOICE004.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('INVOICE005.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('INVOICE006.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('INVOICE007.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('INVOICE008.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('INVOICE009.INC'),ONCE        !Req'd for module callout resolution
                       INCLUDE('INVOICE010.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Frame
!!! </summary>
Main PROCEDURE 

SQLOpenWindow        WINDOW('Initializing Database'),AT(,,208,26),FONT('Microsoft Sans Serif',8,,FONT:regular),CENTER,GRAY,DOUBLE
                       STRING('This process could take several seconds.'),AT(27,12)
                       IMAGE(Icon:Connect),AT(4,4,23,17)
                       STRING('Please wait while the program connects to the database.'),AT(27,3)
                     END

AppFrame             APPLICATION('Invoice Example'),AT(,,505,318),FONT('Segoe UI',10,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  RESIZE,TILED,CENTER,ICON('Application.ico'),MAX,SYSTEM,WALLPAPER('White.png'),IMM
                       TOOLBAR,AT(0,0,505,63),USE(?Toolbar),COLOR(COLOR:White)
                         SHEET,AT(0,0),USE(?Sheet),FULL
                           TAB('File'),USE(?Tab:File)
                             BUTTON('Exit'),AT(1,14,46,46),USE(?Button:File:Exit),ICON('Exit.ico'),FLAT,STD(STD:Close)
                             BUTTON('Print Setup'),AT(51,14,46,46),USE(?Button:File:PrintSetup),ICON('PrintSetup.ico'), |
  FLAT,STD(STD:PrintSetup)
                           END
                           TAB('Browse'),USE(?Tab:Browse)
                             BUTTON('Invoices'),AT(1,14,46,46),USE(?Button:Browse:Invoice),ICON('Invoice.ico'),FLAT
                             BUTTON('Customers'),AT(51,14,46,46),USE(?Button:Browse:Customer),ICON('Customer.ico'),FLAT
                             BUTTON('Customer Companies'),AT(101,14,46,46),USE(?Button:Browse:CustomerCompany),ICON('Company.ico'), |
  FLAT
                             BUTTON('Products'),AT(151,14,46,46),USE(?Button:Browse:Product),FONT(,,,FONT:regular),ICON('Product.ico'), |
  FLAT
                           END
                           TAB('Report'),USE(?Tab:Report)
                             BUTTON('Invoices'),AT(1,14,46,46),USE(?Button:Report:Invoice),ICON('Invoice.ico'),FLAT
                             BUTTON('Customers'),AT(51,14,46,46),USE(?Button:Report:Customer),ICON('Customer.ico'),FLAT
                             BUTTON('Customer Companies'),AT(101,14,46,46),USE(?Button:Report:CustomerCompany),ICON('Company.ico'), |
  FLAT
                             BUTTON('Products'),AT(151,14,46,46),USE(?Button:Report:Product),FONT(,,,FONT:regular),ICON('Product.ico'), |
  FLAT
                           END
                           TAB('Settings'),USE(?Tab:Settings)
                             BUTTON('Setup'),AT(1,14,46,46),USE(?Button:Settings:Configuration),ICON('Settings.ico'),FLAT
                           END
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

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('Main')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = 1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
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
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  Do DefineListboxStyle
  INIMgr.Fetch('Main',AppFrame)                            ! Restore window settings from non-volatile store
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
    INIMgr.Update('Main',AppFrame)                         ! Save window data to non-volatile store
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
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?Button:Browse:Invoice
      START(BrowseInvoice, 25000)
    OF ?Button:Browse:Customer
      START(BrowseCustomer, 25000)
    OF ?Button:Browse:CustomerCompany
      START(BrowseCustomerCompany, 25000)
    OF ?Button:Browse:Product
      START(BrowseProduct, 25000)
    OF ?Button:Report:Invoice
      START(ReportInvoiceByInv:DateKey, 25000)
    OF ?Button:Report:Customer
      START(ReportCustomerByCus:LastFirstNameKey, 25000)
    OF ?Button:Report:CustomerCompany
      START(ReportCustomerCompanyByCusCom:CompanyNameKey, 25000)
    OF ?Button:Report:Product
      START(ReportProductByPro:ProductCodeKey, 25000)
    OF ?Button:Settings:Configuration
      START(BrowseConfiguration, 25000)
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue

