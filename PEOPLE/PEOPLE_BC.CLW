  MEMBER('people.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('people_BC0.CLW')
people_BC0:DctInit             PROCEDURE()
people_BC0:DctKill             PROCEDURE()
people_BC0:FilesInit           PROCEDURE()
    END
  END

DctInit PROCEDURE()
  CODE
  people_BC0:DctInit
  people_BC0:FilesInit


DctKill PROCEDURE()
  CODE
  people_BC0:DctKill

