  PROGRAM

  MAP
SelectEmailAddresses  PROCEDURE(EmailAddressList list, STRING whoFor)
EditAddress           PROCEDURE(EmailAddressList list), BOOL
  END

  INCLUDE('equates.clw'),ONCE
  INCLUDE('ClaRunExt.INC'),ONCE
  INCLUDE('ClaMail.INC'),ONCE



GLO:RecipientEmail  CSTRING(250)
GLO:SenderEmail     CSTRING(250)
GLO:SenderEmailServer   CSTRING(250)
GLO:SenderServerPort    LONG(80)
GLO:SenderServerUserName    CSTRING(250)
GLO:SenderServerPassword    CSTRING(250)
GLO:SenderServerSSL LONG(0)

GLO:MessageSubject  CSTRING(250)
GLO:MessageText     CSTRING(64000)
GLO:MessageHtml     CSTRING(64000)

GLO:EmbeddedImageFileNames  CSTRING(64000)
GLO:AttachedFileNames   CSTRING(64000)
GLO:TmpAttachedFileNames    CSTRING(64000)

GLO:messageBodyEncoding CSTRING(50)
GLO:CCList          EmailAddressList
GLO:BCCList         EmailAddressList
GLO:API             LONG
GLO:Error           LONG
GLO:ErrorMessage    STRING(2000)

!region variables needed for ClaRunExt style calls
ClaTalk             ClaRunExtClass
GLO:CC              SystemStringClass
GLO:BCC             SystemStringClass
!endregion
!region varibles for ClaMail Procedure style calls
clientHandle        LONG
!endregion
!region varibles for ClaMail OOP style calls
client              MailClient
!endregion

