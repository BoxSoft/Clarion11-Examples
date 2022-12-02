! This DLL demonstrates supplying C%V%PRNT%X% with an external procedure

  PROGRAM

  MAP
    TestProc(STRING,STRING),STRING,NAME('TESTPROC')
  END

Escape SHORT(False)

 code

TestProc PROCEDURE (STRING m, STRING s)

ret  string(255)
window WINDOW('Caption'),AT(,,246,41),GRAY
       ENTRY(@s255),AT(8,6,167,13),USE(ret)
       BUTTON('Ok'),AT(183,6,49,14),USE(?Ok),DEFAULT
       STRING('Press <<Escape> to continue uninterrupted'),AT(9,24),USE(?String1)
     END

  code
    ret = '<<None>'
    if (m = 1) AND NOT Escape  then
      open(window)
      window{PROP:text} = s
      accept
        if accepted()=?ok then
          return ret
        end
      end
      Escape = TRUE
    end
    return ret


