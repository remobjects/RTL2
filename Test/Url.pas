namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.EUnit,
  Elements.RTL;

type
  UrlTests = public class(Test)
  public
  
    method TestUnixFileUrls();
    begin
      var PATH: String := "/Users/mh/Desktop/test.txt";
      var lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/test.txt");
      Assert.IsTrue(lUrl.IsFileUrl);
      Assert.IsTrue(lUrl.IsAbsoluteUnixFileURL);
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
      var PATH: String := "C:\Program Files\Test\Test.txt";
      var lUrl := Url.UrlWithFilePath(PATH);
      Assert.IsTrue(lUrl.IsFileUrl);
      Assert.IsFalse(lUrl.IsAbsoluteUnixFileURL);
      Assert.IsTrue(lUrl.IsAbsoluteWindowsFileURL);
      Assert.AreEqual(lUrl.Path, "C:/Program Files/Test/Test.txt"); 
      Assert.AreEqual(lUrl.ToAbsoluteString, "file://C:/Program%20Files/Test/Test.txt");

      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Assert.AreEqual(lUrl.FilePath, PATH.Replace("\","/")); // FilePath always has `/` on Unix
      if Environment.OS in [OperatingSystem.Windows] then
        Assert.AreEqual(lUrl.FilePath, PATH);                  // FilePath always has `\` on Windows
        
      var lUrl2 := lUrl.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file://C:/Program%20Files/Test/");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file://C:/Program%20Files/");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2.ToAbsoluteString, "file://C:/");
      lUrl2 := lUrl2.GetParentUrl;
      Assert.AreEqual(lUrl2, nil);

      var lUrl3 := lUrl.GetParentUrl.GetSubUrl("Test2.txt");
      Assert.AreEqual(lUrl3.ToAbsoluteString, "file://C:/Program%20Files/Test/Test2.txt");
    end;

    method TestEncodings();
    begin
      var lUrl := Url.UrlWithFilePath("C:\Program Files\Tëst\Tést.txt");
      Assert.AreEqual(lUrl.ToAbsoluteString, "file://C:/Program%20Files/T%C3%ABst/T%C3%A9st.txt");

      lUrl := Url.UrlWithString("file://C:/Program%20Files/T%C3%ABst/T%C3%A9st.txt");
      Assert.AreEqual(lUrl.ToAbsoluteString, "file://C:/Program%20Files/T%C3%ABst/T%C3%A9st.txt");
      Assert.AreEqual(lUrl.UnixPath, "C:/Program Files/Tëst/Tést.txt");
      Assert.AreEqual(lUrl.WindowsPath, "C:\Program Files\Tëst\Tést.txt");
    end;
    
    method TestPathComponents();
    begin
      var lUrl := Url.UrlWithFilePath("/Users/mh/Desktop/Test.txt");
      
      Assert.AreEqual(lUrl.PathExtension, ".txt");
      Assert.AreEqual(lUrl.LastPathComponent, "Test.txt");
      
      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Assert.AreEqual(lUrl.FilePathWithoutLastComponent, "/Users/mh/Desktop/");
      if Environment.OS in [OperatingSystem.Windows] then
        Assert.AreEqual(lUrl.FilePathWithoutLastComponent, "/Users/mh/Desktop/");

      Assert.AreEqual(lUrl.WindowsPathWithoutLastComponent, "\Users\mh\Desktop\");
      Assert.AreEqual(lUrl.UnixPathWithoutLastComponent, "/Users/mh/Desktop/");
      
      Assert.AreEqual(lUrl.UrlWithoutLastComponent.ToAbsoluteString, "file:///Users/mh/Desktop/");
      
      lUrl := Url.UrlWithFilePath("C:\Program Files\Tést.txt");
      Assert.AreEqual(lUrl.PathExtension, ".txt");
      Assert.AreEqual(lUrl.LastPathComponent, "Tést.txt");
      Assert.AreEqual(lUrl.FilePathWithoutLastComponent, "C:/Program Files/");
      Assert.AreEqual(lUrl.UrlWithoutLastComponent.ToAbsoluteString, "file://C:/Program%20Files/");    
    end;
    
  end;

end.
