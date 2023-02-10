

   MEMBER('TestInvDev.clw')                                ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABREPORT.INC'),ONCE

                     MAP
                       INCLUDE('TESTINVDEV003.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Source
!!! Generate some CustomerCompany ecords to test having a lot in the file
!!! </summary>
TestGenerate_CustomerCompany PROCEDURE                     ! Declare Procedure
RecordsBefore    LONG
RecordsAfter    LONG
ToDoRecords     LONG
RecordNo        LONG

UniqueName      LONG

Clock1  LONG     
Clock2  LONG     

 
Progress:Thermometer    LONG 
Progress:New            LONG
RecordsPerCycle         LONG
ProgressFACTOR          REAL 
ProgressWindow       WINDOW('Add Test CustomerCompany'),AT(,,142,59),FONT('Segoe UI',9,,FONT:regular),DOUBLE,CENTER,GRAY,MDI 
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,25)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),SKIP
                     END
FilesOpened     BYTE(0)

  CODE
? DEBUGHOOK(CustomerCompany:Record)
    DO OpenFiles
    RecordsBefore = RECORDS(CustomerCompany)
    UniqueName = RecordsBefore +1
    GET(CustomerCompany,0)

    EXECUTE Message('How many Test CustomerCompany records to generate?' & |
                    '||File has ' & Records(CustomerCompany) &' now.' & |
                    '||FYI Duplicate(File)=' & Duplicate(CustomerCompany) &' ? Bug always =True' & |
                    '|Also seems with SQLite driver calling DUPLICATE() clears the Error()' & |
                    '','Test Data',,'Cancel|10|100|1000|5000|10,000')
        ToDoRecords = 0 
        ToDoRecords = 10
        ToDoRecords = 100
        ToDoRecords = 1000
        ToDoRecords = 5000
        ToDoRecords = 10000
    END 

    IF ~ToDoRecords THEN 
        DO CloseFiles 
        RETURN 
    END 

    OPEN(ProgressWindow)
    DISPLAY
    ?Progress:UserString{PROP:Text}='Add ' &  ToDoRecords    
    ProgressFACTOR = ?Progress:Thermometer{PROP:RangeHigh} / ToDoRecords
    
    RandomizeRandoms()
    
    DO AddTestDataRtn
    RecordsAfter = RECORDS(CustomerCompany)
    Progress:Thermometer=100 ; DISPLAY
    
    DO CloseFiles 
    Message('TestGenerateCompanies ||ToDo Records = ' & ToDoRecords & |
               '||Records Before = '& RecordsBefore & |
               '|Records After = '& RecordsAfter & |
               '|Change = '& RecordsAfter - RecordsBefore & |  
               '||Time Taken: ' & (Clock2 -Clock1) / 100 & |
               '','Test Data')            
    
    RETURN
AddTestDataRtn ROUTINE
    DATA
TransxAdd  BOOL 
    CODE
    TransxAdd = Message('How to Add','Add Customers',,'Normal|Transaction') - 1

    Clock1 = CLOCK() 

    ?Progress:UserString{PROP:Text}='Add ' &  ToDoRecords    
    ProgressFACTOR = ?Progress:Thermometer{PROP:RangeHigh} / ToDoRecords
    RecordsPerCycle = 25
    IF TransxAdd THEN 
       RecordsPerCycle = 1000           !This is SO Fast can add a lot 
       LOGOUT(1,CustomerCompany)
    END 
    0{PROP:Timer}=1
AL: ACCEPT
       CASE EVENT()
       OF EVENT:Timer
            LOOP RecordsPerCycle TIMES
                 IF RecordNo >= ToDoRecords THEN BREAK AL: .
                 RecordNo += 1
                 DO AddOneRtn
            END 

            Progress:New = RecordNo * ProgressFACTOR
            IF Progress:Thermometer < Progress:New THEN 
               CHANGE(?Progress:Thermometer,Progress:New) 
               ?Progress:PctText{PROP:Text}=RecordNo &' done'
            END 

       ELSE             
          IF ACCEPTED() = ?Progress:Cancel THEN 
             IF Message('Cancel Process?','Add Test Data',ICON:Cross, |
                        'Cancel|Continue',2)=1 THEN BREAK.
          END 
       END !Case Event 
    END  !Accept      
    0{PROP:Timer}=0  
    
    IF TransxAdd THEN 
       COMMIT()
       IF ERRORCODE() THEN 
          MESSAGE('COMMIT failed ' & Err4Msg(),'Commit Company')
       END 
    END 

    Clock2 = CLOCK() 
    EXIT

AddOneRtn ROUTINE
    GET(CustomerCompany,0)
    CLEAR(CustomerCompany)
    CusCom:GUID = MakeGUID()
    CusCom:CompanyName  = TestDataLorem( RANDOM(20,40) ) &' '& TestDataWord() ! UniqueName ; UniqueName += 1  
    TestDataAddress(CusCom:Street,CusCom:City,CusCom:State,CusCom:PostalCode) 
    CusCom:Phone        = TestDataPhone() 
    
    IF False |                                      !seem to alwasy have DUP()=1
    AND DUPLICATE(CustomerCompany) THEN 
       CASE Message('AddOneRtn ADD(CustomerCompany) DUPLICATE(CustomerCompany) '&  |
            '<13,10>RecordNo=' & RecordNo & |
            '<13,10>CusCom:GUID=' & CusCom:GUID & |
            '<13,10>CusCom:CompanyName=' & CusCom:CompanyName & |
            '<13,10>DUPLICATE(CustomerCompany)=' & DUPLICATE(CustomerCompany) & |
            '<13,10>DUPLICATE(CusCom:GuidKey)=' & DUPLICATE(CusCom:GuidKey) & |
            '<13,10>DUPLICATE(CusCom:CompanyNameKey)=' & DUPLICATE(CusCom:CompanyNameKey) & |
            '','AddOne',,'Skip Add|Abort All Adds|Add Anyway')
       OF 1 ; EXIT             
       OF 2 ; RecordNo=1 + ToDoRecords ; EXIT 
       OF 3 
       END 
    END
    
    ADD(CustomerCompany)
    IF ERRORCODE() THEN
!FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
!FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
!FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
       CASE Message('AddOneRtn ADD(CustomerCompany) '& Err4Msg() & |
            '<13,10>={40}' & |
            '<13,10>RecordNo=' & RecordNo & |
            '<13,10>CusCom:GUID=' & CusCom:GUID & |
            '<13,10>CusCom:CompanyName=' & CusCom:CompanyName & |
            '<13,10><13,10>DUPLICATE(CustomerCompany)=' & DUPLICATE(CustomerCompany) & |
            '<13,10>DUPLICATE(CusCom:GuidKey)=' & DUPLICATE(CusCom:GuidKey) & |
            '<13,10>DUPLICATE(CusCom:CompanyNameKey)=' & DUPLICATE(CusCom:CompanyNameKey) & |
            '<13,10>Error() again at Bottom: ' & ErrorCode()&' '& Error() & |
            '','AddOne Error',,'Continue|Abort All Adds')
       OF 1              
       OF 2 ; RecordNo=1 + ToDoRecords ; EXIT 
       END 

       GET(CustomerCompany,CusCom:GuidKey)      !Is it a GUID duplicate?
       IF ~ERRORCODE() THEN
           Message('Last ADD(CustomerCompany) was GUID duplicate! '&  |
            '<13,10>Found below GUID already in the File!' & |
            '<13,10>CusCom:GUID=' & CusCom:GUID & |
            '<13,10>CusCom:CompanyName=' & CusCom:CompanyName & |
            '','AddOneRtn')  
       ELSE 
           GET(CustomerCompany,CusCom:CompanyNameKey)      !Is it a GUID duplicate?
           IF ~ERRORCODE() THEN
               Message('Last ADD(CustomerCompany) was CompanyNameKey duplicate! '&  |
                '<13,10>Found below CompanyNameKey already in the File!' & |
                '<13,10>CusCom:CompanyName=' & CusCom:CompanyName & |
                '<13,10>CusCom:GUID=' & CusCom:GUID & |                
                '','AddOneRtn')  
           END 
       END 
    END 
    EXIT

    OMIT('**END**')
