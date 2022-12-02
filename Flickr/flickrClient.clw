 PROGRAM
 MAP
 END

 INCLUDE('QuickXMLParser.INC'),ONCE
 INCLUDE('ClaRunExt.INC'),ONCE


!region Data declaratio

!All the data related to the flickr information requested to the web server

FlickrFeedInfo GROUP,TYPE
title             CSTRING(250)
feedLink          CSTRING(250)
feedAlternateLink CSTRING(250)
id                CSTRING(250)
icon              CSTRING(250)
subtitle          CSTRING(250)
updated           CSTRING(250)
generator         CSTRING(250)
generator_uri     CSTRING(250)
 END

FlickrFeedEntryAuthor GROUP,TYPE
name             CSTRING(250)
uri              CSTRING(250)
flickr:nsid      CSTRING(250)
flickr:buddyicon CSTRING(1024)
 END
 
FlickrFeedEntry GROUP,TYPE
title             CSTRING(250)
entryLink         CSTRING(250)
id                CSTRING(250)
published         CSTRING(250)
updated           CSTRING(250)
flickr:date_taken CSTRING(250)
dc:date_Taken     CSTRING(250)
content           CSTRING(1024)
contenttype       CSTRING(20)
author            LIKE(FlickrFeedEntryAuthor)
 END

FlickrFeedEntrys QUEUE(FlickrFeedEntry),TYPE
 END
QFlickrFeedEntrys QUEUE
title             CSTRING(250)
link              CSTRING(250)
fileName          CSTRING(256)
 END

FlickrReader CLASS(XMLFileParser)!,IMPLEMENTS(IXmlNotify)
linkrel                      CSTRING(250)
lastlink                     CSTRING(250)

feedInfo                     LIKE(FlickrFeedInfo)
entrys                       &FlickrFeedEntrys
Construct                    PROCEDURE()
Destruct                     PROCEDURE()
XmlNotifyFoundNode           PROCEDURE( STRING name, STRING  attributes ),DERIVED
XmlNotifyCloseNode           PROCEDURE( STRING name),DERIVED
XmlNotifyFoundElement        PROCEDURE( STRING name, STRING  value, STRING  attributes ),DERIVED
XmlNotifyStartElement        PROCEDURE( STRING name, STRING  value, STRING  attributes ),DERIVED
XmlNotifyEndElement          PROCEDURE( STRING name, STRING  value, STRING  attributes ),DERIVED
XmlNotifyFoundAttribute      PROCEDURE( STRING tagname, STRING name, STRING  value ),DERIVED
 END

!endregion 
!this is the web requester
webReq ClaRunExtClass

XMLWindow WINDOW('flickrClient'),AT(,,449,243),GRAY,IMM,AUTO,FONT('MS Sans Serif',8)
        BUTTON('Load XML from Flickr'),AT(6,5,76),USE(?BUTTONLoad)
        SHEET,AT(5,22,291,198),USE(?Sheet1)
        END
        BUTTON('&Close'),AT(259,222,36,14),USE(?CancelButton),STD(STD:Close),LEFT
        PROGRESS,AT(85,8,210,10),USE(?Progress),RANGE(0,100)
        IMAGE,AT(312,70,116,119),USE(?IMAGE1)
        LIST,AT(6,29,289,180),USE(?FlickrList),HVSCROLL,FORMAT('90L(2)|M~title~@' & |
                'S250@250L(2)|M~link~@S250@250L(2)|M~file~@S250@')
    END


