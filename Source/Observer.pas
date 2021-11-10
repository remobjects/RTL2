namespace RemObjects.Elements.RTL;

{$IF NOT JAVA17_0}

uses
  {$IF ECHOES}
  System.ComponentModel
  {$ENDIF};

type
  ObserverBlock = public block(aTarget: not nullable Object; aName: not nullable String);

  Observer = public partial class(IDisposable)
  public

    constructor(aTarget: not nullable Object; aName: not nullable String; aWillChangeCallback: ObserverBlock := nil; aDidChangeCallback: not nullable ObserverBlock);
    begin
      fTarget := aTarget;
      fName := aName;
      fWillChangeCallback := aWillChangeCallback;
      fDidChangeCallback := aDidChangeCallback;

      if defined("ECHOES") then begin
        if assigned(fWillChangeCallback) then
          INotifyPropertyChanging(fTarget):PropertyChanging += PropertyChanging;
        INotifyPropertyChanged(fTarget):PropertyChanged += PropertyChanged;
      end
      else if defined("COOPER") then begin
        INotifyPropertyChanged(fTarget):addPropertyChangeListener(self);
      end
      else if defined("TOFFEE") then begin
        fTarget.addObserver(self) forKeyPath(aName) options(if assigned(aWillChangeCallback) then Foundation.NSKeyValueObservingOptions.Old or Foundation.NSKeyValueObservingOptions.New else Foundation.NSKeyValueObservingOptions.New) context(nil);
      end
      else if defined("DARWIN") and (fTarget is IslandWrappedCocoaObject) then begin
        IslandWrappedCocoaObject(fTarget).Value.addObserver(self) forKeyPath(aName) options(if assigned(aWillChangeCallback) then Foundation.NSKeyValueObservingOptions.Old or Foundation.NSKeyValueObservingOptions.New else Foundation.NSKeyValueObservingOptions.New) context(nil);
      end
      else if defined("DARWIN") and not defined('TVOS') and not defined('WATCHOS') and (fTarget is IslandWrappedSwiftObject) then begin
        raise new NotImplementedException("Observer is not yet supported on Swift objects");
      end
      else if defined("ISLAND") then begin
        if assigned(fWillChangeCallback) then
          INotifyPropertyChanging(fTarget):PropertyChanging += PropertyChanging;
        INotifyPropertyChanged(fTarget):PropertyChanged += PropertyChanged;
      end
      else begin
        {$ERROR Unsupported platform}
      end;
    end;

    method Unsubscribe;
    begin
      if defined("ECHOES") then begin
        if assigned(fWillChangeCallback) then
          INotifyPropertyChanging(fTarget):PropertyChanging -= PropertyChanging;
        INotifyPropertyChanged(fTarget):PropertyChanged -= PropertyChanged;
      end
      else if defined("COOPER") then begin
        INotifyPropertyChanged(fTarget):removePropertyChangeListener(self);
      end
      else if defined("TOFFEE") then begin
        fTarget.removeObserver(self) forKeyPath(fName);
      end
      else if defined("DARWIN") and (fTarget is IslandWrappedCocoaObject) then begin
        IslandWrappedCocoaObject(fTarget).Value.removeObserver(self) forKeyPath(fName);
      end
      else if defined("DARWIN") and not defined('TVOS') and not defined('WATCHOS') and (fTarget is IslandWrappedSwiftObject) then begin
        raise new NotImplementedException("Observer is not yet supported on Swift objects");
      end
      else if defined("ISLAND") then begin
        if assigned(fWillChangeCallback) then
          INotifyPropertyChanging(fTarget):PropertyChanging -= PropertyChanging;
        INotifyPropertyChanged(fTarget):PropertyChanged -= PropertyChanged;
      end
      else begin
        {$ERROR Unsupported platform}
      end;

      if defined("ECHOES") then
        GC.SuppressFinalize(self)
      else if defined("ISLAND") and exists(Utilities.SuppressFinalize) then
        Utilities.SuppressFinalize(self)
    end;

    method Dispose; //override;
    begin
      Unsubscribe();
    end;

    finalizer;
    begin
      Unsubscribe();
    end;

  private

    fTarget: weak Object;
    fName: not nullable String;
    fWillChangeCallback: ObserverBlock;
    fDidChangeCallback: not nullable ObserverBlock;

    {$IF ECHOES}
    method PropertyChanging(sender: Object; e: PropertyChangingEventArgs);
    begin
      fWillChangeCallback(fTarget, fName);
    end;

    method PropertyChanged(sender: Object; e: PropertyChangedEventArgs);
    begin
      fDidChangeCallback(fTarget, fName);
    end;
    {$ENDIF}

    {$IF ISLAND}
    method PropertyChanging(sender: Object; aName: String);
    begin
      fWillChangeCallback(fTarget, fName);
    end;

    method PropertyChanged(sender: Object; aName: String);
    begin
      fDidChangeCallback(fTarget, fName);
    end;
    {$ENDIF}

    {$IF DARWIN}
    method observeValueForKeyPath(aKeyPath: String) ofObject(aObject: id) change(aChange: Foundation.NSDictionary) context(aContext: ^Void);
    begin

    end;
    {$ENDIF}

  end;

  {$IF COOPER}
  Observer = public partial class(java.beans.PropertyChangeListener)
  public

    method propertyChange(e: java.beans.PropertyChangeEvent);
    begin
      fDidChangeCallback(fTarget, fName);
    end;

  end;
  {$ENDIF}

{$ENDIF}

end.