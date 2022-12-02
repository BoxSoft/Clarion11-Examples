
  PROGRAM

  MAP
  END

 INCLUDE('equates.clw'),ONCE 
 INCLUDE('ClaRunExt.INC'),ONCE




httpWebAddress    CSTRING(512)    ! <param name="httpWebAddress"> the address to send the webRequest</param>
responseOut       CSTRING(64000)  ! <param name="responseOut"> the buffer to be filled with the response, the buffer needs to be big enough to contain the response value</param>


uploadFileName    CSTRING(256)    ! <param name="uploadFileName"> file name of the file to be uploaded to the Web Address using the POST verb method</param>
uploadFileParamName CSTRING(256)  ! <param name="fileNameParameterName"> parameter name of the file in the Form</param>
contentType       CSTRING(256)    ! <param name="contentType"> the content type of the file to be uploaded using the POST verb</param>
otherParameters   CSTRING(256)    ! <param name="otherParameters"> parameters passed to the the webRequest added to the POST data of the file</param>


MyWindow WINDOW('HttpUpload Demo'),AT(,,310,278),GRAY,IMM,SYSTEM,FONT('MS Sans S' & |
            'erif',8,,FONT:regular)
        BUTTON('Close'),AT(266,262,36,14),USE(?CloseButton),LEFT
        BUTTON('Upload'),AT(46,142,255,20),USE(?BUTTONUpload),TIP('Upload')
        ENTRY(@s255),AT(6,22,295),USE(httpWebAddress,, ?ENTRYWebAddress)
        PROMPT('Web Address:'),AT(6,8),USE(?PROMPTWebAddress)
        PROMPT('Extra Parameters:'),AT(6,37),USE(?PROMPTParameters)
        ENTRY(@s255),AT(6,50,295),USE(otherParameters,, ?ENTRYParameters)
        TEXT,AT(47,172,254,84),USE(responseOut,, ?TEXTResponse),VSCROLL
        PROMPT('Response:'),AT(4,175),USE(?PROMPTResponse)
        ENTRY(@s255),AT(6,80,274),USE(uploadFileName,, ?ENTRYUploadFileName)
        BUTTON('...'),AT(284,78,18,14),USE(?ButtonPickUploadFile)
        PROMPT('Upload File Name: (the type content will be inferred from the fi' & |
                'le extension)'),AT(6,66),USE(?PROMPTUploadFileName)
        ENTRY(@s255),AT(6,117,295),USE(uploadFileParamName,, ?ENTRYuploadFileParamName)
        PROMPT('Upload File Parameter Name:'),AT(6,100),USE(?PROMPTUploadFileParamName)
    END
ClaTlk ClaRunExtClass
retVal LONG
  CODE

 httpWebAddress = 'http://posttestserver.com/post.php' 
 uploadFileParamName = 'submitted' 
 uploadFileName = ''
 OPEN(MyWindow)
 ACCEPT
    CASE FIELD()
    OF 0
       CASE EVENT()
       OF EVENT:OpenWindow
       END
    OF ?ButtonPickUploadFile
       CASE EVENT()
       OF EVENT:Accepted
          IF FILEDIALOG('File to upload',uploadFileName)
             DISPLAY(?ENTRYUploadFileName)
          END
       END
    OF ?BUTTONUpload
       CASE EVENT()
       OF EVENT:Accepted
          responseOut = ''
          DISPLAY(?TEXTResponse)
          !The content type is resolved from the file name
          contentType = ClaTlk.GetMimeTypeFromFile(uploadFileName)
          retVal = ClaTlk.HttpUploadFile(httpWebAddress,uploadFileName,uploadFileParamName,contentType,otherParameters,responseOut)
          IF retVal = 0
             MESSAGE('Http Response Successful','HttpUpload')
             DISPLAY(?TEXTResponse)
          ELSE
              IF retVal > 0 
                 MESSAGE('Http Response need more buffer size|Current size='&LEN(responseOut)&'|Needed size='&retVal,'HttpUpload')
                 DISPLAY(?TEXTResponse)
              ELSE
                 MESSAGE('Http Response Exception|Check Response for the exception text.','HttpUpload')
                 DISPLAY(?TEXTResponse)
              END
          END
       END
    OF ?CloseButton
       CASE EVENT()
       OF EVENT:Accepted
          POST(EVENT:CloseWindow)
       END
    END
 END
 