CustomerCompany      FILE,DRIVER('SQLite'),OWNER(Glo:Owner),NAME('CustomerCompany'),PRE(CusCom),BINDABLE,CREATE,THREAD ! Default company information
CusCom:GuidKey                  KEY(CusCom:GUID),NAME('CustomerCompany_GuidKey'),NOCASE,PRIMARY !                     
CusCom:CompanyNameKey           KEY(CusCom:CompanyName),NAME('CustomerCompany_CompanyNameKey'),NOCASE !                     
CusCom:Record                   RECORD,PRE()
CusCom:GUID                        STRING(16)                     !                     
CusCom:CompanyName                 STRING(100)                    !                     
CusCom:Street                      STRING(255)                    !                     
CusCom:City                        STRING(100)                    !                     
CusCom:State                       STRING(100)                    !                     
CusCom:PostalCode                  STRING(100)                    !                     
CusCom:Phone                       STRING(100)                    !                     
                         END
                     END   
    !end of OMIT('**END**')
!--------------------------------------
OpenFiles  ROUTINE
  Access:CustomerCompany.Open()                            ! Open File referenced in 'Other Files' so need to inform it's FileManager
  Access:CustomerCompany.UseFile()                         ! Use File referenced in 'Other Files' so need to inform it's FileManager
  FilesOpened = True
!--------------------------------------
CloseFiles ROUTINE
  IF FilesOpened THEN
     Access:CustomerCompany.Close()
     FilesOpened = False
  END
!!! <summary>
!!! Generated from procedure template - Process
!!! Process the CustomerCompany File
!!! </summary>
DeleteAll_CustomerCompany PROCEDURE 

Progress:Thermometer BYTE                                  ! 
Process:View         VIEW(CustomerCompany)
                     END
ProgressWindow       WINDOW('Delete All CustomerCompany'),AT(,,142,59),FONT('Microsoft Sans Serif',8,,FONT:regular, |
  CHARSET:DEFAULT),DOUBLE,CENTER,GRAY,TIMER(1)
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,100)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel Process'), |
  TIP('Cancel Process')
                     END

ThisWindow           CLASS(ReportManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
                     END

ThisProcess          CLASS(ProcessClass)                   ! Process Manager
TakeRecord             PROCEDURE(),BYTE,PROC,DERIVED
                     END

ProgressMgr          StepClass                             ! Progress Manager

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
  GlobalErrors.SetProcedureName('DeleteAll_CustomerCompany')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Progress:Thermometer
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  Relate:CustomerCompany.Open()                            ! File CustomerCompany used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Open(ProgressWindow)                                ! Open window
  ProgressWindow{Prop:MDI} = True                          ! Make progress window an MDI child window
  Access:CustomerCompany.UseFile()
  CASE Message('Delete ALL ' & Records(CustomerCompany) & ' Customer Company records?','Delete All?',,'Delete All|No Keep')
  OF 2 ; ThisWindow.Kill() ; RETURN Level:Notify
  END     
  
  
      LOCK(CustomerCompany)             !SQLite in Help says this does NOT work, but it did in 11.1
      IF ~ERRORCODE() THEN 
          EMPTY(CustomerCompany)     
          UNLOCK(CustomerCompany)
      END
      IF ~Records(CustomerCompany) THEN RETURN Level:Notify .   
  Do DefineListboxStyle
  ProgressWindow{Prop:Timer} = 10                          ! Assign timer interval
  ThisProcess.Init(Process:View, Relate:CustomerCompany, ?Progress:PctText, Progress:Thermometer)
  ThisProcess.AddSortOrder()
  ProgressWindow{Prop:Text} = 'Processing Records'
  ?Progress:PctText{Prop:Text} = '0% Completed'
  SELF.Init(ThisProcess)
  SELF.SetUseMRP(False)
  ?Progress:UserString{Prop:Text}=''
  SELF.AddItem(?Progress:Cancel, RequestCancelled)
  SEND(CustomerCompany,'QUICKSCAN=on')
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
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisProcess.TakeRecord PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.TakeRecord()
  DELETE(Process:View)
  IF ERRORCODE()
    GlobalErrors.ThrowFile(Msg:DeleteFailed,'Process:View')
    ThisWindow.Response = RequestCompleted
    ReturnValue = Level:Fatal
  END
  RETURN ReturnValue

!!! <summary>
!!! Generated from procedure template - Source
!!! Generate Test Data for Customer - TODO Test Transaction and Timing ?
!!! </summary>
TestGenerate_CustomerFile PROCEDURE                        ! Declare Procedure
RecordsBefore    LONG
RecordsAfter    LONG
ToDoRecords     LONG
RecordNo        LONG

UniqueName      LONG 
UniqueCustNumber  LONG    !for Cus:CustomerNumberKey        KEY(Cus:CustomerNumber),NOCASE    
!CompanyQ  QUEUE,PRE(CompQ)      !To randomly assing
!GUID        LIKE(CusCom:GUID)
!          END
Progress:Thermometer    LONG 
Progress:New            LONG 
ProgressFACTOR           REAL 
ProgressWindow       WINDOW('Add Test Customer'),AT(,,142,59),FONT('Segoe UI',9,,FONT:regular),DOUBLE,CENTER,GRAY,MDI 
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,100)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),SKIP
                     END
CompanyQ             QUEUE,PRE(CompQ)                      ! 
GUID                 LIKE(CusCom:GUID)                     ! 
                     END                                   ! 
FilesOpened     BYTE(0)

  CODE
? DEBUGHOOK(Customer:Record)
? DEBUGHOOK(CustomerCompany:Record)
    SYSTEM{PROP:MsgModeDefault}=MSGMODE:CANCOPY
    DO OpenFiles
    RecordsBefore = RECORDS(Customer)
    UniqueName = RecordsBefore +1
    GET(Customer,0)

    EXECUTE Message('How many Test Customer records to generate?' & |
                    '||File has ' & Records(Customer) &' now.' & |
                    '||FYI Duplicate(File)=' & Duplicate(Customer) &' ? Bug always =True' & |
                    '|Also seems with SQLite driver calling DUPLICATE() clears the Error()' & |
                    '','Test Data',,'Cancel|10|100|1000|5000|10,000')
        ToDoRecords = 0 
        ToDoRecords = 10
        ToDoRecords = 100
        ToDoRecords = 1000
        ToDoRecords = 5000
        ToDoRecords = 10000
    END 

    IF ~ToDoRecords THEN 
        DO CloseFiles 
        RETURN 
    END 

    DO LoadCompanyQ 
    IF ~RECORDS(CompanyQ) THEN 
        Message('There are Zero CustomerCompany Records','Error')
        DO CloseFiles 
        RETURN        
    END 

    OPEN(ProgressWindow)
    ?Progress:UserString{PROP:Text}='Add ' &  ToDoRecords
    DISPLAY
    ProgressFACTOR = ?Progress:Thermometer{PROP:RangeHigh} / ToDoRecords
    
    RandomizeRandoms()
    
    DO AddTestDataRtn
    RecordsAfter = RECORDS(Customer)
    Progress:Thermometer=100 ; DISPLAY
    
    DO CloseFiles 
    Message('TestGenerateCompanies ||ToDo Records = ' & ToDoRecords & |
               '||Records Before = '& RecordsBefore & |
               '|Records After = '& RecordsAfter & |
               '|Change = '& RecordsAfter - RecordsBefore & |
               '','Test Data')            
    
    RETURN
AddTestDataRtn ROUTINE
!    LOOP RecordNo=1 TO ToDoRecords ; DO AddOneRtn ; END  !Simple Loop appears to hang

    SET(Cus:CustomerNumberKey)      !This Key is Autonumbered by the Templates
    PREVIOUS(Customer)
    UniqueCustNumber = CHOOSE(~ERRORCODE(), Cus:CustomerNumber,110)

    0{PROP:Timer}=10
AL: ACCEPT
       CASE EVENT()
       OF EVENT:Timer
