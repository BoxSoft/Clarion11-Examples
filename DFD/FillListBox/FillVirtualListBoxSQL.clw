!This example is similar to the virtual list box example documented in the Dynamic File Driver
!Reference PDF. The big differece here is that it is NOT using the In-Memory driver as the basis
!for the dynamic file. The SQL query is returned to a dynamic SQL table using the CreateFromSQL
!method in the DynFile Class.
!
!The example is also showing the use of SQLTable.SetDriver(*FILE pFile) needed in order to use
!local link compile. The code is defining an empty file structure (AnyTable) which purpose is
!simply to pass it as a parameter to method SetDriver which in turn will assign this structure to
!{prop:FileDriver} which must be used with local link (not needed for standalone (DLL) mode).
!
!               SQLTable.UnfixFormat()
!               SQLTable.ResetAll()
!
!               SQLTable.SetDriver(AnyTable)
!               SQLTable.SetOwner('(local),Northwind,sa,')
!
!               SQLTable.CreateFromSQL(CLIP(lQuery))
!
!               TheFile &= SQLTable.GetFileRef()

    PROGRAM
    MAP
FillVirtualListBox        PROCEDURE()
    END

    INCLUDE('DynFile.inc'), ONCE

AnyTable    FILE, DRIVER('MSSQL','/TURBOSQL=TRUE')
              RECORD
              END
            END


    code
    FillVirtualListBox()


FillVirtualListBox            PROCEDURE

SQLTable      &DynFile

TheFile         &File
TheKey          &Key

ResultQueue   QUEUE
Column1           CSTRING(256)
Column2           CSTRING(256)
Column3           CSTRING(256)
Column4           CSTRING(256)
Column5           CSTRING(256)
Column6           CSTRING(256)
Column7           CSTRING(256)
Column8           CSTRING(256)
Column9           CSTRING(256)
Column10          CSTRING(256)
Column11          CSTRING(256)
Column12          CSTRING(256)
Column13          CSTRING(256)
Column14          CSTRING(256)
Column15          CSTRING(256)
Column16          CSTRING(256)
Column17          CSTRING(256)
Column18          CSTRING(256)
Column19          CSTRING(256)
Column20          CSTRING(256)
                END

!===  VLB  ========
DynFileList        CLASS
Changed                   BYTE
ListControl               USHORT
File                      &File
Key                       &Key
Q                         &QUEUE
Init                      PROCEDURE(UNSIGNED TheList)
Refresh                   PROCEDURE(*FILE TheDynFile,<QUEUE Result>),VIRTUAL
FormatColumn              PROCEDURE(STRING Label,STRING DataType,USHORT DataSize,BYTE Places),STRING,VIRTUAL
VLBProc                   PROCEDURE(LONG ROW, SHORT COL), STRING, VIRTUAL, PROC
                   END
QueryQueue       QUEUE
Query             CSTRING(200)
                 END

lQuery           CSTRING(200)
INIEntrys        LONG
INIEntrysIndex   LONG
lFound           BYTE

AGroup           &GROUP
QCol             ANY
I                LONG

