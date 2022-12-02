  MEMBER('SqlScriptor.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('SqlScriptor_BC0.CLW')
SqlScriptor_BC0:DctInit             PROCEDURE
SqlScriptor_BC0:DctKill             PROCEDURE
SqlScriptor_BC0:FilesInit           PROCEDURE
    END
  END

DctInit PROCEDURE
  CODE
  SqlScriptor_BC0:DctInit
  SqlScriptor_BC0:FilesInit


DctKill PROCEDURE
  CODE
  SqlScriptor_BC0:DctKill

