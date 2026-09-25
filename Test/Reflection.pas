namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.EUnit,
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Reflection;

{$IF COOPER}
type
  ReflectionMethodSample = public class
  public

    property Name: String := 'sample';
  end;

  ReflectionMethodsTest = public class(Test)
  public

    method ReturnsInvokedGetterValue;
    begin
      var lSample := new ReflectionMethodSample;
      var lType := &Type.TypeOf(lSample);
      var lGetter := lType.Methods.FirstOrDefault(aMethod -> (aMethod.Name = 'get_Name') or (aMethod.Name = 'getName'));
      Check.IsNotNil(lGetter);
      Check.AreEqual(lGetter.Invoke(lSample), 'sample');
    end;
  end;
{$ENDIF}

{$IF TOFFEE AND NOT ISLAND}
type
  ReflectionFieldSample = public class
  public
    fCount: Int32;
    fTitle: String;
  end;

  ReflectionFieldEmpty = public class
  end;

  ReflectionFieldsTest = public class(Test)
  public
    method EnumeratesAndAccessesIvars;
    begin
      var lSample := new ReflectionFieldSample;
      lSample.fCount := 42;
      lSample.fTitle := 'first';

      var lFields := &Type.TypeOf(lSample).Fields;
      Check.AreEqual(lFields.Count, 2);

      var lCountField := lFields.FirstOrDefault(aField -> aField.Name = 'fCount');
      Check.IsNotNil(lCountField);
      Check.AreEqual(lCountField.DeclaringType.TypeClass, &Type.TypeOf(lSample).TypeClass);
      Check.AreEqual(lCountField.Type.Name, 'Int32');
      Check.AreEqual(lCountField.GetValue(lSample), 42);
      lCountField.SetValue(lSample, 99);
      Check.AreEqual(lSample.fCount, 99);

      var lTitleField := lFields.FirstOrDefault(aField -> aField.Name = 'fTitle');
      Check.IsNotNil(lTitleField);
      Check.AreEqual(lTitleField.Type.Name, 'id');
      Check.AreEqual(lTitleField.GetValue(lSample), 'first');
      lTitleField.SetValue(lSample, 'second');
      Check.AreEqual(lSample.fTitle, 'second');
    end;

    method ReturnsAnEmptyListForClassesWithoutIvars;
    begin
      Check.AreEqual(&Type.TypeOf(new ReflectionFieldEmpty).Fields.Count, 0);
    end;
  end;
{$ENDIF}

end.
