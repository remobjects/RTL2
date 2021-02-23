namespace RemObjects.Elements.RTL.Reflection;

type
  Helpers = assembly static class

    {$IF COOPER}
    method DecodeCooperVisibiliy(aModifider: Integer): Visibility;
    begin

      result := if java.lang.reflect.Modifier.isPublic(aModifider) then Visibility.Public
                else if java.lang.reflect.Modifier.isProtected(aModifider) then Visibility.Protected
                else if java.lang.reflect.Modifier.isPrivate(aModifider) then Visibility.Private
                else Visibility.Private; // other visibilities aren't supported on Java, at runtime level
    end;
    {$ENDIF}

    {$IF ECHOES}
    method DecodeEchoesVisibiliy(aMember: System.Reflection.FieldInfo): Visibility;
    begin
      result := if aMember.IsPublic then Visibility.Public
                else if aMember.IsFamilyAndAssembly then Visibility.AssemblyAndProtected
                else if aMember.IsFamilyOrAssembly then Visibility.AssemblyOrProtected
                else if aMember.IsFamily then Visibility.Protected
                else if aMember.IsPrivate then Visibility.Private
                else Visibility.Private; // other visibilities arent supported on .NET, at runtime level
    end;

    method DecodeEchoesVisibiliy(aMember: System.Reflection.MethodInfo): Visibility;
    begin
      result := if aMember.IsPublic then Visibility.Public
                else if aMember.IsFamilyAndAssembly then Visibility.AssemblyAndProtected
                else if aMember.IsFamilyOrAssembly then Visibility.AssemblyOrProtected
                else if aMember.IsFamily then Visibility.Protected
                else if aMember.IsPrivate then Visibility.Private
                else Visibility.Private; // other visibilities arent supported on .NET, at runtime level
    end;
    {$ENDIF}

    {$IF ISLAND}
    method DecodeIslandVisibiliy(aMemberAccess: MemberAccess): Visibility;
    begin
      result := case aMemberAccess of
        MemberAccess.Private: Visibility.Private;
        MemberAccess.AssemblyAndProtected: Visibility.AssemblyAndProtected;
        MemberAccess.Assembly: Visibility.Assembly;
        MemberAccess.Protected: Visibility.Protected;
        MemberAccess.AssemblyOrProtected: Visibility.AssemblyOrProtected;
        MemberAccess.Public: Visibility.Public;
        MemberAccess.Unit: Visibility.Unit;
        MemberAccess.UnitOrProtected: Visibility.UnitOrProtected;
        MemberAccess.UnitAndProtected: Visibility.UnitAndProtected;
      end;

    end;
    {$ENDIF}



  end;


end.