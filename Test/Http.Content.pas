namespace RemObjects.Elements.RTL.Tests;

{$IF ECHOES OR DARWIN}
uses
  RemObjects.Elements.EUnit,
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Units;

type
  HttpContentFailureTests = public class(Test)
  private

    method FailedResponse: not nullable HttpResponse;
    begin
      var lRequest := new HttpRequest('rtl2-http-content-test://unsupported/');
      lRequest.Timeout := 2 Seconds;
      var lFinished := new &Event;
      var lResponse: nullable HttpResponse;
      // The transport rejects the scheme before receiving headers or a body. No network is contacted.
      Http.ExecuteRequest(lRequest, response -> begin
        lResponse := response;
        lFinished.Set;
      end);
      var lCompleted := lFinished.WaitFor(5 Seconds);
      if not lCompleted then
        lRequest.Cancel;
      Check.IsTrue(lCompleted, 'A transport failure must still deliver the response callback.');
      Check.IsNotNil(lResponse);
      if not assigned(lResponse) then
        raise new Exception('The failed HTTP response was not delivered.');
      Check.IsFalse(lResponse.Success);
      Check.IsNotNil(lResponse.Exception);
      result := lResponse as not nullable;
    end;

    method CheckFailure<T>(aResponse: not nullable HttpResponse; aRead: not nullable block(aCallback: not nullable HttpContentResponseBlock<T>));
    begin
      var lFinished := new &Event;
      var lContent: nullable HttpResponseContent<T>;
      var lCalls := 0;
      aRead(content -> begin
        lContent := content;
        inc(lCalls);
        lFinished.Set;
      end);
      Check.IsTrue(lFinished.WaitFor(5 Seconds), 'Missing bodies must report a content failure.');
      Check.AreEqual(1, lCalls);
      Check.IsNotNil(lContent);
      if not assigned(lContent) then
        raise new Exception('The failed HTTP content was not delivered.');
      Check.IsFalse(lContent.Success);
      Check.IsFalse(assigned(lContent.Content));
      Check.AreEqual(aResponse.Exception, lContent.Exception);
    end;

  public

    // A failed request has no binary data; preserve its exception instead of constructing a binary from nil.
    method BinaryFailureReportsOriginalException;
    begin
      var lResponse := FailedResponse;
      CheckFailure<ImmutableBinary>(lResponse, callback -> lResponse.GetContentAsBinary(callback));
    end;

    // String readers must receive the same single failure callback through the shared binary reader.
    method StringFailureReportsOriginalException;
    begin
      var lResponse := FailedResponse;
      CheckFailure<String>(lResponse, callback -> lResponse.GetContentAsString(Encoding.UTF8, callback));
    end;

    // A missing transport body is a transport failure, not a JSON parsing attempt or invented empty document.
    method JsonFailureReportsOriginalException;
    begin
      var lResponse := FailedResponse;
      CheckFailure<JsonDocument>(lResponse, callback -> lResponse.GetContentAsJson(callback));
    end;

    // A consumer exception must propagate once; it must not be mistaken for a second content-read failure.
    method ContentCallbackExceptionIsNotRetried;
    begin
      var lResponse := FailedResponse;
      var lException := new Exception('Callback failure');
      var lCalls := 0;
      var lCaught: nullable Exception;
      try
        lResponse.GetContentAsBinary(content -> begin
          inc(lCalls);
          raise lException;
        end);
      except
        on E: Exception do
          lCaught := E;
      end;
      Check.AreEqual(lException, lCaught);
      Check.AreEqual(1, lCalls);
    end;

    // XML readers preserve transport errors without throwing an exception outside their callback contract.
    method XmlFailureReportsOriginalException;
    begin
      var lResponse := FailedResponse;
      CheckFailure<XmlDocument>(lResponse, callback -> lResponse.GetContentAsXml(callback));
    end;

  end;
{$ENDIF}

end.