Window WINDOW('Dynamic File Driver FillVirtualListBox SQL'),AT(,,320,207),FONT('MS Sans Serif',,,FONT:regular,CHARSET:ANSI), |
         CENTER,SYSTEM,GRAY,DOUBLE
       PROMPT('Query:'),AT(8,5),USE(?Query:Prompt1)
       COMBO(@s200),AT(33,5,215,10),USE(?Query:Combo),FORMAT('200L(2)|M@S200@'),DROP(10,250),FROM(QueryQueue)
       BUTTON('Refresh'),AT(251,2,51,14),USE(?Refresh)
       LIST,AT(6,41,308,132),USE(?List1),VSCROLL
       BUTTON('Close'),AT(259,181,51,14),USE(?Button1),STD(STD:Close)
     END

    CODE
    !
    Do LoadQueryList
    !Init Queue of Queries
    IF RECORDS(QueryQueue)=0
       QueryQueue.Query='SELECT ProductID,ProductName FROM Products ORDER BY ProductID'
       ADD(QueryQueue)
       QueryQueue.Query='SELECT ProductName,ProductID FROM Products ORDER BY ProductName'
       ADD(QueryQueue)
       QueryQueue.Query='SELECT Count(DISTINCT SupplierID) Records FROM Products'
       ADD(QueryQueue)
       QueryQueue.Query='SELECT Count(DISTINCT CategoryID) Records FROM Products'
       ADD(QueryQueue)
       QueryQueue.Query='SELECT COUNT(*) Records FROM Products'
       ADD(QueryQueue)
       QueryQueue.Query='SELECT SUM(UnitPrice) AS PriceSum FROM Products'
       ADD(QueryQueue)
       QueryQueue.Query='SELECT AVG(UnitPrice) AS PriceAVG FROM Products'
       ADD(QueryQueue)
       QueryQueue.Query='SELECT MIN(UnitPrice) AS PriceMin FROM Products'
       ADD(QueryQueue)
       QueryQueue.Query='SELECT MAX(UnitPrice) AS PriceMax FROM Products'
       ADD(QueryQueue)
    END

    SQLTable &= NEW(DynFile)

    OPEN(window)
    GET(QueryQueue,1)
    ?Query:Combo{PROP:ScreenText}=QueryQueue.Query
    (?Query:Combo{PROP:ListFeq}){PROP:SELECTED}=1
    DynFileList.Init(?List1)
    ACCEPT
       CASE EVENT()
       OF EVENT:Accepted
           CASE FIELD()
           OF ?Refresh
              lFound = False
              !Search for Combo text in the queue
              LOOP INIEntrysIndex=1 TO RECORDS(QueryQueue)
                   GET(QueryQueue,INIEntrysIndex)
                   IF NOT ERRORCODE()
                      IF ?Query:Combo{PROP:VALUE}=QueryQueue.Query
                         lFound = True
                         !Move query to first place
                         DELETE(QueryQueue)
                         QueryQueue.Query=?Query:Combo{PROP:VALUE}
                         ADD(QueryQueue,1)
                         (?Query:Combo{PROP:ListFeq}){PROP:SELECTED}=1
                         BREAK
                      END
                   END
              END
              !If the combo text was not found in the queue add it
              IF lFound=False
                 QueryQueue.Query = ?Query:Combo{PROP:VALUE}
                 ADD(QueryQueue,1)
              END
              lQuery = QueryQueue.Query
              Do RefreshQuery
           END
       END
    END
    
    DISPOSE(SQLTable)

    Do SaveQueryList

SaveQueryList   ROUTINE
 INIEntrys = GETINI( 'QUERYLIST','QUERYRECORDS',0,'.\TestVLBFill.INI')
 LOOP INIEntrysIndex=1 TO INIEntrys
      PUTINI( 'QUERYLIST','QUERY'&INIEntrysIndex,'','.\TestVLBFill.INI')
 END
 PUTINI( 'QUERYLIST','QUERYRECORDS',RECORDS(QueryQueue),'.\TestVLBFill.INI')
 LOOP INIEntrysIndex=1 TO RECORDS(QueryQueue)
      GET(QueryQueue,INIEntrysIndex)
      IF NOT ERRORCODE()
         PUTINI( 'QUERYLIST','QUERY'&INIEntrysIndex,QueryQueue.Query,'.\TestVLBFill.INI')
      END
 END

LoadQueryList   ROUTINE
 INIEntrys = GETINI( 'QUERYLIST','QUERYRECORDS',0,'.\TestVLBFill.INI')
 FREE(QueryQueue)
 LOOP INIEntrysIndex=1 TO INIEntrys
      QueryQueue.Query=GETINI( 'QUERYLIST','QUERY'&INIEntrysIndex,'','.\TestVLBFill.INI')
      ADD(QueryQueue)
 END

RefreshQuery    ROUTINE
               SQLTable.UnfixFormat()
               SQLTable.ResetAll()

			   SQLTable.SetDriver(AnyTable)
			 ! Edit connect string here	
               SQLTable.SetOwner('server,database,user,password')
		    
               SQLTable.CreateFromSQL(CLIP(lQuery))

               TheFile &= SQLTable.GetFileRef()
               OPEN(TheFile)
               FREE(ResultQueue)
               LOOP
                  NEXT(TheFile)
                  IF ERRORCODE() = 33 THEN
                     BREAK
                  ELSIF ERRORCODE()<>0
                     MESSAGE('FILLQUEUE ERROR:'&ERRORCODE())
                     BREAK
                  END
                  CLEAR(ResultQueue)
                  AGroup &= TheFile{prop:Record}
                  LOOP I=1 TO TheFile{PROP:Fields}
                       QCol &= WHAT(ResultQueue,I)
                       QCol=WHAT(AGroup, I)
                  END
                  ADD(ResultQueue)
               END
               CLOSE(TheFile)
               DynFileList.Refresh(TheFile,ResultQueue)

DynFileList.Init                      PROCEDURE(UNSIGNED TheList)
 CODE
    SELF.File &= NULL
    SELF.ListControl = TheList
    SELF.ListControl{PROP:VLBVal} = ADDRESS(SELF)
    SELF.ListControl{PROP:VLBProc} = ADDRESS(VLBProc)
    SELF.Changed = False

