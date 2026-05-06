namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.EUnit,
  RemObjects.Elements.RTL;

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

    method TestCancelOnFreshRequestIsNoOp;
    begin
      // Calling Cancel() before a request is started should not raise
      var request := new HttpRequest(Url.UrlWithString('https://example.com'));
      Check.That( () -> request.Cancel() ).DoesNotRaise();
    end;

    method TestCancelCalledTwiceIsNoOp;
    begin
      // Cancel() must be idempotent — second call should not raise or double-free
      var request := new HttpRequest(Url.UrlWithString('https://example.com'));
      request.Cancel();
      Check.That( () -> request.Cancel() ).DoesNotRaise();
    end;

    method TestRequestRemainsUsableAfterCancel;
    begin
      // Properties on the request should still be readable after Cancel()
      var request := new HttpRequest(Url.UrlWithString('https://example.com'));
      request.Cancel();
      Check.AreEqual(request.Url.ToString, 'https://example.com');
      Check.AreEqual(request.Timeout, 10.0);
    end;

  end;

end.
