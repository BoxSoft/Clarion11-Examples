 PROGRAM
 MAP
 END

 INCLUDE('QuickXMLParser.INC'),ONCE



QXMLType    QUEUE,TYPE
Text            STRING(400)
Level           LONG
            END
QXML   QXMLType

XMLWindow           WINDOW('XML'),AT(,,302,243),FONT('MS Sans Serif', 8),GRAY,IMM,AUTO
            BUTTON('Load XML'), AT(6,5,41), USE(?BUTTONLoad)
            STRING(''), AT(50,7,245), USE(?StringXMLName)
            SHEET, AT(5,22,291,198), USE(?Sheet1)
              TAB('Tree'), USE(?TreeTab)
                LIST, AT(12,40,279,177), USE(?XMLList), FORMAT('400L(2)|MTS(700)@s255@'), VSCROLL, FROM(QXML)
              END
              TAB('Text'), USE(?TextTab)
                TEXT, AT(10,38,281,180), USE(?LOC:xmlStream), HVSCROLL
              END
            END
            BUTTON('Start'), AT(4,224,31,14), USE(?Start)
            BUTTON('&Cancel'), AT(259,222,36,14), USE(?CancelButton), STD(STD:Close), LEFT
            PROGRESS, AT(38,226,211,8), USE(?Progress), RANGE(0,100)
          END


ShowXML CLASS(XMLFileParser)
Q                            &QXMLType,PROTECTED
ToQueue                      PROCEDURE(QXMLType Q,STRING fileName)
!region Methods derived to implement the functionality of this class (Declaration)
XmlNotifyFoundNode           PROCEDURE( STRING name, STRING  attributes ),DERIVED
XmlNotifyCloseNode           PROCEDURE( STRING name),DERIVED
XmlNotifyFoundElement        PROCEDURE( STRING name, STRING  value, STRING  attributes ),DERIVED
XmlNotifyStartElement        PROCEDURE( STRING name, STRING  value, STRING  attributes ),DERIVED
XmlNotifyEndElement          PROCEDURE( STRING name, STRING  value, STRING  attributes ),DERIVED
XmlNotifyFoundComment        PROCEDURE( STRING Comment),DERIVED
XmlNotifyFoundHeader         PROCEDURE( STRING attributes),DERIVED
XmlNotifyFoundAttribute      PROCEDURE( STRING tagname, STRING name, STRING  value ),DERIVED
!endregion 
            END


GLO:XMLFileName         STRING(256)
 CODE
    IF NOT FILEDIALOG('Choose File to Store',GLO:XMLFileName,'XML|*.xml|XSL|*.xsl|ALL|*.*',0010b)
       RETURN
    END
    OPEN(XMLWindow)
    ?StringXMLName{PROP:Text} = GLO:XMLFileName
    ACCEPT
        CASE EVENT()
        OF EVENT:Accepted
            CASE FIELD()
            OF ?BUTTONLoad
                IF FILEDIALOG('Choose File to Store',GLO:XMLFileName,'XML|*.xml|XSL|*.xsl|ALL|*.*',0010b)
                    ?Start{PROP:Hide}=FALSE
                    ?Progress{PROP:Progress}=0
                    ?LOC:xmlStream{PROP:Text}=''
                    ?StringXMLName{PROP:Text} = GLO:XMLFileName
                    DISPLAY(?StringXMLName)
                    CLEAR(QXML)
                END
            OF ?Start
               ?Start{PROP:Hide}=true
               ShowXML.SetProgressControl(?Progress)
               ShowXML.ToQueue(QXML,GLO:XMLFileName)
               ?LOC:xmlStream{PROP:Text}=ShowXML.GetXmlStream()
            END
        END
    END
    CLOSE(XMLWindow)


ShowXML.ToQueue        PROCEDURE(QXMLType Q,STRING fileName)
 CODE
    SELF.Q &= Q
    FREE(SELF.Q)
    SELF.SetAutoClear(false)
    SELF.SetPassParameters(false)
    SELF.Parse(fileName)    
    
!region Methods derived to implement the functionality of this class (Implementation)
ShowXML.XmlNotifyFoundNode           PROCEDURE( STRING name, STRING  attributes )
 CODE
    SELF.Q.Text='<'&name&'   '&attributes&'/>'
    SELF.Q.Level=SELF.Level
    ADD(SELF.Q)

ShowXML.XmlNotifyCloseNode           PROCEDURE( STRING name)
 CODE

ShowXML.XmlNotifyFoundElement        PROCEDURE( STRING name, STRING  value, STRING  attributes )
 CODE
    SELF.Level+=1
    SELF.Q.Text='<'&name&'> VALUE:'&value
    SELF.Q.Level=SELF.Level
    ADD(SELF.Q)
    SELF.Level-=1

ShowXML.XmlNotifyStartElement        PROCEDURE( STRING name, STRING  value, STRING  attributes )
 CODE
    SELF.Level+=1
    SELF.Q.Text='<'&name&'>'
    SELF.Q.Level=SELF.Level
    ADD(SELF.Q)
    SELF.Level+=1

ShowXML.XmlNotifyEndElement          PROCEDURE( STRING name, STRING  value, STRING  attributes )
 CODE
    SELF.Level-=2

ShowXML.XmlNotifyFoundComment        PROCEDURE( STRING Comment)
 CODE
    SELF.Q.Text='<!--'&Comment&'-->'
    SELF.Q.Level=SELF.Level
    ADD(SELF.Q)
ShowXML.XmlNotifyFoundHeader         PROCEDURE( STRING attributes)
 CODE
    SELF.Q.Text='<?xml'&attributes&'?>'
    SELF.Q.Level=SELF.Level
    ADD(SELF.Q)
    
ShowXML.XmlNotifyFoundAttribute      PROCEDURE( STRING tagname, STRING name, STRING  value )
 CODE
    SELF.Level+=1
    SELF.Q.Text=name&' = '&value
    SELF.Q.Level=SELF.Level
    ADD(SELF.Q)
    SELF.Level-=1
!endregion