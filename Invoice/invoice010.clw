

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('BRWEXT.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE010.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('INVOICE020.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the Configuration file
!!! </summary>
BrowseConfiguration PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(Configuration)
                       PROJECT(Cfg:CompanyName)
                       PROJECT(Cfg:Street)
                       PROJECT(Cfg:City)
                       PROJECT(Cfg:State)
                       PROJECT(Cfg:PostalCode)
                       PROJECT(Cfg:Phone)
                       PROJECT(Cfg:GUID)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Cfg:CompanyName        LIKE(Cfg:CompanyName)          !List box control field - type derived from field
Cfg:Street             LIKE(Cfg:Street)               !List box control field - type derived from field
Cfg:City               LIKE(Cfg:City)                 !List box control field - type derived from field
Cfg:State              LIKE(Cfg:State)                !List box control field - type derived from field
Cfg:PostalCode         LIKE(Cfg:PostalCode)           !List box control field - type derived from field
Cfg:Phone              LIKE(Cfg:Phone)                !List box control field - type derived from field
Cfg:GUID               LIKE(Cfg:GUID)                 !Primary key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Browse the Configuration file'),AT(,,358,198),FONT('Segoe UI',10,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('BrowseConfiguration'),SYSTEM
                       LIST,AT(8,30,342,124),USE(?Browse:1),HVSCROLL,FORMAT('80L(2)|M~Company Name~L(2)@s100@8' & |
  '0L(2)|M~Street~L(2)@s255@80L(2)|M~City~L(2)@s100@80L(2)|M~State~L(2)@s100@80L(2)|M~P' & |
  'ostal Code~L(2)@s100@80L(2)|M~Phone#~L(2)@s100@'),FROM(Queue:Browse:1),IMM,MSG('Browsing t' & |
  'he Configuration file')
                       BUTTON('&Insert'),AT(192,158,50,14),USE(?Insert:2),LEFT,ICON('WAINSERT.ICO'),FLAT,MSG('Insert a Record'), |
  TIP('Insert a Record')
                       BUTTON('&Change'),AT(246,158,50,14),USE(?Change:2),LEFT,ICON('WACHANGE.ICO'),DEFAULT,FLAT, |
  MSG('Change the Record'),TIP('Change the Record')
                       BUTTON('&Delete'),AT(300,158,50,14),USE(?Delete:2),LEFT,ICON('WADELETE.ICO'),FLAT,MSG('Delete the Record'), |
  TIP('Delete the Record')
                       SHEET,AT(4,4,350,172),USE(?CurrentTab)
                         TAB('Tab'),USE(?Tab:2)
                         END
                       END
                       BUTTON('&Close'),AT(304,180,50,14),USE(?Close),LEFT,ICON('WACLOSE.ICO'),FLAT,MSG('Close Window'), |
  TIP('Close Window')
                     END

BRW1::AutoSizeColumn CLASS(AutoSizeColumnClassType)
               END
ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END


  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('BrowseConfiguration')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse:1
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  Relate:Configuration.Open()                              ! File Configuration used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Configuration,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?Browse:1{PROP:LineHeight} = 11
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,Cfg:GuidKey)                          ! Add the sort order for Cfg:GuidKey for sort order 1
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort0:Locator.Init(,Cfg:GUID,1,BRW1)               ! Initialize the browse locator using  using key: Cfg:GuidKey , Cfg:GUID
  BRW1.AddField(Cfg:CompanyName,BRW1.Q.Cfg:CompanyName)    ! Field Cfg:CompanyName is a hot field or requires assignment from browse
  BRW1.AddField(Cfg:Street,BRW1.Q.Cfg:Street)              ! Field Cfg:Street is a hot field or requires assignment from browse
  BRW1.AddField(Cfg:City,BRW1.Q.Cfg:City)                  ! Field Cfg:City is a hot field or requires assignment from browse
  BRW1.AddField(Cfg:State,BRW1.Q.Cfg:State)                ! Field Cfg:State is a hot field or requires assignment from browse
  BRW1.AddField(Cfg:PostalCode,BRW1.Q.Cfg:PostalCode)      ! Field Cfg:PostalCode is a hot field or requires assignment from browse
  BRW1.AddField(Cfg:Phone,BRW1.Q.Cfg:Phone)                ! Field Cfg:Phone is a hot field or requires assignment from browse
  BRW1.AddField(Cfg:GUID,BRW1.Q.Cfg:GUID)                  ! Field Cfg:GUID is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseConfiguration',QuickWindow)          ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateConfiguration
  SELF.SetAlerts()
  BRW1::AutoSizeColumn.Init()
  BRW1::AutoSizeColumn.AddListBox(?Browse:1,Queue:Browse:1)
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Configuration.Close()
  END
  BRW1::AutoSizeColumn.Kill()
  IF SELF.Opened
    INIMgr.Update('BrowseConfiguration',QuickWindow)       ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.Run PROCEDURE(USHORT Number,BYTE Request)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Run(Number,Request)
  IF SELF.Request = ViewRecord
    ReturnValue = RequestCancelled                         ! Always return RequestCancelled if the form was opened in ViewRecord mode
  ELSE
    GlobalRequest = Request
    UpdateConfiguration
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


ThisWindow.TakeEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  IF BRW1::AutoSizeColumn.TakeEvents()
     RETURN Level:Notify
  END
  ReturnValue = PARENT.TakeEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


BRW1.Init PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)

  CODE
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)
  IF WM.Request <> ViewRecord                              ! If called for anything other than ViewMode, make the insert, change & delete controls available
    SELF.InsertControl=?Insert:2
    SELF.ChangeControl=?Change:2
    SELF.DeleteControl=?Delete:2
  END


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

