namespace RemObjects.Elements.RTL;

{$IF ECHOES}
type
  Foundation = assembly class
  public

    const FoundationLib = "/System/Library/Frameworks/Foundation.framework/Versions/Current/Foundation";

    const COPYFILE_CLONE = 1 shl 24;

    [System.Runtime.InteropServices.DllImport(FoundationLib)]
    class method copyfile(aFrom: String; aTo: String; aState: IntPtr; aFlags: UInt32): Integer; external;

    [System.Runtime.InteropServices.DllImport(FoundationLib)]
    class method  fcopyfile(aFrom: Integer; aTo: Integer; aState: IntPtr; aFlags: UInt32): Integer; external;
  end;
{$ENDIF}

end.