     PROGRAM

     INCLUDE('KEYCODES.CLW')

     MAP
        ReadExecutable
        DumpPEExportTable(ULONG RawAddr, ULONG VirtAddr)
        DumpNEExports
        WriteLib
        ReadLib
        InfoWindow
        WriteText
     END

FileName STRING(255)            ! File name for input and output files

! LIBfile is used to read and write import library files

LIBfile  FILE,DRIVER('DOS','/FILEBUFFERS=20'),PRE(LIB),CREATE,NAME(FileName)
Record     RECORD
RawBytes     BYTE,DIM(1024)
header       GROUP,OVER(RawBytes)
typ            BYTE             ! OMF record type = 88H (Coment)
len            USHORT           ! Size of OMF record to follow
kind           USHORT           ! Comment kind = 0A000H
bla            BYTE             ! Always 1 for our purposes
ordflag        BYTE             ! ditto
             END
! For the records we want, the header is follower by the pubname
! and modname in PSTRING format, then the ordinal export number (USHORT)

pstringval   PSTRING(128),OVER(RawBytes)
ushortval    USHORT,OVER(RawBytes)
           END
         END

TxtFile  FILE,PRE(Txt),DRIVER('ASCII','/FILEBUFFERS=20'),CREATE,NAME(FileName)
Record     RECORD
Line         STRING(256)
           END
         END

! EXEfile is used for reading NE and PE format executable files

EXEfile  FILE,DRIVER('DOS','/FILEBUFFERS=20'),PRE(EXE),NAME(FileName)
Record     RECORD
RawBytes     BYTE,DIM(1024)
cstringval   CSTRING(128),OVER(RawBytes)
pstringval   PSTRING(128),OVER(RawBytes)
ulongval     ULONG,OVER(RawBytes)
ushortval    USHORT,OVER(RawBytes)

! DOSheader is the old exe (stub) header format
DOSheader    GROUP,OVER(RawBytes)
dos_magic      STRING(2)         ! contains 'MZ'
dos_filler     USHORT,DIM(29)    ! we don't care about these fields
dos_lfanew     ULONG             ! File offset of new exe header
             END

! NEheader is the new exe (16-bit) header format
NEheader     GROUP,OVER(RawBytes)
ne_magic       STRING(2)         ! Contains 'NE'
ne_ver         BYTE
ne_rev         BYTE
ne_enttab      USHORT
ne_cbenttab    USHORT
ne_crc         LONG
ne_flags       USHORT
ne_autodata    USHORT
ne_heap        USHORT
ne_stack       USHORT
ne_csip        ULONG
ne_sssp        ULONG
ne_cseg        USHORT
ne_cmod        USHORT
ne_cbnrestab   USHORT
ne_segtab      USHORT
ne_rsrctab     USHORT
ne_restab      USHORT
ne_modtab      USHORT
ne_imptab      USHORT
ne_nrestab     ULONG
ne_cmovent     USHORT
ne_align       USHORT
ne_rescount    USHORT
ne_osys        BYTE
ne_flagsother  BYTE
ne_gangstart   USHORT
ne_ganglength  USHORT
ne_swaparea    USHORT
ne_expver      USHORT           ! Expected Window version number
             END

! PEheader is the flat-model (32-bit) header format (PE signature)
PEheader     GROUP,OVER(RawBytes)
pe_signature   ULONG
pe_machine     USHORT
pe_nsect       USHORT
pe_stamp       ULONG
pe_psymbol     ULONG
pe_nsymbol     ULONG
pe_optsize     USHORT
pe_character   USHORT
             END

! Optheader is the "optional header" that follows the PEheader

OptHeader    GROUP,OVER(RawBytes)
opt_Magic          USHORT
opt_MajorLinkerVer BYTE
opt_MinorLinkerVer BYTE
opt_SizeOfCode     ULONG
opt_SizeOfInitData ULONG
opt_SizeOfUninit   ULONG
opt_EntryPoint     ULONG
opt_BaseOfCode     ULONG
opt_BaseOfData     ULONG
opt_ImageBase      ULONG
opt_SectAlignment  ULONG
opt_FileAlignment  ULONG
opt_MajorOSVer     USHORT
opt_MinorOSVer     USHORT
opt_MajorImageVer  USHORT
opt_MinorImageVer  USHORT
opt_MajorSubVer    USHORT
opt_MinorSubVer    USHORT
opt_Reserved1      ULONG
opt_SizeOfImage    ULONG
opt_SizeOfHeaders  ULONG
opt_CheckSum       ULONG
opt_Subsystem      USHORT
opt_DllChar        USHORT
opt_StackReserve   ULONG
opt_StackCommit    ULONG
opt_HeapReserve    ULONG
opt_HeapCommit     ULONG
opt_LoaderFlags    ULONG
opt_DataDirNum     ULONG
             END

