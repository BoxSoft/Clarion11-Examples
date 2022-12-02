        PROGRAM

        INCLUDE('RTF.INT'),ONCE
        INCLUDE('KEYCODES.CLW'),ONCE

        MAP
          T1()
          ToTwips  (LONG,BYTE),LONG,PRIVATE
          FromTwips(LONG,BYTE),LONG,PRIVATE
          IndentDlg(*RTFProperty)
          TabDlg   (*RTFTabs, BYTE)
          Find     (*RTFHandler, <STRING>),BOOLEAN,PROC

          FindDlg  (STRING, STRING)

          SetEffects (*RTFFont)

          MODULE('')
            MulDiv (LONG,LONG,LONG),LONG,PASCAL
          END
        END

EVENT:FindCancel   EQUATE(3000h)
EVENT:FindOK       EQUATE(3001h)

  CODE
  T1()
  RETURN

! =============================================================================

ToTwips  PROCEDURE (LONG V, BYTE Unit)
  CODE
  IF Unit = UNIT:MM100
    V = MulDiv (V, 144, 254)
  ELSIF Unit = UNIT:Inch1000
    V = MulDiv (V, 144, 100)
  END

  RETURN V

! =============================================================================

FromTwips  PROCEDURE (LONG V, BYTE Unit)
  CODE
  IF Unit = UNIT:MM100
    V = MulDiv (V, 254, 144)
  ELSIF Unit = UNIT:Inch1000
    V = MulDiv (V, 100, 144)
  END

  RETURN V

! =============================================================================

IndentDlg  PROCEDURE (*RTFProperty prop)

Left       LONG,AUTO
Right      LONG,AUTO
First      LONG,AUTO
Unit       BYTE,AUTO
Unit1      BYTE,AUTO

W    WINDOW('Paragraph Indents'),AT(,,156,121),FONT('Tahoma',8,,FONT:regular,CHARSET:ANSI),SYSTEM,GRAY, |
         AUTO
       PROMPT('&Units:'),AT(10,12),USE(?Propmpt:Units),TRN
       LIST,AT(57,10,85,12),USE(Unit),LEFT(2),TIP('Units'),DROP(10),FROM('1/100 of millimeter|#1|1/1000 of inch|#2|twips (1/1440 of inch)|#3')
       PROMPT('&First:'),AT(10,34),USE(?Prompt:First),TRN
       SPIN(@N-_6),AT(57,32,84,12),USE(First),RIGHT(2),TIP('First line indent'),RANGE(-99999,99999),STEP(1)
       PROMPT('&Left:'),AT(10,56),USE(?Prompt:Left),TRN
       SPIN(@N-_6),AT(57,54,84,12),USE(Left),RIGHT(2),TIP('Left indent relative first line'),RANGE(-99999,99999),STEP(1)
       PROMPT('&Right:'),AT(11,78),USE(?Prompt:Right),TRN
       SPIN(@N-_6),AT(57,76,84,12),USE(Right),RIGHT(2),TIP('Right indent'),RANGE(-99999,99999),STEP(1)
       BUTTON('OK'),AT(46,97,45,14),USE(?OK),TIP('Save changes'),DEFAULT
       BUTTON('Cancel'),AT(96,97,45,14),USE(?Cancel),TIP('Discard changes'),KEY(EscKey)
     END


  CODE
  Unit  = prop.Unit()
  Unit1 = Unit

  prop.GetIndent (Left, Right, First)
  Left += First

  OPEN (W)

  ACCEPT
    CASE EVENT()
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?OK
        Left -= First
        prop.Unit (Unit)
        prop.SetIndent (Left, Right, First)
      OROF ?Cancel
        POST (EVENT:CloseWindow)
      END
    OF EVENT:NewSelection
      IF FIELD() = ?Unit
        Left  = FromTwips (ToTwips (Left,  Unit1), Unit)
        Right = FromTwips (ToTwips (Right, Unit1), Unit)
        First = FromTwips (ToTwips (First, Unit1), Unit)
        Unit1 = Unit
      END
    END
  END

  CLOSE (W)
  RETURN

! =============================================================================

TabDlg  PROCEDURE (*RTFTabs Tabs, BYTE Unit)

TabQ       QUEUE,AUTO
pos          LONG
           END
Unit1      BYTE,AUTO
EIP        BYTE,AUTO
Dirty      BOOLEAN,AUTO
NTabs      UNSIGNED,AUTO
i          UNSIGNED,AUTO

