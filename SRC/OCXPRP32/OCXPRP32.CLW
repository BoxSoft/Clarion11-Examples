 PROGRAM
  INCLUDE('keycodes.clw')
  INCLUDE('MENUStyle.INC'),ONCE
 MAP
   INCLUDE('Ocx.CLW')
   SelectOCXServer(OleQ PickQ),STRING
   GetSubName(*STRING),STRING
 END

ResultQ    QUEUE(OleQ)
           END

ocxname    STRING(64)
filename   STRING(244)
savefile   STRING(244)

 COMPILE ('**CW7**',_CWVER_>7000)
MenuStyleMgr MenuStyleManager
!**CW7**

w    WINDOW('Setup 32-bit .OCX Properties'),AT(,,238,172),FONT('MS Sans Serif',8,,FONT:regular),CENTER, |
         ICON('OLE.ICO'),SYSTEM,GRAY,RESIZE
       MENUBAR,USE(?MENUBAR1)
         MENU('&File')
           ITEM('&New'),USE(?new)
           ITEM('Save &As'),USE(?saveas)
           ITEM,SEPARATOR
           ITEM('E&xit'),USE(?Close)
         END
         MENU('&Properties')
           ITEM('&Custom'),USE(?custom),KEY(EnterKey)
         END
       END
       OLE,AT(71,41,97,77),USE(?Ole1),AUTOSIZE
       END
     END

  CODE
  OPEN(w)
  !After open window
  COMPILE ('**CW7**',_CWVER_>7000)
      W{PROP:TabBarVisible}  = False
      MenuStyleMgr.Init(?MENUBAR1)
      MenuStyleMgr.SetFlatMode(True)
      MenuStyleMgr.SetColor(MenuBrushes:ImageBkgnd,16706781,14854529)
      MenuStyleMgr.SetColor(MenuBrushes:SelectedBkgnd,16706781,14854529,False)
      MenuStyleMgr.SetColor(MenuBrushes:SelectedBarBkgnd,16706781,14854529,True)
      MenuStyleMgr.SetColor(MenuBrushes:HotBkgnd,16706781,14854529,True)
      MenuStyleMgr.SetColor(MenuBrushes:FrameBrush,8388608, 8388608,True)
  !**CW7**
  DISPLAY
  POST(EVENT:Accepted, ?New)
  ACCEPT
    CASE ACCEPTED()
    OF ?new
      FREE(ResultQ)
      OLEDIRECTORY(ResultQ,1)             ! Get a list of installed 32bit ocx
      ocxname = SelectOCXServer(ResultQ)  ! Let the user pick one
      ?ole1{PROP:create}=ocxname
      IF ?ole1{PROP:license}<>''          ! The control supports licence
        ?ole1{PROP:create}=CLIP(ocxname)&'\!'&?ole1{PROP:license}
        IF NOT ?ole1{PROP:ole}
           ?ole1{PROP:create}=ocxname
        END
      END
      ?ole1{PROP:grabhandles}=1
    OF ?saveas
      IF FILEDIALOG('Save OCX into file...',filename,'OLR files|*.OLR',0100b)
        savefile = GetSubName(filename)
        IF savefile
          SETCURSOR(CURSOR:WAIT)
          ?ole1{PROP:saveas}=CLIP(filename) & '\!' & savefile
          SETCURSOR()
        END
      END
    OF ?custom
      ?ole1{PROP:doverb}=-7
    OF ?close
      break
    END
  END
  ?ole1{PROP:deactivate}=1


SelectOCXServer    FUNCTION(OleQ PickQ)
window WINDOW('Choose OCX'),AT(,,150,167),FONT('MS Sans Serif',8,,FONT:regular),CENTER,SYSTEM,GRAY
       LIST,AT(11,8,121,120),FONT('MS Sans Serif',8,,FONT:regular),ALRT(MouseLeft2),USE(?List),HVSCROLL, |
           FORMAT('146L|~    Name~@s64@135L|~  CLSID~@s64@20L~  ProgID~@s64@'),FROM(PickQ)
       BUTTON('&Select'),AT(14,135),USE(?Select),DEFAULT
       BUTTON('&Cancel'),AT(71,135),USE(?Cancel)
     END
  CODE
  OPEN(window)
  SELECT(?List,1)
  ACCEPT
    CASE EVENT()
    OF EVENT:AlertKey
      POST(EVENT:Accepted, ?Select)
    END
    CASE FIELD()
    OF ?Select
      IF ACCEPTED()
        GET(PickQ,CHOICE(?List))
        RETURN(PickQ.ProgID)
      END
    OF ?Cancel
      IF ACCEPTED()
        BREAK
      END
    END
  END
  RETURN('')


GetSubName    FUNCTION(fname)
subcomponent  STRING(80)
currentstring STRING(255)
window WINDOW('Pick component name'),AT(,,168,91),FONT('MS Sans Serif',8,,FONT:regular),SYSTEM,GRAY
       STRING(@s255),AT(12,7),USE(currentstring)
       ENTRY(@s80),AT(9,33,150,),USE(subcomponent),IMM
       BUTTON('OK'),AT(29,63,45,14),USE(?OK),DEFAULT
       BUTTON('Cancel'),AT(85,63,45,14),USE(?Cancel)
     END

  CODE
  subcomponent = 'ole1'
  CurrentString = CLIP(fname) & '\!' & subcomponent
  OPEN(window)
  ACCEPT
    CASE FIELD()
    OF ?subcomponent
       IF EVENT()=EVENT:NewSelection
         UPDATE(?subcomponent)
         CurrentString = CLIP(fname) & '\!' & subcomponent
       END
    OF ?ok
       IF ACCEPTED()
         RETURN(subcomponent)
       END
    OF ?Cancel
       IF ACCEPTED()
         BREAK
       END
    END
  END
  RETURN('')

