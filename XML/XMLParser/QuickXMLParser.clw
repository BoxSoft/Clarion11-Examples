    MEMBER()

    !INCLUDE('KEYCODES.CLW')       ! Keycode equates/constants
    INCLUDE('QuickXMLParser.INC'),ONCE
    MAP
    END

    PRAGMA('link(C%V%DOS%X%%L%.LIB)')

TagType:Tag     EQUATE(1)
TagType:Comment EQUATE(2)
TagType:Header  EQUATE(3)

idTagLeft   EQUATE('<')
idTagRight  EQUATE('>')
idTagEnd    EQUATE('</')
idTagNoData EQUATE('/>')

idTagLeftLength   EQUATE(1)
idTagRightLength  EQUATE(1)
idTagEndLength    EQUATE(2)
idTagNoDataLength EQUATE(2)

!Extended tags

idHeaderTagLeft             EQUATE('<?')
idHeaderTagRight            EQUATE('?>')
idCommentTagLeft            EQUATE('<!--')
idCommnetTagRight           EQUATE('-->')
!idDirectiveTagLeft          EQUATE('<%@')
!idDirectiveTagRight         EQUATE('%>')
!idMetaTagLeft               EQUATE('<meta')
!idMetaTagRight              EQUATE('>')

idCommentTagLeftLength      EQUATE(4)
idCommnetTagRightLength     EQUATE(3)
idHeaderTagLeftLength       EQUATE(2)
idHeaderTagRightLength      EQUATE(2)
!idDirectiveTagLeftLength    EQUATE(3)
!idDirectiveTagRightLength   EQUATE(2)
!idMetaTagLeftLength         EQUATE(5)
!idMetaTagRightLength        EQUATE(1)


XMLParser.IXmlNotify.FoundNode           PROCEDURE( STRING name, STRING  attributes )
 CODE
    MESSAGE('name='&name&'|attributes='&attributes,'FoundNode')
XMLParser.IXmlNotify.CloseNode           PROCEDURE( STRING name)
 CODE
    MESSAGE('name='&name,'CloseNode')
XMLParser.IXmlNotify.FoundElement        PROCEDURE( STRING name, STRING  value, STRING  attributes )
 CODE
    MESSAGE('name='&name&'|value='&value&'|attributes='&attributes,'FoundElement')
XMLParser.IXmlNotify.CloseElement        PROCEDURE( STRING name)
 CODE
    MESSAGE('name='&name,'CloseElement')
XMLParser.IXmlNotify.StartElement        PROCEDURE( STRING name, STRING  value, STRING  attributes )
 CODE
    MESSAGE('name='&name&'|value='&value&'|attributes='&attributes,'StartElement')
XMLParser.IXmlNotify.EndElement          PROCEDURE( STRING name, STRING  value, STRING  attributes )
 CODE
    MESSAGE('name='&name&'|value='&value&'|attributes='&attributes,'EndElement')
XMLParser.IXmlNotify.FoundComment        PROCEDURE( STRING Comment)
 CODE
    MESSAGE('Comment='&Comment,'FoundComment')
XMLParser.IXmlNotify.FoundHeader         PROCEDURE( STRING attributes)
 CODE
    MESSAGE('attributes='&attributes,'FoundHeader')
XMLParser.IXmlNotify.CloseHeader         PROCEDURE()
 CODE
    MESSAGE('CloseHeader','CloseHeader')
XMLParser.IXmlNotify.FoundAttribute      PROCEDURE( STRING tagname, STRING name, STRING  value )
 CODE
    MESSAGE('tagname='&tagname&'|name='&name&'|value='&value,'FoundAttribute')

XMLParser.Construct               PROCEDURE()
 CODE
    SELF.ClearPos()

XMLParser.Reset               PROCEDURE()
 CODE
    SELF.ResetTagPositions()

