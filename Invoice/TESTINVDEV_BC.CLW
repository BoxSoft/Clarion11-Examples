  MEMBER('TestInvDev.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('TestInvDev_BC0.CLW')
TestInvDev_BC0:DctInit             PROCEDURE()
TestInvDev_BC0:DctKill             PROCEDURE()
TestInvDev_BC0:FilesInit           PROCEDURE()
    END
  END

DctInit PROCEDURE()
  CODE
  TestInvDev_BC0:DctInit
  TestInvDev_BC0:FilesInit


DctKill PROCEDURE()
  CODE
  TestInvDev_BC0:DctKill

