  MODULE('TESTINVDEV003.CLW')
TestGenerate_CustomerCompany PROCEDURE                !Generate some CustomerCompany ecords to test having a lot in the file
DeleteAll_CustomerCompany PROCEDURE                   !Process the CustomerCompany File
TestGenerate_CustomerFile PROCEDURE                   !Generate Test Data for Customer - TODO Test Transaction and Timing ?
DeleteAll_Customer     PROCEDURE                      !Process the CustomerCompany File
TestGenerate_Product   PROCEDURE                      !Generate some Product records to test having a lot in the file
DeleteAll_Product      PROCEDURE                      !Process the Product File to Delete All
TestMakeGUID_StressTest PROCEDURE                     !Call MakeGUID() a million times to check for Duplicates
TestGenerate_Invoices  PROCEDURE                      !Generate Test Data for Customer - TODO Test Transaction and Timing ?
DeleteAll_Invoice      PROCEDURE                      !Process the Invoice File then Details
DeleteAll_InvoiceDetail PROCEDURE                     !Process the Invoice File then Details
  END
