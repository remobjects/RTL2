namespace Elements.RTL;

type 
  Exception = public class({$IF TOFFEE}Foundation.NSException{$ELSE}Exception{$ENDIF})
  public
  
    constructor;
    begin
      constructor("Exception");
    end;
    
    constructor(aMessage: String);
    begin
      {$IF TOFFEE}
      inherited initWithName('Exception') reason(aMessage) userInfo(nil);
      {$ELSE}
      inherited constructor(aMessage);
      {$ENDIF}
    end;
    
    constructor(aFormat: String; params aParams: array of Object);
    begin
      constructor(String.Format(aFormat, aParams));
    end;

    {$IF TOFFEE}
    constructor withError(aError: NSError);
    begin
      inherited initWithName('Exception') reason(aError.description) userInfo(nil);
    end;
    
    property Message: String read reason;
    {$ENDIF}
    
  end;
  
  NotImplementedException = public class(Exception);

  NotSupportedException = public class (Exception);

  ArgumentException = public class (Exception);

  ArgumentNullException = public class(ArgumentException)
  public
  
    constructor(aMessage: String);
    begin
      inherited constructor(ErrorMessage.ARG_NULL_ERROR, aMessage)
    end;
    
    class method RaiseIfNil(Value: Object; Name: String);
    begin
      if Value = nil then
        raise new ArgumentNullException(Name);
    end;
    
  end;
  
  ArgumentOutOfRangeException = public class (ArgumentException);

  FormatException = public class(Exception);

  IOException = public class(Exception);

  /*HttpException = public class(SugarException)
  assembly
    constructor(aMessage: String; aResponse: nullable HttpResponse := nil);
    begin
      inherited constructor(aMessage);
      Response := aResponse;
    end;

  public
    property Response: nullable HttpResponse; readonly;   
  end;*/
  
  FileNotFoundException = public class (Exception)
  public
  
    property FileName: String read write; readonly;

    constructor (aFileName: String);
    begin
      inherited constructor (ErrorMessage.FILE_NOTFOUND, aFileName);
      FileName := aFileName;
    end;
    
  end;

  StackEmptyException = public class (Exception);

  InvalidOperationException = public class (Exception);

  KeyNotFoundException = public class (Exception)
  public
  
    constructor;
    begin
      inherited constructor(ErrorMessage.KEY_NOTFOUND);
    end;
    
  end;

  /*AppContextMissingException = public class (Exception)
  public
  
    class method RaiseIfMissing;
    begin
      if Environment.ApplicationContext = nil then
        raise new AppContextMissingException(ErrorMessage.APP_CONTEXT_MISSING);
    end;
    
  end;*/

  {$IF TOFFEE}
  NSErrorException = public class(Exception)
  public
  
    constructor(Error: Foundation.NSError);
    begin
      inherited constructor(Error.localizedDescription);
    end;
    
  end;
  {$ENDIF}

  ErrorMessage = /*unit*/ assembly static class
  public
    class const FORMAT_ERROR = "Input string was not in a correct format";
    class const OUT_OF_RANGE_ERROR = "Range ({0},{1}) exceeds data length {2}";
    class const NEGATIVE_VALUE_ERROR = "{0} can not be negative";
    class const ARG_OUT_OF_RANGE_ERROR = "{0} argument was out of range of valid values.";
    class const ARG_NULL_ERROR = "Argument {0} can not be nil";
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
