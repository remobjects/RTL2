namespace RemObjects.Elements.RTL;

type
  /*{$IF ECHOES}
  PlatformException = public System.Exception;
  {$ELSEIF TOFFEE}
  PlatformException = public Foundation.NSException;
  {$ELSEIF COOPER}
  PlatformException = public java.lang.Exception;
  {$ELSEIF ISLAND}
  PlatformException = public RemObjects.Elements.System.Exception;
  {$ENDIF}*/

  RTLException = public class(Exception)
  public

    constructor;
    begin
      constructor("Exception");
    end;

    constructor(aMessage: String);
    begin
      {$IF TOFFEE}
      result := inherited constructor withName('Exception') reason(aMessage) userInfo(nil);
      {$ELSE}
      inherited constructor(aMessage);
      {$ENDIF}
    end;

    constructor(aFormat: String; params aParams: array of Object);
    begin
      constructor(String.Format(aFormat, aParams));
    end;

    {$IF TOFFEE}
    constructor withError(aError: Foundation.NSError);
    begin
      result := inherited constructor withName('Exception') reason(aError.description) userInfo(nil);
    end;

    property Message: String read reason;
    {$ELSEIF ISLAND AND DARWIN}
    constructor withError(aError: Foundation.NSError);
    begin
      inherited constructor(aError.description);
    end;

    constructor withNSException(aException: Foundation.NSException);
    begin
      inherited constructor(aException.description);
    end;
    {$ENDIF}

  end;

  {$IF COOPER OR (TOFFEE AND NOT ISLAND)}
  InvalidCastException = public class(RTLException)
  end;
  {$ENDIF}

  {$IF COOPER OR TOFFEEV1}
  IndexOutOfRangeException = public class(RTLException)
  end;
  {$ENDIF}

  Exception_Helpers = public extension class(Exception)
  public
    {$IF TOFFEE}
    property StackTrace: String read (callStackSymbols as ImmutableList<String>).JoinedString(Environment.LineBreak);
    {$ENDIF}

    constructor (aMessage: PlatformString; params aParams: array of Object);
    begin
      result := new Exception(PlatformString(String.Format(aMessage, aParams)));
    end;

    {$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
    property CallStack: ImmutableList<String> read begin
      {$IF COOPER}
      result := StackTrace.Select(a -> a.toString()).ToList();
      {$ELSEIF ECHOES}
      result := (StackTrace.Replace(#13, "") as String).Split(#10);
      {$ELSEIF ISLAND}
      result := new ImmutableList<String>("Exception call stack not available."); {$WARNING Not implemented/supported for Island yet}
      {$ELSEIF TOFFEE}
      result := callstackSymbols;
      {$ENDIF}
    end;

  end;

  {$IF COOPER}NotImplementedException = public class(RTLException);
  {$ELSEIF TOFFEE}NotImplementedException = public class(RTLException);
  {$ELSEIF ECHOES}NotImplementedException = public System.NotImplementedException;
  {$ELSEIF ISLAND}NotImplementedException = public RemObjects.Elements.System.NotImplementedException;
  {$ENDIF}

  {$IF COOPER}NotSupportedException = public java.lang.UnsupportedOperationException;
  {$ELSEIF TOFFEE}NotSupportedException = public class(RTLException);
  {$ELSEIF ECHOES}NotSupportedException = public System.NotSupportedException;
  {$ELSEIF ISLAND}NotSupportedException = public RemObjects.Elements.System.NotSupportedException;
  {$ENDIF}

  {$IF COOPER}ArgumentException = public java.lang.IllegalArgumentException;
  {$ELSEIF TOFFEE}ArgumentException = public class(RTLException);
  {$ELSEIF ECHOES}ArgumentException = public System.ArgumentException;
  {$ELSEIF ISLAND}ArgumentException = public RemObjects.Elements.System.ArgumentException;
  {$ENDIF}

  UrlException = public class (RTLException);
  UrlParserException = public class(UrlException);
  ConversionException = public class(RTLException);

  ArgumentNullException = public class(ArgumentException)
  public

    constructor;
    begin
      inherited constructor(RTLErrorMessages.ARG_NULL_ERROR2)
    end;

    constructor(aMessage: String);
    begin
      inherited constructor(String.Format(RTLErrorMessages.ARG_NULL_ERROR, aMessage))
    end;

    class method RaiseIfNil(Value: Object; Name: String);
    begin
      if Value = nil then
        raise new ArgumentNullException(Name);
    end;

  end;

  ArgumentOutOfRangeException = public class(ArgumentException)
  public

    constructor;
    begin
      inherited constructor(RTLErrorMessages.ARG_OUT_OF_RANGE_ERROR2)
    end;

    constructor(aMessage: String);
    begin
      inherited constructor(String.Format(RTLErrorMessages.ARG_OUT_OF_RANGE_ERROR, aMessage))
    end;

    constructor(aFormat: String; params aParams: array of Object);
    begin
      inherited constructor(String.Format(aFormat, aParams));
    end;

  end;

  FormatException = public class(RTLException)
  public

    constructor();
    begin
      inherited constructor(RTLErrorMessages.FORMAT_ERROR);
    end;

    constructor(aMessage: String);
    begin
      inherited constructor(aMessage);
    end;

    constructor(aFormat: String; params aParams: array of Object);
    begin
      inherited constructor(aFormat, aParams);
    end;

  end;

  IOException = public class(RTLException);

  HttpException = public class(RTLException)
  assembly

    constructor(aMessage: String; aRequest: nullable HttpRequest /*:= nil*/; aResponse: nullable HttpResponse := nil);
    begin
      inherited constructor(aMessage);
      Request := aRequest;
      Response := aResponse;
    end;

    constructor(aCode: Integer; aRequest: nullable HttpRequest/* := nil*/);
    begin
      inherited constructor(String.Format("Unable to complete request, error code: {0}", aCode));
      Request := aRequest;
      fCode := aCode;
    end;

  private
    fCode: nullable Integer;

  public
    property Request: nullable HttpRequest; readonly;
    property Response: nullable HttpResponse; readonly;
    property Code: Integer read coalesce(Response:Code, fCode);
  end;

  FileNotFoundException = public class (RTLException)
  public

    property FileName: String read write; readonly;

    constructor (aFileName: String);
    begin
      inherited constructor (RTLErrorMessages.FILE_NOTFOUND, aFileName);
      FileName := aFileName;
    end;

  end;

  StackEmptyException = public class (RTLException)
  public

    constructor;
    begin
      inherited constructor(RTLErrorMessages.COLLECTION_EMPTY);
    end;

  end;

  QueueEmptyException = public class(StackEmptyException);

  InvalidOperationException = public class (RTLException);

  KeyNotFoundException = public class (RTLException)
  public

    constructor;
    begin
      inherited constructor(RTLErrorMessages.KEY_NOTFOUND);
    end;

  end;

  /*AppContextMissingException = public class (RTLException)
  public

    class method RaiseIfMissing;
    begin
      if Environment.ApplicationContext = nil then
        raise new AppContextMissingException(RTLErrorMessages.APP_CONTEXT_MISSING);
    end;

  end;*/

  {$IF TOFFEE}
  NSErrorException = public class(RTLException)
  public

    constructor(Error: Foundation.NSError);
    begin
      inherited constructor(Error.localizedDescription);
    end;

  end;
  {$ENDIF}

  RTLErrorMessages = /*unit*/ assembly static class
  public
    class const FORMAT_ERROR = "Input string was not in a correct format";
    class const OUT_OF_RANGE_ERROR = "Range ({0},{1}) exceeds data length {2}";
    class const NEGATIVE_VALUE_ERROR = "{0} can not be negative";
    class const ARG_OUT_OF_RANGE_ERROR = "{0} argument was out of range of valid values.";
    class const ARG_OUT_OF_RANGE_ERROR2 = "Argument was out of range of valid values.";
    class const ARG_NULL_ERROR = "Argument {0} can not be nil";
    class const ARG_NULL_ERROR2 = "Argument can not be nil";
    class const TYPE_RANGE_ERROR = "Specified value exceeds range of {0}";
    class const COLLECTION_EMPTY = "Collection is empty";
    class const KEY_NOTFOUND = "Entry with specified key does not exist";
    class const KEY_EXISTS = "An element with the same key already exists in the dictionary";

    class const FILE_EXISTS = "File {0} already exists";
    class const FILE_NOTFOUND = "File {0} not found";
    class const FILE_WRITE_ERROR = "File {0} can not be written";
    class const FILE_READ_ERROR = "File {0} can not be read";
    class const FOLDER_EXISTS = "Folder {0} already exists";
    class const FOLDER_NOTFOUND = "Folder {0} not found";
    class const FOLDER_CREATE_ERROR = "Unable to create folder {0}";
    class const FOLDER_DELETE_ERROR = "Unable to delete folder {0}";
    class const IO_RENAME_ERROR = "Unable to reanme {0} to {1}";

    class const APP_CONTEXT_MISSING = "Environment.ApplicationContext is not set.";
    class const NOTSUPPORTED_ERROR = "{0} is not supported on current platform";
  end;

end.