W    WINDOW('Tabs'),AT(,,232,185),FONT('Tahoma',8,,),IMM,ALRT(EscKey),ALRT(EnterKey),SYSTEM,GRAY,AUTO
       PROMPT('&Units:'),AT(12,12),USE(?Propmpt:Units),TRN
       LIST,AT(57,10,85,12),USE(Unit),SKIP,LEFT(2),TIP('Units'),DROP(10),FROM('1/100 of millimeter|#1|1/1000 of inch|#2|twips (1/1440 of inch)|#3')
       GROUP('&Tabs'),AT(12,30,132,145),USE(?Group:Tabs),BOXED,TRN
       END
       LIST,AT(25,47,106,116),USE(?TabList),FLAT,VSCROLL,RIGHT(2),TIP('List of tab stops'),COLUMN, |
         FORMAT('20R(2)_@N-_6@'),FROM(TabQ),ALRT(MouseLeft2)
       BUTTON('OK'),AT(163,10,45,14),USE(?OK),TIP('Save changes'),DEFAULT
       BUTTON('Cancel'),AT(164,30,45,14),USE(?Cancel),TIP('Discard changes')
       BUTTON('&Insert'),AT(164,66,45,14),USE(?Insert),TIP('Add new tab stop'),KEY(InsertKey)
       BUTTON('&Change'),AT(164,87,45,14),USE(?Change),TIP('Change tab stop'),KEY(CtrlEnter)
       BUTTON('&Delete'),AT(164,107,45,14),USE(?Delete),TIP('Delete tab stop'),KEY(DeleteKey)
       BUTTON('Clear &All'),AT(164,128,45,14),USE(?DoAll),TIP('Clear all tab stops'),KEY(CtrlDelete)
       ENTRY(@N-_6),AT(153,162,60,10),USE(TabQ.Pos,,?Edit),HIDE
     END

  CODE
  Dirty = FALSE
  EIP   = 0
  Unit1 = Unit
  NTabs = Tabs.Count()

  LOOP WHILE NTabs <> 0
    TabQ.pos = Tabs.Tab (NTabs)
    ADD (TabQ)
    NTabs -= 1
  END

  SORT (TabQ, TabQ.pos)

  OPEN (W)

  ?TabList {PROP:LineHeight} = 10

  DO CheckButtons
  SELECT (?TabList)

  ACCEPT
    CASE EVENT()
    OF EVENT:AlertKey
      CASE KEYCODE()
      OF MouseLeft2
        POST (EVENT:Accepted, ?Change)
      OF EscKey
        IF EIP <> 0
          IF EIP = 1
            DELETE (TabQ)
          END
          DO StopEIP
        ELSE
          POST (EVENT:Accepted, ?Cancel)
        END
      OF EnterKey
        IF EIP <> 0
          POST (EVENT:Accepted, ?Edit)
        ELSE
          POST (EVENT:Accepted, ?OK)
        END
      END
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?OK
        IF Dirty
          Tabs.RemoveAll()
          LOOP i = 1 TO RECORDS (TabQ)
            GET (TabQ, i)
            Tabs.Insert (TabQ.pos, Unit)
          END
          Tabs.Update()
        END
      OROF ?Cancel
        POST (EVENT:CloseWindow)
      OF ?Unit
        DO ChangeUnit
        DISPLAY (?TabList)
      OF ?Delete
        IF CHOICE(?TabList) <> 0
          GET (TabQ, CHOICE(?TabList))
          DELETE (TabQ)
          Dirty = TRUE
        END
        DO CheckButtons
      OF ?DoAll
        FREE (TabQ)
        Dirty = TRUE
        DO CheckButtons
      OF ?Insert
        TabQ.pos = 0
        ADD (TabQ)
        GET (TabQ, RECORDS (TabQ))
        SELECT (?TabList, RECORDS (TabQ))

        DO StartEIP
        EIP = 1
      OF ?Change
        IF CHOICE(?TabList) <> 0
          GET (TabQ, CHOICE (?TabList))

          DO StartEIP
          EIP = 2
        END
      OF ?Edit
        PUT (TabQ)
        SORT (TabQ, TabQ.pos)
        DO StopEIP

        Dirty = TRUE
        SELECT (?TabList, POSITION (TabQ))
      END
    END
  END

  CLOSE (W)
  RETURN

ChangeUnit  ROUTINE
  IF Unit <> Unit1
    LOOP i = 1 TO RECORDS (TabQ)
      GET (TabQ, i)
      TabQ.pos = FromTwips (ToTwips (TabQ.pos, Unit1), Unit)
      PUT (TabQ)
    END

    Unit1 = Unit
  END
  EXIT

StartEIP  ROUTINE
  ?TabList {PROP:Edit, 1} = ?Edit
  SELECT (?Edit)
  DISABLE (?OK, ?DoAll)
  EXIT

StopEIP  ROUTINE
  EIP = 0
  ?TabList {PROP:Edit, 1} = 0
  HIDE (?Edit)
  ENABLE (?OK, ?Insert)
  DO CheckButtons
  EXIT

CheckButtons  ROUTINE
  IF RECORDS (TabQ) = 0
    DISABLE (?Change, ?DoAll)
  ELSE
    ENABLE (?Change, ?DoAll)
  END
  EXIT

! =============================================================================

Find  PROCEDURE (*RTFHandler RTF, <STRING Text>)

ExitEvent  UNSIGNED,AUTO

  CODE
  START (FindDlg,, ADDRESS (RTF), Text)

  ACCEPT
    CASE EVENT()
    OF EVENT:FindOK
    OROF EVENT:FindCancel
      ExitEvent = EVENT()
      BREAK
    END
  END

  RETURN CHOOSE (ExitEvent = EVENT:FindOK)

! =============================================================================

FindDlg  PROCEDURE (STRING ARTF, STRING Text)

RTF        &RTFHandler,AUTO
Props      &RTFProperty,AUTO
Selection  &RTFSelection,AUTO
OwnerW     &WINDOW,AUTO

SText      CSTRING(256),AUTO
Down       BOOLEAN(TRUE)
WholeWord  BOOLEAN(FALSE)
MatchCase  BOOLEAN(FALSE)
Found      BOOLEAN(FALSE)
Flags      DWORD,AUTO

