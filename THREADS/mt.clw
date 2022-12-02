! ============================================================================
! This example program demonstrates new aspects of the implementation of
! pre-emptive threads in Clarion 6.0, specifically:
! - All instances of threaded variables have different addresses in different
!   threads. The compiler generates the code to select the variable corresponding to
!   the currently running thread.
! - Initialization and cleanup code for threaded variables is executed for
!   every thread. Specifically, the RTL calls to constructors and destructors
!   of CLASSes declared with the THREAD attribute on startup and termination
!   of every running thread
! - Clarion 6.0 introduces new interfaces to synchronize access to data
!   belonging to one thread from other threads.
! ============================================================================
!
! *Caution*, this example also shows how Suspending of threads can potentially be
!  dangerous if done without great care.  If a thread is suspended, and you attempt to make
!  that same thread's Window active (by giving it focus) will cause the main thread and the 
!  toolbox thread to lockup.  This is because Windows _sends_message to the child window,
!  but inter-thread SendMessage is modal.  Also both the frame and toolbox threads 
!  become locked if you suspend the currently active MDI child window.
!
!  So this example can also teach what not to do when implementing SUSPEND/RESUME.
!
! What this program does:
! - The program has a dummy CODE section, so all the executed code is invoked
!   from the constructor of a global CLASS declared with the THREAD attribute.
! - The constructor opens the MDI frame window in the main thread. A second
!   thread is started automatically and opens the docked toolbox window. All further
!   threads are started manually by pressing the button on the frame toolbox
!   or from menu. They open MDI child windows. These windows change their
!   background color in response to the EVENT:Timer event
! - To start all new threads the program uses a dummy procedure --- all code is
!   made from the constructor of threaded CLASS
! - When a new MDI child window starts, it creates a flat checkbox on the
!   docked toolbox. If you press (untick) the checkbox, the thread that
!   has created that checkbox becomes suspended; if you press (tick) the checkbox
!   again, the thread becomes resumed and continues its work. To avoid
!   conflicts in accessing checkboxes from concurrently running threads
!   the program uses a critical section.
! ============================================================================

        PROGRAM
        INCLUDE('MENUStyle.INC'),ONCE


        MAP
          ThreadProc()                 ! Dummy thread procedure
          FrameProc (*Action)          ! Main thread handler
          ToolProc  (*Action)          ! Toolbox's thread handler
          ChildProc (*Action)          ! MDI child windows threads handlers
        END
 COMPILE ('**CW7**',_CWVER_=7000)
MenuStyleMgr MenuStyleManager
!**CW7**

  COMPILE ('=== C60', _C60_)

        INCLUDE ('CWSYNCHM.INC'),ONCE

Sync           &ICriticalSection       ! The critical section to synchronize
                                       ! access to data belonging to one thread
                                       ! from others
! === C60

! ==============================================================================
! ColorTable is a service class to determine next color to use

ColorTable  CLASS,MODULE('MT001.CLW'),LINK('MT001')

Colors        LONG,DIM(17 * 7)

Construct     PROCEDURE()
GetRGB        PROCEDURE(UNSIGNED),LONG
NextIndex     PROCEDURE(UNSIGNED),UNSIGNED
            END

! ==============================================================================
! Constructor of the Action class determines program behavior

Action      CLASS,THREAD

ThreadNo      SIGNED
Wnd           &WINDOW

Construct     PROCEDURE()
            END

! ==============================================================================

NOTIFY:Started  EQUATE(1)
NOTIFY:Closed   EQUATE(0)
MAX:Threads     EQUATE(64)             ! Limit for test only

MainThread     &Action                 ! Reference to instance of the Action
                                       ! class in the main thread
ToolThread     &Action                 ! Reference to instance of the Action
                                       ! class in the toolbox's thread

! These 2 reference variables give direct access to some thread specific data
! belonging to main and toolbox's threads from other threads.

  CODE
  RETURN

! ==============================================================================
! Dummy thread procedure

ThreadProc  PROCEDURE()
  CODE
  RETURN