MyWindow            WINDOW('Email Demo'),AT(,,363,318),GRAY,SYSTEM,FONT('Segoe UI',9,, |
                      FONT:regular)
                      GROUP('Recipient Information'),AT(6,4,349,37),USE(?GROUPrecipient),BOXED
                        PROMPT('Recipient email:'),AT(13,14),USE(?PROMPTRecipientEmail)
                        ENTRY(@s250),AT(14,24,119),USE(GLO:RecipientEmail,, ?ENTRYRecipientEmail)
                        BUTTON('CC Addresses'),AT(157,23),USE(?CCButton)
                        BUTTON('BCC Addresses'),AT(238,23),USE(?BccButton)
                      END
                      GROUP('Sender Information'),AT(6,46,349,69),USE(?GROUPSender),BOXED
                        PROMPT('Sender''s Email Server:'),AT(12,59),USE(?PROMPTEmailServer)
                        ENTRY(@s250),AT(13,71,120),USE(GLO:SenderEmailServer,, ?ENTRYEmailServer)
                        PROMPT('Port:'),AT(139,59,34),USE(?PROMPTServerPort)
                        ENTRY(@s250),AT(139,71,34),USE(GLO:SenderServerPort,, ?ENTRYServerPort)
                        PROMPT('SSL:'),AT(178,58,24),USE(?PROMPTServerSSL)
                        CHECK,AT(180,72,14),USE(GLO:SenderServerSSL,, ?CHECKSenderServerSSL), |
                          VALUE('1','0')
                        PROMPT('Sender''s Email Server User :'),AT(206,60),USE(?PROMPTEmailServerUse)
                        ENTRY(@s250),AT(207,71,120),USE(GLO:SenderServerUserName,, ?ENTRYEmailServerUser)
                        PROMPT('Sender Email Address:'),AT(12,87),USE(?PROMPTEmail)
                        ENTRY(@s250),AT(12,99),USE(GLO:SenderEmail,, ?ENTRYEmail)
                        PROMPT('Sender''s Email Server Password:'),AT(207,87),USE(?PROMPTEmailServerPassword) |

                        ENTRY(@s250),AT(208,99,120),USE(GLO:SenderServerPassword,, |
                          ?ENTRYEmailServerPassword)
                      END
                      PROMPT('Subject:'),AT(13,120),USE(?PROMPTSubject)
                      ENTRY(@s250),AT(42,118,310),USE(GLO:MessageSubject,, ?ENTRYSubject)
                      PROMPT('Message Text:'),AT(12,132),USE(?PROMPTMessage)
                      TEXT,AT(12,144,339,28),USE(GLO:MessageText,, ?TEXTMessage),VSCROLL
                      PROMPT('Message Html:'),AT(12,176),USE(?PROMPTMessageHtml)
                      TEXT,AT(12,188,339,28),USE(GLO:MessageHtml,, ?TEXTMessageHtml),VSCROLL
                      PROMPT('Attached File Names (separated by ; ):'),AT(14,220),USE(?PROMPTAttachedFileNames) |

                      TEXT,AT(14,232,337,27),USE(GLO:AttachedFileNames,, ?TEXTAttachedFileNames),VSCROLL
                      BUTTON('Add File'),AT(144,219,58,12),USE(?SelectAttachements),LEFT
                      OPTION('Send API'),AT(6,262,349,26),USE(GLO:API),BOXED
                        RADIO('ClaRunExt'),AT(82,273),USE(?GLO:API:RADIO1),VALUE('0')
                        RADIO('ClaMail Procedures'),AT(138,273),USE(?GLO:API:RADIO2),VALUE('1')
                        RADIO('ClaMail Classes'),AT(211,273),USE(?GLO:API:RADIO3),VALUE('2')
                      END
                      STRING('Send message using:'),AT(13,273,66),USE(?STRING1)
                      BUTTON('&Send'),AT(131,290,101,16),USE(?SendButton)
                      BUTTON('&Close'),AT(315,290,36,16),USE(?CloseButton)
                    END

  CODE
  GLO:SenderEmailServer     = 'smtp.gmail.com'
  GLO:SenderServerPort      = 587
  GLO:SenderServerSSL       = TRUE
  GLO:SenderServerPassword = ''
  GLO:SenderServerUserName = ''
  GLO:SenderEmail          = ''
  GLO:RecipientEmail       = ''
  GLO:MessageSubject        = 'Clarion Test Message'
  GLO:MessageText           = 'Message sent by ClarionRunExt'
  GLO:AttachedFileNames     = ''
  GLO:messageBodyEncoding   = ''!When empty default is "us-ascii"

  OPEN(MyWindow)
  ACCEPT
    CASE EVENT()
    OF EVENT:OpenWindow
    OF EVENT:Accepted
      CASE FIELD()
      OF ?SelectAttachements
        GLO:TmpAttachedFileNames = ''
        IF FILEDIALOGA('Select attachments',GLO:TmpAttachedFileNames,'*.*', FILE:LongName)
          IF CLIP(GLO:AttachedFileNames)
            GLO:AttachedFileNames = CLIP(GLO:AttachedFileNames)&';'&GLO:TmpAttachedFileNames
          ELSE
            GLO:AttachedFileNames = GLO:TmpAttachedFileNames
          END
          DISPLAY(?TEXTAttachedFileNames)
        END
      OF ?CCButton
        SelectEmailAddresses(GLO:CCList, 'List of CC Addresses')
      OF ?BCCButton
        SelectEmailAddresses(GLO:BCCList, 'List of BCC Addresses')
      OF ?SendButton
        MESSAGE('GLO:SenderEmailServer='&GLO:SenderEmailServer&|
          '|GLO:SenderServerUserName='&GLO:SenderServerUserName& |
          '|GLO:SenderEmailServerPassword='&GLO:SenderServerPassword& |
          '|GLO:SenderServerPort='&GLO:SenderServerPort& |
          '|GLO:SenderServerSSL='&GLO:SenderServerSSL& |
          '|GLO:SenderEmail='&GLO:SenderEmail& |
          '|GLO:RecipientEmail='&GLO:RecipientEmail& |
          '|GLO:MessageSubject='&GLO:MessageSubject& |
          '|GLO:MessageText='&GLO:MessageText& |
          '|GLO:MessageHtml='&GLO:MessageHtml)

        CASE Glo:API
        OF 0
          CreateEmailList(GLO:ccList, GLO:cc)
          CreateEmailList(GLO:bccList, GLO:bcc)
          GLO:Error = ClaTalk.SendMail(GLO:SenderEmailServer, |
            GLO:SenderServerUserName, |
            GLO:SenderServerPassword, |
            GLO:SenderServerPort, |
            GLO:SenderServerSSL, |            
            FALSE, |
            FALSE,|
            GLO:messageBodyEncoding,|
            GLO:SenderEmail, |
            GLO:RecipientEmail, |
            GLO:SenderEmail, |
            GLO:MessageSubject, |
            GLO:MessageHtml, |
            GLO:embeddedImageFileNames, |
            GLO:MessageText, |
            GLO:attachedFileNames, |
            GLO:cc.str(), |
            GLO:bcc.str(), |
            GLO:ErrorMessage)
        OF 1
          clientHandle = MakeMailClient(GLO:SenderEmailServer, GLO:SenderServerUserName, |
            GLO:SenderServerPassword, GLO:SenderEmail, GLO:SenderServerSSL, |
            GLO:SenderServerPort)
          SetErrorReporting(clientHandle, FALSE)
          SetEncoding(clientHandle, GLO:messageBodyEncoding)
          IF GLO:MessageHtml
            GLO:Error = SendHTMLMail(GLO:RecipientEmail, GLO:MessageSubject, |
              GLO:MessageHtml, GLO:EmbeddedImageFileNames, GLO:AttachedFileNames, |
              GLO:ccList, GLO:bccList)
          ELSE
            GLO:Error = SendMail(clientHandle, GLO:RecipientEmail, GLO:MessageSubject, |
              GLO:MessageText, GLO:AttachedFileNames, GLO:ccList, GLO:bccList, GLO:ErrorMessage)
          END
          FreeMailClient(clientHandle)
        OF 2
          client.Init(GLO:SenderEmailServer, GLO:SenderServerUserName, |
            GLO:SenderServerPassword, GLO:SenderEmail, GLO:SenderServerSSL, |
            GLO:SenderServerPort)
          client.SetErrorReporting(FALSE)
          client.SetEncoding(GLO:messageBodyEncoding)
          IF GLO:MessageHtml
            GLO:Error = client.SendHTMLMail(GLO:RecipientEmail, GLO:MessageSubject, |
              GLO:MessageHtml, GLO:EmbeddedImageFileNames, GLO:AttachedFileNames, |
              GLO:ccList, GLO:bccList, GLO:ErrorMessage)
          ELSE
            GLO:Error = client.SendMail(GLO:RecipientEmail, GLO:MessageSubject, |
              GLO:MessageText, GLO:AttachedFileNames, GLO:ccList, GLO:bccList, GLO:ErrorMessage)
          END
        END
        IF GLO:Error
          MESSAGE('Error sending the Message|Error#=' & GLO:Error & '|Error Details=' & GLO:ErrorMessage,'SMS Message')
        ELSE
          MESSAGE('Message was sent successfully!','SMS Message')
        END
      OF ?CloseButton
        POST(EVENT:CloseWindow)
      END
    END
  END

