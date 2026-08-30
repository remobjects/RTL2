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
      Check.AreEqual(request.Url.ToString, 'https://example.com/');
      Check.AreEqual(Double(request.Timeout), Double(10 Seconds));
    end;

  end;

  {$IF ECHOES}
  LoopbackHttpErrorServer = private class(IDisposable)
  private

    fListener: System.Net.Sockets.TcpListener;
    fWorker: System.Threading.Thread;
    fReleaseBody := new System.Threading.ManualResetEventSlim;
    fStatusCode: Integer;
    fStopping: Boolean;
    fFailure: Exception;

    method Serve;
    begin
      try
        using lClient := fListener.AcceptTcpClient do
          using lStream := lClient.GetStream do begin
            lStream.ReadTimeout := 5000;
            lStream.WriteTimeout := 5000;
            using lReader := new System.IO.StreamReader(lStream, System.Text.Encoding.ASCII, false, 1024, true) do begin
              var lLine := lReader.ReadLine;
              while length(lLine) > 0 do
                lLine := lReader.ReadLine;
            end;

            var lBody := Encoding.UTF8.GetBytes(Body);
            var lHeaders := Encoding.UTF8.GetBytes($"HTTP/1.1 {fStatusCode} Test" + #13#10 +
              'Content-Type: application/json' + #13#10 +
              'X-Request-Id: local-http-test' + #13#10 +
              $"Content-Length: {lBody.Length}" + #13#10 +
              'Connection: close' + #13#10#13#10);
            lStream.Write(lHeaders, 0, lHeaders.Length);
            lStream.Flush;

            // Send the body only after the caller receives the response or exception.
            if not fReleaseBody.Wait(5000) then
              raise new Exception('Timed out waiting to release the test response body.');
            lStream.Write(lBody, 0, lBody.Length);
          end;
      except
        on E: Exception do
          if not fStopping then
            fFailure := E;
      end;
    end;

  public

    constructor(aStatusCode: Integer);
    begin
      fStatusCode := aStatusCode;
      fListener := new System.Net.Sockets.TcpListener(System.Net.IPAddress.Loopback, 0);
      fListener.Start;
      Port := (fListener.LocalEndpoint as System.Net.IPEndPoint).Port;
      fWorker := new System.Threading.Thread(-> Serve);
      fWorker.IsBackground := true;
      fWorker.Start;
    end;

    property Port: Integer read private write;
    property Body: String read '{"error":{"message":"declined"}}';

    method CreateRequest: HttpRequest;
    begin
      result := new HttpRequest(Url.UrlWithString($"http://127.0.0.1:{Port}/error"));
      result.Proxy := new HttpProxySettings(HttpProxyMode.None);
      result.Timeout := 5 Seconds;
    end;

    method ReleaseBody;
    begin
      fReleaseBody.Set;
    end;

    method Dispose;
    begin
      fStopping := true;
      fReleaseBody.Set;
      fListener.Stop;
      if not fWorker.Join(5000) then
        raise new Exception('The loopback HTTP server did not stop.');
      fReleaseBody.Dispose;
      if assigned(fFailure) then
        raise fFailure;
    end;

  end;

  HttpErrorResponseTests = public class(Test)
  public

    method TestSynchronousExceptionPreservesResponse;
    begin
      using lServer := new LoopbackHttpErrorServer(402) do begin
        var lRequest := lServer.CreateRequest;
        var lException: HttpException;
        try
          using lResponse := Http.ExecuteRequestSynchronous(lRequest) do;
        except
          on E: HttpException do
            lException := E;
        end;
        lServer.ReleaseBody;
        Check.IsNotNil(lException);
        if not assigned(lException) then
          exit;
        Check.AreEqual(lException.Request, lRequest);
        Check.AreEqual(lException.Code, 402);
        Check.IsNotNil(lException.Response);
        if not assigned(lException.Response) then
          exit;
        using lResponse := lException.Response do begin
          Check.AreEqual(lResponse.Code, 402);
          Check.IsFalse(lResponse.Success);
          var lRequestId: String;
          for each k in lResponse.Headers.Keys do
            if k.EqualsIgnoringCase('X-Request-Id') then
              lRequestId := lResponse.Headers[k];
          Check.AreEqual(lRequestId, 'local-http-test');
          Check.AreEqual(lResponse.GetContentAsJsonSynchronous['error']['message'].StringValue, 'declined');
        end;
      end;
    end;

    method TestTryExecutePreservesErrorResponse;
    begin
      using lServer := new LoopbackHttpErrorServer(402) do
        using lResponse := Http.TryExecuteRequestSynchronous(lServer.CreateRequest) do begin
          lServer.ReleaseBody;
          Check.IsNotNil(lResponse);
          Check.AreEqual(lResponse.Code, 402);
          Check.IsFalse(lResponse.Success);
          Check.AreEqual(lResponse.GetContentAsStringSynchronous, lServer.Body);
        end;
    end;

    method TestSuccessfulResponseRemainsReadable;
    begin
      using lServer := new LoopbackHttpErrorServer(200) do
        using lResponse := Http.ExecuteRequestSynchronous(lServer.CreateRequest) do begin
          lServer.ReleaseBody;
          Check.IsTrue(lResponse.Success);
          Check.AreEqual(lResponse.GetContentAsStringSynchronous, lServer.Body);
        end;
    end;

    method TestAsynchronousExceptionReferencesReturnedResponse;
    begin
      using lServer := new LoopbackHttpErrorServer(500) do
        using lFinished := new System.Threading.ManualResetEventSlim do begin
          var lRequest := lServer.CreateRequest;
          var lResponse: HttpResponse;
          Http.ExecuteRequest(lRequest, response -> begin
            lResponse := response;
            lServer.ReleaseBody;
            lFinished.Set;
          end);
          Check.IsTrue(lFinished.Wait(5000));
          Check.IsNotNil(lResponse);
          using lResponse do begin
            Check.IsFalse(lResponse.Success);
            Check.IsTrue(lResponse.Exception is HttpException);
            if not (lResponse.Exception is HttpException) then
              exit;
            var lException := lResponse.Exception as HttpException;
            Check.AreEqual(lException.Request, lRequest);
            Check.AreEqual(lException.Response, lResponse);
            if not assigned(lException.Response) then
              exit;
            Check.AreEqual(lException.Code, 500);
            Check.AreEqual(lException.Response.GetContentAsJsonSynchronous['error']['message'].StringValue, 'declined');
          end;
        end;
    end;

  end;
  {$ENDIF}

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
