  MEMBER('TRACE.clw')

  INCLUDE('ABFILE.INC'),ONCE

  MAP
TRACE_BC0:DctInit    PROCEDURE
TRACE_BC0:DctKill    PROCEDURE
TRACE_BC0:FilesInit  PROCEDURE
  END

Hide:Access:drvlist  CLASS(FileManager),TYPE               ! FileManager for drvlist
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:drvlist  CLASS(RelationManager),TYPE           ! RelationManager for drvlist
Init                   PROCEDURE
Kill                   PROCEDURE(),DERIVED
                     END


_Hide:Access:drvlist &Hide:Access:drvlist,AUTO,THREAD
_Hide:Relate:drvlist &Hide:Relate:drvlist,AUTO,THREAD


TRACE_BC0:DctInit PROCEDURE
  CODE
  _Hide:Access:drvlist &= NEW(Hide:Access:drvlist)
  _Hide:Relate:drvlist &= NEW(Hide:Relate:drvlist)
  Relate:drvlist &= _Hide:Relate:drvlist


TRACE_BC0:FilesInit PROCEDURE
  CODE
  _Hide:Relate:drvlist.Init


TRACE_BC0:DctKill PROCEDURE
  CODE
  _Hide:Relate:drvlist.Kill
  DISPOSE(_Hide:Relate:drvlist)


Hide:Relate:drvlist.Init PROCEDURE
  CODE
  _Hide:Access:drvlist.Init
  SELF.Init(Access:drvlist,1)


Hide:Access:drvlist.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= DRV:Record
  SELF.FileNameValue = 'drvlist'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= drvlist
  PARENT.Init
  Access:drvlist &= SELF


Hide:Access:drvlist.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:drvlist &= NULL                                   ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:drvlist.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(drvlist,GlobalErrors)
    SELF.LockRecover = 10
    SELF.AddKey(DRV:NameKey,'DRV:NameKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:drvlist.Kill PROCEDURE

  CODE
  _Hide:Access:drvlist.Kill                                ! Kill the file manager
  PARENT.Kill
  Relate:drvlist &= NULL                                   ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:drvlist)                            ! destroy the file manager

