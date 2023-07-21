                              PROGRAM

                              MAP
AllocateResponseOut             Procedure(Long BufferSize)
                              END

  INCLUDE('Errors.clw'),ONCE 
  INCLUDE('Equates.clw'),ONCE 
  INCLUDE('Keycodes.clw'),ONCE 
  INCLUDE('ClaRunExt.inc'),ONCE

httpWebAddress                CSTRING(4096)   ! <param name="httpWebAddress"> the address to send the webRequest</param>
httpVerbMethod                BYTE            ! <param name="httpVerbMethod"> the verb method used in the webRequest, it can be HttpVerb:GET, POST, PUT, DELETE</param>
postData                      CSTRING(1024)   ! <param name="postData"> data passed to the webRequest when using the POST verb</param>
requestParameters             CSTRING(512)    ! <param name="requestParameters"> parameters passed to the the webRequest appended to the http address after the ?</param>
responseOut                   &CSTRING        ! <param name="responseOut"> the buffer to be filled with the response, the buffer needs to be big enough to contain the response value</param>
filetoStore                   CSTRING(512)    ! <param name="outputFilename"> the name of the file to store the response</param>
storeInFile                   BYTE            ! var used to determine if response should be saved into a file

MyWindow                      WINDOW('WebRequest Demo'),AT(,,431,280),IMM,AUTO,SYSTEM,ICON(ICON:Clarion),FONT('Segoe UI',10,,FONT:regular)
                                PROMPT('End Point:'),AT(6,7),USE(?PROMPTEndPoint)
                                TEXT,AT(59,7,363,12),USE(httpWebAddress),BOXED,SINGLE
                                PROMPT('Verb:'),AT(6,29),USE(?PROMPT3)
                                LIST,AT(59,29,67,12),USE(httpVerbMethod),DROP(4),FROM('GET|#0|POST|#1|PUT|#2|DELETE|#3'),FORMAT('999L(2)')
                                PROMPT('Parameters:'),AT(6,49),USE(?PROMPTParameters)
                                ENTRY(@s255),AT(59,50,363),USE(requestParameters)
                                PROMPT('Post Data:'),AT(6,74),USE(?PROMPTPostData)
                                TEXT,AT(59,75,363,47),USE(postData),BOXED,VSCROLL,TIP('When using POST verb the postData will be send to the server,' & |
                                    ' otherwise use the parameters')
                                CHECK('Store in File'),AT(4,128,54),USE(storeInfile,, ?CHECKStoreInFile),RIGHT
                                ENTRY(@s255),AT(59,128,346),USE(filetoStore,, ?ENTRYfile),HIDE
                                BUTTON('...'),AT(409,128,14,12),USE(?ButtonPickfile),HIDE
                                BUTTON('Request'),AT(371,148,50,14),USE(?BUTTONRequest)
                                PROMPT('Response:'),AT(4,175),USE(?PROMPTResponse)
                                TEXT,AT(59,172,363,84),USE(?TEXTresponseOut),BOXED,VSCROLL,FONT('Consolas')
                                BUTTON('Close'),AT(371,262,50,14),USE(?BUTTONClose)
                              END
ClaTalk                       ClaRunExtClass
retVal                        LONG
  CODE

  httpWebAddress    = 'https://httpbin.org/get'
  requestParameters = 'format=json'
 
  OPEN(MyWindow)
  AllocateResponseOut(64000)
  ACCEPT
    CASE EVENT()
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?CHECKStoreInFile
        IF storeInFile
          UNHIDE(?ENTRYfile)
          UNHIDE(?ButtonPickfile)
        ELSE
          HIDE(?ENTRYfile)
          HIDE(?ButtonPickfile)
        END
      OF ?ButtonPickfile
        IF FILEDIALOG('File to save',filetoStore,,FILE:Save + FILE:NoError)
        END
      OF ?BUTTONRequest
        SETCURSOR(CURSOR:Wait)
        responseOut = ''
        IF storeInFile
          retVal = ClaTalk.HttpWebRequestToFile(httpWebAddress,httpVerbMethod,postData,requestParameters,responseOut,filetoStore)
          SETCURSOR()
          IF retVal = 0
            MESSAGE('Http Response Successful|Check the content of file|File Name:'&filetoStore,'WebRequest')
          ELSIF retVal > 0 
            AllocateResponseOut(retVal)
            POST(EVENT:Accepted, ?BUTTONRequest)
          ELSE
            MESSAGE('Http Response error.|Check the Response for the error text','WebRequest')
          END
        ELSE
          retVal = ClaTalk.HttpWebRequest(httpWebAddress,httpVerbMethod,postData,requestParameters,responseOut)
          SETCURSOR()
          IF retVal = 0
            MESSAGE('Http Response Successful','WebRequest')
          ELSIF retVal > 0 
            AllocateResponseOut(retVal)
            POST(EVENT:Accepted, ?BUTTONRequest)
          ELSE
            MESSAGE('Http Response Exception|Check Response for the exception text.','WebRequest')
          END
        END   
      OF ?BUTTONClose
        POST(EVENT:CloseWindow)
      END
    END
  END
  DISPOSE(responseOut)
  
AllocateResponseOut           Procedure(Long BufferSize)
  CODE
  DISPOSE(responseOut)
  responseOut &= NEW CSTRING(BufferSize)
  ?TEXTresponseOut{PROP:Use} = responseOut