XMLParser.ResetTagPositions   PROCEDURE(LONG Start=-1)
 CODE
    ! set tag positions
    SELF._firstTagStart  = start
    SELF._firstTagEnd    = start

    SELF._lastTagStart   = start
    SELF._lastTagEnd     = start

    SELF._nameStart      = start
    SELF._nameEnd        = start

    SELF._attrStart      = start
    SELF._attrEnd        = start

    SELF._valueStart     = start
    SELF._valueEnd       = start

XMLParser.ClearPos             PROCEDURE()
 CODE
    ! parse buffer and offsets of where we are parsing
    SELF._buffer      &= NULL
    SELF._parseLength = 0

    ! current position in parse buffer
    SELF._current    = 0

    ! reset tag positions
    SELF.Reset()

XMLParser.getLength           PROCEDURE( long startPos,long endPos )
 CODE
    ! if positions invalid show no length
      IF ( startPos < 0 OR endPos < 0 OR endPos < startPos )
         RETURN 0
      END

    ! get length
      RETURN endPos - startPos + 1

XMLParser.find                PROCEDURE( string srchStr, long offset=0, long length = 0 )
pos     LONG,AUTO
 CODE
    ! if no length set to length to
    ! end of parse buffer
    IF ( length = 0 )
        length = SELF._parseLength
    END
    IF offset=0
       offset = SELF._current
!    ELSE
!       IF offset<SELF._current
!          RETURN 0
!       END
    END


    ! search for it
    pos = INSTRING(srchStr,SELF._buffer,1,offset)

    ! if at end did not find it
    IF ( pos > (length+offset-1) OR pos=0)
        RETURN 0
    ELSE
        RETURN pos
    END

XMLParser.getTagLength        PROCEDURE()
 CODE
    RETURN SELF.getLength( SELF._firstTagStart, SELF._firstTagEnd )

XMLParser.getLastTagLength    PROCEDURE()
 CODE
    RETURN SELF.getLength( SELF._lastTagStart, SELF._lastTagEnd )

XMLParser.hasTag              PROCEDURE()
 CODE
    IF ( SELF.getTagLength() > 0 )
       RETURN True
    ELSE
       RETURN False
    END

XMLParser.hasLastTag          PROCEDURE()
 CODE
    IF ( SELF.getLastTagLength() > 0 )
       RETURN True
    ELSE
       RETURN False
    END

XMLParser.hasNullTag          PROCEDURE()
 CODE
    IF (SELF._buffer[(SELF._firstTagEnd)-1:SELF._firstTagEnd]=idTagNoData)
       RETURN True
    ELSE
       RETURN False
    END

XMLParser.getNameLength       PROCEDURE()
 CODE
    RETURN SELF.getLength( SELF._nameStart, SELF._nameEnd )

XMLParser.hasName             PROCEDURE()
 CODE
    IF ( SELF.getNameLength() > 0 )
       RETURN True
    ELSE
       RETURN False
    END

XMLParser.getAttributesLength PROCEDURE()
 CODE
    RETURN SELF.getLength( SELF._attrStart, SELF._attrEnd )

XMLParser.hasAttributes       PROCEDURE()
 CODE
    IF ( SELF.getAttributesLength() > 0 )
       RETURN True
    ELSE
       RETURN False
    END

XMLParser.getValueLength      PROCEDURE()
 CODE
    RETURN SELF.getLength( SELF._valueStart, SELF._valueEnd )

XMLParser.hasValue            PROCEDURE()
 CODE
    IF ( SELF.getValueLength() > 0 )
       RETURN True
    ELSE
       RETURN False
    END
XMLParser.getTag              PROCEDURE()
 CODE
    IF ( SELF.hasName())
       RETURN SELF._buffer[(SELF._firstTagStart) : SELF._firstTagEnd]
    ELSE
       RETURN ''
    END


XMLParser.getName             PROCEDURE()
 CODE
    IF ( SELF.hasName())
       RETURN SELF._buffer[(SELF._nameStart) : SELF._nameEnd]
    ELSE
       RETURN ''
    END

XMLParser.getValue            PROCEDURE()
 CODE
    IF ( SELF.hasValue())
       RETURN SELF._buffer[(SELF._valueStart) : SELF._valueEnd]
    ELSE
       RETURN ''
    END

