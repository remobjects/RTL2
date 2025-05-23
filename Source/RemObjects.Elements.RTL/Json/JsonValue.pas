﻿namespace RemObjects.Elements.RTL;

type
  JsonValue<T> = public abstract readonly class(JsonNode)
  public

    constructor(aValue: not nullable T);
    begin
      Value := aValue;
    end;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): not nullable String; override;
    begin
      result := Value.ToString as not nullable;
    end;

    [ToString]
    method ToString: String;
    begin
      result := ToJsonString;
    end;

    [&Equals]
    method &Equals(Obj: Object): Boolean; override;
    begin
      if (Obj = nil) or (not (Obj is JsonValue<T>)) then
        exit false;

      result := self.Value.Equals(JsonValue<T>(Obj).Value);
    end;

    [Hash]
    method GetHashCode: Integer; override;
    begin
      result := if self.Value = nil then -1 else self.Value.GetHashCode;
    end;

    property Value: not nullable T; readonly;

    operator Implicit(aValue: JsonValue<T>): T;
    begin
      result := aValue:Value;
    end;

    method UniqueCopy: InstanceType; override;
    begin
      result := self;
    end;

  end;

  //
  //
  //

  JsonStringValue = public class(JsonValue<not nullable String>)
  public

    property NodeKind: JsonNodeKind read JsonNodeKind.String; override;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String; override;
    begin
      var sb := new StringBuilder;

      sb.Append(JsonConsts.STRING_QUOTE);
      for i: Int32 := 0 to Value.Length-1 do begin
        var c := Value[i];
        case c of
          '\': sb.Append("\\");
          '"': sb.Append('\"');
          #8: sb.Append('\b');
          #9: sb.Append('\t');
          #10: sb.Append('\n');
          #12: sb.Append('\f');
          #13: sb.Append('\r');
          #32..#33,
          #35..#91,
          #93..#127: sb.Append(c);
          else sb.Append('\u'+Convert.ToHexString(Int32(c), 4));
        end;
      end;
      sb.Append(JsonConsts.STRING_QUOTE);

      result := sb.ToString();
    end;

    operator Implicit(aValue: nullable String): JsonStringValue;
    begin
      if assigned(aValue) then
        result := new JsonStringValue(aValue);
    end;

    operator Implicit(aValue: nullable JsonStringValue): string;
    begin
      result := aValue:StringValue;
    end;

    operator Equal(aLeft: JsonStringValue; aRight: Object): Boolean;
    begin
      if not assigned(aLeft) and not assigned(aRight) then exit true;
      if not assigned(aLeft) then exit false;
      if not assigned(aRight) then exit false;
      if aRight is String then exit aLeft.Value = (aRight as String);
      if aRight is JsonStringValue then exit aLeft.Value = (aRight as JsonStringValue).Value;
    end;

    operator Equal(aLeft: Object; aRight: JsonStringValue): Boolean;
    begin
      result := aRight = aLeft;
    end;

    operator &Equal(lhs: JsonStringValue; rhs: JsonStringValue): Boolean;
    begin
      if Object(lhs) = Object(rhs) then
        exit true;
      if not assigned(lhs) or not assigned(rhs) then
        exit false;

      result := lhs.Value = rhs.Value;
    end;

    operator &Equal(lhs: JsonStringValue; rhs: String): Boolean;
    begin
      result := lhs:Value = rhs;
    end;

    operator &Equal(lhs: String; rhs: JsonStringValue): Boolean;
    begin
      result := lhs = rhs:Value;
    end;

  end;

  //
  //
  //

  JsonIntegerValue = public class(JsonValue<Int64>)
  public

    property NodeKind: JsonNodeKind read JsonNodeKind.Integer; override;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String; override;
    begin
      result := Convert.ToString(Value);
    end;

    operator Implicit(aValue: Int64): JsonIntegerValue;
    begin
      result := new JsonIntegerValue(aValue);
    end;

    operator Implicit(aValue: Int32): JsonIntegerValue;
    begin
      result := new JsonIntegerValue(aValue);
    end;

    operator Implicit(aValue: JsonIntegerValue): JsonFloatValue;
    begin
      result := new JsonFloatValue(aValue.Value);
    end;

    operator Implicit(aValue: JsonIntegerValue): not nullable Int32;
    begin
      result := aValue.Value;
    end;

    operator Implicit(aValue: JsonIntegerValue): not nullable Double;
    begin
      result := aValue.Value;
    end;

    operator Implicit(aValue: JsonIntegerValue): not nullable Single;
    begin
      result := aValue.Value;
    end;

    operator &Equal(lhs: JsonIntegerValue; rhs: JsonIntegerValue): Boolean;
    begin
      if Object(lhs) = Object(rhs) then
        exit true;
      if not assigned(lhs) or not assigned(rhs) then
        exit false;

      result := lhs.Value = rhs.Value;
    end;

    operator &Equal(lhs: JsonIntegerValue; rhs: Integer): Boolean;
    begin
      result := lhs:Value = rhs;
    end;

    operator &Equal(lhs: Integer; rhs: JsonIntegerValue): Boolean;
    begin
      result := lhs = rhs:Value;
    end;

  end;

  //
  //
  //

  //JsonUnsignedIntegerValue = public class(JsonValue<UInt64>)
  //public
    //method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String; override;
    //operator Implicit(aValue: UInt64): JsonUnsignedIntegerValue;
    //operator Implicit(aValue: UInt32): JsonUnsignedIntegerValue;
    //operator Implicit(aValue: JsonUnsignedIntegerValue): JsonFloatValue;

    //operator Implicit(aValue: JsonUnsignedIntegerValue): not nullable UInt32;
    //operator Implicit(aValue: JsonUnsignedIntegerValue): not nullable Double;
    //operator Implicit(aValue: JsonUnsignedIntegerValue): not nullable Single;

    ////property IntegerValue: Integer read Value write Value; override;
    ////property FloatValue: Double read Value write inherited IntegerValue; override;
    ////property StringValue: String read ToJsonString write ToJsonString; override;
  //end;

  //
  //
  //

  JsonFloatValue = public class(JsonValue<Double>)
  public

    property NodeKind: JsonNodeKind read JsonNodeKind.Float; override;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String; override;
    begin
      result := Convert.ToStringInvariant(Value).Replace(",","");
      if not result.Contains(".") and not result.Contains("E") and not result.Contains("N") and not result.Contains("I") then result := result+".0";
    end;

    operator Implicit(aValue: Double): JsonFloatValue;
    begin
      result := new JsonFloatValue(aValue);
    end;

    operator Implicit(aValue: Single): JsonFloatValue;
    begin
      result := new JsonFloatValue(aValue);
    end;

    operator Implicit(aValue: JsonFloatValue): Single;
    begin
      result := aValue.Value;
    end;

    //property FloatValue: Double read Value write Value; override;
    //property IntegerValue: Int64 read Value write Value; override;
    //property StringValue: String read ToJsonString write ToJsonString; override;

    operator &Equal(lhs: JsonFloatValue; rhs: JsonFloatValue): Boolean;
    begin
      if Object(lhs) = Object(rhs) then
        exit true;
      if not assigned(lhs) or not assigned(rhs) then
        exit false;

      result := lhs.Value = rhs.Value;
    end;

    operator &Equal(lhs: JsonFloatValue; rhs: Double): Boolean;
    begin
      result := lhs.Value = rhs;
    end;

    operator &Equal(lhs: Double; rhs: JsonFloatValue): Boolean;
    begin
      result := lhs = rhs:Value;
    end;


  end;

  //
  //
  //

  JsonBooleanValue = public class(JsonValue<Boolean>)
  public

    property NodeKind: JsonNodeKind read JsonNodeKind.Boolean; override;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String; override;
    begin
      result := if Value as Boolean then JsonConsts.TRUE_VALUE else JsonConsts.FALSE_VALUE;
    end;

    operator Implicit(aValue: Boolean): JsonBooleanValue;
    begin
      result := new JsonBooleanValue(aValue);
    end;

    //property BooleanValue: Boolean read Value write Value; override;
    //property StringValue: String read ToJsonString write ToJsonString; override;

    operator &Equal(lhs: JsonBooleanValue; rhs: JsonBooleanValue): Boolean;
    begin
      if Object(lhs) = Object(rhs) then
        exit true;
      if not assigned(lhs) or not assigned(rhs) then
        exit false;

      result := lhs.Value = rhs.Value;
    end;

    operator &Equal(lhs: JsonBooleanValue; rhs: Boolean): Boolean;
    begin
      result := lhs:Value = rhs;
    end;

    operator &Equal(lhs: Boolean; rhs: JsonBooleanValue): Boolean;
    begin
      result := lhs = rhs:Value;
    end;

    class property &True: not nullable JsonBooleanValue := new JsonBooleanValue(true); lazy;
    class property &False: not nullable JsonBooleanValue := new JsonBooleanValue(false); lazy;

  end;

  //
  //
  //

  JsonNullValue = public class(JsonValue<Boolean>)
  public

    property NodeKind: JsonNodeKind read JsonNodeKind.Null; override;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String; override;
    begin
      result := JsonConsts.NULL_VALUE;
    end;

    class property Null: not nullable JsonNullValue := new JsonNullValue; lazy;

  private

    constructor;
    begin
      inherited constructor(false);
    end;

    operator &Equal(lhs: JsonNullValue; rhs: JsonNullValue): Boolean;
    begin
      exit true;
    end;

    operator &Equal(lhs: JsonNullValue; rhs: Object): Boolean;
    begin
      exit not assigned(rhs);
    end;

    operator &Equal(lhs: Object; rhs: JsonNullValue): Boolean;
    begin
      exit not assigned(lhs);
    end;

  end;