SelectEmailAddresses    PROCEDURE(EmailAddressList list, STRING whoFor)
selected                  LONG
WINDOW                    WINDOW('Caption'),AT(,,260,206),GRAY,SYSTEM,FONT('Segoe UI',9)
                            LIST,AT(15,12,185,185),USE(?AddressList),FROM(LIST),FORMAT('95L(2)|M~Person~C(2)20' & |
                              'L(2)|M~Address~C(2)')
                            BUTTON('&Insert'),AT(210,31,41),USE(?InsertButton)
                            BUTTON('&Change'),AT(210,62,41),USE(?ChangeButton)
                            BUTTON('&Delete'),AT(210,91,41),USE(?DeleteButton)
                            BUTTON('&OK'),AT(210,160,41,14),USE(?OkButton)
                          END
  CODE
  OPEN(Window)
  0{PROP:Text} = whoFor
  ACCEPT
    CASE EVENT()
    OF EVENT:OpenWindow
      DO SetButtonState
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?InsertButton
        CLEAR(list)
        IF EditAddress(list)
          ADD(list)
          ENABLE(?ChangeButton)
          ENABLE(?DeleteButton)
        END
      OF ?ChangeButton
        selected = ?AddressList{PROP:Selected}
        GET(list, selected)
        IF EditAddress(list)
          PUT(list)
        END
      OF ?DeleteButton
        selected = ?AddressList{PROP:Selected}
        GET(list, selected)
        IF MESSAGE('Do you really want to delete this email address?')
          DELETE(list)
          DO SetButtonState
        END
      OF ?OkButton
        POST(EVENT:CloseWindow)
      END
    END
  END

SetButtonState      ROUTINE
  IF RECORDS(list) = 0
    DISABLE(?ChangeButton)
    DISABLE(?DeleteButton)
  END

EditAddress         PROCEDURE(EmailAddressList list)
ret                   BOOL
WINDOW                WINDOW('Edit Email Address'),AT(,,307,74),GRAY,FONT('Microsoft Sans Serif',8)
                        PROMPT('Recipient''s Name:'),AT(2,15),USE(?PROMPT1)
                        PROMPT('Recipient''s Email Address:'),AT(2,32),USE(?PROMPT2)
                        ENTRY(@s80),AT(91,12,203),USE(list.displayName)
                        ENTRY(@S80),AT(91,29,203),USE(list.emailAddress)
                        BUTTON('&OK'),AT(13,49,41,14),USE(?OkButton),DEFAULT
                        BUTTON('&Cancel'),AT(253,46,42,14),USE(?CancelButton)
                      END
  CODE
  OPEN(window)
  ACCEPT
    CASE ACCEPTED()
    OF ?OkButton
      ret = TRUE
      POST(EVENT:CloseWindow)
    OF ?CancelButton
      ret = FALSE
      POST(EVENT:CloseWindow)
    END
  END
  RETURN ret
