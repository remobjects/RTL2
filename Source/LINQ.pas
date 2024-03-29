﻿namespace RemObjects.Elements.RTL;

interface

uses
{$IF COOPER}
  remobjects.elements.linq,
{$ELSEIF TOFFEE AND NOT TOFFEEV2}
  Foundation,
  RemObjects.Elements.Linq,
{$ELSEIF ECHOES}
  System.Collections.Generic,
{$ENDIF}
  RemObjects.Elements.RTL;

{$IF COOPER}
[assembly: NamespaceAlias('RemObjects.Elements.RTL', ['remobjects.elements.linq'])]
[assembly: NamespaceAlias('RemObjects.Elements.RTL.Linq', ['remobjects.elements.linq'])]
{$ELSEIF TOFFEE AND NOT TOFFEEV2}
[assembly: NamespaceAlias('RemObjects.Elements.RTL', ['RemObjects.Elements.Linq'])]
[assembly: NamespaceAlias('RemObjects.Elements.RTL.Linq', ['RemObjects.Elements.Linq'])]
{$ELSEIF ECHOES}
[assembly: NamespaceAlias('RemObjects.Elements.RTL', ['System.Linq'])]
[assembly: NamespaceAlias('RemObjects.Elements.RTL.Linq', ['System.Linq'])]
{$ENDIF}

{$IF TOFFEEV2}
// In toffee V2 sequences are always enumerable, INSFastEnumeration is rare; but when we do ToList, we want the RTL2 List which is an NSArray, not a regular System.List.
extension method IEnumerable<T>.ToList<T>: not nullable List<T>; where T is NSObject; public;
{$ENDIF}

{$IF TOFFEE}
extension method Foundation.INSFastEnumeration.ToList: not nullable List<id>; public;
extension method Foundation.INSFastEnumeration.ToList<U>: not nullable List<U>; public;
extension method Foundation.INSFastEnumeration.ToArray: not nullable array of id; public;
extension method Foundation.INSFastEnumeration.ToDictionary(aKeyBlock: IDBlock; aValueBlock: IDBlock): not nullable Dictionary<id,id>; public;
extension method RemObjects.Elements.System.INSFastEnumeration<T>.ToList: not nullable List<T>; inline; public;
extension method RemObjects.Elements.System.INSFastEnumeration<T>.ToList<U>: not nullable List<U>; inline; public;
extension method RemObjects.Elements.System.INSFastEnumeration<T>.ToArray: not nullable array of T; inline; public;
//extension method RemObjects.Elements.System.INSFastEnumeration<T>.ToDictionary<K,V>(aKeyBlock: block(aItem: id): K; aValueBlock: block(aItem: id): V): not nullable Dictionary<K,V>; public;
{$ENDIF}

implementation

{$IF TOFFEEV2}
extension method IEnumerable<T>.ToList<T>: not nullable List<T>;
begin
  var lRes := new List<T>;
  for each el in self do
    lRes.Add(el);
  exit lRes;
end;

{$ENDIF}

{$IF TOFFEE}
extension method Foundation.INSFastEnumeration.ToList: not nullable List<id>;
begin
  result := self.ToNSArray.mutableCopy as not nullable;
end;

extension method Foundation.INSFastEnumeration.ToList<U>: not nullable List<U>;
begin
  result := self.ToNSArray.mutableCopy as not nullable;
end;

extension method Foundation.INSFastEnumeration.ToArray: not nullable array of id;
begin
  result := (self.ToNSArray as List<id>).ToArray as not nullable;
end;

extension method Foundation.INSFastEnumeration.ToDictionary(aKeyBlock: IDBlock; aValueBlock: IDBlock): not nullable Dictionary<id,id>;
begin
  result := dictionary(aKeyBlock, aValueBlock) as NSMutableDictionary;
end;

extension method RemObjects.Elements.System.INSFastEnumeration<T>.ToList: not nullable List<T>;
begin
  exit Foundation.INSFastEnumeration(self).ToNSArray.mutableCopy as not nullable;
end;

extension method RemObjects.Elements.System.INSFastEnumeration<T>.ToList<U>: not nullable List<U>;
begin
  exit Foundation.INSFastEnumeration(self).ToNSArray.mutableCopy as not nullable;
end;

extension method RemObjects.Elements.System.INSFastEnumeration<T>.ToArray: not nullable array of T;
begin
  exit (Foundation.INSFastEnumeration(self).ToNSArray as List<T>).ToArray as not nullable;
end;

{extension method RemObjects.Elements.System.INSFastEnumeration<T>.ToDictionary<K,V>(aKeyBlock: block(aItem: id): K; aValueBlock: block(aItem: id): V): not nullable Dictionary<K,V>;
begin
  exit Foundation.INSFastEnumeration(self).dictionary(IDBlock(aKeyBlock), IDBlock(aValueBlock));
end;}
{$ENDIF}

end.
    