! The Optional header is followed by an array of the following structures

DataDir      GROUP,OVER(RawBytes)
data_VirtualAddr   ULONG
data_Size          ULONG
             END

! SectHeader describes a section in a PE file
SectHeader GROUP,OVER(RawBytes)
sh_SectName  CSTRING(8)
sh_VirtSize  ULONG
sh_PhysAddr  ULONG,OVER(sh_VirtSize)
sh_VirtAddr  ULONG
sh_RawSize   ULONG
sh_RawPtr    ULONG
sh_Reloc     ULONG
sh_LineNum   ULONG
sh_RelCount  USHORT
sh_LineCount USHORT
sh_Character ULONG
           END

! ExpDirectory is at start of a .edata section in a PE file
ExpDirectory GROUP,OVER(RawBytes)
exp_Character   ULONG
exp_stamp       ULONG
exp_Major       USHORT
exp_Minor       USHORT
exp_Name        ULONG
exp_Base        ULONG
exp_NumFuncs    ULONG
exp_NumNames    ULONG
exp_AddrFuncs   ULONG
exp_AddrNames   ULONG
exp_AddrOrds    ULONG
              END
            END
          END

newoffset ULONG   ! File offset to NE/PE header

LocatorText CSTRING(129)

ExportQ   QUEUE,PRE(EXQ)
Symbol      CSTRING(129)
icon        SHORT
treelevel   SHORT
ordinal     USHORT
module      CSTRING(21)
libno       USHORT
          END

QPointer  LONG,AUTO
LastLib   USHORT(0)

oldheight USHORT,AUTO
oldwidth  USHORT,AUTO
xdelta    SHORT,AUTO
ydelta    SHORT,AUTO

i         SIGNED,AUTO

