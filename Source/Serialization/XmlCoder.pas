namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.RTL;

type
  XmlCoder = public partial class(GenericCoder<XmlElement>)
  public

    constructor;
    begin
      {$IF NOT SERIALIZATION}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
    end;

    {$IF NOT WEBASSEMBLY}
    constructor withFile(aFileName: String);
    begin
      {$IF NOT SERIALIZATION}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
      constructor withXml(XmlDocument.FromFile(aFileName).Root);
    end;
    {$ENDIF}


    constructor withXml(aXml: XmlElement);
    begin
      {$IF NOT SERIALIZATION}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
      Xml := aXml;
      Hierarchy.Push(Xml);
    end;

    property Xml: XmlElement;

    [ToString]
    method ToString: String; override;
    begin
      result := XmlDocument.WithRootElement(Xml).ToString(XmlFormattingOptions.StandardReadableStyle);
    end;

  end;

end.