XMLParser.getAttributes       PROCEDURE()
 CODE
    IF ( SELF.hasAttributes())
       RETURN SELF._buffer[(SELF._attrStart) : SELF._attrEnd]
    ELSE
       RETURN ''
    END

XMLParser.ParseName           PROCEDURE()
last    LONG
 CODE
    ! if first tag search failed show failed
    if ( SELF._firstTagStart < 0 or  SELF._firstTagEnd < 0 or SELF._firstTagEnd <= SELF._firstTagStart )
        SELF._nameStart = -1
        SELF._nameEnd   = -1
        return false
    end

    ! init name start/end position
    SELF._nameStart = SELF._firstTagStart + idTagLeftLength
    SELF._nameEnd   = SELF._firstTagEnd - 1

    ! if null tag then backup before
    ! null tag marker
    if ( SELF.hasNullTag() )
        SELF._nameEnd -= 1
    end
    ! check for separator (i.e. there are attributes)
    last = SELF.find(' ',SELF._nameStart, SELF.getNameLength())
    if ( last > 0 )
        ! there are attributes so backup
        ! before attributes
        SELF._nameEnd = last - 1
    end
    if SELF.getNameLength()>=3
       if SELF._buffer[(SELF._nameStart):(SELF._nameStart+2)]='!--'
          SELF._nameEnd = SELF._nameStart+2
       end
    end

    return true

XMLParser.ParseAttributes     PROCEDURE()
tagLength  LONG
nameLength LONG
diff       LONG
 CODE
    ! init name start/end position
    SELF._attrStart = -1
    SELF._attrEnd   = -1

    ! if tag or name length invalid stop
    tagLength  = SELF.getTagLength()
    nameLength = SELF.getNameLength()
    if ( tagLength <= 0 or nameLength <= 0 )
        return 0
    end
    ! if the difference in the lengths is
    ! less than the length of the left/right marker
    ! then no attributes
    diff = SELF.getTagLength() - SELF.getNameLength()

    CASE ( diff )
    OF   0
    OROF 1
    OROF 2
         return false
    OF 3
       ! no attribute case but has null tag
       return false
    END

    ! init attributes start, move past space after name
    SELF._attrStart = SELF._nameEnd + 2

    ! init attribute end move before right tag marker
    ! if null tag move before null tag marker
    SELF._attrEnd = SELF._firstTagEnd - 1
       CASE SELF.GetTagType()
       OF TagType:Header
          SELF._attrEnd -= 1
       OF TagType:Comment
          SELF._attrStart -= 1
          SELF._attrEnd -= 2
       ELSE
          if ( SELF.hasNullTag() )
              SELF._attrEnd -= 1
          end
       END
    return true

XMLParser.ParseValue          PROCEDURE()
 CODE
    ! if first tag search failed show failed
    if ( SELF._firstTagStart < 1 OR  SELF._lastTagEnd < 1 OR SELF._lastTagEnd <= SELF._firstTagStart )
        SELF._valueStart = -1
        SELF._valueEnd   = -1
        return false
    end

    ! init value start/end positions
    SELF._valueStart = SELF._firstTagEnd + 1
    IF SELF._buffer[(SELF._firstTagEnd + 1)]=CHR(10) OR SELF._buffer[(SELF._firstTagEnd + 1)]=CHR(13)
       SELF._valueStart +=1
    END
    IF SELF._buffer[(SELF._firstTagEnd + 2)]=CHR(10) OR SELF._buffer[(SELF._firstTagEnd + 2)]=CHR(13)
       SELF._valueStart +=1
    END
    SELF._valueEnd   = SELF._lastTagStart - 1
    !Clip Left
    LOOP
       IF SELF._buffer[SELF._valueStart]<>' ' OR SELF._valueEnd = SELF._valueStart
          BREAK
       END
       SELF._valueStart += 1
    END
    !Clip Right
    LOOP
       IF SELF._buffer[SELF._valueEnd]<>' ' OR SELF._valueEnd = SELF._valueStart
          BREAK
       END
       SELF._valueEnd -= 1
    END
    !Remove CR at the end of the value
    IF SELF._buffer[(SELF._valueEnd - 1)]=CHR(13) AND SELF._buffer[(SELF._valueEnd)]=CHR(10)
       SELF._valueEnd -=2
    END
    IF SELF._valueEnd <= SELF._valueStart
       SELF._valueStart = -1
       SELF._valueEnd   = -1
       return false
    END
    return true

