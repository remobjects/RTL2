namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  Guids = public class(Test)
  private
  protected
  public

    method EmptyGuids;
    begin
      var e := Guid.EmptyGuid;
      Check.AreEqual(e.ToString, "00000000-0000-0000-0000-000000000000");
      Check.AreEqual(e.ToString(GuidFormat.Default), "00000000-0000-0000-0000-000000000000");
      Check.AreEqual(e.ToString(GuidFormat.Braces), "{00000000-0000-0000-0000-000000000000}");
      Check.AreEqual(e.ToString(GuidFormat.Parentheses), "(00000000-0000-0000-0000-000000000000)");

      var e2 := Guid.EmptyGuid;
      Check.AreEqual(e, e2);
      Check.AreNotEqual(e, Guid.NewGuid);
      Check.IsTrue(e = e2);
      Check.IsFalse(e ≠ e2);
    end;

    method Equality;
    begin
      var g1 := Guid.NewGuid;
      var g2 := Guid.NewGuid;
      Check.IsTrue(g1 ≠ g2);
      Check.IsFalse(g1 = g2);

      Check.IsTrue(g1 = g1);
      Check.IsFalse(g1 ≠ g1);
    end;

    /*method Bytes2;
    begin
      var g := Guid.NewGuid;
      writeLn(g);
      var b := g.ToByteArray;
      var s := Convert.ToHexString(new Binary(b));
      writeLn(s);
    end;*/

    method Bytes;
    begin
      // This tests/enforces the weird byte switch we do form Echoes. so far, Echoes, Toffee and Cooper are confirmed to behave equally.

      var g := new Guid("C4511C21-B9AE-4C77-95E1-8D43622F4A5C");
      var b := g.ToByteArray;
      var s := Convert.ToHexString(b);
      Check.AreEqual(s, "C4511C21B9AE4C7795E18D43622F4A5C");
      var g2 := new Guid(b);
      s := Convert.ToHexString(b);
      Check.AreEqual(g.ToString, g2.ToString);
      Check.AreEqual(g,g2);
      Check.IsTrue(g = g2);
      Check.IsFalse(g ≠ g2);

      var s2 := Convert.ToHexString(new Binary(b));
      var s3 := Convert.ToHexString(new Binary(b).ToArray);
      Check.AreEqual(s,s2);
      Check.AreEqual(s,s3);
    end;

  end;

end.