DynFileList.Refresh                   PROCEDURE(*FILE TheDynFile,<QUEUE Result>)
lColumns    SHORT
lFormat     CSTRING(2048),AUTO
Idx         SHORT
  CODE
    IF NOT OMITTED(3)
       SELF.Q &= Result
    ELSE
       SELF.Q &= NULL
    END
    SELF.File &= TheDynFile
    IF NOT SELF.File &= NULL
       lColumns = SELF.File{PROP:Fields}
       lFormat = ''
       SELF.ListControl{PROP:FORMAT}=CLIP(lFormat)
       LOOP Idx=1 TO lColumns
            lFormat=CLIP(lFormat)&SELF.FormatColumn(SELF.File{PROP:Label,Idx},SELF.File{PROP:Type,Idx},SELF.File{PROP:Size,Idx},SELF.File{PROP:Places,Idx})
       END
       SELF.ListControl{PROP:FORMAT}=CLIP(lFormat)
       SELF.Changed = True
    ELSE
       SELF.Changed = False
    END
    

DynFileList.VLBProc                   PROCEDURE(LONG ROW, SHORT COL)
AttrIndex   UNSIGNED, AUTO
AttrString  ANY
locGroup    &GROUP
lColumns    SHORT
lFormat     STRING(2048),AUTO
lRecords    LONG

  CODE
  CASE ROW
  OF -1
    IF NOT SELF.File &= NULL
       IF NOT SELF.Q &= NULL
          lRecords=RECORDS(SELF.Q)
       ELSE
          SET(TheFile)
          lRecords=RECORDS(SELF.File)
       END
       RETURN lRecords
    ELSE
       RETURN 0
    END
  OF -2
    IF NOT SELF.File &= NULL
       RETURN SELF.File{PROP:Fields}
    ELSE
       RETURN 1
    END
  OF -3
    IF NOT SELF.File &= NULL
       IF SELF.Changed
         SELF.Changed = False
         RETURN TRUE
       END
    END
    RETURN FALSE
  ELSE
    IF NOT SELF.File &= NULL
       IF NOT SELF.Q &= NULL
          GET(SELF.Q, ROW)
          AttrString &= WHAT(SELF.Q, COL)
          RETURN AttrString
       ELSE
          locGroup &= SELF.File{prop:Record}
          GET(SELF.File, ROW)
          IF NOT ERRORCODE()
              AttrString &= WHAT(locGroup, COL)
              RETURN AttrString
          ELSE
              MESSAGE(ERRORCODE())
          END
       END
    ELSE
       RETURN ''
    END
  END
  RETURN ''

DynFileList.FormatColumn              PROCEDURE(STRING Label,STRING DataType,USHORT DataSize,BYTE Places)
lJustification   STRING('L')
lWidth           USHORT(0)
lIndent          BYTE(2)
lPicture         CSTRING(20)
  CODE
  CASE DataType
  OF 'BYTE'
     lPicture = 'n3'
     lWidth   = LEN(Label)*5
  OF 'SHORT'
     lPicture = 'n-7'
     lWidth   = LEN(Label)*5
     lJustification='R'
  OF 'USHORT'
     lPicture = 'n6'
     lWidth   = LEN(Label)*5
     lJustification='R'
  OF 'DATE'
     lPicture = 'd17'
     lWidth   = LEN(Label)*5
     lJustification='R'
  OF 'TIME'
     lPicture = 't7'
     lWidth   = LEN(Label)*5
     lJustification='R'
  OF 'LONG'
     lPicture = 'n-14'
     lWidth   = LEN(Label)*5
     lJustification='R'
  OF 'ULONG'
     lPicture = 'n13'
     lWidth   = LEN(Label)*5
     lJustification='R'
  OF 'SREAL'
     lPicture = 'n10.2'
     lWidth   = LEN(Label)*5
     lJustification='R'
  OF 'REAL'
     lPicture = 'n10.2'
     lWidth   = LEN(Label)*5
     lJustification='R'
  OF 'DECIMAL'
     lPicture = 'n10.2'
     lWidth   = LEN(Label)*5
     lJustification='R'
  OF 'PDECIMAL'
     lPicture = 'n10.2'
     lWidth   = LEN(Label)*5
     lJustification='R'
  OF 'BFLOAT4'
     lPicture = 'n10.2'
     lWidth   = LEN(Label)*5
     lJustification='R'
  OF 'BFLOAT8'
     lPicture = 'n10.2'
     lWidth   = LEN(Label)*5
     lJustification='R'
  OF 'STRING'
     lPicture = 's'&DataSize
     lWidth   = DataSize*5
  OF 'CSTRING'
     lPicture = 's'&(DataSize+1)
     lWidth   = DataSize*5
  OF 'PSTRING'
     lPicture = 's'&(DataSize+1)
     lWidth   = DataSize*5
  OF 'MEMO'
     lPicture = 's250'
     lWidth   = 80
!  OF 'GROUP'
!  OF 'BLOB'
  ELSE
  END
  RETURN CLIP(lWidth&lJustification&'('&lIndent&')|M~'&Label&'~@'&lPicture&'@')