XMLParser.valueHasTag         PROCEDURE()
pos     LONG,AUTO
 CODE
    ! if find end tag
    pos = SELF.find( idTagLeft, SELF._valueStart, SELF.getValueLength() )

    ! if found tag
    if ( pos > 0 )
        return true
    else
        return false
    end

XMLParser.SetPassParameters   PROCEDURE(BYTE PassParemeters)
 CODE
    SELF._OverPassParameters = PassParemeters

XMLParser.GetPassParameters   PROCEDURE()
 CODE
    RETURN SELF._OverPassParameters

XMLParser.NotifyProgressControl PROCEDURE()
 CODE
    IF SELF._ProgressControl>0
       SELF._ProgressControl{PROP:Progress}=SELF._current
       DISPLAY(SELF._ProgressControl)
    END

XMLParser.SetProgressControl  PROCEDURE(SIGNED ProgressControl)
 CODE
    SELF._ProgressControl = ProgressControl
    IF SELF._ProgressControl>0
       SELF._ProgressControl{PROP:Progress}=0
    END

XMLParser.GetProgressControl  PROCEDURE()
 CODE
    RETURN SELF._ProgressControl

XMLParser.Parse               PROCEDURE(*STRING xmlStream,IXmlNotify XmlNotify)
 CODE
    IF SELF._ProgressControl>0
       SELF._ProgressControl{PROP:rangehigh}=LEN(xmlStream)
       SELF._ProgressControl{PROP:Progress} = 0
    END
    RETURN SELF.Parse(xmlStream,XmlNotify,1,LEN(xmlStream))

XMLParser.Parse               PROCEDURE(*STRING xmlStream,IXmlNotify XmlNotify,LONG parseStart, LONG parseLength)
 CODE
    SELF.ResetTagPositions()
    SELF._buffer &= xmlStream
    SELF.XmlNotify &= XmlNotify
    ! init tag position
    SELF._current = parseStart

    SELF._parseLength = parseLength
    LOOP
       IF SELF.Parse()=False THEN BREAK.
       CASE SELF.GetTagType()
       OF TagType:Header
          SELF.NotifyFoundHeader()
       OF TagType:Comment
          SELF.NotifyFoundComment()
       ELSE
          IF SELF.hasValue()
             IF SELF.valueHasTag()
                SELF.NotifyStartElement()
                SELF.ParseNodes()
                SELF.NotifyEndElement()
             ELSE
                SELF.NotifyFoundElement()
             END
          ELSE
             SELF.NotifyFoundNode()
          END
       END
    END
    RETURN True

XMLParser.ParseNodes          PROCEDURE()
lRecurXMLParser &XMLParser
 CODE
    lRecurXMLParser &= NEW(XMLParser)
    RETURN lRecurXMLParser.Parse(SELF._buffer,SELF.XmlNotify,SELF._valueStart, SELF.getValueLength())

