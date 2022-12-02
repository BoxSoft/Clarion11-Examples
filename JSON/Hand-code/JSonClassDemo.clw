  PROGRAM


  MAP
  END

 INCLUDE('equates.clw'),ONCE 
 INCLUDE ('JSON.INC'),ONCE

mygroup    GROUP
Name        STRING(20)
Value       STRING(20)
           END

myQueue   QUEUE(mygroup)
           END

JSON JSONDataClass
GJSONString     STRING(512)
  CODE
  JSON.SetSupportNullString(true)
  JSON.SetNumberFormatter('VALUE','@NULL')
  ! add some records to a Queue
  myQueue.NAME  = 'Aaa'
  myQueue.VALUE = ''
  ADD(myQueue)
  myQueue.NAME  = 'Bbb'
  myQueue.VALUE = 2
  ADD(myQueue)
  myQueue.NAME  = 'Ccc'
  myQueue.VALUE = 3
  ADD(myQueue)
  
  ! turn on automatic CLIP()
  JSON.SetClipValues(true)
  ! create a JSON string from the records in the Queue
  GJSONString = JSON.ToJSON(myQueue)
  ! display the JSON string  
  MESSAGE('JSON String representation of the queue|'&GJSONString,,,,,2)
  
  ! empty the Queue of all records
  FREE(myQueue)
  ! re-build the Queue from the JSON string 
  JSON.FromJSON(GJSONString,myQueue)    
  
  ! display the new records
  LOOP I# = 1 TO RECORDS(myQueue)
       GET(myQueue,I#)
       IF NOT ERRORCODE()
          MESSAGE('Created from the JSON string Record# '&I#&'|'&|
                  'NAME  = '&myQueue.NAME&'|'&|
                  'VALUE = '&myQueue.VALUE)
       END
  END
