
  PROGRAM

 INCLUDE('equates.clw'),ONCE 
 INCLUDE ('JSON.INC'),ONCE

  MAP
  END
JSON JSONDataClass

S STRING(200000) 
S2 STRING(200000) 
 


ItemsArray QUEUE,TYPE
A           CSTRING(10) !can be null when empty
B           LONG
C           BYTE !true/false
 END

localArray &ItemsArray

IG GROUP
ColsNum BYTE
ColVals BYTE,DIM(3)!true/false
 END
 
localGroup   GROUP
Anumber        LONG
items          &ItemsArray
IsActive       BYTE !true/false
Description    CSTRING(30)!can be null when empty
nums           LONG,DIM(5)
Cols           LIKE(IG)
           END

 CODE
 
    localGroup.IsActive = false
    localGroup.Description = 'A'
    localGroup.nums[1] = 1
    localGroup.nums[2] = 2
    localGroup.nums[3] = 3
    localGroup.nums[4] = 4
    localGroup.nums[5] = 5
    
    localGroup.Cols.ColsNum = 3
    localGroup.Cols.ColVals[1] = true
    localGroup.Cols.ColVals[2] = false
    localGroup.Cols.ColVals[3] = false

    
    localGroup.items &= new ItemsArray
    localGroup.items.A = '1';localGroup.items.B = 10;localGroup.items.C = true;ADD(localGroup.items)
    localGroup.items.A = '';localGroup.items.B = 22;localGroup.items.C = false;ADD(localGroup.items)
    localGroup.items.A = '3';localGroup.items.B = 34;localGroup.items.C = true;ADD(localGroup.items)
    JSON.AddSubQueue('items',localGroup.items)

    JSON.SetSupportNullString(true)    
    JSON.SetNumberFormatter('ColVals','@BOOL')
    JSON.SetNumberFormatter('IsActive','@BOOL')
    JSON.SetNumberFormatter('Description','@NULL')
    JSON.SetNumberFormatter('A','@NULL')
    JSON.SetNumberFormatter('C','@BOOL')
    
    S = JSON.ToJSON(localGroup)

    FREE(localGroup.items)

    JSON.FromJSON(CLIP(S),localGroup)
    S2 = JSON.ToJSON(localGroup)
    MESSAGE('T:'&CLIP(S)&'|F:'&CLIP(S2))
