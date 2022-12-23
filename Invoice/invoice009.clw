

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
Process:View         VIEW(Customer)
                       PROJECT(Cus:City)
                       PROJECT(Cus:CompanyGuid)
                       PROJECT(Cus:Email)
                       PROJECT(Cus:FirstName)
                       PROJECT(Cus:LastName)
                       PROJECT(Cus:MobilePhone)
                       PROJECT(Cus:Phone)
                       PROJECT(Cus:PostalCode)
                       PROJECT(Cus:State)
                       PROJECT(Cus:Street)
                     END
ProgressWindow       WINDOW('Report Customer'),AT(,,142,59),FONT('Segoe UI',10,COLOR:Black,FONT:regular,CHARSET:DEFAULT), |
  DOUBLE,CENTER,GRAY,TIMER(1)
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,100)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel Report'), |
  TIP('Cancel Report')
                     END

Report               REPORT('Customer Report'),AT(250,1190,8000,9310),PRE(RPT),PAPER(PAPER:LETTER),FONT('Segoe UI', |
  10,COLOR:Black,FONT:regular,CHARSET:DEFAULT),THOUS
                       HEADER,AT(250,250,8000,940),USE(?Header),FONT('Microsoft Sans Serif',8,,FONT:regular,CHARSET:DEFAULT)
                         STRING('Report Customer file'),AT(0,20,8000,220),USE(?ReportTitle),FONT('Segoe UI',12,COLOR:Black, |
  FONT:regular,CHARSET:DEFAULT),CENTER
                         BOX,AT(0,350,8000,610),USE(?HeaderBox),COLOR(COLOR:Black)
                         LINE,AT(2000,350,0,610),USE(?HeaderLine:1),COLOR(COLOR:Black)
                         LINE,AT(4000,350,0,610),USE(?HeaderLine:2),COLOR(COLOR:Black)
                         LINE,AT(6000,350,0,610),USE(?HeaderLine:3),COLOR(COLOR:Black)
                         STRING('Company Guid'),AT(50,390,1900,170),USE(?HeaderTitle:1),TRN
                         STRING('First Name'),AT(2050,390,1900,170),USE(?HeaderTitle:2),TRN
                         STRING('Last Name'),AT(4050,390,1900,170),USE(?HeaderTitle:3),TRN
                         STRING('Street'),AT(6050,390,1900,170),USE(?HeaderTitle:4),TRN
                         STRING('City'),AT(50,570,1900,170),USE(?HeaderTitle:5),TRN
                         STRING('State'),AT(2050,570,1900,170),USE(?HeaderTitle:6),TRN
                         STRING('Postal Code'),AT(4050,570,1900,170),USE(?HeaderTitle:7),TRN
                         STRING('Phone#'),AT(6050,570,1900,170),USE(?HeaderTitle:8),TRN
                         STRING('Phone#'),AT(50,750,1900,170),USE(?HeaderTitle:9),TRN
                         STRING('Email'),AT(2050,750,1900,170),USE(?HeaderTitle:10),TRN
                       END
Detail                 DETAIL,AT(0,0,8000,750),USE(?Detail)
                         LINE,AT(0,0,0,750),USE(?DetailLine:0),COLOR(COLOR:Black)
                         LINE,AT(2000,0,0,750),USE(?DetailLine:1),COLOR(COLOR:Black)
                         LINE,AT(4000,0,0,750),USE(?DetailLine:2),COLOR(COLOR:Black)
                         LINE,AT(6000,0,0,750),USE(?DetailLine:3),COLOR(COLOR:Black)
                         LINE,AT(8000,0,0,750),USE(?DetailLine:4),COLOR(COLOR:Black)
                         STRING(@s16),AT(50,50,1900,170),USE(Cus:CompanyGuid)
                         STRING(@s100),AT(2050,50,1900,170),USE(Cus:FirstName)
                         STRING(@s100),AT(4050,50,1900,170),USE(Cus:LastName)
                         STRING(@s255),AT(6050,50,1900,170),USE(Cus:Street)
                         STRING(@s100),AT(50,230,1900,170),USE(Cus:City)
                         STRING(@s100),AT(2050,230,1900,170),USE(Cus:State)
                         STRING(@s100),AT(4050,230,1900,170),USE(Cus:PostalCode)
                         STRING(@s100),AT(6050,230,1900,170),USE(Cus:Phone)
                         STRING(@s100),AT(50,410,1900,170),USE(Cus:MobilePhone)
                         STRING(@s100),AT(2050,410,1900,170),USE(Cus:Email)
                         LINE,AT(0,750,8000,0),USE(?DetailEndLine),COLOR(COLOR:Black)
                       END
                       FOOTER,AT(250,10500,8000,250),USE(?Footer)
                         STRING('Date:'),AT(115,52,344,135),USE(?ReportDatePrompt:2),FONT('Arial',8,,FONT:regular), |
  TRN
                         STRING('<<-- Date Stamp -->'),AT(490,52,927,135),USE(?ReportDateStamp:2),FONT('Arial',8,,FONT:regular), |
  TRN
                         STRING('Time:'),AT(1625,52,271,135),USE(?ReportTimePrompt:2),FONT('Arial',8,,FONT:regular), |
  TRN
                         STRING('<<-- Time Stamp -->'),AT(1927,52,927,135),USE(?ReportTimeStamp:2),FONT('Arial',8,, |
  FONT:regular),TRN
                         STRING(@pPage <<#p),AT(6950,52,700,135),USE(?PageCount:2),FONT('Arial',8,,FONT:regular),PAGENO
                       END
                       FORM,AT(250,250,8000,10500),USE(?Form),FONT('Segoe UI',10,COLOR:Black,FONT:regular,CHARSET:DEFAULT)
                         IMAGE,AT(0,0,8000,10500),USE(?FormImage),TILED
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
  ProgressWindow{PROP:Timer} = 10                          ! Assign timer interval
  ProgressMgr.Init(ScrollSort:AllowAlpha+ScrollSort:AllowNumeric,ScrollBy:RunTime)
  ThisReport.Init(Process:View, Relate:Customer, ?Progress:PctText, Progress:Thermometer, ProgressMgr, Cus:LastName)
  ThisReport.CaseSensitiveValue = FALSE
  ThisReport.AddSortOrder(Cus:LastFirstNameKey)
  SELF.AddItem(?Progress:Cancel,RequestCancelled)
  SELF.Init(ThisReport,Report,Previewer)
  ?Progress:UserString{PROP:Text} = ''
  Relate:Customer.SetQuickScan(1,Propagate:OneMany)
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
    SELF.Report $ ?ReportTimeStamp:2{PROP:Text} = FORMAT(CLOCK(),@T7)
  END
  RETURN ReturnValue


ThisReport.TakeRecord PROCEDURE

ReturnValue          BYTE,AUTO

SkipDetails BYTE
  CODE
  ReturnValue = PARENT.TakeRecord()
  PRINT(RPT:Detail)
  RETURN ReturnValue

