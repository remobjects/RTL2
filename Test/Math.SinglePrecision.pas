// Positive numerical regression guard promoted from IsotopeLab Single math checks.
// A fixed seed and exact representable-value distances make failures reproducible.
// The system-library reference is test-only; product math remains unchanged.
namespace Elements.RTL2.Tests.Shared;

uses RemObjects.Elements.RTL, RemObjects.Elements.EUnit;

{$IF ISLAND AND (DARWIN OR WINDOWS)}

type
  // Independent test reference: resolve system math through an explicit library handle.
  SystemMathReference = static class
  private
    {$IF ISLAND AND WINDOWS}
    fUCRT: rtl.HMODULE;
    {$ELSEIF ISLAND AND DARWIN}
    fLibM: ^Void;
    {$ENDIF}

    // Function pointer types
    type
      FuncD_D = public function(x: Double): Double;
      FuncDD_D = public function(x, y: Double): Double;

    // Function pointers
    class var fAbs: FuncD_D;
    class var fCeil: FuncD_D;
    class var fFloor: FuncD_D;
    class var fTrunc: FuncD_D;
    class var fRound: FuncD_D;
    class var fSin: FuncD_D;
    class var fCos: FuncD_D;
    class var fTan: FuncD_D;
    class var fAsin: FuncD_D;
    class var fAcos: FuncD_D;
    class var fAtan: FuncD_D;
    class var fAtan2: FuncDD_D;
    class var fSinh: FuncD_D;
    class var fCosh: FuncD_D;
    class var fTanh: FuncD_D;
    class var fExp: FuncD_D;
    class var fLog: FuncD_D;
    class var fLog10: FuncD_D;
    class var fPow: FuncDD_D;
    class var fFmod: FuncDD_D;
    class var fSqrt: FuncD_D;

  public
    class method Load: Boolean;
    begin
      {$IF ISLAND AND WINDOWS}
      fUCRT := rtl.LoadLibraryA('ucrtbase.dll');
      if fUCRT = nil then begin
        Console.WriteLine('ERROR: Could not load ucrtbase.dll');
        exit false;
      end;

      fAbs := FuncD_D(rtl.GetProcAddress(fUCRT, 'fabs'));
      fCeil := FuncD_D(rtl.GetProcAddress(fUCRT, 'ceil'));
      fFloor := FuncD_D(rtl.GetProcAddress(fUCRT, 'floor'));
      fTrunc := FuncD_D(rtl.GetProcAddress(fUCRT, 'trunc'));
      fRound := FuncD_D(rtl.GetProcAddress(fUCRT, 'round'));
      fSin := FuncD_D(rtl.GetProcAddress(fUCRT, 'sin'));
      fCos := FuncD_D(rtl.GetProcAddress(fUCRT, 'cos'));
      fTan := FuncD_D(rtl.GetProcAddress(fUCRT, 'tan'));
      fAsin := FuncD_D(rtl.GetProcAddress(fUCRT, 'asin'));
      fAcos := FuncD_D(rtl.GetProcAddress(fUCRT, 'acos'));
      fAtan := FuncD_D(rtl.GetProcAddress(fUCRT, 'atan'));
      fAtan2 := FuncDD_D(rtl.GetProcAddress(fUCRT, 'atan2'));
      fSinh := FuncD_D(rtl.GetProcAddress(fUCRT, 'sinh'));
      fCosh := FuncD_D(rtl.GetProcAddress(fUCRT, 'cosh'));
      fTanh := FuncD_D(rtl.GetProcAddress(fUCRT, 'tanh'));
      fExp := FuncD_D(rtl.GetProcAddress(fUCRT, 'exp'));
      fLog := FuncD_D(rtl.GetProcAddress(fUCRT, 'log'));
      fLog10 := FuncD_D(rtl.GetProcAddress(fUCRT, 'log10'));
      fPow := FuncDD_D(rtl.GetProcAddress(fUCRT, 'pow'));
      fFmod := FuncDD_D(rtl.GetProcAddress(fUCRT, 'fmod'));
      fSqrt := FuncD_D(rtl.GetProcAddress(fUCRT, 'sqrt'));

      if (fAbs = nil) or (fCeil = nil) or (fFloor = nil) or (fTrunc = nil) or (fRound = nil) or (fSin = nil) or (fCos = nil) or (fTan = nil) or (fAsin = nil) or (fAcos = nil) or (fAtan = nil) or (fAtan2 = nil) or (fSinh = nil) or (fCosh = nil) or (fTanh = nil) or (fExp = nil) or (fLog = nil) or (fLog10 = nil) or (fPow = nil) or (fFmod = nil) or (fSqrt = nil) then begin
        Console.WriteLine('ERROR: Could not load math functions from ucrtbase.dll');
        Unload;
        exit false;
      end;

      exit true;
      {$ELSEIF ISLAND AND DARWIN}
      // On macOS, load libSystem.B.dylib which contains the math functions
      fLibM := rtl.dlopen('/usr/lib/libSystem.B.dylib', rtl.RTLD_NOW);
      if fLibM = nil then begin
        Console.WriteLine('ERROR: Could not load libSystem.B.dylib');
        exit false;
      end;

      fAbs := FuncD_D(rtl.dlsym(fLibM, 'fabs'));
      fCeil := FuncD_D(rtl.dlsym(fLibM, 'ceil'));
      fFloor := FuncD_D(rtl.dlsym(fLibM, 'floor'));
      fTrunc := FuncD_D(rtl.dlsym(fLibM, 'trunc'));
      fRound := FuncD_D(rtl.dlsym(fLibM, 'round'));
      fSin := FuncD_D(rtl.dlsym(fLibM, 'sin'));
      fCos := FuncD_D(rtl.dlsym(fLibM, 'cos'));
      fTan := FuncD_D(rtl.dlsym(fLibM, 'tan'));
      fAsin := FuncD_D(rtl.dlsym(fLibM, 'asin'));
      fAcos := FuncD_D(rtl.dlsym(fLibM, 'acos'));
      fAtan := FuncD_D(rtl.dlsym(fLibM, 'atan'));
      fAtan2 := FuncDD_D(rtl.dlsym(fLibM, 'atan2'));
      fSinh := FuncD_D(rtl.dlsym(fLibM, 'sinh'));
      fCosh := FuncD_D(rtl.dlsym(fLibM, 'cosh'));
      fTanh := FuncD_D(rtl.dlsym(fLibM, 'tanh'));
      fExp := FuncD_D(rtl.dlsym(fLibM, 'exp'));
      fLog := FuncD_D(rtl.dlsym(fLibM, 'log'));
      fLog10 := FuncD_D(rtl.dlsym(fLibM, 'log10'));
      fPow := FuncDD_D(rtl.dlsym(fLibM, 'pow'));
      fFmod := FuncDD_D(rtl.dlsym(fLibM, 'fmod'));
      fSqrt := FuncD_D(rtl.dlsym(fLibM, 'sqrt'));

      if (fAbs = nil) or (fCeil = nil) or (fFloor = nil) or (fTrunc = nil) or (fRound = nil) or (fSin = nil) or (fCos = nil) or (fTan = nil) or (fAsin = nil) or (fAcos = nil) or (fAtan = nil) or (fAtan2 = nil) or (fSinh = nil) or (fCosh = nil) or (fTanh = nil) or (fExp = nil) or (fLog = nil) or (fLog10 = nil) or (fPow = nil) or (fFmod = nil) or (fSqrt = nil) then begin
        Console.WriteLine('ERROR: Could not load math functions from libSystem.B.dylib');
        Unload;
        exit false;
      end;

      exit true;
      {$ELSE}
      Console.WriteLine('ERROR: Library loading only supported on Windows or macOS Island');
      exit false;
      {$ENDIF}


    end;

    class method Unload;
    begin
      {$IF WINDOWS}
      if assigned(fUCRT) then
        rtl.FreeLibrary(fUCRT);
      fUCRT := nil;
      {$ELSEIF DARWIN}
      if assigned(fLibM) then
        rtl.dlclose(fLibM);
      fLibM := nil;
      {$ENDIF}
    end;

    // Accessor methods
    class method Abs(x: Double): Double; begin exit fAbs(x); end;
    class method Ceil(x: Double): Double; begin exit fCeil(x); end;
    class method Floor(x: Double): Double; begin exit fFloor(x); end;
    class method Trunc(x: Double): Double; begin exit fTrunc(x); end;
    class method Round(x: Double): Double; begin exit fRound(x); end;
    class method Sin(x: Double): Double; begin exit fSin(x); end;
    class method Cos(x: Double): Double; begin exit fCos(x); end;
    class method Tan(x: Double): Double; begin exit fTan(x); end;
    class method Asin(x: Double): Double; begin exit fAsin(x); end;
    class method Acos(x: Double): Double; begin exit fAcos(x); end;
    class method Atan(x: Double): Double; begin exit fAtan(x); end;
    class method Atan2(y, x: Double): Double; begin exit fAtan2(y, x); end;
    class method Sinh(x: Double): Double; begin exit fSinh(x); end;
    class method Cosh(x: Double): Double; begin exit fCosh(x); end;
    class method Tanh(x: Double): Double; begin exit fTanh(x); end;
    class method Exp(x: Double): Double; begin exit fExp(x); end;
    class method Log(x: Double): Double; begin exit fLog(x); end;
    class method Log10(x: Double): Double; begin exit fLog10(x); end;
    class method Pow(x, y: Double): Double; begin exit fPow(x, y); end;
    class method Fmod(x, y: Double): Double; begin exit fFmod(x, y); end;
    class method Sqrt(x: Double): Double; begin exit fSqrt(x); end;
  end;

  MathSinglePrecisionTest = public class(Test)
  private
    const TEST_SIZE = 10000;

    // Measure distance between adjacent representable Single values, rather
    // than dividing by a relative epsilon. Reject nonfinite mismatches first.
    class method ULPDistance(actual, expected: Single): Double;
    begin
      if Single.IsNaN(actual) or Single.IsNaN(expected) then
        exit if Single.IsNaN(actual) and Single.IsNaN(expected) then 0.0 else Double.PositiveInfinity;
      if Single.IsInfinity(actual) or Single.IsInfinity(expected) then
        exit if actual = expected then 0.0 else Double.PositiveInfinity;
      if actual = expected then exit 0.0;

      var actualBits := ^UInt32(@actual)^;
      var expectedBits := ^UInt32(@expected)^;
      var signBit := UInt32($80000000);
      var actualOrdered := if (actualBits and signBit) <> 0 then not actualBits else actualBits or signBit;
      var expectedOrdered := if (expectedBits and signBit) <> 0 then not expectedBits else expectedBits or signBit;
      exit if actualOrdered >= expectedOrdered then
        Double(actualOrdered - expectedOrdered) else Double(expectedOrdered - actualOrdered);
    end;

    class method Check(name: String; actual, expected: array of Single; threshold: Double): Boolean;
    begin
      var failures := 0;
      var firstFailure := -1;
      var maxULP := 0.0;
      for i: Integer := 0 to actual.Length-1 do begin
        var ulp := ULPDistance(actual[i], expected[i]);
        if ulp > maxULP then maxULP := ulp;
        if ulp > threshold then begin
          inc(failures);
          if firstFailure = -1 then firstFailure := i;
        end;
      end;
      if failures > 0 then begin
        Console.WriteLine(name + ' Single FAILED: ' + failures.ToString() +
          ' failures, max ULP: ' + maxULP.ToString(2));
        Console.WriteLine('  First: actual=' + actual[firstFailure].ToString() +
          ', expected=' + expected[firstFailure].ToString());
        exit false;
      end;
      exit true;
    end;

  public

    // Positive guard: fixed finite-domain inputs exercise the public Single
    // overloads against separately loaded system Double math, rounded to Single.
    // Two ULPs (four for Pow) are differential tolerances, not an accuracy proof.
    method SinglePrecision;
    begin
      Assert.IsTrue(SystemMathReference.Load, 'System math reference library must load');
      try
        Assert.IsTrue(Run, 'Single math must remain within the differential ULP limits');
      finally
        SystemMathReference.Unload;
      end;
    end;

    class method Run: Boolean;
    begin
      var random := new Random(123456789);
      var signedInput := new array of Single(TEST_SIZE);
      var unitInput := new array of Single(TEST_SIZE);
      var positiveInput := new array of Single(TEST_SIZE);
      var otherInput := new array of Single(TEST_SIZE);
      var resultValues := new array of Single(TEST_SIZE);
      var referenceValues := new array of Single(TEST_SIZE);

      for i: Integer := 0 to TEST_SIZE-1 do begin
        signedInput[i] := Single(-1.0 + random.NextDouble() * 2.0);
        unitInput[i] := Single(-0.9 + random.NextDouble() * 1.8);
        positiveInput[i] := Single(0.25 + random.NextDouble() * 8.0);
        otherInput[i] := Single(0.25 + random.NextDouble() * 4.0);
      end;

      var allPassed := true;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Acos(unitInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Acos(Double(unitInput[i])));
      allPassed := Check('Acos', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Asin(unitInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Asin(Double(unitInput[i])));
      allPassed := Check('Asin', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Atan(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Atan(Double(signedInput[i])));
      allPassed := Check('Atan', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Atan2(signedInput[i], otherInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Atan2(Double(signedInput[i]), Double(otherInput[i])));
      allPassed := Check('Atan2', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Cos(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Cos(Double(signedInput[i])));
      allPassed := Check('Cos', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Cosh(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Cosh(Double(signedInput[i])));
      allPassed := Check('Cosh', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Exp(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Exp(Double(signedInput[i])));
      allPassed := Check('Exp', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Exp2(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Pow(2.0, Double(signedInput[i])));
      allPassed := Check('Exp2', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Log(positiveInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Log(Double(positiveInput[i])));
      allPassed := Check('Log', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Log2(positiveInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Log(Double(positiveInput[i])) / SystemMathReference.Log(2.0));
      allPassed := Check('Log2', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Log10(positiveInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Log10(Double(positiveInput[i])));
      allPassed := Check('Log10', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Pow(positiveInput[i], signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Pow(Double(positiveInput[i]), Double(signedInput[i])));
      allPassed := Check('Pow', resultValues, referenceValues, 4.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Sin(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Sin(Double(signedInput[i])));
      allPassed := Check('Sin', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Sinh(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Sinh(Double(signedInput[i])));
      allPassed := Check('Sinh', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Tan(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Tan(Double(signedInput[i])));
      allPassed := Check('Tan', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Tanh(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Tanh(Double(signedInput[i])));
      allPassed := Check('Tanh', resultValues, referenceValues, 2.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Round(Single(signedInput[i] * 10.0));
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Round(Double(Single(signedInput[i] * 10.0))));
      allPassed := Check('Round', resultValues, referenceValues, 0.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Abs(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Abs(Double(signedInput[i])));
      allPassed := Check('Abs', resultValues, referenceValues, 0.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Ceiling(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Ceil(Double(signedInput[i])));
      allPassed := Check('Ceiling', resultValues, referenceValues, 0.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Floor(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Floor(Double(signedInput[i])));
      allPassed := Check('Floor', resultValues, referenceValues, 0.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Truncate(signedInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Trunc(Double(signedInput[i])));
      allPassed := Check('Truncate', resultValues, referenceValues, 0.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.Sqrt(positiveInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Sqrt(Double(positiveInput[i])));
      allPassed := Check('Sqrt', resultValues, referenceValues, 1.0) and allPassed;

      for i: Integer := 0 to TEST_SIZE-1 do resultValues[i] := Math.fmodf(positiveInput[i], otherInput[i]);
      for i: Integer := 0 to TEST_SIZE-1 do referenceValues[i] := Single(SystemMathReference.Fmod(Double(positiveInput[i]), Double(otherInput[i])));
      allPassed := Check('fmodf', resultValues, referenceValues, 2.0) and allPassed;

      exit allPassed;
    end;
  end;

{$ENDIF}

end.
