  MEMBER('invoice.clw')

  INCLUDE('ABFILE.INC'),ONCE

  MAP
invoice_BC0:DctInit    PROCEDURE()
invoice_BC0:DctKill    PROCEDURE()
invoice_BC0:FilesInit  PROCEDURE()
  END

Hide:Access:CustomerCompany CLASS(FileManager),TYPE        ! FileManager for CustomerCompany
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:CustomerCompany CLASS(RelationManager),TYPE    ! RelationManager for CustomerCompany
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:Product  CLASS(FileManager),TYPE               ! FileManager for Product
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Product  CLASS(RelationManager),TYPE           ! RelationManager for Product
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:InvoiceDetail CLASS(FileManager),TYPE          ! FileManager for InvoiceDetail
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:InvoiceDetail CLASS(RelationManager),TYPE      ! RelationManager for InvoiceDetail
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:Invoice  CLASS(FileManager),TYPE               ! FileManager for Invoice
Init                   PROCEDURE(),DERIVED
Insert                 PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
TryInsert              PROCEDURE(),BYTE,PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Invoice  CLASS(RelationManager),TYPE           ! RelationManager for Invoice
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:Customer CLASS(FileManager),TYPE               ! FileManager for Customer
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Customer CLASS(RelationManager),TYPE           ! RelationManager for Customer
Init                   PROCEDURE
DeferedAddRelations    PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
                     END

Hide:Access:Configuration CLASS(FileManager),TYPE          ! FileManager for Configuration
Init                   PROCEDURE(),DERIVED
Kill                   PROCEDURE(),DERIVED
PrimeFields            PROCEDURE(),PROC,DERIVED
UseFile                PROCEDURE(BYTE UseType = UseType:Uses),BYTE,PROC,DERIVED
                     END


Hide:Relate:Configuration CLASS(RelationManager),TYPE      ! RelationManager for Configuration
Init                   PROCEDURE
Kill                   PROCEDURE(),DERIVED
                     END


_Hide:Access:CustomerCompany &Hide:Access:CustomerCompany,AUTO,THREAD
_Hide:Relate:CustomerCompany &Hide:Relate:CustomerCompany,AUTO,THREAD
_Hide:Access:Product &Hide:Access:Product,AUTO,THREAD
_Hide:Relate:Product &Hide:Relate:Product,AUTO,THREAD
_Hide:Access:InvoiceDetail &Hide:Access:InvoiceDetail,AUTO,THREAD
_Hide:Relate:InvoiceDetail &Hide:Relate:InvoiceDetail,AUTO,THREAD
_Hide:Access:Invoice &Hide:Access:Invoice,AUTO,THREAD
_Hide:Relate:Invoice &Hide:Relate:Invoice,AUTO,THREAD
_Hide:Access:Customer &Hide:Access:Customer,AUTO,THREAD
_Hide:Relate:Customer &Hide:Relate:Customer,AUTO,THREAD
_Hide:Access:Configuration &Hide:Access:Configuration,AUTO,THREAD
_Hide:Relate:Configuration &Hide:Relate:Configuration,AUTO,THREAD


invoice_BC0:DctInit PROCEDURE()
  CODE
  _Hide:Access:CustomerCompany &= NEW(Hide:Access:CustomerCompany)
  _Hide:Relate:CustomerCompany &= NEW(Hide:Relate:CustomerCompany)
  _Hide:Access:Product &= NEW(Hide:Access:Product)
  _Hide:Relate:Product &= NEW(Hide:Relate:Product)
  _Hide:Access:InvoiceDetail &= NEW(Hide:Access:InvoiceDetail)
  _Hide:Relate:InvoiceDetail &= NEW(Hide:Relate:InvoiceDetail)
  _Hide:Access:Invoice &= NEW(Hide:Access:Invoice)
  _Hide:Relate:Invoice &= NEW(Hide:Relate:Invoice)
  _Hide:Access:Customer &= NEW(Hide:Access:Customer)
  _Hide:Relate:Customer &= NEW(Hide:Relate:Customer)
  _Hide:Access:Configuration &= NEW(Hide:Access:Configuration)
  _Hide:Relate:Configuration &= NEW(Hide:Relate:Configuration)
  Relate:CustomerCompany &= _Hide:Relate:CustomerCompany
  Relate:Product &= _Hide:Relate:Product
  Relate:InvoiceDetail &= _Hide:Relate:InvoiceDetail
  Relate:Invoice &= _Hide:Relate:Invoice
  Relate:Customer &= _Hide:Relate:Customer
  Relate:Configuration &= _Hide:Relate:Configuration


