  MEMBER('SqlScriptor.clw')

  INCLUDE('ABFILE.INC'),ONCE

  MAP
SqlScriptor_BC0:DctInit    PROCEDURE
SqlScriptor_BC0:DctKill    PROCEDURE
SqlScriptor_BC0:FilesInit  PROCEDURE
  END

Hide:Access:sqlTable CLASS(FileManager),TYPE               ! FileManager for sqlTable
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:sqlTable CLASS(RelationManager),TYPE           ! RelationManager for sqlTable
Init                   PROCEDURE
Kill                   PROCEDURE(),DERIVED
                     END


_Hide:Access:sqlTable &Hide:Access:sqlTable,AUTO,THREAD
_Hide:Relate:sqlTable &Hide:Relate:sqlTable,AUTO,THREAD


SqlScriptor_BC0:DctInit PROCEDURE
  CODE
  _Hide:Access:sqlTable &= NEW(Hide:Access:sqlTable)
  _Hide:Relate:sqlTable &= NEW(Hide:Relate:sqlTable)
  Relate:sqlTable &= _Hide:Relate:sqlTable


SqlScriptor_BC0:FilesInit PROCEDURE
  CODE
  _Hide:Relate:sqlTable.Init


SqlScriptor_BC0:DctKill PROCEDURE
  CODE
  _Hide:Relate:sqlTable.Kill
  DISPOSE(_Hide:Relate:sqlTable)


Hide:Relate:sqlTable.Init PROCEDURE
  CODE
  _Hide:Access:sqlTable.Init
  SELF.Init(Access:sqlTable,1)


Hide:Access:sqlTable.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= sql:Record
  SELF.FileNameValue = 'sqlTable'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= sqlTable
  PARENT.Init
  Access:sqlTable &= SELF


Hide:Access:sqlTable.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:sqlTable &= NULL                                  ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:sqlTable.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(sqlTable,GlobalErrors)
    SELF.Create = 0
    SELF.LockRecover = 10
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:sqlTable.Kill PROCEDURE

  CODE
  _Hide:Access:sqlTable.Kill                               ! Kill the file manager
  PARENT.Kill
  Relate:sqlTable &= NULL                                  ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:sqlTable)                           ! destroy the file manager

