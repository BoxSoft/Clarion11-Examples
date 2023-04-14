   PROGRAM



   INCLUDE('ABERROR.INC'),ONCE
   INCLUDE('ABFILE.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('CSIDL.EQU'),ONCE
   INCLUDE('ERRORS.CLW'),ONCE
   INCLUDE('KEYCODES.CLW'),ONCE
   INCLUDE('SPECIALFOLDER.INC'),ONCE
   INCLUDE('ABFUZZY.INC'),ONCE
   INCLUDE('Invoice.equ'),ONCE

   MAP
     MODULE('INVOICE_BC.CLW')
DctInit     PROCEDURE                                      ! Initializes the dictionary definition module
DctKill     PROCEDURE                                      ! Kills the dictionary definition module
     END
!--- Application Global and Exported Procedure Definitions --------------------------------------------
     MODULE('INVOICE001.CLW')
Main                   PROCEDURE   !See comments within this module for references to webinars
     END
     MODULE('INVOICE021.CLW')
MakeGUID               FUNCTION(),STRING   !
LogoutInvoice          FUNCTION(BOOL ShowErrorMessage=App:ShowMessage),LONG   !
NextInvoiceNumber      FUNCTION(),LONG   !
Trace                  PROCEDURE(STRING DebugMessage)   !
     END
         MODULE('Windows API')
           appOutputDebugString(*CSTRING DebugMessage),RAW,PASCAL,NAME('OutputDebugStringA'),DLL(1)
         END
   END

Glo:Owner            STRING('Invoice.sqlite {241}')
SilentRunning        BYTE(0)                               ! Set true when application is running in 'silent mode'

!region File Declaration
CustomerCompany      FILE,DRIVER('SQLite'),OWNER(Glo:Owner),NAME('CustomerCompany'),PRE(CusCom),BINDABLE,CREATE,THREAD ! Default company information
GuidKey                  KEY(CusCom:GUID),NAME('CustomerCompany_GuidKey'),NOCASE,PRIMARY !                     
CompanyNameKey           KEY(CusCom:CompanyName),NAME('CustomerCompany_CompanyNameKey'),NOCASE !                     
Record                   RECORD,PRE()
GUID                        STRING(16)                     !                     
CompanyName                 STRING(100),NAME('CompanyName | SELECTNAME=CompanyName COLLATE NOCASE') !                     
Street                      STRING(255)                    !                     
City                        STRING(100)                    !                     
State                       STRING(100)                    !                     
PostalCode                  STRING(100)                    !                     
Phone                       STRING(100)                    !                     
                         END
                     END                       

Product              FILE,DRIVER('SQLite'),OWNER(Glo:Owner),NAME('Product'),PRE(Pro),BINDABLE,CREATE,THREAD ! Product's Information
GuidKey                  KEY(Pro:GUID),NAME('Product_GuidKey'),NOCASE,PRIMARY !                     
ProductCodeKey           KEY(Pro:ProductCode),NOCASE       !                     
ProductNameKey           KEY(Pro:ProductName),DUP,NAME('Product_ProductNameKey'),NOCASE !                     
ImageBlob                   BLOB,BINARY                    !                     
Record                   RECORD,PRE()
GUID                        STRING(16)                     !                     
ProductCode                 STRING(100)                    ! User defined Product Number
ProductName                 STRING(100)                    !                     
Description                 STRING(255)                    ! Product's Description
Price                       DECIMAL(11,2)                  ! Product's Price     
QuantityInStock             LONG                           ! Quantity of product in stock
ReorderQuantity             LONG                           ! Product's quantity for re-order
Cost                        DECIMAL(11,2)                  !                     
ImageFilename               STRING(255)                    !                     
                         END
                     END                       

InvoiceDetail        FILE,DRIVER('SQLite'),OWNER(Glo:Owner),NAME('InvoiceDetail'),PRE(InvDet),BINDABLE,CREATE,THREAD ! Product-Order detail
GuidKey                  KEY(InvDet:GUID),NAME('InvoiceDetail_GuidKey'),NOCASE,PRIMARY !                     
InvoiceKey               KEY(InvDet:InvoiceGuid,InvDet:LineNumber),DUP,NAME('InvoiceDetail_InvoiceKey'),NOCASE !                     
ProductKey               KEY(InvDet:ProductGuid),DUP,NAME('InvoiceDetail_ProductKey'),NOCASE !                     
Record                   RECORD,PRE()
GUID                        STRING(16)                     !                     
InvoiceGuid                 STRING(16)                     !                     
ProductGuid                 STRING(16)                     !                     
LineNumber                  LONG                           ! Line number         
Quantity                    LONG                           !                     
Price                       DECIMAL(11,2)                  ! Product's Price     
DiscountRate                DECIMAL(6,4)                   ! Special discount rate on product
Discount                    DECIMAL(11,2)                  !                     
Subtotal                    DECIMAL(11,2)                  !                     
TaxRate                     DECIMAL(6,4)                   ! Consumer's Tax rate 
TaxPaid                     DECIMAL(11,2)                  !                     
Total                       DECIMAL(11,2)                  !                     
Note                        STRING(255)                    !                     
                         END
                     END                       

Invoice              FILE,DRIVER('SQLite'),OWNER(Glo:Owner),NAME('Invoice'),PRE(Inv),BINDABLE,CREATE,THREAD ! Customer's Orders   
GuidKey                  KEY(Inv:GUID),NAME('Invoice_GuidKey'),NOCASE,PRIMARY !                     
CustomerKey              KEY(Inv:CustomerGuid),DUP,NOCASE  !                     
InvoiceNumberKey         KEY(Inv:InvoiceNumber),NOCASE     !                     
DateKey                  KEY(Inv:Date,Inv:InvoiceNumber),DUP,NAME('Invoice_DateKey'),NOCASE !                     
Record                   RECORD,PRE()
GUID                        STRING(16)                     !                     
CustomerGuid                STRING(16)                     !                     
InvoiceNumber               LONG                           ! Invoice number for each order
Date                        DATE                           !                     
CustomerOrderNumber         STRING(100)                    !                     
OrderShipped                BYTE                           ! Checked if order is shipped
FirstName                   STRING(100)                    !                     
LastName                    STRING(100)                    !                     
Street                      STRING(255)                    !                     
City                        STRING(100)                    !                     
State                       STRING(100)                    !                     
PostalCode                  STRING(100)                    !                     
Phone                       STRING(100)                    !                     
Total                       DECIMAL(11,2)                  ! Roll-up Field       
Note                        STRING(255)                    !                     
                         END
                     END                       

Customer             FILE,DRIVER('SQLite'),OWNER(Glo:Owner),NAME('Customer'),PRE(Cus),BINDABLE,CREATE,THREAD ! Customer's Information
GuidKey                  KEY(Cus:GUID),NAME('Customer_GuidKey'),NOCASE,PRIMARY !                     
CompanyKey               KEY(Cus:CompanyGuid),DUP,NAME('Customer_CompanyKey'),NOCASE !                     
CustomerNumberKey        KEY(Cus:CustomerNumber),NOCASE    !                     
LastFirstNameKey         KEY(Cus:LastName,Cus:FirstName),DUP,NAME('Customer_LastFirstNameKey'),NOCASE !                     
FirstLastNameKey_Copy    KEY(Cus:FirstName,Cus:LastName),DUP,NAME('Customer_FirstLastNameKey'),NOCASE !                     
PostalCodeKey            KEY(Cus:PostalCode),DUP,NAME('Customer_PostalCodeKey'),NOCASE !                     
StateKey                 KEY(Cus:State),DUP,NAME('Customer_StateKey'),NOCASE !                     
Record                   RECORD,PRE()
GUID                        STRING(16)                     !                     
CustomerNumber              LONG                           !                     
CompanyGuid                 STRING(16)                     !                     
FirstName                   STRING(100),NAME('FirstName | SELECTNAME=FirstName COLLATE NOCASE') !                     
LastName                    STRING(100),NAME('LastName | SELECTNAME=LastName COLLATE NOCASE') !                     
Street                      STRING(255),NAME('Street | SELECTNAME=Street COLLATE NOCASE') !                     
City                        STRING(100)                    !                     
State                       STRING(100),NAME('State | SELECTNAME=State COLLATE NOCASE') !                     
PostalCode                  STRING(100),NAME('PostalCode | SELECTNAME=PostalCode COLLATE NOCASE') !                     
Phone                       STRING(100)                    !                     
MobilePhone                 STRING(100)                    !                     
Email                       STRING(100)                    !                     
                         END
                     END                       

Configuration        FILE,DRIVER('SQLite'),OWNER(Glo:Owner),NAME('Configuration'),PRE(Cfg),BINDABLE,CREATE,THREAD ! Program settings and such
GuidKey                  KEY(Cfg:GUID),NAME('CustomerCompany_GuidKey'),NOCASE,PRIMARY !                     
Record                   RECORD,PRE()
GUID                        STRING(16)                     !                     
CompanyName                 STRING(100)                    !                     
Street                      STRING(255)                    !                     
City                        STRING(100)                    !                     
State                       STRING(100)                    !                     
PostalCode                  STRING(100)                    !                     
Phone                       STRING(100)                    !                     
TaxRate                     DECIMAL(6,4)                   ! Default Tax rate    
                         END
                     END                       

!endregion

Access:CustomerCompany &FileManager,THREAD                 ! FileManager for CustomerCompany
Relate:CustomerCompany &RelationManager,THREAD             ! RelationManager for CustomerCompany
Access:Product       &FileManager,THREAD                   ! FileManager for Product
Relate:Product       &RelationManager,THREAD               ! RelationManager for Product
Access:InvoiceDetail &FileManager,THREAD                   ! FileManager for InvoiceDetail
Relate:InvoiceDetail &RelationManager,THREAD               ! RelationManager for InvoiceDetail
Access:Invoice       &FileManager,THREAD                   ! FileManager for Invoice
Relate:Invoice       &RelationManager,THREAD               ! RelationManager for Invoice
Access:Customer      &FileManager,THREAD                   ! FileManager for Customer
Relate:Customer      &RelationManager,THREAD               ! RelationManager for Customer
Access:Configuration &FileManager,THREAD                   ! FileManager for Configuration
Relate:Configuration &RelationManager,THREAD               ! RelationManager for Configuration

FuzzyMatcher         FuzzyClass                            ! Global fuzzy matcher
GlobalErrorStatus    ErrorStatusClass,THREAD
GlobalErrors         ErrorClass                            ! Global error manager
INIMgr               INIClass                              ! Global non-volatile storage manager
svSpecialFolder        SpecialFolder
GlobalRequest        BYTE(0),THREAD                        ! Set when a browse calls a form, to let it know action to perform
GlobalResponse       BYTE(0),THREAD                        ! Set to the response from the form
VCRRequest           LONG(0),THREAD                        ! Set to the request from the VCR buttons

Dictionary           CLASS,THREAD
Construct              PROCEDURE
Destruct               PROCEDURE
                     END


  CODE
  GlobalErrors.Init(GlobalErrorStatus)
  FuzzyMatcher.Init                                        ! Initilaize the browse 'fuzzy matcher'
  FuzzyMatcher.SetOption(MatchOption:NoCase, 1)            ! Configure case matching
  FuzzyMatcher.SetOption(MatchOption:WordOnly, 0)          ! Configure 'word only' matching
  svSpecialFolder.CreateDirIn(SV:CSIDL_PERSONAL, 'SoftVelocity Examples' & '\' & 'Invoice' )
  INIMgr.Init(svSpecialFolder.GetDir(SV:CSIDL_PERSONAL, 'SoftVelocity Examples' & '\' & 'Invoice') & '\' & 'invoice.INI', NVD_INI)
  DctInit()
  SYSTEM{PROP:Icon} = 'Application.ico'
    SYSTEM{PROP:Icon} = '~Application.ico'
  Main
  INIMgr.Update
  INIMgr.Kill                                              ! Destroy INI manager
  FuzzyMatcher.Kill                                        ! Destroy fuzzy matcher


Dictionary.Construct PROCEDURE

  CODE
  IF THREAD()<>1
     DctInit()
  END


Dictionary.Destruct PROCEDURE

  CODE
  DctKill()