window WINDOW('LibMaker'),AT(,,315,168),CENTER,GRAY,IMM,SYSTEM,MAX,ICON('LIBRARY.ICO'), |
            FONT('Segoe UI',10),Tiled,RESIZE
        LIST,AT(7,19,236,142),USE(?LIST1),DISABLE,FLAT,VSCROLL,FONT('Courier New' & |
                '',9,,FONT:regular),TIP('List of libraries'),FROM(ExportQ), |
                FORMAT('178L(2)|MIT(L)~Symbol~L(36)Q''Exported symbols''20R(4)~O' & |
                'rdinal~L@N_5B@Q''Ordinal numbers'''),ALRT(MouseRight),ALRT(DeleteKey)
        BUTTON('&Add file...'),AT(252,7,56,13),USE(?ADDFILE),FONT(,,,FONT:regular), |
                TIP('Add library to list'),LEFT
        BUTTON('&Remove'),AT(252,26,56,13),USE(?REMOVE),FONT(,,,FONT:regular), |
                TIP('Remove function from list'),LEFT
        BUTTON('C&lear'),AT(252,44,56,13),USE(?CLEAR),DISABLE,FONT(,,,FONT:regular), |
                TIP('Remove all items from list'),LEFT
        BUTTON('&Save as...'),AT(252,63,56,13),USE(?SAVEAS),DISABLE,FONT(,,, |
                FONT:regular),TIP('Save listed items as a LIB file'),LEFT
        BUTTON('&To Text'),AT(252,82,56,13),USE(?TOTEXT),DISABLE,FONT(,,,FONT:regular), |
                TIP('Save listed items as EXP files'),LEFT
        BUTTON('&Info...'),AT(252,101,56,13),USE(?INFO),FONT(,,,FONT:regular), |
                TIP('About this program'),LEFT
        BUTTON('&Close'),AT(252,120,56,13),USE(?CLOSE),STD(STD:Close), |
                FONT(,,,FONT:regular),TIP('Close the program'),LEFT
        ENTRY(@s128),AT(8,7,210,10),USE(LocatorText,,?ENTRYLocator)
        BUTTON('Next'),AT(220,7,23,10),USE(?BUTTONNext)
    END
    
   CODE
   OPEN(window)
   0{PROP:Buffer} = 1
   ?List1{PROP:iconlist, 1} = '~Opened.ico'
   ?List1{PROP:iconlist, 2} = '~Closed.ico'
   oldheight = window{PROP:height}
   oldwidth = window{PROP:width}
   window {PROP:minheight} = oldheight
   window {PROP:minwidth} = oldwidth
   IF COMMAND('1') <> ''
     FileName = COMMAND('1')
     DO LoadFile
     ENABLE(?LIST1)
   END

   ACCEPT
      CASE ACCEPTED()
      OF ?BUTTONNext
         IF CLIP(LocatorText)<>''
            Do FindNext
         END
      OF ?Info
         InfoWindow

      OF ?Clear
         FREE(ExportQ)
         DO EnableControls
         DISPLAY

      OF ?Remove
         DO DeleteThis

      OF ?AddFile
        IF FileDialog('Import symbols from file ...', FileName, |
                      'DLL files (*.dll)|*.dll|LIB files (*.lib)|*.lib|All files (*.*)|*.*', |
                      FILE:LongName + FILE:KeepDir)
          DO LoadFile
        END
        DO EnableControls

      OF ?SaveAs
        IF RECORDS(ExportQ)>0
          CLEAR(FileName)
          IF FileDialog('Output library definition to ...', FileName, 'Library files (*.lib)|*.lib', |
                        FILE:Save + FILE:LongName + FILE:KeepDir)
            WriteLib
          END
        END

      OF ?ToText
        IF RECORDS(ExportQ) > 0
          CLEAR(FileName)
          WriteText
        END
      END

      CASE EVENT()
      OF EVENT:expanded
      OROF EVENT:contracted
        QPointer = ?List1{PROPLIST:MouseDownRow}
        GET(ExportQ, QPointer)

        ExportQ.TreeLevel = -ExportQ.TreeLevel
        IF ExportQ.Icon = 1
          ExportQ.Icon = 2
        ELSE
          ExportQ.Icon = 1
        END
        PUT(ExportQ)
        DISPLAY(?list1)

      OF EVENT:Sized
         Do ResizeWindow
      OF EVENT:AlertKey
        CASE KEYCODE()
        OF DeleteKey
          DO DeleteThis
        OF MouseRight
          IF  FIELD() = ?List1
            GET (ExportQ, CHOICE (?List1))
            EXECUTE POPUP ('[' & PROP:Icon & '(~abc.ico)]Sort by &Name |' &|
                           '[' & PROP:Icon & '(~123.ico)]Sort by &Ordinal |' & |
                           '|-|' & |
                           '[' & PROP:Icon & '(~Copy.ico)]Copy to Clipboard |' & |
                           '|-|' & |
                           '[' & PROP:Icon & '(~DelLine.ico)]Delete this item')
              SORT (ExportQ, +ExportQ.Libno, +ExportQ.Symbol)
              SORT (ExportQ, +ExportQ.Libno, +ExportQ.Ordinal)
              Do CopyToClipboard
              DO DeleteThis
            END
            SELECT(?List1, POSITION(ExportQ))
          END
        END
        DISPLAY(?List1)
      END
   END

ResizeWindow ROUTINE         
        ydelta = window{PROP:height}-oldheight
        xdelta = window{PROP:width}-oldwidth
        SYSTEM {PROP:defermove} = ?BUTTONNext - ?List1

        SetPosition(?List1,,,?List1{PROP:width}+xdelta, ?list1{PROP:height}+ydelta)
        SetPosition(?ENTRYLocator,,,?ENTRYLocator{PROP:width}+xdelta,)
        SETPOSITION (?BUTTONNext, ?BUTTONNext{PROP:xPos} + xDelta)
        
        LOOP i = ?AddFile TO ?Close
          SETPOSITION (i, i{PROP:xPos} + xDelta)
        END
        oldheight = window{PROP:height}
        oldwidth  = window{PROP:width}

FindNext ROUTINE
  QPointer = CHOICE (?List1)
  IF QPointer>0
     IF QPointer=RECORDS(ExportQ) AND QPointer>1
        QPointer = 0
     END
     LOOP
        QPointer+=1
        GET (ExportQ, QPointer)
        IF ERRORCODE()
           BREAK
        END
        IF INSTRING(UPPER(CLIP(LocatorText)),UPPER(ExportQ.Symbol),1,1) > 0
           SELECT (?List1, QPointer)
           BREAK
        END
        IF QPointer>RECORDS(ExportQ)
           BREAK
        END
     END
  END