invoice_BC0:FilesInit PROCEDURE()
  CODE
  _Hide:Relate:CustomerCompany.Init
  _Hide:Relate:Product.Init
  _Hide:Relate:InvoiceDetail.Init
  _Hide:Relate:Invoice.Init
  _Hide:Relate:Customer.Init
  _Hide:Relate:Configuration.Init


invoice_BC0:DctKill PROCEDURE()
  CODE
  _Hide:Relate:CustomerCompany.Kill
  DISPOSE(_Hide:Relate:CustomerCompany)
  _Hide:Relate:Product.Kill
  DISPOSE(_Hide:Relate:Product)
  _Hide:Relate:InvoiceDetail.Kill
  DISPOSE(_Hide:Relate:InvoiceDetail)
  _Hide:Relate:Invoice.Kill
  DISPOSE(_Hide:Relate:Invoice)
  _Hide:Relate:Customer.Kill
  DISPOSE(_Hide:Relate:Customer)
  _Hide:Relate:Configuration.Kill
  DISPOSE(_Hide:Relate:Configuration)


Hide:Relate:CustomerCompany.Init PROCEDURE()
  CODE
  _Hide:Access:CustomerCompany.Init
  SELF.Init(Access:CustomerCompany,1)


Hide:Access:CustomerCompany.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= CusCom:Record
  SELF.FileNameValue = 'CustomerCompany'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= CustomerCompany
  PARENT.Init
  Access:CustomerCompany &= SELF


Hide:Access:CustomerCompany.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:CustomerCompany &= NULL                           ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:CustomerCompany.PrimeFields PROCEDURE

  CODE
  CusCom:GUID = MakeGUID()                                 ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:CustomerCompany.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(CustomerCompany,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(CusCom:GuidKey,'CusCom:GuidKey',0)
    SELF.AddKey(CusCom:CompanyNameKey,'CusCom:CompanyNameKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:CustomerCompany.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:Customer,RI:None,RI:RESTRICT,Cus:CompanyKey)
  SELF.AddRelationLink(CusCom:GUID,Cus:CompanyGuid)


Hide:Relate:CustomerCompany.Kill PROCEDURE

  CODE
  _Hide:Access:CustomerCompany.Kill                        ! Kill the file manager
  PARENT.Kill
  Relate:CustomerCompany &= NULL                           ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:CustomerCompany)                    ! destroy the file manager


Hide:Relate:Product.Init PROCEDURE()
  CODE
  _Hide:Access:Product.Init
  SELF.Init(Access:Product,1)


Hide:Access:Product.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Pro:Record
  SELF.FileNameValue = 'Product'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Product
  PARENT.Init
  Access:Product &= SELF


Hide:Access:Product.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Product &= NULL                                   ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Product.PrimeFields PROCEDURE

  CODE
  Pro:GUID = MakeGUID()                                    ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:Product.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Product,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Pro:GuidKey,'Pro:GuidKey',0)
    SELF.AddKey(Pro:ProductCodeKey,'Pro:ProductCodeKey',0)
    SELF.AddKey(Pro:ProductNameKey,'Pro:ProductNameKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Product.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:InvoiceDetail,RI:None,RI:RESTRICT,InvDet:ProductKey)
  SELF.AddRelationLink(Pro:GUID,InvDet:ProductGuid)


Hide:Relate:Product.Kill PROCEDURE

  CODE
  _Hide:Access:Product.Kill                                ! Kill the file manager
  PARENT.Kill
  Relate:Product &= NULL                                   ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Product)                            ! destroy the file manager


