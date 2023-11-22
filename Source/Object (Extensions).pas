namespace RemObjects.Elements.RTL;

{$IF COOPER}
extension method java.lang.Object.«ToString»: PlatformString; public;
begin
  result := «toString»();
end;

extension method java.lang.Object.«Equals»(aOther: Object): Boolean; public;
begin
  result := self.equals(aOther)
end;

extension method java.lang.Object.GetHashCode: Integer; public;
begin
  result := hashCode;
end;
{$ELSEIF TOFFEE}
extension method Foundation.NSObject.ToString: PlatformString; public;
begin
  result := description;
end;

extension method Foundation.NSObject.Equals(Obj: Object): Boolean; public;
begin
  result := isEqual(Obj);
end;

extension method Foundation.NSObject.GetHashCode: Integer; public;
begin
  result := hash;
end;
{$ENDIF}

end.