About the "IMDDAndSQLEx.app" -



The Dictionary is based on the MS-SQL Northwind database, but the Dictionary used in the example 

defines 2 additional tables which do not exist in the standard Northwind database. 



Those tables are:



CustomerOrderHist    FILE,DRIVER('MSSQL','/TURBOSQL=TRUE'),OWNER(',northwind,'),NAME('dbo.CustomerOrderHist'),PRE(CUS1),CREATE,BINDABLE,THREAD

Record                   RECORD,PRE()

ProductName                 CSTRING(41)

TotalQty                    LONG

                         END

                     END                       



IMDD_CustOrdHist     FILE,DRIVER('MEMORY'),PRE(IMD1),CREATE,BINDABLE,THREAD

Record                   RECORD,PRE()

ProductName                 CSTRING(41)

TotalQty                    LONG

                         END

                     END                     

                     

These tables are used in the example to call the stored procedure (CustOrderHist) which is part of the standard Northwind database. The CustOrderHist stored procedure returns a recordset with fields: ProductName and a SUM of the Quantity ordered by the customer for each product (the CustomerID is passed as parameter to Stored Procedure). 

