namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  StreamUsage = public class(Test)
  public
    method MemoryStreamTests;
    begin
      var lStream := new MemoryStream(5);
      var lArray := new Byte[5];
      var lToRead := new Byte[5];
      lArray := [9, 8, 7, 6, 5];
      Assert.AreEqual(lStream.Write(lArray, 5), 5);

      lStream.Position := 0;
      Assert.AreEqual(lStream.Position, 0);

      var lTmp := lStream.Read(lToRead, 1);
      Assert.AreEqual(lTmp, 1);
      Assert.AreEqual(lStream.Position, 1);
      Assert.AreEqual(lToRead[0], 9);
      lStream.Read(lToRead, 4);
      Assert.AreEqual(lToRead[0], 8);

      var lNewStream := new MemoryStream(5);
      lStream.CopyTo(lNewStream);

      lStream.Seek(2, SeekOrigin.Begin);
      Assert.AreEqual(lStream.Position, 2);
    end;

    method FileStreamTests;
    begin
      var lPath := Path.Combine(Environment.TempFolder, 'rtl2_tests');
      var lStream := new FileStream(lPath, FileOpenMode.Create);
      var lArray := new Byte[5];
      var lToRead := new Byte[5];
      lArray := [9, 8, 7, 6, 5];
      Assert.AreEqual(lStream.Write(lArray, 5), 5);
      lStream.Close;
      lStream := new FileStream(lPath, FileOpenMode.ReadOnly);

      var lTmp := lStream.Read(lToRead, 1);
      Assert.AreEqual(lTmp, 1);
      Assert.AreEqual(lStream.Position, 1);
      Assert.AreEqual(lToRead[0], 9);
      lStream.Read(lToRead, 4);
      Assert.AreEqual(lToRead[0], 8);

      var lNewStream := new MemoryStream(5);
      lStream.CopyTo(lNewStream);

      lStream.Seek(2, SeekOrigin.Begin);
      Assert.AreEqual(lStream.Position, 2);

      lStream.Close;
      File.Delete(lPath);
    end;

    method BinaryStreamTextTests;
    begin
      var lMemStream := new MemoryStream();
      var lTextStream := new BinaryStream(lMemStream, Encoding.UTF16LE);
      lTextStream.WriteString('Testing TextStream');
      
      lTextStream.BaseStream.Position := 0;
      var lString := lTextStream.ReadString(36);
      Assert.AreEqual(lString, 'Testing TextStream');
    end;

    method BinaryStreamTests;
    begin
      var lMemStream := new MemoryStream();
      var lBinary := new BinaryStream(lMemStream);
      lBinary.WriteInt16(32767);
      lBinary.WriteInt32(110000);
      lBinary.WriteDouble(8.75);
      lBinary.WriteByte(27);
      lBinary.WriteInt64(Int64(1234567890));

      lBinary.BaseStream.Position := 0;

      var lInt1 := lBinary.ReadInt16;
      var lInt2 := lBinary.ReadInt32;
      var lDouble := lBinary.ReadDouble;
      var lByte := lBinary.ReadByte;
      var lInt64 := lBinary.ReadInt64;

      Assert.AreEqual(lInt1, 32767);
      Assert.AreEqual(lInt2, 110000);
      Assert.AreEqual(lDouble, 8.75);
      Assert.AreEqual(lByte, 27);
      Assert.AreEqual(lInt64, 1234567890);
    end;
  end;

end.