W WINDOW('Find'),AT(,,236,62),FONT('Tahoma',8),GRAY,DOUBLE,IMM
       PROMPT('Fi&nd what:'),AT(5,7),RIGHT
       ENTRY(@s255),AT(41,7,137,10),USE(SText),LEFT(2)
       CHECK(' &Whole words only'),AT(3,35),USE(WholeWord)
       OPTION('Direction'),AT(107,35,71,23),USE(Down),BOXED
         RADIO('&Up'),AT(111,45),USE(?ToTop),VALUE('0')
         RADIO('&Down'),AT(138,45),USE(?ToEnd),VALUE('1')
       END
       CHECK(' &Case sensitive search'),AT(3,48),USE(MatchCase)
       BUTTON('&Find Next'),AT(184,5,48,14),USE(?Find),DEFAULT
       BUTTON('Cancel'),AT(184,24,48,14),USE(?Cancel)
     END

  CODE
  RTF &= ARTF + 0

  IF RTF &= NULL
    Props     &= NULL
    Selection &= NULL
    OwnerW    &= NULL
  ELSE
    Props     &= RTF.Properties()
    Selection &= Props.Selection()
    OwnerW    &= RTF.OwnerWindow()
  END

  IF  LEN (CLIP (Text)) <> 0
    SText = Text
  ELSIF NOT Selection &= NULL
    Selection.SelectedText (SText)
    
    IF SText[1] ='<0>'
      RTF.FindHistory (SText)
    END
  END

  OPEN (W, OwnerW)

  ACCEPT
    IF EVENT() = EVENT:ACCEPTED
      CASE ACCEPTED()
      OF ?Cancel
        POST (CHOOSE (NOT Found, EVENT:FindCancel, EVENT:FindOK),, OwnerW {PROP:Thread})
        POST (EVENT:CloseWindow)
      OF ?Find
        Flags = 0
        IF NOT Down
          Flags += FIND:Back
        END
        IF MatchCase
          Flags += FIND:MatchCase
        END
        IF WholeWord
          Flags += FIND:WholeWord
        END

        IF RTF.Find (SText, Flags) = -1
          BEEP (BEEP:SystemExclamation)
          MESSAGE ('"' & SText & '" not found.', 'Search', ICON:Question, BUTTON:OK)
        ELSE
          Found = TRUE
          DISPLAY
        END
      END
    END
  END
 
  RETURN

! =============================================================================

SetEffects  PROCEDURE (*RTFFont CurFont)

EFBold        DWORD,AUTO
EFItalic      DWORD,AUTO
EFUnderline   DWORD,AUTO
EFStrikeout   DWORD,AUTO
EFProtected   DWORD,AUTO
EFDisabled    DWORD,AUTO
EFRevised     DWORD,AUTO
EFAutoColor   DWORD,AUTO
EFAutoBkColor DWORD,AUTO
Effects       DWORD,AUTO
Cmd           BYTE(255)

EW   WINDOW('Font Effects'),AT(,,219,137),FONT('Tahoma',8),IMM,GRAY,AUTO
       CHECK(' Bold'),AT(15,12),USE(EFBold)
       CHECK(' Italic'),AT(15,26),USE(EFItalic)
       CHECK(' Underline'),AT(15,39),USE(EFUnderline)
       CHECK(' Strikeout'),AT(15,51),USE(EFStrikeout)
       CHECK(' Protected'),AT(15,63),USE(EFProtected)
       CHECK(' Disabled'),AT(15,75),USE(EFDisabled)
       CHECK(' Revised'),AT(15,87),USE(EFRevised)
       CHECK(' Auto Color'),AT(15,99),USE(EFAutoColor)
       CHECK(' Auto Bkgnd Color'),AT(15,112),USE(EFAutoBkColor)
       BUTTON('SET'),AT(123,13,77,14),USE(?SET),SKIP
       BUTTON('CLEAR'),AT(123,31,77,14),USE(?CLEAR),SKIP
       BUTTON('OR'),AT(123,49,77,14),USE(?OR),SKIP
       BUTTON('XOR'),AT(123,68,77,14),USE(?XOR),SKIP
       BUTTON('Close'),AT(123,106,77,14),USE(?Close),STD(STD:Close),SKIP
     END

  CODE
  IF ADDRESS (CurFont) = 0
    RETURN
  END

  Effects = CurFont.FontEffects()

  EFBold        = BAND (Effects, FONTEFFECT:BOLD)
  EFItalic      = BAND (Effects, FONTEFFECT:ITALIC)
  EFUnderline   = BAND (Effects, FONTEFFECT:UNDERLINE)
  EFStrikeout   = BAND (Effects, FONTEFFECT:STRIKEOUT)
  EFProtected   = BAND (Effects, FONTEFFECT:PROTECTED)
  EFDisabled    = BAND (Effects, FONTEFFECT:DISABLED)
  EFRevised     = BAND (Effects, FONTEFFECT:REVISED)
  EFAutoColor   = BAND (Effects, FONTEFFECT:AUTOCOLOR)
  EFAutoBkColor = BAND (Effects, FONTEFFECT:AUTOBKCOLOR)

  OPEN (EW)

  SETPOSITION (0, MOUSEX(), MOUSEY())

  ?EFBold        {PROP:TrueValue} = FONTEFFECT:BOLD
  ?EFItalic      {PROP:TrueValue} = FONTEFFECT:Italic
  ?EFUnderline   {PROP:TrueValue} = FONTEFFECT:Underline
  ?EFStrikeout   {PROP:TrueValue} = FONTEFFECT:Strikeout
  ?EFProtected   {PROP:TrueValue} = FONTEFFECT:Protected
  ?EFDisabled    {PROP:TrueValue} = FONTEFFECT:Disabled
  ?EFRevised     {PROP:TrueValue} = FONTEFFECT:Revised
  ?EFAutoColor   {PROP:TrueValue} = FONTEFFECT:AutoColor
  ?EFAutoBkColor {PROP:TrueValue} = FONTEFFECT:AutoBkColor


  ACCEPT
    IF EVENT() = EVENT:Accepted
      CASE ACCEPTED()
      OF ?SET
        Cmd = FONTEFFECT:SET
      OF ?CLEAR
        Cmd = FONTEFFECT:CLEAR
      OF ?OR
        Cmd = FONTEFFECT:OR
      OF ?XOR
        Cmd = FONTEFFECT:XOR
      END

      IF Cmd <> 255
        Effects = EFBold + |
                  EFItalic + |
                  EFUnderline + |
                  EFStrikeOut + |
                  EFProtected + |
                  EFDisabled + |
                  EFRevised + |
                  EFAutoColor + |
                  EFAutoBkColor
        CurFont.FontEffects (Effects, Cmd)
        Cmd = 255
      END
    END
  END

  CLOSE (EW)
  RETURN

