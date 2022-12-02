    program
    map
FillVirtualListBox        procedure()
    end

    include('DynFile.inc'), once


    code
    FillVirtualListBox()



FillVirtualListBox            procedure

people               FILE,DRIVER('TOPSPEED'),PRE(PEO),CREATE,BINDABLE,THREAD
KeyId                    KEY(PEO:Id),NOCASE,OPT,PRIMARY
KeyLastName              KEY(PEO:LastName),DUP,NOCASE
Record                   RECORD,PRE()
Id                          LONG
FirstName                   STRING(30)
LastName                    STRING(30)
Gender                      STRING(1)
                         END
                     END                       

MSProducts      &DynFile
MEMProducts     &DynFile

TheFile         &File
TheKey          &Key

MyQueue         queue
productID         long
ProductName       string(25)
                end

!===  VLB  ========
DynFileList        CLASS
Changed                   BYTE
ListControl               USHORT
File                      &File
Key                       &Key
Init                      PROCEDURE(UNSIGNED TheList)
Refresh                   PROCEDURE(*FILE TheDynFile),VIRTUAL
FormatColumn              PROCEDURE(STRING Label,STRING DataType,USHORT DataSize,BYTE Places),STRING,VIRTUAL
VLBProc                   PROCEDURE(LONG ROW, SHORT COL), STRING, VIRTUAL, PROC
                   END
QueryQueue  QUEUE
Query           CSTRING(200)
            END
lQuery           CSTRING(200)
INIEntrys   LONG
INIEntrysIndex   LONG
lFound  BYTE

Window WINDOW('Dynamic File Driver FillVirtualListBox'),AT(,,320,207),FONT('MS Sans Serif',,,FONT:regular,CHARSET:ANSI), |
         SYSTEM,GRAY,DOUBLE
       PROMPT('Query:'),AT(8,5),USE(?Query:Prompt1)
       COMBO(@s200),AT(33,5,215,10),USE(?Query:Combo),FORMAT('200L(2)|M@S200@'),DROP(10,400),FROM(QueryQueue)
       BUTTON('From People.TPS'),AT(224,24,78,14),USE(?FromPeople)
       BUTTON('Refresh'),AT(251,2,51,14),USE(?Refresh)
       LIST,AT(6,41,308,132),USE(?List1),VSCROLL
       BUTTON('Close'),AT(259,181,51,14),USE(?Button1),STD(STD:Close)
     END

    CODE
    !
    Do LoadQueryList
    !Init Queue of Queries
    IF RECORDS(QueryQueue)=0
       QueryQueue.Query='SELECT ProductID , ProductName FROM Products ORDER BY ProductName'
       ADD(QueryQueue)
       QueryQueue.Query='SELECT ProductName,ProductID FROM Products ORDER BY ProductName'
       ADD(QueryQueue)
       QueryQueue.Query='SELECT ProductName FROM Products ORDER BY ProductName'
       ADD(QueryQueue)
       QueryQueue.Query='SELECT COUNT(*) Records FROM Products'
       ADD(QueryQueue)
    END

    MSProducts &= new(DynFile)
    MEMProducts &= new(DynFile)

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
           OF ?FromPeople
               MEMProducts.UnfixFormat()
               MEMProducts.ResetAll()
               MEMProducts.CreateFromFile(people)
               MEMProducts.SetName('MEMProduct')
               MEMProducts.SetDriver('MEMORY')
               MEMProducts.FillFrom(people)
               
               TheFile &= MEMProducts.GetFileRef()
               DynFileList.Refresh(TheFile)
           END
       END
    END

    DISPOSE(MSProducts)
    DISPOSE(MEMProducts)

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

AddQueryToList   ROUTINE
 
RefreshQuery    ROUTINE
               MSProducts.UnfixFormat()
               MEMProducts.UnfixFormat()

               MSProducts.ResetAll()
               MEMProducts.ResetAll()

			   MSProducts.SetDriver('MSSQL')
			  ! Edit connect string here	
               MSProducts.SetOwner('(local),Northwind,sa,')
	          
	           MSProducts.CreateFromSQL(CLIP(lQuery))
               MEMProducts.SetCreate(true)
               MEMProducts.SetName('MEMProduct')
               MEMProducts.SetDriver('MEMORY')
               MEMProducts.FillFrom(MSProducts)
               TheFile &= MEMProducts.GetFileRef()
               DynFileList.Refresh(TheFile)


DynFileList.Init                      PROCEDURE(UNSIGNED TheList)
 CODE
    SELF.File &= NULL
    SELF.ListControl = TheList
    SELF.ListControl{PROP:VLBVal} = ADDRESS(SELF)
    SELF.ListControl{PROP:VLBProc} = ADDRESS(VLBProc)
    SELF.Changed = False

DynFileList.Refresh                   PROCEDURE(*FILE TheDynFile)
lColumns    SHORT
lFormat     CSTRING(2048),AUTO
Idx         SHORT
  CODE
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
       SET(TheFile)
       lRecords=RECORDS(SELF.File)
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
       locGroup &= SELF.File{prop:Record}
       GET(SELF.File, ROW)
       IF NOT ERRORCODE()
           AttrString &= WHAT(locGroup, COL)
           RETURN AttrString
       ELSE
           MESSAGE(ERRORCODE())
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
