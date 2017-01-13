namespace RemObjects.Elements.RTL;

type
  XmlException = public class({$IF TOFFEE}Foundation.NSException{$ELSE}Exception{$ENDIF})
  public
    constructor(aMessage: String; aRow: Integer; aColumn: Integer);
    begin
      {$IF TOFFEE}
      inherited initWithName('SugarException') reason(aMessage) userInfo(nil);
      {$ELSE}
      inherited constructor(aMessage+" at "+aRow+"/"+aColumn);
      {$ENDIF}
      Row := aRow;
      Column := aColumn;
    end;
    property Row: Integer;
    property Column: Integer;
  end;


end.