! =============================================================================

T1  PROCEDURE()

RTFCtl         SIGNED,AUTO
Fonts          FontList,AUTO
Scripts        FontScriptList,AUTO
Props          &RTFProperty,AUTO
RTF            &RTFHandler,AUTO
DefaultFont    &RTFFont,AUTO
CurrentFont    &RTFFont,AUTO
Selection      &RTFSelection,AUTO
Scroller       &RTFScrollBar,AUTO

RunTest        BOOLEAN(FALSE)
Alignment      BYTE,AUTO
Bold           BOOLEAN,AUTO
Italic         BOOLEAN,AUTO
Underline      BOOLEAN,AUTO
Bullets        BOOLEAN,AUTO
BulletStyle    BYTE,AUTO

FontName       CSTRING(32),AUTO
FontSize       SIGNED,AUTO
FontScript     BYTE,AUTO
FontColor      LONG,AUTO
FontStyle      LONG,AUTO
FontWeight     LONG,AUTO
FontBkColor    LONG,AUTO

W1      WINDOW,AT(,,340,356),CENTER,GRAY,FONT('Tahoma',8),ALRT(CtrlF)
            GROUP,AT(0,0,,20),FULL,USE(?InfoGroup),BOXED,HIDE,TRN,BEVEL(1,1)
                PANEL,AT(5,3,150,14),USE(?Panel3),BEVEL(-1)
                PANEL,AT(159,3,99,14),USE(?Panel4),BEVEL(-1)
                PANEL,AT(263,3,54,14),USE(?Panel5),BEVEL(-1)
                PANEL,AT(321,3,13,14),USE(?Panel6),BEVEL(-1)
                STRING(''),AT(9,6,141,10),USE(?ShowFileName),FONT('Courier New',9,, |
                    FONT:bold)
                STRING(''),AT(163,6,90,10),USE(?ShowLineNo),FONT('Courier New',9,, |
                    FONT:bold)
                STRING(''),AT(267,6,45,10),USE(?ShowPosInLine),FONT('Courier New',9, |
                    ,FONT:bold)
                STRING(''),AT(324,6,6,10),USE(?ShowDirty),FONT('Times New Roman',16, |
                    COLOR:Red,FONT:bold)
            END
            REGION,AT(10,30,320,236),USE(?RTFPlaceHolder),DISABLE
            GROUP,AT(10,271,320,41),USE(?CtlGroup),BOXED,HIDE,TRN
                PANEL,AT(14,279,2,26),USE(?Panel2)
                BUTTON,AT(20,279,16,14),USE(?ButtonNew),MSG('New'),SKIP,ICON('New.ico'), |
                    TIP('New'),TRN
                BUTTON,AT(36,279,16,14),USE(?ButtonOpen),MSG('Open'),SKIP,ICON('Open.ico'), |
                    TIP('Open'),TRN
                BUTTON,AT(52,279,16,14),USE(?ButtonSave),MSG('Save'),SKIP,ICON('Save.ico'), |
                    TIP('Save'),TRN
                BUTTON,AT(72,279,16,14),USE(?ButtonPrint),MSG('Print'),SKIP, |
                    ICON('Print.ico'),TIP('Print'),TRN
                BUTTON,AT(90,279,16,14),USE(?ButtonFind),MSG('Find'),SKIP,ICON('find.ico'), |
                    TIP('Find'),TRN
                BUTTON,AT(110,279,16,14),USE(?ButtonCut),DISABLE,MSG('Cut'),SKIP, |
                    STD(STD:Cut),ICON('cut.ico'),TIP('Cut'),TRN
                BUTTON,AT(126,279,16,14),USE(?ButtonCopy),DISABLE,MSG('Copy'),SKIP, |
                    STD(STD:Copy),ICON('Copy.ico'),TIP('Copy'),TRN
                BUTTON,AT(142,279,16,14),USE(?ButtonPaste),DISABLE,MSG('Paste'),SKIP, |
                    STD(STD:Paste),ICON('Paste.ico'),TIP('Paste'),TRN
                BUTTON,AT(162,279,16,14),USE(?ButtonUndo),DISABLE,MSG('Undo'),SKIP, |
                    STD(STD:Undo),ICON('undo.ico'),TIP('Undo'),TRN
                BUTTON,AT(178,279,16,14),USE(?ButtonRedo),DISABLE,MSG('Redo'),SKIP, |
                    ICON('redo.ico'),TIP('Redo'),TRN
                BUTTON,AT(198,279,16,14),USE(?ButtonTabs),MSG('Tab stops'),SKIP, |
                    ICON('tabstop.ico'),TIP('Tab stops'),TRN
                BUTTON,AT(216,279,16,14),USE(?ButtonPara),MSG('Paragraph indents'),SKIP, |
                    ICON('para.ico'),TIP('Paragraph indents'),TRN
                OPTION,AT(236,276,68,18),USE(Alignment),SKIP
                    RADIO,AT(238,279,16,14),USE(?AlignmentLeft),SKIP,TRN,MSG('Left A' & |
                        'lignment'),TIP('Left'),ICON('JUSTLFT.ICO'),VALUE('1')
                    RADIO,AT(254,279,16,14),USE(?AlignmentCenter),SKIP,TRN, |
                        MSG('Center Alignment'),TIP('Center'),ICON('JUSTCTR.ICO'), |
                        VALUE('3')
                    RADIO,AT(270,279,16,14),USE(?AlignmentRight),SKIP,TRN, |
                        MSG('Right Alignment'),TIP('Right'),ICON('JUSTRT.ICO'), |
                        VALUE('2')
                    RADIO,AT(286,279,16,14),USE(?AlignmentJust),SKIP,TRN,MSG('Justif' & |
                        'y Alignment'),TIP('Justify'),ICON('JUSTJUST.ICO'),VALUE('4')
                END
                CHECK,AT(306,279,16,14),USE(Bullets),SKIP,TRN,MSG('Bullets and numbering'), |
                    ICON('BULLETS.ICO'),TIP('Bullets and numbering')
                LIST,AT(322,279,4,14),USE(BulletStyle),SKIP,LEFT(2),MSG('Bullets styles'), |
                    TIP('Bullets styles'),DROP(8,90),FROM('Bullets|#1|Arabic num' & |
                    'bers|#2|Lower letters|#3|Upper letters|#4|Lower Roman numbe' & |
                    'rs|#5|Upper Roman numbers|#6'),ALRT(EscKey)
                LIST,AT(20,295,104,12),USE(FontName),SKIP,VSCROLL,LEFT(2),MSG('Font name'), |
                    TIP('Font'),DROP(10),FROM(Fonts),FORMAT('20L(2)I@S32@'), |
                    ALRT(EscKey)
                LIST,AT(128,295,30,12),USE(FontSize),SKIP,VSCROLL,LEFT(2),MSG('Font size'), |
                    TIP('Font size'),DROP(10),FROM('8|9|10|11|12|14|16|18|20|22|' & |
                    '24|26|28|36|48|72'),FORMAT('20R(2)@N2@'),ALRT(EscKey)
                LIST,AT(162,295,87,12),USE(FontScript),SKIP,VSCROLL,LEFT(2), |
                    MSG('Font charset'),TIP('Charset'),DROP(10),FROM(Scripts.Script), |
                    FORMAT('20L(2)@S32@?'),ALRT(EscKey)
                CHECK,AT(254,295,16,14),USE(Bold),SKIP,TRN,MSG('Bold'),ICON('bold.ico'), |
                    TIP('Bold')
                CHECK,AT(270,295,16,14),USE(Italic),SKIP,TRN,MSG('Italic'), |
                    ICON('italic.ico'),TIP('Italic')
                CHECK,AT(286,295,16,14),USE(Underline),SKIP,TRN,MSG('Underline'), |
                    ICON('undrline.ico'),TIP('Underline')
                LIST,AT(306,295,16,14),USE(?FontColor),SKIP,MSG('Font color'), |
                    TIP('Font color'),DROP(17,60),FROM('Black|1|Maroon|2|Green|3' & |
                    '|Olive|4|Navy|5|Purple|6|Teal|7|Gray|8|Silver|9|Red|10|Lime' & |
                    '|11|Yellow|12|Blue|13|Fuchia|14|Aqua|15|White|16|Automatic|0'), |
                    FORMAT('20L(2)J@S10@'),ALRT(EscKey)
                BUTTON,AT(322,295,4,14),USE(?ColorDialog),MSG('Background color'),SKIP, |
                    TIP('Background color'),TRN
            END
            CHECK('RTF Control Test'),AT(0,320,,40),FULL,USE(RunTest),SKIP, |
                FONT('Times New Roman',16,COLOR:Yellow,FONT:bold+FONT:italic), |
                COLOR(COLOR:Navy),ICON(ICON:None),TIP('Click Here to start')
        END