!TODO: What if we add a Transaction?  Should speed up?
!TODO: What if we add a Transaction?  Should speed up?
            LOOP 25 TIMES
                 IF RecordNo >= ToDoRecords THEN BREAK AL: .
                 RecordNo += 1
                 DO AddOneRtn
            END 
            Progress:New = RecordNo * ProgressFACTOR
            IF Progress:Thermometer < Progress:New THEN 
               Progress:Thermometer = Progress:New
               ?Progress:PctText{PROP:Text}=RecordNo &' done'
               DISPLAY
            END 
       ELSE !Other Events            
!Simpe:   IF ACCEPTED() = ?Progress:Cancel THEN BREAK.
          IF ACCEPTED() = ?Progress:Cancel THEN 
             IF Message('Cancel Process?','Add Test Data',ICON:Cross, |
                        'Cancel|Continue',2)=1 THEN BREAK.
          END 
       END
       
    END 
    0{PROP:Timer}='' 
    EXIT

AddOneRtn ROUTINE
    GET(Customer,0)
    CLEAR(Customer)
    Cus:GUID = MakeGUID()
    UniqueCustNumber += 1
    Cus:CustomerNumber = UniqueCustNumber
    GET(CompanyQ,RANDOM(1,RECORDS(CompanyQ)))
    Cus:CompanyGuid = CompQ:GUID
    TestDataFirstLast(Cus:FirstName,Cus:LastName)
    TestDataAddress(Cus:Street,Cus:City,Cus:State,Cus:PostalCode) 
    Cus:Phone        = TestDataPhone() 
    Cus:MobilePhone  = TestDataPhone() 
    Cus:Email = CLIP(Cus:FirstName) &'.'&  CLIP(Cus:LastName) &'@'& |  ! CLIP(SUB(CusCom:CompanyName,1,16)) &'.com' 
                CHOOSE(RANDOM(1,3),'Gmail.con','Yahoo.con','HotMail.con')   !use con not com incase we use this data
    SmashSpaces(Cus:Email)

    ADD(Customer)
    IF ERRORCODE() THEN
!FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
!FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
!FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
       CASE Message('AddOneRtn ADD(Customer) '& Err4Msg() & |
            '<13,10>={40}' & |
            '<13,10>RecordNo=' & RecordNo & |
            '<13,10>Cus:GUID=' & Cus:GUID & |
            '<13,10>Cus:CustomerNumber=' & Cus:CustomerNumber & |
            '<13,10>Cus:FirstName=' & Cus:FirstName & |
            '<13,10>Cus:LastName=' & Cus:LastName & |
            '<13,10>Error() again at Bottom: ' & ErrorCode()&' '& Error() & |
            '','AddOne Error',,'Continue|Abort All Adds')
       OF 1              
       OF 2 ; RecordNo=1 + ToDoRecords ; EXIT 
       END 

       GET(Customer,Cus:GuidKey)      !Is it a GUID duplicate?
       IF ~ERRORCODE() THEN
           Message('Last ADD(Customer) was GUID duplicate! '&  |
            '<13,10>Found below GUID already in the File!' & |
            '<13,10>Cus:GUID=' & Cus:GUID & |
            '<13,10>Cus:FirstName=' & Cus:FirstName & |
            '<13,10>Cus:LastName=' & Cus:LastName & |
            '','AddOneRtn')  
       ELSE 
!           GET(Customer,Cus:CompanyNameKey)      !Is it a GUID duplicate?
!           IF ~ERRORCODE() THEN
!               Message('Last ADD(Customer) was CompanyNameKey duplicate! '&  |
!                '<13,10>Found below CompanyNameKey already in the File!' & |
!                '<13,10>Cus:CompanyName=' & Cus:CompanyName & |
!                '<13,10>Cus:GUID=' & Cus:GUID & |                
!                '','AddOneRtn')  
!           END 
       END 
    END 
    EXIT
LoadCompanyQ ROUTINE    !Load Q so have CusCom:GUID to randomly assing 
    FREE(CompanyQ)
    Access:CustomerCompany.UseFile()
    SET(CustomerCompany)
    LOOP
        NEXT(CustomerCompany)
        IF ERRORCODE() THEN BREAK.
        CompQ:Guid = CusCom:GUID
        ADD(CompanyQ)
    END
    EXIT 


    OMIT('**END**')
Customer             FILE,DRIVER('SQLite'),OWNER(Glo:Owner),NAME('Customer'),PRE(Cus),BINDABLE,CREATE,THREAD ! Customer's Information
Cus:GuidKey                  KEY(Cus:GUID),NAME('Customer_GuidKey'),NOCASE,PRIMARY !                     
Cus:CompanyKey               KEY(Cus:CompanyGuid),DUP,NAME('Customer_CompanyKey'),NOCASE !                     
Cus:CustomerNumberKey        KEY(Cus:CustomerNumber),NOCASE    !                     
Cus:LastFirstNameKey         KEY(Cus:LastName,Cus:FirstName),DUP,NAME('Customer_LastFirstNameKey'),NOCASE !                     
Cus:FirstLastNameKey_Copy    KEY(Cus:FirstName,Cus:LastName),DUP,NAME('Customer_FirstLastNameKey'),NOCASE !                     
Cus:PostalCodeKey            KEY(Cus:PostalCode),DUP,NAME('Customer_PostalCodeKey'),NOCASE !                     
Cus:StateKey                 KEY(Cus:State),DUP,NAME('Customer_StateKey'),NOCASE !                     
Cus:Record                   RECORD,PRE()
Cus:GUID                        STRING(16)                     !                     
Cus:CustomerNumber              LONG                           !                     
Cus:CompanyGuid                 STRING(16)                     !                     
Cus:FirstName                   STRING(100)                    !                     
Cus:LastName                    STRING(100)                    !                     
Cus:Street                      STRING(255)                    !                     
Cus:City                        STRING(100)                    !                     
Cus:State                       STRING(100)                    !                     
Cus:PostalCode                  STRING(100)                    !                     
Cus:Phone                       STRING(100)                    !                     
Cus:MobilePhone                 STRING(100)                    !                     
Cus:Email                       STRING(100)                    !                     
                         END
    !end of OMIT('**END**')
    
    OMIT('**END**')
CustomerCompany      FILE,DRIVER('SQLite'),OWNER(Glo:Owner),NAME('CustomerCompany'),PRE(CusCom),BINDABLE,CREATE,THREAD ! Default company information
CusCom:GuidKey                  KEY(CusCom:GUID),NAME('CustomerCompany_GuidKey'),NOCASE,PRIMARY !                     
CusCom:CompanyNameKey           KEY(CusCom:CompanyName),NAME('CustomerCompany_CompanyNameKey'),NOCASE !                     
CusCom:Record                   RECORD,PRE()
CusCom:GUID                        STRING(16)                     !                     
CusCom:CompanyName                 STRING(100)                    !                     
CusCom:Street                      STRING(255)                    !                     
CusCom:City                        STRING(100)                    !                     
CusCom:State                       STRING(100)                    !                     
CusCom:PostalCode                  STRING(100)                    !                     
CusCom:Phone                       STRING(100)                    !                     
                         END
                     END   
    !end of OMIT('**END**')
!--------------------------------------
OpenFiles  ROUTINE
  Access:Customer.Open()                                   ! Open File referenced in 'Other Files' so need to inform it's FileManager
  Access:Customer.UseFile()                                ! Use File referenced in 'Other Files' so need to inform it's FileManager
  Access:CustomerCompany.Open()                            ! Open File referenced in 'Other Files' so need to inform it's FileManager
  Access:CustomerCompany.UseFile()                         ! Use File referenced in 'Other Files' so need to inform it's FileManager
  FilesOpened = True
!--------------------------------------
CloseFiles ROUTINE
  IF FilesOpened THEN
     Access:Customer.Close()
     Access:CustomerCompany.Close()
     FilesOpened = False
  END
!!! <summary>
!!! Generated from procedure template - Process
!!! Process the CustomerCompany File
!!! </summary>
DeleteAll_Customer PROCEDURE 

Progress:Thermometer BYTE                                  ! 
Process:View         VIEW(Customer)
                     END
ProgressWindow       WINDOW('Delete All Customer'),AT(,,142,59),FONT('Microsoft Sans Serif',8,,FONT:regular,CHARSET:DEFAULT), |
  DOUBLE,CENTER,GRAY,TIMER(1)
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,100)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel Process'), |
  TIP('Cancel Process')
                     END

