    program

    include('svbase.inc'), once


    map
      CreateConnection()
      ShowErrors(*CConnection pConn)
    end


    code
    CreateConnection()


CreateConnection    procedure

COMIniter           CCOMIniter                              ! CCOMIniter make sure the API COInitialise is called
szConnectStr        cstring(128)
MyConnectObject     &CConnection
hr                  HRESULT

    code

    szConnectStr = 'Provider=SQLOLEDB.1;Persist Security Info=False;User ID=INVALID_USER;Initial Catalog=northwind;Data Source=server1'

    if COMIniter.IsInitialised()

      MyConnectObject &= new(CConnection)                     ! Create an instance of a CConnection object
      if ~(MyConnectObject &= null)                           ! If instance was created without error
        hr = MyConnectObject.Init()                           ! Call the init method, this will actually create the ADO Connection object
        if hr = S_OK                                          ! If the ADO connection object was created without error
          hr = MyConnectObject.Connect(szConnectStr)          ! Call the Connect method with the Connection string
          if hr = S_OK                                        ! If method returned S_OK, the object connected to the db
            ! We are connected
            message('Connection made with the db!')
          else
            ! Something whent wrong                           ! Else, a problem occured.
            ShowErrors(MyConnectObject)
          end
        end
      else
        ! Instance creation went wrong
        message('MyConnectObject &= new(CConnection) did fail!')
      end

    else
      ! COM is not initialised
    end

    if ~(MyConnectObject &= null)

      hr = MyConnectObject.Close()                          ! Close the connection
      if hr = S_OK
        ! Connection closed ok
      else
        ! Connection didnt close
      end

      dispose(MyConnectObject)                              ! release the memory

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
