DDEClient   PROGRAM
!Updated 8/2003

      INCLUDE('KEYCODES.CLW')

      MAP
        Client
        INCLUDE('DDE.CLW')
      END

Application CSTRING(64)
Topic       CSTRING(64)
nChildren   LONG(0)

MainWindow WINDOW('Clarion DDE Client'),AT(,,187,73),CENTER,GRAY
     PROMPT('Application:'),AT(8,16),USE(?Prompt1)
     ENTRY(@s20),AT(48,16,132,10),USE(Application)
     PROMPT('Topic:'),AT(8,32)
     ENTRY(@s20),AT(48,32,132,10),USE(Topic)
     BUTTON('Start'),AT(4,56,40,12),FONT('MS Sans Serif',10,,FONT:regular),USE(?Start)
     BUTTON('&Exit'),AT(48,56,40,12),FONT('MS Sans Serif',10,,FONT:regular),USE(?Exit)
   END

  CODE
  OPEN(MainWindow)
  DISPLAY
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
      !nChildren += 1
      START(Client)

    OF ?Exit
      !IF nChildren THEN
      !  BEEP
      !ELSE
        RETURN
      !END
    END
  END

Client  PROCEDURE

Client          LONG
ddeCommand      CSTRING(128)
PokeValue       CSTRING(128)
Data            CSTRING(128)
DDEEvent        CSTRING(128)
DDETopic        CSTRING(128)
DDEApplication  CSTRING(128)
DDEItem         CSTRING(128)
DDEValue        CSTRING(128)
ServerWindow WINDOW('No Link Established'),AT(,,294,200),FONT('MS Sans Serif',10,,FONT:regular),SYSTEM, |
     GRAY,MAX,RESIZE
     GROUP('DDEEXECUTE'),AT(8,4,262,32),FONT('MS Sans Serif',8,,FONT:bold),BOXED
     ENTRY(@s128),AT(66,15,128,10),USE(ddeCommand)
     PROMPT('Command:'),AT(16,16,40,10),FONT('MS Sans Serif',10,00H,FONT:regular)
     BUTTON('E&xecute'),AT(202,14,40,12),FONT('MS Sans Serif',10,00H,FONT:regular),USE(?Execute)
     END
     GROUP('DDEPOKE'),AT(8,39,262,32),FONT('MS Sans Serif',8,,FONT:bold),BOXED
     ENTRY(@s128),AT(65,50,128,10),USE(PokeValue)
     PROMPT('Value:'),AT(22,51,23,10),FONT('MS Sans Serif',10,,FONT:regular)
     BUTTON('&Poke'),AT(202,49,40,12),FONT('MS Sans Serif',10,00H,FONT:regular),USE(?Poke)
     END
     GROUP('DDEREAD'),AT(8,75,262,32),FONT('MS Sans Serif',8,,FONT:bold),BOXED
     PROMPT('Data:'),AT(15,88),FONT('MS Sans Serif',10,00H,FONT:regular)
     STRING(@s128),AT(40,88,128,10),FONT('MS Sans Serif',10,00H,FONT:bold),USE(Data)
     BUTTON('&Auto'),AT(175,86,40,12),FONT('MS Sans Serif',10,00H,FONT:regular),USE(?Auto)
     BUTTON('&Manual'),AT(222,86,40,12),FONT('MS Sans Serif',10,00H,FONT:regular),USE(?Manual)
     END
     GROUP('Link Information'),AT(8,112,262,80),FONT('MS Sans Serif',8,,FONT:bold),BOXED
     BUTTON('&Close'),AT(211,127,40,12),FONT('MS Sans Serif',10,,FONT:regular),USE(?ClientExit)
     PROMPT('Event:'),AT(16,128,29,10),FONT('MS Sans Serif',10,00H,FONT:regular)
     STRING(@s128),AT(60,128,128,10),FONT('MS Sans Serif',10,00H,FONT:bold),USE(DDEEvent)
     PROMPT('Application:'),AT(16,140,40,10),FONT('MS Sans Serif',10,00H,FONT:regular)
     STRING(@s128),AT(60,140,128,10),FONT('MS Sans Serif',10,00H,FONT:bold),USE(DDEApplication)
     PROMPT('Topic:'),AT(16,152,32,10),FONT('MS Sans Serif',10,00H,FONT:regular)
     STRING(@s128),AT(60,152,128,),FONT('MS Sans Serif',10,00H,FONT:bold),USE(DDETopic)
     PROMPT('Item:'),AT(16,164,36,10),FONT('MS Sans Serif',10,00H,FONT:regular)
     STRING(@s128),AT(60,164,128,10),FONT('MS Sans Serif',10,00H,FONT:bold),USE(DDEItem)
     PROMPT('Item:'),AT(32,164,16,10),FONT('MS Sans Serif',10,00H,FONT:regular)
     PROMPT('Value:'),AT(16,176,36,10),FONT('MS Sans Serif',10,00H,FONT:regular)
     STRING(@s128),AT(60,176,128,10),FONT('MS Sans Serif',10,00H,FONT:bold),USE(DDEValue)
     END
   END

  CODE
  OPEN(ServerWindow)
  ServerWindow{PROP:Text} = 'DDE Client ' & Application & ' : ' & Topic
  Client = DDECLIENT(Application, Topic)
  IF NOT Client THEN
    MESSAGE('Unable to open DDECLIENT(' & Application & ',' & Topic &')')
    RETURN
  END
  ACCEPT
    CASE EVENT()
    OF EVENT:ACCEPTED
      CASE ACCEPTED()
      OF ?Execute
        DDEEXECUTE(Client, ddeCommand)
      OF ?Poke
        DDEPOKE(Client, 'PokeData', PokeValue)
      OF ?Auto
        DISABLE(?Manual)
        DDEREAD(Client, DDE:auto, 'AutoData', Data)
      OF ?Manual
        DISABLE(?Auto)
        DDEREAD(Client, DDE:manual, 'Manualdata', Data)
      OF ?ClientExit
        nChildren -= 1
        RETURN
      END
    OF EVENT:DDEdata
      DDEEvent = 'EVENT:DDEdata'
      DDEApplication = DDEAPP()
      DDETopic = DDETOPIC()
      DDEItem = DDEITEM()
      DDEValue = DDEVALUE()
      DISPLAY(?DDEValue)
      BEEP
    END
  END

