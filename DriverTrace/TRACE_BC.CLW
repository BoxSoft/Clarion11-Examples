  MEMBER('TRACE.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('TRACE_BC0.CLW')
TRACE_BC0:DctInit             PROCEDURE
TRACE_BC0:DctKill             PROCEDURE
TRACE_BC0:FilesInit           PROCEDURE
    END
  END

DctInit PROCEDURE
  CODE
  TRACE_BC0:DctInit
  TRACE_BC0:FilesInit


DctKill PROCEDURE
  CODE
  TRACE_BC0:DctKill