{ JsonUnsignedIntegerValue }

//method JsonUnsignedIntegerValue.ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String;
//begin
  //result := Convert.ToString(Value);
//end;

//operator JsonUnsignedIntegerValue.Implicit(aValue: UInt64): JsonUnsignedIntegerValue;
//begin
  //result := new JsonUnsignedIntegerValue(aValue);
//end;

//operator JsonUnsignedIntegerValue.Implicit(aValue: UInt32): JsonUnsignedIntegerValue;
//begin
  //result := new JsonUnsignedIntegerValue(aValue);
//end;

//operator JsonUnsignedIntegerValue.Implicit(aValue: JsonUnsignedIntegerValue): JsonFloatValue;
//begin
  //result := new JsonFloatValue(aValue.Value);
//end;

//operator JsonUnsignedIntegerValue.Implicit(aValue: JsonUnsignedIntegerValue): not nullable UInt32;
//begin
  //result := aValue.Value;
//end;

//operator JsonUnsignedIntegerValue.Implicit(aValue: JsonUnsignedIntegerValue): not nullable Double;
//begin
  //result := aValue.Value;
//end;

//operator JsonUnsignedIntegerValue.Implicit(aValue: JsonUnsignedIntegerValue): not nullable Single;
//begin
  //result := aValue.Value;
//end;

end.