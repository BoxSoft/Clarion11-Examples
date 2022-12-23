

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('BRWEXT.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE014.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Select a Product Record
!!! </summary>
SelectProduct PROCEDURE 

CurrentTab           STRING(80)                            ! 
BRW1::View:Browse    VIEW(Product)
                       PROJECT(Pro:ProductCode)
                       PROJECT(Pro:ProductName)
                       PROJECT(Pro:Description)
                       PROJECT(Pro:Price)
                       PROJECT(Pro:QuantityInStock)
                       PROJECT(Pro:ReorderQuantity)
                       PROJECT(Pro:Cost)
                       PROJECT(Pro:ImageFilename)
                       PROJECT(Pro:GUID)
                     END
Queue:Browse:1       QUEUE                            !Queue declaration for browse/combo box using ?Browse:1
Pro:ProductCode        LIKE(Pro:ProductCode)          !List box control field - type derived from field
Pro:ProductName        LIKE(Pro:ProductName)          !List box control field - type derived from field
Pro:Description        LIKE(Pro:Description)          !List box control field - type derived from field
Pro:Price              LIKE(Pro:Price)                !List box control field - type derived from field
Pro:QuantityInStock    LIKE(Pro:QuantityInStock)      !List box control field - type derived from field
Pro:ReorderQuantity    LIKE(Pro:ReorderQuantity)      !List box control field - type derived from field
Pro:Cost               LIKE(Pro:Cost)                 !List box control field - type derived from field
Pro:ImageFilename      LIKE(Pro:ImageFilename)        !List box control field - type derived from field
Pro:GUID               LIKE(Pro:GUID)                 !Primary key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
QuickWindow          WINDOW('Select a Product Record'),AT(,,358,198),FONT('Segoe UI',10,COLOR:Black,FONT:regular, |
  CHARSET:DEFAULT),RESIZE,CENTER,GRAY,IMM,MDI,HLP('SelectProduct'),SYSTEM
                       LIST,AT(8,30,342,124),USE(?Browse:1),HVSCROLL,FORMAT('80L(2)|M~Product Code~L(2)@s100@8' & |
  '0L(2)|M~Product Name~L(2)@s100@80L(2)|M~Description~L(2)@s255@64D(28)|M~Price~C(0)@n' & |
  '15.2@72R(2)|M~Quantity In Stock~C(0)@n-14@68R(2)|M~Reorder Quantity~C(0)@n13@68D(32)' & |
  '|M~Cost~C(0)@n-15.2@80L(2)|M~Image~L(2)@s255@'),FROM(Queue:Browse:1),IMM,MSG('Browsing t' & |
  'he Product file')
                       BUTTON('&Select'),AT(300,158,50,14),USE(?Select:2),LEFT,ICON('WASELECT.ICO'),FLAT,MSG('Select the Record'), |
  TIP('Select the Record')
                       SHEET,AT(4,4,350,172),USE(?CurrentTab)
                         TAB('Tab'),USE(?Tab:2)
                         END
                         TAB('Tab'),USE(?Tab:3)
                         END
                         TAB('Tab'),USE(?Tab:4)
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
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse:1
Q                      &Queue:Browse:1                !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
ResetSort              PROCEDURE(BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
BRW1::Sort1:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 2
BRW1::Sort2:Locator  StepLocatorClass                      ! Conditional Locator - CHOICE(?CurrentTab) = 3
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
  GlobalErrors.SetProcedureName('SelectProduct')
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
  Relate:Product.Open()                                    ! File Product used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse:1,Queue:Browse:1.ViewPosition,BRW1::View:Browse,Queue:Browse:1,Relate:Product,SELF) ! Initialize the browse manager
  SELF.Open(QuickWindow)                                   ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?Browse:1{PROP:LineHeight} = 11
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse:1
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,Pro:ProductCodeKey)                   ! Add the sort order for Pro:ProductCodeKey for sort order 1
  BRW1.AddLocator(BRW1::Sort1:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort1:Locator.Init(,Pro:ProductCode,1,BRW1)        ! Initialize the browse locator using  using key: Pro:ProductCodeKey , Pro:ProductCode
  BRW1.AddSortOrder(,Pro:ProductNameKey)                   ! Add the sort order for Pro:ProductNameKey for sort order 2
  BRW1.AddLocator(BRW1::Sort2:Locator)                     ! Browse has a locator for sort order 2
  BRW1::Sort2:Locator.Init(,Pro:ProductName,1,BRW1)        ! Initialize the browse locator using  using key: Pro:ProductNameKey , Pro:ProductName
  BRW1.AddSortOrder(,Pro:GuidKey)                          ! Add the sort order for Pro:GuidKey for sort order 3
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 3
  BRW1::Sort0:Locator.Init(,Pro:GUID,1,BRW1)               ! Initialize the browse locator using  using key: Pro:GuidKey , Pro:GUID
  BRW1.AddField(Pro:ProductCode,BRW1.Q.Pro:ProductCode)    ! Field Pro:ProductCode is a hot field or requires assignment from browse
  BRW1.AddField(Pro:ProductName,BRW1.Q.Pro:ProductName)    ! Field Pro:ProductName is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Description,BRW1.Q.Pro:Description)    ! Field Pro:Description is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Price,BRW1.Q.Pro:Price)                ! Field Pro:Price is a hot field or requires assignment from browse
  BRW1.AddField(Pro:QuantityInStock,BRW1.Q.Pro:QuantityInStock) ! Field Pro:QuantityInStock is a hot field or requires assignment from browse
  BRW1.AddField(Pro:ReorderQuantity,BRW1.Q.Pro:ReorderQuantity) ! Field Pro:ReorderQuantity is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Cost,BRW1.Q.Pro:Cost)                  ! Field Pro:Cost is a hot field or requires assignment from browse
  BRW1.AddField(Pro:ImageFilename,BRW1.Q.Pro:ImageFilename) ! Field Pro:ImageFilename is a hot field or requires assignment from browse
  BRW1.AddField(Pro:GUID,BRW1.Q.Pro:GUID)                  ! Field Pro:GUID is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('SelectProduct',QuickWindow)                ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
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
    Relate:Product.Close()
  END
  BRW1::AutoSizeColumn.Kill()
  IF SELF.Opened
    INIMgr.Update('SelectProduct',QuickWindow)             ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
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
  SELF.SelectControl = ?Select:2
  SELF.HideSelect = 1                                      ! Hide the select button when disabled
  PARENT.Init(ListBox,Posit,V,Q,RM,WM)


BRW1.ResetSort PROCEDURE(BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  IF CHOICE(?CurrentTab) = 2
    RETURN SELF.SetSort(1,Force)
  ELSIF CHOICE(?CurrentTab) = 3
    RETURN SELF.SetSort(2,Force)
  ELSE
    RETURN SELF.SetSort(3,Force)
  END
  ReturnValue = PARENT.ResetSort(Force)
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