CopyToClipboard ROUTINE 
  QPointer = CHOICE (?List1)
  GET (ExportQ, QPointer)
  IF ExportQ.TreeLevel = 2
    SETCLIPBOARD(ExportQ.Symbol)
  END
  
LoadFile        ROUTINE
  DISPLAY
  SetCursor(CURSOR:Wait)

  QPointer = RECORDS (ExportQ)
  IF INSTRING('.LIB', UPPER(FileName), 1, 1)
    ReadLib
  ELSE
    ReadExecutable
  END
  LastLib += 2
  SELECT (?List1, QPointer + 1)
  SetCursor()

DeleteThis      ROUTINE
  QPointer = CHOICE (?List1)
  GET (ExportQ, QPointer)

  IF  ExportQ.TreeLevel = 2
    DELETE (ExportQ)
  ELSE
    LOOP
      DELETE (ExportQ)
      GET (ExportQ, QPointer)
    WHILE ERRORCODE() = 0  AND  ExportQ.TreeLevel = 2
  END

  DO EnableControls
  EXIT

EnableControls  ROUTINE
   IF RECORDS(ExportQ)
     ENABLE (?list1)
     ENABLE (?SaveAs)
     ENABLE (?ToText)
     ENABLE (?Clear)
   ELSE
     DISABLE (?list1)
     DISABLE (?SaveAs)
     DISABLE (?ToText)
     DISABLE (?Clear)
   END

   EXIT

! ReadExecutable gets export table from 16 or 32-bit file or LIB file

ReadExecutable PROCEDURE ()

sectheaders ULONG   ! File offset to section headers
sections    USHORT  ! File offset to section headers
VAexport    ULONG   ! Virtual address of export table, according to data directory
                    ! This is used as an alternative way to find table if .edata not found
   CODE
   OPEN(EXEfile, 0)
   GET(EXEfile, 1, SIZE(EXE:DOSheader))
   IF EXE:dos_magic = 'MZ' THEN
     newoffset = EXE:dos_lfanew
     GET(EXEfile, newoffset+1, SIZE(EXE:PEheader))

     IF EXE:pe_signature = 04550H THEN
       sectheaders = EXE:pe_optsize+newoffset+SIZE(EXE:PEheader)
       sections = EXE:pe_nsect
       ! Read the "Optional header"
       GET(EXEfile, newoffset+SIZE(EXE:PEheader)+1, SIZE(EXE:Optheader))
       IF EXE:opt_DataDirNum THEN
          ! First data directory describes where to find export table
          GET (EXEfile, newoffset+SIZE(EXE:PEheader)+SIZE(EXE:OptHeader)+1, SIZE(EXE:DataDir))
          VAexport = EXE:data_VirtualAddr
       END

       LOOP i# = 1 TO sections
         GET(EXEfile,sectheaders+1,SIZE(EXE:sectheader))
         sectheaders += SIZE(EXE:sectheader)
         IF EXE:sh_SectName = '.edata' THEN
            DumpPEExportTable(EXE:sh_VirtAddr, EXE:sh_VirtAddr - EXE:sh_rawptr)
         ELSIF EXE:sh_VirtAddr <= VAexport AND |
               EXE:sh_VirtAddr+EXE:sh_RawSize > VAexport
            DumpPEExportTable(VAexport, EXE:sh_VirtAddr - EXE:sh_rawptr)
         END
       END
     ELSE
       GET(EXEfile, newoffset+1, SIZE(EXE:NEheader))
       DumpNEExports
     END
   END
   CLOSE(EXEfile)

! DumpPEexportTable gets export table from a PE format file (32-bit)

DumpPEExportTable PROCEDURE (ULONG VirtualAddress, ULONG ImageBase)

NumNames  ULONG,AUTO
Names     ULONG,AUTO
Ordinals  ULONG,AUTO
Base      ULONG,AUTO

