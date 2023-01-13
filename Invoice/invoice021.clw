

   MEMBER('invoice.clw')                                   ! This is a MEMBER module

                     MAP
                       INCLUDE('INVOICE021.INC'),ONCE        !Local module procedure declarations
                       INCLUDE('INVOICE006.INC'),ONCE        !Req'd for module callout resolution
                     END


!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
MakeGUID             PROCEDURE                             ! Declare Procedure
Alphabet               STRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')
X                      LONG
Guid                   STRING(16)        

  CODE
  LOOP X = 1 TO SIZE(Guid)
    Guid[X] = Alphabet[RANDOM(1, SIZE(Alphabet))]
  END
  RETURN Guid
    
!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
BrowseInvoice        PROCEDURE                             ! Declare Procedure

  CODE
  BrowseInvoice:Window()
  