XMLParser.Parse               PROCEDURE()
first   LONG
last    LONG,AUTO
pos     LONG,AUTO
endTag                              CSTRING(256),AUTO
startTag  CSTRING(256),AUTO
endTagStart LONG,AUTO
 CODE
    SELF.ResetTagPositions()
    SELF._firstTagStart = SELF._current
    SELF._firstTagEnd   = SELF._current

    SELF._lastTagStart  = SELF._current
    SELF._lastTagEnd    = SELF._current

    ! find first tag
    first = SELF.find( idTagLeft, SELF._current )
    if ( first = 0 )
        return false
    end

    ! if find right tag
    last  = SELF.find( idTagRight, first )
    if ( last = 0  )
       return false
    end
        ! set first tag start/end
        SELF._firstTagStart = first
        SELF._firstTagEnd   = last

        ! now parse name
        if ( not SELF.parseName() )
            return false
        end
        SELF.SetTagType()
        ! parse attributes
        SELF.parseAttributes()

        ! if null tag no data or last tag
        if ( SELF.hasNullTag() OR SELF.GetTagType()=TagType:Header OR SELF.GetTagType()=TagType:Comment)
            !SELF.XmlNotify.FoundNode( SELF.getName(), SELF.getAttributes() )
            ! update cur position
            SELF._current  = SELF._firstTagEnd + idTagRightLength!+ 1!idTagNoDataLength

            ! done so show success
            return true
        END

        ! form end tag
        ! check if the tag is a comment,header or just a tag.
        endTag  = SELF.getName()
!        CASE endTag
!        OF '?xml'
!            endTag  = idHeaderTagRight
!        OF '!---'
!            endTag  = idCommnetTagRight
!        ELSE
            endTag  = idTagEnd & SELF.getName() & idTagRight !</AA>
!        END
        endTagStart = last
        ! find last tag
        loop
           !first = SELF.find( idTagEnd & SELF.getName() & idTagRight, endTagStart )
           first = SELF.find( endTag, endTagStart )
           if ( first <= 0 )
               return false
           end
           !Control to see if there is the same tag but as a child
       startTag = idTagLeft & SELF.getName()&' ' !<AA 
           endTagStart=SELF.find(startTag,endTagStart+1)
           IF endTagStart>first OR endTagStart=0
              BREAK
       ELSE
          ! If it come here iss because we have an internal tag with the same name as the tag
        ! that we are trying to look for a closing tag
        !    |endTagStart |first
        ! <AA><AA>       </AA>
        ! <AA><AA xx=""></AA>   
        ! <AA><AA/></AA>
        ! <AA><AA xx=""/></AA>    
        IF SELF.isClosedTag(endTagStart,first)
           BREAK
        END
        endTagStart=first+1
           END
        END
        ! set last tag start/end
        SELF._lastTagStart = first
        SELF._lastTagEnd   = first + LEN(endTag)

        ! parse the value if not a null tag
        if ( not SELF.hasNullTag() )
            SELF.parseValue()
        end
        ! update cur position
        ! we have parsed a tag so look for the start
        ! of a new tag, if found set current position
        ! to it, else set to last tag
        pos = SELF.find( idTagLeft, SELF._lastTagEnd )
        if ( pos >0  )
            SELF._current = pos
        else
            SELF._current = SELF._lastTagEnd
        end
        
        return true

XMLParser.isClosedTag       PROCEDURE(LONG tagStart,LONG endTagStart)
closingTag LONG
closingNoTag LONG
 CODE
  
  ! <AA><AA/></AA>
  ! <AA><AA xx=""/></AA>
  closingTag = SELF.find(idTagRight,tagStart+1)
  closingNoTag = SELF.find(idTagNoData,endTagStart+1)
  IF closingTag-1 = closingNoTag
    RETURN TRUE
  ELSE
    RETURN FALSE
  END
    
XMLParser.GetTagType          PROCEDURE()
 CODE
    RETURN SELF._tagType

XMLParser.SetTagType          PROCEDURE()
 CODE
    CASE SELF.getName()
    OF '?xml'
       SELF._tagType = TagType:Header
    OF '!--'
       SELF._tagType = TagType:Comment
    ELSE
       SELF._tagType = TagType:Tag
    END

XMLParser.NotifyFoundNode           PROCEDURE()
 CODE
    SELF.NotifyProgressControl()
    IF SELF._OverPassParameters
       SELF.XmlNotify.FoundNode( SELF.getName(), SELF.getAttributes() )
    ELSE
       SELF.XmlNotify.FoundNode( SELF.getName(), '' )
    END
    IF SELF.hasAttributes()
       SELF.NotifyFoundAttributes()
    END
    SELF.XmlNotify.CloseNode( SELF.getName())

