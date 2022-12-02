   
  PROGRAM

  PRAGMA ('project(#file copy AWSSDK.Core.dll)')
  PRAGMA ('project(#file copy AWSSDK.S3.dll)')

  INCLUDE('SpecialFolder.inc'),ONCE
  INCLUDE('CSIDL.equ'),ONCE
  INCLUDE('abutil.inc'),ONCE
  INCLUDE('claawss3.inc'),ONCE
  INCLUDE('keycodes.clw'),ONCE

MyNotificationCode  EQUATE(23)

TreeQData           GROUP,TYPE
Name                  STRING(500)
icon                  LONG
Level                 LONG
ExtraName             STRING(500)
Container             STRING(100)
IsFolder              BOOL
Searched              BOOL
LastModified          GROUP
Date                    DATE
Time                    TIME
                      END
Size                  ULONG
                    END

TreeQ               QUEUE(TreeQData),TYPE
                    END
TransferDataInfo    GROUP(TreeQData),TYPE
pos                   LONG
doingUpload           BOOL
                    END

  MAP
Main    PROCEDURE()
GetIAmInfo  PROCEDURE(*STRING S3Key, *STRING S3Pwd)
ExistsInFolder  PROCEDURE (TreeQ S3Files, TransferDataInfo transferData),BOOL
DisplayError    PROCEDURE(IAWSS3Client client, STRING message)
  END

SpectialFolders     SpecialFolder 
IniManager          INIClass
GlobalErrorStatus   ErrorStatusClass,THREAD
GlobalErrors        ErrorClass                            ! Global error manager

  CODE
  GlobalErrors.Init(GlobalErrorStatus)
  SpectialFolders.CreateDir(SpectialFolders.GetDir(SV:CSIDL_APPDATA, 'SoftVelocity\AWS'));
  IniManager.Init(SpectialFolders.GetDir(SV:CSIDL_APPDATA, 'SoftVelocity\AWS') & '\AWSExample.ini', NVD_INI)
  Main()
  IniManager.Update()
  IniManager.Kill()
  
Main                PROCEDURE()
  MAP
CreateContainer PROCEDURE()
CreateFolder    PROCEDURE()
UploadFile  PROCEDURE()
DeleteContainer PROCEDURE()
DeleteFolder    PROCEDURE()
DeleteFolderNoAsk   PROCEDURE(LONG pos)
EmptyFolder PROCEDURE(LONG pos)
FileProperties  PROCEDURE()
DownloadFile    PROCEDURE()
DeleteFile  PROCEDURE()
DeleteFileNoAsk PROCEDURE()
SetupFolder PROCEDURE(LONG pos)
CheckIfFileExists   PROCEDURE()
  END

S3Files               QUEUE(TreeQ),PRE(SF)
                      END
transferData          GROUP(TransferDataInfo)
                      END
