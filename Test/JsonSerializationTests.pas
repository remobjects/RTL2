namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  JsonSerializationTests = public class(Test)
  private

    method Alpha(aContext: not nullable JsonObjectSerializationContext);
    begin
      aContext.Order := JsonKeyOrder.Alpha;
    end;

    method InvalidCustom(aKeys: nullable ImmutableList<String>);
    begin
      var lRoot := JsonObject.FromString('{"nested":{"a":1,"b":2}}');
      var lRejected := false;
      try
        lRoot.ToJsonString(c -> begin
          if c.Path = '/nested' then begin
            c.Order := JsonKeyOrder.Custom;
            c.CustomKeys := aKeys;
          end;
        end);
      except
        on E: JsonSerializationException do begin
          Check.IsTrue(E.Message.Contains('/nested'));
          lRejected := true;
        end;
      end;
      Check.IsTrue(lRejected, 'Invalid custom keys must be rejected');
    end;

  public

    method EmptyContainersStayInline;
    begin
      Check.AreEqual('{}', (new JsonObject).ToJsonString);
      Check.AreEqual('[]', (new JsonArray).ToJsonString);
      var lJson := JsonObject.FromString('{"empty":{},"items":[]}');
      var lNewLine := Environment.LineBreak;
      var lExpected := '{'+lNewLine+'  "empty": {},'+lNewLine+'  "items": []'+lNewLine+'}';
      Check.AreEqual(lExpected, lJson.ToJsonString(c -> Alpha(c)));
      Check.AreEqual('[{}]', JsonArray.FromString('[{}]').ToJsonString(JsonFormat.Minimal));
      Check.AreEqual('['+lNewLine+'  {},'+lNewLine+'  []'+lNewLine+']', JsonArray.FromString('[{},[]]').ToJsonString);
    end;

    method AsIsPreservesExistingOutputAndDocument;
    begin
      var lJson := JsonObject.FromString('{"z":1,"A":{"b":2,"a":3},"empty":{},"values":[3,2,1]}');
      var lKeys := lJson.Keys.JoinedString('|');
      for lFormat in [JsonFormat.HumanReadable, JsonFormat.Minimal] do begin
        var lBefore := lJson.ToJsonString(lFormat);
        Check.AreEqual(lBefore, lJson.ToJsonString(c -> begin
          Check.AreEqual(JsonKeyOrder.AsIs, c.Order);
          Check.IsNil(c.CustomKeys);
          c.Order := JsonKeyOrder.AsIs;
        end, lFormat));
        lJson.ToJsonString(c -> Alpha(c), lFormat);
        Check.AreEqual(lBefore, lJson.ToJsonString(lFormat));
      end;
      Check.AreEqual(lKeys, lJson.Keys.JoinedString('|'));
    end;

    method AlphaHasDeterministicCaseAndUnicodeOrder;
    begin
      var lJson := JsonObject.FromString('{"b":1,"a":3,"A":2,"Z":4,"":5,"ä":7,"Ä":6}');
      Check.AreEqual('{"":5,"A":2,"a":3,"b":1,"Z":4,"\u00C4":6,"\u00E4":7}', lJson.ToJsonString(c -> Alpha(c), JsonFormat.Minimal));
      var lParsed := JsonDocument.FromString(lJson.ToJsonString(c -> Alpha(c)), true);
      Check.IsTrue(lJson = lParsed);
    end;

    method CustomGroupingAndAlphaChildren;
    begin
      var lJson := JsonObject.FromString('{"Items":{"Compile":{"z.pas":{},"A.pas":{}}},"Settings":{"Optimize":true,"AssemblyName":"Example"}}');
      var lCalls := new List<String>;
      var lText := lJson.ToJsonString(c -> begin
        lCalls.Add(c.Path);
        Check.AreEqual(c.Node.Count, c.Keys.Count);
        if c.Path = '' then begin
          c.Order := JsonKeyOrder.Custom;
          c.CustomKeys := new List<String>('Settings', 'Items');
        end
        else begin
          c.Order := JsonKeyOrder.Alpha;
        end;
      end, JsonFormat.Minimal);
      Check.AreEqual('{"Settings":{"AssemblyName":"Example","Optimize":true},"Items":{"Compile":{"A.pas":{},"z.pas":{}}}}', lText);
      Check.AreEqual('|/Settings|/Items|/Items/Compile|/Items/Compile/A.pas|/Items/Compile/z.pas', lCalls.JoinedString('|'));
    end;

    method PathsIncludeArraysAndEscapedAndEmptyNames;
    begin
      var lJson := JsonObject.FromString('{"/~":[{},{"":[{}]}]}');
      var lPaths := new List<String>;
      Check.AreEqual('{"/~":[{},{"":[{}]}]}', lJson.ToJsonString(c -> lPaths.Add(c.Path), JsonFormat.Minimal));
      Check.AreEqual('|/~1~0/0|/~1~0/1|/~1~0/1//0', lPaths.JoinedString('|'));
    end;

    method RootArraysAndRepeatedObjectsVisitEachOccurrence;
    begin
      var lShared := JsonObject.FromString('{"b":2,"a":1}');
      var lArray := new JsonArray;
      lArray.Add(lShared);
      lArray.Add(new JsonIntegerValue(3));
      lArray.Add(lShared);
      var lPaths := new List<String>;
      var lText := lArray.ToJsonString(c -> begin
        lPaths.Add(c.Path);
        Check.IsTrue(c.Node = lShared);
        c.Order := JsonKeyOrder.Alpha;
      end, JsonFormat.Minimal);
      Check.AreEqual('[{"a":1,"b":2},3,{"a":1,"b":2}]', lText);
      Check.AreEqual('/0|/2', lPaths.JoinedString('|'));
    end;

    method EmptyCustomOrderIsValid;
    begin
      var lCalled := false;
      var lText := (new JsonObject).ToJsonString(c -> begin
        Check.AreEqual('', c.Path);
        Check.AreEqual(0, c.Keys.Count);
        c.Order := JsonKeyOrder.Custom;
        c.CustomKeys := new List<String>;
        lCalled := true;
      end);
      Check.IsTrue(lCalled);
      Check.AreEqual('{}', lText);
    end;

    method CustomOrderMustBeAnExactPermutation;
    begin
      InvalidCustom(nil);
      InvalidCustom(new List<String>('a'));
      InvalidCustom(new List<String>('a', 'b', 'extra'));
      InvalidCustom(new List<String>('a', 'a'));
      InvalidCustom(new List<String>('a', 'extra'));
      InvalidCustom(new List<String>('A', 'b'));
      var lNullKey := new List<String>('a', 'b');
      lNullKey[1] := nil;
      InvalidCustom(lNullKey);
    end;

    method EmptyObjectRejectsNonemptyCustomOrder;
    begin
      var lRejected := false;
      try
        (new JsonObject).ToJsonString(c -> begin
          c.Order := JsonKeyOrder.Custom;
          c.CustomKeys := new List<String>('extra');
        end);
      except
        on E: JsonSerializationException do
          lRejected := true;
      end;
      Check.IsTrue(lRejected);
    end;

    method CustomOrderPreservesCaseDistinctAndNullValuedKeys;
    begin
      var lJson := JsonObject.FromString('{"A":null,"a":1,"":2}');
      Check.AreEqual('{"a":1,"":2,"A":null}', lJson.ToJsonString(c -> begin
        c.Order := JsonKeyOrder.Custom;
        c.CustomKeys := new List<String>('a', '', 'A');
      end, JsonFormat.Minimal));
    end;

    method ScalarRootsAndAllStaticNodeTypesSupportTheOverload;
    begin
      var lCalls := 0;
      var lCallback: JsonObjectSerializationCallback := c -> inc(lCalls);
      var lObject := new JsonObject;
      var lArray := new JsonArray;
      var lValue := new JsonIntegerValue(42);
      var lNode: JsonNode := lObject;
      Check.AreEqual('{}', lObject.ToJsonString(lCallback));
      Check.AreEqual('{}', lNode.ToJsonString(lCallback));
      Check.AreEqual('[]', lArray.ToJsonString(lCallback));
      Check.AreEqual('42', lValue.ToJsonString(lCallback));
      Check.AreEqual('null', JsonDocument.FromString('null').ToJsonString(lCallback));
      Check.AreEqual(2, lCalls);
    end;

    method BytesAndBinaryHonorCallbackFormatEncodingAndBom;
    begin
      var lJson := JsonObject.FromString('{"b":2,"a":"ä"}');
      var lExpected := '{"a":"\u00E4","b":2}';
      Check.AreEqual(lExpected, Encoding.UTF8.GetString(lJson.ToJsonBytes(c -> Alpha(c))));
      Check.AreEqual(lExpected, Encoding.UTF8.GetString(lJson.ToJsonBinary(c -> Alpha(c))));
      for lFormat in [JsonFormat.HumanReadable, JsonFormat.Minimal] do begin
        var lText := lJson.ToJsonString(c -> Alpha(c), lFormat);
        var lBytes := lJson.ToJsonBytes(c -> Alpha(c), lFormat, Encoding.UTF8, true);
        var lBinary := lJson.ToJsonBinary(c -> Alpha(c), lFormat, Encoding.UTF16LE, false);
        Check.AreEqual(Byte($ef), lBytes[0]);
        Check.AreEqual(Byte($bb), lBytes[1]);
        Check.AreEqual(Byte($bf), lBytes[2]);
        Check.AreEqual(lText, Encoding.UTF8.GetString(lBytes));
        Check.AreEqual(lText, Encoding.UTF16LE.GetString(lBinary));
        Check.AreEqual(lText, Encoding.UTF8.GetString(lJson.ToJsonBytes(c -> Alpha(c), lFormat)));
      end;
    end;

    method CallbackExceptionsPropagate;
    begin
      var lRejected := false;
      try
        (new JsonObject).ToJsonString(c -> raise new JsonSerializationException('callback failure'));
      except
        on E: JsonSerializationException do begin
          Check.AreEqual('callback failure', E.Message);
          lRejected := true;
        end;
      end;
      Check.IsTrue(lRejected);
    end;

    {$IF NOT WEBASSEMBLY}
    method FileOutputAndFailuresPreserveExistingContent;
    begin
      var lFile: File := Path.Combine(Environment.TempFolder, 'rtl2-json-order-'+Guid.NewGuid.ToString+'.json');
      try
        var lJson := JsonObject.FromString('{"b":2,"a":"ä"}');
        lJson.SaveToFile(lFile, c -> Alpha(c), JsonFormat.Minimal, Encoding.UTF8, true);
        var lBytes := File.ReadBytes(lFile);
        Check.AreEqual(Byte($ef), lBytes[0]);
        Check.AreEqual(Byte($bb), lBytes[1]);
        Check.AreEqual(Byte($bf), lBytes[2]);
        Check.AreEqual('{"a":"\u00E4","b":2}', File.ReadText(lFile, Encoding.UTF8));
        lJson.SaveToFile(lFile, c -> Alpha(c));
        Check.AreEqual(lJson.ToJsonString(c -> Alpha(c)), File.ReadText(lFile));

        for lInvalidOrder in [false, true] do begin
          File.WriteText(lFile, 'keep existing content');
          var lRejected := false;
          try
            lJson.SaveToFile(lFile, c -> begin
              if lInvalidOrder then begin
                c.Order := JsonKeyOrder.Custom;
                c.CustomKeys := new List<String>('a', 'a');
              end
              else begin
                raise new JsonSerializationException('callback failure');
              end;
            end);
          except
            on E: JsonSerializationException do
              lRejected := true;
          end;
          Check.IsTrue(lRejected);
          Check.AreEqual('keep existing content', File.ReadText(lFile));
        end;
      finally
        if lFile.Exists then
          File.Delete(lFile);
      end;
    end;
    {$ENDIF}

  end;

end.
