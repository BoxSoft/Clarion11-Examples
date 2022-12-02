DDEServer   PROGRAM
!Updated 8/2003

       INCLUDE('KEYCODES.CLW')

       MAP
         Starter
         Server
         INCLUDE('DDE.CLW')
       END

Application CSTRING(64)
Topic       CSTRING(64)
nChildren   LONG(0)

AppFrame            APPLICATION('DDE SERVER Example'),SYSTEM,MAX,AT(,,264,157),FONT('Microsoft Sans Serif', 10,, FONT:regular, CHARSET:DEFAULT),RESIZE
                        TOOLBAR, AT(0,0,264,24), USE(?TOOLBAR1)
                            PANEL, AT(1,1,263,23), USE(?PANEL1), BEVEL(2,-2)
                            BUTTON, AT(28,3,24,19), USE(?ExitApp), ICON(ICON:Cross), TIP('Exit the Example program')
                            BUTTON, AT(3,3,24,19), USE(?Starter), ICON(ICON:Frame), TIP('Start a DDE session')
                        END
                    END

  CODE
  OPEN(AppFRAME)
  DISPLAY
  ACCEPT
    CASE ACCEPTED()
    OF ?Starter
      START(STARTER)
    OF ?ExitApp
       CLOSE(AppFRAME)
       RETURN
    END
  END

Starter PROCEDURE
MainWindow WINDOW('Clarion DDE Server'),AT(,,189,75),CENTER,SYSTEM,GRAY,MAX,RESIZE,MDI
     PROMPT('Application:'),AT(8,12),USE(?Prompt1)
     ENTRY(@s20),AT(48,12,132,10),USE(Application)
     PROMPT('Topic:'),AT(8,28)
     ENTRY(@s20),AT(48,28,132,10),USE(Topic)
     BUTTON('Start'),TIP('Start a DDE Thread '),AT(8,56,40,12),FONT('MS Sans Serif',10,,FONT:regular),USE(?Start)
     BUTTON('&Exit'),AT(52,56,40,12),FONT('MS Sans Serif',10,,FONT:regular),USE(?Exit)
   END



  CODE
  OPEN(MainWindow)
  ACCEPT
    CASE ACCEPTED()
    OF ?Start
      IF Application = '' THEN
        BEEP
        SELECT(?Application)
        CYCLE
      END
      IF Topic = '' THEN
        BEEP
        SELECT(?Topic)
        CYCLE
      END
      nChildren += 1
      START(Server)

    OF ?Exit
      IF nChildren THEN
        BEEP
      ELSE
        RETURN
      END
    END
  END

Server  PROCEDURE

Event           CSTRING(128)
Item            CSTRING(128)
Value           CSTRING(128)
Data            CSTRING(128)
DDETopic        CSTRING(128)
DDEApplication  CSTRING(128)

ServerWindow WINDOW('No Link Established'),AT(,,205,140),CENTER,GRAY,MDI
     GROUP('Data'),AT(8,4,188,28),BOXED
     ENTRY(@s128),AT(16,16,172,10),USE(Data)
     END
     GROUP('Link Information'),AT(8,36,188,84),FONT('MS Sans Serif',10,,FONT:bold),BOXED
     PROMPT('Event:'),AT(16,52),FONT('MS Sans Serif',10,,FONT:regular)
     STRING(@s128),AT(56,52,128,10),FONT('MS Sans Serif',10,,FONT:bold),USE(Event)
     PROMPT('Application:'),AT(16,64),FONT('MS Sans Serif',10,,FONT:regular)
     STRING(@s128),AT(56,64,128,10),FONT('MS Sans Serif',10,,FONT:bold),USE(DDEApplication)
     PROMPT('Topic'),AT(16,76),FONT('MS Sans Serif',10,,FONT:regular)
     STRING(@s128),AT(56,76,128,10),FONT('MS Sans Serif',10,,FONT:bold),USE(DDETopic)
     PROMPT('Item:'),AT(16,88),FONT('MS Sans Serif',10,,FONT:regular)
     STRING(@s128),AT(56,88,128,10),FONT('MS Sans Serif',10,,FONT:bold),USE(Item)
     PROMPT('Value:'),AT(16,100),FONT('MS Sans Serif',10,,FONT:regular)
     STRING(@s128),AT(56,100,128,10),FONT('MS Sans Serif',10,,FONT:bold),USE(Value)
     END
     BUTTON('&Exit'),AT(8,124,40,12),FONT('MS Sans Serif',10,,FONT:regular),USE(?ServerExit)
   END

Server    LONG

  CODE
  Data = 'No Data'
  Value = ''
  OPEN(ServerWindow)
  ServerWindow{PROP:Text} = 'DDE Server ' & Application & ' : ' & Topic
  Server = DDESERVER(Application, Topic)
  ACCEPT
    CASE EVENT()
    OF EVENT:ACCEPTED
      CASE ACCEPTED()
      OF ?ServerExit
        nChildren -= 1
        RETURN
      END
    OF EVENT:DDEEXECUTE
      DDETopic = DDETOPIC()
      DDEApplication = DDEAPP()
      Event = 'EVENT:DDEEXECUTE'
      Item = DDEITEM()
      Value = DDEVALUE()
      POST(EVENT:GAINFOCUS)
      DISPLAY
    OF EVENT:DDEadvise
      DDETopic = DDETOPIC()
      DDEApplication = DDEAPP()
      Event = 'EVENT:DDEadvise'
      Item = DDEITEM()
      Value = DDEVALUE()
      DDEWRITE(Server, 2, 'AutoData', Data)
    OF EVENT:DDErequest
      DDETopic = DDETOPIC()
      DDEApplication = DDEAPP()
      Event = 'EVENT:DDErequest'
      Item = DDEITEM()
      Value = DDEVALUE()
      DDEWRITE(Server, DDE:manual, 'ManualData', Data)
    OF EVENT:DDEpoke
      DDETopic = DDETOPIC()
      DDEApplication = DDEAPP()
      Event = 'EVENT:DDEPOKE'
      Item = DDEITEM()
      Value = DDEVALUE()
      Data = Value
      DISPLAY(?Data)
    END
  END

