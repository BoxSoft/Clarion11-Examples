

   MEMBER('invoice.clw')                                   ! This is a MEMBER module

                     MAP
                       INCLUDE('INVOICE021.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
MakeGUID             PROCEDURE                             ! Declare Procedure
Alphabet                STRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')
X                       LONG
Guid                    STRING(16)        

  CODE
  LOOP X = 1 TO SIZE(Guid)
    Guid[X] = Alphabet[RANDOM(1, SIZE(Alphabet))]
  END
  RETURN Guid
    
