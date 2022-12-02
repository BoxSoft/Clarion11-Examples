  PROGRAM

  MAP
    MODULE('CreateSMSDataBase.clw')
    CreateSMSTables()  
    END
  END

 INCLUDE('equates.clw'),ONCE 
 INCLUDE('ClaRunExt.INC'),ONCE

countries       FILE,DRIVER('TOPSPEED'),NAME('SMSProviders.TPS\!Countries'),PRE(cou),CREATE
ById              KEY(cou:CountryID),PRIMARY,NOCASE,OPT
ByName            KEY(cou:CountryName),NOCASE
record            RECORD
CountryID           STRING(3)
CountryName         STRING(20)
                  END
                END

carriers        FILE,DRIVER('TOPSPEED'),NAME('SMSProviders.TPS\!Carriers'),PRE(car),CREATE
ByCountryID       KEY(car:CountryID,car:Name),DUP,NOCASE
ById              KEY(car:CarrierID),PRIMARY,NOCASE
ByName            KEY(car:Name),DUP,NOCASE
record            RECORD
CountryID           STRING(3)
CarrierID           LONG
Name                STRING(35)
                  END
                END

sms_carrier     FILE,DRIVER('TOPSPEED'),NAME('SMSProviders.TPS\!sms_carrier'),PRE(smsc),CREATE
ByCarrierID       KEY(smsc:CarrierID),DUP,NOCASE
record            RECORD
CarrierID           LONG
SMSAddress          STRING(255)
                  END
                END

Country:Queue QUEUE
CountryName         STRING(20)
CountryID           STRING(3)
 END

Carrier:Queue QUEUE
CarrierName         STRING(35)
CarrierID           LONG
 END

SMSFormat:Queue QUEUE
SMSAddress          STRING(255)
 END


GLO:SMSAddress          CSTRING(255)

GLO:RecipientPhoneNumber CSTRING(250)
GLO:SenderEmail         CSTRING(250)
GLO:SenderEmailServer   CSTRING(250)
GLO:SenderServerPort    LONG(80)
GLO:SenderServerUserName CSTRING(250)
GLO:SenderServerPassword   CSTRING(250)
GLO:SenderServerSSL LONG(0)

GLO:MessageSubject      CSTRING(250)
GLO:MessageText         CSTRING(255)

GLO:Selected LONG

GLO:Error LONG
 
SMSWindow           WINDOW('SMS Demo'),AT(,,363,266),GRAY,SYSTEM,FONT('Segoe UI',9,,FONT:regular)
                        GROUP('Recipient Information'),AT(6,6,349,79),USE(?GROUPrecipient),BOXED
                            PROMPT('Country:'),AT(14,16,,9),USE(?PROMPTCountry)
                            PROMPT('Recipient Celullar Carrier:'),AT(14,46),USE(?PROMPTCarrier)
                            PROMPT('Recipient Phone Number:'),AT(188,46,,10),USE(?PROMPTNumber)
                            PROMPT('Recipient SMS Carrier Format:'),AT(188,16,,9),USE(?PROMPTSMSFormat)
                            LIST,AT(14,27,164,12),USE(?LISTCountry),VSCROLL,DROP(10), |
                                FROM(Country:Queue),FORMAT('20L(2)|M@S20@')
                            LIST,AT(188,27,159,12),USE(?LISTSMSFormat),VSCROLL,DROP(10), |
                                FROM(SMSFormat:Queue),FORMAT('20L(2)|M@s250@')
                            LIST,AT(14,57,164,12),USE(?LISTCarrier),VSCROLL,DROP(10), |
                                FROM(Carrier:Queue),FORMAT('20L(2)|M@s35@')
                            ENTRY(@s20),AT(186,57,160),USE(GLO:RecipientPhoneNumber,, ?ENTRYNumber)
                        END
                        GROUP('Sender Information'),AT(6,95,349,69),USE(?GROUPSender),BOXED
                            PROMPT('Sender''s SMTP Email Server:'),AT(12,108),USE(?PROMPTEmailServer)
                            PROMPT('Sender''s Email Address:'),AT(12,136,90),USE(?PROMPTEmail)
                            PROMPT('Port:'),AT(138,107,34,10),USE(?PROMPTServerPort)
                            PROMPT('SSL:'),AT(179,107,24),USE(?PROMPTServerSSL)
                            PROMPT('Sender''s Email Server Login name:'),AT(206,108),USE(?PROMPTEmailServerUse) |
                    
                            PROMPT('Sender''s Email Server Password:'),AT(208,136),USE(?PROMPTEmailServerPassword) |
                    
                            ENTRY(@s250),AT(13,120,120),USE(GLO:SenderEmailServer,, ?ENTRYEmailServer)
                            ENTRY(@s250),AT(139,120,34),USE(GLO:SenderServerPort,, ?ENTRYServerPort)
                            CHECK('SSL'),AT(180,122,8,10),USE(GLO:SenderServerSSL,, |
                                ?CHECKSenderServerSSL),LEFT,VALUE('1','0'),TIP('Send SSL?')
                            ENTRY(@s250),AT(207,120,120),USE(GLO:SenderServerUserName,, |
                                ?ENTRYEmailServerUser)
                            ENTRY(@s250),AT(13,148,160),USE(GLO:SenderEmail,, ?ENTRYEmail)
                            ENTRY(@s250),AT(207,148,120),USE(GLO:SenderServerPassword,, |
                                ?ENTRYEmailServerPassword)
                        END
                        PROMPT('Subject:'),AT(6,167,,10),USE(?PROMPTSubject)
                        PROMPT('SMS Message Text (255 characters Max.)'),AT(6,195),USE(?PROMPTMessage)
                        ENTRY(@s255),AT(6,179,339),USE(GLO:MessageSubject,, ?ENTRYSubject)
                        TEXT,AT(6,208,339,28),USE(GLO:MessageText,, ?TEXTMessage)
                        BUTTON('&Send SMS'),AT(126,247,50,16),USE(?SendButton)
                        BUTTON('&Close'),AT(186,247,50,16),USE(?CloseButton)
                    END

