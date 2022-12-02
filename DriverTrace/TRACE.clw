   PROGRAM



   INCLUDE('ABERROR.INC'),ONCE
   INCLUDE('ABFILE.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ERRORS.CLW'),ONCE
   INCLUDE('KEYCODES.CLW'),ONCE
   INCLUDE('ABFUZZY.INC'),ONCE
INCLUDE('CSIDL.EQU'),ONCE
INCLUDE('SpecialFolder.inc'),ONCE

   MAP
     MODULE('TRACE_BC.CLW')
DctInit     PROCEDURE                                      ! Initializes the dictionary definition module
DctKill     PROCEDURE                                      ! Kills the dictionary definition module
     END
!--- Application Global and Exported Procedure Definitions --------------------------------------------
     MODULE('TRACE001.CLW')
Main                   PROCEDURE   !
     END
   END

Driver               STRING(20)
Trace                BYTE
Profile              BYTE
Details              BYTE
BindData             BYTE
TraceFile            STRING(512)
Suppress             BYTE
Drivers              QUEUE,PRE()
SupportsTrace          BYTE
SupportsBufferSuppression BYTE
                     END
DrvNames             QUEUE,PRE()
Name                   STRING(20)
                     END
SilentRunning        BYTE(0)                               ! Set true when application is running in 'silent mode'

EQTrace     EQUATE('Trace')
EQProfile   EQUATE('Profile')
EQDetails   EQUATE('Details')
EQBindData  EQUATE('BindData')
EQTraceFile EQUATE('TraceFile')
EQSuppress  EQUATE('TraceIntoFiles')
!region File Declaration
drvlist              FILE,DRIVER('TOPSPEED'),PRE(DRV),CREATE,BINDABLE,THREAD !List of all file drivers
NameKey                  KEY(DRV:Name),DUP,NOCASE          !                    
Record                   RECORD,PRE()
Name                        STRING(20)                     !                    
SupportsTrace               BYTE                           !                    
SupportsBufferSuppression   BYTE                           !                    
                         END
                     END                       

!endregion

Access:drvlist       &FileManager,THREAD                   ! FileManager for drvlist
Relate:drvlist       &RelationManager,THREAD               ! RelationManager for drvlist

FuzzyMatcher         FuzzyClass                            ! Global fuzzy matcher
GlobalErrorStatus    ErrorStatusClass,THREAD
GlobalErrors         ErrorClass                            ! Global error manager
INIMgr               INIClass                              ! Global non-volatile storage manager
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
  INIMgr.Init('.\TRACE.INI', NVD_INI)                      ! Configure INIManager to use INI file
  DctInit
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