XMLParser.NotifyFoundElement        PROCEDURE()
 CODE
    SELF.NotifyProgressControl()
    IF SELF._OverPassParameters
       SELF.XmlNotify.FoundElement( SELF.getName(), SELF.getValue(), SELF.getAttributes() )
    ELSE
       SELF.XmlNotify.FoundElement( SELF.getName(), SELF.getValue(), '' )
    END
    IF SELF.hasAttributes()
       SELF.NotifyFoundAttributes()
    END
    SELF.XmlNotify.CloseElement( SELF.getName())

XMLParser.NotifyStartElement        PROCEDURE()
 CODE
    SELF.NotifyProgressControl()
    IF SELF._OverPassParameters
       SELF.XmlNotify.StartElement( SELF.getName(), SELF.getValue(), SELF.getAttributes() )
    ELSE
       SELF.XmlNotify.StartElement( SELF.getName(), '', '')
    END
    IF SELF.hasAttributes()
       SELF.NotifyFoundAttributes()
    END

XMLParser.NotifyEndElement          PROCEDURE()
 CODE
    IF SELF._OverPassParameters
       SELF.XmlNotify.EndElement( SELF.getName(), SELF.getValue(), SELF.getAttributes() )
    ELSE
       SELF.XmlNotify.EndElement( SELF.getName(), '', '')
    END

XMLParser.NotifyFoundComment        PROCEDURE()
 CODE
    SELF.NotifyProgressControl()
    SELF.XmlNotify.FoundComment(SELF.getAttributes())

XMLParser.NotifyFoundHeader         PROCEDURE()
 CODE
    SELF.NotifyProgressControl()
    IF SELF._OverPassParameters
       SELF.XmlNotify.FoundHeader(SELF.getAttributes())
    ELSE
       SELF.XmlNotify.FoundHeader('')
    END
    IF SELF.hasAttributes()
       SELF.NotifyFoundAttributes()
    END
    SELF.XmlNotify.CloseHeader()

XMLParser.NotifyFoundAttributes     PROCEDURE()
lIndex      LONG
lNameStart  LONG
lNameEnd    LONG
lValueStart LONG
lValueEnd   LONG
lQuoted     BYTE
lReadingName BYTE
lReadingValue BYTE
lHasName BYTE
lHasValue BYTE
 CODE
    lReadingName  = False
    lReadingValue = False
    lHasName = False
    lHasValue = False
    LOOP lIndex=SELF._attrStart TO SELF._attrEnd
         CASE SELF._buffer[lIndex]
         OF '"'
            IF lReadingValue
               IF lQuoted
                  lValueEnd   =lIndex
                  SELF.XmlNotify.FoundAttribute(SELF.getName(), SELF._buffer[lNameStart : lNameEnd],SELF._buffer[lValueStart+1 : lValueEnd-1])
                  lNameStart = 0
                  lNameEnd   = 0
                  lValueStart =0
                  lValueEnd   =0
                  lHasValue = False
                  lReadingValue = False
                  lHasName = False
                  lQuoted = False
                  lReadingName = False
               ELSE
                  lQuoted = True
                  lHasValue = true
                  lValueStart =lIndex
                  lValueEnd   =lIndex
               END
            END
         OF '='
            IF lReadingName
               lReadingName = false
               lNameEnd     = lIndex-1
               lReadingValue = True
               lHasName = True
               lHasValue = false
               lQuoted = False
            ELSE
               IF lHasName = True AND lQuoted = False
                  lReadingValue = True
                  lHasValue = False
                  lQuoted = False
               END
            END
         OF ' '
            IF lReadingName
               lReadingName = false
               lNameEnd     = lIndex-1
               lHasName = True
               lHasValue = false
            END
            IF lHasValue AND lQuoted = False
                  lValueEnd   =lIndex
                  SELF.XmlNotify.FoundAttribute(SELF.getName(), SELF._buffer[lNameStart : lNameEnd],SELF._buffer[lValueStart+1 : lValueEnd-1])
                  lNameStart = 0
                  lNameEnd   = 0
                  lValueStart =0
                  lValueEnd   =0
                  lHasValue = False
                  lReadingValue = False
                  lHasName = False
                  lQuoted = False
            END
         ELSE
            IF NOT(lReadingName OR lReadingValue)
               IF lHasName = True
                  SELF.XmlNotify.FoundAttribute( SELF.getName(), SELF._buffer[lNameStart : lNameEnd],'')
               END
               lReadingName = True
               lNameStart = lIndex
               lNameEnd   = lIndex
               lHasName = True
               lHasValue = False
               lValueStart =0
               lValueEnd   =0
               lQuoted = False
               CYCLE
            END
