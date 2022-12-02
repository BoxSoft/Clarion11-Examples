  PROGRAM

  INCLUDE('EQUATES.CLW'),ONCE

  MAP
    CheckError(),LONG
    CreateSMSTables()
    AddCountries()
    AddSMS_Carriers()
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


countries       FILE,DRIVER('TOPSPEED'),NAME('SMSProviders.TPS\!Countries'),PRE(cou),CREATE
ById              KEY(cou:CountryID),PRIMARY,NOCASE,OPT
ByName            KEY(cou:CountryName),NOCASE
record            RECORD
CountryID           STRING(3)
CountryName         STRING(20)
                  END
                END


sms_carrier     FILE,DRIVER('TOPSPEED'),NAME('SMSProviders.TPS\!sms_carrier'),PRE(smsc),CREATE
ByCarrierID       KEY(smsc:CarrierID),DUP,NOCASE
record            RECORD
CarrierID           LONG
SMSAddress          STRING(255)
                  END
                END




 CODE
 CreateSMSTables()

CreateSMSTables PROCEDURE()
  CODE

  CREATE(countries)
  IF CheckError() THEN RETURN END

  CREATE(sms_carrier)
  IF CheckError() THEN RETURN END

  CREATE(carriers)
  IF CheckError() THEN RETURN END

  OPEN(countries)
  IF CheckError() THEN RETURN END
  OPEN(sms_carrier)
  IF CheckError() THEN RETURN END
  OPEN(carriers)
  IF CheckError() THEN RETURN END

  STREAM(countries)
  STREAM(sms_carrier)
  STREAM(carriers)

  AddCountries()
  AddSMS_Carriers()

  FLUSH(countries)
  FLUSH(sms_carrier)
  FLUSH(carriers)
 

  BUILD(countries)
  IF CheckError() THEN RETURN END
  BUILD(sms_carrier)
  IF CheckError() THEN RETURN END
  BUILD(carriers) 
  IF CheckError() THEN RETURN END

  CLOSE(countries)
  CLOSE(sms_carrier)
  CLOSE(carriers)

  MESSAGE('The SMSProviders.TPS file was created!')
  
CheckError        FUNCTION()
  CODE
  IF ERRORCODE()
    IF ERRORCODE() = 90
      MESSAGE('File System Error: (' & FILEERRORCODE() & ') ' & FILEERROR())
      RETURN ERRORCODE()
    END
    MESSAGE('Error: ' & ERROR())
    RETURN ERRORCODE()
  END
  RETURN 0
  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
