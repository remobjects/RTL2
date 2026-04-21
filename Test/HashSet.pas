namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.EUnit,
  RemObjects.Elements.RTL;

type
  HashSetTests = public class(Test)
  private
    fData: HashSet<String>;

  public
    method Setup; override;
    begin
      fData := new HashSet<String>(["One", "Two", "Three"]);
    end;

    method Constructors;
    begin
      var lCopy := new HashSet<String>(fData);
      Assert.AreEqual(lCopy.Count, 3);
      Assert.IsTrue(lCopy.SetEquals(fData));

      var lNilSet: HashSet<String> := nil;
      var lEmptyFromNil := new HashSet<String>(lNilSet);
      Assert.AreEqual(lEmptyFromNil.Count, 0);
      Assert.IsTrue(lEmptyFromNil.SetEquals(nil));

      var lFromSequence := new HashSet<String>(["One", "Two", "Two", "Three"]);
      Assert.AreEqual(lFromSequence.Count, 3);
      Assert.IsTrue(lFromSequence.SetEquals(fData));

      var lNilItems: sequence of String := nil;
      var lEmptyFromNilItems := new HashSet<String>(lNilItems);
      Assert.AreEqual(lEmptyFromNilItems.Count, 0);
      Assert.IsTrue(lEmptyFromNilItems.SetEquals(nil));

      var lFromArray := new HashSet<String>(fData.ToArray);
      Assert.IsTrue(lFromArray.SetEquals(fData));
    end;

    method AddAndRemove;
    begin
      Assert.IsTrue(fData.Add("Four"));
      Assert.IsFalse(fData.Add("Four"));
      Assert.IsTrue(fData.Contains("Four"));
      Assert.AreEqual(fData.Count, 4);

      Assert.IsTrue(fData.Remove("Four"));
      Assert.IsFalse(fData.Remove("Four"));
      Assert.IsFalse(fData.Contains("Four"));
      Assert.AreEqual(fData.Count, 3);

      fData.Clear;
      Assert.AreEqual(fData.Count, 0);
    end;

    method EnumeratesUniqueItems;
    begin
      var lEnumerated := new HashSet<String>;
      var lForEachCount := 0;

      fData.ForEach(aItem -> begin
        inc(lForEachCount);
        lEnumerated.Add(aItem);
      end);

      Assert.AreEqual(lForEachCount, 3);
      Assert.IsTrue(lEnumerated.SetEquals(fData));

      var lLooped := new HashSet<String>;
      var lLoopCount := 0;
      for each lItem in fData do begin
        inc(lLoopCount);
        lLooped.Add(lItem);
      end;

      Assert.AreEqual(lLoopCount, 3);
      Assert.IsTrue(lLooped.SetEquals(fData));

      var lArray := new HashSet<String>(fData.ToArray);
      Assert.IsTrue(lArray.SetEquals(fData));
    end;

    method IntersectAndUnion;
    begin
      var lNilSet: HashSet<String> := nil;
      var lValue := new HashSet<String>(["Zero", "Two", "Three"]);

      fData.Union(lNilSet);
      Assert.AreEqual(fData.Count, 3);

      fData.Intersect(lValue);
      Assert.AreEqual(fData.Count, 2);
      Assert.IsTrue(fData.SetEquals(new HashSet<String>(["Two", "Three"])));
      Assert.AreEqual(lValue.Count, 3);

      fData.Union(new HashSet<String>(["Three", "Four"]));
      Assert.AreEqual(fData.Count, 3);
      Assert.IsTrue(fData.SetEquals(new HashSet<String>(["Two", "Three", "Four"])));

      fData.Intersect(lNilSet);
      Assert.AreEqual(fData.Count, 0);
    end;

    method SetRelations;
    begin
      var lNilSet: HashSet<String> := nil;
      var lSubset := new HashSet<String>(["Two", "Three"]);

      Assert.IsTrue(lSubset.IsSubsetOf(fData));
      Assert.IsTrue(fData.IsSupersetOf(lSubset));
      Assert.IsFalse(fData.SetEquals(lSubset));

      lSubset.Add("One");
      Assert.IsTrue(lSubset.SetEquals(fData));

      Assert.IsTrue(new HashSet<String>().IsSubsetOf(fData));
      Assert.IsTrue(fData.IsSupersetOf(new HashSet<String>()));
      Assert.IsTrue(fData.IsSupersetOf(lNilSet));
      Assert.IsFalse(fData.IsSubsetOf(lNilSet));
      Assert.IsFalse(fData.SetEquals(lNilSet));
      Assert.IsTrue(new HashSet<String>().IsSubsetOf(lNilSet));
      Assert.IsTrue(new HashSet<String>().SetEquals(lNilSet));
    end;
  end;

end.
