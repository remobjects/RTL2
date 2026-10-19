// Positive regression guard: public Single and Double min/max must produce
// the expected values across every vector-body and scalar-tail length 0..256.
// Promoted from IsotopeLab Workloads without its timing machinery.
namespace Elements.RTL2.Tests.Shared;

uses RemObjects.Elements.RTL, RemObjects.Elements.EUnit;

type
  MathVectorMinMaxTest = public class(Test)
  public

    [DisableInlining]
    class method MinDouble(aInput, aOutput: array of Double);
    begin
      for i := 0 to length(aInput) - 1 do
        aOutput[i] := Math.Min(aInput[i], Double(0.7));
    end;

    [DisableInlining]
    class method MaxDouble(aInput, aOutput: array of Double);
    begin
      for i := 0 to length(aInput) - 1 do
        aOutput[i] := Math.Max(aInput[i], Double(0.7));
    end;

    [DisableInlining]
    class method MinSingle(aInput, aOutput: array of Single);
    begin
      for i := 0 to length(aInput) - 1 do
        aOutput[i] := Math.Min(aInput[i], Single(0.7));
    end;

    [DisableInlining]
    class method MaxSingle(aInput, aOutput: array of Single);
    begin
      for i := 0 to length(aInput) - 1 do
        aOutput[i] := Math.Max(aInput[i], Single(0.7));
    end;

    method MinMaxAtEveryLength;
    begin
      for n := 0 to 256 do begin
        var lInput := new Double[n];
        var lOutput := new Double[n];
        var lInputSingle := new Single[n];
        var lOutputSingle := new Single[n];
        for i := 0 to n - 1 do begin
          lInput[i] := (i mod 13) / 16.0;
          lInputSingle[i] := Single(lInput[i]);
        end;
        MinDouble(lInput, lOutput);
        MinSingle(lInputSingle, lOutputSingle);
        for i := 0 to n - 1 do begin
          var lExpected := if lInput[i] > 0.7 then 0.7 else lInput[i];
          Assert.AreEqual(lExpected, lOutput[i]);
          Assert.AreEqual(Single(lExpected), lOutputSingle[i]);
        end;
        MaxDouble(lInput, lOutput);
        MaxSingle(lInputSingle, lOutputSingle);
        for i := 0 to n - 1 do begin
          var lExpected := if lInput[i] < 0.7 then 0.7 else lInput[i];
          Assert.AreEqual(lExpected, lOutput[i]);
          Assert.AreEqual(Single(lExpected), lOutputSingle[i]);
        end;
      end;
    end;

  end;

end.