! ==============================================================================
! This code is invoked for every started thread before call to ThreadProc. 
! Depending on the  current thread, Action.Construct executes one of 3 handler
! procedures.

Action.Construct  PROCEDURE()
  CODE
  SELF.Threadno = THREAD()

  CASE SELF.ThreadNo
  OF 1
    COMPILE ('=== C60', _C60_)
      Sync &= NewCriticalSection()     ! Create the critical section object
    ! === C60
    MainThread &= SELF                 ! Set MainThread to instance of Action
                                       ! for the main thread
    FrameProc (SELF)
    MainThread &= NULL
    COMPILE ('=== C60', _C60_)
      Sync.Kill()                      ! Delete the critical section
    ! === C60
  OF 2
    ToolThread &= SELF                 ! Set ToolThread to instance of Action
                                       ! for the toolbox's thread
    ToolProc (SELF)
    ToolThread &= NULL
  ELSE
    ChildProc (SELF)
  END
  RETURN

! ==============================================================================

FrameProc  PROCEDURE (*Action THIS)

FrameWnd APPLICATION('New Threads Test'),AT(,,418,219),FONT('MS Sans Serif',8,,),ICON(ICON:Application), |
         WALLPAPER('cwwall.bmp'),TILED,TIMER(10),SYSTEM,MAX,MAXIMIZE,RESIZE
       MENUBAR,USE(?MenuBAR1)
         MENU('&File'),USE(?File)
           ITEM('&New Child'),USE(?FileNewChild)
           ITEM,SEPARATOR
           ITEM('E&xit'),USE(?FileExit),STD(STD:Close)
         END
         MENU('&Window'),USE(?Window)
           ITEM('&Tile'),USE(?WindowTile),STD(STD:TileWindow)
           ITEM('&Cascade'),USE(?WindowCascade),STD(STD:CascadeWindow)
         END
       END
       TOOLBAR,AT(0,0,,25)
         BUTTON('&New Child'),AT(9,5,48,14),USE(?New)
         BUTTON('&Close'),AT(61,5,48,14),USE(?Close),STD(STD:Close)
       END
     END

Thr       SIGNED,AUTO
Kind      UNSIGNED,AUTO

  CODE
  OPEN (FrameWnd)
!After open window
  COMPILE ('**CW7**',_CWVER_=7000)
      FrameWnd{PROP:TabBarVisible}  = False
      MenuStyleMgr.Init(?MENUBAR1)
      MenuStyleMgr.SetFlatMode(True)
      MenuStyleMgr.SetColor(MenuBrushes:ImageBkgnd,16706781,14854529)
      MenuStyleMgr.SetColor(MenuBrushes:SelectedBkgnd,16706781,14854529,False)
      MenuStyleMgr.SetColor(MenuBrushes:SelectedBarBkgnd,16706781,14854529,True)
      MenuStyleMgr.SetColor(MenuBrushes:HotBkgnd,16706781,14854529,True)
      MenuStyleMgr.SetColor(MenuBrushes:FrameBrush,8388608, 8388608,True)
  !**CW7**		
  THIS.Wnd &= FrameWnd

  ACCEPT
    CASE EVENT()
    OF EVENT:OpenWindow
      START (ThreadProc)               ! Start toolbox automatically
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?New
      OROF ?FileNewChild
        START (ThreadProc)             ! Start a new MDI child window
      END

  COMPILE ('=== C60', _C60_)
      ! If frame window is being closed, all child windows are closed too
      ! but for success of closing all suspended threads must be resumed
    OF EVENT:CloseWindow
    OROF EVENT:CloseDown
      Sync.Wait()
      IF NOT ToolThread &= NULL AND NOT ToolThread.Wnd &= NULL
        LOOP Thr = MAX:Threads TO 3 BY -1
          Kind = ToolThread.Wnd $ Thr {PROP:Type}
          IF Kind = CREATE:CHECK
            IF NOT ToolThread.Wnd $ Thr {PROP:Checked}
              RESUME (Thr)
            END
          END
        END
      END
      Sync.Release()