GLO:XMLFileName         STRING(256)
GLO:lIndex LONG
requestEndpoint   CSTRING(512)
httpVerbMethod    BYTE
postData          CSTRING(1024)
requestParameters CSTRING(512)
responseOut       CSTRING(64000)
storeInFile       BYTE
filetoStore       CSTRING(512)
tmpImagefile      CSTRING(512)
dotPos            LONG
retVal            LONG
 CODE
    OPEN(XMLWindow)
    ACCEPT
        CASE FIELD()
        OF ?FlickrList       
            CASE EVENT()
            OF EVENT:NewSelection
               GLO:lIndex = ?FlickrList{PROP:Selected}
               IF GLO:lIndex>0
               GET(QFlickrFeedEntrys,GLO:lIndex)
               IF QFlickrFeedEntrys.Filename = ''
                  Do GenerateFileFromLink
               END
               ?IMAGE1{PROP:Text} = QFlickrFeedEntrys.Filename
               END
            END
        OF ?BUTTONLoad
            CASE EVENT()
            OF EVENT:Accepted
               Do DeleteImages
               UNHIDE(?Progress)
               ?Progress{PROP:Progress} = 0
               requestEndpoint = 'https://api.flickr.com/services/feeds/photos_public.gne' 
               httpVerbMethod = HttpVerb:GET
               requestParameters = 'format=xml'
               filetoStore = 'flickrResponse.xml'
               postData = ''
               responseOut = ''
               !----> just one method call to get the information
               retVal = webReq.HttpWebRequestToFile(requestEndpoint,httpVerbMethod,postData,requestParameters,responseOut,filetoStore)
               IF retVal <> 0
                  IF retVal > 0 
                     MESSAGE('Http Response need more buffer size|Current size='&LEN(responseOut)&'|Needed size='&retVal,'WebRequest')
                  ELSE
                     MESSAGE('Http Response Exception|----------------------|'&responseOut,'WebRequest')
                  END
               ELSE                  
                  FlickrReader.SetProgressControl(?Progress)
                  FlickrReader.Parse(filetoStore)
                  FREE(QFlickrFeedEntrys)
                  LOOP I# = 1 to RECORDS(FlickrReader.entrys)
                       GET(FlickrReader.entrys,I#)
                       CLEAR(QFlickrFeedEntrys)
                       QFlickrFeedEntrys.title = FlickrReader.entrys.title                   
                       QFlickrFeedEntrys.link = FlickrReader.entrys.entryLink
                       ADD(QFlickrFeedEntrys)
                  END
                  ?FlickrList{PROP:From} = QFlickrFeedEntrys
                  ?FlickrList{PROP:Selected}=0
                  HIDE(?Progress)
               END              
            END
        END
    END
    CLOSE(XMLWindow)
    Do DeleteImages

DeleteImages ROUTINE
  IF EXISTS(filetoStore)
     REMOVE(filetoStore)
  END
  LOOP I# = 1 to RECORDS(QFlickrFeedEntrys)
       GET(QFlickrFeedEntrys,I#)
       IF QFlickrFeedEntrys.Filename<>''
          IF EXISTS(QFlickrFeedEntrys.Filename)
             REMOVE(QFlickrFeedEntrys.Filename)
          END
       END
  END
  FREE(QFlickrFeedEntrys)
  
GenerateFileFromLink ROUTINE
 dotPos = INSTRING('/',QFlickrFeedEntrys.link,-1,LEN(CLIP(QFlickrFeedEntrys.link)))
 IF dotPos>0   
    tmpImagefile = RIGHT(QFlickrFeedEntrys.link,LEN(QFlickrFeedEntrys.link)-dotPos)
    requestEndpoint = QFlickrFeedEntrys.link
    httpVerbMethod = HttpVerb:GET
    postData = ''
    responseOut = ''
    requestParameters = ''
    retVal = webReq.HttpWebRequestToFile(requestEndpoint,httpVerbMethod,postData,requestParameters,responseOut,tmpImagefile)
    IF retVal <> 0
       IF retVal > 0 
          MESSAGE('Http Response need more buffer size|Current size='&LEN(responseOut)&'|Needed size='&retVal,'WebRequest')
       ELSE
          MESSAGE('Http Response Exception|----------------------|'&responseOut,'WebRequest')
       END
    ELSE
       QFlickrFeedEntrys.Filename = tmpImagefile
       PUT(QFlickrFeedEntrys)
    END 
 END 
!region FlickrReader Methods derived to implement the functionality of this class (Implementation)

!Most of the implementation is just CASE,
!all the heavy lifting on parsing hte XML is done by the class
!the user jsut implement the Interface with the data received as parameters

FlickrReader.Construct       PROCEDURE()
 CODE 
    SELF.SetTrace(true)
    SELF.entrys   &= NEW FlickrFeedEntrys

FlickrReader.Destruct PROCEDURE()
 CODE 
    FREE(SELF.entrys)
    DISPOSE(SELF.entrys)
    
FlickrReader.XmlNotifyFoundNode           PROCEDURE(STRING name, STRING  attributes)
 CODE
!    CASE name
!    OF 'link'
!       SELf.linkrel =''
!       SELf.lastlink =''
!    END
    
FlickrReader.XmlNotifyCloseNode           PROCEDURE(STRING name)
 CODE
    CASE name
    OF 'feed'
    OF 'link'
       SELf.linkrel =''
       SELf.lastlink =''
    END
    
FlickrReader.XmlNotifyFoundElement        PROCEDURE(STRING name, STRING  value, STRING  attributes)
 CODE
    CASE SELF.GetCurrentElementName()
    OF 'feed'
       !Level 2 is the  content
       CASE name
       OF 'title'
          SELF.feedInfo.title = value
       OF 'subtitle'
          SELF.feedInfo.subtitle = value
       OF 'id'
          SELF.feedInfo.id = value
       OF 'icon'
          SELF.feedInfo.icon = value
       OF 'updated'
          SELF.feedInfo.updated = value
       OF 'generator'
          SELF.feedInfo.generator = value
       END
    OF 'entry'
       CASE name
       OF 'title'
          SELF.entrys.title = value
       OF 'id'
          SELF.entrys.id = value
       OF 'published'
          SELF.entrys.published = value
       OF 'updated'
          SELF.entrys.updated = value
       OF 'flickr:date_taken'
          SELF.entrys.flickr:date_taken = value
       OF 'dc:date.Taken'
          SELF.entrys.dc:date_Taken = value
       OF 'content'
          SELF.entrys.content = value
       END
    OF 'author'
       CASE name
       OF 'name'
          SELF.entrys.author.name = value
       OF 'uri'
          SELF.entrys.author.uri = value
       OF 'flickr:nsid'
          SELF.entrys.author.flickr:nsid = value
       OF 'flickr:buddyicon'
          SELF.entrys.author.flickr:buddyicon = value
       END
    END

FlickrReader.XmlNotifyFoundAttribute      PROCEDURE(STRING tagname, STRING name, STRING  value)
 CODE
    CASE SELF.GetCurrentElementName()
    OF 'feed'
        CASE tagname
        OF 'link'
           CASE name
           OF 'rel'
              IF SELF.linkrel<>''
                 IF SELF.linkrel = 'SELF'
                    SELF.feedInfo.feedLink = value
                    SELF.linkrel = ''
                 ELSE
                    IF SELF.linkrel = 'alternate'
                       SELF.feedInfo.feedalternateLink = value
                       SELF.linkrel = ''
                    END
                 END         
              END
              SELF.linkrel = value
           OF 'href'
              IF SELF.linkrel = 'SELF'
                 SELF.feedInfo.feedLink = value
                 SELF.linkrel = ''
              ELSE
                 IF SELF.linkrel = 'alternate'
                    SELF.feedInfo.feedalternateLink = value
                    SELF.linkrel = ''
                 ELSE
                    SELF.lastlink = value
                 END
              END
           END
        OF 'generator'
           CASE name
           OF 'uri'
              SELF.feedInfo.generator_uri = value
           END
        END
    OF 'entry'
        CASE tagname
        OF 'link'
           CASE name
           OF 'rel'
              SELF.linkrel = value
              IF SELF.entrys.entryLink<>''
                 IF SELF.linkrel <> 'enclosure'
                    SELF.entrys.entryLink = ''
                    SELF.linkrel = ''
                 END         
              END
           OF 'href'
              IF SELF.linkrel = 'enclosure' OR SELF.linkrel = ''
                 SELF.entrys.entryLink = value                 
                 SELF.linkrel = ''
              END
           END      
        END
    END
    
FlickrReader.XmlNotifyStartElement        PROCEDURE(STRING name, STRING  value, STRING  attributes)
 CODE
    CASE name
    OF 'feed'
       FREE(SELF.entrys)
       CLEAR(SELF.feedInfo)
    OF 'entry'
       CLEAR(SELF.entrys)
    OF 'author'
       CLEAR(SELF.entrys.author)
    END

FlickrReader.XmlNotifyEndElement          PROCEDURE(STRING name, STRING  value, STRING  attributes)
 CODE
    IF name = 'entry'
       ADD(SELF.entrys)
    END
!FlickrReader.XmlNotifyFoundComment        PROCEDURE(STRING Comment)
! CODE
!FlickrReader.XmlNotifyFoundHeader         PROCEDURE(STRING attributes)
! CODE
!FlickrReader.XmlNotifyCloseHeader         PROCEDURE()
! CODE

!endregion
