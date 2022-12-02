  PROGRAM

NameQ QUEUE,TYPE
name   CSTRING(260)
     END

BrowseBase  CSTRING(260)
BrowseQ     QUEUE(NameQ)
uname         CSTRING(260)
            END

FullScreen      BYTE
TimeDelay        LONG
BrowseExtensions CSTRING(260)

  MAP
    SwapImage (*SIGNED,*SIGNED)
    LoadImage(SIGNED, STRING, SIGNED,SIGNED,SIGNED,SIGNED),BYTE
    ResizeImage(SIGNED, SIGNED,SIGNED,SIGNED,SIGNED)
    GetAllFiles (STRING dir, BrowseQ dirq, WINDOW)
    Browse()
    GetDefaultOptions()
    SaveOptions()
    MODULE('MATCH.CPP')
      Match(*CSTRING,*CSTRING),SIGNED,RAW,NAME('_match')
      MatchSet(*CSTRING,*CSTRING),SIGNED,RAW,NAME('_matchset')
    END
  END
  INCLUDE('keycodes')

  CODE
  GetDefaultOptions()
  Browse()

GetDefaultOptions PROCEDURE
  CODE
  FILEDIALOG('Choose Images Directory',BrowseBase,,FILE:Directory) 
  IF ~BrowseBase
    BrowseBase = PATH()
  END
  IF BrowseBase[LEN(CLIP(BrowseBase))] ~= '\'
    BrowseBase = BrowseBase & '\'
  END
  BrowseExtensions = GETINI('Image Browser', 'Browse Extensions','*.jpg;*.gif')
  FullScreen = GETINI('Image Browser', 'Full screen','0')
  TimeDelay = GETINI('Image Browser', 'Delay','200')
  SaveOptions()

SaveOptions PROCEDURE
  CODE
  PUTINI('Image Browser', 'Browse Extensions', BrowseExtensions)
  PUTINI('Image Browser', 'Full screen', FullScreen)
  PUTINI('Image Browser', 'Delay', TimeDelay)

Browse PROCEDURE
window WINDOW('Viewer'),AT(,,281,211),COLOR(COLOR:Black),IMM,STATUS(200,100,100,100),TIMER(5),PALETTE(256), |
         MAX,RESIZE
       IMAGE,AT(110,61),USE(?Image1),HIDE
       IMAGE,AT(110,61),USE(?Image2),HIDE
       BOX,AT(-1,0,282,212),USE(?fullb),FULL,FILL(COLOR:White)
       STRING('Loading...'),AT(-1,0,282,212),USE(?wait),TRN,FULL,CENTER
     END

n     SHORT
count SHORT
held  SHORT
write SHORT(1)
winw  SIGNED
winh  SIGNED
?next SIGNED(?image1)
?current SIGNED(?image2)
?temp SIGNED
lastclock  LONG
fulltext STRING(20)
nextempty BYTE(1)
  CODE
  OPEN(window)
  window{PROP:pixels} = 1
  ALERT(SpaceKey)
  ALERT(Bkey)
  ALERT(Hkey)
  ACCEPT
    CASE EVENT()
    OF Event:OpenWindow
      winh = ?fullb{PROP:height}
      winw = ?fullb{PROP:width}
      ?wait{PROP:ypos} = winh/2
      ?image1{PROP:alrt, 1} = MouseRight
      ?image2{PROP:alrt, 1} = MouseRight
      GetAllFiles(BrowseBase, BrowseQ, Window)
      SORT(BrowseQ, +BrowseQ.uname)
      DO SetFull
      HIDE(?fullb,?wait)
      DISPLAY
      POST(Event:Timer)
    OF Event:Sized
      winh = ?fullb{PROP:height}
      winw = ?fullb{PROP:width}
      IF ?Current{Prop:Height} > winh OR ?Current{Prop:Width} > winw
        ResizeImage(?current,0,0,winw,winh)
      END
    OF Event:Timer
      IF (LastClock=0 OR CLOCK()-LastClock > TimeDelay) AND NOT Held
        DO LoadNew
      END
      IF nextempty THEN
        DO GetNextImage
      END
    OF EVENT:AlertKey
      CASE KEYCODE()
      OF MouseRight
        EXECUTE POPUP('&Hold|-|'&Fulltext&'|E&xit')
          Held = 1 - held
          ;
          DO FullToggle
          BREAK
        END
        lastclock = CLOCK()
      OF HKey
       Held = 1 - Held
      OF BKey
        n -= 3
        IF n < 0
          n += RECORDS(BrowseQ)
        END
        held = 1
        nextempty = 1
        DO LoadNew
      OF SpaceKey
        DO LoadNew
      END
    END
  END

