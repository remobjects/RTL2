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

    method ToLowerInvariant: Char;
    begin
      {$IF COOPER}
      result := Character.toLowerCase(self);
      {$ELSEIF TOFFEE}
      result := chr(rtl.toLower(ord(self)));
      {$ELSEIF ECHOES}
      result := Char.ToLowerInvariant(self);
      {$ELSEIF ISLAND}
      result := self.ToLower();
      {$ENDIF}
    end;

    method ToUpperChar: Char; assembly;
    begin
      {$IF COOPER}
      result := Character.toUpperCase(self);
      {$ELSEIF TOFFEE}
      result := chr(toupper(ord(self)));
      {$ELSEIF ECHOES}
      result := Char.ToUpper(self);
      {$ELSEIF ISLAND}
      result := self.ToUpper();
      {$ENDIF}
    end;

    //
    //
    //

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
      {$WARNING Not Implemeted for Island}
      raise new NotImplementedException("Some String APIs are not implemented for Island yet.");
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
      {$WARNING Not Implemeted for Island}
      raise new NotImplementedException("Some String APIs are not implemented for Island yet.");
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

  end;

end.