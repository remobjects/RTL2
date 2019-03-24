namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.EUnit,
  RemObjects.Elements.RTL;

type
  UrlTests = public class(Test)
  public

    method UrlTypes;
    begin
      //var ftp := Url.UrlWithString("ftp://ftp.is.co.za/rfc/rfc1808.txt");
      //var gopher := Url.UrlWithString("gopher://spinaltap.micro.umn.edu/00/Weather/California/Los%20Angeles");
      //var http := Url.UrlWithString("http://www.math.uio.no/faq/compression-faq/part1.html");
      //var mail := Url.UrlWithString("mailto:mduerst@ifi.unizh.ch");
      //var news := Url.UrlWithString("news:comp.infosystems.www.servers.unix");
      //var telnet := Url.UrlWithString("telnet://melvyl.ucop.edu/");
    end;

    method TestUrlWithString();
    begin
      var s := "http://foo:8986/bar/baz-1340456-786%2dabc/d";
      var u := Url.UrlWithString(s);
      //writeLn(u.ToAbsoluteString);
      Check.AreEqual(s, u.ToAbsoluteString);
    end;

    method TestUnixFileUrls();
    begin
      var PATH: String := "/Users/mh/Desktop/test.txt";
      var lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/test.txt");
      Check.IsTrue(lUrl.IsFileUrl);
      Check.IsFalse(lUrl.IsAbsoluteWindowsFileURL);

      Check.AreEqual(lUrl.Path, PATH);
      Check.AreEqual(lUrl.ToAbsoluteString, "file:///Users/mh/Desktop/test.txt");

      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Check.AreEqual(lUrl.FilePath, PATH);                   // FilePath always has `/` on Unix
      if Environment.OS in [OperatingSystem.Windows] then
        Check.AreEqual(lUrl.FilePath, PATH.Replace("/", "\")); // FilePath always has `\` on Windows

      var lUrl2 := lUrl.GetParentUrl;
      Check.AreEqual(lUrl2.ToAbsoluteString, "file:///Users/mh/Desktop/");
      lUrl2 := lUrl2.GetParentUrl;
      Check.AreEqual(lUrl2.ToAbsoluteString, "file:///Users/mh/");
      lUrl2 := lUrl2.GetParentUrl;
      Check.AreEqual(lUrl2.ToAbsoluteString, "file:///Users/");
      lUrl2 := lUrl2.GetParentUrl;
      Check.AreEqual(lUrl2.ToAbsoluteString, "file:///");
      lUrl2 := lUrl2.GetParentUrl;
      Check.AreEqual(lUrl2, nil);

      var lUrl3 := lUrl.GetParentUrl.SubUrl("test2.txt");
      Check.AreEqual(lUrl3.ToAbsoluteString, "file:///Users/mh/Desktop/test2.txt");

      var lUrl4 := lUrl.GetParentUrl.SubUrl("bla", "test2.txt");
      Check.AreEqual(lUrl4.ToAbsoluteString, "file:///Users/mh/Desktop/bla/test2.txt");
    end;

    method TestWindowsFileUrls();
    begin
      var lUrl := Url.UrlWithWindowsPath("C:\Program Files\Test\Test.txt");
      Check.IsTrue(lUrl.IsFileUrl);
      Check.IsTrue(lUrl.IsAbsoluteWindowsFileURL);
      Check.AreEqual(lUrl.Path, "/C:/Program%20Files/Test/Test.txt");
      Check.AreEqual(lUrl.UnixPath, "/C:/Program Files/Test/Test.txt");
      Check.AreEqual(lUrl.WindowsPath, "C:\Program Files\Test\Test.txt");
      Check.AreEqual(lUrl.ToAbsoluteString, "file:///C:/Program%20Files/Test/Test.txt");

      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Check.AreEqual(lUrl.FilePath, "/C:/Program Files/Test/Test.txt"); // FilePath always has `/` on Unix
      if Environment.OS in [OperatingSystem.Windows] then
        Check.AreEqual(lUrl.FilePath, "C:\Program Files\Test\Test.txt");                  // FilePath always has `\` on Windows

      var lUrl2 := lUrl.GetParentUrl;
      Check.AreEqual(lUrl2.ToAbsoluteString, "file:///C:/Program%20Files/Test/");
      lUrl2 := lUrl2.GetParentUrl;
      Check.AreEqual(lUrl2.ToAbsoluteString, "file:///C:/Program%20Files/");
      lUrl2 := lUrl2.GetParentUrl;
      Check.AreEqual(lUrl2.ToAbsoluteString, "file:///C:/");
      lUrl2 := lUrl2.GetParentUrl;
      Check.AreEqual(lUrl2, nil);

      var lUrl3 := lUrl.GetParentUrl.SubUrl("YTest2.txt");
      Check.AreEqual(lUrl3.ToAbsoluteString, "file:///C:/Program%20Files/Test/YTest2.txt");
    end;

    method TestWindowsNetworkFileUrls();
    begin
      var lUrl := Url.UrlWithWindowsPath("\\SHARE\Program Files\Test\Test.txt");
      Check.IsTrue(lUrl.IsFileUrl);
      Check.IsTrue(lUrl.IsAbsoluteWindowsNetworkDriveFileURL);
      Check.IsFalse(lUrl.IsAbsoluteWindowsDriveLetterFileURL);
      Check.IsTrue(lUrl.IsAbsoluteWindowsFileURL);
      Check.AreEqual(lUrl.Host,        "SHARE");
      Check.AreEqual(lUrl.Path,        "/Program%20Files/Test/Test.txt");
      Check.AreEqual(lUrl.UnixPath,    "/Program Files/Test/Test.txt");
      Check.AreEqual(lUrl.WindowsPath,  "\\SHARE\Program Files\Test\Test.txt");
      Check.AreEqual(lUrl.ToAbsoluteString, "file://SHARE/Program%20Files/Test/Test.txt");

      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Check.AreEqual(lUrl.FilePath, "/Program Files/Test/Test.txt"); // FilePath always has `/` on Unix
      if Environment.OS in [OperatingSystem.Windows] then
        Check.AreEqual(lUrl.FilePath, "\\SHARE\Program Files\Test\Test.txt");                  // FilePath always has `\` on Windows

      var lUrl2 := lUrl.GetParentUrl;
      Check.AreEqual(lUrl2.ToAbsoluteString, "file://SHARE/Program%20Files/Test/");
      lUrl2 := lUrl2.GetParentUrl;
      Check.AreEqual(lUrl2.ToAbsoluteString, "file://SHARE/Program%20Files/");
      lUrl2 := lUrl2.GetParentUrl;
      Check.AreEqual(lUrl2.ToAbsoluteString, "file://SHARE/");
      lUrl2 := lUrl2.GetParentUrl;
      Check.AreEqual(lUrl2, nil);

      var lUrl3 := lUrl.GetParentUrl.SubUrl("XTest2.txt");
      Check.AreEqual(lUrl3.ToAbsoluteString, "file://SHARE/Program%20Files/Test/XTest2.txt");

      var lUrl4 := lUrl.GetParentUrl.SubUrl("bla", "XTest2.txt");
      Check.AreEqual(lUrl4.ToAbsoluteString, "file://SHARE/Program%20Files/Test/bla/XTest2.txt");
    end;

    method TestProperWindowsNetworkFileUrls();
    begin
      var lUrl := Url.UrlWithString("file://SHARE/Program%20Files/Test/Test.txt");
      Check.IsTrue(lUrl.IsFileUrl);
      Check.IsTrue(lUrl.IsAbsoluteWindowsFileURL);
      Check.AreEqual(lUrl.Host,        "SHARE");
      Check.AreEqual(lUrl.Path,        "/Program%20Files/Test/Test.txt");
      Check.AreEqual(lUrl.UnixPath,    "/Program Files/Test/Test.txt");
      Check.AreEqual(lUrl.WindowsPath,  "\\SHARE\Program Files\Test\Test.txt");
      Check.AreEqual(lUrl.ToAbsoluteString, "file://SHARE/Program%20Files/Test/Test.txt");

      lUrl := Url.UrlWithString("file://///SHARE/Program%20Files/Test/Test.txt");
      Check.IsTrue(lUrl.IsFileUrl);
      Check.IsTrue(lUrl.IsAbsoluteWindowsFileURL);
      Check.AreEqual(lUrl.Host,        "SHARE");
      Check.AreEqual(lUrl.Path,        "/Program%20Files/Test/Test.txt");
      Check.AreEqual(lUrl.UnixPath,    "/Program Files/Test/Test.txt");
      Check.AreEqual(lUrl.WindowsPath,  "\\SHARE\Program Files\Test\Test.txt");
      Check.AreEqual(lUrl.ToAbsoluteString, "file://SHARE/Program%20Files/Test/Test.txt");
    end;

    method TestEncodings();
    begin
      var lUrl := Url.UrlWithWindowsPath("C:\Program Files\Tëst\Tést.txt");
      Check.AreEqual(lUrl.ToAbsoluteString, "file:///C:/Program%20Files/T%C3%ABst/T%C3%A9st.txt");

      lUrl := Url.UrlWithString("file:///C:/Program%20Files/T%C3%ABst/T%C3%A9st.txt");
      Check.AreEqual(lUrl.ToAbsoluteString, "file:///C:/Program%20Files/T%C3%ABst/T%C3%A9st.txt");
      Check.AreEqual(lUrl.UnixPath, "/C:/Program Files/Tëst/Tést.txt");
      Check.AreEqual(lUrl.WindowsPath, "C:\Program Files\Tëst\Tést.txt");


      lUrl := Url.UrlWithFilepath("/Foo/String+Helpers.cs");
      Check.AreEqual(lUrl.ToAbsoluteString, "file:///Foo/String%2BHelpers.cs");
      Check.AreEqual(lUrl.UnixPath, "/Foo/String+Helpers.cs");
    end;

    method TestRemovePercentEncodings();
    begin
      var s1 := "VIPVC does not contain a declaration that matches this method signature: method VIPVC.didRecˆeiveMemoryWarning";
      var s2 := Url.AddPercentEncodingsToPath(s1);
      var s3 := Url.RemovePercentEncodingsFromPath(s2);

      {$IF NOT COOPER}
      s1 := "Pro🙉gram";
      s2 := Url.AddPercentEncodingsToPath(s1);
      s3 := Url.RemovePercentEncodingsFromPath(s2);
      Check.AreEqual(s1,s3);
      {$ENDIF}
    end;

    method TestCanonical();
    begin
      var lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/../Test.txt");
      Check.AreEqual(lUrl.CanonicalVersion.Path, "/Users/mh/Test.txt");

      lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/../../Test.txt");
      Check.AreEqual(lUrl.CanonicalVersion.Path, "/Users/Test.txt");

      lUrl := Url.UrlWithFilePath("/Users/../mh/Desktop/../../Test.txt");
      Check.AreEqual(lUrl.CanonicalVersion.Path, "/Test.txt");

      lUrl := Url.UrlWithFilePath("/../../Test.txt");
      Check.AreEqual(lUrl.CanonicalVersion.Path, "/../../Test.txt");

      lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/./Test.txt");
      Check.AreEqual(lUrl.CanonicalVersion.Path, "/Users/mh/Desktop/Test.txt");
    end;

    method TestRelative();
    begin
      var lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/");
      var lUrl2 := Url.UrlWithFilePath("/Users/mh/Desktop/Test.txt");
      Check.AreEqual(lUrl2.UnixPathRelativeToUrl(lUrl) Threshold(1), "Test.txt");

      lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/1/2/3/4/5");
      lUrl2 := Url.UrlWithFilePath("/Users/mh/Desktop/1/2/3/a/b/Test.txt");
      Check.AreEqual(lUrl2.UnixPathRelativeToUrl(lUrl) Threshold(1), "/Users/mh/Desktop/1/2/3/a/b/Test.txt");
      Check.AreEqual(lUrl2.UnixPathRelativeToUrl(lUrl) Threshold(2), "/Users/mh/Desktop/1/2/3/a/b/Test.txt");
      Check.AreEqual(lUrl2.UnixPathRelativeToUrl(lUrl) Threshold(3), "../../a/b/Test.txt");
      Check.AreEqual(lUrl2.UnixPathRelativeToUrl(lUrl) Threshold(4), "../../a/b/Test.txt");
      Check.AreEqual(lUrl2.UnixPathRelativeToUrl(lUrl) Threshold(5), "../../a/b/Test.txt");
    end;

    method TestRelative2();
    begin
      var lUnixUrl := Url.UrlWithFilePath("/Users/mh/Desktop/");
      Check.AreEqual(Url.UrlWithFilePath("/Users/mh/").UnixPathRelativeToUrl(lUnixUrl) Always(true), "..");
      Check.AreEqual(Url.UrlWithFilePath("/Users/mh/Library").UnixPathRelativeToUrl(lUnixUrl) Always(true), "../Library");
      Check.AreEqual(Url.UrlWithFilePath("/Users/mh/Desktop/Test").UnixPathRelativeToUrl(lUnixUrl) Always(true), "Test");
      Check.AreEqual(Url.UrlWithWindowsPath("C:\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lUnixUrl) Always(true), nil);
      Check.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lUnixUrl) Always(true), nil);
      //Check.AreEqual(Url.UrlWithWindowsPath("C:\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lUnixUrl) Always(true), "C:\Users\mh\Desktop\Test");
      //Check.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lUnixUrl) Always(true), "\\RIBBONS\Users\mh\Desktop\Test");

      var lWindowsDriveLetterUrl := Url.UrlWithWindowsPath("C:\Users\mh\Desktop");
      Check.AreEqual(Url.UrlWithWindowsPath("C:\Users\mh\").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "..");
      Check.AreEqual(Url.UrlWithWindowsPath("C:\Users\mh\Library").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "../Library");
      Check.AreEqual(Url.UrlWithWindowsPath("C:\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "Test");
      Check.AreEqual(Url.UrlWithWindowsPath("C:\Users\").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "../..");
      Check.AreEqual(Url.UrlWithWindowsPath("C:\").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "../../..");
      Check.AreEqual(Url.UrlWithWindowsPath("c:\Users\").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "../..");
      Check.AreEqual(Url.UrlWithWindowsPath("D:\").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), nil);
      Check.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), nil);
      Check.AreEqual(Url.UrlWithFilePath("/Users/mh/Desktop/Test").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), nil);
      //Check.AreEqual(Url.UrlWithWindowsPath("D:\").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "D:\");
      //Check.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "\\RIBBONS\Users\mh\Desktop\Test");
      //Check.AreEqual(Url.UrlWithUnixPath("/Users/mh/Desktop/Test").UnixPathRelativeToUrl(lWindowsDriveLetterUrl) Always(true), "/Users/mh/Desktop/Test");

      var lWindowsDriveLetterUrl2 := Url.UrlWithWindowsPath("C:\Users\mh\Desktop\Really\Long\Path");
      Check.AreEqual(Url.UrlWithWindowsPath("C:\Users\Different\Path").WindowsPathRelativeToUrl(lWindowsDriveLetterUrl2) Threshold(2), "C:\Users\Different\Path");
      Check.AreEqual(Url.UrlWithWindowsPath("D:\Different\Drive").WindowsPathRelativeToUrl(lWindowsDriveLetterUrl2) Always(true), nil);
      Check.AreEqual(Url.UrlWithWindowsPath("D:\Different\Drive").WindowsPathRelativeToUrl(lWindowsDriveLetterUrl2) Always(false), "D:\Different\Drive");

      var lWindowsNetworkUrl := Url.UrlWithWindowsPath("\\RIBBONS\Users\mh\Desktop");
      Check.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\Users\mh\").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "..");
      Check.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\Users\mh\Library").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "../Library");
      Check.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\Users\").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "../..");
      Check.AreEqual(Url.UrlWithWindowsPath("\\RIBBONS\").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "../../..");
      Check.AreEqual(Url.UrlWithWindowsPath("\\Ribbons\Users\").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "../..");

      Check.AreEqual(Url.UrlWithWindowsPath("\\FLOORSHOW\").WindowsPathRelativeToUrl(lWindowsNetworkUrl) Always(false), "\\FLOORSHOW\");
      Check.AreEqual(Url.UrlWithWindowsPath("\\FLOORSHOW\").WindowsPathRelativeToUrl(lWindowsNetworkUrl) Always(true), nil);
      Check.AreEqual(Url.UrlWithWindowsPath("\\FLOORSHOW\").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(false), "\\FLOORSHOW\");
      Check.AreEqual(Url.UrlWithWindowsPath("\\FLOORSHOW\").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), nil);


      Check.AreEqual(Url.UrlWithWindowsPath("\\FLOORSHOW\Users\mh\Desktop").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), nil);
      Check.AreEqual(Url.UrlWithWindowsPath("C:\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), nil);
      Check.AreEqual(Url.UrlWithFilePath("/Users/mh/Desktop/Test").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), nil);
      //Check.AreEqual(Url.UrlWithWindowsPath("\\FLOORSHOW\").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "\\FLOORSHOW\");
      //Check.AreEqual(Url.UrlWithWindowsPath("\\FLOORSHOW\Users\mh\Desktop").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "\\FLOORSHOW\Users\mh\Desktop");
      //Check.AreEqual(Url.UrlWithWindowsPath("C:\Users\mh\Desktop\Test").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "C:\Users\mh\Desktop\Test");
      //Check.AreEqual(Url.UrlWithUnixPath("/Users/mh/Desktop/Test").UnixPathRelativeToUrl(lWindowsNetworkUrl) Always(true), "/Users/mh/Desktop/Test");
    end;


    method Dummy2();
    begin
      //var baseUrl := Url.UrlWithString("file:///Users/mh/Code/git/EUnit/");
      //var url2 := Url.UrlWithString("file:///Users/mh/Code/IslandRTL/Source/Bin/Debug/Linux/x86_64/Island.fx");
      //var url := Url.UrlWithUnixPath("/Users/mh/Code/IslandRTL/Source/Bin/Debug/Linux/x86_64/Island.fx");
      //writeLn(url2);
      //writeLn(url);
      //var path := url.FilePathRelativeToUrl(baseUrl) Threshold(3);
      //writeLn(path);
    end;

    method Dummy();
    begin
      var include := "../Resources/Project Icons/Debug-BreakpointOff.png";
      var baseUrl := Url.UrlWithFilePath("/Users/mh/Code/Fire/FireApp/");
      var suburl := baseUrl.UrlWithRelativeOrAbsoluteFileSubPath(include);
      Check.IsNotNil(suburl);

      {$IF TOFFEE}
      var lUrl := NSURL.URLWithString("file:///Users/mh/Test%20Projects/App24/App24.sln");
      var u := lUrl as Url;
      Check.AreEqual(lUrl.absoluteString, "file:///Users/mh/Test%20Projects/App24/App24.sln");
      Check.AreEqual(u.ToAbsoluteString(), "file:///Users/mh/Test%20Projects/App24/App24.sln"); // fails ONLY when i inline Convert.Utf8BytesToString

      var solutionLicenseFile := Path.ChangeExtension(u.FilePath, "licenses");
      Check.AreEqual(solutionLicenseFile, "/Users/mh/Test Projects/App24/App24.licenses");
      {$ENDIF}
    end;

    method Escaping;
    begin
      //var base := Url.UrlWithFilePath("/foo");
      //var u := base.UrlWithRelativeOrAbsoluteWindowsSubPath("rofx-xcode\samples\website samples\oxygene\dasampleapp\masterviewcontroller.pas");
      //writeLn(u);

      //var base2 := Url.UrlWithFilePath("/foo/rofx-xcode/");
      //var u2 := base2.UrlWithRelativeOrAbsoluteWindowsSubPath("samples\website samples\oxygene\dasampleapp\masterviewcontroller.pas");
      //writeLn(u2);

      //var base3 := Url.UrlWithString("file:///foo/rofx-xcode/foo.pas");
      //var u3 := base3.CanonicalVersion;
      //writeLn(u3);

      ////writeLn("x");
    end;

    method TestPathComponents();
    begin
      var lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/Test.txt");

      Check.AreEqual(lUrl.PathExtension, ".txt");
      Check.AreEqual(lUrl.LastPathComponent, "Test.txt");

      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Check.AreEqual(lUrl.FilePathWithoutLastComponent, "/Users/mh/Desktop/");
      if Environment.OS in [OperatingSystem.Windows] then
        Check.AreEqual(lUrl.FilePathWithoutLastComponent, "\Users\mh\Desktop\");

      Check.AreEqual(lUrl.WindowsPathWithoutLastComponent, "\Users\mh\Desktop\");
      Check.AreEqual(lUrl.UnixPathWithoutLastComponent, "/Users/mh/Desktop/");

      Check.AreEqual(lUrl.UrlWithoutLastComponent.ToAbsoluteString, "file:///Users/mh/Desktop/");

      lUrl := Url.UrlWithFilePath("foo.txt");
      Check.AreEqual(lUrl.PathExtension, ".txt");

      lUrl := Url.UrlWithWindowsPath("C:\Program Files\Tést.txt");
      Check.AreEqual(lUrl.PathExtension, ".txt");
      Check.AreEqual(lUrl.LastPathComponent, "Tést.txt");

      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Check.AreEqual(lUrl.FilePathWithoutLastComponent, "/C:/Program Files/");
      if Environment.OS in [OperatingSystem.Windows] then
        Check.AreEqual(lUrl.FilePathWithoutLastComponent, "C:\Program Files\");

      Check.AreEqual(lUrl.UnixPathWithoutLastComponent, "/C:/Program Files/");
      Check.AreEqual(lUrl.WindowsPathWithoutLastComponent, "C:\Program Files\");
      Check.AreEqual(lUrl.UrlWithoutLastComponent.ToAbsoluteString, "file:///C:/Program%20Files/");

      lUrl := Url.UrlWithFilePath("/foo/bar/test.txt");
      Check.AreEqual(lUrl.UrlWithChangedPathExtension("foo").ToAbsoluteString, "file:///foo/bar/test.foo");
      Check.AreEqual(lUrl.UrlWithChangedPathExtension(".foo").ToAbsoluteString, "file:///foo/bar/test.foo");
    end;

    method TestOperators();
    begin
      var lUrl1 := Url.UrlWithFilePath("/Users/mh/Desktop/Test.txt");
      var lUrl2 := Url.UrlWithFilePath("/Users/mh/Desktop/Test.txt");
      var lUrl3 := Url.UrlWithFilePath("/Users/mh/Desktop/Test2.txt");
      Check.AreEqual(lUrl1 = lUrl2, true); //FAILS
      Check.AreEqual(lUrl1 ≠ lUrl3, true);

      var lUrl1A := lUrl1 as Object;
      var lUrl2A := lUrl2 as Object;
      var lUrl3A := lUrl2 as Object;

      Check.AreEqual(lUrl1 = lUrl2A, true); // calls fiest operator
      Check.AreEqual(lUrl1A = lUrl2, true); // calls scond operator

      Check.AreEqual(lUrl1A = lUrl2A, false); // expected to fail, object comparisson
      Check.AreEqual(lUrl1A ≠ lUrl3A, true);
    end;


  end;

end.