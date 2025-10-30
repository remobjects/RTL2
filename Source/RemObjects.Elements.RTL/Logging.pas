namespace RemObjects.Elements.RTL;

type
  ILogger = public interface
    method Log(aMessage: String);

    method Log(aMessage: String; params aParameters: array of Object);
    begin
      Log(String.Format(aMessage, aParameters));
    end;

    method Log(aObject: nullable Object);
    begin
      Log(coalesce(aObject:ToString(), "(null)"));
    end;

    method LogMultipleLines(aMessage: String);
    begin
      for each s in aMessage.Split(#10) do
        Log(s.Trim([#13]));
    end;
  end;

  SimpleLogger = partial class(ILogger)
  protected

    method Log(aMessage: String);
    begin
      {$IF DARWIN AND (MACOS OR SIMULATOR)}
      Foundation.NSLog("%@", aMessage)
      {$ELSEIF JAVA}
      if not fCheckedForAndroid then begin
        fCheckedForAndroid := true;
        fLogClass := &RemObjects.Elements.RTL.Reflection.Type.GetType("android.util.Log");
        fLogMethod := (fLogClass as RemObjects.Elements.RTL.Reflection.PlatformType):getDeclaredMethod("e", typeOf(String), typeOf(String));
      end;
      if assigned(fLogMethod) then
        fLogMethod.Invoke(fLogClass, coalesce(AppName, "Elements"), aMessage)
      else
        writeLn(aMessage);
      {$ELSE}
      writeLn(aMessage);
      {$ENDIF}
    end;

  private
    {$IF JAVA}
    var fCheckedForAndroid: Boolean;
    var fLogClass: &RemObjects.Elements.RTL.Reflection.Type;
    var fLogMethod: &RemObjects.Elements.RTL.Reflection.Method;
    {$ENDIF}
  end;

  WriteLnLogger = partial class(ILogger)
  protected

    method Log(aMessage: String);
    begin
      writeLn(aMessage);
    end;

  end;

  {$IF JAVA}
  IAndroidLogger = public interface
    property AppName: String;
  end;

  SimpleLogger = partial class(IAndroidLogger)
  public
    property AppName: String;

  end;
  {$ENDIF}

__Global = public static partial class
public
  class property Logger: ILogger := new SimpleLogger(); lazy;
end;

method Log(aMessage: String); public;
begin
  Logger:Log(aMessage);
end;

method Log(aFormat: String; params aParameters: array of Object); public;
begin
  Logger:Log(aFormat, aParameters);
end;

method Log(aObject: nullable Object);
begin
  Logger.Log(aObject);
end;

//

[Conditional("DEBUG")]
method DebugLog(aMessage: String); public;
begin
  Logger:Log(aMessage);
end;

[Conditional("DEBUG")]
method DebugLog(aFormat: String; params aParameters: array of Object); public;
begin
  Logger:Log(aFormat, aParameters);
end;

[Conditional("DEBUG")]
method DebugLog(aObject: nullable Object);
begin
  Logger.Log(aObject);
end;

end.