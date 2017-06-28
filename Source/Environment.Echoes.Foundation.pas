namespace RemObjects.Elements.RTL;

{$IF ECHOES}
type
  Foundation = assembly class
  public

    const FoundationLib = "/System/Library/Frameworks/Foundation.framework/Versions/Current/Foundation";

    const COPYFILE_ACL          = 1 shl 0;
    const COPYFILE_STAT         = 1 shl 1;
    const COPYFILE_XATTR        = 1 shl 2;
    const COPYFILE_DATA         = 1 shl 3;

    const COPYFILE_SECURITY     = COPYFILE_STAT or COPYFILE_ACL;
    const COPYFILE_METADATA     = COPYFILE_SECURITY or COPYFILE_XATTR;
    const COPYFILE_ALL          = COPYFILE_METADATA or COPYFILE_DATA;

    const COPYFILE_RECURSIVE    = 1 shl 15;
    const COPYFILE_CHECK        = 1 shl 16; /* return flags for xattr or acls if set */
    const COPYFILE_EXCL         = 1 shl 17; /* fail if destination exists */
    const COPYFILE_NOFOLLOW_SRC = 1 shl 18; /* don't follow if source is a symlink */
    const COPYFILE_NOFOLLOW_DST = 1 shl 19; /* don't follow if dst is a symlink */
    const COPYFILE_MOVE         = 1 shl 20; /* unlink src after copy */
    const COPYFILE_UNLINK       = 1 shl 21; /* unlink dst before copy */
    const COPYFILE_NOFOLLOW     = COPYFILE_NOFOLLOW_SRC or COPYFILE_NOFOLLOW_DST;

    const COPYFILE_PACK         = 1 shl 22;
    const COPYFILE_UNPACK       = 1 shl 23;

    const COPYFILE_CLONE        = 1 shl 24;
    const COPYFILE_CLONE_FORCE  = 1 shl 25;

    const COPYFILE_VERBOSE      = 1 shl 30;

    [System.Runtime.InteropServices.DllImport(FoundationLib)]
    class method copyfile(aFrom: String; aTo: String; aState: IntPtr; aFlags: UInt32): Integer; external;

    [System.Runtime.InteropServices.DllImport(FoundationLib)]
    class method  fcopyfile(aFrom: Integer; aTo: Integer; aState: IntPtr; aFlags: UInt32): Integer; external;
  end;
{$ENDIF}

end.