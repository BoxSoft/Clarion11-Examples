APIExample  PROGRAM
            !This program demonstrates how to call WIN-API functions

            INCLUDE('EQUATES.CLW')      !Standard Clarion Equates
            INCLUDE('KEYCODES.CLW')     !Standard Clarion Equates

            INCLUDE('WINAPI.CLW','Equates')
                                        !TYPEd groups used by this program
                                        !extracted from WINTYPES.TXT 
                                        !could have been included in WINEQU.CLW
                                        
            MAP
              !User Defined Procedure Prototypes
              BooleanBand(ULONG,ULONG),BYTE          !Returns the boolean
                                                     !value of the 2 params
                                                     !bitwise 'anded'
              DecToHex(ULONG,<SHORT>),STRING         !Converts decimal to hex
              DisplayInfo()                          !Display Window to show API info
              CBk_EnumFunc(hWnd hWnd,lParam lParam),SHORT,PASCAL !Callback Enum function
                                                     !required by Win API

              INCLUDE('WINAPI.CLW','Prototypes')     !API Prototypes
            END


ModuleName      LPCSTR(255)              !declare API parameters using WIN data types (in WINEQU.CLW)
ModuleHandle    HMODULE
ModuleFileName  LPCSTR(255)
wReturn         WORD
szWindowsDir    LPSTR(144)


Queue       QUEUE,PRE(Que)
HexhWnd       STRING(4)                  !Will hold hex value of hWnd for display purposes
ClassName     CSTRING(16)
hWnd          USHORT                     !Real value of hWnd
            END