ClaTalk ClaRunExtClass
  CODE
 IF NOT EXISTS('SMSProviders.TPS')
    CreateSMSTables()
 END
 GLO:SenderEmailServer     = 'smtp.gmail.com'
 GLO:SenderServerPort      = 587
 GLO:SenderServerSSL       = TRUE
 GLO:MessageSubject        = 'Message from Clarion'
 GLO:MessageText           = 'SMS messaging from Clarion apps is simple to implement'
 OPEN(SMSWindow) 
 ACCEPT
    CASE FIELD()
    OF 0
       CASE EVENT()
       OF EVENT:OpenWindow
          Do LoadCountry:Queue
          DO LoadCarrier:Queue          
          Do LoadSMSFormat:Queue
       END
    OF ?LISTCountry
       CASE EVENT()
       OF EVENT:NewSelection
          DO LoadCarrier:Queue
          Do LoadSMSFormat:Queue
       END
    OF ?LISTCarrier
       CASE EVENT()
       OF EVENT:NewSelection
          Do LoadSMSFormat:Queue
       END
    OF ?LISTSMSFormat
       GLO:Selected = ?LISTSMSFormat{PROP:Selected}
       GET(SMSFormat:Queue, GLO:Selected)
       GLO:SMSAddress = SMSFormat:Queue.SMSAddress
    OF ?SendButton
       CASE EVENT()
       OF EVENT:Accepted
       GLO:Selected = ?LISTSMSFormat{PROP:Selected}
       IF GLO:Selected>0
          GET(SMSFormat:Queue,GLO:Selected)
          GLO:SMSAddress = SMSFormat:Queue.SMSAddress
       END
       
       GLO:Error = ClaTalk.SendSMS(GLO:SenderEmailServer, |
               GLO:SenderServerUserName, | 
               GLO:SenderServerPassword, | 
               GLO:SenderServerPort, | 
               GLO:SenderServerSSL, | 
               TRUE, |
               GLO:SenderEmail, | 
               GLO:RecipientPhoneNumber, |
               GLO:SMSAddress, | 
               GLO:MessageSubject, | 
               GLO:MessageText)
        IF GLO:Error
               MESSAGE('Error on sending the Message|Error#='&GLO:Error,'SMS Message')
        ELSE
               MESSAGE('Message was sent successfully!','SMS Message')
        END
       END
    OF ?CloseButton
       CASE EVENT()
       OF EVENT:Accepted
          POST(EVENT:CloseWindow)
       END
    END
 END
 

LoadCountry:Queue ROUTINE
    FREE(Country:Queue)
    OPEN(countries)
    IF NOT ERRORCODE()
       CLEAR(cou:RECORD)
       SET(countries)
       LOOP 
          NEXT(countries)
          IF ERRORCODE()
             BREAK
          END
          CLEAR(Country:Queue)
          Country:Queue.CountryID = cou:CountryID
          Country:Queue.CountryName = cou:CountryName          
          ADD(Country:Queue)
       END
    END
    CLOSE(countries)
    ?LISTCountry{PROP:Selected} = 1
    GET(Country:Queue, ?LISTCountry{PROP:Selected})

LoadCarrier:Queue ROUTINE
    FREE(Carrier:Queue)
    GLO:Selected = ?LISTCountry{PROP:Selected}
    IF GLO:Selected > 0
        GET(Country:Queue, GLO:Selected)        
        IF Country:Queue.CountryID<>''   
           OPEN(carriers)
           IF NOT ERRORCODE()
              CLEAR(car:RECORD)
              car:CountryID = Country:Queue.CountryID
              car:Name = ''
              SET(car:ByCountryID,car:ByCountryID)
              LOOP 
                 NEXT(carriers)
                 IF ERRORCODE() OR car:CountryID<>Country:Queue.CountryID
                    BREAK
                 END
                 CLEAR(Carrier:Queue)
                 Carrier:Queue.CarrierID   = car:CarrierID
                 Carrier:Queue.CarrierName = car:Name
                 ADD(Carrier:Queue)
              END
           END
           CLOSE(carriers)
           ?LISTCarrier{PROP:Selected} = 1
           GET(Carrier:Queue, 1)
        END
    END

LoadSMSFormat:Queue ROUTINE
    FREE(SMSFormat:Queue)
    GLO:Selected = ?LISTCarrier{PROP:Selected}
    IF GLO:Selected > 0
       GET(Carrier:Queue, GLO:Selected)
       IF Carrier:Queue.CarrierID>0
          OPEN(sms_carrier)
          IF NOT ERRORCODE()
             CLEAR(smsc:RECORD)
             smsc:CarrierID = Carrier:Queue.CarrierID
             smsc:SMSAddress = ''
             SET(smsc:ByCarrierID,smsc:ByCarrierID)
             LOOP 
                NEXT(sms_carrier)
                IF ERRORCODE() OR smsc:CarrierID<>Carrier:Queue.CarrierID
                   BREAK
                END
                CLEAR(SMSFormat:Queue)
                SMSFormat:Queue.SMSAddress = smsc:SMSAddress
                ADD(SMSFormat:Queue)
             END
          END
          CLOSE(sms_carrier)
          ?LISTSMSFormat{PROP:Selected} = 1
          GET(SMSFormat:Queue, 1)
          GLO:SMSAddress = SMSFormat:Queue.SMSAddress
       END
    END
