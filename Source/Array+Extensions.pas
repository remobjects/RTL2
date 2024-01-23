﻿namespace RemObjects.Elements.RTL;

type
  ArrayExtensions<T> = public extension record(array of T) where T is IEquatable<T>;
  public
    operator &Equal(lhs: array of T; rhs: array of T): Boolean;
    begin
      {$IF NOT TOFFEE}
      if Object(lhs) = Object(rhs) then
        exit true;
      {$ENDIF}
      if RemObjects.Elements.System.length(lhs) ≠ RemObjects.Elements.System.length(rhs) then
        exit false;
      for i := 0 to RemObjects.Elements.System.length(lhs)-1 do
        if not lhs[i].Equals(rhs[i]) then
          exit false;
      result := true;
    end;

    operator NotEqual(lhs: array of T; rhs: array of T): Boolean;
    begin
      result := not (lhs = rhs);
    end;

  end;

end.