AddCountries PROCEDURE()
 CODE
 cou:CountryID = 'us'; cou:CountryName = 'United States'; ADD(countries) 
 cou:CountryID = 'ca'; cou:CountryName = 'Canada'; ADD(countries) 
 cou:CountryID = 'ar'; cou:CountryName = 'Argentina'; ADD(countries) 
 cou:CountryID = 'aw'; cou:CountryName = 'Aruba'; ADD(countries) 
 cou:CountryID = 'au'; cou:CountryName = 'Australia'; ADD(countries) 
 cou:CountryID = 'be'; cou:CountryName = 'Belgium'; ADD(countries) 
 cou:CountryID = 'br'; cou:CountryName = 'Brazil'; ADD(countries) 
 cou:CountryID = 'bg'; cou:CountryName = 'Bulgaria'; ADD(countries) 
 cou:CountryID = 'cn'; cou:CountryName = 'China'; ADD(countries) 
 cou:CountryID = 'co'; cou:CountryName = 'Columbia'; ADD(countries) 
 cou:CountryID = 'dm'; cou:CountryName = 'Dominica'; ADD(countries) 
 cou:CountryID = 'eg'; cou:CountryName = 'Egypt'; ADD(countries) 
 cou:CountryID = 'fr'; cou:CountryName = 'France'; ADD(countries) 
 cou:CountryID = 'de'; cou:CountryName = 'Germany'; ADD(countries) 
 cou:CountryID = 'hk'; cou:CountryName = 'Hong Kong'; ADD(countries) 
 cou:CountryID = 'is'; cou:CountryName = 'Iceland'; ADD(countries) 
 cou:CountryID = 'in'; cou:CountryName = 'India'; ADD(countries) 
 cou:CountryID = 'ie'; cou:CountryName = 'Ireland'; ADD(countries) 
 cou:CountryID = 'il'; cou:CountryName = 'Israel'; ADD(countries) 
 cou:CountryID = 'it'; cou:CountryName = 'Italy'; ADD(countries) 
 cou:CountryID = 'jp'; cou:CountryName = 'Japan'; ADD(countries) 
 cou:CountryID = 'mu'; cou:CountryName = 'Mauritius'; ADD(countries) 
 cou:CountryID = 'mx'; cou:CountryName = 'Mexico'; ADD(countries) 
 cou:CountryID = 'np'; cou:CountryName = 'Nepal'; ADD(countries) 
 cou:CountryID = 'nl'; cou:CountryName = 'Netherlands'; ADD(countries) 
 cou:CountryID = 'nz'; cou:CountryName = 'New Zealand'; ADD(countries) 
 cou:CountryID = 'pa'; cou:CountryName = 'Panama'; ADD(countries) 
 cou:CountryID = 'pl'; cou:CountryName = 'Poland'; ADD(countries) 
 cou:CountryID = 'pr'; cou:CountryName = 'Puerto Rico'; ADD(countries) 
 cou:CountryID = 'sg'; cou:CountryName = 'Singapore'; ADD(countries) 
 cou:CountryID = 'za'; cou:CountryName = 'South Africa'; ADD(countries) 
 cou:CountryID = 'kr'; cou:CountryName = 'South Korea'; ADD(countries) 
 cou:CountryID = 'es'; cou:CountryName = 'Spain'; ADD(countries) 
 cou:CountryID = 'lk'; cou:CountryName = 'Sri Lanka'; ADD(countries) 
 cou:CountryID = 'se'; cou:CountryName = 'Sweden'; ADD(countries) 
 cou:CountryID = 'ch'; cou:CountryName = 'Switzerland'; ADD(countries) 
 cou:CountryID = 'ua'; cou:CountryName = 'Ukraine'; ADD(countries) 
 cou:CountryID = 'uk'; cou:CountryName = 'United Kingdom'; ADD(countries) 
 cou:CountryID = 'EU'; cou:CountryName = 'Europe'; ADD(countries) 
 cou:CountryID = 'LAT'; cou:CountryName = 'Latin America'; ADD(countries) 
 cou:CountryID = 'INT'; cou:CountryName = 'International'; ADD(countries)   
 
