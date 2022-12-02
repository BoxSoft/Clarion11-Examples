DdeDemo   PROGRAM

  INCLUDE('KEYCODES.CLW')

  MAP
    INCLUDE('DDE.CLW')
    InsertItem
  END

sGroupName  CSTRING(128)

GroupQueue  QUEUE, PRE(GRP)
sName        CSTRING(128)
            END

sItemName   CSTRING(128)

ItemQueue   QUEUE, PRE(ITM)
sName        CSTRING(128)
            END

ShowGroup   BOOL(TRUE)

MainWindow WINDOW('DDE Demonstration'),AT(,,208,141),CENTER,GRAY
     GROUP('&Program Group'),AT(4,4,200,56),FONT('MS Sans Serif',8,,FONT:bold),USE(?ProgramGroup),BOXED
     COMBO(@s128),AT(36,20,160,10),USE(sGroupName),VSCROLL,DROP(4),FROM(GroupQueue)
     CHECK('Show Group'),AT(12,44),FONT('MS Sans Serif',10,00H,FONT:regular),USE(ShowGroup)
     BUTTON('&Delete'),AT(160,44,40,12),FONT('MS Sans Serif',10,00H,FONT:regular),USE(?DeleteGroup)
     PROMPT('Name:'),AT(12,20),FONT('MS Sans Serif',10,00H,FONT:regular)
     END
     GROUP('Program Item'),AT(4,64,200,56),FONT('MS Sans Serif',8,,FONT:bold),USE(?ProgramItem),DISABLE, |
       BOXED
     PROMPT('Name:'),AT(12,80),FONT('MS Sans Serif',10,00H,FONT:regular),USE(?Prompt2)
     COMBO(@s128),AT(36,80,160,10),USE(sItemName),VSCROLL,DROP(4),FROM(ItemQueue)
     BUTTON('&Delete'),AT(160,104,40,12),FONT('MS Sans Serif',10,00H,FONT:regular),USE(?DeleteItem)
     BUTTON('&Insert'),AT(116,104,40,12),FONT('MS Sans Serif',10,00H,FONT:regular),USE(?InsertItem)
     END
     BUTTON('&Exit'),AT(4,124,40,12),FONT('MS Sans Serif',10,,FONT:regular),USE(?ExitMain)
   END


hProgMan  LONG
sGroups   CSTRING(4096)
sItems    CSTRING(4096)
Test      CSTRING(4096)
  CODE
  OPEN(MainWindow)

  hProgMan = DDECLIENT('PROGMAN','PROGMAN')

  IF NOT hProgMan THEN
    MESSAGE('DDE Error - Unable to establish DDE conversation with PROGMAN.')
  END

  DDEREAD(hProgMan, DDE:manual, 'PROGMAN', sGroups )

  LOOP WHILE sGroups <> ''
    i# = INSTRING('<13>', sGroups, 1, 1)
    GRP:sName = SUB(sGroups, 1, (i# - 1))
    GET(GroupQueue,GRP:sName)
     IF ERRORCODE()
      ADD(GroupQueue,GRP:sName)
     END
    sGroups = SUB(sGroups, i# + 2, LEN(sGroups) - (i# + 1))
  END

  SORT(GroupQueue, +GRP:sName)
  DISPLAY
  ACCEPT
    CASE EVENT()
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?sGroupName
        GRP:sName = sGroupName
        GET(GroupQueue,GRP:sName)
        IF ERRORCODE() THEN
          DDEEXECUTE(hProgMan, '[CreateGroup(' & sGroupName & ')]')
          ADD(GroupQueue, +GRP:sName)
        ELSE
          IF ShowGroup THEN
            DDEEXECUTE(hProgMan, '[ShowGroup(' & sGroupName & ',1)]')
          END
          ENABLE(?ProgramItem)
        END

        FREE(ItemQueue)

        sItems= ''
        DDEREAD(hProgMan, DDE:manual,sGroupName, sItems)

        i# = INSTRING('<13>', sItems, 1, 1)
        sItems = SUB(sItems, i# + 2, LEN(sItems) - (i# + 1))

        LOOP WHILE sItems <> ''
          i# = INSTRING('"', sItems, 1, 1)
          i# += 1
          ITM:sName = SUB(sItems, i#, (INSTRING('"', sItems,1,i#) - i#))
          ADD(ItemQueue)
          i# = INSTRING('<13>', sItems, 1, 1)
          sItems = SUB(sItems, i# + 2, LEN(sItems) - (i# + 1))
        END

        SORT(ItemQueue, +ITM:sName)
        SELECT(?sItemName, 1)
        DISPLAY(?sItemName)

      OF ?DeleteGroup
        IF CHOICE(?sGroupName) THEN
          DDEEXECUTE(hProgMan, '[DeleteGroup(' & sGroupName & ')]')
          DELETE(GroupQueue)
          sGroupName = ''
          DISPLAY(?sGroupName)
        END

      OF ?InsertItem
        InsertItem()
        SELECT(?sItemName, 1)
        DISPLAY(?sItemName)

      OF ?DeleteItem
        IF CHOICE(?sItemName) THEN
          DDEEXECUTE(hProgMan, '[DeleteItem(' & sItemName & ')]')
          DELETE(ItemQueue)
          SELECT(?sItemName, 1)
          DISPLAY(?sItemName)
        END

      OF ?ExitMain
        RETURN
      END
    END
  END

InsertItem  PROCEDURE
sName     CSTRING(128)
sTarget   CSTRING(128)

InsertWindow WINDOW('DDE Demonstration'),AT(,,197,74),CENTER,GRAY
     PROMPT('Name:'),AT(12,12),FONT('MS Sans Serif',10,,FONT:regular)
     ENTRY(@s128),AT(40,12,148,10),USE(sName)
     PROMPT('Target:'),AT(12,32),FONT('MS Sans Serif',10,,FONT:regular)
     ENTRY(@s128),AT(40,32,140,10),USE(sTarget)
     BUTTON('...'),AT(180,32,10,10),FONT('MS Sans Serif',10,,FONT:regular),USE(?Dialog)
     BUTTON('&Cancel'),AT(52,56,40,12),FONT('MS Sans Serif',10,,FONT:regular),USE(?Cancel)
     BUTTON('&OK'),AT(4,56,40,12),FONT('MS Sans Serif',10,,FONT:regular),USE(?OK)
   END

  CODE
  OPEN(InsertWindow)

  ACCEPT
    CASE ACCEPTED()
    OF ?OK
      IF sName = '' OR sTarget = '' THEN
        BEEP
        CYCLE
      END
      DDEEXECUTE(hProgMan,'[AddItem(' & sTarget & ',' & sName & ')]')
      RETURN

    OF ?Cancel
      RETURN

    OF ?Dialog
      IF FILEDIALOG('Select Target File', sTarget, 'Command (*.com)|*.com|Executable (*.exe)|*.EXE|Batch (*.bat)|*.BAT|All files(*.*)|*.*', 0) THEN
        ITM:sName = sName
        ADD(ItemQueue)
        DISPLAY(?sTarget)
      END
    END
  END

