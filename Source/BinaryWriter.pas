namespace RemObjects.Elements.RTL;

type
  BinaryWriter = public class
  public
    constructor withBinary(aBinary: Binary);
    begin
      fStream := aBinary;
    end;

    property Endianess: Endianess := Endianess.Little;

    // UInt64
    method WriteUInt64(value: UInt64);
    begin
      case Endianess of
        Endianess.Little: WriteUInt64LE(value);
        Endianess.Big: WriteUInt64BE(value);
      end;
    end;

    // UInt32
    method WriteUInt32(value: UInt32);
    begin
      case Endianess of
        Endianess.Little: WriteUInt32LE(value);
        Endianess.Big: WriteUInt32BE(value);
      end;
    end;

    // UInt16
    method WriteUInt16(value: UInt16);
    begin
      case Endianess of
        Endianess.Little: WriteUInt16LE(value);
        Endianess.Big: WriteUInt16BE(value);
      end;
    end;

    // Int64
    method WriteInt64(value: Int64);
    begin
      WriteUInt64(UInt64(value));
    end;

    // Int32
    method WriteInt32(value: Int32);
    begin
      WriteUInt32(UInt32(value));
    end;

    // Int16
    method WriteInt16(value: Int16);
    begin
      WriteUInt16(UInt16(value));
    end;

    // UInt8
    method WriteUInt8(value: Byte);
    begin
      fStream.Write([value], 0, 1);
    end;

    // Guid
    method WriteGuid(value: Guid);
    begin
      var bytes := value.ToByteArray();
      fStream.Write(bytes, 0, length(bytes));
    end;


    // Double
    method WriteDouble(value: Double);
    begin
      case Endianess of
        Endianess.Little: WriteDoubleLE(value);
        Endianess.Big: WriteDoubleBE(value);
      end;
    end;

    method WriteSingle(value: Single);
    begin
      case Endianess of
        Endianess.Little: WriteSingleLE(value);
        Endianess.Big: WriteSingleBE(value);
      end;
    end;

    method WriteDoubleLE(value: Double);
    begin
      {$IF ECHOES}
      WriteUInt64LE(BitConverter.DoubleToInt64Bits(value));
      {$ELSEIF COOPER}
      WriteInt64LE(Double.doubleToLongBits(value));
      {$ELSE}
      var lBuffer := new Byte[sizeOf(Double)];
      memcpy(@lBuffer[0], @value, sizeOf(Double));
      lBuffer.ReverseArray;
      WriteByteArray(lBuffer);
      {$ENDIF}
    end;

    method WriteDoubleBE(value: Double);
    begin
      {$IF ECHOES}
      WriteUInt64BE(BitConverter.DoubleToInt64Bits(value));
      {$ELSEIF COOPER}
      WriteInt64BE(Double.doubleToLongBits(value));
      {$ELSE}
      var lBuffer := new Byte[sizeOf(Double)];
      memcpy(@lBuffer[0], @value, sizeOf(Double));
      //lBuffer.ReverseArray;
      WriteByteArray(lBuffer);
      {$ENDIF}
    end;

    method WriteSingleLE(value: Single);
    begin
      {$IF ECHOES}
      WriteUInt32LE(BitConverter.DoubleToInt64Bits(value));
      {$ELSEIF COOPER}
      WriteInt32LE(Single.floatToIntBits(value));
      {$ELSE}
      var lBuffer := new Byte[sizeOf(Single)];
      memcpy(@lBuffer[0], @value, sizeOf(Single));
      lBuffer.ReverseArray;
      WriteByteArray(lBuffer);
      {$ENDIF}
    end;

    method WriteSingleBE(value: Single);
    begin
      {$IF ECHOES}
      WriteUInt32BE(BitConverter.DoubleToInt64Bits(value));
      {$ELSEIF COOPER}
      WriteUInt32BE(Single.floatToIntBits(value));
      {$ELSE}
      var lBuffer := new Byte[sizeOf(Single)];
      memcpy(@lBuffer[0], @value, sizeOf(Single));
      //lBuffer.ReverseArray;
      WriteByteArray(lBuffer);
      {$ENDIF}
    end;

    method WriteByteArray(aArray: array of Byte);
    begin
      fStream.Write(aArray);
    end;

  private
    var fStream: Binary;

    // Write methods for Little-Endian (LE) and Big-Endian (BE)

    // UInt64LE
    method WriteUInt64LE(value: UInt64);
    begin
      var bytes: array of Byte := [
        Byte(value and $ff),
        Byte((value shr 8) and $ff),
        Byte((value shr 16) and $ff),
        Byte((value shr 24) and $ff),
        Byte((value shr 32) and $ff),
        Byte((value shr 40) and $ff),
        Byte((value shr 48) and $ff),
        Byte((value shr 56) and $ff)
      ];
      fStream.Write(bytes, 0, 8);
    end;

    // UInt64BE
    method WriteUInt64BE(value: UInt64);
    begin
      var bytes: array of Byte := [
        Byte((value shr 56) and $ff),
        Byte((value shr 48) and $ff),
        Byte((value shr 40) and $ff),
        Byte((value shr 32) and $ff),
        Byte((value shr 24) and $ff),
        Byte((value shr 16) and $ff),
        Byte((value shr 8) and $ff),
        Byte(value and $ff)
      ];
      fStream.Write(bytes, 0, 8);
    end;

    // UInt32LE
    method WriteUInt32LE(value: UInt32);
    begin
      var bytes: array of Byte := [
        Byte(value and $ff),
        Byte((value shr 8) and $ff),
        Byte((value shr 16) and $ff),
        Byte((value shr 24) and $ff)
      ];
      fStream.Write(bytes, 0, 4);
    end;

    // UInt32BE
    method WriteUInt32BE(value: UInt32);
    begin
      var bytes: array of Byte := [
        Byte((value shr 24) and $ff),
        Byte((value shr 16) and $ff),
        Byte((value shr 8) and $ff),
        Byte(value and $ff)
      ];
      fStream.Write(bytes, 0, 4);
    end;

    // UInt16LE
    method WriteUInt16LE(value: UInt16);
    begin
      var bytes: array of Byte := [
        Byte(value and $ff),
        Byte((value shr 8) and $ff)
      ];
      fStream.Write(bytes, 0, 2);
    end;

    // UInt16BE
    method WriteUInt16BE(value: UInt16);
    begin
      var bytes: array of Byte := [
        Byte((value shr 8) and $ff),
        Byte(value and $ff)
      ];
      fStream.Write(bytes, 0, 2);
    end;

//

    // Int64LE
    method WriteInt64LE(value: Int64);
    begin
      WriteUInt64LE(value as UInt64);
    end;

    // Int64BE
    method WriteInt64BE(value: Int64);
    begin
      WriteUInt64BE(value as UInt64);
    end;

    // Int32LE
    method WriteInt32LE(value: Int32);
    begin
      WriteUInt32LE(value as UInt32);
    end;

    // Int32BE
    method WriteInt32BE(value: Int32);
    begin
      WriteUInt32BE(value as UInt32);
    end;

    // Int16LE
    method WriteInt16LE(value: Int16);
    begin
      WriteUInt16LE(value as UInt16);
    end;

    // Int16BE
    method WriteInt16BE(value: Int16);
    begin
      WriteUInt16BE(value as UInt16);
    end;

    // Int8
    method WriteInt8(value: SByte);
    begin
      WriteUInt8(value as Byte);
    end;
  end;

end.