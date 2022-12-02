
  PROGRAM

  MAP
  END

 INCLUDE('equates.clw'),ONCE 
 INCLUDE('ClaRunExt.INC'),ONCE




httpWebAddress    CSTRING(512)    ! <param name="httpWebAddress"> the address to send the webRequest</param>
httpVerbMethod    BYTE            ! <param name="httpVerbMethod"> the verb method used in the webRequest, it can be HttpVerb:GET, POST, PUT, DELETE</param>
postData          CSTRING(1024)   ! <param name="postData"> data passed to the webRequest when using the POST verb</param>
requestParameters CSTRING(512)    ! <param name="requestParameters"> parameters passed to the the webRequest appended to the http address after the ?</param>
responseOut       CSTRING(64000)  ! <param name="responseOut"> the buffer to be filled with the response, the buffer needs to be big enough to contain the response value</param>
filetoStore       CSTRING(512)    ! <param name="outputFilename"> the name of the file to store the response</param>
storeInFile       BYTE            ! var used to determine if response should be saved into a file

MyWindow WINDOW('WebRequest Demo'),AT(,,279,278),GRAY,IMM,SYSTEM,FONT('MS Sans S' & |
            'erif',8,,FONT:regular)
        BUTTON('Close'),AT(235,262,36,14),USE(?CloseButton),LEFT
        BUTTON('Request'),AT(46,148,224,20),USE(?BUTTONRequest),TIP('Request')
        ENTRY(@s255),AT(47,7,224),USE(httpWebAddress,, ?ENTRYEndPoint)
        PROMPT('End Point:'),AT(6,8),USE(?PROMPTEndPoint)
        PROMPT('Parameters:'),AT(6,53),USE(?PROMPTParameters)
        ENTRY(@s255),AT(47,50,224),USE(requestParameters,, ?ENTRYParameters)
        PROMPT('Verb:'),AT(6,28),USE(?PROMPT3)
        LIST,AT(47,29,67,13),USE(httpVerbMethod,, ?DROPHttpVerb),IMM,DROP(4), |
                FROM('GET|#0|POST|#1|PUT|#2|DELETE|#3')
        TEXT,AT(47,75,224,47),USE(postData,, ?TEXTPostData),VSCROLL,TIP('When us' & |
                'ing POST verb the postData will be send to the server, otherwis' & |
                'e use the parameters')
        TEXT,AT(47,172,224,84),USE(responseOut,, ?TEXTResponse),VSCROLL
        PROMPT('Post Data:'),AT(6,78),USE(?PROMPTPostData)
        PROMPT('Response:'),AT(4,175),USE(?PROMPTResponse)
        CHECK('Store in File:'),AT(4,130,51),USE(storeInfile,,?CHECKStoreInFile),LEFT
        ENTRY(@s255),AT(58,128,192),USE(filetoStore,,?ENTRYfile),HIDE
        BUTTON('...'),AT(254,128,18,14),USE(?ButtonPickfile),HIDE
    END
ClaTlk ClaRunExtClass
retVal LONG
  CODE

 httpWebAddress = 'https://api.flickr.com/services/feeds/photos_public.gne' 
 requestParameters = 'format=json'
 
 OPEN(MyWindow)
 ACCEPT
    CASE FIELD()
    OF 0
       CASE EVENT()
       OF EVENT:OpenWindow
          HIDE(?TEXTPostData)
       END
    OF ?CHECKStoreInFile
       CASE EVENT()
       OF EVENT:Accepted
          IF storeInFile
             UNHIDE(?ENTRYfile)
             UNHIDE(?ButtonPickfile)
          ELSE
             HIDE(?ENTRYfile)
             HIDE(?ButtonPickfile)
          END
       END
    OF ?ButtonPickfile
       CASE EVENT()
       OF EVENT:Accepted
          IF FILEDIALOG('File to save',filetoStore,,FILE:Save + FILE:NoError)
             DISPLAY(?ENTRYfile)
          END
       END
    OF ?DROPHttpVerb
       CASE EVENT()
       OF EVENT:Accepted
          IF httpVerbMethod = HttpVerb:POST
             UNHIDE(?TEXTPostData)
          ELSE
             HIDE(?TEXTPostData)
          END
          DISPLAY(?TEXTPostData)
       END
    OF ?BUTTONRequest
       CASE EVENT()
       OF EVENT:Accepted
          responseOut = ''
          DISPLAY(?TEXTResponse)
          IF storeInFile
             retVal = ClaTlk.HttpWebRequestToFile(httpWebAddress,httpVerbMethod,postData,requestParameters,responseOut,filetoStore)
             IF retVal = 0
                MESSAGE('Http Response Successful|Check the content of file|File Name:'&filetoStore,'WebRequest')
                DISPLAY(?TEXTResponse)
             ELSE
                MESSAGE('Http Response error.|Check the Response for the error text','WebRequest')
                DISPLAY(?TEXTResponse)
             END
          ELSE
             retVal = ClaTlk.HttpWebRequest(httpWebAddress,httpVerbMethod,postData,requestParameters,responseOut)
             IF retVal = 0
                MESSAGE('Http Response Successful','WebRequest')
                DISPLAY(?TEXTResponse)
             ELSE
                 IF retVal > 0 
                    MESSAGE('Http Response need more buffer size|Current size='&LEN(responseOut)&'|Needed size='&retVal,'WebRequest')
                    DISPLAY(?TEXTResponse)
                 ELSE
                    MESSAGE('Http Response Exception|Check Response for the exception text.','WebRequest')
                    DISPLAY(?TEXTResponse)
                 END
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
 