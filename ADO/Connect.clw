    program

    include('svbase.inc'), once


    map
      CreateConnection()
    end


    code
    CreateConnection()


CreateConnection    procedure

COMIniter           CCOMIniter                              ! CCOMIniter make sure the API COInitialise is called
szConnectStr        cstring(128)
MyConnectObject     &CConnection
hr                  HRESULT

    code

    szConnectStr = 'Provider=SQLOLEDB.1;Persist Security Info=False;User ID=sa;Initial Catalog=northwind;Data Source=server1'

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
            message('Connection Object did not return S_OK, not connected to the db')
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