j         UNSIGNED,AUTO

   CODE
   GET(EXEfile, VirtualAddress-ImageBase+1, SIZE(EXE:ExpDirectory))
   NumNames = EXE:exp_NumNames
   Names    = EXE:exp_AddrNames
   Ordinals = EXE:exp_AddrOrds
   Base     = EXE:exp_Base
   GET(EXEfile, EXE:exp_Name-ImageBase+1, SIZE(EXE:cstringval))

   ExportQ.Module   = EXE:cstringval
   ExportQ.Symbol    = EXE:cstringval
   ExportQ.TreeLevel = 1
   ExportQ.Icon      = 1
   ExportQ.Ordinal   = 0
   ExportQ.Libno     = LastLib
   ADD(ExportQ)

   ExportQ.TreeLevel = 2
   ExportQ.Icon      = 0

   LOOP j = 0 TO NumNames - 1
      GET(EXEfile, Names+j*4-ImageBase+1, SIZE(EXE:ulongval))
      GET(EXEfile, EXE:ulongval-ImageBase+1, SIZE(EXE:cstringval))
      ExportQ.Symbol = EXE:cstringval

      GET(EXEfile, Ordinals+j*2-ImageBase+1, SIZE(EXE:ushortval))
      ExportQ.Ordinal = EXE:ushortval+Base
      ExportQ.Libno   = LastLib + 1
      ADD(ExportQ)
   END

! DumpNEexports gets export table from a NE format file (16-bit)

DumpNEExports PROCEDURE ()

j         LONG,AUTO
r         LONG,AUTO

   CODE
! First get the module name - stored as first entry in resident name table
   j = EXE:ne_nrestab+1
   r = newoffset+EXE:ne_restab+1
   GET(EXEfile, r, SIZE(EXE:pstringval))

   ExportQ.Module    = EXE:pstringval
   ExportQ.Symbol    = EXE:pstringval
   ExportQ.Ordinal   = 0
   ExportQ.TreeLevel = 1
   ExportQ.Icon      = 1
   ExportQ.Libno     = LastLib
   ADD(ExportQ)

   r += LEN(EXE:pstringval)+1    !move past module name
   r += 2                        !move past ord#

! Now pull apart the resident name table. First entry is the module name, read above

   ExportQ.TreeLevel = 2
   ExportQ.Icon = 0

   LOOP
     GET(EXEfile, r, SIZE(EXE:pstringval))
     IF LEN(EXE:pstringval) = 0 THEN
       BREAK
     END
     ExportQ.Symbol = EXE:pstringval
     r += LEN(EXE:pstringval)+1
     GET(EXEfile, r, SIZE(EXE:ushortval))
     r += 2
     ExportQ.Ordinal = EXE:ushortval
     ExportQ.Libno   = LastLib + 1
     ADD(ExportQ)
   END

! Now pull apart the non-resident name table. First entry is the description, and is skipped
   GET(EXEfile, j, SIZE(EXE:pstringval))
   j += LEN(EXE:pstringval)+1
   GET(EXEfile, j, SIZE(EXE:ushortval))
   j += 2
   LOOP
     GET(EXEfile, j, SIZE(EXE:pstringval))
     IF LEN(EXE:pstringval)=0 THEN
       BREAK
     END
     ExportQ.Symbol = EXE:pstringval
     j += LEN(EXE:pstringval)+1
     GET(EXEfile, j, SIZE(EXE:ushortval))
     j += 2
     ExportQ.Ordinal = EXE:ushortval
     ExportQ.libno = LastLib + 1
     ADD(ExportQ)
   END

! WriteLib writes out all info in the export Q to a LIB file

WriteLib PROCEDURE ()

rec     UNSIGNED,AUTO

   CODE
   CREATE(LIBfile)
   OPEN(LIBfile)

   LOOP rec = 1 TO RECORDS(ExportQ)
      GET(ExportQ, rec)
      IF ExportQ.TreeLevel = 2 THEN
        ! Record size is length of the strings, plus two length bytes, a two byte
        ! ordinal, plus the header length (excluding the first three bytes)
        LIB:typ = 88H
        LIB:kind = 0A000H
        LIB:bla = 1
        LIB:ordflag = 1
        LIB:len = LEN(CLIP(exq:module))+LEN(CLIP(exq:Symbol))+2+2+SIZE(LIB:header)-3
        ADD(LIBfile, SIZE(LIB:header))
        LIB:pstringval = ExportQ.Symbol
        ADD(LIBfile, LEN(LIB:pstringval)+1)
        LIB:pstringval = ExportQ.Module
        ADD(LIBfile, LEN(LIB:pstringval)+1)
        LIB:ushortval = ExportQ.Ordinal
        ADD(LIBfile, SIZE(LIB:ushortval))
      END
   END
   CLOSE(LIBfile)

! Readlib reads back in a LIB file output by WriteLib above or by IMPLIB etc

ReadLib    PROCEDURE

