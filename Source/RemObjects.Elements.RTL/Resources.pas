namespace RemObjects.Elements.RTL;

type
  {$IF COOPER}
  &Assembly = public Object;
  {$ELSEIF ECHOES}
  &Assembly = public System.Reflection.Assembly;
  {$ELSEIF ISLAND}
  &Assembly = public Object;
  {$ELSEIF TOFFEE}
  &Assembly = public Foundation.NSBundle;
  {$ENDIF}

  Resources = public class
  public

    method GetResource(aAssembly: nullable &Assembly := nil; aName: not nullable String): nullable Stream;
    begin
      if not assigned(aAssembly) then
        aAssembly := EntryAssembly;

      {$IF COOPER}
      {$ELSEIF ECHOES}
      //result := new WrappedPlatformStream(aAssembly:GetManifestResourceStream(aName));
      {$ELSEIF ISLAND}
      {$ELSEIF TOFFEE}
      //var lFileName := NSBundle.mainBundle.pathForResource(Path.ChangeExtension(aName, "")) ofType(aName.PathExtension);
      //if lFileName:FileExists then
        //result := new FileStream(lFileName);
      {$ENDIF}

    end;

    method GetImage(aAssembly: nullable &Assembly := nil; aName: not nullable String): nullable Stream;
    begin
      if not assigned(aAssembly) then
        aAssembly := EntryAssembly;

      {$IF COOPER}
      {$ELSEIF ECHOES}
      //result := new WrappedPlatformStream(aAssembly:GetManifestResourceStream(aName));
      {$ELSEIF ISLAND}
      {$ELSEIF TOFFEE}
      //var lFileName := NSBundle.mainBundle.pathForResource(Path.ChangeExtension(aName, "")) ofType(aName.PathExtension);
      //if lFileName:FileExists then
      //result := new FileStream(lFileName);
      {$ENDIF}

    end;

  private

    property EntryAssembly: &Assembly read begin
      {$IF COOPER}
      {$ELSEIF ECHOES}
      result := System.Reflection.Assembly.GetEntryAssembly;
      {$ELSEIF ISLAND}
      {$ELSEIF TOFFEE}
      result := Foundation.NSBundle.mainBundle;
      {$ENDIF}
    end;

  end;

end.