RedoEnabled    BOOLEAN,AUTO
X              SIGNED,AUTO
Y              SIGNED,AUTO
W              SIGNED,AUTO
H              SIGNED,AUTO
Err            LONG,AUTO

NotifyHandler  CLASS,IMPLEMENTS(RTFNotify)
UndoAction       UNDONAMEID,PROTECTED

Construct        PROCEDURE()
               END

  CODE
  RTF   &= NULL
  Props &= NULL

  OPEN (W1)

  ! === ACCEPT loop

  ACCEPT
    IF NOT RTF &= NULL
      DO CheckRedo
    END

    CASE EVENT()
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?RunTest
        IF RunTest
          DO MakeRTFControl
        ELSE
          DO DestroyRTFControl
        END
      OF ?ButtonNew
        RTF.Reset()
        RTF.SetFocus()
      OF ?ButtonOpen
        RTF.Load()
        RTF.SetFocus()
      OF ?ButtonSave
        RTF.Save()
        DO ShowFileName
        RTF.SetFocus()
      OF ?ButtonFind
        Find (RTF)
        RTF.SetFocus()
      OF ?ButtonPrint
        Err = RTF.PrintRTF ('Test')
        IF Err <> 0
          BEEP (BEEP:SystemExclamation)
          MESSAGE ('Printing error ' & Err, 'Error', ICON:Hand)
        END
      OF ?ButtonCut
        Props.Cut()
      OF ?ButtonCopy
        Props.Copy()
      OF ?ButtonPaste
        Props.Paste()
      OF ?ButtonUndo
        Props.Undo()
      OF ?ButtonRedo
        Props.Redo()
      OF ?ButtonTabs
        TabDlg (Props.Tabs(), Props.Unit())
        RTF.SetFocus()
      OF ?ButtonPara
        IndentDlg (Props)
        RTF.SetFocus()
      OF ?Alignment
        Props.Alignment (Alignment)
      OF ?Bullets
        Props.BulletStyle (CHOOSE (NOT Bullets, PARA:Nothing, BulletStyle))
      OF ?FontName
        CurrentFont.SetFont (FontName)
        DO ReloadScripts
      OF ?FontSize
        CurrentFont.FontSize (FontSize)
      OF ?FontScript
        CurrentFont.FontScript (FontScript)
      OF ?Bold
        IF Bold
          CurrentFont.FontWeight (FONT:Bold)
        ELSE
          CurrentFont.FontWeight (FONT:Regular)
        END
      OF ?Italic
        CurrentFont.FontItalic (Italic)
      OF ?Underline
        CurrentFont.FontUnderline (Underline)
      OF ?FontColor
        CurrentFont.FontColor (CHOOSE (CHOICE (?FontColor), COLOR:Black,    |
                                                            COLOR:Maroon,   |
                                                            COLOR:Green,    |
                                                            COLOR:Olive,    |
                                                            COLOR:Navy,     |
                                                            COLOR:Purple,   |
                                                            COLOR:Teal,     |
                                                            COLOR:Gray,     |
                                                            COLOR:Silver,   |
                                                            COLOR:Red,      |
                                                            COLOR:Lime,     |
                                                            COLOR:Yellow,   |
                                                            COLOR:Blue,     |
                                                            COLOR:Fuschia,  |
                                                            COLOR:Aqua,     |
                                                            NotAColor))
        RTF.SetFocus()
      OF ?ColorDialog
        FontBkColor = CurrentFont.FontBackColor()
        IF COLORDIALOG ('Font Color', FontBkColor, 0)
          CurrentFont.FontBackColor (FontBkColor)
        END
        RTF.SetFocus()
      END

    OF EVENT:AlertKey
      IF KEYCODE() = CtrlF
        SetEffects (CurrentFont)
      END
      CASE FIELD()
      OF ?FontName TO ?FontScript
      OROF ?BulletStyle
      OROF ?FontColor
        RTF.SetFocus()
      END
    END

  END

  DO DestroyRTFControl
  CLOSE (W1)
  RETURN

