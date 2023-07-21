                              PROGRAM

                              MAP
                              END

  INCLUDE('Equates.clw'),ONCE 
  INCLUDE('Errors.clw'),ONCE 
  INCLUDE('Keycodes.clw'),ONCE 
  INCLUDE('ClaRunExt.inc'),ONCE

httpWebAddress                CSTRING(4096)   ! <param name="httpWebAddress"> the address to send the webRequest</param>
responseOut                   &CSTRING        ! <param name="responseOut"> the buffer to be filled with the response, the buffer needs to be big enough to contain the response value</param>

uploadFileName                CSTRING(FILE:MaxFilePath)    ! <param name="uploadFileName"> file name of the file to be uploaded to the Web Address using the POST verb method</param>
uploadFileParamName           CSTRING(FILE:MaxFilePath)  ! <param name="fileNameParameterName"> parameter name of the file in the Form</param>
contentType                   CSTRING(256)               ! <param name="contentType"> the content type of the file to be uploaded using the POST verb</param>
otherParameters               CSTRING(256)               ! <param name="otherParameters"> parameters passed to the the webRequest added to the POST data of the file</param>
ClaTalk                       ClaRunExtClass
retVal                        LONG

MyWindow                      WINDOW('HttpUpload Demo'),AT(,,310,265),IMM,AUTO,SYSTEM,ICON(ICON:Clarion),FONT('Segoe UI',10,,FONT:regular)
                                PROMPT('Web Address:'),AT(6,8),USE(?PROMPTWebAddress)
                                TEXT,AT(6,21,295,12),USE(httpWebAddress),BOXED,SINGLE
                                PROMPT('Extra Parameters:'),AT(6,37),USE(?PROMPTParameters)
                                ENTRY(@s255),AT(6,50,295),USE(otherParameters)
                                PROMPT('Upload File Name: (the type content will be inferred from the file extension)'),AT(6,66),USE(?PROMPTUploadFileName)
                                ENTRY(@s255),AT(6,80,274),USE(uploadFileName)
                                BUTTON('...'),AT(284,79,14,12),USE(?ButtonPickUploadFile)
                                PROMPT('Upload File Parameter Name:'),AT(6,100),USE(?PROMPTUploadFileParamName)
                                ENTRY(@s255),AT(6,113,295),USE(uploadFileParamName)
                                BUTTON('Upload'),AT(251,131,50,14),USE(?BUTTONUpload)
                                PROMPT('Response:'),AT(5,148),USE(?PROMPTResponse)
                                TEXT,AT(6,161,294,84),USE(?TEXTresponseOut),BOXED,VSCROLL,FONT('Consolas')
                                BUTTON('Close'),AT(251,248,50,14),USE(?BUTTONClose)
                              END

  CODE
  httpWebAddress      = 'https://httpbin.org/post' 
  uploadFileParamName = 'submitted' 
  responseOut        &= NEW CSTRING(64000)
  OPEN(MyWindow)
  ACCEPT
    CASE EVENT()
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?ButtonPickUploadFile
        IF FILEDIALOG('File to upload', uploadFileName,, FILE:KeepDir+FILE:LongName)
        END
      OF ?BUTTONUpload
        IF NOT EXISTS(uploadFileName)
          SELECT(?uploadFileName)
          MESSAGE('Please specify a valid file to upload.', 'Attention!', ICON:Asterisk)
          CYCLE
        END
        !The content type is resolved from the file name
        SETCURSOR(CURSOR:Wait)
        ?TEXTresponseOut{PROP:Use} = responseOut
        contentType                = ClaTalk.GetMimeTypeFromFile(uploadFileName)
        retVal                     = ClaTalk.HttpUploadFile(httpWebAddress, uploadFileName, uploadFileParamName, contentType, otherParameters, responseOut)
        SETCURSOR()
        IF retVal = 0
          MESSAGE('Http Response Successful','HttpUpload')
        ELSIF retVal > 0 
          DISPOSE(responseOut)
          responseOut               &= NEW CSTRING(retVal)
          ?TEXTresponseOut{PROP:Use} = responseOut
          POST(EVENT:Accepted, ?BUTTONUpload)
        ELSE
          MESSAGE('Http Response Exception|Check Response for the exception text.','HttpUpload')
        END
      OF ?BUTTONClose
        POST(EVENT:CloseWindow)
      END
    END
  END
  DISPOSE(responseOut)
 