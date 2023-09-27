  MEMBER('people.clw')

  INCLUDE('ABFILE.INC'),ONCE

  MAP
people_BC0:DctInit    PROCEDURE()
people_BC0:DctKill    PROCEDURE()
people_BC0:FilesInit  PROCEDURE()
  END

Hide:Access:people   CLASS(FileManager),TYPE               ! FileManager for people
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:people   CLASS(RelationManager),TYPE           ! RelationManager for people
Init                   PROCEDURE
Kill                   PROCEDURE(),DERIVED
                     END


_Hide:Access:people  &Hide:Access:people,AUTO,THREAD
_Hide:Relate:people  &Hide:Relate:people,AUTO,THREAD


people_BC0:DctInit PROCEDURE()
  CODE
  _Hide:Access:people &= NEW(Hide:Access:people)
  _Hide:Relate:people &= NEW(Hide:Relate:people)
  Relate:people &= _Hide:Relate:people


people_BC0:FilesInit PROCEDURE()
  CODE
  _Hide:Relate:people.Init


people_BC0:DctKill PROCEDURE()
  CODE
  _Hide:Relate:people.Kill
  DISPOSE(_Hide:Relate:people)


Hide:Relate:people.Init PROCEDURE()
  CODE
  _Hide:Access:people.Init
  SELF.Init(Access:people,1)


Hide:Access:people.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= PEO:Record
  SELF.FileNameValue = 'people'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= people
  PARENT.Init
  Access:people &= SELF


Hide:Access:people.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:people &= NULL                                    ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:people.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(people,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(PEO:KeyId,'PEO:KeyId',1)
    SELF.AddKey(PEO:KeyLastName,'PEO:KeyLastName',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:people.Kill PROCEDURE

  CODE
  _Hide:Access:people.Kill                                 ! Kill the file manager
  PARENT.Kill
  Relate:people &= NULL                                    ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:people)                             ! destroy the file manager

