    PROGRAM
    INCLUDE('KEYCODES.CLW')
    MAP
      INCLUDE('OCX.CLW')                    !from LibSrc
SelectOleServer FUNCTION(OleQ PickQ),STRING
    END
    INCLUDE('ERRORS.CLW')             !Include errorcode constants
SaveLinks   FILE,DRIVER('TopSpeed'),PRE(SAV),CREATE
Object        BLOB
Record        RECORD
LinkWidth       BYTE                  ! 32 = 32-bit
LinkType        STRING(1)             !F = File, B = BLOB
LinkFile        STRING(64)            !OLE Compound Storage file name and object
              END
           END
BitWidth   BYTE(32)                   !32-bit OLE objects

i          LONG                       !Loop counters
j          LONG
ResultQ    QUEUE                      !Queue to hold return from OLEDIRECTORY
Name         CSTRING(64)
CLSID        CSTRING(64)
ProgID       CSTRING(64)
           END
MainWin WINDOW('OLE Demo'),AT(,,313,158),STATUS(-1,-1),TIMER(1),SYSTEM,GRAY,MAX,RESIZE
       MENUBAR
         MENU('&File')
           ITEM('e&xit'),USE(?exit)
         END
         MENU('&Objects')
           ITEM('Create Object'),USE(?CreateObject)
           ITEM('Paste Object'),USE(?PasteObject),DISABLE
           ITEM('PasteLink Object'),USE(?PasteLinkObject),DISABLE
           ITEM('Save Object to BLOB'),USE(?SaveObjectBlob),DISABLE
           ITEM('Save Object to OLE File'),USE(?SaveObjectFile),DISABLE
           ITEM('Retrieve Saved Object'),USE(?GetObject),DISABLE
         END
         MENU('&Activate')
           ITEM('&Any OLE Object'),USE(?ActiveOLE),DISABLE
         END
       END
       OLE,AT(0,1,313,157),USE(?AnyOLEObject),FULL,COMPATIBILITY(01H),AUTOSIZE
         MENUBAR
           MENU('&Clarion App')
             ITEM('&Deactivate Object'),USE(?DeactOLE)
           END
         END
       END
     END
  CODE
  OPEN(SaveLinks)
  IF ERRORCODE()                            !Check for error on Open
    IF ERRORCODE() = NoFileErr              ! if the file doesn't exist
      CREATE(SaveLinks)                     ! then create it
      IF ERRORCODE() THEN HALT(,ERROR()).
        OPEN(SaveLinks)                     ! then open it for use
        IF ERRORCODE() THEN HALT(,ERROR()).
    ELSE
      HALT(,ERROR())
    END
  END
  OPEN(MainWin)
  MainWin{PROP:StatusText,1} = 'Loading saved object'
  DISPLAY
  IF RECORDS(SaveLinks)                       !Check for existing saved record
    SET(SaveLinks)                            ! and get it
    NEXT(SaveLinks)
    IF BitWidth = SAV:LinkWidth               !Check object's bit width
      POST(EVENT:Accepted,?GetObject)         ! and display it if same as 
      DO MenuEnable                           ! the current compile
    ELSE
      CLEAR(SAV:Record)                       !Otherwise, lose the object
      SAV:Object{PROP:Size} = 0
      PUT(SaveLinks)
    END
  ELSE
    ADD(SaveLinks)                            ! or add blank record
  END
  IF ERRORCODE() THEN HALT(,ERROR()).
  MainWin{PROP:StatusText,1} = ''
  SETCURSOR
  ACCEPT
    CASE EVENT()
    OF EVENT:CloseWindow
      ?AnyOLEObject{PROP:Deactivate}
    OF EVENT:Timer
      IF CLIPBOARD()
        IF ?AnyOLEObject{PROP:CanPaste}         !Can Paste object from the clipboard?
          IF ?PasteObject{PROP:Disable} THEN ENABLE(?PasteObject).
        ELSIF NOT ?PasteObject{PROP:Disable}
          DISABLE(?PasteObject)
        END
        IF ?AnyOLEObject{PROP:CanPasteLink}     !Can PasteLink object from clipboard?
          IF ?PasteLinkObject{PROP:Disable} THEN ENABLE(?PasteLinkObject).
        ELSIF NOT ?PasteLinkObject{PROP:Disable}
          DISABLE(?PasteLinkObject)
        END
      END
    OF EVENT:Accepted
      CASE FIELD()
      OF ?Exit
        POST(EVENT:CloseWindow)
      OF ?CreateObject
        FREE(ResultQ)
        OLEDIRECTORY(ResultQ,0)                                !Get a list of installed OLE Servers
        ?AnyOLEObject{PROP:Create} = SelectOleServer(ResultQ)  !Let the user pick one
        ?AnyOLEObject{PROP:DoVerb} = 0                         !Activate OLE Server in its default mode
        DO MenuEnable
      OF ?PasteObject
        ?AnyOLEObject{PROP:Paste}                    !Paste the object
        SETCLIPBOARD('Paste Completed')              !Assign non-object text to clipboard
        DO MenuEnable
      OF ?PasteLinkObject                                
        ?AnyOLEObject{PROP:PasteLink}                 !PasteLink the object
        SETCLIPBOARD('PasteLink Completed')           !Assign non-object text to clipboard
        DO MenuEnable
      OF ?SaveObjectBlob                              !Save object to BLOB
        SAV:Object{PROP:Size} = 0                     !Clear any current object
        SAV:Object{PROP:Handle} = ?AnyOLEObject{PROP:Blob}
        SAV:LinkType = 'B'
        SAV:LinkWidth = BitWidth
        PUT(SaveLinks)
        IF ERRORCODE() THEN STOP(ERROR()).
      OF ?SaveObjectFile                              !Save to OLE Compound Storage file
        ?AnyOLEObject{PROP:SaveAs} = 'TEST1.OLE\!Object'
        SAV:LinkFile = 'TEST1.OLE\!Object'
        SAV:LinkType = 'F'
        SAV:LinkWidth = BitWidth
        PUT(SaveLinks)
        IF ERRORCODE() THEN STOP(ERROR()).
      OF ?GetObject
        IF SAV:LinkType = 'F'                         !Saved to OLE Compound Storage file?
          ?AnyOLEObject{PROP:Open} = SAV:LinkFile
        ELSIF SAV:LinkType = 'B'                      !Saved to BLOB?
          ?AnyOLEObject{PROP:Blob} = SAV:Object{PROP:Handle}
        END
        DISPLAY
      OF ?ActiveOLE
        ?AnyOLEObject{PROP:DoVerb} = 0                !Activate OLE Server in its default mode
      OF ?DeactOLE
        ?AnyOLEObject{PROP:Deactivate}                !Return to the Clarion application
      END
    END
  END

MenuEnable              ROUTINE                        !Enable menu items
  ENABLE(?ActiveOLE)
  ENABLE(?SaveObjectBlob,?GetObject)

SelectOleServer    FUNCTION(OleQ PickQ)
window WINDOW('Choose OLE Server'),AT(,,122,159),CENTER,SYSTEM,GRAY
       LIST,AT(11,8,100,120),ALRT(MouseLeft2),USE(?List),HVSCROLL,FORMAT('146L~Name~@s64@135L~CLSID~@s64@20L~ProgID~@s64@'), |
           FROM(PickQ)
       BUTTON('Select'),AT(42,134),USE(?Select)
     END
  CODE
  OPEN(window)
  SELECT(?List,1)
  ACCEPT
    IF EVENT() = EVENT:AlertKey THEN POST(EVENT:Accepted,?Select).
    CASE ACCEPTED()
    OF ?Select
      GET(PickQ,CHOICE(?List))
      IF ERRORCODE() THEN STOP(ERROR()).
      POST(EVENT:CloseWindow)
    END
  END
  RETURN(PickQ.ProgID)

