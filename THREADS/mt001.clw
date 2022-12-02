         MEMBER('MT')

! ==============================================================================

ColorTable.Construct  PROCEDURE()

RI     BYTE,AUTO
GI     BYTE,AUTO
BI     BYTE,AUTO
I      UNSIGNED,AUTO

R      LONG,AUTO
G      LONG,AUTO
B      LONG,AUTO

  CODE
  I = 0
  B = 0
  G = 0

  ! RGB (0,0,0) -> RGB (255,0,0)

  LOOP RI = 0 TO 16
    R = RI * 16
    IF R = 256
      R = 255
    END

    I += 1
    SELF.Colors[I] = R + G + B
  END

  ! RGB (255,0,0) -> RGB (255,255,0)

  LOOP GI = 0 TO 16
    G = GI * 16
    IF G = 256
      G = 255
    END

    G *= 100H

    I += 1
    SELF.Colors[I] = R + G + B
  END

  ! RGB (255,255,0) -> RGB (0,255,0)

  LOOP RI = 16 TO 0 BY -1
    R = RI * 16
    IF R = 256
      R = 255
    END

    I += 1
    SELF.Colors[I] = R + G + B
  END

  ! RGB (0,255,0) -> RGB (0,255,255)

  LOOP BI = 0 TO 16
    B = BI * 16
    IF B = 256
      B= 255
    END

    B *= 10000H

    I += 1
    SELF.Colors[I] = R + G + B
  END

  ! RGB (0,255,255) -> RGB (0,0,255)

  LOOP GI = 16 TO 0 BY -1
    G = GI * 16
    IF G = 256
      G = 255
    END

    G *= 100H

    I += 1
    SELF.Colors[I] = R + G + B
  END

  ! RGB (0,0,255) -> RGB (255,0,255)

  LOOP RI = 0 TO 16
    R = RI * 16
    IF R = 256
      R = 255
    END

    I += 1
    SELF.Colors[I] = R + G + B
  END

  ! RGB (255,0,255) -> RGB (255,255,255)

  LOOP GI = 0 TO 16
    G = GI * 16
    IF G = 256
      G = 255
    END

    G *= 100H

    I += 1
    SELF.Colors[I] = R + G + B
  END

  RETURN

! ==============================================================================

ColorTable.GetRGB  PROCEDURE (UNSIGNED ColorIndex)
  CODE
  RETURN SELF.Colors [ColorIndex % 256 + 1]

! ==============================================================================

ColorTable.NextIndex  PROCEDURE (UNSIGNED ColorIndex)
  CODE
  IF ColorIndex = 256
    ColorIndex = 0
  ELSIF ColorIndex = 17 * 7 - 1
    ColorIndex = 256 + 17 * 7 - 1
  END
  IF ColorIndex < 256
    ColorIndex += 1
  ELSE
    ColorIndex -= 1
  END

  RETURN ColorIndex