!            IF lReadingValue = True AND lHasValue = false
!               lHasValue = True
!               lValueStart =lIndex
!            END
         END
    END
!----------------------------------------------------------------
!----------------------------------------------------------------
!----------------------------------------------------------------
XMLFileParser.Destruct                     PROCEDURE
 CODE
    SELF.ClearXmlStream()
    
XMLFileParser.GetXmlStream                 PROCEDURE()
 CODE
    IF NOT SELF.xmlStream &= NULL
       RETURN SELF.xmlStream
    END
    RETURN ''

XMLFileParser.SetAutoClear                 PROCEDURE(BYTE autoClear=1)
 CODE
    SELF.autoClear = autoClear
    
XMLFileParser.ClearXmlStream               PROCEDURE()
 CODE
    IF NOT SELF.xmlStream &= NULL
       DISPOSE(SELF.xmlStream)
    END
XMLFileParser.SetPassParameters            PROCEDURE(BYTE PassParemeters)
 CODE
    SELF._PassParemeters = PassParemeters
    
XMLFileParser.GetPassParameters            PROCEDURE()
 CODE
    RETURN SELF._PassParemeters
    
XMLFileParser.GetFileName                  PROCEDURE()
 CODE
    RETURN SELF._FileName

XMLFileParser.SetProgressControl           PROCEDURE(USHORT progressControl)
 CODE
    SELF.ProgressControl = progressControl

XMLFileParser.Parse                        PROCEDURE(STRING fileName)

__XMLFile      FILE,DRIVER('DOS'),PRE(__XMLFile),THREAD
Record        RECORD
Line             STRING(2000)
              END
             END            
LOC:LastRec      LONG
LOC:SavPtr       LONG(1)                    !Start at 1
LOC:FileSize     LONG
lXMLParser       XMLParser
 CODE
    SELF.ClearXmlStream()
    IF SELF.ProgressControl<>0
       SELF.ProgressControl{PROP:Progress}=0
       DISPLAY(SELF.ProgressControl)
    END
    SELF.Level = 0
    SELF._FileName = fileName
    __XMLFile{PROP:Name}=fileName
    OPEN(__XMLFile)
    IF NOT ERRORCODE()
       LOC:FileSize = BYTES(__XMLFile)
       IF SELF.ProgressControl<>0
          SELF.ProgressControl{PROP:rangehigh}=LOC:FileSize
       END
       LOC:LastRec = LOC:FileSize % SIZE(__XMLFile:Record)
       SELF.xmlStream &= NEW STRING(LOC:FileSize)
       LOOP INT(LOC:FileSize/SIZE(__XMLFile:Record)) TIMES
            GET(__XMLFile,LOC:SavPtr)
            ASSERT(NOT ERRORCODE())
            SELF.xmlStream[LOC:SavPtr : LOC:SavPtr + SIZE(__XMLFile:Record) - 1] = __XMLFile:Record
            LOC:SavPtr += SIZE(__XMLFile:Record)            !Compute next record pointer
            IF SELF.ProgressControl<>0
               SELF.ProgressControl{PROP:Progress}=LOC:SavPtr
               DISPLAY(SELF.ProgressControl)
            END
       END
       IF LOC:LastRec                             !If short record at end of file
          GET(__XMLFile,LOC:SavPtr)                   !Get last record
          ASSERT(BYTES(__XMLFile) = LOC:LastRec)      ! size read should match computed size
          SELF.xmlStream[LOC:SavPtr : LOC:SavPtr + LOC:LastRec - 1] = __XMLFile:Record
       END
    END
    CLOSE(__XMLFile)
    IF SELF.ProgressControl<>0
       SELF.ProgressControl{PROP:Progress}=LOC:FileSize
       DISPLAY(SELF.ProgressControl)
    END
    SELF.Level = 0
    lXMLParser.SetPassParameters(SELF._PassParemeters)
    lXMLParser.SetProgressControl(SELF.ProgressControl)
    lXMLParser.Parse(SELF.XMLStream,SELF.IXmlNotify)
    IF SELF.autoClear<>0
       DISPOSE(SELF.XMLStream)
    END
    SELF.Level = 0
    
 