ThisWindow           CLASS(ReportManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
                     END

ThisProcess          CLASS(ProcessClass)                   ! Process Manager
TakeRecord             PROCEDURE(),BYTE,PROC,DERIVED
                     END

ProgressMgr          StepClass                             ! Progress Manager

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
  GlobalErrors.SetProcedureName('DeleteAll_Customer')
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
  ProgressWindow{Prop:MDI} = True                          ! Make progress window an MDI child window
  Access:Customer.UseFile()
  CASE Message('Delete ALL ' & Records(Customer) & ' Customer records?','Delete All?',,'Delete All|No Keep')
  OF 2 ; ThisWindow.Kill() ; RETURN Level:Notify
  END 
  
  
     LOCK(Customer)             !SQLite in Help says this does NOT work, but it did in 11.1
     IF ~ERRORCODE() THEN 
        EMPTY(Customer)     
        UNLOCK(Customer)
     END
     IF ~Records(Customer) THEN RETURN Level:Notify .   
  Do DefineListboxStyle
  ProgressWindow{Prop:Timer} = 10                          ! Assign timer interval
  ThisProcess.Init(Process:View, Relate:Customer, ?Progress:PctText, Progress:Thermometer)
  ThisProcess.AddSortOrder()
  ProgressWindow{Prop:Text} = 'Processing Records'
  ?Progress:PctText{Prop:Text} = '0% Completed'
  SELF.Init(ThisProcess)
  SELF.SetUseMRP(False)
  ?Progress:UserString{Prop:Text}=''
  SELF.AddItem(?Progress:Cancel, RequestCancelled)
  SEND(Customer,'QUICKSCAN=on')
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
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisProcess.TakeRecord PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.TakeRecord()
  DELETE(Process:View)
  IF ERRORCODE()
    GlobalErrors.ThrowFile(Msg:DeleteFailed,'Process:View')
    ThisWindow.Response = RequestCompleted
    ReturnValue = Level:Fatal
  END
  RETURN ReturnValue

!!! <summary>
!!! Generated from procedure template - Source
!!! Generate some Product records to test having a lot in the file
!!! </summary>
TestGenerate_Product PROCEDURE                             ! Declare Procedure
RecordsBefore    LONG
RecordsAfter    LONG
ToDoRecords     LONG
RecordNo        LONG

UniqueName      LONG

Clock1  LONG     
Clock2  LONG     

 
Progress:Thermometer    LONG 
Progress:New            LONG
RecordsPerCycle         LONG
ProgressFACTOR          REAL 
ProgressWindow       WINDOW('Add Test Product'),AT(,,142,59),FONT('Segoe UI',9,,FONT:regular),DOUBLE,CENTER,GRAY,MDI 
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,25)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),SKIP
                     END
FilesOpened     BYTE(0)

  CODE
? DEBUGHOOK(Product:Record)
    DO OpenFiles
    RecordsBefore = RECORDS(Product)
    UniqueName = RecordsBefore +1
    GET(Product,0)

    EXECUTE Message('How many Test Product records to generate?' & |
                    '||File has ' & Records(Product) &' now.' & |
                    '||FYI Duplicate(File)=' & Duplicate(Product) &' ? Bug always =True' & |
                    '|Also seems with SQLite driver calling DUPLICATE() clears the Error()' & |
                    '','Test Data',,'Cancel|26|100|1000|5000|10,000')
        ToDoRecords = 0 
        ToDoRecords = 26
        ToDoRecords = 100
        ToDoRecords = 1000
        ToDoRecords = 5000
        ToDoRecords = 10000
    END 

    IF ~ToDoRecords THEN 
        DO CloseFiles 
        RETURN 
    END 

    OPEN(ProgressWindow)
    DISPLAY
    ?Progress:UserString{PROP:Text}='Add ' &  ToDoRecords    
    ProgressFACTOR = ?Progress:Thermometer{PROP:RangeHigh} / ToDoRecords
    
    RandomizeRandoms()
    
    DO AddTestDataRtn
    RecordsAfter = RECORDS(Product)
    Progress:Thermometer=100 ; DISPLAY
    
    DO CloseFiles 
    Message('TestGenerateCompanies ||ToDo Records = ' & ToDoRecords & |
               '||Records Before = '& RecordsBefore & |
               '|Records After = '& RecordsAfter & |
               '|Change = '& RecordsAfter - RecordsBefore & |  
               '||Time Taken: ' & (Clock2 -Clock1) / 100 & |
               '','Test Data')            
    
    RETURN
AddTestDataRtn ROUTINE
    DATA
TransxAdd  BOOL 
    CODE
!    TransxAdd = Message('How to Add','Add Products',,'Normal|Transaction') - 1

    Clock1 = CLOCK() 

    ?Progress:UserString{PROP:Text}='Add ' &  ToDoRecords    
    ProgressFACTOR = ?Progress:Thermometer{PROP:RangeHigh} / ToDoRecords
    RecordsPerCycle = 25
    IF TransxAdd THEN 
       RecordsPerCycle = 1000           !This is SO Fast can add a lot 
       LOGOUT(1,Product)
    END 
    0{PROP:Timer}=1
AL: ACCEPT
       CASE EVENT()
       OF EVENT:Timer
            LOOP RecordsPerCycle TIMES
                 IF RecordNo >= ToDoRecords THEN BREAK AL: .
                 RecordNo += 1
                 DO AddOneRtn
            END 

            Progress:New = RecordNo * ProgressFACTOR
            IF Progress:Thermometer < Progress:New THEN 
               CHANGE(?Progress:Thermometer,Progress:New) 
               ?Progress:PctText{PROP:Text}=RecordNo &' done'
            END 

       ELSE             
          IF ACCEPTED() = ?Progress:Cancel THEN 
             IF Message('Cancel Process?','Add Test Data',ICON:Cross, |
                        'Cancel|Continue',2)=1 THEN BREAK.
          END 
       END !Case Event 
    END  !Accept      
    0{PROP:Timer}=0  
    
    IF TransxAdd THEN 
       COMMIT()
       IF ERRORCODE() THEN 
          MESSAGE('COMMIT failed ' & Err4Msg(),'Commit Company')
       END 
    END 

    Clock2 = CLOCK() 
    EXIT

AddOneRtn ROUTINE
    GET(Product,0)
    CLEAR(Product)
    Pro:GUID = MakeGUID() 
    Pro:ProductCode  = TestDataPhone() & CHR(RANDOM(65,90))        !A phone looks like a Product
    !Pro:ProductName  = TestDataLorem( RANDOM(20,40) ) 
    Pro:ProductName  = TestDataWord() &' '& TestDataWord() &' '& TestDataWord() &' '& TestDataWord()  &' '& TestDataWord()
    Pro:Description  = TestDataLorem( RANDOM(100,200) ) 
    Pro:Price        = random(12,99) + Random(0,99) / 100
    Pro:QuantityInStock  = random(100,999)
    Pro:ReorderQuantity  = Pro:QuantityInStock * .20
    Pro:Cost             = Pro:Price * .50
    
    !--Lets have 26 consistent products A-Z we know we can use 
    IF RecordsBefore=0 AND RecordNo <= 26 THEN 
        Pro:ProductCode = CHR(64+RecordNo) & RecordNo * 100         !Consistent A100,B200,C300 for forst 26
        Pro:GUID='000' & CLIP(Pro:ProductCode) & ALL('1')           !A consistent GUID for the 26 to use in Invoices