ii         LONG,AUTO
jj         LONG,AUTO
ordinal    USHORT,AUTO
lastmodule CSTRING(21)
modulename CSTRING(21)
Symbolname CSTRING(129),AUTO

   CODE
   OPEN(LIBfile, 40h)
   ii = 1

   LOOP 
      GET(LIBfile, ii, SIZE(LIB:header))     ! Read next OMF record
      IF ERRORCODE()
         BREAK                              ! All done
      END
      IF LIB:typ = 0 OR LIB:len = 0
         BREAK
      END

      jj   = ii + SIZE(LIB:header)             ! Read export info from here
      ii  += LIB:len + 3                       ! Read next OMF record from here

      IF LIB:typ = 88H AND LIB:kind = 0A000H AND LIB:bla = 1 AND LIB:ordflag = 1 THEN
          GET(LIBfile, jj, SIZE(LIB:pstringval))
          Symbolname = LIB:pstringval
          jj += LEN(LIB:Pstringval)+1
          GET(LIBfile, jj, SIZE(LIB:pstringval))
          modulename = LIB:pstringval
          jj += LEN(LIB:Pstringval)+1
          GET(LIBfile, jj, SIZE(LIB:ushortval))
          ordinal = LIB:ushortval

          IF modulename <> lastmodule      ! A LIB can describe multiple DLLs
             IF  lastmodule[1] <> '<0>'
               LastLib += 2
             END
             lastmodule = modulename

             ExportQ.TreeLevel = 1
             ExportQ.Icon      = 1
             ExportQ.Symbol    = modulename
             ExportQ.Module    = modulename
             ExportQ.Ordinal   = 0
             ExportQ.Libno     = LastLib
             ADD(ExportQ)
          END

          ExportQ.TreeLevel = 2
          ExportQ.Icon      = 0
          ExportQ.Symbol    = SymbolName
          ExportQ.Module    = modulename
          ExportQ.Ordinal   = ordinal
          ExportQ.Libno     = LastLib + 1
          ADD(ExportQ)
      END
   END
   CLOSE(LIBfile)

! Procedure InfoWindow provides the 'About' screen

InfoWindow      PROCEDURE

infowin WINDOW('LibMaker Info'),AT(,,193,68),CENTER,GRAY,FONT('Segoe UI',11,,FONT:regular,CHARSET:ANSI),Tiled,NOFRAME
        REGION,AT(1,1,191,42),USE(?PANEL1)
        TEXT,AT(5,5,182,32),USE(?TEXTMessage),SKIP,TRN,FLAT,READONLY
        IMAGE('SVLogo.png'),AT(10,38),USE(?IMAGE1)
        BUTTON('OK'),AT(145,51,42,11),USE(?OkButton),STD(STD:Close),FONT(,9,,FONT:regular),DEFAULT
    END

  CODE
  OPEN(infowin)
  ?TEXTMessage{PROP:Text}='This program is provided as both a useful utility and as a source code example. The source code is installed in the EXAMPLES\LIBMAKER subdirectory.'
  SELECT(?OkButton)
  ACCEPT
  END
  CLOSE (infowin)
!

WriteText       PROCEDURE

Rec         UNSIGNED,AUTO
Opened      BYTE,AUTO
Dot         UNSIGNED,AUTO

  CODE
  SORT (ExportQ, +ExportQ.libno, +ExportQ.Ordinal)
  Opened = FALSE
  LOOP Rec = 1 TO RECORDS (ExportQ)
    Get(ExportQ, rec)
    IF ExportQ.Ordinal <> 0
      IF Opened
        TxtFile.Line = '  ' & ExportQ.Symbol & ' @' & ExportQ.Ordinal
        ADD(TxtFile)
        CYCLE
      END
      FileName = 'DEFAULT.EXP'
    ELSE
      IF STATUS (TxtFile)
        CLOSE(TxtFile)
      END
      dot = INSTRING ('.', ExportQ.Symbol, 1, 1)
      IF  dot
        FileName = ExportQ.Symbol [1 : dot] & 'EXP'
      ELSE
        FileName = ExportQ.Symbol & '.EXP'
      END
      opened = TRUE
    END

    MESSAGE('Export file, ' & CLIP(FileName) & ' being written in ' & |
            LongPath(PATH()),'Library exported!',ICON:Exclamation)

    CREATE (TxtFile)
    OPEN (TxtFile)
    TxtFile.Line = 'EXPORTS'
    ADD (TxtFile)
    IF  NOT opened
      TxtFile.Line = '  ' & ExportQ.Symbol & ' @' & ExportQ.Ordinal
      ADD (TxtFile)
      opened = TRUE
    END
  END
  CLOSE (TxtFile)
