

   MEMBER('invoice.clw')                                   ! This is a MEMBER module


   INCLUDE('ABBROWSE.INC'),ONCE
   INCLUDE('ABPOPUP.INC'),ONCE
   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE
   INCLUDE('BRWEXT.INC'),ONCE

                     MAP
                       INCLUDE('INVOICE004.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('INVOICE012.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Browse the Product file
!!! </summary>
BrowseProduct PROCEDURE 

CurrentTab           STRING(80)                            ! 
LastColumn           STRING(1)                             ! 
BRW1::View:Browse    VIEW(Product)
                       PROJECT(Pro:ProductCode)
                       PROJECT(Pro:ProductName)
                       PROJECT(Pro:Description)
                       PROJECT(Pro:Price)
                       PROJECT(Pro:QuantityInStock)
                       PROJECT(Pro:ReorderQuantity)
                       PROJECT(Pro:Cost)
                       PROJECT(Pro:GUID)
                     END
Queue:Browse         QUEUE                            !Queue declaration for browse/combo box using ?Browse
Pro:ProductCode        LIKE(Pro:ProductCode)          !List box control field - type derived from field
Pro:ProductName        LIKE(Pro:ProductName)          !List box control field - type derived from field
Pro:Description        LIKE(Pro:Description)          !List box control field - type derived from field
Pro:Price              LIKE(Pro:Price)                !List box control field - type derived from field
Pro:QuantityInStock    LIKE(Pro:QuantityInStock)      !List box control field - type derived from field
Pro:ReorderQuantity    LIKE(Pro:ReorderQuantity)      !List box control field - type derived from field
Pro:Cost               LIKE(Pro:Cost)                 !List box control field - type derived from field
LastColumn             LIKE(LastColumn)               !List box control field - type derived from local data
Pro:GUID               LIKE(Pro:GUID)                 !Primary key field - type derived from field
Mark                   BYTE                           !Entry's marked status
ViewPosition           STRING(1024)                   !Entry's view position
                     END
Window               WINDOW('Products'),AT(,,356,163),FONT('Segoe UI',10,,FONT:regular,CHARSET:DEFAULT),RESIZE, |
  CENTER,ICON('Product.ico'),IMM,MDI,SYSTEM
                       LIST,AT(2,2,351,124),USE(?Browse),HVSCROLL,FORMAT('80L(2)|M~Product Code~@s100@80L(2)|M' & |
  '~Product Name~@s100@80L(2)|M~Description~@s255@64R(2)|M~Price~C(0)@n15.2@72R(2)|M~Qu' & |
  'antity In Stock~C(0)@n-14@68R(2)|M~Reorder Quantity~C(0)@n13@68R(2)|M~Cost~C(0)@n-15' & |
  '.2@2L(2)@s1@'),FROM(Queue:Browse),IMM
                       BUTTON('Insert'),AT(196,129,50,14),USE(?Insert)
                       BUTTON('Change'),AT(250,129,50,14),USE(?Change),DEFAULT
                       BUTTON('Delete'),AT(304,129,50,14),USE(?Delete)
                       BUTTON('Close'),AT(304,146,50,14),USE(?Close)
                     END

BRW1::LastSortOrder       BYTE
BRW1::SortHeader  CLASS(SortHeaderClassType) !Declare SortHeader Class
QueueResorted          PROCEDURE(STRING pString),VIRTUAL
                  END
BRW1::AutoSizeColumn CLASS(AutoSizeColumnClassType)
               END
ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
Run                    PROCEDURE(USHORT Number,BYTE Request),BYTE,PROC,DERIVED
SetAlerts              PROCEDURE(),DERIVED
TakeEvent              PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
BRW1                 CLASS(BrowseClass)                    ! Browse using ?Browse
Q                      &Queue:Browse                  !Reference to browse queue
Init                   PROCEDURE(SIGNED ListBox,*STRING Posit,VIEW V,QUEUE Q,RelationManager RM,WindowManager WM)
SetSort                PROCEDURE(BYTE NewOrder,BYTE Force),BYTE,PROC,DERIVED
                     END

BRW1::Sort0:Locator  StepLocatorClass                      ! Default Locator
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END


  CODE
? DEBUGHOOK(Product:Record)
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
  GlobalErrors.SetProcedureName('BrowseProduct')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Browse
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  BIND('LastColumn',LastColumn)                            ! Added by: BrowseBox(ABC)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  Relate:Product.Open()                                    ! File Product used by this procedure, so make sure it's RelationManager is open
  SELF.FilesOpened = True
  BRW1.Init(?Browse,Queue:Browse.ViewPosition,BRW1::View:Browse,Queue:Browse,Relate:Product,SELF) ! Initialize the browse manager
  SELF.Open(Window)                                        ! Open window
  !Setting the LineHeight for every control of type LIST/DROP or COMBO in the window using the global setting.
  ?Browse{PROP:LineHeight} = 11
  Do DefineListboxStyle
  BRW1.Q &= Queue:Browse
  BRW1.RetainRow = 0
  BRW1.AddSortOrder(,Pro:GuidKey)                          ! Add the sort order for Pro:GuidKey for sort order 1
  BRW1.AddLocator(BRW1::Sort0:Locator)                     ! Browse has a locator for sort order 1
  BRW1::Sort0:Locator.Init(,Pro:GUID,1,BRW1)               ! Initialize the browse locator using  using key: Pro:GuidKey , Pro:GUID
  BRW1.AddField(Pro:ProductCode,BRW1.Q.Pro:ProductCode)    ! Field Pro:ProductCode is a hot field or requires assignment from browse
  BRW1.AddField(Pro:ProductName,BRW1.Q.Pro:ProductName)    ! Field Pro:ProductName is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Description,BRW1.Q.Pro:Description)    ! Field Pro:Description is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Price,BRW1.Q.Pro:Price)                ! Field Pro:Price is a hot field or requires assignment from browse
  BRW1.AddField(Pro:QuantityInStock,BRW1.Q.Pro:QuantityInStock) ! Field Pro:QuantityInStock is a hot field or requires assignment from browse
  BRW1.AddField(Pro:ReorderQuantity,BRW1.Q.Pro:ReorderQuantity) ! Field Pro:ReorderQuantity is a hot field or requires assignment from browse
  BRW1.AddField(Pro:Cost,BRW1.Q.Pro:Cost)                  ! Field Pro:Cost is a hot field or requires assignment from browse
  BRW1.AddField(LastColumn,BRW1.Q.LastColumn)              ! Field LastColumn is a hot field or requires assignment from browse
  BRW1.AddField(Pro:GUID,BRW1.Q.Pro:GUID)                  ! Field Pro:GUID is a hot field or requires assignment from browse
  Resizer.Init(AppStrategy:Surface,Resize:SetMinSize)      ! Controls like list boxes will resize, whilst controls like buttons will move
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('BrowseProduct',Window)                     ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  BRW1.AskProcedure = 1                                    ! Will call: UpdateProduct
  SELF.SetAlerts()
  BRW1::AutoSizeColumn.Init()
  BRW1::AutoSizeColumn.AddListBox(?Browse,Queue:Browse)
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW1::SortHeader.Init(Queue:Browse,?Browse,'','',BRW1::View:Browse,Pro:GuidKey)
  BRW1::SortHeader.UseSortColors = False
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.FilesOpened
    Relate:Product.Close()
  !Kill the Sort Header
  BRW1::SortHeader.Kill()
  END
  BRW1::AutoSizeColumn.Kill()
  IF SELF.Opened
    INIMgr.Update('BrowseProduct',Window)                  ! Save window data to non-volatile store
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
    UpdateProduct
    ReturnValue = GlobalResponse
  END
  RETURN ReturnValue


ThisWindow.SetAlerts PROCEDURE

  CODE
  PARENT.SetAlerts
  !Initialize the Sort Header using the Browse Queue and Browse Control
  BRW1::SortHeader.SetAlerts()


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
  !Take Sort Headers Events
  IF BRW1::SortHeader.TakeEvents()
     RETURN Level:Notify
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
    SELF.InsertControl=?Insert
    SELF.ChangeControl=?Change
    SELF.DeleteControl=?Delete
  END


BRW1.SetSort PROCEDURE(BYTE NewOrder,BYTE Force)

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.SetSort(NewOrder,Force)
  IF BRW1::LastSortOrder<>NewOrder THEN
     BRW1::SortHeader.ClearSort()
  END
  BRW1::LastSortOrder=NewOrder
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window

BRW1::SortHeader.QueueResorted       PROCEDURE(STRING pString)
  CODE
    IF pString = ''
       BRW1.RestoreSort()
       BRW1.ResetSort(True)
    ELSE
       BRW1.ReplaceSort(pString,BRW1::Sort0:Locator)
       BRW1.SetLocatorFromSort()
    END
