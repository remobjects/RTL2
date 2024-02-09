namespace RemObjects.Elements.RTL;

type
  VariableStyle = public enum(Percent, DoubleCurly, EBuild);

  String = public partial class
  public

    method ProcessVariables(aStyle: VariableStyle; aCallback: block(aVariable: not nullable String): nullable String): not nullable String;
    begin
      result := case aStyle of
        VariableStyle.Percent: ProcessPlaceholders_PercentStyle(aCallback);
        VariableStyle.DoubleCurly: ProcessPlaceholders_DoubleCurlyStyle(aCallback);
        VariableStyle.EBuild: ProcessPlaceholders_EBuildStyle(aCallback);
        else raise new Exception($"Unknown variable style {aStyle}");
      end;
    end;

  private

    method ProcessPlaceholders_EBuildStyle(aCallback: block(aVariable: not nullable String): nullable String): not nullable String;
    begin

      var lCurrentStart := 0;
      var lResult: StringBuilder;

      method AppendResult(aString: String);
      begin
        if assigned(lResult) then
          lResult.Append(aString)
        else
          lResult := new StringBuilder(aString);
      end;

      var i: Integer := 0;
      var len := self.Length;
      Outer: while i < len-2 do begin

        if self[i] = '$' then begin
          if self[i+1] = '(' then begin
            if (i > 0) and (self[i-1] = '$') then begin // use `$$(` to escape, keep `$(`
              AppendResult(self.Substring(lCurrentStart, i-lCurrentStart));
              AppendResult("(");
              inc(i, 2);
              lCurrentStart := i;
              continue Outer;
            end;

            AppendResult(self.Substring(lCurrentStart, i-lCurrentStart));
            lCurrentStart := i;
            inc(i,2);
            while i < self.Length do begin
              if self[i] = ')' then begin
                var lVariableName := self.Substring(lCurrentStart+2, i-lCurrentStart-2);
                var lValue := aCallback(lVariableName);
                if assigned(lValue) then begin
                  AppendResult(lValue);
                  inc(i);
                  lCurrentStart := i;
                  continue Outer;
                end;
                break;
              end;
              inc(i);
            end;
          end
          else;
        end;
        inc(i);

      end;
      if assigned(lResult) and (lCurrentStart < len) then
        AppendResult(self.Substring(lCurrentStart));

      result := coalesce(lResult:ToString, self);
    end;

    method ProcessPlaceholders_DoubleCurlyStyle(aCallback: block(aVariable: not nullable String): nullable String): not nullable String;
    begin

      var lCurrentStart := 0;
      var lResult: StringBuilder;

      method AppendResult(aString: String);
      begin
        if assigned(lResult) then
          lResult.Append(aString)
        else
          lResult := new StringBuilder(aString);
      end;

      var i: Integer := 0;
      var len := self.Length;
      Outer: while i < len-3 do begin

        if self[i] = '{' then begin
          if self[i+1] = '{' then begin
            if self[i+2] = '{' then begin // use `{{{` to escape, keep two
              AppendResult(self.Substring(lCurrentStart, i-lCurrentStart+2));
              inc(i, 3);
              lCurrentStart := i;
              continue Outer;
            end;

            AppendResult(self.Substring(lCurrentStart, i-lCurrentStart));
            lCurrentStart := i;
            inc(i,2);
            while i < self.Length-1 do begin
              if self[i] = '}' then begin
                if self[i+1] = '}' then begin
                  var lVariableName := self.Substring(lCurrentStart+2, i-lCurrentStart-2);
                  var lValue := aCallback(lVariableName);
                  if assigned(lValue) then begin
                    AppendResult(lValue);
                    inc(i,2);
                    lCurrentStart := i;
                    continue Outer;
                  end;
                end;
              end;
              inc(i);
            end;
          end;
        end;
        inc(i);

      end;
      if assigned(lResult) and (lCurrentStart < len) then
        AppendResult(self.Substring(lCurrentStart));

      result := coalesce(lResult:ToString, self);
    end;

    method ProcessPlaceholders_PercentStyle(aCallback: block(aVariable: not nullable String): nullable String): not nullable String;
    begin

      var lCurrentStart := 0;
      var lResult: StringBuilder;

      method AppendResult(aString: String);
      begin
        if assigned(lResult) then
          lResult.Append(aString)
        else
          lResult := new StringBuilder(aString);
      end;

      var i: Integer := 0;
      var len := self.Length;
      Outer: while i < len-2 do begin

        if self[i] = '%' then begin
          if self[i+1] = '%' then begin // use `%%` to escape, keep one
            AppendResult(self.Substring(lCurrentStart, i-lCurrentStart+1));
            inc(i, 2);
            lCurrentStart := i;
            continue Outer;
          end;

          AppendResult(self.Substring(lCurrentStart, i-lCurrentStart));
          lCurrentStart := i;
          inc(i);
          while i < self.Length do begin
            if self[i] = '%' then begin
              var lVariableName := self.Substring(lCurrentStart+1, i-lCurrentStart-1);
              var lValue := aCallback(lVariableName);
              if assigned(lValue) then begin
                AppendResult(lValue);
                inc(i);
                lCurrentStart := i;
                continue Outer;
              end;
            end;
            inc(i);
          end;
        end;
        inc(i);

      end;
      if assigned(lResult) and (lCurrentStart < len) then
        AppendResult(self.Substring(lCurrentStart));

      result := coalesce(lResult:ToString, self);
    end;

  end;

end.