!        Pro:GUID= ALL('0',SIZE(Pro:GUID)-LEN(CLIP(Pro:ProductCode)) -1 ) |     !A consistent GUID for the 26 to use in Invoices
!                & CLIP(Pro:ProductCode)            & Pro:ProductCode[1]        !too complicated to use elsewhere
                
        Pro:Price       =  RecordNo * 10
        Pro:Cost        = Pro:Price * .50
        EXECUTE RecordNo
          Pro:ProductName = 'Alpha, Beta and Gamma Radiation Shielding'
          Pro:ProductName = 'Bravo Channel Guide to Opera'
          Pro:ProductName = 'Charlie Sheen''s Guide to Pharmacology'
          Pro:ProductName = 'Delta Air Lines Gift Card'  ! 'Delta Wing Design for Supersonic Aircraft'
          Pro:ProductName = 'Echo Location in Bats'
          Pro:ProductName = 'Foxtrot Dancing for Dummies'
          Pro:ProductName = 'Golf in South Africa'
          Pro:ProductName = 'Hotel Guide to Cape Town'
          Pro:ProductName = 'India - History of a Subcontinent'
          Pro:ProductName = 'Juliett and Romeo from Her Point of View '
          Pro:ProductName = 'Kilo and 1000 Other Greek Prefixes'
          Pro:ProductName = 'Lima Peru Hiking to Machu Picchu'
          Pro:ProductName = 'Mike''s Guide to Amplification'
          Pro:ProductName = 'November 5 and Guy Fawkes Gunpowder Plot of 1605'
          Pro:ProductName = 'Oscar Wilde - The Picture of Dorian Gray'    !'Oscar Fingal O''Flahertie Wills Wilde - Poems and Plays'
          Pro:ProductName = 'Papa John''s Pizza Gift Card'
          Pro:ProductName = 'Quebec City Tourism Guide'
          Pro:ProductName = 'Romeo on Tragedy - A Survivor''s Guide'
          Pro:ProductName = 'Sierra Madre Hiking (without no stinking badges)'
          Pro:ProductName = 'Tango and Cash DVD - The FUBAR Edition'
          Pro:ProductName = 'Uniform Resource Identifiers for Hyperlinking' !'Uniforms of the British Empire'
          Pro:ProductName = 'Victor / Victoria DVD'
          Pro:ProductName = 'Whiskey or Scotch? Choose Your Poison!'
          Pro:ProductName = 'X-ray Crystallography of DNA '
          Pro:ProductName = 'Yankee Baseball Jersey'
          Pro:ProductName = 'Zulu Language History'
        END 
    END

    ADD(Product)
    IF ERRORCODE() THEN
!FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
!FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
!FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
       CASE Message('AddOneRtn ADD(Product) '& Err4Msg() & |
            '<13,10>={40}' & |
            '<13,10>RecordNo=' & RecordNo & |
            '<13,10>Pro:GUID=' & Pro:GUID & |
            '<13,10>Pro:ProductCode=' & Pro:ProductCode & |
            '<13,10><13,10>DUPLICATE(Product)=' & DUPLICATE(Product) & |
            '<13,10>DUPLICATE(Pro:GuidKey)=' & DUPLICATE(Pro:GuidKey) & |
            '<13,10>DUPLICATE(Pro:ProductCodeKey)=' & DUPLICATE(Pro:ProductCodeKey) & |
            '<13,10>Error() again at Bottom: ' & ErrorCode()&' '& Error() & |
            '','AddOne Error',,'Continue|Abort All Adds')
       OF 1              
       OF 2 ; RecordNo=1 + ToDoRecords ; EXIT 
       END 

       GET(Product,Pro:GuidKey)      !Is it a GUID duplicate?
       IF ~ERRORCODE() THEN
           Message('Last ADD(Product) was GUID duplicate! '&  |
            '<13,10>Found below GUID already in the File!' & |
            '<13,10>Pro:GUID=' & Pro:GUID & |
            '<13,10>Pro:ProductCode=' & Pro:ProductCode & |
            '','AddOneRtn')  
       ELSE 
           GET(Product,Pro:ProductCodeKey)   
           IF ~ERRORCODE() THEN
               Message('Last ADD(Product) was CompanyNameKey duplicate! '&  |
                '<13,10>Found below CompanyNameKey already in the File!' & |
                '<13,10>Pro:ProductCode=' & Pro:ProductCode & |
                '<13,10>Pro:GUID=' & Pro:GUID & |                
                '','AddOneRtn')  
           END 
       END 
    END 
    EXIT

    OMIT('**END**')
    Product         FILE,DRIVER('SQLite'),OWNER(Glo:Owner),NAME('Product'),PRE(Pro),CREATE !Product's Information
        Pro:GuidKey           KEY(Pro:GUID),PRIMARY,NAME('Product_GuidKey'),NOCASE
        Pro:ProductCodeKey    KEY(Pro:ProductCode),NOCASE
        Pro:ProductNameKey    KEY(Pro:ProductName),DUP,NAME('Product_ProductNameKey'),NOCASE
        Pro:ImageBlob         BLOB,Binary
        Pro:record            RECORD
        Pro:GUID                STRING('MakeGUID() {6}')
        Pro:ProductCode         STRING(100) !User defined Product Number
        Pro:ProductName         STRING(100)
        Pro:Description         STRING(255) !Product's Description
        Pro:Price               DECIMAL(11,2) !Product's Price
        Pro:QuantityInStock     LONG !Quantity of product in stock
        Pro:ReorderQuantity     LONG !Product's quantity for re-order
        Pro:Cost                DECIMAL(11,2)
        Pro:ImageFilename       STRING(255)
                      END
                    END

    !end of OMIT('**END**')
!--------------------------------------
OpenFiles  ROUTINE
  Access:Product.Open()                                    ! Open File referenced in 'Other Files' so need to inform it's FileManager
  Access:Product.UseFile()                                 ! Use File referenced in 'Other Files' so need to inform it's FileManager
  FilesOpened = True
!--------------------------------------
CloseFiles ROUTINE
  IF FilesOpened THEN
     Access:Product.Close()
     FilesOpened = False
  END
!!! <summary>
!!! Generated from procedure template - Process
!!! Process the Product File to Delete All
!!! </summary>
DeleteAll_Product PROCEDURE 

Progress:Thermometer BYTE                                  ! 
Process:View         VIEW(Product)
                     END
ProgressWindow       WINDOW('Delete All Customer'),AT(,,142,59),FONT('Microsoft Sans Serif',8,,FONT:regular,CHARSET:DEFAULT), |
  DOUBLE,CENTER,GRAY,TIMER(1)
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,100)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel Process'), |
  TIP('Cancel Process')
                     END

ThisWindow           CLASS(ReportManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
                     END

ThisProcess          CLASS(ProcessClass)                   ! Process Manager
TakeRecord             PROCEDURE(),BYTE,PROC,DERIVED
                     END

ProgressMgr          StepClass                             ! Progress Manager

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
  GlobalErrors.SetProcedureName('DeleteAll_Product')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Progress:Thermometer
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  Relate:Product.Open()                                    ! File Product used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Open(ProgressWindow)                                ! Open window
  ProgressWindow{Prop:MDI} = True                          ! Make progress window an MDI child window
  Access:Product.UseFile()
  CASE Message('Delete ALL ' & Records(Product) & ' Product records?','Delete All?',,'Delete All|No Keep')
  OF 2 ; ThisWindow.Kill() ; RETURN Level:Notify
  END 
  
  
     LOCK(Product)             !SQLite in Help says this does NOT work, but it did in 11.1
     IF ~ERRORCODE() THEN 
        EMPTY(Product)     
        UNLOCK(Product)
     END
     IF ~Records(Product) THEN RETURN Level:Notify .   
  Do DefineListboxStyle
  ProgressWindow{Prop:Timer} = 10                          ! Assign timer interval
  ThisProcess.Init(Process:View, Relate:Product, ?Progress:PctText, Progress:Thermometer)
  ThisProcess.AddSortOrder()
  ProgressWindow{Prop:Text} = 'Processing Records'
  ?Progress:PctText{Prop:Text} = '0% Completed'
  SELF.Init(ThisProcess)
  SELF.SetUseMRP(False)
  ?Progress:UserString{Prop:Text}=''
  SELF.AddItem(?Progress:Cancel, RequestCancelled)
  SEND(Product,'QUICKSCAN=on')
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
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisProcess.TakeRecord PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.TakeRecord()
  DELETE(Process:View)
  IF ERRORCODE()
    GlobalErrors.ThrowFile(Msg:DeleteFailed,'Process:View')
    ThisWindow.Response = RequestCompleted
    ReturnValue = Level:Fatal
  END
  RETURN ReturnValue

!!! <summary>
!!! Generated from procedure template - Source
!!! Call MakeGUID() a million times to check for Duplicates
!!! </summary>
TestMakeGUID_StressTest PROCEDURE                          ! Declare Procedure
ToDoRecords     LONG
RecordNo        LONG
DuplicateCnt    LONG
DupGUIDs        CSTRING(17*16)
TotalAdds       LONG
NoDupMsgs       BOOL 
Progress:Thermometer    LONG 
Progress:New            LONG 
ProgressFACTOR           REAL 
ProgressWindow       WINDOW('MakeGUID() Stress Test'),AT(,,142,59),FONT('Segoe UI',9,,FONT:regular),DOUBLE,CENTER,GRAY,MDI 
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,1000)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),SKIP
                     END
