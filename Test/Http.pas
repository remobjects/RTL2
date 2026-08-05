namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.EUnit,
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Units
  {$IF ISLAND AND WINDOWS},
  RemObjects.Elements.System
  {$ENDIF};

type
  HttpProxyTests = public class(Test)
  public

    method TestHttpProxyModeEnum;
    begin
      // Verify enum ordinal values match expected (important for DLL interop)
      Check.AreEqual(Integer(HttpProxyMode.None), 0);
      Check.AreEqual(Integer(HttpProxyMode.System), 1);
      Check.AreEqual(Integer(HttpProxyMode.Custom), 2);
    end;

    method TestHttpProxySettingsDefaultConstructor;
    begin
      var settings := new HttpProxySettings();
      Check.AreEqual(settings.Mode, HttpProxyMode.System);
      Check.AreEqual(settings.Host, nil);
      Check.AreEqual(settings.Port, 8080);
    end;

    method TestHttpProxySettingsModeConstructor;
    begin
      var settingsNone := new HttpProxySettings(HttpProxyMode.None);
      Check.AreEqual(settingsNone.Mode, HttpProxyMode.None);

      var settingsSystem := new HttpProxySettings(HttpProxyMode.System);
      Check.AreEqual(settingsSystem.Mode, HttpProxyMode.System);

      var settingsCustom := new HttpProxySettings(HttpProxyMode.Custom);
      Check.AreEqual(settingsCustom.Mode, HttpProxyMode.Custom);
    end;

    method TestHttpProxySettingsCustomConstructor;
    begin
      var settings := new HttpProxySettings('proxy.example.com', 3128);
      Check.AreEqual(settings.Mode, HttpProxyMode.Custom);
      Check.AreEqual(settings.Host, 'proxy.example.com');
      Check.AreEqual(settings.Port, 3128);
    end;

    method TestHttpProxySettingsDefaultProperty;
    begin
      var defaultSettings := HttpProxySettings.Default;
      Check.IsNotNil(defaultSettings);
      Check.AreEqual(defaultSettings.Mode, HttpProxyMode.System);
    end;

    method TestHttpRequestProxyPropertyAssignment;
    begin
      var request := new HttpRequest(Url.UrlWithString('https://example.com'));

      // Initially nil
      Check.AreEqual(request.Proxy, nil);

      // Assign proxy settings
      var proxySettings := new HttpProxySettings('proxy.test.com', 8080);
      request.Proxy := proxySettings;

      // Verify assignment (reference equality)
      Check.AreEqual(request.Proxy, proxySettings);
      Check.AreEqual(request.Proxy.Host, 'proxy.test.com');
      Check.AreEqual(request.Proxy.Port, 8080);
      Check.AreEqual(request.Proxy.Mode, HttpProxyMode.Custom);
    end;

    method TestHttpRequestProxyIsReferenceType;
    begin
      // Verify that HttpProxySettings is a reference type (class, not record)
      // Assigning to request.Proxy should share the same object
      var proxySettings := new HttpProxySettings('proxy.test.com', 8080);
      var request := new HttpRequest(Url.UrlWithString('https://example.com'));
      request.Proxy := proxySettings;

      // Modify original - should affect request.Proxy since it's the same reference
      proxySettings.Port := 9999;
      Check.AreEqual(request.Proxy.Port, 9999);
    end;

  end;

  HttpCancelTests = public class(Test)
  public

    //method TestCancelOnFreshRequestIsNoOp;
    //begin
      //// Calling Cancel() before a request is started should not raise
      //var request := new HttpRequest(Url.UrlWithString('https://example.com'));
      //Check.That( () -> request.Cancel() ).DoesNotRaise();
    //end;

    //method TestCancelCalledTwiceIsNoOp;
    //begin
      //// Cancel() must be idempotent — second call should not raise or double-free
      //var request := new HttpRequest(Url.UrlWithString('https://example.com'));
      //request.Cancel();
      //Check.That( () -> request.Cancel() ).DoesNotRaise();
    //end;

    method TestRequestRemainsUsableAfterCancel;
    begin
      // Properties on the request should still be readable after Cancel()
      var request := new HttpRequest(Url.UrlWithString('https://example.com'));
      request.Cancel();
      Check.AreEqual(request.Url.ToString, 'https://example.com');
      Check.AreEqual(Double(request.Timeout), Double(10 Seconds));
    end;

  end;

  {$IF ISLAND AND WINDOWS}
  {$IFDEF DEBUG}
  LoopbackHttpProxy = private class(IDisposable)
  private
    fFinished: &Event := new &Event;
    fListener: Socket;
    fPort: Integer;
    fStopping: Boolean;
    fFailure: Exception;
  public
    constructor;
    begin
      fListener := new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
      fListener.Bind(new IPEndPoint(IPAddress.Parse('127.0.0.1'), 0));

      var lAddress := new Byte[sizeOf(rtl.SOCKADDR_IN)];
      var lAddressSize := lAddress.Length;
      if rtl.getsockname(fListener.Handle, @lAddress[0], @lAddressSize) <> 0 then
        raise new RTLException($"Could not get the loopback proxy port (Windows error {rtl.WSAGetLastError}).");
      fPort := rtl.ntohs(^rtl.SOCKADDR_IN(@lAddress[0])^.sin_port);
      fListener.Listen(1);

      async begin
        try
          using lClient := fListener.Accept() do begin
            var lRequestBuffer := new Byte[4096];
            lClient.Receive(lRequestBuffer);
            lClient.Send(Encoding.UTF8.GetBytes('HTTP/1.1 200 OK' + #13#10 + 'Content-Length: 9' + #13#10 + 'Connection: close' + #13#10 + #13#10 + 'via-proxy'));
          end;
        except
          on E: Exception do
            if not fStopping then
              fFailure := E;
        finally
          fFinished.Set();
        end;
      end;
    end;

    method Dispose;
    begin
      fStopping := true;
      if assigned(fListener) then begin
        fListener.Close();
        fListener := nil;
      end;
      fFinished.WaitFor(5 Seconds);
      if assigned(fFailure) then
        raise fFailure;
    end;

    property Port: Integer read fPort;
  end;

  WindowsSystemProxyTests = public class(Test)
  public
    method TestSystemProxyUsesResolvedStaticProxy;
    begin
      var lPreviousProxy := Http.SystemProxyForTesting;
      try
        using lProxy := new LoopbackHttpProxy() do begin
          Http.SystemProxyForTesting := new HttpProxySettings('127.0.0.1', lProxy.Port);

          var lRequest := new HttpRequest(Url.UrlWithString('http://system-proxy-test.invalid/through-proxy'));
          lRequest.Proxy := new HttpProxySettings(HttpProxyMode.System);
          lRequest.Timeout := 5 Seconds;
          using lResponse := Http.ExecuteRequestSynchronous(lRequest) do
            Check.AreEqual(lResponse.GetContentAsStringSynchronous, 'via-proxy');
        end;
      finally
        Http.SystemProxyForTesting := lPreviousProxy;
      end;
    end;
  end;
  {$ENDIF}
  {$ENDIF}

end.
