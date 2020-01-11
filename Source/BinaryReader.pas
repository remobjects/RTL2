namespace RemObjects.Elements.RTL;

type
  Endianess = public enum(Little, Big);

  BinaryReader = public class
  public

    constructor withBinary(aBinary: Binary) InitialOffset(aOffset: UInt64 := 0);
    begin
      constructor withBytes(aBinary.ToArray) InitialOffset(aOffset);
    end;

    constructor withBytes(aBytes: array of Byte) InitialOffset(aOffset: UInt64 := 0);
    begin
      fBytes := aBytes;
      fOffset := aOffset;
    end;

    property Endianess: Endianess := Endianess.Little;
    property Offset: UInt64 read fOffset write fOffset;

    //
    // Read at specific offset
    //

    method ReadUInt64(aOffset: UInt64): UInt64; inline;
    begin
      result := ReadUInt64(var aOffset);
    end;

    method ReadUInt32(aOffset: UInt64): UInt32; inline;
    begin
      result := ReadUInt32(var aOffset);
    end;

    method ReadUInt16(aOffset: UInt64): UInt16; inline;
    begin
      result := ReadUInt16(var aOffset);
    end;

    method ReadUInt8(aOffset: UInt64): UInt16; inline;
    begin
      result := ReadUInt8(var aOffset);
    end;

    //

    method ReadUInt64(var aOffset: UInt64): UInt64;
    begin
      case Endianess of
        Endianess.Little: result := ReadUInt64LE(var aOffset);
        Endianess.Big: result := ReadUInt64BE(var aOffset);
      end;
    end;

    method ReadUInt32(var aOffset: UInt64): UInt32;
    begin
      case Endianess of
        Endianess.Little: result := ReadUInt32LE(var aOffset);
        Endianess.Big: result := ReadUInt32BE(var aOffset);
      end;
    end;

    method ReadUInt16(var aOffset: UInt64): UInt16;
    begin
      case Endianess of
        Endianess.Little: result := ReadUInt16LE(var aOffset);
        Endianess.Big: result := ReadUInt16BE(var aOffset);
      end;
    end;

    //

    method ReadUInt64LE(var aOffset: UInt64): UInt32;
    begin
      result := (UInt64(fBytes[aOffset+0])) +
                (UInt64(fBytes[aOffset+1]) shl  8) +
                (UInt64(fBytes[aOffset+2]) shl 16) +
                (UInt64(fBytes[aOffset+3]) shl 24) +
                (UInt64(fBytes[aOffset+4]) shl 31) +
                (UInt64(fBytes[aOffset+5]) shl 40) +
                (UInt64(fBytes[aOffset+6]) shl 48) +
                (UInt64(fBytes[aOffset+7]) shl 56);;
      inc(aOffset, 8);
    end;

    method ReadUInt64BE(var aOffset: UInt64): UInt32;
    begin
      result := (UInt64(fBytes[aOffset+7])) +
                (UInt64(fBytes[aOffset+6]) shl  8) +
                (UInt64(fBytes[aOffset+5]) shl 16) +
                (UInt64(fBytes[aOffset+4]) shl 24) +
                (UInt64(fBytes[aOffset+3]) shl 31) +
                (UInt64(fBytes[aOffset+2]) shl 40) +
                (UInt64(fBytes[aOffset+1]) shl 48) +
                (UInt64(fBytes[aOffset+0]) shl 56);;
      inc(aOffset, 8);
    end;

    method ReadUInt32LE(var aOffset: UInt64): UInt32;
    begin
      result := (fBytes[aOffset+0]) + (fBytes[aOffset+1] shl 8) + (fBytes[aOffset+2] shl 16) + (fBytes[aOffset+3] shl 24);
      inc(aOffset, 4);
    end;

    method ReadUInt32BE(var aOffset: UInt64): UInt32;
    begin
      result := (fBytes[aOffset+3]) + (fBytes[aOffset+2] shl 8) + (fBytes[aOffset+1] shl 16) + (fBytes[aOffset+0] shl 24);
      inc(aOffset, 4);
    end;

    method ReadUInt16LE(var aOffset: UInt64): UInt16;
    begin
      result := (fBytes[aOffset+0]) + (fBytes[aOffset+1] shl 8);
      inc(aOffset, 2);
    end;

    method ReadUInt16BE(var aOffset: UInt64): UInt16;
    begin
      result := (fBytes[aOffset+1]) + (fBytes[aOffset+0] shl 8);
      inc(aOffset, 2);
    end;

    method ReadUInt8(var aOffset: UInt64): Byte;
    begin
      result := fBytes[aOffset];
      inc(aOffset);
    end;

    method ReadULEB128(var aOffset: UInt64): UInt32;
    begin
      var lByte := fBytes[aOffset];
      result := lByte and $7f;
      var lShift := 0;
      while lByte and $80 > 0 do begin
        inc(aOffset);
        inc(lShift);
        lByte := fBytes[aOffset];
        result := result + (lByte and $7f) shl (lShift*7);
      end;
      inc(aOffset);
    end;

    method ReadStringWithULEB128LengthIndicator(var aOffset: UInt64) Encoding(aEncoding: Encoding := Encoding.UTF8): String;
    begin
      var lLength := ReadULEB128(var aOffset);
      result := aEncoding.GetString(fBytes, aOffset, lLength);
      inc(aOffset, lLength);
    end;

    method ReadStringWithULEB128LengthIndicator(aOffset: UInt64) Encoding(aEncoding: Encoding := Encoding.UTF8): String; inline;
    begin
      result := ReadStringWithULEB128LengthIndicator(var aOffset) Encoding(aEncoding);
    end;

    //
    // Read at current offset
    //

    method &Skip(aByteCount: UInt64);
    begin
      inc(fOffset, aByteCount);
    end;

    method ReadUInt32: UInt32;
    begin
      result := ReadUInt32(var fOffset);
    end;

  private

    var fBytes: array of Byte;
    var fOffset: UInt64;

  end;

end.