! === C60
    END
  END

  CLOSE (FrameWnd)
  RETURN

! ==============================================================================

ToolProc  PROCEDURE (*Action THIS)

Toolbox WINDOW,AT(,,64,274),FONT('MS Sans Serif',8,,),DOCK(DOCK:left),DOCKED(DOCK:left),TIMER(10),TOOLBOX, |
         GRAY,AUTO
       PANEL,AT(63,0,1,),USE(?Panel1),FULL,BEVEL(-1)
     END

Thr       SIGNED,AUTO
Cmd       UNSIGNED,AUTO
Kind      UNSIGNED,AUTO
Uses      BYTE,DIM(64),AUTO

  CODE
  IF MainThread &= NULL
    RETURN
  END

  OPEN (Toolbox, MainThread.Wnd)
  THIS.Wnd &= Toolbox

  ACCEPT
    CASE EVENT()
    OF EVENT:OpenWindow
      Toolbox {PROP:Height} = MainThread.Wnd {PROP:Height}

  COMPILE ('=== C60', _C60_)
      ! If toolbox window is being closed, it must resume all suspended threads
      ! Otherwise they can't be closed properly
    OF EVENT:CloseWindow
    OROF EVENT:CloseDown
      Sync.Wait()
        LOOP Thr = MAX:Threads TO 3 BY -1
          Kind = Thr {PROP:Type}
          IF Kind = CREATE:CHECK
            IF NOT Thr {PROP:Checked}
              RESUME (Thr)
            END
            DESTROY (Thr)
          END
        END
        THIS.Wnd &= NULL
      Sync.Release()
! === C60

    OF EVENT:Notify
      NOTIFICATION (Cmd, Thr)

      CASE Cmd
      OF NOTIFY:Started
      ! Create flat checkboxes for started threads
        CREATE (Thr, CREATE:CHECK)
        Uses[Thr] = 1
        Thr {PROP:Use} = Uses[Thr]
        SETPOSITION (Thr, 8, (Thr - 3) * 20 + 8, 46, 16)
        Thr {PROP:Flat} = TRUE
        Thr {PROP:Text} = 'Thread ' & Thr
        UNHIDE (Thr)
        DISPLAY (Thr)
      OF Notify:Closed
        DESTROY (Thr)
      END
    OF EVENT:Accepted
  COMPILE ('=== C60', _C60_)
      Sync.Wait()
        Thr = ACCEPTED()
        IF NOT Thr {PROP:Checked}
          IF NOT SUSPEND (Thr, FALSE)  ! Try suspend a thread
            CHANGE (Thr, TRUE)
          END
        ELSE
          RESUME (Thr)                 ! Resume a thread
        END
      Sync.Release()
! === C60
    END
  END

  CLOSE (Toolbox)
  RETURN

! ==============================================================================

ChildProc  PROCEDURE (*Action THIS)

ChildWindow WINDOW('Child Window'),AT(,,185,92),FONT('MS Sans Serif',8), |
         COLOR(COLOR:Black),SYSTEM,GRAY,RESIZE,MDI,MAX,TIMER(15)
     END

ColorIndex  UNSIGNED,AUTO

  CODE
  ! Inform the toolbox about new thread
  NOTIFY (NOTIFY:Started, 2)

  OPEN (ChildWindow)
  ChildWindow {PROP:Text} = 'Thread ' & THIS.ThreadNo

  THIS.Wnd &= ChildWindow
  ColorIndex = 0

  ACCEPT
    CASE EVENT()
  COMPILE ('=== C60', _C60_)
    OF EVENT:CloseWindow
    OROF EVENT:CloseDown
      ! Inform the toolbox that thread is being closed
      NOTIFY (NOTIFY:Closed, 2)
      THIS.Wnd &= NULL
! === C60
    OF EVENT:Timer
      ChildWindow {PROP:Color} = ColorTable.GetRGB (ColorIndex)
      ColorIndex = ColorTable.NextIndex (ColorIndex)
    END
  END

  RETURN

