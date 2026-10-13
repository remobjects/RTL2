// Positive guards: public Round returns Int64 for both precisions and remains
// correct when callers store that result in integer or floating-point arrays.
// Negative regression guard: nearest-even midpoints, saturation, signed zero
// and large integral floats must survive vector bodies and scalar tails. Promoted from the IsotopeLab
// RoundOutputs experiment; fixed seeds make the raw-bit guards reproducible.
namespace Elements.RTL2.Tests.Shared;
uses RemObjects.Elements.RTL, RemObjects.Elements.EUnit;

{$IF ISLAND}
type
  MathRoundOutputsTest = public class(Test)
  public

    class method Verify(aCondition: Boolean; aMessage: String);
    begin
      Assert.IsTrue(aCondition, aMessage);
    end;

    [DisableInlining]
    class method SingleInteger(aInput: array of Single; aOutput: array of Int64);
    begin
      for i := 0 to length(aInput) - 1 do
        aOutput[i] := Math.Round(aInput[i]);
    end;

    [DisableInlining]
    class method SingleFloat(aInput: array of Single; aOutput: array of Single);
    begin
      for i := 0 to length(aInput) - 1 do
        aOutput[i] := Math.Round(aInput[i]);
    end;

    method SingleOutputEdges;
    begin
      var lValues: array of Single := [Single(-0.0), Single(-0.25), Single(-0.5), Single(-1.5), Single(-2.5),
          Single(0.5), Single(1.5), Single(2.5),
          Single(Consts.NaN), Single(Consts.PositiveInfinity), Single(Consts.NegativeInfinity),
          Single(9223372036854775808.0), Single(-9223372036854775808.0),
          Single(18446744073709551616.0), Single(-18446744073709551616.0),
          Single(8388607.5), Single(8388609.0), Single(-8388609.0),
          Single(0.4999999701976776), Single(-0.4999999701976776),
          Single(9223371487098961920.0), Single(-9223371487098961920.0)];
      var lExpected: array of Int64 := [0, 0, 0, -2, -2, 0, 2, 2, 0, Consts.MaxInt64, Consts.MinInt64,
          Consts.MaxInt64, Consts.MinInt64, Consts.MaxInt64, Consts.MinInt64,
          8388608, 8388609, -8388609, 0, 0, 9223371487098961920, -9223371487098961920];
      for n := 0 to 65 do begin
        var lInput := new Single[n];
        var lInteger := new Int64[n];
        var lFloat := new Single[n];
        for offset := 0 to length(lValues) - 1 do begin
          for i := 0 to n - 1 do
            lInput[i] := lValues[(i + offset) mod length(lValues)];
          SingleInteger(lInput, lInteger);
          SingleFloat(lInput, lFloat);
          for i := 0 to n - 1 do begin
            var lWanted := lExpected[(i + offset) mod length(lValues)];
            Verify(lInteger[i] = lWanted, 'Single integer edge');
            Verify(lFloat[i] = Single(lWanted), 'Single float edge');
            if lWanted = 0 then
              Verify(Single(1.0) / lFloat[i] = Single(Consts.PositiveInfinity), 'Single positive zero');
          end;
        end;
      end;
    end;

    [DisableInlining]
    class method DoubleInteger(aInput: array of Double; aOutput: array of Int64);
    begin
      for i := 0 to length(aInput) - 1 do
        aOutput[i] := Math.Round(aInput[i]);
    end;

    [DisableInlining]
    class method DoubleFloat(aInput: array of Double; aOutput: array of Double);
    begin
      for i := 0 to length(aInput) - 1 do
        aOutput[i] := Math.Round(aInput[i]);
    end;

    method DoubleOutputEdges;
    begin
      var lValues: array of Double := [Double(-0.0), Double(-0.25), Double(-0.5), Double(-1.5), Double(-2.5),
          Double(0.5), Double(1.5), Double(2.5),
          Double(Consts.NaN), Double(Consts.PositiveInfinity), Double(Consts.NegativeInfinity),
          Double(9223372036854775808.0), Double(-9223372036854775808.0),
          Double(18446744073709551616.0), Double(-18446744073709551616.0),
          Double(8388607.5), Double(8388609.0), Double(-8388609.0),
          Double(0.49999999999999994), Double(-0.49999999999999994),
          Double(9223372036854774784.0), Double(-9223372036854774784.0),
          Double(4503599627370495.5), Double(4503599627370497.0)];
      var lExpected: array of Int64 := [0, 0, 0, -2, -2, 0, 2, 2, 0, Consts.MaxInt64, Consts.MinInt64,
          Consts.MaxInt64, Consts.MinInt64, Consts.MaxInt64, Consts.MinInt64,
          8388608, 8388609, -8388609, 0, 0, 9223372036854774784, -9223372036854774784,
          4503599627370496, 4503599627370497];
      for n := 0 to 65 do begin
        var lInput := new Double[n];
        var lInteger := new Int64[n];
        var lFloat := new Double[n];
        for offset := 0 to length(lValues) - 1 do begin
          for i := 0 to n - 1 do
            lInput[i] := lValues[(i + offset) mod length(lValues)];
          DoubleInteger(lInput, lInteger);
          DoubleFloat(lInput, lFloat);
          for i := 0 to n - 1 do begin
            var lWanted := lExpected[(i + offset) mod length(lValues)];
            Verify(lInteger[i] = lWanted, 'Double integer edge');
            Verify(lFloat[i] = Double(lWanted), 'Double float edge');
            if lWanted = 0 then
              Verify(Double(1.0) / lFloat[i] = Double(Consts.PositiveInfinity), 'Double positive zero');
          end;
        end;
      end;
    end;

    [DisableInlining]
    class method ScalarSingle(aValue: Single): Single;
    begin
      // Keep the reference integer result across a no-inline call boundary.
      // The new round-trip fold must not also rewrite this oracle.
      exit Single(ScalarSingleInteger(aValue));
    end;

    [DisableInlining]
    class method ScalarSingleInteger(aValue: Single): Int64;
    begin
      exit Math.Round(aValue);
    end;

    // Positive guard: sample the entire Single exponent/sign range using raw
    // bits, with scalar public-API conversion as a separate code-generation oracle.
    method SingleOutputBits;
    begin
      const N = 65537;
      var lInput := new Single[N];
      var lOutput := new Single[N];
      var lInteger := new Int64[N];
      var lState: UInt32 := 123456789;
      for batch := 0 to 15 do begin
        for i := 0 to N - 1 do begin
          lState := lState xor (lState shl 13);
          lState := lState xor (lState shr 17);
          lState := lState xor (lState shl 5);
          lInput[i] := ^Single(@lState)^;
        end;
        SingleFloat(lInput, lOutput);
        SingleInteger(lInput, lInteger);
        for i := 0 to N - 1 do begin
          Verify(lOutput[i] = ScalarSingle(lInput[i]), 'Single raw-bit conversion');
          Verify(lInteger[i] = ScalarSingleInteger(lInput[i]), 'Single raw-bit integer');
          if lInteger[i] = 0 then
            Verify(Single(1.0) / lOutput[i] = Single(Consts.PositiveInfinity), 'Single raw-bit positive zero');
        end;
      end;
    end;

    [DisableInlining]
    class method ScalarDouble(aValue: Double): Double;
    begin
      // Independently convert the scalar integer result, as for Single above.
      exit Double(ScalarDoubleInteger(aValue));
    end;

    [DisableInlining]
    class method ScalarDoubleInteger(aValue: Double): Int64;
    begin
      exit Math.Round(aValue);
    end;

    // Positive guard: sample the entire Double exponent/sign range using raw
    // bits, with scalar public-API conversion as a separate code-generation oracle.
    method DoubleOutputBits;
    begin
      const N = 65537;
      var lInput := new Double[N];
      var lOutput := new Double[N];
      var lInteger := new Int64[N];
      var lState: UInt64 := 123456789123456789;
      for batch := 0 to 15 do begin
        for i := 0 to N - 1 do begin
          lState := lState xor (lState shl 13);
          lState := lState xor (lState shr 7);
          lState := lState xor (lState shl 17);
          lInput[i] := ^Double(@lState)^;
        end;
        DoubleFloat(lInput, lOutput);
        DoubleInteger(lInput, lInteger);
        for i := 0 to N - 1 do begin
          Verify(lOutput[i] = ScalarDouble(lInput[i]), 'Double raw-bit conversion');
          Verify(lInteger[i] = ScalarDoubleInteger(lInput[i]), 'Double raw-bit integer');
          if lInteger[i] = 0 then
            Verify(Double(1.0) / lOutput[i] = Double(Consts.PositiveInfinity), 'Double raw-bit positive zero');
        end;
      end;
    end;

  end;
{$ENDIF}

end.