GuidQ                QUEUE,PRE(GuidQ)                      ! 
GUID1                STRING(16)                            ! 
                     END                                   ! 

  CODE
    SYSTEM{PROP:MsgModeDefault}=MSGMODE:CANCOPY
    !Change MakeGUID to just 2 8 bytes to see some Dups?
    LOOP 
        EXECUTE Message('Stress test MakeGUID() by adding many to a Queue to check for Duplicates' & |
                        '||Test Count: ' & CLIP(LEFT(FORMAT(Records(GuidQ) + DuplicateCnt,@n15)))  & |
                        '||Duplicates: ' & DuplicateCnt & | 
                        '|GUIDs: ' & DupGUIDs & |
                        '||You can run this many times and return to this message.' & |
                        '','Test Data',,'Cancel|10,000|50,000|100,000|1,00,000|2,000,000')
            ToDoRecords = 0 
            ToDoRecords = 10000
            ToDoRecords = 50000
            ToDoRecords = 100000
            ToDoRecords = 1000000
            ToDoRecords = 2000000
        END 

        IF ~ToDoRecords THEN 
           RETURN 
        END 
        
        OPEN(ProgressWindow)
        DO TestRtn
        Progress:Thermometer=100 ; DISPLAY 
        CLOSE(ProgressWindow)
    END         
    
    RETURN
TestRtn ROUTINE
    
    RecordNo=0
    Progress:Thermometer = 0
    Progress:New         = 0 
    ?Progress:UserString{PROP:Text}='Add ' &  ToDoRecords
    DISPLAY
    ProgressFACTOR = ?Progress:Thermometer{PROP:RangeHigh} / ToDoRecords
    
    0{PROP:Timer}=10
AL: ACCEPT
       CASE EVENT()
       OF EVENT:Timer
            LOOP 1000 TIMES
                 IF RecordNo >= ToDoRecords THEN BREAK AL: .
                 RecordNo += 1
                 DO AddOneRtn
            END 
            Progress:New = RecordNo * ProgressFACTOR
            IF Progress:Thermometer < Progress:New THEN 
               Progress:Thermometer = Progress:New
               ?Progress:PctText{PROP:Text}=RecordNo &' done'
               DISPLAY
            END 
       ELSE !Other Events            
          IF ACCEPTED() = ?Progress:Cancel THEN 
             IF Message('Cancel at record '& RecordNo &' of '& ToDoRecords &'?','MakeGUID() Test',ICON:Cross, |
                        'Cancel|Continue',2)=1 THEN BREAK.
          END 
       END
       
    END 
    0{PROP:Timer}='' 
    EXIT

AddOneRtn ROUTINE
    TotalAdds += 1
    GuidQ:GUID1 = MakeGUID()
    GET(GuidQ,GuidQ:GUID1)
    IF ERRORCODE() THEN  
       ADD(GuidQ,GuidQ:GUID1) 
       EXIT
    END 
    DuplicateCnt += 1 
    DupGUIDs = GuidQ:GUID1 &' '& DupGUIDs  
    IF ~NoDupMsgs THEN 
       CASE Message('MakeGUID() Duplicated on ' & GuidQ:GUID1 & |
            '|={40}' & |
            '||RecordNo ' & RecordNo &' of '& ToDoRecords & ' adds ('& TotalAdds &' total)'& |
            '||DuplicateCnt=' & DuplicateCnt & |
            '||Dup GUIDs=' & DupGUIDs & |
            '','MakeGUID() DUPLICATE !!!',,'Continue|Abort Test|No Dup Messages')
       OF 1              
       OF 2 ; RecordNo=1 + ToDoRecords ; EXIT  
       OF 3 ; NoDupMsgs = 1
       END 
    END 

    EXIT
!!! <summary>
!!! Generated from procedure template - Source
!!! Generate Test Data for Customer - TODO Test Transaction and Timing ?
!!! </summary>
TestGenerate_Invoices PROCEDURE                            ! Declare Procedure
RecordsBefore    LONG
RecordsAfter    LONG
RecordsBeforeDetail    LONG
RecordsAfterDetail    LONG

ToDoRecords     LONG
RecordNo        LONG

!UniqueName      LONG 
UniqueInvoiceNumber  LONG    !for Inv:InvoiceNumberKey

CustomerQ        QUEUE,PRE(CustQ)  
GUID                 LIKE(Cus:GUID)             ! CustQ:GUID
_Record              STRING(SIZE(Cus:Record))   ! CustQ:_Record
                END 

ProductQ        QUEUE,PRE(ProdQ)  
GUID                 LIKE(Pro:GUID)             ! ProdQ:GUID
_Record              STRING(SIZE(Pro:Record))   ! ProdQ:_Record
                END  
                
!CompanyQ  QUEUE,PRE(CompQ)      !To randomly assing
!GUID        LIKE(CusCom:GUID)
!          END
Progress:Thermometer    LONG 
Progress:New            LONG 
ProgressFACTOR           REAL 
ProgressWindow       WINDOW('Add Test Invoices'),AT(,,142,59),FONT('Segoe UI',9,,FONT:regular),DOUBLE,CENTER,GRAY,MDI 
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,25)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),SKIP
                     END

                     
DetLineNo            LONG                                  ! 
SubTotal             DECIMAL(11,2)                         ! 
FilesOpened     BYTE(0)

  CODE
? DEBUGHOOK(Customer:Record)
? DEBUGHOOK(CustomerCompany:Record)
? DEBUGHOOK(Invoice:Record)
? DEBUGHOOK(InvoiceDetail:Record)
? DEBUGHOOK(Product:Record)
    SYSTEM{PROP:MsgModeDefault}=MSGMODE:CANCOPY
    DO OpenFiles
    RecordsBefore = RECORDS(Invoice)
    RecordsBeforeDetail =  RECORDS(InvoiceDetail)

    EXECUTE Message('How many Test Invoice records to generate?' & |
                    '||File has ' & Records(Invoice) &' Invoices and '& RecordsBeforeDetail &' Details now.' & |
                    '','Test Data',,'Cancel|10|100|1000|5000|10,000')
        ToDoRecords = 0 
        ToDoRecords = 10
        ToDoRecords = 100
        ToDoRecords = 1000
        ToDoRecords = 5000
        ToDoRecords = 10000
    END 

    IF ~ToDoRecords THEN 
        DO CloseFiles 
        RETURN 
    END 

    OPEN(ProgressWindow)
    ?Progress:UserString{PROP:Text}='Add ' &  ToDoRecords
    DISPLAY
    ProgressFACTOR = ?Progress:Thermometer{PROP:RangeHigh} / ToDoRecords
    
    RandomizeRandoms()
    
    DO AddTestDataRtn
    RecordsAfter       = RECORDS(Invoice)
    RecordsAfterDetail = RECORDS(InvoiceDetail)

    Progress:Thermometer=100 ; DISPLAY
    
    DO CloseFiles 
    Message('TestGenerate Invoice ||ToDo Records = ' & ToDoRecords & |
               '||Invoice Records Before='& RecordsBefore &'  Details=' & RecordsBeforeDetail & |
               '|Invoice Records After=  '& RecordsAfter  &'  Details=' & RecordsAfterDetail & |
               '|Change = '& RecordsAfter - RecordsBefore & |
               '','Test Data')            
    
    RETURN