S3Key                 STRING(50)
S3Secret              STRING(50)
regions               RegionList
errors                STRING(500)
i                     LONG
curRec                LONG
client                &IAWSS3Client
clientAddress         LONG
transferProgress      LONG
transferStatus        LONG
notifyCode            LONG
WINDOW                WINDOW('AWS S3 Example'),AT(,,424,198),GRAY,SYSTEM,FONT('Microsoft Sans S' & |
                        'erif',8)
                        LIST,AT(7,7,411,156),USE(?FileList),HVSCROLL,FROM(S3Files),FORMAT('20L(2)IT(' & |
                          'R)~S3 Servers~')
                        BUTTON('Check if file exists'),AT(330,169,37,22),USE(?FileExists)
                        BUTTON('&Finished'),AT(376,173,42,14),USE(?FinishedButton)
                        BUTTON('Set Access Keys'),AT(6,173),USE(?Keys)
                        STRING('Uploading'),AT(93,175),USE(?Uploading),HIDE
                        PROGRESS,AT(139,176,134),USE(transferProgress),HIDE,RANGE(0,100)
                        BUTTON('Cancel'),AT(284,173),USE(?CancelButton),HIDE
                      END

  CODE
  S3Key = IniManager.TryFetch('S3', 'Key')
  S3Secret = IniManager.TryFetch('S3', 'Secret')
  OPEN(Window)
  ALERT(MouseRight)
  ALERT(MouseLeft2)
  ?FileList{PROP:IconList, 1} = '~computer.ico'
  ?FileList{PROP:IconList, 2} = '~bucket.ico'
  ?FileList{PROP:IconList, 3} = '~closedfold.ico'
  ?FileList{PROP:IconList, 4} = '~Item2.ico'
  ACCEPT
    CASE EVENT()
    OF EVENT:OpenWindow
      DO InitialiseS3
    OF EVENT:AlertKey
      IF FOCUS() = ?FileList
        CASE KEYCODE()
        OF MouseRight
          DO GetCurrentRecord
          IF S3Files.Level = 1
            DO RegionPopup
          ELSIF S3Files.Level = 2
            DO ContainerPopup
          ELSIF S3Files.IsFolder
            DO FolderPopup
          ELSE
            DO FilePopup
          END
        OF MouseLeft2
          IF NOT S3Files.IsFolder
            FileProperties()
          END
        END
      END
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?FileList
        DO GetCurrentRecord
        IF S3Files.IsFolder AND NOT S3Files.Searched
          SETCURSOR(CURSOR:Wait)
          SetupFolder(curRec)
          DISPLAY(?FileList)
          SETCURSOR()
        END
      OF ?CancelButton
        client.CancelTransfer()
        SELECT(?FileList)
      OF ?FileExists
        DO GetCurrentRecord
        CheckIfFileExists()
      OF ?FinishedButton
        BREAK
      OF ?Keys
        GetIAmInfo(S3Key, S3Secret)
        DO InitialiseS3
        SELECT(?FileList)
      END
    OF EVENT:Notify
      ! Normally you would use NOTIFICATION to get the client if supporting multiple uploads
      ! In this example there is no need to test the notification code or use the passed
      ! parsameter to get the IAWSStoreage instance as there are no other notifications in 
      ! the program and only one active IAWSStoreage, but the code is here to show how you
      ! can set the notification code returned by the AWS and use multiple IAWSStoreage instances
      NOTIFICATION(notifyCode,,clientAddress)
      IF notifyCode = MyNotificationCode
        client &= (clientAddress)
        client.TransferStatus(transferStatus, transferProgress)
        CASE TransferStatus
        OF AWSTransfer:Transfering
          DISPLAY(?transferProgress)
        OF AWSTransfer:Completed
          MESSAGE('Transfer Complete')
          IF transferData.doingUpload AND NOT ExistsInFolder(S3Files, transferData)
            S3Files = transferData
            ADD(S3Files, transferData.pos)
          END
        OF AWSTransfer:Cancelled
          MESSAGE('Transfer Canceled')
        OF AWSTransfer:Error
          DisplayError(client, 'Transfer Failed')
        END
        IF TransferStatus <> AWSTransfer:Transfering
          HIDE(?Uploading, ?CancelButton)
        END
      END
    END
  END

InitialiseS3        ROUTINE
  DATA
errorInfo   STRING(1000)
needContainers  BOOL(FALSE)
containers  AWSContainerList
j   LONG
  CODE
  FREE(S3Files)
  DISPLAY()
  IF NOT client &= NULL
    client.Disconnect()
    client &= NULL
  END
  IF RECORDS(regions) = 0
    SETCURSOR(CURSOR:Wait)
    IF NOT ListRegions(regions, errors)
      SETCURSOR()
      MESSAGE('Could not list regions. Error: ' & errors)
      RETURN
    END
    SETCURSOR()
  END
  LOOP i = 1 TO RECORDS(regions)
    GET(regions, i)
    SF:Name = regions.DisplayName
    SF:icon = 1
    SF:Level = 1
    SF:ExtraName = regions.SystemName
    SF:IsFolder = TRUE
    SF:Searched = TRUE
    ADD(S3Files)
  END
  IF ~S3Key
    DISABLE(?FileList)
  ELSE
    ENABLE(?FileList)
    DISPLAY()
    SETCURSOR(CURSOR:Wait)
    client &= ConnectToS3(S3Key, S3Secret, errorInfo)
    SETCURSOR()
    IF client &= NULL
      MESSAGE('Could not connect to S3.  Error: ' & errorInfo)
    ELSE
      needContainers = TRUE
    END
    IF needContainers
    ! We set the notification code simply to show doing it.  It is not needed
    ! in this program
      client.SetNotificationCode(MyNotificationCode)
      SETCURSOR(CURSOR:Wait)
      IF NOT client.ListContainers(containers)
        SETCURSOR()
        DisplayError(client, 'Could not get a list of containers')
      ELSE
        LOOP i = RECORDS(containers) TO 1 BY -1
          GET(containers, i)
          LOOP j = 1 TO RECORDS(S3Files)
            GET(S3Files, j)
            IF S3Files.ExtraName = containers.RegionSystemName
              CLEAR(S3Files)
              S3Files.Name = containers.Name
              S3Files.icon = 2
              S3Files.Level = 2
              S3Files.ExtraName = ''
              S3Files.Container = containers.Name
              S3Files.IsFolder = TRUE
              S3Files.Searched = FALSE
              ADD(S3Files, j + 1)
              BREAK
            END
          END
        END
        DISPLAY()
        SETCURSOR()
      END
    END
  END

