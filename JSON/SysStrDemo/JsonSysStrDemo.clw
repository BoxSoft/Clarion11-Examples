
  PROGRAM

 INCLUDE('equates.clw'),ONCE
 INCLUDE('JSON.INC'),ONCE
 INCLUDE('SystemString.inc'),ONCE

  MAP
  END



JSON JSONDataClass
SysStr SystemStringClass
SysStrR &SystemStringClass

S       CSTRING(200000)

GRetValType GROUP,Type
Ok      BYTE
Error   LONG
!MSG STRING(10)
MSG     &SystemStringClass
       END

GRetVal LIKE(GRetValType)
GRetVal2 LIKE(GRetValType)

  CODE
  JSON.ClearObject()
  JSON.AddBool('Ok',true)
  JSON.AddString('ClaREST','ClaREST_ProcessRequest')
  JSON.AddString('requestMethod','AAA')
  JSON.AddString('entryPoint','BBB')
  JSON.AddString('headerData','CCC')
  JSON.AddString('urlQuery','DDD')
  JSON.AddString('postData','EEE')

  SysStrR &= new SystemStringClass
  SysStrR.SetString(Json.ToJSON()) !Store the JSON Object into the SysStr
  JSON.ClearObject() !Will crear the object adn all the formaters

  GRetVal.Msg &= SysStrR !Msg is a reference and should not be used here, only SysStrR

  JSON.AddSysStr('Msg',GRetVal.Msg)
  JSON.SetNumberFormatter('Msg','@STRING')
  JSON.SetNumberFormatter('Ok','@BOOL')

   S = Json.ToJSON(GRetVal)!S will contain the GRetVal GROUP to json, that include the SysStr

   MESSAGE('The Group to JSON|'&S)
   SysStrR.Clean() !Make sure that the string is empty
   MESSAGE('Is Empty?|"'&SysStrR.ToString()&'"')

   !After making sure to clear the group and SysStr get the value back to the GORUP form the S string

   JSON.FromJSON(S,GRetVal)

   !Verify that the SysStr on the gorup was loaded correctly
   MESSAGE(SysStrR.ToString())

   DISPOSE(SysStrR)
  RETURN