AddTestDataRtn ROUTINE
!    LOOP RecordNo=1 TO ToDoRecords ; DO AddOneRtn ; END  !Simple Loop appears to hang

    DO LoadCustomerQ 
    DO LoadProductQ 
    IF ~RECORDS(CustomerQ) OR ~RECORDS(ProductQ) THEN 
        Message('There are '& RECORDS(CustomerQ) &' Customer Records ' & |
                '|and there are '& RECORDS(ProductQ) &' Product Records ' & |
                '||Cannot add Invoices','AddTestDataRtn')
        EXIT 
    END

    SET(Inv:InvoiceNumberKey)      !This Key is Autonumbered by the Templates
    PREVIOUS(Invoice)
    UniqueInvoiceNumber = CHOOSE(~ERRORCODE(), Inv:InvoiceNumber,110)

    0{PROP:Timer}=10
AL: ACCEPT
       CASE EVENT()
       OF EVENT:Timer
!TODO: What if we add a Transaction?  Should speed up?
!TODO: What if we add a Transaction?  Should speed up?
            LOOP 10 TIMES
                 IF RecordNo >= ToDoRecords THEN BREAK AL: .
                 RecordNo += 1
                 DO AddOneInvoiceRtn
            END 
            Progress:New = RecordNo * ProgressFACTOR
            IF Progress:Thermometer < Progress:New THEN 
               Progress:Thermometer = Progress:New
               ?Progress:PctText{PROP:Text}=RecordNo &' done'
               DISPLAY
            END 
       ELSE !Other Events            
!Simpe:   IF ACCEPTED() = ?Progress:Cancel THEN BREAK.
          IF ACCEPTED() = ?Progress:Cancel THEN 
             IF Message('Cancel Process?','Add Test Data',ICON:Cross, |
                        'Cancel|Continue',2)=1 THEN BREAK.
          END 
       END
       
    END 
    0{PROP:Timer}='' 
    EXIT

AddOneInvoiceRtn ROUTINE
    GET(CustomerQ,RANDOM(1,RECORDS(CustomerQ)))
    Cus:Record = CustQ:_Record

    GET(Invoice,0)
    CLEAR(Invoice)
    Inv:GUID            = MakeGUID()
    Inv:CustomerGuid    = Cus:GUID
    UniqueInvoiceNumber += 1
    Inv:InvoiceNumber   = UniqueInvoiceNumber
    Inv:Date            = TODAY() - RANDOM(0,60)
    Inv:CustomerOrderNumber = RANDOM(1111,987654321)
    Inv:OrderShipped    = RANDOM(0,1)
    Inv:FirstName       = Cus:FirstName
    Inv:LastName        = Cus:LastName
    Inv:Street          = Cus:Street
    Inv:City            = Cus:City
    Inv:State           = Cus:State
    Inv:PostalCode      = Cus:PostalCode
    Inv:Phone           = Cus:Phone
    Inv:Total           = 0
    Inv:Note            =TestDataLorem(random(30,300))
    
!    TestDataFirstLast(Inv:FirstName,Inv:LastName)
!    TestDataAddress(Inv:Street,Inv:City,Inv:State,Inv:PostalCode) 
!    Inv:Phone        = TestDataPhone() 

    ADD(Invoice)
    IF ~ERRORCODE() THEN
        DO AddDetailsRtn
        PUT(Invoice)            !Save Totals
    ELSE 
!FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
!FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
!FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
       CASE Message('AddOneRtn ADD(Invoice) '& Err4Msg() & |
            '<13,10>={40}' & |
            '<13,10>RecordNo=' & RecordNo & |
            '<13,10>Inv:GUID=' & Inv:GUID & |
            '<13,10>Inv:CustomerGuid=' & Inv:CustomerGuid & |
            '<13,10>Inv:InvoiceNumber=' & Inv:InvoiceNumber & |
            '<13,10>Error() again at Bottom: ' & ErrorCode()&' '& Error() & |
            '','AddOne Error',,'Continue|Abort All Adds')
       OF 1              
       OF 2 ; RecordNo=1 + ToDoRecords ; EXIT 
       END 

    END 
    EXIT
AddDetailsRtn ROUTINE

    LOOP DetLineNo = 1 TO RANDOM(1,9)
        
        GET(ProductQ,RANDOM(1,RECORDS(ProductQ)))
        Pro:Record = ProdQ:_Record

        GET(InvoiceDetail,0)
        CLEAR(InvoiceDetail)
        InvDet:GUID         = MakeGUID()
        InvDet:InvoiceGuid  = Inv:GUID
        InvDet:ProductGuid  = Pro:GUID
        InvDet:LineNumber   = DetLineNo
        InvDet:Quantity     = RANDOM(1,20)
        InvDet:Price        = Pro:Price

        SubTotal            = InvDet:Quantity * InvDet:Price

        InvDet:DiscountRate = RANDOM(0,5) * 2 
        InvDet:Discount     = ROUND(SubTotal * InvDet:DiscountRate / 100,.01)
        SubTotal -= InvDet:Discount
        
        InvDet:TaxRate      = 0
        CASE Inv:State
        OF 'IL' ; InvDet:TaxRate = 6.5
        OF 'CA' ; InvDet:TaxRate = 8
        OF 'WA' ; InvDet:TaxRate = 5.5
        END
        
        InvDet:TaxPaid      = ROUND(SubTotal * InvDet:TaxRate / 100,.01)
        SubTotal -= InvDet:TaxPaid
        
        InvDet:Total        = SubTotal      !Not sure what was intended for this 
        
        InvDet:Note         = TestDataLorem(RANDOM(20,200))

        ADD(InvoiceDetail)
        IF ~ERRORCODE() THEN 
            Inv:Total += InvDet:Total
            CYCLE 
        END 
        
    !FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
    !FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
    !FYI it seems DUPLICATE() clears the Error() in the SQLite driver, so below put Err4Msg() 1st
        CASE Message('AddDetailsRtn ADD(InvoiceDetail) '& Err4Msg() & |
             '<13,10>={40}' & |
             '<13,10>InvDet:GUID=' & InvDet:GUID & |
             '<13,10>InvDet:LineNumber=' & InvDet:LineNumber & |
             '<13,10>' &  |
             '<13,10>Inv:GUID=' & Inv:GUID & |
             '<13,10>Inv:CustomerGuid=' & Inv:CustomerGuid & |
             '<13,10>Inv:InvoiceNumber=' & Inv:InvoiceNumber & |
             '<13,10>Error() again at Bottom: ' & ErrorCode()&' '& Error() & |
             '','AddOne Error',,'Continue|Abort Detail Adds|Abort Invoice Adds')
        OF 1              
        OF 2 ; EXIT 
        OF 3 ; RecordNo=1 + ToDoRecords ; EXIT 
        END 

    END !Loop DetLineNo
    EXIT
LoadCustomerQ ROUTINE    !Load Q so have CustQ:GUID to randomly assign 
    FREE(CustomerQ)
    Access:Customer.UseFile()
    SET(Customer)
    LOOP
        NEXT(Customer)
        IF ERRORCODE() THEN BREAK.
        CustQ:Guid    = Cus:GUID
        CustQ:_Record = Cus:Record
        ADD(CustomerQ)
    END
    EXIT 


    OMIT('**END**')
CustomerQ        QUEUE,PRE(CustQ)  
GUID                 LIKE(Cus:GUID)             ! CustQ:GUID
_Record              STRING(SIZE(Cus:Record))   ! CustQ:_Record
                END  
    !end of OMIT('**END**')
LoadProductQ ROUTINE    !Load Q so have ProdQ:GUID to randomly assign 
    FREE(ProductQ)
    Access:Product.UseFile()
    SET(Product)
    LOOP
        NEXT(Product)
        IF ERRORCODE() THEN BREAK.
        ProdQ:Guid    = Pro:GUID
        ProdQ:_Record = Pro:Record
        ADD(ProductQ)
    END
    EXIT 


    OMIT('**END**')
ProductQ        QUEUE,PRE(ProdQ)  
GUID                 LIKE(Pro:GUID)             ! ProdQ:GUID
_Record              STRING(SIZE(Pro:Record))   ! ProdQ:_Record
                END  
    !end of OMIT('**END**')