XMLFileParser.IXmlNotify.FoundNode           PROCEDURE(STRING name, STRING  attributes)
 CODE
    SELF.Level+=1
    SELF.XmlNotifyFoundNode(name, attributes)
XMLFileParser.IXmlNotify.CloseNode           PROCEDURE(STRING name)
 CODE
    SELF.XmlNotifyCloseNode(name)
    SELF.Level-=1
XMLFileParser.IXmlNotify.FoundElement        PROCEDURE(STRING name, STRING  value, STRING  attributes)
 CODE
    SELF.XmlNotifyFoundElement(name, value, attributes)
XMLFileParser.IXmlNotify.CloseElement        PROCEDURE(STRING name)
 CODE
    SELF.XmlNotifyCloseElement(name)
XMLFileParser.IXmlNotify.StartElement        PROCEDURE(STRING name, STRING  value, STRING  attributes)
 CODE
    SELF.XmlNotifyStartElement(name, value, attributes)
XMLFileParser.IXmlNotify.EndElement          PROCEDURE(STRING name, STRING  value, STRING  attributes)
 CODE
    SELF.XmlNotifyEndElement(name, value, attributes)
XMLFileParser.IXmlNotify.FoundComment        PROCEDURE(STRING Comment)
 CODE
    SELF.XmlNotifyFoundComment(Comment)
XMLFileParser.IXmlNotify.FoundHeader         PROCEDURE(STRING attributes)
 CODE
    SELF.XmlNotifyFoundHeader(attributes)
XMLFileParser.IXmlNotify.CloseHeader         PROCEDURE()
 CODE
    SELF.XmlNotifyCloseHeader()
XMLFileParser.IXmlNotify.FoundAttribute      PROCEDURE(STRING tagname, STRING name, STRING  value)
 CODE
    SELF.XmlNotifyFoundAttribute(tagname, name, value)

!virtual methods need to be derived
XMLFileParser.XmlNotifyFoundNode           PROCEDURE(STRING name, STRING  attributes)
 CODE
XMLFileParser.XmlNotifyCloseNode           PROCEDURE(STRING name)
 CODE
XMLFileParser.XmlNotifyFoundElement        PROCEDURE(STRING name, STRING  value, STRING  attributes)
 CODE
XMLFileParser.XmlNotifyCloseElement        PROCEDURE(STRING name)
 CODE
XMLFileParser.XmlNotifyStartElement        PROCEDURE(STRING name, STRING  value, STRING  attributes)
 CODE
XMLFileParser.XmlNotifyEndElement          PROCEDURE(STRING name, STRING  value, STRING  attributes)
 CODE
XMLFileParser.XmlNotifyFoundComment        PROCEDURE(STRING Comment)
 CODE
XMLFileParser.XmlNotifyFoundHeader         PROCEDURE(STRING attributes)
 CODE
XMLFileParser.XmlNotifyCloseHeader         PROCEDURE()
 CODE
XMLFileParser.XmlNotifyFoundAttribute      PROCEDURE(STRING tagname, STRING name, STRING  value)
 CODE
