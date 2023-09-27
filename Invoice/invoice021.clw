

   MEMBER('invoice.clw')                                   ! This is a MEMBER module

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
  RETURN Guid
    
!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
BrowseInvoice        PROCEDURE                             ! Declare Procedure

  CODE
  BrowseInvoice:Window()
  
!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
LogoutInvoice        PROCEDURE  (BOOL ShowErrorMessage=App:ShowMessage)!,LONG ! Declare Procedure

  CODE
  LOGOUT(5, Invoice)
  CASE ERRORCODE()
  OF NoError
    RETURN Level:Benign
  END
  !Log error?
  IF ShowErrorMessage
    !Show message
  END
  RETURN Level:Notify
!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
NextInvoiceNumber    PROCEDURE                             ! Declare Procedure
Invoice::State  USHORT
FilesOpened     BYTE(0)
ReturnValue             LIKE(Inv:InvoiceNumber)

  CODE
? DEBUGHOOK(Invoice:Record)
  DO OpenFiles
  DO SaveFiles

  IF Invoice{PROP:SQLDriver} = FALSE
    !Trace('NextInvoiceNumber: ISAM')
    DO HandleISAM
  ELSE
    !Trace('NextInvoiceNumber: SQL')
    DO HandleSQL
  END
  
  DO RestoreFiles
  DO CloseFiles
  !Trace('NextInvoiceNumber: '& ReturnValue)
  Return ReturnValue
HandleISAM                    ROUTINE
  SET(Inv:InvoiceNumberKey)
  PREVIOUS(Invoice)
  CASE ERRORCODE()
  OF NoError
    ReturnValue = Inv:InvoiceNumber + 1
  ELSE
    ReturnValue = 1
  END

HandleSQL                     ROUTINE
  Invoice{PROP:SQL} = 'SELECT MAX(InvoiceNumber) FROM '& Invoice{PROP:Name}  !Returns value in first field of Record
  NEXT(Invoice)
  ReturnValue = Inv:GUID + 1  !This is the first field in the record
SaveFiles  ROUTINE
  Invoice::State = Access:Invoice.SaveFile()               ! Save File referenced in 'Other Files' so need to inform its FileManager
RestoreFiles  ROUTINE
  IF Invoice::State <> 0
    Access:Invoice.RestoreFile(Invoice::State)             ! Restore File referenced in 'Other Files' so need to inform its FileManager
  END
!--------------------------------------
OpenFiles  ROUTINE
  Access:Invoice.Open()                                    ! Open File referenced in 'Other Files' so need to inform it's FileManager
  Access:Invoice.UseFile()                                 ! Use File referenced in 'Other Files' so need to inform it's FileManager
  FilesOpened = True
!--------------------------------------
CloseFiles ROUTINE
  IF FilesOpened THEN
     Access:Invoice.Close()
     FilesOpened = False
  END
!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
Trace                PROCEDURE  (STRING DebugMessage)      ! Declare Procedure
szMsg                   CSTRING(size(DebugMessage)+7),AUTO

  CODE
  PUSHERRORS()
  szMsg = '[app] ' & Clip(DebugMessage)
  appOutputDebugString(szMsg)
  POPERRORS()
  
!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
CallUpdateConfiguration PROCEDURE                          ! Declare Procedure
FilesOpened     BYTE(0)

  CODE
  DO OpenFiles
  
  IF RECORDS(Configuration) = 0
    Access:Configuration.PrimeRecord()
    !Any other field defaults
    IF Access:Configuration.Insert() <> Level:Benign
      DO CloseFiles
      RETURN
    END
  END
  
  SET(Configuration)
  WATCH(Configuration)
  IF Access:Configuration.Next() <> Level:Benign
    MESSAGE('Cannot fetch Configuration')
  ELSE
    GlobalRequest = ChangeRecord
    UpdateConfiguration()
  END
  
  DO CloseFiles
  
!--------------------------------------
OpenFiles  ROUTINE
  FilesOpened = True
!--------------------------------------
CloseFiles ROUTINE
  IF FilesOpened THEN
     FilesOpened = False
  END
