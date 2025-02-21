namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.Cirrus,
  RemObjects.Elements.Cirrus.Values,
  RemObjects.Elements.Cirrus.Statements;

type
  NamingStyle = public enum(AsIs, PascalCase, camelCase, lowercase, UPPERCASE);

  Direction = enum(Encode, Decode);

  CodableAspect = public class(System.Attribute, IBaseAspect, ITypeInterfaceDecorator, ITypeImplementationDecorator)
  public

    method HandleInterface(aServices: IServices; aType: ITypeDefinition); virtual;
    begin
      var lCodableHelpers := new CodableHelpers(aServices, aType, fNamingStyle, true);
      lCodableHelpers.EmitPlatformWarning;
      fNeedToImplementEncode := lCodableHelpers.AddIEncode;
      fNeedToImplementDecode := lCodableHelpers.AddIDecode;
    end;

    method HandleImplementation(aServices: IServices; aType: ITypeDefinition); virtual;
    begin
      var lCodableHelpers := new CodableHelpers(aServices, aType, fNamingStyle, true);
      if fNeedToImplementEncode then
        lCodableHelpers.ImplementEncode;
      if fNeedToImplementDecode then
        lCodableHelpers.ImplementDecode;
    end;

    constructor; empty;

    constructor (aNamingStyle: NamingStyle);
    begin
      fNamingStyle := aNamingStyle;
    end;

  protected

    fNamingStyle: NamingStyle;
    fNeedToImplementEncode, fNeedToImplementDecode: Boolean;

  end;

  EncodableAspect = public class(CodableAspect)
  public

    method HandleInterface(aServices: IServices; aType: ITypeDefinition); override;
    begin
      var lCodableHelpers := new CodableHelpers(aServices, aType, fNamingStyle);
      lCodableHelpers.EmitPlatformWarning;
      fNeedToImplementEncode := lCodableHelpers.AddIEncode;
    end;

    method HandleImplementation(aServices: IServices; aType: ITypeDefinition); override;
    begin
      var lCodableHelpers := new CodableHelpers(aServices, aType, fNamingStyle);
      lCodableHelpers.EmitPlatformWarning;
      if fNeedToImplementEncode then
        lCodableHelpers.ImplementEncode;
    end;

  end;

  DecodableAspect = public class(CodableAspect)
  public

    method HandleInterface(aServices: IServices; aType: ITypeDefinition); override;
    begin
      var lCodableHelpers := new CodableHelpers(aServices, aType, fNamingStyle);
      fNeedToImplementDecode := lCodableHelpers.AddIDecode;
    end;

    method HandleImplementation(aServices: IServices; aType: ITypeDefinition); override;
    begin
      var lCodableHelpers := new CodableHelpers(aServices, aType, fNamingStyle);
      if fNeedToImplementDecode then
        lCodableHelpers.ImplementDecode;
    end;

  end;

  //
  // CodableHelpers
  //

  CodableHelpers = unit class
  unit

    constructor(aServices: IServices; aType: ITypeDefinition; aNamingStyle: NamingStyle; aBoth: Boolean := false);
    begin
      fServices := aServices;
      fType := aType;
      fNamingStyle := aNamingStyle;
      fImplementingEncodeAndDecode := aBoth;
    end;

    var fServices: IServices; private;
    var fType: ITypeDefinition; private;
    var fNamingStyle: NamingStyle;
    var fImplementingEncodeAndDecode: Boolean;

    method EmitPlatformWarning;
    begin
      case fServices.Platform of
        Platform.Island: fServices.EmitHint(fType, $"Serialization is not fully supported on Island, yet.");
        Platform.Cooper: fServices.EmitHint(fType, $"Serialization is not fully supported on Java, yet.");
        Platform.Gotham: fServices.EmitError(fType, $"Serialization is notsupported for Gotham projects.");
        Platform.All: fServices.EmitError(fType, $"Serialization is not supported for mixed-platforms projects.");
      end;
    end;

    //
    // ENCODE
    //

    method AddIEncode: Boolean;
    begin
      AddInterface("RemObjects.Elements.Serialization.IEncodable");

      var lExisting := fType.GetMethod("Encode", ["RemObjects.Elements.Serialization.Coder"], [ParameterModifier.In]);
      if assigned(lExisting) then
        exit false;

      var lEncode := fType.AddMethod("Encode", VoidType, false);
      lEncode.AddParameter("aCoder", ParameterModifier.In, fServices.GetType("RemObjects.Elements.Serialization.Coder"));

      if IsEncodable(fType.ParentType) then
        lEncode.Virtual := VirtualMode.Override
      else
        lEncode.Virtual := VirtualMode.Virtual;

      result := true;
    end;

    method AddIDecode: Boolean;
    begin
      AddInterface("RemObjects.Elements.Serialization.IDecodable");

      var lExisting := fType.GetMethod("Decode", ["RemObjects.Elements.Serialization.Coder"], [ParameterModifier.In]);
      if assigned(lExisting) then
        exit false;

      var lDecode := fType.AddMethod("Decode", VoidType, false);
      lDecode.AddParameter("aCoder", ParameterModifier.In, fServices.GetType("RemObjects.Elements.Serialization.Coder"));

      if IsDecodable(fType.ParentType) then
        lDecode.Virtual := VirtualMode.Override
      else
        lDecode.Virtual := VirtualMode.Virtual;

      result := true;
    end;

    //
    // ENCODE
    //

    method ImplementEncode;
    begin
      var lEncode := fType.GetMethod("Encode", ["RemObjects.Elements.Serialization.Coder"], [ParameterModifier.In]);
      if not assigned(lEncode) then
        raise new Exception("Encode method not found");

      //var lEncode := fType.AddMethod("Encode", VoidType, false);
      //lEncode.AddParameter("aCoder", ParameterModifier.In, fServices.GetType("RemObjects.Elements.Serialization.Coder"));

      var lBody := new BeginStatement;

      if lEncode.Virtual = VirtualMode.Override then begin
        var lInheritedCall := new ProcValue(new SelfValue, "Encode", new IdentifierValue("aCoder"), &Inherited := true);
        lBody.Add(new StandaloneStatement(lInheritedCall));
      end;

      //var lCoder := fServices.GetType("RemObjects.Elements.Serialization.Coder");
      //var lCoderEncode := lCoder.GetMethod("Encode", ["System.String", "System.Object"], [ParameterModifier.In, ParameterModifier.In]);

      PropertiesLoop:
      for each p in GetCodableProperties do begin

        var lValue: Value;
        var lPosition: IPosition := nil;

        var lParameterName := AdjustName(p.Name);

        for i := 0 to p.AttributeCount-1 do begin
          var a := p.GetAttribute(i);
          case a.Type.Fullname of
            //"RemObjects.Elements.Serialization.EncodeMemberAttribute": begin
                //lPosition := a;
                //var lName := a.GetParameter(0);
                ////writeLn($"lName.ToString {lName.ToString}");
                ////lValue := new IfStatement()
                //lValue := new ProcValue(new ParamValue(0), "EncodeField", nil, false, [AdjustName(p.Name)+"."+AdjustName(lName.ToString),
                                                                                       //new IdentifierValue(new IdentifierValue(p.Name), lName.ToString)]);
                //break;
              //end;

            "RemObjects.Elements.Serialization.EncodeAttribute": begin
                var lParameter := a.GetParameter(0) as DataValue;
                if lParameter.Value is Boolean then begin
                  if not Boolean(lParameter.Value) then
                    continue PropertiesLoop;
                end
                else begin
                  lParameterName := lParameter.ToString;
                end;
                break;
              end;
          end;
        end;

        var (lEncoderFunction, lEncoderType, lErrorType) := GetCoderFunctionName(p.Type, Direction.Encode);
        //Log($"{p.Name}: {lEncoderFunction}");

        var lEncoderTypeRef: Value := if assigned(lEncoderType) then
          (if fServices.Platform = Platform.Toffee then
             new NewValue(fServices.GetType("RemObjects.Elements.RTL.Reflection.Type"), [new ProcValue(new TypeValue(lEncoderType), "class")], nil, ["withPlatformType"])
           else
             new TypeOfValue(lEncoderType));

        case lEncoderFunction of
          "Object": begin
              lValue := new ProcValue(new ParamValue(0), "Encode"+lEncoderFunction, nil, [lParameterName, new IdentifierValue(p.Name), lEncoderTypeRef]);
            end;
          "Array", "List", "StringDictionary": begin
              if (lEncoderFunction = "Array") and (fServices.Platform in [Platform.Toffee, Platform.Cooper]) then begin
                fServices.EmitWarning(p, $"Arrays are not supported for serialization on this platform yet.");
                continue;
              end;
              lValue := new ProcValue(new ParamValue(0), "Encode"+lEncoderFunction, [lEncoderType], [lParameterName, new IdentifierValue(p.Name), lEncoderTypeRef])
            end;
          else begin
              lValue := new ProcValue(new ParamValue(0), "Encode"+lEncoderFunction, nil, [lParameterName, new IdentifierValue(p.Name)]);
            end;
        end;

        if not assigned(lEncoderFunction) then begin
          if fImplementingEncodeAndDecode then
            fServices.EmitWarning(p, $"Type '{coalesce(lErrorType, p.Type).Fullname}' for property '{p.Name}' is not codable")
          else
            fServices.EmitWarning(p, $"Type '{coalesce(lErrorType, p.Type).Fullname}' for property '{p.Name}' is not encodable");
          continue;
        end;

        //var lValue := case lEncoderFunction in ["Object", "Array", "List"] then
          //new BinaryValue(new ProcValue(new ParamValue(0), "Encode"+lEncoderFunction, nil, false, [lParameterName,
                                                                                                   //new TypeOfValue(lDecoderType)]),
                          //new TypeValue(p.Type),
                          //BinaryOperator.As)
        //else
          //new ProcValue(new ParamValue(0), "Encode"+lDecoderFunction, nil, false, [lParameterName]);

        //if not assigned(lValue) then
          //lValue := new ProcValue(new ParamValue(0), "EncodeField", nil, false, [AdjustName(p.Name), new IdentifierValue(p.Name)]);
        var lStatement := new StandaloneStatement(lValue);
        if assigned(lPosition) then
          lStatement.Position := lPosition;
        lBody.Add(lStatement);
      end;

      (lEncode as IMethodDefinition).ReplaceMethodBody(lBody);
    end;

    //
    // DECODE
    //

    method ImplementDecode;
    begin
      var lDecode := fType.GetMethod("Decode", ["RemObjects.Elements.Serialization.Coder"], [ParameterModifier.In]);
      if not assigned(lDecode) then
        raise new Exception("Decode method not found");

      //var lDecode := fType.AddMethod("Decode", VoidType, false);
      //lDecode.AddParameter("aCoder", ParameterModifier.In, fServices.GetType("RemObjects.Elements.Serialization.Coder"));

      var lBody := new BeginStatement;

      if lDecode.Virtual = VirtualMode.Override then begin
        //writeLn($"ParentType {fType.ParentType.Fullname} of {fType.Fullname} is decodable");
        var lInheritedCall := new ProcValue(new SelfValue, "Decode", new IdentifierValue("aCoder"), &Inherited := true);
        lBody.Add(new StandaloneStatement(lInheritedCall));
      end;

      //var lCoder := fServices.GetType("RemObjects.Elements.Serialization.Coder");
      //var lCoderEncode := lCoder.GetMethod("Encode", ["System.String", "System.Object"], [ParameterModifier.In, ParameterModifier.In]);

      PropertiesLoop:
      for each p in GetCodableProperties do begin

        if p.ReadOnly then
          continue;

        var lValue: Value;
        var lPosition: IPosition := nil;

        //Log($"p.Type {p.Type.Fullname}, {lType.Fullname}");

        var lParameterName := AdjustName(p.Name);

        //Log($"AttributeCount for {p.Name}: {p.AttributeCount}");
        for i := 0 to p.AttributeCount-1 do begin
          var a := p.GetAttribute(i);
          //Log($"a.Type.Fullname {a.Type.Fullname}");
          case a.Type.Fullname of
            //"RemObjects.Elements.Serialization.EncodeMemberAttribute": begin
                //lPosition := a;
                //var lName := a.GetParameter(0);
                ////writeLn($"lName.ToString {lName.ToString}");
                ////lValue := new IfStatement()
                //lValue := new ProcValue(new ParamValue(0), "EncodeField", nil, false, [AdjustName(p.Name)+"."+AdjustName(lName.ToString),
                                                                                       //new IdentifierValue(new IdentifierValue(p.Name), lName.ToString)]);
                //break;
              //end;

            "RemObjects.Elements.Serialization.EncodeAttribute": begin
                var lParameter := a.GetParameter(0) as DataValue;
                if lParameter.Value is Boolean then begin
                  if not Boolean(lParameter.Value) then
                    continue PropertiesLoop;
                end
                else begin
                  lParameterName := lParameter.ToString;
                end;
                break;
              end;
          end;
        end;

        var (lDecoderFunction, lDecoderType, lErrorType) := GetCoderFunctionName(p.Type, Direction.Decode);

        if not assigned(lDecoderFunction) then begin
          if not fImplementingEncodeAndDecode then
            fServices.EmitWarning(p, $"Type '{coalesce(lErrorType, p.Type).Fullname}' for property '{p.Name}' is not decodable");
          continue;
        end;

        for i := 0 to p.AttributeCount-1 do begin
          var a := p.GetAttribute(i);
          case a.Type.Fullname of
            //"RemObjects.Elements.Serialization.EncodeMemberAttribute": begin
                //lPosition := a;
                //var lName := a.GetParameter(0);
                ////writeLn($"lName.ToString {lName.ToString}");
                ////lValue := new IfStatement()
                //lValue := new ProcValue(new ParamValue(0), "EncodeField", nil, false, [AdjustName(p.Name)+"."+AdjustName(lName.ToString),
                                                                                       //new IdentifierValue(new IdentifierValue(p.Name), lName.ToString)]);
                //break;
              //end;

            "RemObjects.Elements.Serialization.EncodeAttribute": begin
                //Log($"has EncodeAttribute");
                var lParameter := a.GetParameter(0) as DataValue;
                //Log($"lParameter {lParameter}");
                if lParameter.Value is Boolean then begin
                  if not Boolean(lParameter.Value) then
                    continue PropertiesLoop;
                end
                else begin
                  lParameterName := lParameter.ToString;
                end;
                break;
              end;
          end;
        end;

        var lDecoderTypeRef: Value := if assigned(lDecoderType) then
          (if fServices.Platform = Platform.Toffee then
             new NewValue(fServices.GetType("RemObjects.Elements.RTL.Reflection.Type"), [new ProcValue(new TypeValue(lDecoderType), "class")], nil, ["withPlatformType"])
           else
             new TypeOfValue(lDecoderType));

        case lDecoderFunction of
          "Object": begin
              lValue := new BinaryValue(new ProcValue(new ParamValue(0), "Decode"+lDecoderFunction, nil, [lParameterName, lDecoderTypeRef]),
                                        new TypeValue(p.Type),
                                        BinaryOperator.As)
            end;
          "Array", "List", "StringDictionary": begin
              if (lDecoderFunction = "Array") and (fServices.Platform in [Platform.Toffee, Platform.Cooper]) then begin
                fServices.EmitWarning(p, $"Arrays are not supported for serialization on this platform yet.");
                continue;
              end;
              if fServices.Platform in [Platform.Cooper] then begin
                fServices.EmitWarning(p, $"Collections are not supported for decoding on Java yet.");
                continue;
              end;
              lValue := new BinaryValue(new ProcValue(new ParamValue(0), "Decode"+lDecoderFunction, [lDecoderType], [lParameterName, lDecoderTypeRef]),
                                        new TypeValue(p.Type),
                                        BinaryOperator.As)
            end;
          else begin
              lValue := new ProcValue(new ParamValue(0), "Decode"+lDecoderFunction, nil, [lParameterName]);
            end;
        end;

        var lStatement := new AssignmentStatement(new IdentifierValue(p.Name), lValue);
        if assigned(lPosition) then
          lStatement.Position := lPosition;
        lBody.Add(lStatement);
      end;

      (lDecode as IMethodDefinition).ReplaceMethodBody(lBody);
    end;

    //
    // Helpers
    //

    method FlattenType(aType: IType): IType;
    begin
      loop begin
        case aType type of
          ILinkType: aType := (aType as ILinkType).SubType;
          IRemappedType: aType := (aType as IRemappedType).RealType;
          IWrappedNullableType: aType := (aType as IWrappedNullableType).SubType;
          INotNullableType: aType := (aType as INotNullableType).SubType;
          else break;
        end;
      end;
      result := aType;
    end;

    method GetCoderFunctionName(aType: IType; aDirection: Direction): tuple of (String, IType, IType);
    begin

      aType := FlattenType(aType);

      var lCoderFunction: String;
      var lCoderType: IType;
      var lName := aType.Fullname;
      if lName.StartsWith("RemObjects.Elements.System.") then
        lName := lName.Substring(20) // Let Island system types fall back to the names of .NET System types
      else if lName.StartsWith("RemObjects.Oxygene.System.") then
        lName := lName.Substring(19) // Let Island system types fall back to the names of .NET System types
      else if lName.StartsWith("nullable ") then
        lName := lName.Substring(9); // happens for Cocoa numbers

      if fServices.Platform = Platform.Cooper then
        lName := lName.SubstringToFirstOccurrenceOf("<"); // for some reaosn hasmap has the full parameters in the name

      //Log($"lName {lName}");
      case lName of
        "RemObjects.Elements.RTL.PlatformString", // why does nullable Stirng NOW have "RemObjects.Elements.RTL.PlatformString", but regular has System?
        "RemObjects.Elements.RTL.String", // why does nullable Stirng have "RemObjects.Elements.RTL.String", bnut regular has System?
        "Foundation.NSString",
        "java.lang.String",
        "System.String": lCoderFunction := "String";

        "RemObjects.Elements.RTL.Guid",
        "Foundation.NSUUID",
        "java.util.UUID",
        "System.Guid": lCoderFunction := "Guid";

        "RemObjects.Elements.RTL.DateTime",
        "Foundation.NSDate",
        "java.util.Calendar",
        "System.DateTime": lCoderFunction := "DateTime";

        "RemObjects.Elements.RTL.JsonNode": lCoderFunction := "JsonNode";
        "RemObjects.Elements.RTL.JsonArray": lCoderFunction := "JsonArray";
        "RemObjects.Elements.RTL.JsonObject": lCoderFunction := "JsonObject";

        "System.Int8",   "System.SByte", "System.UnsignedByte": lCoderFunction := "Int8";
        "System.Int16",  "System.SmallInt", "java.lang.Short": lCoderFunction := "Int16";
        "System.Int32",  "System.Integer",  "java.lang.Integer": lCoderFunction := "Int32";
        "System.Int64",  "java.lang.Long": lCoderFunction := "Int64";
        "System.UInt8",  "System.Byte", "java.lang.Byte": lCoderFunction := "UInt8";
        "System.UInt16", "System.Word", "System.UnsignedShort": lCoderFunction := "UInt16";
        "System.UInt32", "System.Cardinal", "System.UnsignedInteger": lCoderFunction := "UInt32";
        "System.UInt64", "System.UnsignedLong": lCoderFunction := "UInt64";

        "System.IntPtr", "System.NativeInt": lCoderFunction := "IntPtr";
        "System.UIntPtr", "System.NativeUInt": lCoderFunction := "UIntPtr";

        "System.Single": lCoderFunction := "Single";
        "System.Double": lCoderFunction := "Double";
        "System.Boolean": lCoderFunction := "Boolean";

        else begin
          if ((aDirection = Direction.Encode) and IsEncodable(aType)) or ((aDirection = Direction.Decode) and IsDecodable(aType)) then begin
            lCoderFunction := "Object";
            lCoderType := aType;
            //Log($"Decode: treating '{lType.Fullname}' as decodale object");
          end
          else if aType is var lArrayType: IArrayType then begin
            lCoderFunction := "Array";
            lCoderType := FlattenType(lArrayType.SubType);
          end
          else if aType is var lGeneric: IGenericInstantiationType then begin
            var lType := FlattenType(lGeneric.GenericType);

            case lType.Fullname of

              "System.Nullable`1",
              "RemObjects.Elements.System.Nullable`1": begin
                  var lNestedType := lGeneric.GetParameter(0);
                  var lNestedCoderFunction := GetCoderFunctionName(lNestedType, aDirection);
                  if assigned(lNestedCoderFunction[0]) then
                    lCoderFunction := /*"Nullable"+*/lNestedCoderFunction[0];
                end;

              "java.util.ArrayList",
              "Foundation.NSArray",
              "Foundation.NSMutableArray",
              "System.Collections.Generic.List`1",
              "RemObjects.Elements.System.List`1",
              "RemObjects.Elements.RTL.List`1",
              "RemObjects.Elements.RTL.ImmutableList`1": begin

                  var lNestedType := lGeneric.GetParameter(0);
                  lCoderFunction := "List";
                  lCoderType := FlattenType(lNestedType);
                  if not assigned(GetCoderFunctionName(lCoderType, aDirection)[0]) then
                    exit (nil, nil, lNestedType);

                end;

              "java.util.HashMap",
              "Foundation.NSDictionary",
              "Foundation.NSMutableDictionary",
              "System.Collections.Generic.Dictionary`2",
              "RemObjects.Elements.System.Dictionary`2",
              "RemObjects.Elements.RTL.Dictionary`1",
              "RemObjects.Elements.RTL.ImmutableDictionary`1": begin

                  var lKeyType := lGeneric.GetParameter(0);
                  var lNestedType := lGeneric.GetParameter(1);
                  lCoderFunction := "StringDictionary";
                  lCoderType := FlattenType(lNestedType);
                  if GetCoderFunctionName(FlattenType(lKeyType), aDirection)[0] ≠ "String" then // key must be String
                    exit (nil, nil, nil);
                  if not assigned(GetCoderFunctionName(lCoderType, aDirection)[0]) then
                    exit (nil, nil, lNestedType);

                end;

            "Foundation.NSNumber": begin

                var lNestedType := lGeneric.GetParameter(0);
                  exit GetCoderFunctionName(FlattenType(lNestedType), aDirection);

              end;

            else begin
                {$IF DEBUG}
                Log($"Unsupported generic type '{lType.Fullname}'");
                {$ENDIF}
              end;

            end; // case

          end
          else begin
            {$IF DEBUG}
            Log($"Unsupported type '{aType.Fullname}'");
            {$ENDIF}
          end;
        end;
      end;
      result := (lCoderFunction, lCoderType, nil);
    end;

    //
    //
    //

    method GetCodableProperties: sequence of IPropertyDefinition; iterator;
    begin
      for i := 0 to fType.PropertyCount-1 do begin
        var p := fType.GetProperty(i);
        //Log($"- {p.Name}: {p.Type.Name}");
        // Todo: check if it can be serialized
        yield p;
      end;
    end;

    method AdjustName(aName: String): String;
    begin
      result := case fNamingStyle of
        NamingStyle.AsIs: aName;
        NamingStyle.lowercase: aName:ToLowerInvariant;
        NamingStyle.UPPERCASE: aName:ToUpperInvariant;
        NamingStyle.PascalCase: ConvertToPascalCase(aName);
        NamingStyle.camelCase: ConvertToCamelCase(aName);
        else raise new Exception($"The '{fNamingStyle}' naming style is not implemented yet");
      end;
    end;

    method ConvertToPascalCase(aName: String): String; //special handling form ID -> Id
    begin
      var lChars := aName.ToCharArray;
      var i := 0;
      lChars[i] := Char.ToUpperInvariant(lChars[i]);
      while i < length(lChars) do begin
        if (lChars[i] = 'I') and (i < length(lChars)) then begin
          if (i = length(lChars)-2) and (lChars[i+1] = "d") then begin
            lChars[i+1] := 'D';
            break;
          end
        end;
        inc(i);
      end;
      result := new String(lChars);
    end;

    method ConvertToCamelCase(aName: String): String;
    begin
      if length(aName) = 0 then
        exit aName;
      var lChars := aName.ToCharArray;
      var i := 0;
      while i < length(lChars) do begin
        if Char.IsUpper(lChars[i]) then begin
          if (i = 0) then
            lChars[i] := Char.ToLowerInvariant(lChars[i]);
          inc(i);
          if (i < length(lChars)) and Char.IsUpper(lChars[i]) then begin
            while (i < length(lChars)-1) and Char.IsUpper(lChars[i]) and Char.IsUpper(lChars[i+1]) do begin
              lChars[i] := Char.ToLowerInvariant(lChars[i]);
              inc(i);
            end;
            if (i = length(lChars)-1) and Char.IsUpper(lChars[i]) then begin
              lChars[i] := Char.ToLowerInvariant(lChars[i]);
              inc(i);
            end;
          end;
        end;
        while (i < length(lChars)) and not Char.IsUpper(lChars[i]) do begin
          inc(i);
        end;
      end;
      result := new String(lChars);
    end;

    method AddInterface(aName: String);
    begin
      for i := 0 to fType.InterfaceCount-1 do
        if fType.GetInterface(i).Name = aName then
          exit;
      fType.AddInterface(fServices.GetType(aName));
    end;

    property VoidType: ITypeReference := case fServices.Platform of
      Platform.Echoes: fServices.GetType("System.Void");
      Platform.Island: fServices.GetType("RemObjects.Elements.System.Void");
      Platform.Toffee: nil;
      Platform.Cooper: nil;
      else raise new Exception($"Unsupported platform {fServices.Platform}.");
    end; lazy;

  end;

  //
  //
  //

  method TypeImplementsInterface(aType: IType; aName: String): Boolean;
  begin
    for i := 0 to aType.InterfaceCount-1 do begin
      if aType.GetInterface(i).Name = aName then
        exit true;
    end;
  end;

  method TypeHasAttribute(aType: IType; aName: String): Boolean;
  begin
    if aType is var lAttributesProvider: IAttributesProvider then
      for i := 0 to lAttributesProvider.AttributeCount-1 do
        if lAttributesProvider.GetAttribute(i).Type.Fullname = aName then
          exit true;
  end;

  method IsDecodable(aType: IType): Boolean;
  begin
    result := TypeImplementsInterface(aType, "RemObjects.Elements.Serialization.IDecodable") or
              TypeHasAttribute(aType, "RemObjects.Elements.Serialization.DecodableAspect") or
              TypeHasAttribute(aType, "RemObjects.Elements.Serialization.CodableAspect") or
              assigned(aType.ParentType) and IsDecodable(aType.ParentType);
  end;

  method IsEncodable(aType: IType): Boolean;
  begin
    result := TypeImplementsInterface(aType, "RemObjects.Elements.Serialization.IEncodable") or
              TypeHasAttribute(aType, "RemObjects.Elements.Serialization.EncodableAspect") or
              TypeHasAttribute(aType, "RemObjects.Elements.Serialization.CodableAspect") or
              assigned(aType.ParentType) and IsEncodable(aType.ParentType);

  end;

end.