GetCurrentRecord    ROUTINE
  curRec = CHOICE(?FileList)
  GET(S3Files, curRec)

RegionPopup         ROUTINE
  DATA
RegionMenu  STRING('New Container')
  CODE
  IF POPUP(RegionMenu)
    CreateContainer()
  END
  
ContainerPopup      ROUTINE
  DATA
ContainerMenu   STRING('New Folder|Upload File|Delete Container')
  CODE
  EXECUTE POPUP(ContainerMenu)
    CreateFolder()
    UploadFile()
    DeleteContainer()
  END

FolderPopup         ROUTINE
  DATA
FolderMenu  STRING('New Folder|Upload File|Delete Folder')
  CODE
  EXECUTE POPUP(FolderMenu)
    CreateFolder()
    UploadFile()
    DeleteFolder()
  END
  
FilePopup           ROUTINE
  DATA
FileMenu    STRING('Properties|Download File|Delete File')
  CODE
  EXECUTE POPUP(FileMenu)
    FileProperties()
    DownloadFile()
    DeleteFile()
  END

CheckIfFileExists   PROCEDURE()
fileName              STRING(255)
FileExistsWindow      WINDOW('File Exists?'),AT(,,367,75),GRAY,FONT('Microsoft Sans Serif',8)
                        STRING('Enter the name of a file including all parent folders.  Use / to sep' & |
                          'erate folders.'),AT(62,14)
                        ENTRY(@S200),AT(20,29,331),USE(fileName)
                        BUTTON('Ch&eck'),AT(19,46,41,14),USE(?CheckButton),DEFAULT
                        BUTTON('&Close'),AT(309,46,42,14),USE(?CancelFileExistsButton)
                      END
  CODE
  IF client &= NULL
    MESSAGE('You need to set up connection details first')
    RETURN
  END
  OPEN(FileExistsWindow)
  ACCEPT
    IF EVENT() = EVENT:Accepted
      CASE ACCEPTED()
      OF ?CancelFileExistsButton
        BREAK
      OF ?CheckButton
        IF client.FileExists(S3Files.Container, fileName)
          MESSAGE(CLIP(fileName) & ' exists', 'S3 Example')
        ELSIF client.ErrorCode()
          MESSAGE('An error occured while trying to check if the file exists.|' &|
            'Error: ' & client.Error(), 'S3 Example')
        ELSE
          MESSAGE(CLIP(fileName) & ' does not exist in ' & S3Files.Container, 'S3 Example')
        END
        SELECT(?fileName)
      END
    END
  END
  CLOSE(FileExistsWindow)

SetupFolder         PROCEDURE(LONG pos)
files                 AWSObjectList
j                     LONG
curLevel              LONG
  CODE
  IF NOT client.ListFiles(S3Files.Container, S3Files.ExtraName, files)
    DisplayError(client, 'Could not get a list of files')
  ELSE
    curLevel = S3Files.Level + 1
    S3Files.Searched = TRUE
    PUT(S3Files)
    LOOP i = 1 TO RECORDS(files)
      GET(S3Files, pos)
      GET(files, i)
      S3Files.Name = files.Name
      S3Files.icon = CHOOSE(files.IsFolder, 3, 4)
      S3Files.Level = curLevel
      S3Files.IsFolder = files.IsFolder
      IF S3Files.ExtraName
        S3Files.ExtraName = CLIP(S3Files.ExtraName) & '/' & files.Name
      ELSE
        S3Files.ExtraName = files.Name
      END
      IF NOT S3Files.IsFolder
        S3Files.LastModified = files.LastModified
        S3Files.SIZE = files.Size.lo  ! This example only displays files of less than 4GB in size
      END
      S3Files.Searched = FALSE
      ADD(S3Files, pos + i)
    END
  END

