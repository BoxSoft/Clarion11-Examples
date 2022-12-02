    program

    include('svbase.inc'), once
    include('svmapper.inc'), once


    map
      CreateConnection(), *CConnection
      ShowErrors(*CConnection pConn)
      CreateSet(*CConnection pConn)
    end


COMIniter           CCOMIniter                              ! CCOMIniter make sure the API COInitialise is called
MyConnect           &CConnection


    code
    if COMIniter.IsInitialised()
      MyConnect &= CreateConnection()
      if ~(MyConnect &= null)
        CreateSet(MyConnect)
        MyConnect.Close()
        dispose(MyConnect)
      end
    end


CreateConnection    procedure

szConnectStr        cstring(128)
MyConnectObject     &CConnection
hr                  HRESULT

    code

    szConnectStr = 'Provider=SQLOLEDB.1;Persist Security Info=False;User ID=sa;Initial Catalog=northwind;Data Source=server1'

    MyConnectObject &= new(CConnection)                     ! Create an instance of a CConnection object
    if ~(MyConnectObject &= null)                           ! If instance was created without error
      hr = MyConnectObject.Init()                           ! Call the init method, this will actually create the ADO Connection object
      if hr = S_OK                                          ! If the ADO connection object was created without error
        hr = MyConnectObject.Connect(szConnectStr)          ! Call the Connect method with the Connection string
        if hr = S_OK                                        ! If method returned S_OK, the object connected to the db
          ! We are connected
          message('Connection made with the db!')
          return MyConnectObject                            ! Object and connection ok, return it
        else
          ! Something whent wrong                           
          message('Connection Object did not return S_OK, not connected to the db')
          ShowErrors(MyConnectObject)
          dispose(MyConnectObject)
          return null
        end
      end

      dispose(MyConnectObject)

    else
      ! Instance creation went wrong
      message('MyConnectObject &= new(CConnection) did fail!')
      return null
    end




CreateSet       procedure(*CConnection pConn)

CustomerQ       queue
CustomerID        string(5)
CompanyName       string(40)
City              string(15)
                end

Mapper          &TableMapper
CustSet         &CRecordset

hr              HRESULT

cstrQuery       cstring('SELECT CustomerID, CompanyName, City FROM CUSTOMERS')

Window WINDOW('Customers'),AT(,,434,184),FONT('MS Sans Serif',8,,FONT:regular,CHARSET:ANSI),GRAY,DOUBLE
       LIST,AT(9,6,416,128),USE(?List1),VSCROLL,FORMAT('48L(2)|M~Customer ID~@s5@167L(2)|M~Company Name~@s40@20L(2)|M~City~@s15@'), |
           FROM(CustomerQ)
       BUTTON('Close'),AT(361,150,45,14),USE(?Close)
     END


    code
    Mapper &= new(TableMapper)                   ! Create a mapper object
    if Mapper &= null                            ! Check if mapper created ok
      message('Mapper object not created!')
      return
    end

    CustSet &= new(CRecordset)                   ! Create a CRecordset object
    if CustSet &= null                           ! Check if CRecordset created ok
      message('CustSet object not created')
      return
    end

    hr = CustSet.Init()                                                                 ! Call to CRecordset Init, this will create the ADO Recordset object
    if hr = S_OK                                                                        ! if ADO Recordset created ok
      hr = CustSet.PutCursorLocation(adUseClient)                                       ! Set cursor location to adUseClient
      hr = CustSet.Open(cstrQuery, pConn,  adUSeClient, adLockOptimistic, adCmdText)    ! Open the set

      if hr = S_OK                                                                      ! If no errors

        Mapper.addFieldsInfo('CUSTOMERS', CustomerQ)                                    ! Instruct the Mapper to map the Queue members to corresponding column
                                                                                        ! in the query

        Mapper.Map(CustSet)                                                             ! Execute the mapping with the values of current row of the recordset
        add(CustomerQ)                                                                  ! Add in the queue
        do FillQ                                                                        ! Fill the other rows of the set in the Q

      else
        ShowErrors(pConn)
      end
    end

    if records(CustomerQ)                        ! If there are records, open the window and display them

      open(window)
      accept
        case field()
        of ?Close
          if event() = EVENT:Accepted
            post(EVENT:CloseWindow)
          end
        end
      end

    end

    free(CustomerQ)                             ! Free the queue
    CustSet.Close()                             ! Close the set
    dispose(CustSet)                            ! Cleanup memory
    dispose(Mapper)                             ! Cleanup memory


FillQ       routine

    data

bEof    short   ! Used to check for Recordset EOF

    code
    loop
      hr = CustSet.MoveNext()         ! Get the next row in the recordset
      if hr = S_OK                    ! if no error
        hr = CustSet.GetEof(bEof)     ! Check if there is an EOF condition
        if hr = S_OK                  ! if no error occured during the check of EOF
          if bEof = -1                ! look at the value of bEof var (with ADO, true is -1 and false is 0). So if bEof is "true"
            break                     ! break the loop
          else                        ! else
            Mapper.Map(CustSet)       ! Execute the mapping with the values of the current row of the recordset
            add(CustomerQ)            ! and add them to the queue
          end
        end
      else
        break
      end
    end


ShowErrors      procedure(*CConnection pConn)

Errors          &CErrors
cErr            &CError
lErr            long
cstrDesc        &CStr

ErrorCount      long
ndx             long
hr              HRESULT

ErrorQueue      queue
ErrorID           long
ErrorDesc         string(125)
                end

Window WINDOW('Errors list'),AT(,,401,235),GRAY,DOUBLE
       LIST,AT(3,6,395,190),USE(?List1),FORMAT('73R(2)|M~Error Number~@n-15@100L(2)|M~Description~@s100@'), |
           FROM(ErrorQueue)
       BUTTON('Close'),AT(349,206,45,14),USE(?btnClose)
     END

    code

    Errors &= pConn.Errors(hr)                                  ! Get the Errors collection object from the connection

    if hr = S_OK                                                ! if everything ok
      hr = Errors.GetCount(ErrorCount)                          ! Get the count number of errors
      if hr = S_OK                                              !
        loop ndx = 0 to ErrorCount - 1                          ! Single error object in the collection are numbered starting with 0
          cErr &= Errors.Error(ndx, hr)                         ! Get a single error object from the erros collection
          if hr = S_OK                                          !
            hr = cErr.Number(lErr)                              ! Get the error number code
            if hr = S_OK                                        !
              ErrorQueue.ErrorID = lErr                         !
              cstrDesc &= cErr.Description(hr)                  ! Get the description
              if hr = S_OK                                      !
                ErrorQueue.ErrorDesc = cstrDesc.GetCstr()       !
                add(ErrorQueue)                                 ! Add to the list queue
              end
              dispose(cstrDesc)
            end
            dispose(cErr)
          end

        end
      end

      dispose(Errors)

    end

    open(window)
    accept
      case field()
      of ?btnClose
        if event() = EVENT:Accepted
          post(EVENT:CloseWindow)
        end
      end
    end

    free(ErrorQueue)