Window WINDOW('Windows API Function Example'),AT(,,262,179),FONT('Arial',10,,FONT:regular,CHARSET:ANSI), |
         CENTER,SYSTEM,GRAY,DOUBLE
       PROMPT('&Module Handle:'),AT(3,3),USE(?AppModHandle),RIGHT
       STRING(@s15),AT(195,3),USE(szWindowsDir)
       PROMPT('Windows Directory: '),AT(126,3),USE(?WindowsDirPrompt)
       STRING(@p##########p),AT(63,3,40,10),USE(ModuleHandle),LEFT
       LIST,AT(3,16,145,128),USE(?ListBox),VSCROLL,FORMAT('26L(1)|~hWnd~@s4@133L(1)|~Class Name~@s32@'), |
           FROM(Queue)
       GROUP('Example Controls'),AT(161,16,96,129),USE(?Group),BOXED
         COMBO(@s20),AT(167,28,84,10),USE(?ComboBox),READONLY,FORMAT('27L(1)|~hWnd~@n05@20L(1)|~Class Name~@s32@'), |
             DROP(3),FROM(Queue)
         BOX,AT(167,40,84,16),USE(?Box1),FILL(COLOR:Red)
         CHECK('&Check Box'),AT(169,60),USE(?Check)
         OPTION('&Radio Button Group'),AT(165,72,88,36),USE(?Option),BOXED
           RADIO('Radio 1'),AT(169,84),USE(?Option1:Radio1)
           RADIO('Radio 2'),AT(169,96),USE(?Option:Radio2)
         END
         SPIN(@n05),AT(203,128,48,12),USE(?Spin),READONLY,RANGE(1,100),STEP(1)
       END
       IMAGE('sv_small.jpg'),AT(3,151,61,24),USE(?Image1),CENTERED
       BUTTON('&Quit'),AT(206,156,49,14),USE(?QuitButton)
       LINE,AT(256,123,-92,0),USE(?Line1),COLOR(COLOR:Red)
     END

  CODE
  wReturn = GetWindowsDirectory(szWindowsDir, size(szWindowsDir))   !API call
  ModuleName = 'APIEXMPL.EXE'
  ModuleHandle = GetModuleHandle(ModuleName)                        !API Call
  wReturn = GetModuleFileName( ModuleHandle, ModuleFileName, size(ModuleFileName))   !API Call
  OPEN(Window)
  Window{Prop:Text} = 'Windows API Example - ' & ModuleFileName
  ?ListBox{Prop:Alrt}=MouseLeft2
  IF EnumChildWindows(Window{Prop:Handle},CBk_EnumFunc,0) THEN    !Calls CBk_EnumFunc for every window control
    ACCEPT
      CASE EVENT()
      OF Event:GainFocus
        SELECT(?ListBox,1)
        DISPLAY
      END
      CASE FIELD()
      OF ?QuitButton
        IF EVENT()=Event:Accepted THEN BREAK.
      OF ?ListBox
        CASE EVENT()
        OF Event:AlertKey
          IF KEYCODE()=MouseLeft2 THEN
            GET(Queue,Choice(?ListBox))
            DisplayInfo
          END
        END
      END
    END  ! Accept
  END !If EnumChildWindows

  CLOSE(Window)
  FREE(Queue)


DisplayInfo PROCEDURE

MYRect            GROUP(Rect),PRE(Rct)    !Inherit from TYPEd group RECT
                  END                     !defined in WINSTRU.CLW

MyWindowPlacement GROUP(WindowPlacement)  !Inherit from TYPEd group WINDOWPLACEMENT
                  END                     !defined in WINSTRU.CLW


Infowindow WINDOW('Information...'),AT(,,230,70),FONT('Arial',10,,FONT:regular),CENTER,SYSTEM,GRAY,DOUBLE
       PROMPT('Class Name:'),AT(8,5,56,10),USE(?Prompt2),LEFT
       STRING(@s32),AT(70,4,132,10),USE(Que:ClassName),LEFT
       PROMPT('Client Rectangle:'),AT(8,16),USE(?Prompt1),LEFT
       STRING('***'),AT(69,15,163,10),USE(?RectInfo)
       PROMPT('Parents hWnd Handle:'),AT(8,28),USE(?Prompt3),LEFT
       STRING('####'),AT(88,28,132,10),USE(?ParenthWnd),LEFT
       BUTTON('&OK'),AT(95,51),USE(?OKButton),DEFAULT
     END

  CODE
  OPEN(InfoWindow)
  ACCEPT
      CASE EVENT()
      OF EVENT:OpenWindow
        GetWindowRect(Que:hWnd,MyRect)           !API Call
        ?RectInfo{Prop:Text}='Left:'&Rct:Left&','&'Top:'&Rct:Top&','&'Right;'&Rct:Right&','&'Bottom:'&Rct:Bottom
        ?ParenthWnd{Prop:Text}=DecToHex(GetParent(Que:hWnd))     !API Call
        MyWindowPlaceMent:Length=SIZE(MyWindowPlacement)      
        IF NOT GetWindowPlacement(Que:hWnd,MyWindowPlacement)    !API Call
          CLEAR(MyWindowPlacement)
        END
      END
      CASE FIELD()
      OF ?OKButton
        IF EVENT()=Event:Accepted THEN POST(Event:CloseWindow).
      END
  END
  CLOSE(InfoWindow)


CBk_EnumFunc FUNCTION(hWnd hWnd,lParam lParam)

  CODE
  Que:hWnd=hWnd
  Que:HexhWnd=DecToHex(Que:hWnd,4)
  CLEAR(Que:ClassName)
  IF GetClassName(hWnd,Que:ClassName,SIZE(Que:ClassName)) !Make API Call
    ADD(Queue,Que:ClassName)                !Add to queue, sort by ClassName
  END
  RETURN(1)                                 !Forces re-call to CBf_Func



DecToHex    FUNCTION(Value,Digits)

Pos         ULONG,AUTO
PwrValue    ULONG,AUTO
RVal        STRING(8)
RValChar    STRING(1),DIM(Size(RVal)),OVER(RVal)
HexChars    STRING('0123456789ABCDEF')

  CODE
  IF OMITTED(2) THEN Digits=4.             !Set default value for digits
  LOOP Pos=Digits TO 1 BY -1
      PwrValue=16^(Pos-1)
      IF PwrValue>Value THEN
          RValChar[Digits-Pos+1]='0'
      ELSE
          RValChar[Digits-Pos+1]=HexChars[Int(Value/PwrValue)+1]
          Value-=(PwrValue*Int(Value/PwrValue))
      END
  END
  RETURN(CLIP(RVal))


BooleanBand FUNCTION(Value,Msk)

  CODE
  IF BAND(Value,Msk) THEN RETURN(1) ELSE RETURN(0).



