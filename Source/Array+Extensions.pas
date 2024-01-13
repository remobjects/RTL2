namespace RemObjects.Elements.RTL;

type
  ArrayExtensions<T> = public extension record(array of T) where T is IEquatable<T>;
  public

    operator &Equal(lhs: array of Byte; rhs: array of Byte): Boolean;
    begin
      {$IF NOT TOFFEE}
      if Object(lhs) = Object(rhs) then
        exit true;
      {$ENDIF}
      if RemObjects.Elements.System.length(lhs) ≠ RemObjects.Elements.System.length(rhs) then
        exit false;
      for i := 0 to RemObjects.Elements.System.length(lhs)-1 do
        if lhs[i] ≠ rhs[i] then
          exit false;
      result := true;
    end;

    operator NotEqual(lhs: array of Byte; rhs: array of Byte): Boolean;
    begin
      result := not (lhs = rhs);
    end;

  end;

end.