MakeRTFControl ROUTINE

  UNHIDE (?InfoGroup)
  UNHIDE (?CtlGroup)

  RTFCtl = CREATE (0, CREATE:RTF)
  RTF   &= RTFCtl {PROP:Interface} + 0
  Props &= RTF.Properties()

  DefaultFont &= Props.Font (TRUE)
  CurrentFont &= Props.Font (FALSE)

  ! === Setting default values

  Alignment   = 0
  Bold        = FALSE
  Italic      = FALSE
  Underline   = FALSE
  Bullets     = FALSE

  ! === Set RTF control position

  GETPOSITION (?RTFPlaceHolder, X, Y, W, H)
  Props.SetPosition (X, Y, W, H)

  ! === Set initial font information

  DefaultFont.GetFont (FontName)
  FontSize    = DefaultFont.FontSize()
  FontScript  = DefaultFont.FontScript()
  FontColor   = DefaultFont.FontColor()
  FontStyle   = DefaultFont.FontStyle()
  FontWeight  = DefaultFont.FontWeight()
  FontBkColor = DefaultFont.FontBackColor()

  DO LoadFonts

  RTF.LoadScripts (Scripts, FontName)

  IF BAND (FontStyle, FONT:Italic)
    Italic = TRUE
  END

  IF BAND (FontStyle, FONT:Underline)
    Underline = TRUE
  END

  FontWeight = BAND (FontStyle, FONT:Weight)

  IF FontWeight = FONT:Bold
    Bold = TRUE
  END

  ! === Initialize other data

  RTF.Notify (NotifyHandler.RTFNotify)

  IF RTF.Version() < 0300h
    DISABLE (?AlignmentJust)           ! Not supported in RichEdit 2.0
    HIDE (?BulletStyle)                ! Not supported in RichEdit 2.0
  ELSE
    CHANGE (?BulletStyle, PARA:Bullets)
  END

  ?FontColor {PROP:Icon}        = '~color.ico'
  ?FontColor {PROP:Lineheight}  = 10
  ?FontColor {PROP:IconList,  1} = '~BLACK.BMP'
  ?FontColor {PROP:IconList,  2} = '~MAROON.BMP'
  ?FontColor {PROP:IconList,  3} = '~GREEN.BMP'
  ?FontColor {PROP:IconList,  4} = '~OLIVE.BMP'
  ?FontColor {PROP:IconList,  5} = '~NAVY.BMP'
  ?FontColor {PROP:IconList,  6} = '~PURPLE.BMP'
  ?FontColor {PROP:IconList,  7} = '~TEAL.BMP'
  ?FontColor {PROP:IconList,  8} = '~GRAY.BMP'
  ?FontColor {PROP:IconList,  9} = '~SILVER.BMP'
  ?FontColor {PROP:IconList, 10} = '~RED.BMP'
  ?FontColor {PROP:IconList, 11} = '~LIME.BMP'
  ?FontColor {PROP:IconList, 12} = '~YELLOW.BMP'
  ?FontColor {PROP:IconList, 13} = '~BLUE.BMP'
  ?FontColor {PROP:IconList, 14} = '~FUSCHIA.BMP'
  ?FontColor {PROP:IconList, 15} = '~AQUA.BMP'
  ?FontColor {PROP:IconList, 16} = '~WHITE.BMP'

  RedoEnabled = FALSE

  Scroller &= Props.ScrollBar (SCROLLBAR:Vertical)
  Scroller.Unhide()

  Scroller &= Props.ScrollBar (SCROLLBAR:Horizontal)
  Scroller.Unhide()