CreateContainer     PROCEDURE
containerName         STRING(200)
CreateContainerWINDOW WINDOW('New Container'),AT(,,223,55),CENTER,GRAY,SYSTEM, |
                        FONT('Microsoft Sans Serif',8)
                        PROMPT('Container Name:'),AT(3,14),USE(?PROMPT1)
                        ENTRY(@s200),AT(61,12,143),USE(containerName)
                        BUTTON('&OK'),AT(3,36,41,14),USE(?OkButton),DEFAULT
                        BUTTON('&Cancel'),AT(163,36,42,14),USE(?Cancel)
                      END
  CODE
  OPEN(CreateContainerWindow)
  ACCEPT
    IF EVENT() = EVENT:Accepted
      CASE ACCEPTED()
      OF ?Cancel
        BREAK
      OF ?OkButton
        IF client.CreateContainer(containerName, S3Files.ExtraName)
          DisplayError(client, 'Container creation Failed')
        ELSE
          S3Files.Name = containerName
          S3Files.icon = 2
          S3Files.Level = 2
          S3Files.ExtraName = ''
          S3Files.Container = containerName
          S3Files.IsFolder = TRUE
          S3Files.Searched = TRUE
          ADD(S3Files, curRec + 1)
          BREAK
        END
      END
    END
  END
  CLOSE(CreateContainerWindow)
  SELECT(?FileList, curRec + 1)

CreateFolder        PROCEDURE
folderName            STRING(255)
fullFolderName        STRING(1024)
CreateFolderWINDOW    WINDOW('New Folder'),AT(,,223,55),CENTER,GRAY,SYSTEM, |
                        FONT('Microsoft Sans Serif',8)
                        PROMPT('Folder Name:'),AT(3,14),USE(?PROMPT1)
                        ENTRY(@s255),AT(61,12,143),USE(folderName)
                        BUTTON('&OK'),AT(3,36,41,14),USE(?OkButton),DEFAULT
                        BUTTON('&Cancel'),AT(163,36,42,14),USE(?Cancel)
                      END
  CODE
  OPEN(CreateFolderWINDOW)
  ACCEPT
    IF EVENT() = EVENT:Accepted
      CASE ACCEPTED()
      OF ?Cancel
        BREAK
      OF ?OkButton
        IF S3Files.ExtraName
          fullFolderName = CLIP(S3Files.ExtraName) & '/' & folderName
        ELSE
          fullFolderName = folderName
        END
        IF client.CreateFolder(S3Files.Container, fullFolderName)
          DisplayError(client, 'Folder creation Failed')
        ELSE
          S3Files.Name = folderName
          S3Files.icon = 3
          S3Files.Level += 1
          S3Files.ExtraName = fullfolderName
          S3Files.IsFolder = TRUE
          S3Files.Searched = TRUE
          ADD(S3Files, curRec + 1)
          BREAK
        END
      END
    END
  END
  CLOSE(CreateFolderWINDOW)
  SELECT(?FileList, curRec + 1)

