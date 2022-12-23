  MEMBER('invoice.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('invoice_BC0.CLW')
invoice_BC0:DctInit             PROCEDURE()
invoice_BC0:DctKill             PROCEDURE()
invoice_BC0:FilesInit           PROCEDURE()
    END
  END

DctInit PROCEDURE()
  CODE
  invoice_BC0:DctInit
  invoice_BC0:FilesInit


DctKill PROCEDURE()
  CODE
  invoice_BC0:DctKill

