namespace RemObjects.Elements.RTL;

{$IF ECHOES OR COOPER OR ((MACOS OR WINDOWS OR LINUX) AND NOT (MACCATALYST OR ANDROID))}

uses
  {$IF TOFFEE OR ISLAND}rtl,{$ENDIF}
  RemObjects.Elements.System;

type
  {$IF COOPER}
  TerminalQuery = public block: not nullable Int32;
  {$ENDIF}

  // A frame captures the dimensions used for drawing. The event loop checks
  // them again before displaying it, since a resize can occur during rendering.
  TerminalFrame = public sealed class
  assembly
    field Buffer: not nullable StringBuilder := new StringBuilder;
    constructor(aRows, aColumns: Integer);
    begin
      Rows := aRows;
      Columns := aColumns;
    end;
  public
    property Rows: Integer; readonly;
    property Columns: Integer; readonly;

    method Clear;
    begin
      Buffer.Append(#27'[2J');
    end;

    // Draw a row of single-cell text, clipping to the viewport. Position
    // individual cells to suppress auto-wrap when a resize shrinks the window.
    method WriteLine(aRow: Integer; aText: not nullable String);
    begin
      if (aRow < 1) or (aRow > Rows) then exit;
      Buffer.Append(#27 + $'[{aRow};1H');
      var lLength := length(aText);
      if lLength < Columns then Buffer.Append(#27'[K');
      if lLength > Columns then lLength := Columns;
      for lColumn: Integer := 1 to lLength do begin
        if lColumn > 1 then Buffer.Append(#27 + $'[{lColumn}G');
        Buffer.Append(aText[lColumn-1]);
      end;
      Buffer.Append(#13);
    end;
  end;

  {$IF ISLAND AND WINDOWS}
  // ReadConsoleInputW writes a 20-byte INPUT_RECORD. Its key event starts
  // at byte four and bKeyDown occupies a full Win32 BOOL before the repeat
  // count, virtual key, scan code and UTF-16 character.
  ConsoleKeyRecord = record
    field EventType, Padding: UInt16;
    field KeyDown: Int32;
    field RepeatCount, VirtualKey, ScanCode, Character: UInt16;
    field ControlState: UInt32;
  end;
  {$ENDIF}

  // Owns the process console while a caller is reading keys or drawing a full-screen view.
  Terminal = public static class
  private

    {$IF ECHOES}
    class var fOriginalControlC: Boolean;
    class var fWindowsOutput: IntPtr;
    class var fWindowsMode: UInt32;

    // Windows interprets ANSI cursor sequences only when this output flag is set.
    [System.Runtime.InteropServices.DllImport('kernel32.dll')]
    class method GetStdHandle(aKind: Int32): IntPtr; external;
    [System.Runtime.InteropServices.DllImport('kernel32.dll')]
    class method GetConsoleMode(aHandle: IntPtr; out aMode: UInt32): Boolean; external;
    [System.Runtime.InteropServices.DllImport('kernel32.dll')]
    class method SetConsoleMode(aHandle: IntPtr; aMode: UInt32): Boolean; external;
    {$ELSEIF COOPER}
    class var fRows, fColumns, fRead: TerminalQuery;
    class var fWriter: java.io.PrintWriter;
    {$ELSEIF WINDOWS}
    class var fIn, fOut: rtl.HANDLE;
    class var fInputMode, fOutputMode: rtl.DWORD;

    class method IsConsoleStream(aHandle: rtl.HANDLE): Boolean;
    begin
      if rtl.GetFileType(aHandle) ≠ rtl.FILE_TYPE_CHAR then
        exit false;
      var lMode: rtl.DWORD;
      exit (Integer(rtl.GetConsoleMode(aHandle, @lMode)) ≠ 0) or (rtl.GetLastError() = rtl.ERROR_ACCESS_DENIED);
    end;

    class method OpenConsoleDevice(aName: RemObjects.Elements.System.String): rtl.HANDLE;
    begin
      exit rtl.CreateFileW(aName.FirstChar, rtl.GENERIC_READ or rtl.GENERIC_WRITE,
                           rtl.FILE_SHARE_READ or rtl.FILE_SHARE_WRITE, nil, rtl.OPEN_EXISTING, 0, nil);
    end;
    {$ELSE}
    // libc fills this aligned buffer with the host's termios structure.
    class var fOriginal: array[0..31] of UInt64;
    {$ENDIF}
    class var fEscapeState: Integer;
    class var fOpen: Boolean;

    class method OpenDevice: Boolean;
    begin
      {$IF ECHOES}
      if System.Console.IsInputRedirected or System.Console.IsOutputRedirected then
        exit false;
      if System.Environment.OSVersion.Platform = System.PlatformID.Win32NT then begin
        fWindowsOutput := GetStdHandle(-11);
        if not GetConsoleMode(fWindowsOutput, out fWindowsMode) or not SetConsoleMode(fWindowsOutput, fWindowsMode or 4) then
          exit false;
      end;
      try
        fOriginalControlC := System.Console.TreatControlCAsInput;
        System.Console.TreatControlCAsInput := true;
      except
        if System.Environment.OSVersion.Platform = System.PlatformID.Win32NT then
          SetConsoleMode(fWindowsOutput, fWindowsMode);
        raise;
      end;
      exit true;
      {$ELSEIF COOPER}
      // Raw input on the JVM requires an application-supplied console backend.
      exit false;
      {$ELSEIF WINDOWS}
      // A shell can attach read-only input and write-only output handles.
      // Console mode changes need both permissions. Reopen the devices only
      // after checking that the streams belong to a character device.
      if not IsConsoleStream(rtl.GetStdHandle(rtl.STD_INPUT_HANDLE)) or not IsConsoleStream(rtl.GetStdHandle(rtl.STD_OUTPUT_HANDLE)) then
        exit false;
      fIn := OpenConsoleDevice('CONIN$');
      fOut := OpenConsoleDevice('CONOUT$');
      var lOpened := false;
      try
        if (Integer(rtl.GetConsoleMode(fIn, @fInputMode)) = 0) or (Integer(rtl.GetConsoleMode(fOut, @fOutputMode)) = 0) then
          exit false;
        if Integer(rtl.SetConsoleMode(fOut, fOutputMode or 5)) = 0 then
          exit false;
        if Integer(rtl.SetConsoleMode(fIn, fInputMode and not UInt32(7))) = 0 then begin
          rtl.SetConsoleMode(fOut, fOutputMode);
          exit false;
        end;
        lOpened := true;
        exit true;
      finally
        if not lOpened then begin
          rtl.CloseHandle(fIn);
          rtl.CloseHandle(fOut);
        end;
      end;
      {$ELSE}
      if (isatty(0) ≠ 1) or (isatty(1) ≠ 1) or (tcgetattr(0, @fOriginal[0]) ≠ 0) then
        exit false;
      var lRaw: array[0..31] of UInt64;
      memcpy(@lRaw[0], @fOriginal[0], sizeOf(lRaw));
      cfmakeraw(@lRaw[0]);
      exit tcsetattr(0, 2, @lRaw[0]) = 0;
      {$ENDIF}
    end;

  public
    const EndOfInput = -1;
    const Timeout = -2;
    const UpArrow = -3;
    const DownArrow = -4;
    const RightArrow = -5;
    const LeftArrow = -6;

    {$IF COOPER}
    // Java applications supply raw input and viewport dimensions from their
    // console backend. aRead returns an input code, Timeout while idle, or
    // EndOfInput. The caller owns the writer and restores the raw console mode.
    class method RunFullScreen(aWriter: not nullable java.io.PrintWriter;
                               aRows, aColumns, aRead: not nullable TerminalQuery;
                               aBody: not nullable block): Boolean;
    begin
      locking typeOf(Terminal) do begin
        if fOpen or assigned(fWriter) then exit false;
        fWriter := aWriter;
        fRows := aRows;
        fColumns := aColumns;
        fRead := aRead;
        fOpen := true;
        fEscapeState := 0;
      end;
      try
        RunScreenBody(aBody);
      finally
        locking typeOf(Terminal) do begin
          fWriter := nil;
          fRows := nil;
          fColumns := nil;
          fRead := nil;
          fOpen := false;
        end;
      end;
      exit true;
    end;
    {$ENDIF}

    // Run an interactive alternate-screen session, restoring the cursor and
    // the original console mode when the callback returns or raises.
    class method RunFullScreen(aBody: not nullable block): Boolean;
    begin
      if not Open then exit false;
      try
        RunScreenBody(aBody);
      finally
        Close;
      end;
      exit true;
    end;

  private
    class method RunScreenBody(aBody: not nullable block);
    begin
      try
        Send(#27'[?1049h'#27'[?25l');
        aBody();
      finally
        Send(#27'[?25h'#27'[?1049l');
      end;
    end;

  public
    // Ask the caller to draw on entry and after a resize while waiting for
    // input. Return the next key, or EndOfInput when the input closes.
    class method ReadKey(aDraw: not nullable block(aFrame: not nullable TerminalFrame)): Integer;
    begin
      var lDrawnRows := -1;
      var lDrawnColumns := -1;
      loop begin
        var lRows, lColumns: Integer;
        if not Size(out lRows, out lColumns) then raise new RTLException('Could not read terminal size.');
        if (lDrawnRows ≠ lRows) or (lDrawnColumns ≠ lColumns) then begin
          var lFrame := new TerminalFrame(lRows, lColumns);
          aDraw(lFrame);
          if not Size(out lDrawnRows, out lDrawnColumns) then raise new RTLException('Could not read terminal size.');
          if (lDrawnRows = lRows) and (lDrawnColumns = lColumns) then
            Send(lFrame.Buffer.ToString as not nullable)
          else begin
            lDrawnRows := -1;
            continue;
          end;
        end;
        result := ReadKey;
        if result ≠ Timeout then exit;
      end;
    end;

    // A terminal session owns the process console until Close restores its settings.
    class method Open: Boolean;
    begin
      locking typeOf(Terminal) do begin
        if fOpen then exit false;
        fOpen := OpenDevice;
        fEscapeState := 0;
        exit fOpen;
      end;
    end;

    class method Close;
    begin
      locking typeOf(Terminal) do begin
        if not fOpen then exit;
        try
          RestoreDevice;
        finally
          fOpen := false;
        end;
      end;
    end;

  private
    class method RestoreDevice;
    begin
      {$IF ECHOES}
      try
        System.Console.TreatControlCAsInput := fOriginalControlC;
      finally
        if System.Environment.OSVersion.Platform = System.PlatformID.Win32NT then
          SetConsoleMode(fWindowsOutput, fWindowsMode);
      end;
      {$ELSEIF COOPER}
      // The caller owns the console streams and restores the device mode.
      {$ELSEIF WINDOWS}
      rtl.SetConsoleMode(fIn, fInputMode);
      rtl.SetConsoleMode(fOut, fOutputMode);
      rtl.CloseHandle(fIn);
      rtl.CloseHandle(fOut);
      {$ELSE}
      if tcsetattr(0, 2, @fOriginal[0]) ≠ 0 then
        raise new RTLException('Could not restore terminal settings. Run stty sane if needed.');
      {$ENDIF}
    end;

  public
    class method Size(out aRows, aColumns: Integer): Boolean;
    begin
      {$IF ECHOES}
      aRows := System.Console.WindowHeight;
      aColumns := System.Console.WindowWidth;
      {$ELSEIF COOPER}
      aRows := fRows();
      aColumns := fColumns();
      {$ELSEIF WINDOWS}
      var lInfo: rtl.CONSOLE_SCREEN_BUFFER_INFO;
      if Integer(GetConsoleScreenBufferInfo(fOut, @lInfo)) = 0 then
        exit false;
      aRows := lInfo.srWindow.Bottom - lInfo.srWindow.Top + 1;
      aColumns := lInfo.srWindow.Right - lInfo.srWindow.Left + 1;
      {$ELSE}
      var lSize: array[0..3] of UInt16;
      if ioctl(1, {$IF LINUX}$5413{$ELSE}$40087468{$ENDIF}, @lSize[0]) ≠ 0 then
        exit false;
      aRows := lSize[0];
      aColumns := lSize[1];
      {$ENDIF}
      exit true;
    end;

    class method Send(aText: not nullable String);
    begin
      {$IF ECHOES}
      System.Console.Write(aText);
      {$ELSEIF COOPER}
      fWriter.print(aText);
      fWriter.flush;
      {$ELSEIF WINDOWS}
      var lWritten: rtl.DWORD;
      if Integer(rtl.WriteConsoleW(fOut, (aText as RemObjects.Elements.System.String).FirstChar, length(aText), @lWritten, nil)) = 0 then
        raise new RTLException('Could not write to the terminal.');
      {$ELSE}
      var lBytes := Encoding.UTF8.GetBytes(aText);
      var lOffset := 0;
      while lOffset < length(lBytes) do begin
        var lWritten := rtl.write(1, @lBytes[lOffset], length(lBytes) - lOffset);
        if lWritten ≤ 0 then
          raise new RTLException('Could not write to the terminal.');
        lOffset := lOffset + Integer(lWritten);
      end;
      {$ENDIF}
    end;

  private
    class method ReadInput: Integer;
    begin
      {$IF ECHOES}
      if not System.Console.KeyAvailable then begin
        System.Threading.Thread.Sleep(100);
        exit -2;
      end;
      var lKey := System.Console.ReadKey(true);
      case lKey.Key of
        System.ConsoleKey.UpArrow: exit UpArrow;
        System.ConsoleKey.DownArrow: exit DownArrow;
        System.ConsoleKey.RightArrow: exit RightArrow;
        System.ConsoleKey.LeftArrow: exit LeftArrow;
      else
        exit ord(lKey.KeyChar);
      end;

      {$ELSEIF COOPER}
      exit fRead();
      {$ELSEIF WINDOWS}
      if rtl.WaitForSingleObject(fIn, 100) = rtl.WAIT_TIMEOUT then
        exit -2;
      var lEvent: ConsoleKeyRecord;
      var lCount: rtl.DWORD;
      if Integer(rtl.ReadConsoleInputW(fIn, ^rtl.INPUT_RECORD(@lEvent), 1, @lCount)) = 0 then
        exit -1;
      if (lCount = 0) or (lEvent.EventType ≠ 1) or (lEvent.KeyDown = 0) then
        exit -2;
      case lEvent.VirtualKey of
        rtl.VK_UP: exit UpArrow;
        rtl.VK_DOWN: exit DownArrow;
        rtl.VK_RIGHT: exit RightArrow;
        rtl.VK_LEFT: exit LeftArrow;
      else
        exit lEvent.Character;
      end;

      {$ELSE}
      var lPoll: PollDescriptor;
      lPoll.Descriptor := 0;
      lPoll.Events := 1;
      var lReady := poll(@lPoll, 1, 100);
      if lReady = 0 then
        exit -2;
      if lReady < 0 then begin
        if ({$IF LINUX}__errno_location{$ELSE}__error{$ENDIF})^ = 4 then
          exit -2;
        exit -1;
      end;
      var lByte: Byte;
      if rtl.read(0, @lByte, 1) ≠ 1 then
        exit -1;
      exit lByte;
      {$ENDIF}
    end;

  public
    // Read an input code or a named arrow key. Timeout allows an idle client
    // to poll the window size. Keep partial escape sequences across timeouts.
    class method ReadKey: Integer;
    begin
      loop begin
        var lKey := ReadInput;
        if lKey < 0 then exit lKey;
        if lKey = 27 then begin
          fEscapeState := 1;
          continue;
        end;
        case fEscapeState of
          1: begin
            fEscapeState := 0;
            if (lKey = ord('[')) or (lKey = ord('O')) then begin
              fEscapeState := 2;
              continue;
            end;
          end;
          2: begin
            if (lKey ≥ $20) and (lKey ≤ $3f) then continue;
            fEscapeState := 0;
            case lKey of
              ord('A'): exit UpArrow;
              ord('B'): exit DownArrow;
              ord('C'): exit RightArrow;
              ord('D'): exit LeftArrow;
            end;
            continue;
          end;
        end;
        exit lKey;
      end;
    end;

  end;

{$IF ISLAND AND WINDOWS}
[DllImport('kernel32.dll')]
method GetConsoleScreenBufferInfo(aOutput: rtl.HANDLE; aInfo: ^rtl.CONSOLE_SCREEN_BUFFER_INFO): rtl.BOOL; external;
{$ENDIF}

{$IF TOFFEE OR (ISLAND AND NOT WINDOWS)}
type
  PollDescriptor = record
    field Descriptor: Int32;
    field Events, ReturnedEvents: Int16;
  end;

{$IF ISLAND}
const CRuntime = {$IF LINUX}'libc.so.6'{$ELSE}'/usr/lib/libSystem.B.dylib'{$ENDIF};
{$ENDIF}

{$IF ISLAND}[DllImport(CRuntime, EntryPoint := 'tcgetattr')]{$ENDIF}
method tcgetattr(aFd: Int32; aBuffer: ^UInt64): Int32; external;
{$IF ISLAND}[DllImport(CRuntime, EntryPoint := 'tcsetattr')]{$ENDIF}
method tcsetattr(aFd, aWhen: Int32; aBuffer: ^UInt64): Int32; external;
{$IF ISLAND}[DllImport(CRuntime, EntryPoint := 'cfmakeraw')]{$ENDIF}
method cfmakeraw(aBuffer: ^UInt64); external;
{$IF ISLAND}[DllImport(CRuntime, EntryPoint := 'poll')]{$ENDIF}
method poll(aDescriptors: ^PollDescriptor; aCount: {$IF LINUX}NativeUInt{$ELSE}UInt32{$ENDIF}; aTimeout: Int32): Int32; external;
{$IF LINUX}
{$IF ISLAND}[DllImport(CRuntime, EntryPoint := '__errno_location')]{$ENDIF}
method __errno_location: ^Int32; external;
{$ELSE}
{$IF ISLAND}[DllImport(CRuntime, EntryPoint := '__error')]{$ENDIF}
method __error: ^Int32; external;
{$ENDIF}
{$ENDIF}

{$ENDIF}

end.