LoadNew ROUTINE
  IF NextEmpty
    DO GetNextImage
  END
  LastClock = CLOCK()
  ?temp = ?current
  ?current = ?next
  ?next = ?temp
  IF ?Current{Prop:Height} > winh OR ?Current{Prop:Width} > winw
    ResizeImage(?current,0,0,winw,winh)
  END
  HIDE(?next)
  IF NOT 0{PROP:maximize}
    0{PROP:text} = ?current{PROP:text}
  END
  0{PROP:statustext, 1} = ?current{PROP:text}
  UNHIDE(?current)
  DISPLAY
  NextEmpty = TRUE

SetFull ROUTINE
  IF FullScreen
    0{PROP:noframe} = 1
    0{PROP:status} = 0
    0{PROP:text} = ''
    0{PROP:maximize} = 1
    POST(Event:Sized)
    FullText = 'Normal window'
  ELSE
    0{PROP:maximize} = 0
    0{PROP:resize} = 1
    0{PROP:status,1} = 200
    0{PROP:status,2} = 100
    0{PROP:status,3} = 100
    0{PROP:status,4} = 100
    0{PROP:text} = ?{PROP:text}
    POST(Event:Sized)
    FullText = 'Full screen'
  END

FullToggle ROUTINE
  IF FullScreen
    FullScreen = 0
  ELSE
    FullScreen = 1
  END
  DO SetFull
  SaveOptions()

GetNextImage ROUTINE
  LOOP WHILE records(BrowseQ)>0
    n += 1
    IF (n>RECORDS(BrowseQ))
      n = 1
    END
    GET(BrowseQ,n)
    IF LoadImage(?next, BrowseQ.name, 0, 0, winw, winh)
      BREAK
    ELSE
      DELETE(BrowseQ)
      n -= 1
    END
  END
  NextEmpty = FALSE

SwapImage PROCEDURE(?current, ?next)
?i1 SIGNED
?i2 SIGNED
  CODE
  ?i1 = ?current
  ?i2 = ?next
  IF ?i1{PROP:hide}
    ?next = ?i2
    ?current = ?i1
  ELSE
    ?next = ?i1
    ?current = ?i2
  END

LoadImage PROCEDURE(?myimage, name, winx, winy, winw, winh)
w  SIGNED
h  SIGNED
  CODE
!  ?myimage{PROP:height} = 080000000h
!  ?myimage{PROP:width} = 080000000h
  ?myimage{PROP:Noheight} = True
  ?myimage{PROP:Nowidth} = True

  ?myimage{PROP:text} = Name
  IF NOT ?myimage{PROP:text} 
    RETURN FALSE
  ELSE
    RETURN TRUE
  END

ResizeImage PROCEDURE(?myimage, winx, winy, winw, winh)
w  SIGNED
h  SIGNED
  CODE
  h = ?myimage{PROP:height}
  w = ?myimage{PROP:width}
  0{PROP:statustext,2} = w & 'x' & h
  IF w/h > winw/winh
    h = h * winw/w
    w = winw
  ELSE
    w = w * winh/h
    h = winh
  END
  SETPOSITION(?myimage, (winw-w)/2, (winh-h)/2, w, h)

GetAllFiles PROCEDURE(STRING dir, BrowseQ DestQ, WINDOW ww)
ffq  QUEUE,PRE(ffq)
Name           STRING(FILE:MaxFileName)
fName      STRING(13)
Date           LONG
Time           LONG
Size           LONG
Attrib         BYTE
     END
name CSTRING(260)
i    SHORT
  CODE
  name = CLIP(dir)
  ww{PROP:statustext, 1} = dir
  DISPLAY
  DIRECTORY(ffq, dir & '*.*', 0)
  LOOP i = 1 to RECORDS(ffq)
    GET(ffq, i)
    name = CLIP(ffq:name)
    IF MatchSet(name, BrowseExtensions) 
      DestQ:name = dir & name
      DestQ.uname = UPPER(DestQ.name)
      ADD(DestQ)
    END
  END
  FREE(ffq)
  DIRECTORY(ffq, dir & '*.*', ff_:directory)
  LOOP i = 1 to RECORDS(ffq)
    GET(ffq, i)
    IF BAND(ffq:Attrib,ff_:DIRECTORY) AND ffq:Name <> '..' AND ffq:Name <> '.' THEN
      GetAllFiles(dir & CLIP(ffq:name) & '\', DestQ, ww)
    END
  END

