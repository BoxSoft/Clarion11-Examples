
 SECTION('Equates')
UINT                    EQUATE(UNSIGNED)
FOURCC                  EQUATE(LONG)
WCHAR                   EQUATE(BYTE)
UCHAR                   EQUATE(BYTE)
CHAR                    EQUATE(BYTE)
BOOL                    EQUATE(SIGNED)
BYTE                    EQUATE(BYTE)
WORD                    EQUATE(SIGNED)
DWORD                   EQUATE(ULONG)
HANDLE                  EQUATE(UNSIGNED)
LPVOID                  EQUATE(ULONG)
PVOID                   EQUATE(ULONG)
FLOAT                   EQUATE(SREAL)
LPSTR                   EQUATE(CSTRING)    !Usage:Pass the Label of the LPSTR
LPCSTR                  EQUATE(CSTRING)    !Usage:Pass the Label of the LPCSTR
MAX_PATH                EQUATE(260)
HWND                    EQUATE(HANDLE)
HINSTANCE               EQUATE(HANDLE)
HMODULE                 EQUATE(HINSTANCE)
HTASK                   EQUATE(HANDLE)
HDC                     EQUATE(HANDLE)
WPARAM                  EQUATE(UINT)
LPARAM                  EQUATE(LONG)
LRESULT                 EQUATE(LONG)
LPBOOL                  EQUATE(ULONG)
LPCVOID                 EQUATE(ULONG)

HDIOBJ                  EQUATE(HANDLE)
HCOLORSPACE             EQUATE(HANDLE)
HRDVR                   EQUATE(HANDLE)
HWAVEOUT                EQUATE(HANDLE)
HWAVEIN                 EQUATE(HANDLE)
HACCEL                  EQUATE(HANDLE)
HBITMAP                 EQUATE(HANDLE)
HPEN                    EQUATE(HANDLE)
HWINSTA                 EQUATE(HANDLE)
HBRUSH                  EQUATE(HANDLE)
HRGN                    EQUATE(HANDLE)
HKL                     EQUATE(HANDLE)
HPALETTE                EQUATE(HANDLE)
HFONT                   EQUATE(HANDLE)
HHOOK                   EQUATE(HANDLE)
HDRVR                   EQUATE(HANDLE)
HDWP                    EQUATE(HANDLE)
HRSRC                   EQUATE(HANDLE)
HSTR                    EQUATE(HANDLE)
HCURSOR                 EQUATE(HANDLE)
HICON                   EQUATE(HCURSOR)
HGRN                    EQUATE(HANDLE)
HMENU                   EQUATE(HANDLE)
SC_HANDLE               EQUATE(HANDLE)
HDESK                   EQUATE(HANDLE)
HENHMETAFILE            EQUATE(HANDLE)
HSZ                     EQUATE(WORD)
HMETAFILE               EQUATE(HANDLE)
HMIDIIN                 EQUATE(HANDLE)
HMIDIOUT                EQUATE(HANDLE)
HMMIO                   EQUATE(HANDLE)
HFILE                   EQUATE(SIGNED)
LUID                    EQUATE(LONG)
PLUID                   EQUATE(LONG)

ANYSIZE_ARRAY           EQUATE(1)        
PHANDLE                 EQUATE(HANDLE)        
SPHANDLE                EQUATE(HANDLE)        
LPHANDLE                EQUATE(HANDLE)        
HGLOBAL                 EQUATE(HANDLE)        
HLOCAL                  EQUATE(HANDLE)        
GLOBALHANDLE            EQUATE(HANDLE)        
LOCALHANDLE             EQUATE(HANDLE)        
ATOM                    EQUATE(UINT)        

COLORREF                EQUATE(DWORD)                   
HDDEDATA                EQUATE(DWORD)                   
HCONV                   EQUATE(DWORD)                   
HCONVLIST               EQUATE(DWORD)                   
LONGREAL                EQUATE(REAL)        
DWORDLONG               EQUATE(REAL)        
WORDLONG                EQUATE(REAL)        
LARGE_INTEGER           EQUATE(LONG)        
ULARGE_INTEGER          EQUATE(ULONG)        
BOOLEAN                 EQUATE(BYTE)        
VERSION                 EQUATE(UNSIGNED)        

!TYPE definitions only--these declarations are used only to
!define other data structures. No memory is allocated for TYPEs!
RECT    GROUP,TYPE
left      SIGNED
top       SIGNED
right     SIGNED
bottom    SIGNED
        END

POINT   GROUP,TYPE
X         SIGNED
Y         SIGNED
        END

WINDOWPLACEMENT GROUP,TYPE
length            UINT
flags             UINT
showCmd           UINT
ptMinPosition     LIKE(POINT)
ptMaxPosition     LIKE(POINT)
rcNormalPosition  LIKE(RECT)
                END

!"real" data structure based on above TYPE. The following structure
!has memory allocated and is used to hold and pass data.
rcNormalPosition  GROUP(Rect)        !Inherit from TYPEd group RECT
                  END

 SECTION('Prototypes')
              Module('Windows API')
                GetParent(HWND),HWND,PASCAL
                   OMIT('***',_WIDTH32_)
                GetClassName(HWND, *LPSTR, SIGNED),SIGNED,PASCAL,RAW
                   ***
                  COMPILE('***',_WIDTH32_)
                GetClassName(HWND,*LPSTR,SIGNED),SIGNED,PASCAL,RAW,NAME('GetClassNameA')
                  ***
                    OMIT('***',_WIDTH32_)
                GetModuleFileName(HINSTANCE, *LPSTR, SIGNED),SIGNED,PASCAL,RAW
                    ***
                    COMPILE('***',_WIDTH32_)
                GetModuleFileName(HINSTANCE,*LPSTR,DWORD),DWORD,PASCAL,RAW,NAME('GetModuleFileNameA')
                    ***
                GetWindowPlacement(HWND, *WINDOWPLACEMENT),BOOL,PASCAL,RAW
                GetWindowRect(HWND, *RECT),PASCAL,RAW
                GetWindowRgn(HWND,HRGN),SIGNED,PASCAL
                    OMIT('***',_WIDTH32_)
                GetWindowsDirectory(*LPSTR, WORD),WORD,PASCAL,RAW
                    ***
                    COMPILE('***',_WIDTH32_)
                GetWindowsDirectory(*LPSTR,UNSIGNED),UNSIGNED,PASCAL,RAW,NAME('GetWindowsDirectoryA')
                    ***
                EnumChildWindows(HWND, CBK_EnumFunc, LPARAM),BOOL,PASCAL
                  OMIT('***',_WIDTH32_)
                GetModuleHandle(*LPCSTR),HMODULE,PASCAL,RAW
                   ***
                  COMPILE('***',_WIDTH32_)
                GetModuleHandle(*LPCSTR),HMODULE,PASCAL,RAW,NAME('GetModuleHandleA')
                   ***

             End
