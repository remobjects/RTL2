namespace RemObjects.Elements.RTL.Tests;

interface

uses
  RemObjects.Elements.EUnit;

type
  Program = public static class
  public
    method Main(aArguments: array of String): Integer;
  end;

implementation

method Program.Main(aArguments: array of String): Integer;
begin
	if (length(aArguments) > 0) and aArguments[0].EqualsIgnoringCase("--multipart-upload") then begin
		var lEndpoint := if length(aArguments) > 1 then aArguments[1] else "https://httpbin.org/post";
		exit HttpMultipartUploadProbe.Run(lEndpoint);
	end;
	if (length(aArguments) > 1) and aArguments[0].EqualsIgnoringCase("--multipart-file-upload") then begin
		var lEndpoint := if length(aArguments) > 2 then aArguments[2] else "https://api.elevenlabs.io/v1/music/upload";
		exit HttpMultipartUploadProbe.RunFileUpload(lEndpoint, aArguments[1]);
	end;
	var lTests := Discovery.DiscoverTests();
  var lTestResult := Runner.RunTests(lTests) withListener(Runner.DefaultListener);
  result := if lTestResult.State = TestState.Succeeded then 0 else 1;
end;

end.
