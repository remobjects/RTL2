namespace RemObjects.Elements.RTL;

type
  CharExtensions = public extension record(Char)
  public

    method ToLower: Char;
    begin
      {$IF COOPER}
      result := Character.toLowerCase(self);
      {$ELSEIF TOFFEE}
      result := chr(rtl.toLower(ord(self)));
      {$ELSEIF ECHOES}
      result := Char.ToLower(self);
      {$ELSEIF ISLAND}
      result := self.ToLower();
      {$ENDIF}
    end;

    //method ToLowerInvariant: Char;
    //begin
      //{$IF COOPER}
      //result := Character.toLowerCase(self);
      //{$ELSEIF TOFFEE}
      //result := chr(rtl.toLower(ord(self)));
      //{$ELSEIF ECHOES}
      //result := Char.ToLowerInvariant(self);
      //{$ELSEIF ISLAND}
      //result := self.ToLower();
      //{$ENDIF}
    //end;

    method ToUpperChar: Char; assembly;
    begin
      {$IF COOPER}
      result := Character.toUpperCase(self);
      {$ELSEIF TOFFEE}
      result := chr(rtl.toupper(ord(self)));
      {$ELSEIF ECHOES}
      result := Char.ToUpper(self);
      {$ELSEIF ISLAND}
      result := self.ToUpper();
      {$ENDIF}
    end;

    //method ToUpperCharInvariant: Char; assembly;
    //begin
      //{$IF COOPER}
      //result := Character.toUpperCase(self);
      //{$ELSEIF TOFFEE}
      //result := chr(rtl.toupper(ord(self)));
      //{$ELSEIF ECHOES}
      //result := Char.ToUpper(self);
      //{$ELSEIF ISLAND}
      //result := self.ToUpper();
      //{$ENDIF}
    //end;

    //
    //
    //

    property IsLatin: Boolean read ord(self) < length(Unicode.Latin1CharInfo); assembly;

    property IsWhitespace: Boolean read
    begin
      {$IF COOPER}
      result := java.lang.Character.isWhitespace(self);
      {$ELSEIF TOFFEE}
      result := Foundation.NSCharacterSet.whitespaceAndNewlineCharacterSet.characterIsMember(self);
      {$ELSEIF ECHOES OR ISLAND}
      result := Char.IsWhiteSpace(self);
      {$ENDIF}
    end;

    property IsLetter: Boolean read
    begin
      {$IF COOPER}
      result := java.lang.Character.isLetter(self);
      {$ELSEIF TOFFEE}
      result := Foundation.NSCharacterSet.letterCharacterSet.characterIsMember(self);
      {$ELSEIF ECHOES}
      result := Char.IsLetter(self);
      {$ELSEIF ISLAND}
      if IsLatin then
        result := (Unicode.Latin1CharInfo[ord(self)] and (Unicode.IsUpperCaseLetterFlag or Unicode.IsLowerCaseLetterFlag)) ≠ 0;
      {$HINT does not cover > Latin characters yet }
      {$ENDIF}
    end;

    property IsNumber: Boolean read
    begin
      {$IF COOPER}
      result := java.lang.Character.isDigit(self);
      {$ELSEIF TOFFEE}
      result := Foundation.NSCharacterSet.decimalDigitCharacterSet.characterIsMember(self);
      {$ELSEIF ECHOES OR ISLAND}
      result := Char.IsNumber(self);
      {$ENDIF}
    end;

    property IsLetterOrNumber: Boolean read
    begin
      {$IF COOPER}
      result := java.lang.Character.isLetterOrDigit(self);
      {$ELSEIF TOFFEE}
      result := Foundation.NSCharacterSet.alphanumericCharacterSet.characterIsMember(self);
      {$ELSEIF ECHOES}
      result := Char.IsLetter(self) or Char.IsNumber(self);
      {$ELSEIF ISLAND}
      result := IsLetter or IsNumber;
      {$ENDIF}
    end;

    property IsUpper: Boolean read
    begin
      {$IF COOPER}
      result := java.lang.Character.isUpperCase(self);
      {$ELSEIF TOFFEE}
      result := Foundation.NSCharacterSet.uppercaseLetterCharacterSet.characterIsMember(self);
      {$ELSEIF ECHOES}
      result := Char.IsUpper(self);
      {$ELSEIF ISLAND}
      if IsLatin then
        result := (Unicode.Latin1CharInfo[ord(self)] and (Unicode.IsUpperCaseLetterFlag)) ≠ 0;
      {$HINT does not cover > Latin characters yet }
      {$ENDIF}
    end;

    property IsLower: Boolean read
    begin
      {$IF COOPER}
      result := java.lang.Character.isLowerCase(self);
      {$ELSEIF TOFFEE}
      result := Foundation.NSCharacterSet.lowercaseLetterCharacterSet.characterIsMember(self);
      {$ELSEIF ECHOES}
      result := Char.IsLower(self);
      {$ELSEIF ISLAND}
      if IsLatin then
        result := (Unicode.Latin1CharInfo[ord(self)] and (Unicode.IsLowerCaseLetterFlag)) ≠ 0;
      {$HINT does not cover > Latin characters yet }
      {$ENDIF}
    end;

    property IsDigit: Boolean read
    begin
      {$IF COOPER}
      result := java.lang.Character.isDigit(self);
      {$ELSEIF TOFFEE}
      result := Foundation.NSCharacterSet.decimalDigitCharacterSet.characterIsMember(self);
      {$ELSEIF ECHOES}
      result := Char.IsDigit(self);
      {$ELSEIF ISLAND}
      result := Char.IsNumber(self)
      {$ENDIF}
    end;

  end;

  CharArrayExtensions = public extension record(array of Char)
  public

    method ContainsChar(aChar: Char): Boolean;
    begin
      for i: Integer := 0 to RemObjects.Elements.System.length(self)-1 do
        if self[i] = aChar then
          exit true;
    end;

    class operator &Add(Value1: array of Char; Value2: array of Char): array of Char;
    begin
      var len1 := RemObjects.Elements.System.length(Value1);
      var len2 := RemObjects.Elements.System.length(Value2);
      result := new Char[len1+len2];
      for i: Integer := 0 to len1-1 do
        result[i] := Value1[i];
      for i: Integer := 0 to len2-1 do
        result[len1+i] := Value2[i];
    end;

  end;

end.