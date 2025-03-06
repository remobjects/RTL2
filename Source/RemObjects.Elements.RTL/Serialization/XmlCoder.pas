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
      fXml := aXml;
      Hierarchy.Push(fXml);
    end;

    [ToString]
    method ToString: String; override;
    begin
      result := XmlDocument.WithRootElement(fXml).ToString(XmlFormattingOptions.StandardReadableStyle);
    end;

    method ToXml: XmlElement;
    begin
      result := fXml;
    end;

    method ToXmlString(aFormat: XmlFormattingOptions := nil): String;
    begin
      fXml.ToString(true, false, aFormat);
    end;

  private

    property fXml: XmlElement;

  end;

end.