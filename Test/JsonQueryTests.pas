namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  JsonQueryTests = public class(Test)
  private

    method Query(aQuery: String; aInput: String; aExpected: String);
    begin
      var lInput := JsonDocument.FromString(aInput, true);
      var lBefore := lInput.ToJsonString;
      var lQuery := new JsonQuery(aQuery);
      for i: Integer := 0 to 1 do begin
        var lResults := lQuery.Evaluate(lInput);
        var lArray := new JsonArray;
        for lResult in lResults do
          lArray.Add(lResult);
        Check.IsTrue(lArray = JsonDocument.FromString(aExpected, true), $"Query {aQuery}: {lArray.ToJsonString}");
        Check.AreEqual(lBefore, lInput.ToJsonString);
      end;
    end;

    method Reject(aQuery: String; aInput: String := 'null'; aOptions: JsonQueryOptions := nil);
    begin
      var lRejected := false;
      try
        new JsonQuery(aQuery).Evaluate(JsonDocument.FromString(aInput, true), aOptions);
      except
        on E: JsonQueryException do
          lRejected := true;
      end;
      Check.IsTrue(lRejected, $"Expected query rejection: {aQuery}");
    end;

  public

    method PathsAndStreams;
    begin
      Query('.', 'null', '[null]');
      Query('.a.b', '{"a":{"b":42}}', '[42]');
      Query('.missing.child', '{}', '[null]');
      Query('.a, .missing', '{"a":null}', '[null,null]');
      Query('.["a.b"][0]', '{"a.b":[1,2]}', '[1]');
      Query('.[-1], .[99], .[-99]', '[1,2]', '[2,null,null]');
      Query('.[] | .x', '[{"x":1},{"x":2}]', '[1,2]');
      Query('[.[] | .x]', '[{"x":1},{"x":2}]', '[[1,2]]');
      Query('. and true', 'false', '[false]');
      Query('empty', '42', '[]');
      Query('[empty]', '42', '[[]]');
      Query('.a, .b | length', '{"a":[1],"b":[2,3]}', '[1,2]');
      Query('.[]', '{"a":null}', '[null]');
      Query('map(.x)', '{"a":{"x":1}}', '[[1]]');
    end;

    method FiltersAndProjections;
    begin
      Query('map(select(.n >= 2) | {name, n: .n})', '[{"name":"a","n":1},{"name":"b","n":2}]', '[[{"name":"b","n":2}]]');
      Query('{a: (1,2), "b": (3,4)}', 'null', '[{"a":1,"b":3},{"a":1,"b":4},{"a":2,"b":3},{"a":2,"b":4}]');
      Query('{a: empty}', 'null', '[]');
      Query('map(select(.enabled and (.n < 3)))', '[{"enabled":true,"n":2},{"enabled":false,"n":1}]', '[[{"enabled":true,"n":2}]]');
      Query('[false, null, 0, "", [], {}] | map(not)', 'null', '[[true,true,false,false,false,false]]');
      Query('false and .missing', '42', '[false]');
      Query('true or .missing', '42', '[true]');
      Query('select(true, true)', '1', '[1,1]');
      Query('{"x": null}', '{}', '[{"x":null}]');
    end;

    method AggregationAndOrdering;
    begin
      Query('keys', '{"z":1,"a":null}', '[["a","z"]]');
      Query('keys', '[0,0]', '[[0,1]]');
      Query('map(length)', '[null,[],{},"abc",-3,1.5]', '[[0,0,0,3,3,1.5]]');
      Query('length', '"\ud83d\ude00"', '[1]');
      Query('map(type)', '[null,false,1,"",[],{}]', '[["null","boolean","number","string","array","object"]]');
      Query('unique', '[3,1,2,1,null,false,true]', '[[null,false,true,1,2,3]]');
      Query('sort_by(.a, .b)', '[{"a":1,"b":2},{"a":0,"b":3},{"a":1,"b":1}]', '[[{"a":0,"b":3},{"a":1,"b":1},{"a":1,"b":2}]]');
      Query('group_by(.g) | map({group: .[0].g, count: length})', '[{"g":"b"},{"g":"a"},{"g":"b"}]', '[[{"group":"a","count":1},{"group":"b","count":2}]]');
      Query('add', '[1,2,3]', '[6]');
      Query('add', '["a","b"]', '["ab"]');
      Query('add', '[[1],[2,3]]', '[[1,2,3]]');
      Query('add', '[{"a":1},{"a":null,"b":2}]', '[{"a":null,"b":2}]');
      Query('add, min, max', '[]', '[null,null,null]');
      Query('min, max', '[3,1,2]', '[1,3]');
      Query('flatten', '[1,[2,[],[3]],{"x":[4]}]', '[[1,2,3,{"x":[4]}]]');
      Query('sort', '[{"b":0},{"a":2},{"a":1}]', '[[{"a":1},{"a":2},{"b":0}]]');
      Query('.[0] > .[1]', '[9007199254740993,9007199254740992.0]', '[true]');
      Query('.[0] < .[1]', '[9223372036854775807,9223372036854775808.0]', '[true]');
      Query('unique', '[9007199254740993,9007199254740992]', '[[9007199254740992,9007199254740993]]');
    end;

    method LargerInputAndCancellation;
    begin
      var lInput := new JsonArray;
      for i: Integer := 0 to 1999 do begin
        var lItem := new JsonObject;
        lItem["group"] := new JsonIntegerValue(i mod 20);
        lInput.Add(lItem);
      end;
      var lResult := new JsonQuery('group_by(.group) | map(length)').Evaluate(lInput);
      Check.AreEqual(1, lResult.Count);
      var lCounts := lResult[0] as JsonArray;
      Check.AreEqual(20, lCounts.Count);
      for i: Integer := 0 to lCounts.Count-1 do
        Check.AreEqual(Int64(100), lCounts[i].IntegerValue);
      var lCalls := 0;
      var lCancelled := false;
      try
        new JsonQuery('group_by(.group)').Evaluate(lInput, new JsonQueryOptions(IsCancelled := () -> begin
          inc(lCalls);
          exit lCalls > 100;
        end));
      except
        on E: JsonQueryException do
          lCancelled := E.Message.Contains("cancelled");
      end;
      Check.IsTrue(lCancelled);
    end;

    method ErrorsAndLimits;
    begin
      for lQuery in ['', '.?', '..', '.[] // 0', 'map(', '.a = 1', '.[1:2]', '.[.x]', 'unknown', '1 + 2', '{a:}', '"unterminated', '$x'] do
        Reject(lQuery);
      Reject('.x', '1');
      Reject('.[]', 'null');
      Reject('sort', '{}');
      Reject('add', '[1,"a"]');
      Reject('length', 'true');
      Reject('add', '[9223372036854775807,1]');
      Reject('.', 'null', new JsonQueryOptions(MaxSteps := 1));
      Reject('.[]', '[1,2,3]', new JsonQueryOptions(MaxValues := 2));
      Reject('.a.b', '{}', new JsonQueryOptions(MaxDepth := 1));
      Reject('.', 'null', new JsonQueryOptions(IsCancelled := () -> true));
      Reject('.', 'null', new JsonQueryOptions(MaxValues := 0));
      Reject('add', '["ab","cd"]', new JsonQueryOptions(MaxStringLength := 3));
      var lNested: String := '.';
      for i: Integer := 0 to 70 do
        lNested := '('+lNested+')';
      Reject(lNested);
    end;

  end;

end.