Hide:Relate:InvoiceDetail.Init PROCEDURE()
  CODE
  _Hide:Access:InvoiceDetail.Init
  SELF.Init(Access:InvoiceDetail,1)


Hide:Access:InvoiceDetail.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= InvDet:Record
  SELF.FileNameValue = 'InvoiceDetail'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= InvoiceDetail
  PARENT.Init
  Access:InvoiceDetail &= SELF


Hide:Access:InvoiceDetail.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:InvoiceDetail &= NULL                             ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:InvoiceDetail.PrimeFields PROCEDURE

  CODE
  InvDet:GUID = MakeGUID()                                 ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:InvoiceDetail.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(InvoiceDetail,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(InvDet:GuidKey,'InvDet:GuidKey',0)
    SELF.AddKey(InvDet:InvoiceKey,'InvDet:InvoiceKey',0)
    SELF.AddKey(InvDet:ProductKey,'InvDet:ProductKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:InvoiceDetail.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:Invoice)

  SELF.AddRelation(Relate:Product)


Hide:Relate:InvoiceDetail.Kill PROCEDURE

  CODE
  _Hide:Access:InvoiceDetail.Kill                          ! Kill the file manager
  PARENT.Kill
  Relate:InvoiceDetail &= NULL                             ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:InvoiceDetail)                      ! destroy the file manager


Hide:Relate:Invoice.Init PROCEDURE()
  CODE
  _Hide:Access:Invoice.Init
  SELF.Init(Access:Invoice,1)


Hide:Access:Invoice.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Inv:Record
  SELF.FileNameValue = 'Invoice'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Invoice
  PARENT.Init
  Access:Invoice &= SELF


Hide:Access:Invoice.Insert PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  IF LogoutInvoice(App:ShowMessage) <> Level:Benign
    RETURN Level:Notify
  END
  Inv:InvoiceNumber = NextInvoiceNumber()
  ReturnValue = PARENT.Insert()
  COMMIT
  RETURN ReturnValue


Hide:Access:Invoice.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Invoice &= NULL                                   ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Invoice.PrimeFields PROCEDURE

  CODE
  Inv:GUID = MakeGUID()                                    ! Assign initial field value
  Inv:Date = TODAY()                                       ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:Invoice.TryInsert PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  IF LogoutInvoice(App:DontShowMessage) <> Level:Benign
    RETURN Level:Notify
  END
  Inv:InvoiceNumber = NextInvoiceNumber()
  ReturnValue = PARENT.TryInsert()
  COMMIT
  RETURN ReturnValue


Hide:Access:Invoice.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Invoice,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Inv:GuidKey,'Inv:GuidKey',0)
    SELF.AddKey(Inv:CustomerKey,'Inv:CustomerKey',0)
    SELF.AddKey(Inv:InvoiceNumberKey,'Inv:InvoiceNumberKey',0)
    SELF.AddKey(Inv:DateKey,'Inv:DateKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Invoice.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:InvoiceDetail,RI:None,RI:CASCADE,InvDet:InvoiceKey)
  SELF.AddRelationLink(Inv:GUID,InvDet:InvoiceGuid)

  SELF.AddRelation(Relate:Customer)


Hide:Relate:Invoice.Kill PROCEDURE

  CODE
  _Hide:Access:Invoice.Kill                                ! Kill the file manager
  PARENT.Kill
  Relate:Invoice &= NULL                                   ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Invoice)                            ! destroy the file manager