! Props.WrapMode (WRAP:ToWindow)
  Props.LineWidth (5000, UNIT:Inch1000)
  Props.WrapMode (WRAP:ToWidth)

! Props.Transparent (TRUE)             ! Make control transparent
  Props.Boxed (TRUE)                   ! Draw border around the control
  Props.Flat (TRUE)                    ! Make border not-3D

  DO ShowFileName

  CurrentFont.FontBackColor (COLOR:Yellow)

  Props.Touch (FALSE)

  UNHIDE (RTFCtl)
  SELECT (RTFCtl)

  DISPLAY
  EXIT

DestroyRTFControl  ROUTINE

  DESTROY (RTFCtl)

  FREE (Fonts)
  FREE (Scripts)

  RTF   &= NULL
  Props &= NULL

  HIDE (?CtlGroup)
  HIDE (?InfoGroup)
  EXIT

ShowFileName  ROUTINE
  DATA
FileName  CSTRING(256),AUTO
L         UNSIGNED,AUTO
i         UNSIGNED,AUTO
  CODE
  Props.FileName (FileName)

  IF FileName[1] = '<0>'
    ?ShowFileName {PROP:Text} = '<<<<<< UNKNOWN >>>'
  ELSE
    L = LEN (FileName)
    i = L

    LOOP
      IF FileName[i] = '\' OR FileName[i] = ':'
        i += 1
        BREAK
      END
      i -= 1
    UNTIL i = 0
    ?ShowFileName {PROP:Text} = FileName [i : L]
  END

  DO ShowLinePos
  EXIT

ShowLinePos  ROUTINE
  ?ShowLineNo    {PROP:Text} = 'Line: ' & Props.CaretY() & ' of ' & Props.LineCount()
  ?ShowPosInLine {PROP:Text} = 'Col: ' & Props.CaretX()
  EXIT

LoadFonts ROUTINE
  DATA
i    UNSIGNED,AUTO
  CODE
  RTF.LoadFonts (Fonts)

  LOOP i = 1 TO RECORDS (Fonts)
    GET (Fonts, i)

    IF BAND (Fonts.Technology, FONT:DEVICE)
      Fonts.Icon = 1
    ELSIF BAND (Fonts.Technology, FONT:BITMAP)
      Fonts.Icon = 2
    ELSIF BAND (Fonts.Technology, FONT:TRUETYPE)
      IF BAND (Fonts.Technology, FONT:OPENTRUETYPE)
        Fonts.Icon = 4
      ELSE
        Fonts.Icon = 3
      END
    END

    PUT (Fonts)
  END

  ?FontName {PROP:Lineheight}  = 10
  ?FontName {PROP:IconList, 1} = '~PRNFONT.ICO'
  ?FontName {PROP:IconList, 2} = '~BMPFONT.ICO'
  ?FontName {PROP:IconList, 3} = '~TTFFONT.ICO'
  ?FontName {PROP:IconList, 4} = '~OPENFONT.ICO'

  EXIT

ReloadScripts  ROUTINE
  DATA
N    UNSIGNED,AUTO
  CODE
  FREE (Scripts)
  RTF.LoadScripts (Scripts, FontName)

  Scripts.Charset = FontScript
  N = POSITION (Scripts)

  IF ERRORCODE()
    FontScript = CurrentFont.FontScript()
    Scripts.Charset = FontScript
    N = POSITION (Scripts)
  END

  ?FontScript {PROP:Selected} = N
  EXIT

