   PROGRAM



   INCLUDE('ABERROR.INC'),ONCE
   INCLUDE('ABFILE.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ERRORS.CLW'),ONCE
   INCLUDE('KEYCODES.CLW'),ONCE

   MAP
     MODULE('PEOPLE_BC.CLW')
DctInit     PROCEDURE                                      ! Initializes the dictionary definition module
DctKill     PROCEDURE                                      ! Kills the dictionary definition module
     END
     MODULE('PEOPLE001.CLW')
Updatepeople           PROCEDURE   !Update the people File
Browsepeople           PROCEDURE   !Browse the people File
Main                   PROCEDURE   !Example EIP Application
PrintPEO:KeyId         PROCEDURE   !People File Cockpit
PrintPEO:KeyLastName   PROCEDURE   !Print the people File by PEO:KeyLastName
     END
   END

SilentRunning        BYTE(0)                               ! Set true when application is running in 'silent mode'

!region File Declaration
people               FILE,DRIVER('TOPSPEED'),PRE(PEO),CREATE,BINDABLE,THREAD !                     
KeyId                    KEY(PEO:Id),NOCASE,OPT            !                     
KeyLastName              KEY(PEO:LastName),DUP,NOCASE      !                     
Record                   RECORD,PRE()
Id                          LONG                           !                     
FirstName                   STRING(30)                     !                     
LastName                    STRING(30)                     !                     
Gender                      STRING(1)                      !                     
                         END
                     END                       

!endregion

Access:people        &FileManager,THREAD                   ! FileManager for people
Relate:people        &RelationManager,THREAD               ! RelationManager for people

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
  INIMgr.Init('.\people.INI', NVD_INI)                     ! Configure INIManager to use INI file
  DctInit()
  Main
  INIMgr.Update
  INIMgr.Kill                                              ! Destroy INI manager


Dictionary.Construct PROCEDURE

  CODE
  IF THREAD()<>1
     DctInit()
  END


Dictionary.Destruct PROCEDURE

  CODE
  DctKill()