Hide:Relate:Customer.Init PROCEDURE()
  CODE
  _Hide:Access:Customer.Init
  SELF.Init(Access:Customer,1)


Hide:Access:Customer.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Cus:Record
  SELF.FileNameValue = 'Customer'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Customer
  PARENT.Init
  Access:Customer &= SELF


Hide:Access:Customer.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Customer &= NULL                                  ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Customer.PrimeFields PROCEDURE

  CODE
  Cus:GUID = MakeGUID()                                    ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:Customer.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Customer,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Cus:GuidKey,'Cus:GuidKey',0)
    SELF.AddKey(Cus:CompanyKey,'Cus:CompanyKey',0)
    SELF.AddKey(Cus:CustomerNumberKey,'Cus:CustomerNumberKey',1)
    SELF.AddKey(Cus:LastFirstNameKey,'Cus:LastFirstNameKey',0)
    SELF.AddKey(Cus:FirstLastNameKey_Copy,'Cus:FirstLastNameKey_Copy',0)
    SELF.AddKey(Cus:PostalCodeKey,'Cus:PostalCodeKey',0)
    SELF.AddKey(Cus:StateKey,'Cus:StateKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Customer.DeferedAddRelations PROCEDURE

  CODE
  DO AddRelations_1
  
  PARENT.DeferedAddRelations

AddRelations_1 ROUTINE
  SELF.AddRelation(Relate:Invoice,RI:None,RI:RESTRICT,Inv:CustomerKey)
  SELF.AddRelationLink(Cus:GUID,Inv:CustomerGuid)

  SELF.AddRelation(Relate:CustomerCompany)


Hide:Relate:Customer.Kill PROCEDURE

  CODE
  _Hide:Access:Customer.Kill                               ! Kill the file manager
  PARENT.Kill
  Relate:Customer &= NULL                                  ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Customer)                           ! destroy the file manager


Hide:Relate:Configuration.Init PROCEDURE()
  CODE
  _Hide:Access:Configuration.Init
  SELF.Init(Access:Configuration,1)


Hide:Access:Configuration.Init PROCEDURE

  CODE
  SELF.Initialized = False
  SELF.Buffer &= Cfg:Record
  SELF.FileNameValue = 'Configuration'
  SELF.SetErrors(GlobalErrors)
  SELF.File &= Configuration
  PARENT.Init
  Access:Configuration &= SELF


Hide:Access:Configuration.Kill PROCEDURE

  CODE
  PARENT.Kill
  Access:Configuration &= NULL                             ! File manager has been destroyed to assign null, it is an error to reference this after this point


Hide:Access:Configuration.PrimeFields PROCEDURE

  CODE
  Cfg:GUID = MakeGUID()                                    ! Assign initial field value
  PARENT.PrimeFields


Hide:Access:Configuration.UseFile PROCEDURE(BYTE UseType = UseType:Uses)

ReturnValue          BYTE,AUTO

  CODE
  IF UseType ~= UseType:Initialize
    SELF.UseFile(UseType:Initialize)                       !Recursive call to ensure initialization takes place
  END
  IF UseType = UseType:Initialize AND ~SELF.Initialized
    SELF.InUseFile = True
    SELF.Init(Configuration,GlobalErrors)
    SELF.Create = 1
    SELF.LockRecover = 10
    SELF.AddKey(Cfg:GuidKey,'Cfg:GuidKey',0)
  END
                                                           !SELF.InUseFile will be set to False in PARENT
  ReturnValue = PARENT.UseFile(UseType)
  RETURN ReturnValue


Hide:Relate:Configuration.Kill PROCEDURE

  CODE
  _Hide:Access:Configuration.Kill                          ! Kill the file manager
  PARENT.Kill
  Relate:Configuration &= NULL                             ! Assign NULL to the RelationManager's FileManager reference, it is an error to reference this after this point
  DISPOSE(_Hide:Access:Configuration)                      ! destroy the file manager

