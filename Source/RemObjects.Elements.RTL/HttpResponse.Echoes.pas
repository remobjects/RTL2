namespace RemObjects.Elements.RTL;

{$IF ECHOES}
type
  {$IF HTTPCLIENT}
  PlatformResponse = System.Net.Http.HttpResponseMessage;
  {$ELSE}
  PlatformResponse = HttpWebResponse;
  {$ENDIF}

  HttpResponse = public partial class
  assembly
    var Response: PlatformResponse;

    constructor(aResponse: PlatformResponse);
    begin
      Response := aResponse;
      Code := Int32(aResponse.StatusCode);
      var lHeaders := new Dictionary<String,String>;
      {$IF HTTPCLIENT}
      for each k in aResponse.Headers do
        lHeaders[k.Key] := k.Value.JoinedString(", ");
      {$ELSE}
      for each k in aResponse.Headers:AllKeys do
        lHeaders[k.ToString] := aResponse.Headers[k];
      {$ENDIF}
      Headers := lHeaders;
    end;

    constructor(aResponse: PlatformResponse; aException: Exception);
    begin
      constructor(aResponse);
      Exception := aException;
    end;
    //{$ELSE}
    //var Response: PlatformResponse;
    //constructor(aResponse: PlatformResponse);
    //begin
      //Response := aResponse;
      //Code := Int32(aResponse.StatusCode);
      //Headers := new Dictionary<String,String>();
    //end;

    //constructor(aResponse: PlatformResponse; aException: Exception);
    //begin
      //constructor(aResponse);
      //Exception := aException;
    //end;
    //{$ENDIF HTTPCLIENT}

  end;

{$ENDIF}
end.