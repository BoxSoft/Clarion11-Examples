  PROGRAM


  MAP
  END

 INCLUDE('equates.clw'),ONCE 
 
 INCLUDE ('CWSYNCWT.INC'),ONCE
LOC:ShowMessage        BYTE
LOC:Message            STRING(20)


MyWindow WINDOW('WorkingThread Example'),AT(,,192,110),GRAY,FONT('MS Sans Serif', |
            8,,FONT:regular)
        BUTTON('cancel Thread'),AT(22,55,116,14),USE(?CancelThread),DEFAULT,LEFT
        BUTTON('Close'),AT(144,82,36,14),USE(?CancelButton),LEFT
        ENTRY(@s20),AT(22,12,115),USE(LOC:Message)
        BUTTON('Show Message'),AT(22,28,116),USE(?BUTTONShowMessage)
    END


MyThreadWork CLASS(WorkingThreadManager)
varShowMessage        LIKE(LOC:ShowMessage),PRIVATE       ! Should be private to enforce the thread safety
tmpShowMessage        LIKE(LOC:ShowMessage),PRIVATE       ! Should be private to enforce the thread safety
varMessage            LIKE(LOC:Message),PRIVATE ! and are only accessed thru the DoAssignFromClass and DoAssignToClass
tmpMessage            LIKE(LOC:Message),PRIVATE ! and are only accessed thru the DoAssignFromClass and DoAssignToClass
WorkingThreadProcess  PROCEDURE(),DERIVED,PROTECTED
WhenProcessFinish     PROCEDURE(),DERIVED,PROTECTED
DoAssignToClassTmp    PROCEDURE(BYTE pVal=0),DERIVED,PROTECTED ! Derived to move data between
DoAssignFromClassTmp  PROCEDURE(BYTE pVal=0),DERIVED,PROTECTED ! the class and the procedure
DoWriteToClassTmp     PROCEDURE(BYTE pVal=0),DERIVED,PROTECTED ! Derived to move data between
DoReadFromClassTmp    PROCEDURE(BYTE pVal=0),DERIVED,PROTECTED ! the class and the procedure


 END
 
  CODE
 OPEN(MyWindow)
 0{PROP:Text} = 0{PROP:Text}&'('&THREAD()&')'
 ACCEPT
    CASE FIELD()
    OF 0
       CASE EVENT()
       OF EVENT:OpenWindow
       END
    OF ?BUTTONShowMessage
       CASE EVENT()
       OF EVENT:Accepted
          IF NOT MyThreadWork.IsStarted()
             MyThreadWork.StartProcess()
          END
          IF MyThreadWork.IsStarted()
             LOC:ShowMessage = true
             MyThreadWork.AssignToClass()
          END
          !DISABLE(?OkButton)
       END
    OF ?CancelThread
       CASE EVENT()
       OF EVENT:Accepted
          MyThreadWork.CancelProcess()
       END
    OF ?CancelButton
       CASE EVENT()
       OF EVENT:Accepted
          POST(EVENT:CloseWindow)
       END
    END
    MyThreadWork.TakeEvent()
 END
 MyThreadWork.CancelProcess()


MyThreadWork.WorkingThreadProcess    PROCEDURE()
lMessage STRING(20)
 CODE
    !loop till the process is Cancelled or Finish
    LOOP
       IF SELF.IsCancelled()
          BREAK
       END
       SELF.ReadFromClassTmp()
       IF SELF.varShowMessage
          SELF.varShowMessage = FALSE          
          lMessage = SELF.varMessage
          SELF.varMessage = '' 
          SELF.WriteToClassTmp()
          IF MESSAGE(lMessage&'|'&'Do you want to finish the thread process?','Finish? ('&THREAD()&')',,BUTTON:YES+BUTTON:NO, BUTTON:NO) = BUTTON:YES
             !this break will finish the process (LOOP)
             !SELF.UpdateCaller()
             BREAK
          END
       END
    END
    IF SELF.IsCancelled()
       MESSAGE('This is a separated thread than the UI|And the process LOOP was cancelled|and will end','On Thread ('&THREAD()&')')
    ELSE
       MESSAGE('This is a separated thread than the UI|And the process LOOP was finish', 'On Thread ('&THREAD()&')')
    END
    
MyThreadWork.WhenProcessFinish       PROCEDURE()
 CODE
    !ENABLE(?OkButton)
    IF SELF.IsCancelled()
       MESSAGE('Thread work was cancelled.')
    ELSE
       MESSAGE('Thread work finish the process')
    END
    
    
MyThreadWork.DoAssignToClassTmp       PROCEDURE(BYTE pVal=0)
 CODE
    !The assignment is thead safe
    SELF.tmpMessage     = LOC:Message
    SELF.tmpShowMessage = LOC:ShowMessage
    
MyThreadWork.DoAssignFromClassTmp     PROCEDURE(BYTE pVal=0)
 CODE
    !The read is thead safe
    LOC:Message = SELF.tmpMessage
    LOC:ShowMessage = SELF.tmpShowMessage

MyThreadWork.DoWriteToClassTmp       PROCEDURE(BYTE pVal=0)
 CODE
    !The assignment is thead safe
    SELF.tmpMessage     = SELF.varMessage     
    SELF.tmpShowMessage = SELF.varShowMessage
    
MyThreadWork.DoReadFromClassTmp     PROCEDURE(BYTE pVal=0)
 CODE
    !The read is thead safe
    SELF.varMessage     = SELF.tmpMessage
    SELF.varShowMessage = SELF.tmpShowMessage