UploadFile          PROCEDURE()
fileToUpload          STRING(255)
destFile              STRING(1024)
slash                 LONG
async                 BOOL
res                   BOOL
  CODE
  IF FILEDIALOG('Select File to Upload', fileToUpload)
    slash = INSTRING('\', fileToUpload, -1, LEN(fileToUpload))
    transferData.Name = SUB(fileToUpload, slash + 1, 255)
    IF S3Files.ExtraName
      destFile = CLIP(S3Files.ExtraName) & '/' & transferData.Name
    ELSE
      destFile = transferData.Name
    END
    transferProgress = 0
    DISPLAY(?transferProgress)
    async = CHOOSE(MESSAGE('Upload file asynchronously?', 'File Upload', ICON:Question, BUTTON:YES + BUTTON:NO, BUTTON:YES) = BUTTON:YES)
    SETCURSOR(CURSOR:Wait)
    res = client.UploadFile(fileToUpload, S3Files.container, destFile, async)
    SETCURSOR()
    IF res
      DisplayError(client, 'Error uploading file')
    ELSE
      transferData.pos = curRec + 1
      transferData.icon = 4
      transferData.Level = S3Files.Level + 1
      transferData.ExtraName = destFile
      transferData.Container = S3Files.Container
      transferData.IsFolder = FALSE
      transferData.Searched = TRUE
      transferData.doingUpload = TRUE
      IF NOT async
        S3Files = transferData
        ADD(S3Files, transferData.pos)
      ELSE
        ?Uploading{PROP:Text} = 'Uploading'
        UNHIDE(?Uploading, ?CancelButton)
      END
    END
  END
  
DeleteContainer     PROCEDURE()
  CODE
  IF MESSAGE('Are you sure you want to delete the container ' & CLIP(S3Files.Name) & '?', | 
    'Delete Container', ICON:Question, BUTTON:YES + BUTTON:NO, BUTTON:YES) = BUTTON:YES
    SETCURSOR(CURSOR:Wait)
    EmptyFolder(curRec)
    IF client.DeleteContainer(S3Files.Name)
      SETCURSOR()
      DisplayError(client, 'Delete of container ' & CLIP(S3Files.Name) & ' Failed')
    ELSE
      DELETE(S3Files)
      SETCURSOR()
    END
  END
  SELECT(?FileList, curRec)

DeleteFolder        PROCEDURE()
  CODE
  IF MESSAGE('Are you sure you want to delete the folder ' & CLIP(S3Files.Name) & '?', | 
    'Delete Folder', ICON:Question, BUTTON:YES + BUTTON:NO, BUTTON:YES) = BUTTON:YES
    SETCURSOR(CURSOR:Wait)
    DeleteFolderNoAsk(curRec)
    SETCURSOR()
  END
  SELECT(?FileList, curRec)
  
DeleteFolderNoAsk   PROCEDURE(LONG pos)
  CODE
  EmptyFolder(pos)
  IF client.DeleteFolder(S3Files.Container, S3Files.ExtraName)
    DisplayError(client, 'Delete of folder ' & CLIP(S3Files.Name) & ' Failed')
  ELSE
    DELETE(S3Files)
  END

EmptyFolder         PROCEDURE(LONG pos)
level                 LONG,AUTO
  CODE
  GET(S3Files, pos)
  level = S3Files.Level
  GET(S3Files, pos + 1)
  LOOP WHILE NOT ERRORCODE() AND S3Files.Level > level
    IF S3Files.IsFolder
      IF NOT S3Files.Searched
        SetupFolder(pos + 1)
      END
      DeleteFolderNoAsk(pos + 1)
    ELSE
      DeleteFileNoAsk()
    END
    GET(S3Files, pos + 1)
  END
  GET(S3Files, pos)
  
DownloadFile        PROCEDURE()
downloadTo            STRING(255)
async                 BOOL
res                   BOOL
  CODE
  downloadTo = S3Files.Name
  IF FILEDIALOG('Save ' & S3Files.Name & ' to', downloadTo, ,FILE:Save)
    transferData.doingUpload = FALSE
    transferProgress = 0
    DISPLAY(?transferProgress)
    async = CHOOSE(MESSAGE('Download file asynchronously?', 'File Download', ICON:Question, BUTTON:YES + BUTTON:NO, BUTTON:YES) = BUTTON:YES)
    SETCURSOR(CURSOR:Wait)
    res = client.DownloadFile(S3Files.container, S3Files.ExtraName, downloadTo, async)
    SETCURSOR()
    IF res
      DisplayError(client, 'Download Failed')
    ELSIF async
      ?Uploading{PROP:Text} = 'Downloading'
      UNHIDE(?Uploading, ?CancelButton)
    END
  END
  
DeleteFile          PROCEDURE()
  CODE
  IF MESSAGE('Are you sure you want to delete the file ' & CLIP(S3Files.Name) & '?', | 
    'Delete Folder', ICON:Question, BUTTON:YES + BUTTON:NO, BUTTON:YES) = BUTTON:YES
    SETCURSOR(CURSOR:Wait)
    DeleteFileNoAsk()
    SETCURSOR()
  END
  SELECT(?FileList, curRec)

DeleteFileNoAsk     PROCEDURE()
  CODE
  IF client.DeleteFile(S3Files.Container, S3Files.ExtraName)
    DisplayError(client, 'Delete of file ' & CLIP(S3Files.Name) & ' Failed')
  ELSE
    DELETE(S3Files)
  END

FileProperties      PROCEDURE()
  MAP
GetTimeLimitedURL   PROCEDURE()
EditMetaData    PROCEDURE(*STRING key, *STRING value), BOOL
  END

metaData              AWSMetaData
hasPublicAccess       BOOL
publicURL             STRING(300)
modified              STRING(50)
size                  STRING(30)
res                   BOOL
PropertiesWindow      WINDOW('Properties'),AT(,,615,255),CENTER,GRAY,IMM,SYSTEM, |
                        FONT('Microsoft Sans Serif',8),DOUBLE
                        GROUP('Details'),AT(6,5,604,90),USE(?DetailsGroup),BOXED
                          PROMPT('File Size:'),AT(12,17),USE(?PROMPT1)
                          ENTRY(@s30),AT(62,16),USE(SIZE),SKIP,TRN,LEFT,READONLY
                          PROMPT('Last Modified:'),AT(12,31),USE(?PROMPT2)
                          ENTRY(@s50),AT(62,30),USE(modified),SKIP,TRN,LEFT,READONLY
                          PROMPT('Link:'),AT(12,46),USE(?PROMPT3)
                          ENTRY(@s255),AT(62,44,539),CURSOR(CURSOR:Hand),USE(publicURL),SKIP,TRN,LEFT, |
                            FONT(,,0CC6600H,FONT:regular+FONT:underline),READONLY
                          BUTTON('Allow Public Access'),AT(12,68),USE(?PublicAccessButton)
                          BUTTON('Created Temporary Link'),AT(129,68),USE(?TemporaryAccessButton)
                        END
                        LIST,AT(7,103,603,132),USE(?MacroList),HVSCROLL,FROM(metaData), |
                          FORMAT('[122L(2)|M~Key~20L(2)~Value~]|~Metadata~')
                        BUTTON('Add'),AT(6,239),USE(?AddButton)
                        BUTTON('Change'),AT(43,239),USE(?ChangeButton)
                        BUTTON('Delete'),AT(87,239),USE(?DeleteButton)
                        BUTTON('Refresh'),AT(136,239),USE(?RefreshButton)
                        BUTTON('Store All'),AT(287,239),USE(?StoreAll),TIP('Shows saving multiple met' & |
                          'a data items at once')
                        BUTTON('&Close'),AT(568,239,42,14),USE(?CloseButton)
                      END
  CODE
  SETCURSOR(CURSOR:Wait)
  res = client.GetMetaData(S3Files.container, S3Files.ExtraName, metaData)
  SETCURSOR()
  IF NOT res
    DisplayError(client, 'Could not get meta data for ' & CLIP(S3Files.NAME))
  END
  SETCURSOR(CURSOR:Wait)
  hasPublicAccess = CHOOSE(client.HasPublicAccess(S3Files.container, S3Files.ExtraName))
  SETCURSOR()
  IF client.ERROR()
    DisplayError(client, 'Could not get public access status')
  END
  modified = FORMAT(S3Files.LastModified.Date, @D17) & ' ' & FORMAT(S3Files.LastModified.Time, @T4)
  size = CLIP(LEFT(FORMAT(S3Files.Size, @N12))) & ' bytes'
  OPEN(PropertiesWindow)
  ALERT(MouseLeft2)
  0{PROP:Text} = 'Properties for ' & S3Files.NAME
  DO SetPublicAccessText
  DO EnableButtons
  ACCEPT
    CASE EVENT()
    OF EVENT:Selected
      IF SELECTED() = ?publicURL
        RUN(publicURL, 2)
      END
    OF EVENT:NewSelection
      IF FIELD() = ?MacroList
        DO EnableButtons
      END
    OF EVENT:AlertKey
      IF FOCUS() = ?MacroList AND KEYCODE() = MouseLeft2
        POST(EVENT:Accepted, ?ChangeButton)
      END
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?PublicAccessButton
        SETCURSOR(CURSOR:Wait)
        res = client.AllowPublicAccess(S3Files.container, S3Files.ExtraName, CHOOSE(NOT HasPublicAccess))
        SETCURSOR()
        IF res
          DisplayError(client, 'Public Access could not be changed')
        ELSE
          HasPublicAccess = CHOOSE(NOT HasPublicAccess)
          DO SetPublicAccessText
        END
      OF ?TemporaryAccessButton
        GetTimeLimitedURL()
      OF ?AddButton
        CLEAR(metaData)
        IF EditMetaData(metaData.key, metaData.value)
          SETCURSOR(CURSOR:Wait)
          res = client.SetMetaData(S3Files.container, S3Files.ExtraName, metaData.key, metaData.value)
          SETCURSOR()
          IF res
            DisplayError(client, 'Could not add meta data')
          ELSE
            ADD(metaData, metaData.key)
          END
        END
      OF ?ChangeButton
        DO GetRecord
        IF EditMetaData(metaData.key, metaData.value)
          SETCURSOR(CURSOR:Wait)
          res = client.SetMetaData(S3Files.container, S3Files.ExtraName, metaData.key, metaData.value)
          SETCURSOR()
          IF res
            DisplayError(client, 'Could not change meta data')
          ELSE
            PUT(metaData, metaData.key)
            DISPLAY(?MacroList)
            SELECT(?MacroList)
          END
        END
      OF ?DeleteButton
        DO GetRecord
        IF MESSAGE('Do you really want to delete the meta data ' & metaData.key, 'Delete Meta Data', ICON:Question, |
          BUTTON:YES + BUTTON:NO, BUTTON:YES) = BUTTON:YES
          SETCURSOR(CURSOR:Wait)
          res = client.RemoveMetaData(S3Files.container, S3Files.ExtraName, metaData.key)
          SETCURSOR()
          IF res
            DisplayError(client, 'Could not remove meta data')
          ELSE
            DELETE(metaData)
          END
        END
      OF ?RefreshButton
        DO GetRecord
        SETCURSOR(CURSOR:Wait)
        metaData.value = client.GetMetaData(S3Files.container, S3Files.ExtraName, metaData.key)
        SETCURSOR()
        IF client.Error() <> ''
          DisplayError(client, 'Could not get meta data')
        ELSE
          PUT(metaData)
        END
      OF ?StoreAll
        SETCURSOR(CURSOR:Wait)
        res = client.SetMetaData(S3Files.container, S3Files.ExtraName, metaData)
        SETCURSOR()
        IF res
          DisplayError(client, 'Could not save all meta data')
        END
      OF ?CloseButton
        BREAK
      END
    END
  END

SetPublicAccessText ROUTINE
  IF HasPublicAccess
    ?PublicAccessButton{PROP:Text} = 'Deny Public Access'
    UNHIDE(?publicURL)
    publicURL = client.GetPermanentURL(S3Files.container, S3Files.ExtraName)
    IF client.ERROR() = ''
      DISPLAY(?publicURL)
    ELSE
      DisplayError(client, 'Getting Public URL')
    END
  ELSE
    ?PublicAccessButton{PROP:Text} = 'Allow Public Access'
    HIDE(?publicURL)
  END

EnableButtons       ROUTINE
  IF CHOICE(?MacroList) = 0
    DISABLE(?ChangeButton, ?RefreshButton)
  ELSE
    ENABLE(?ChangeButton, ?RefreshButton)
  END

GetRecord           ROUTINE
  DATA
curRec  LONG,AUTO
  CODE
  curRec = CHOICE(?MacroList)
  GET(MetaData, curRec)

GetTimeLimitedURL   PROCEDURE()
urlDays               LONG
urlHours              LONG
urlMinutes            LONG
url                   STRING(1024)
TimeLimitWindow       WINDOW('Caption'),AT(,,357,99),GRAY,FONT('Microsoft Sans Serif',8)
                        GROUP('How long the URL is active'),AT(7,6,341,35),USE(?GROUP1),BOXED
                          PROMPT('Days:'),AT(15,18),USE(?DaysPrompt)
                          SPIN(@N3),AT(38,17),USE(urlDays)
                          PROMPT('Hours:'),AT(79,18),USE(?HoursPrompt)
                          SPIN(@N2),AT(108,17),USE(urlHours)
                          PROMPT('Minutes:'),AT(146,18),USE(?MinutesPrompt)
                          SPIN(@N2),AT(181,17),USE(urlMinutes)
                        END
                        PROMPT('Temporary URL:'),AT(8,46),USE(?urlPrompt),HIDE
                        ENTRY(@s255),AT(91,44,256),USE(url),SKIP,TRN,FLAT,HIDE
                        BUTTON('C&reate'),AT(8,73,41,14),USE(?CreateButton),DEFAULT
                        BUTTON('Copy URL'),AT(155,73),USE(?Copy)
                        BUTTON('&Cancel'),AT(305,73,42,14),USE(?TimeLimitedCancelButton)
                      END
  CODE
  OPEN(TimeLimitWindow)
  0{PROP:Text} = 'Create Time Limited URL for ' & S3Files.Name
  ACCEPT
    CASE ACCEPTED()
    OF ?CreateButton
      url = client.GetTemporaryURL(S3Files.container, S3Files.ExtraName, urlDays, urlHours, urlMinutes)
      IF client.ERROR() = ''
        UNHIDE(?urlPrompt, ?url)
        DISPLAY(?url)
      ELSE
        DisplayError(client, 'Getting Temporary URL')
      END
    OF ?Copy
      SETCLIPBOARD(url)
    OF ?TimeLimitedCancelButton
      BREAK
    END
  END
 

EditMetaData        PROCEDURE(*STRING key, *STRING value)
MetaDataWindow        WINDOW('Caption'),AT(,,283,70),GRAY,FONT('Microsoft Sans Serif',8)
                        PROMPT('Key:'),AT(18,7),USE(?KeyPrompt)
                        ENTRY(@s200),AT(44,6,223),USE(KEY)
                        PROMPT('Value:'),AT(18,28),USE(?ValuePrompt)
                        ENTRY(@s200),AT(44,27,223),USE(VALUE)
                        BUTTON('&OK'),AT(43,49,41,14),USE(?OkButton),DEFAULT
                        BUTTON('&Cancel'),AT(225,49,42,14),USE(?MetaDataCancelButton)
                      END
ret                   BOOL
  CODE
  OPEN (MetaDataWindow)
  IF key = ''
    MetaDataWindow{PROP:Text} = 'Add meta data'
  ELSE
    DISABLE(?Key)
    MetaDataWindow{PROP:Text} = 'Edit meta data'
  END
  ACCEPT
    CASE ACCEPTED()
    OF ?OkButton
      ret = TRUE
      BREAK
    OF ?MetaDataCancelButton
      BREAK
    END
  END
  RETURN ret
  

GetIAmInfo          PROCEDURE(*STRING S3Key, *STRING S3Pwd)
SaveAccessInfo        BOOL
WINDOW                WINDOW('Set IAm Information'),AT(,,325,93),GRAY,FONT('Microsoft Sans Serif',8)
                        PROMPT('S3 Access Key ID:'),AT(8,9),USE(?keyPrompt)
                        ENTRY(@s20),AT(137,9,103),USE(S3Key)
                        PROMPT('S3 Secret Access Key:'),AT(8,29),USE(?pwdPrompt)
                        ENTRY(@s50),AT(137,28,172),USE(S3Pwd)
                        CHECK('Save Access Information'),AT(8,49),USE(SaveAccessInfo)
                        BUTTON('&OK'),AT(8,68,41,14),USE(?OkButton),DEFAULT
                        BUTTON('&Cancel'),AT(268,68,42,14),USE(?CancelButton)
                      END
  CODE
  OPEN(Window)
  ACCEPT
    CASE EVENT()
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?OkButton
        IF SaveAccessInfo
          IniManager.Update('S3', 'Key', S3Key)
          IniManager.Update('S3', 'Secret', S3Pwd)
        END
        BREAK
      OF ?CancelButton
        BREAK
      END
    END
  END

ExistsInFolder      PROCEDURE (TreeQ S3Files, TransferDataInfo transferData)
i                     LONG
  CODE
  LOOP
    GET(S3Files, transferData.pos + i)
    IF ERRORCODE() OR S3Files.Level < transferData.level
      RETURN FALSE
    END
    IF S3Files.NAME = transferData.NAME
      RETURN TRUE
    END
    i += 1
  END

DisplayError        PROCEDURE(IAWSS3Client client, STRING message)
  CODE
  MESSAGE(message & '.  Error: ' & client.ERROR() & CHOOSE(client.ERRORCODE(), '(' & client.ERRORCODE() & ')', ''))

