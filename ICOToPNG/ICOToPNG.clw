!!
!! App to convert Icon files to PNG
!!
!! SoftVelocity (c)
!!
!!
  PROGRAM

 INCLUDE('ClaRunExt.INC')

  MAP
  END

 
ClaRun      ClaRunExtClass 
AllIconFiles QUEUE(File:queue),PRE(FIL)
        END
 
LOC:OneFileName           CSTRING(FILE:MaxFileName) 

LOC:SourceDirectory           CSTRING(FILE:MaxFileName) 
LOC:TargetDirectory           CSTRING(FILE:MaxFileName) 


LOC:Idx     LONG
  CODE
  
  !Change the path to the path you want to convert all the icons to PNG
  LOC:SourceDirectory = ''
  IF NOT FILEDIALOG('Pick a Directory to Process Icons files',LOC:SourceDirectory,, FILE:LongName + FILE:Directory)
     RETURN
  END
  LOC:TargetDirectory = LOC:SourceDirectory
  IF NOT FILEDIALOG('Pick Target Directory for the PNG files',LOC:TargetDirectory,, FILE:LongName + FILE:Directory + FILE:KeepDir)
     RETURN
  END
  SETPATH(LOC:SourceDirectory)
  
  DIRECTORY(AllIconFiles,'.\*.ICO',ff_:NORMAL)  
  IF RECORDS(AllIconFiles) = 0
     MESSAGE('No files with extension .ICO where found in the directory:|'&LONGPATH(),'No work to do!')
     RETURN
  END
  IF MESSAGE('The '&RECORDS(AllIconFiles)&' ICON images in the directory|'&LONGPATH()&'|will be converted to PNG|And saved to:|'&LOC:TargetDirectory,'Continue?',,BUTTON:YES+BUTTON:NO) = BUTTON:YES
     LOOP LOC:Idx = 1 TO RECORDS(AllIconFiles)
        GET(AllIconFiles,LOC:Idx)
        IF NOT ERRORCODE()
           IF claRun.ImageToPNG(CLIP(AllIconFiles.Name),LOC:TargetDirectory&'\'&CLIP(AllIconFiles.Name)&'.PNG')
              MESSAGE('error with file:'&AllIconFiles.Name,'error in conversion')
              BREAK
           END
        END
     END
     MESSAGE('All the  '&RECORDS(AllIconFiles)&' ICON images in the directory|'&LONGPATH()&'|were converted to PNG|And saved to:|'&LOC:TargetDirectory,'Work finished!')
  END
