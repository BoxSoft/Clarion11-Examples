

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABREPORT.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE009.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Report
!!! Print the Customer File by Cus:LastFirstNameKey
!!! </summary>
ReportCustomerByCus:LastFirstNameKey PROCEDURE 

Progress:Thermometer BYTE                                  ! 
FullName             STRING(255)                           ! 
Process:View         VIEW(Customer)
                       PROJECT(Cus:City)
                       PROJECT(Cus:Email)
                       PROJECT(Cus:FirstName)
                       PROJECT(Cus:LastName)
                       PROJECT(Cus:MobilePhone)
                       PROJECT(Cus:Phone)
                       PROJECT(Cus:State)
                       PROJECT(Cus:CompanyGuid)
                       JOIN(CusCom:GuidKey,Cus:CompanyGuid)
                         PROJECT(CusCom:CompanyName)
                       END
                     END
ProgressWindow       WINDOW('Customers'),AT(,,250,61),FONT('Segoe UI',10,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  DOUBLE,CENTER,GRAY,TIMER(1)
                       PROGRESS,AT(15,15,220,15),USE(Progress:Thermometer),RANGE(0,100)
                       STRING(''),AT(2,3,247),USE(?Progress:UserString),CENTER
                       STRING(''),AT(2,30,247),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(101,42,49,15),USE(?Progress:Cancel)
                     END

Report               REPORT('Customer Report'),AT(250,1000,11000,8250),PRE(RPT),PAPER(PAPER:A4),LANDSCAPE,FONT('Segoe UI', |
  10,COLOR:Black,FONT:regular,CHARSET:DEFAULT),THOUS
                       HEADER,AT(250,250,10500,740),USE(?Header)
                         IMAGE('logo.png'),AT(0,0,400,400),USE(?IMAGE1)
                         STRING('Customers'),AT(0,9,10448),USE(?ReportTitle),FONT(,14,00701919h,FONT:regular),CENTER, |
  TRN
                         STRING('<<-- Date Stamp -->'),AT(9521,31,927),USE(?ReportDateStamp:2),FONT(,,00404040h),RIGHT(30), |
  TRN
                         STRING('<<-- Time Stamp -->'),AT(9521,260,927),USE(?ReportTimeStamp),FONT(,,00404040h),RIGHT(30), |
  TRN
                         STRING('Company'),AT(2115,500),USE(?STRING1),FONT(,12,00701919h,FONT:regular),TRN
                         STRING('Name'),AT(52,500),USE(?STRING2),FONT(,12,00701919h,FONT:regular),TRN
                         STRING('City'),AT(7302,500),USE(?STRING3),FONT(,12,00701919h,FONT:regular),TRN
                         STRING('State'),AT(8865,500),USE(?STRING4),FONT(,12,00701919h,FONT:regular),TRN
                         STRING('Phone/Mobile'),AT(3677,500),USE(?STRING5),FONT(,12,00701919h,FONT:regular),TRN
                         STRING('Email'),AT(5240,500),USE(?STRING6),FONT(,12,00701919h,FONT:regular),TRN
                       END
Detail                 DETAIL,AT(0,0,10500),USE(?Detail)
                         LINE,AT(0,104,10500,0),USE(?LINE2),COLOR(00EFEFEFh)
                         TEXT,AT(52,140,2000),USE(FullName),TRN
                         STRING(@s100),AT(2115,140,1500,170),USE(CusCom:CompanyName)
                         STRING(@s100),AT(7302,140,1500,170),USE(Cus:City)
                         STRING(@s100),AT(8865,140,1583,170),USE(Cus:State)
                         STRING(@s100),AT(3677,140,1500,170),USE(Cus:Phone)
                         STRING(@s100),AT(3677,360,1500,170),USE(Cus:MobilePhone)
                         STRING(@s100),AT(5240,140,2000,170),USE(Cus:Email)
                       END
                       FOOTER,AT(250,7750,10500,250),USE(?Footer)
                         STRING(@pPage <<#p),AT(9750,10,700),USE(?PageCount:2),FONT(,,00404040h),PAGENO
                       END
                     END
ThisWindow           CLASS(ReportManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
OpenReport             PROCEDURE(),BYTE,PROC,DERIVED
                     END

ThisReport           CLASS(ProcessClass)                   ! Process Manager
TakeRecord             PROCEDURE(),BYTE,PROC,DERIVED
                     END

ProgressMgr          StepStringClass                       ! Progress Manager
Previewer            PrintPreviewClass                     ! Print Previewer

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
  GlobalErrors.SetProcedureName('ReportCustomerByCus:LastFirstNameKey')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Progress:Thermometer
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  Relate:Customer.Open()                                   ! File Customer used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Open(ProgressWindow)                                ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  Do DefineListboxStyle
  INIMgr.Fetch('ReportCustomerByCus:LastFirstNameKey',ProgressWindow) ! Restore window settings from non-volatile store
  ProgressMgr.Init(ScrollSort:AllowAlpha+ScrollSort:AllowNumeric,ScrollBy:RunTime)
  ThisReport.Init(Process:View, Relate:Customer, ?Progress:PctText, Progress:Thermometer, ProgressMgr, Cus:LastName)
  ThisReport.CaseSensitiveValue = FALSE
  ThisReport.AddSortOrder(Cus:LastFirstNameKey)
  SELF.AddItem(?Progress:Cancel,RequestCancelled)
  SELF.Init(ThisReport,Report,Previewer)
  ?Progress:UserString{PROP:Text} = ''
  Relate:Customer.SetQuickScan(1,Propagate:OneMany)
  ProgressWindow{PROP:Timer} = 10                          ! Assign timer interval
  SELF.SkipPreview = False
  Previewer.SetINIManager(INIMgr)
  Previewer.AllowUserZoom = True
  Previewer.Maximize = True
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
    INIMgr.Update('ReportCustomerByCus:LastFirstNameKey',ProgressWindow) ! Save window data to non-volatile store
  END
  ProgressMgr.Kill()
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.OpenReport PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.OpenReport()
  IF ReturnValue = Level:Benign
    SELF.Report $ ?ReportDateStamp:2{PROP:Text} = FORMAT(TODAY(),@D17)
  END
  IF ReturnValue = Level:Benign
    SELF.Report $ ?ReportTimeStamp{PROP:Text} = FORMAT(CLOCK(),@T7)
  END
  RETURN ReturnValue


ThisReport.TakeRecord PROCEDURE

ReturnValue          BYTE,AUTO

SkipDetails BYTE
  CODE
  ReturnValue = PARENT.TakeRecord()
  FullName = LEFT(CLIP(Cus:LastName) & CHOOSE(~Cus:FirstName, '', ', '& Cus:FirstName))
  PRINT(RPT:Detail)
  RETURN ReturnValue