CheckRedo ROUTINE
  IF Props.CanRedo() <> RedoEnabled
    IF RedoEnabled
      DISABLE (?ButtonRedo)
    ELSE
      ENABLE (?ButtonRedo)
    END
    RedoEnabled = BXOR (RedoEnabled, 1)
  END
  EXIT

! -----------------------------------------------------------------------------

NotifyHandler.Construct  PROCEDURE()
  CODE
  SELF.UndoAction = -1
  RETURN

! -----------------------------------------------------------------------------

NotifyHandler.RTFNotify.ChangeCallback PROCEDURE (LONG bitmap)

FontBitmap     LONG,AUTO
TextColor      LONG,AUTO

  CODE
  DO CheckRedo

  ! === Check made undo

  IF SELF.UndoAction <> -1
    IF SELF.UndoAction = UNDO:Unknown
      CHANGE (?Alignment, Props.Alignment())
      Bullets = Props.BulletStyle()
      IF Bullets = PARA:Nothing
        CHANGE (?Bullets, FALSE)
      ELSE
        CHANGE (?BulletStyle, Bullets)
        CHANGE (?Bullets, TRUE)
      END
    END

    SELF.UndoAction = -1
  END

  ! === Check changes in selection and caret position

  IF BAND (bitmap, CHANGE:Selection)
    Selection &= Props.Selection()
    Selection.Snap()

    DO ShowLinePos
  END

  ! === Check changes in the current font

  IF BAND (bitmap, CHANGE:Font)
    FontBitmap = CurrentFont.Changes()

    IF BAND (FontBitmap, CHANGEFONT:Name)
      CurrentFont.GetFont (FontName)
      DO ReloadScripts
      DISPLAY (?FontName)
    END

    IF BAND (FontBitmap, CHANGEFONT:Size)
      CHANGE (?FontSize, CurrentFont.FontSize())
    END

    IF BAND (FontBitmap, CHANGEFONT:Charset)
      CHANGE (?FontScript, CurrentFont.FontScript())
    END

    IF BAND (FontBitmap, CHANGEFONT:Weight)
      CHANGE (?Bold, CHOOSE (CurrentFont.FontWeight() >= FONT:Bold))
    END

    IF BAND (FontBitmap, CHANGEFONT:Italic)
      CHANGE (?Italic, CurrentFont.FontItalic())
    END

    IF BAND (FontBitmap, CHANGEFONT:Underline)
      CHANGE (?Underline, CurrentFont.FontUnderline())
    END

    IF BAND (FontBitmap, CHANGEFONT:Color)
      CASE CurrentFont.FontColor()
!     OF COLOR:Black
      OF COLOR:Maroon
        TextColor = 2
      OF COLOR:Green
        TextColor = 3
      OF COLOR:Olive
        TextColor = 4
      OF COLOR:Navy
        TextColor = 5
      OF COLOR:Purple
        TextColor = 6
      OF COLOR:Teal
        TextColor = 7
      OF COLOR:Gray
        TextColor = 8
      OF COLOR:Silver
        TextColor = 9
      OF COLOR:Red
        TextColor = 10
      OF COLOR:Lime
        TextColor = 11
      OF COLOR:Yellow
        TextColor = 12
      OF COLOR:Blue
        TextColor = 13
      OF COLOR:Fuschia
        TextColor = 14
      OF COLOR:Aqua
        TextColor = 15
      OF NotAColor
        TextColor = 16
      ELSE
        TextColor = 1
      END

      ?FontColor {PROP:Selected} = TextColor
    END

    CurrentFont.Snap()
  END

  ! === Update "modified" flag

  IF Props.Changed()
    ?ShowDirty {PROP:Text} = '*'
  ELSE
    ?ShowDirty {PROP:Text} = ''
  END

! -----------------------------------------------------------------------------

NotifyHandler.RTFNotify.EventCallback PROCEDURE (LONG event)
  CODE
  CASE event
  OF NOTIFY:Dirty
    IF MESSAGE ('Text is changed. Do you want to save it?', 'Text is changed', |
                ICON:Exclamation, BUTTON:Yes + BUTTON:No, BUTTON:Yes) = BUTTON:No
      RETURN 0
    END
  OF NOTIFY:Undo
    SELF.UndoAction = Props.WhatUndo()
  OF NOTIFY:NewContent
    DO ShowFileName
  END

  RETURN 1

! -----------------------------------------------------------------------------

NotifyHandler.RTFNotify.ContextMenuText PROCEDURE()
  CODE
  RETURN ''

! -----------------------------------------------------------------------------

NotifyHandler.RTFNotify.ContextMenuChoice PROCEDURE (LONG c)
  CODE
  RETURN

! -----------------------------------------------------------------------------

NotifyHandler.RTFNotify.ContextMenuXlat PROCEDURE (STRING Txt)
  CODE
  CASE CLIP (Txt)
  OF 'Cut'
    RETURN 'Вырезать'
  OF 'Copy'
    RETURN 'Копировать'
  OF '&Paste'
    RETURN 'Вставить'
  ELSE
    RETURN ''
  END

NotifyHandler.RTFNotify.LinkPressed PROCEDURE (STRING Txt)
  CODE
  MESSAGE (Txt, 'Pressed link')
  RETURN