AddSMS_Carriers PROCEDURE()
LOC:CarrierID LONG(0)
 CODE
 LOC:CarrierID = 0
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'us'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Airfire Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.airfiremobile.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Alltel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@message.alltel.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Alltel (Allied Wireless)'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.alltelwireless.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Alaska Communications'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@msg.acsalaska.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Ameritech'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@paging.acswireless.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'AT&T Wireless'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@txt.att.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'AT&T Mobility (Cingular)'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@txt.att.net'
 ADD(sms_carrier)
 smsc:SMSAddress= '{{number}@cingularme.com'
 ADD(sms_carrier)
 smsc:SMSAddress= '{{number}@mobile.mycingular.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'AT&T Enterprise Paging'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@page.att.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'AT&T Global Smart Messaging Suite'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.smartmessagingsuite.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'BellSouth'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@bellsouth.cl'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Bluegrass Cellular'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.bluecell.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Bluesky Communications'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@psms.bluesky.as'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'BlueSkyFrog'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@blueskyfrog.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Boost Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@myboostmobile.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Cellcom'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@cellcom.quiktxt.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Cellular South'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@csouth1.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Centennial Wireless'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@cwemail.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Chariton Valley Wireless'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.cvalley.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Cincinnati Bell'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@gocbw.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Cingular (Postpaid)'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@cingular.com'
 ADD(sms_carrier)
 smsc:SMSAddress= '{{number}@mobile.mycingular.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Cleartalk Wireless'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.cleartalk.us'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Comcast PCS'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@comcastpcs.textmsg.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Cricket'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.mycricket.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'C Spire Wireless'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@cspire1.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Element Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.elementmobile.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Esendex'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@echoemail.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'General Communications Inc.'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@mobile.gci.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Golden State Cellular'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@gscsms.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Google Voice'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@txt.voice.google.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Helio'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@myhelio.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'i wireless (T-Mobile)'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}.iws@iwspcs.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'i wireless (Sprint PCS)'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@iwirelesshometext.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Kajeet'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@mobile.kajeet.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'LongLines'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@text.longlines.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Metro PCS'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@mymetropcs.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Nextech'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.nextechwireless.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Nextel (Sprint)'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@messaging.nextel.com'
 ADD(sms_carrier)
 smsc:SMSAddress= '{{number}@page.nextel.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Page Plus Cellular'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@vtext.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Pioneer Cellular'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@zsend.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'PSC Wireless'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.pscel.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Rogers Wireless'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@pcs.rogers.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Qwest'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@qwestmp.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Simple Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@smtext.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'South Central Communications'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@rinasms.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Southern Link'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@page.southernlinc.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Sprint PCS'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@messaging.sprintpcs.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Straight Talk'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@vtext.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Syringa Wireless'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@rinasms.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'T-Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@tmomail.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Teleflip'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@teleflip.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Tracfone'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@mmst5.tracfone.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Telus Mobility'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@msg.telus.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Unicel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@utext.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'US Cellular'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@email.uscc.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'USA Mobility'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@usamobility.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Verizon Wireless'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@vtext.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Viaero'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@viaerosms.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Virgin Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@vmobl.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Voyager Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@text.voyagermobile.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'West Central Wireless'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.wcc.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'XIT Communications'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.xit.net'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'ca'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Aliant'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@chat.wirefree.ca'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Bell Mobility & Solo Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@txt.bell.ca'
 ADD(sms_carrier)
 smsc:SMSAddress= '{{number}@txt.bellmobility.ca'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Fido'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.fido.ca'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Koodo Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@msg.telus.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Lynx Mobility'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.lynxmobility.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Manitoba Telecom/MTS Mobility'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@text.mtsmobility.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'NorthernTel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@txt.northerntelmobility.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'PC Telecom'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@mobiletxt.ca'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Rogers Wireless'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@pcs.rogers.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'SaskTel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.sasktel.com'
 ADD(sms_carrier)
 smsc:SMSAddress= '{{number}@pcs.sasktelmobility.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Telebec'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@txt.telebecmobilite.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Telus Mobility'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@msg.telus.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Virgin Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@vmobile.ca'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Wind Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@txt.windmobile.ca'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'ar'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'CTI Movil (Claro)'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.ctimovil.com.ar'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Movistar'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.movistar.net.ar'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Nextel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= 'TwoWay.{{number}@nextel.net.ar'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Telecom (Personal)'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@alertas.personal.com.ar'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'aw'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Setar Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@mas.aw'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'au'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'T-Mobile (Optus Zoo)'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@optusmobile.com.au'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'UTBox'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.utbox.net'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'be'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Mobistar'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@mobistar.be'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'br'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Claro'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@clarotorpedo.com.br'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vivo'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@torpedoemail.com.br'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'bg'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Globul'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.globul.bg'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Mobiltel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.mtel.net'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'cn'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'China Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@139.com'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'co'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Comcel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@comcel.com.co'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Movistar'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@movistar.com.co'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'dm'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Digicel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@digitextdm.com'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'eg'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Mobinil'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@mobinil.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@vodafone.com.eg'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'fr'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'SFR'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sfr.fr'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Bouygues Telecom'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@mms.bouyguestelecom.fr'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'de'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'E-Plus'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@smsmail.eplus.de'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'O2'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@o2online.de'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@vodafone-sms.de'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'hk'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'CSL'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@mgw.mmsc1.hkcsl.com'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'is'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'OgVodafone'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.is'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Siminn'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@box.is'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'in'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Aircel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@aircel.co.in'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Aircel - Tamil Nadu'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@airsms.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Airtel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@airtelmail.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Airtel - Andhra Pradesh'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@airtelap.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Airtel - Chennai'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@airtelchennai.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Airtel - Karnataka'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@airtelkk.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Airtel - Kerala'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@airtelkerala.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Airtel - Kolkata'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@airtelkol.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Airtel - Tamil Nadu'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@airtelmobile.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Celforce'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@celforce.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Escotel Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@escotelmobile.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Idea Cellular'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@ideacellular.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Loop (BPL Mobile)'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@loopmobile.co.in'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Orange'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@orangemail.co.in'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'ie'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Meteor'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.mymeteor.ie'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'il'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Spikko'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@spikkosms.com'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'it'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.vodafone.it'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'jp'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'AU by KDDI'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@ezweb.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'NTT DoCoMo'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@docomo.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Chuugoku/Western'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@n.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Hokkaido'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@d.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Hokuriku/Central North'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@r.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Kansai/West'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@k.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Kanto'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@k.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Koushin'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@k.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Kyuushu'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@q.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Niigata/North'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@h.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Okinawa'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@q.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Osaka'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@k.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Shikoku'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@s.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Tokyo'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@k.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Touhoku'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@h.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone - Toukai'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@h.vodafone.ne.jp'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Willcom'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@pdx.ne.jp'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'mu'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Emtel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@emtelworld.net'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'mx'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Nextel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@msgnextel.com.mx'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'np'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Ncell'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.ncell.com.np'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'nl'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Orange'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.orange.nl'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'T-Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@gin.nl'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'nz'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Telecom'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@etxt.co.nz'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodafone'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@mtxt.co.nz'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'pa'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Mas Movil'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@cwmovil.com'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'pl'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Orange Polska'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.orange.pl'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Polkomtel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '+{{number}@text.plusgsm.pl'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Plus'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '+{{number}@text.plusgsm.pl'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'pr'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Claro'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@vtexto.com'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'sg'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'M1'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@m1.com.sg'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'za'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'MTN'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.co.za'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodacom'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@voda.co.za'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'kr'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Helio'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@myhelio.com'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'es'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Esendex'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@esendex.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Movistar/Telefonica'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@movistar.net'
 ADD(sms_carrier)
 smsc:SMSAddress= '{{number}@correo.movistar.net'
 ADD(sms_carrier)
 smsc:SMSAddress= '{{number}@movimensaje.com.ar'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Telefonica'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Vodaphone'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@vodafone.es'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'lk'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Mobitel'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.mobitel.lk'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'se'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Tele2'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.tele2.se'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'ch'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Sunrise Communications'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@gsm.sunrise.ch'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'ua'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Beeline'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.beeline.ua'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'uk'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'aql'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@text.aql.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Esendex'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@echoemail.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Hay Systems Ltd (HSL)'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@sms.haysystems.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'O2'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@mmail.co.uk'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Orange'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@orange.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'T-Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@t-mobile.uk.net'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Txtlocal'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@txtlocal.co.uk'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'UniMovil Corporation'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@viawebsms.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'My-Cool-SMS'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@my-cool-sms.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Virgin Mobile'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@vxtras.com'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'EU'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'TellusTalk'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@esms.nu'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'LAT'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Movistar'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@movimensaje.com.ar'
 ADD(sms_carrier)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 car:CountryID = 'INT'
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Globalstar satellite'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@msg.globalstarusa.com'
 ADD(sms_carrier)
 LOC:CarrierID += 1; car:CarrierID = LOC:CarrierID
 car:Name = 'Iridium satellite'; ADD(carriers)
 smsc:CarrierID = car:CarrierID
 smsc:SMSAddress= '{{number}@msg.iridium.com'
 ADD(sms_carrier)
