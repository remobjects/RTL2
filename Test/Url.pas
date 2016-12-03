namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.EUnit,
  RemObjects.Elements.RTL;

type
  UrlTests = public class(Test)
  public
  
    method TestUnixFileUrls();
    begin
      var PATH: String := "/Users/mh/Desktop/test.txt";
      var lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/test.txt");
      Assert.IsTrue(lUrl.IsFileUrl);
      Assert.IsFalse(lUrl.IsAbsoluteWindowsFileURL);
      
      Assert.AreEqual(lUrl.Path, PATH);
      Assert.AreEqual(lUrl.ToAbsoluteString, "file:///Users/mh/Desktop/test.txt");
      
      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Assert.AreEqual(lUrl.FilePath, PATH);                   // FilePath always has `/` on Unix
      if Environment.OS in [OperatingSystem.Windows] then
        Assert.AreEqual(lUrl.FilePath, PATH.Replace("/", "\")); // FilePath always has `\` on Windows
      
      var lUrl2 := lUrl.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file:///Users/mh/Desktop/");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file:///Users/mh/");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file:///Users/");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file:///");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2, nil);
      
      var lUrl3 := lUrl.GetParentUrl.GetSubUrl("test2.txt");
      Assert.AreEqual(lUrl3.ToAbsoluteString, "file:///Users/mh/Desktop/test2.txt");
    end;
  
    method TestWindowsFileUrls();
    begin
      var lUrl := Url.UrlWithWindowsPath("C:\Program Files\Test\Test.txt");
      Assert.IsTrue(lUrl.IsFileUrl);
      Assert.IsTrue(lUrl.IsAbsoluteWindowsFileURL);
      Assert.AreEqual(lUrl.Path, "/C:/Program Files/Test/Test.txt"); 
      Assert.AreEqual(lUrl.WindowsPath, "C:\Program Files\Test\Test.txt"); 
      Assert.AreEqual(lUrl.ToAbsoluteString, "file:///C:/Program%20Files/Test/Test.txt");

      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Assert.AreEqual(lUrl.FilePath, "/C:/Program Files/Test/Test.txt"); // FilePath always has `/` on Unix
      if Environment.OS in [OperatingSystem.Windows] then
        Assert.AreEqual(lUrl.FilePath, "C:\Program Files\Test\Test.txt");                  // FilePath always has `\` on Windows
        
      var lUrl2 := lUrl.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file:///C:/Program%20Files/Test/");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file:///C:/Program%20Files/");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file:///C:/");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2, nil);

      var lUrl3 := lUrl.GetParentUrl.GetSubUrl("YTest2.txt");
      Assert.AreEqual(lUrl3.ToAbsoluteString, "file:///C:/Program%20Files/Test/YTest2.txt");
    end;
    
    method TestWindowsNetworkFileUrls();
    begin
      var lUrl := Url.UrlWithWindowsPath("\\SHARE\Program Files\Test\Test.txt");
      Assert.IsTrue(lUrl.IsFileUrl);
      Assert.IsTrue(lUrl.IsAbsoluteWindowsFileURL);
      Assert.AreEqual(lUrl.Path,        "///SHARE/Program Files/Test/Test.txt"); 
      Assert.AreEqual(lUrl.UnixPath,    "///SHARE/Program Files/Test/Test.txt"); 
      Assert.AreEqual(lUrl.WindowsPath,  "\\SHARE\Program Files\Test\Test.txt"); 
      Assert.AreEqual(lUrl.ToAbsoluteString, "file://///SHARE/Program%20Files/Test/Test.txt");

      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Assert.AreEqual(lUrl.FilePath, "///SHARE/Program Files/Test/Test.txt"); // FilePath always has `/` on Unix
      if Environment.OS in [OperatingSystem.Windows] then
        Assert.AreEqual(lUrl.FilePath, "\\SHARE\Program Files\Test\Test.txt");                  // FilePath always has `\` on Windows
        
      var lUrl2 := lUrl.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file://///SHARE/Program%20Files/Test/");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file://///SHARE/Program%20Files/");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file://///SHARE/");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2, nil);

      var lUrl3 := lUrl.GetParentUrl.GetSubUrl("XTest2.txt");
      Assert.AreEqual(lUrl3.ToAbsoluteString, "file://///SHARE/Program%20Files/Test/XTest2.txt");
    end;    

    method TestEncodings();
    begin
      var lUrl := Url.UrlWithWindowsPath("C:\Program Files\Tëst\Tést.txt");
      Assert.AreEqual(lUrl.ToAbsoluteString, "file:///C:/Program%20Files/T%C3%ABst/T%C3%A9st.txt");

      lUrl := Url.UrlWithString("file:///C:/Program%20Files/T%C3%ABst/T%C3%A9st.txt");
      Assert.AreEqual(lUrl.ToAbsoluteString, "file:///C:/Program%20Files/T%C3%ABst/T%C3%A9st.txt");
      Assert.AreEqual(lUrl.UnixPath, "/C:/Program Files/Tëst/Tést.txt");
      Assert.AreEqual(lUrl.WindowsPath, "C:\Program Files\Tëst\Tést.txt");


      lUrl := Url.UrlWithFilepath("/Foo/String+Helpers.cs");
      Assert.AreEqual(lUrl.ToAbsoluteString, "file:///Foo/String%2BHelpers.cs");
      Assert.AreEqual(lUrl.UnixPath, "/Foo/String+Helpers.cs");
    end;
    
    method TestCanonical();
    begin
      var lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/../Test.txt");
      Assert.AreEqual(lUrl.CanonicalVersion.Path, "/Users/mh/Test.txt");

      lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/../../Test.txt");
      Assert.AreEqual(lUrl.CanonicalVersion.Path, "/Users/Test.txt");

      lUrl := Url.UrlWithFilePath("/Users/../mh/Desktop/../../Test.txt");
      Assert.AreEqual(lUrl.CanonicalVersion.Path, "/Test.txt");

      lUrl := Url.UrlWithFilePath("/../../Test.txt");
      Assert.AreEqual(lUrl.CanonicalVersion.Path, "/../../Test.txt");

      lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/./Test.txt");
      Assert.AreEqual(lUrl.CanonicalVersion.Path, "/Users/mh/Desktop/Test.txt");
    end;
    
    method TestRelative();
    begin
      var lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/");
      var lUrl2 := Url.UrlWithFilePath("/Users/mh/Desktop/Test.txt");
      Assert.AreEqual(lUrl2.UnixPathRelativeToUrl(lUrl) Threshold(1), "Test.txt");

      lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/1/2/3/4/5");
      lUrl2 := Url.UrlWithFilePath("/Users/mh/Desktop/1/2/3/a/b/Test.txt");
      Assert.AreEqual(lUrl2.UnixPathRelativeToUrl(lUrl) Threshold(1), "/Users/mh/Desktop/1/2/3/a/b/Test.txt");
      Assert.AreEqual(lUrl2.UnixPathRelativeToUrl(lUrl) Threshold(2), "/Users/mh/Desktop/1/2/3/a/b/Test.txt");
      Assert.AreEqual(lUrl2.UnixPathRelativeToUrl(lUrl) Threshold(3), "../../a/b/Test.txt");
      Assert.AreEqual(lUrl2.UnixPathRelativeToUrl(lUrl) Threshold(4), "../../a/b/Test.txt");
      Assert.AreEqual(lUrl2.UnixPathRelativeToUrl(lUrl) Threshold(5), "../../a/b/Test.txt");
    end;

    method TestRelative2();
    begin
      var lUnixUrl := Url.UrlWithFilePath("/Users/mh/Desktop/");
      Assert.AreEqual(Url.UrlWithFilePath("/Users/mh/").UnixPathRelativeToUrl(lUnixUrl) Always(true), "..");
      Assert.AreEqual(Url.UrlWithFilePath("/Users/mh/Library").UnixPathRelativeToUrl(lUnixUrl) Always(true), "../Library");
      Assert.AreEqual(Url.UrlWithFilePath("/Users/mh/Desktop/Test").UnixPathRelativeToUrl(lUnixUrl) Always(true), "Test");
      Assert.AreEqual(Url.UrlWithWindowsPath("C:\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lUnixUrl) Always(true), nil);
      Assert.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lUnixUrl) Always(true), nil);

      var lWindowsDriveLetterUrl := Url.UrlWithWindowsPath("C:\Users\mh\Desktop");
      Assert.AreEqual(Url.UrlWithWindowsPath("C:\Users\mh\").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "..");
      Assert.AreEqual(Url.UrlWithWindowsPath("C:\Users\mh\Library").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "../Library");
      Assert.AreEqual(Url.UrlWithWindowsPath("C:\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "Test");
      Assert.AreEqual(Url.UrlWithWindowsPath("C:\Users\").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "../..");
      Assert.AreEqual(Url.UrlWithWindowsPath("C:\").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "../../..");
      Assert.AreEqual(Url.UrlWithWindowsPath("c:\Users\").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "../..");
      Assert.AreEqual(Url.UrlWithWindowsPath("D:\").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), nil);
      Assert.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), nil);
      Assert.AreEqual(Url.UrlWithFilePath("/Users/mh/Desktop/Test").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), nil);

      var lWindowsNetworkUrl := Url.UrlWithWindowsPath("\\RIBBONS\Users\mh\Desktop");
      Assert.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\Users\mh\").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "..");
      Assert.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\Users\mh\Library").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "../Library");
      Assert.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\Users\").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "../..");
      Assert.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "../../..");
      Assert.AreEqual(Url.UrlWithWindowsPath("\\Ribbons\Users\").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "../..");
      Assert.AreEqual(Url.UrlWithWindowsPath("\\FLOORSHOW\").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), nil);
      Assert.AreEqual(Url.UrlWithWindowsPath("\\FLOORSHOW\Users\mh\Desktop").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), nil);
      Assert.AreEqual(Url.UrlWithWindowsPath("C:\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), nil);
      Assert.AreEqual(Url.UrlWithFilePath("/Users/mh/Desktop/Test").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), nil);
    end;

    method Dummy();
    begin
      var include := "../Resources/Project Icons/Debug-BreakpointOff.png";
      var baseUrl := Url.UrlWithFilePath("/Users/mh/Code/Fire/FireApp/"); 
      var suburl := baseUrl.UrlWithRelativeOrAbsoluteFileSubPath(include);
      Assert.IsNotNil(suburl);
      
      {$IF TOFFEE}
      var lUrl := NSURL.URLWithString("file:///Users/mh/Test%20Projects/App24/App24.sln");
      var u := lUrl as Url;
      Assert.AreEqual(lUrl.absoluteString, "file:///Users/mh/Test%20Projects/App24/App24.sln");
      Assert.AreEqual(u.ToAbsoluteString(), "file:///Users/mh/Test%20Projects/App24/App24.sln"); // fails ONLY when i inline Convert.Utf8BytesToString

      var solutionLicenseFile := Path.ChangeExtension(u.FilePath, "licenses");
      Assert.AreEqual(solutionLicenseFile, "/Users/mh/Test Projects/App24/App24.licenses");
      {$ENDIF}
    end;
    
    method TestPathComponents();
    begin
      var lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/Test.txt");
      
      Assert.AreEqual(lUrl.PathExtension, ".txt");
      Assert.AreEqual(lUrl.LastPathComponent, "Test.txt");
      
      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Assert.AreEqual(lUrl.FilePathWithoutLastComponent, "/Users/mh/Desktop/");
      if Environment.OS in [OperatingSystem.Windows] then
        Assert.AreEqual(lUrl.FilePathWithoutLastComponent, "\Users\mh\Desktop\");

      Assert.AreEqual(lUrl.WindowsPathWithoutLastComponent, "\Users\mh\Desktop\");
      Assert.AreEqual(lUrl.UnixPathWithoutLastComponent, "/Users/mh/Desktop/");
      
      Assert.AreEqual(lUrl.UrlWithoutLastComponent.ToAbsoluteString, "file:///Users/mh/Desktop/");
      
      lUrl := Url.UrlWithFilePath("foo.txt");
      Assert.AreEqual(lUrl.PathExtension, ".txt");
      
      lUrl := Url.UrlWithWindowsPath("C:\Program Files\Tést.txt");
      Assert.AreEqual(lUrl.PathExtension, ".txt");
      Assert.AreEqual(lUrl.LastPathComponent, "Tést.txt");
      
      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Assert.AreEqual(lUrl.FilePathWithoutLastComponent, "/C:/Program Files/");
      if Environment.OS in [OperatingSystem.Windows] then
        Assert.AreEqual(lUrl.FilePathWithoutLastComponent, "C:\Program Files\");
        
      Assert.AreEqual(lUrl.UnixPathWithoutLastComponent, "/C:/Program Files/");
      Assert.AreEqual(lUrl.WindowsPathWithoutLastComponent, "C:\Program Files\");
      Assert.AreEqual(lUrl.UrlWithoutLastComponent.ToAbsoluteString, "file:///C:/Program%20Files/");
      
      lUrl := Url.UrlWithFilePath("/foo/bar/test.txt");
      Assert.AreEqual(lUrl.UrlWithChangedPathExtension("foo").ToAbsoluteString, "file:///foo/bar/test.foo");
      Assert.AreEqual(lUrl.UrlWithChangedPathExtension(".foo").ToAbsoluteString, "file:///foo/bar/test.foo");
    end;
    
    method TestOperators();
    begin
      var lUrl1 := Url.UrlWithFilePath("/Users/mh/Desktop/Test.txt");
      var lUrl2 := Url.UrlWithFilePath("/Users/mh/Desktop/Test.txt");
      var lUrl3 := Url.UrlWithFilePath("/Users/mh/Desktop/Test2.txt");
      Assert.AreEqual(lUrl1 = lUrl2, true); //FAILS
      Assert.AreEqual(lUrl1 ≠ lUrl3, true);

      var lUrl1A := lUrl1 as Object;
      var lUrl2A := lUrl2 as Object;
      var lUrl3A := lUrl2 as Object;

      Assert.AreEqual(lUrl1 = lUrl2A, true); // calls fiest operator
      Assert.AreEqual(lUrl1A = lUrl2, true); // calls scond operator

      Assert.AreEqual(lUrl1A = lUrl2A, false); // expected to fail, object comparisson
      Assert.AreEqual(lUrl1A ≠ lUrl3A, true);
    end;

    
  end;

end.