!--------------------------------------
OpenFiles  ROUTINE
  Access:Product.Open()                                    ! Open File referenced in 'Other Files' so need to inform it's FileManager
  Access:Product.UseFile()                                 ! Use File referenced in 'Other Files' so need to inform it's FileManager
  Access:InvoiceDetail.Open()                              ! Open File referenced in 'Other Files' so need to inform it's FileManager
  Access:InvoiceDetail.UseFile()                           ! Use File referenced in 'Other Files' so need to inform it's FileManager
  Access:Invoice.Open()                                    ! Open File referenced in 'Other Files' so need to inform it's FileManager
  Access:Invoice.UseFile()                                 ! Use File referenced in 'Other Files' so need to inform it's FileManager
  Access:Customer.Open()                                   ! Open File referenced in 'Other Files' so need to inform it's FileManager
  Access:Customer.UseFile()                                ! Use File referenced in 'Other Files' so need to inform it's FileManager
  Access:CustomerCompany.Open()                            ! Open File referenced in 'Other Files' so need to inform it's FileManager
  Access:CustomerCompany.UseFile()                         ! Use File referenced in 'Other Files' so need to inform it's FileManager
  FilesOpened = True
!--------------------------------------
CloseFiles ROUTINE
  IF FilesOpened THEN
     Access:Product.Close()
     Access:InvoiceDetail.Close()
     Access:Invoice.Close()
     Access:Customer.Close()
     Access:CustomerCompany.Close()
     FilesOpened = False
  END
!!! <summary>
!!! Generated from procedure template - Process
!!! Process the Invoice File then Details
!!! </summary>
DeleteAll_Invoice PROCEDURE 

Yes_DeleteALL BOOL 
Progress:Thermometer BYTE                                  ! 
Process:View         VIEW(Invoice)
                     END
ProgressWindow       WINDOW('Delete All Invoice'),AT(,,142,59),FONT('Microsoft Sans Serif',8,,FONT:regular,CHARSET:DEFAULT), |
  DOUBLE,CENTER,GRAY,TIMER(1)
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,100)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel Process'), |
  TIP('Cancel Process')
                     END

ThisWindow           CLASS(ReportManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
                     END

ThisProcess          CLASS(ProcessClass)                   ! Process Manager
TakeRecord             PROCEDURE(),BYTE,PROC,DERIVED
                     END

ProgressMgr          StepClass                             ! Progress Manager

  CODE
? DEBUGHOOK(Invoice:Record)
? DEBUGHOOK(InvoiceDetail:Record)
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
  GlobalErrors.SetProcedureName('DeleteAll_Invoice')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Progress:Thermometer
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  Relate:Invoice.SetOpenRelated()
  Relate:Invoice.Open()                                    ! File Invoice used by this procedure, so make sure it's RelationManager is open
  Access:InvoiceDetail.UseFile()                           ! File referenced in 'Other Files' so need to inform it's FileManager
  SELF.FilesOpened = True
  SELF.Open(ProgressWindow)                                ! Open window
  ProgressWindow{Prop:MDI} = True                          ! Make progress window an MDI child window
  Access:Invoice.UseFile()
  Access:InvoiceDetail.UseFile()
  CASE Message('Delete ALL ' & Records(Invoice) & ' Invoice records?' & |
               '||And '& Records(InvoiceDetail) &' Details','Delete All?',,'Delete All|No Keep')
  OF 2 ; ThisWindow.Kill() ; RETURN Level:Notify
  END 
  
  Yes_DeleteALL = True
  
  IF Records(InvoiceDetail) THEN DeleteAll_InvoiceDetail(). !1st Details 
  
     LOCK(Invoice)             !SQLite in Help says this does NOT work, but it did in 11.1
     IF ~ERRORCODE() THEN 
        EMPTY(Invoice)     
        UNLOCK(Invoice)
     END
     IF ~Records(Invoice) THEN RETURN Level:Notify .   
  Do DefineListboxStyle
  ProgressWindow{Prop:Timer} = 10                          ! Assign timer interval
  ThisProcess.Init(Process:View, Relate:Invoice, ?Progress:PctText, Progress:Thermometer)
  ThisProcess.AddSortOrder()
  ProgressWindow{Prop:Text} = 'Processing Records'
  ?Progress:PctText{Prop:Text} = '0% Completed'
  SELF.Init(ThisProcess)
  SELF.SetUseMRP(False)
  ?Progress:UserString{Prop:Text}=''
  SELF.AddItem(?Progress:Cancel, RequestCancelled)
  SEND(Invoice,'QUICKSCAN=on')
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
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisProcess.TakeRecord PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.TakeRecord()
  DELETE(Process:View)
  IF ERRORCODE()
    GlobalErrors.ThrowFile(Msg:DeleteFailed,'Process:View')
    ThisWindow.Response = RequestCompleted
    ReturnValue = Level:Fatal
  END
  RETURN ReturnValue

!!! <summary>
!!! Generated from procedure template - Process
!!! Process the Invoice File then Details
!!! </summary>
DeleteAll_InvoiceDetail PROCEDURE 

Yes_DeleteALL BOOL 
Progress:Thermometer BYTE                                  ! 
Process:View         VIEW(InvoiceDetail)
                     END
ProgressWindow       WINDOW('Delete All Invoice Details'),AT(,,142,59),FONT('Microsoft Sans Serif',8,,FONT:regular, |
  CHARSET:DEFAULT),DOUBLE,CENTER,GRAY,TIMER(1)
                       PROGRESS,AT(15,15,111,12),USE(Progress:Thermometer),RANGE(0,100)
                       STRING(''),AT(0,3,141,10),USE(?Progress:UserString),CENTER
                       STRING(''),AT(0,30,141,10),USE(?Progress:PctText),CENTER
                       BUTTON('Cancel'),AT(46,42,49,15),USE(?Progress:Cancel),LEFT,ICON('WACANCEL.ICO'),FLAT,MSG('Cancel Process'), |
  TIP('Cancel Process')
                     END

ThisWindow           CLASS(ReportManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
                     END

ThisProcess          CLASS(ProcessClass)                   ! Process Manager
TakeRecord             PROCEDURE(),BYTE,PROC,DERIVED
                     END

ProgressMgr          StepClass                             ! Progress Manager

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

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('DeleteAll_InvoiceDetail')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Progress:Thermometer
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  Relate:InvoiceDetail.SetOpenRelated()
  Relate:InvoiceDetail.Open()                              ! File InvoiceDetail used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  SELF.Open(ProgressWindow)                                ! Open window
  ProgressWindow{Prop:MDI} = True                          ! Make progress window an MDI child window
  Access:InvoiceDetail.UseFile()
  !  CASE Message('Delete ALL ' & Records(Invoice) & ' Invoice records?','Delete All?',,'Delete All|No Keep')
  !  OF 2 ; ThisWindow.Kill() ; RETURN Level:Notify
  !  END 
  
  Yes_DeleteALL = True
  
     LOCK(InvoiceDetail)             !SQLite in Help says this does NOT work, but it did in 11.1
     IF ~ERRORCODE() THEN 
        EMPTY(InvoiceDetail)     
        UNLOCK(InvoiceDetail)
     END
     IF ~Records(InvoiceDetail) THEN RETURN Level:Notify .   
  Do DefineListboxStyle
  ProgressWindow{Prop:Timer} = 10                          ! Assign timer interval
  ThisProcess.Init(Process:View, Relate:InvoiceDetail, ?Progress:PctText, Progress:Thermometer)
  ThisProcess.AddSortOrder()
  ProgressWindow{Prop:Text} = 'Processing Records'
  ?Progress:PctText{Prop:Text} = '0% Completed'
  SELF.Init(ThisProcess)
  SELF.SetUseMRP(False)
  ?Progress:UserString{Prop:Text}=''
  SELF.AddItem(?Progress:Cancel, RequestCancelled)
  SEND(InvoiceDetail,'QUICKSCAN=on')
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
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisProcess.TakeRecord PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.TakeRecord()
  DELETE(Process:View)
  IF ERRORCODE()
    GlobalErrors.ThrowFile(Msg:DeleteFailed,'Process:View')
    ThisWindow.Response = RequestCompleted
    ReturnValue = Level:Fatal
  END
  RETURN ReturnValue

