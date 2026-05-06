namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  JsonTests = public class(Test)
  public

    method Floats;
    begin
      var f := JsonFloatValue(12.18688);
      Check.AreEqual(f.ToString, "12.18688");
      Check.AreEqual(f.ToJsonString, "12.18688");
      Check.AreNotEqual(f.ToJsonString, "12.187");
    end;

    method TryFromAString;
    begin
      var lJson := JsonDocument.TryFromString("");
      Check.IsNil(lJson);
    end;

    method TryFromStringHandlesIncompleteJsonBasedOnAllowPartial;
    begin
      Check.IsNil(JsonDocument.TryFromString('{"name":"value"'));
      Check.IsNil(JsonDocument.TryFromString('{"name":"value"', false));
      Check.IsNotNil(JsonDocument.TryFromString('{"name":"value"', true));

      Check.IsNil(JsonDocument.TryFromString('{"name":"value'));
      Check.IsNil(JsonDocument.TryFromString('{"name":"value', false));
      Check.IsNotNil(JsonDocument.TryFromString('{"name":"value', true));

      Check.IsNil(JsonDocument.TryFromString('{ "name": "long string'));
      Check.IsNil(JsonDocument.TryFromString('{ "name": "long string', false));
      Check.IsNotNil(JsonDocument.TryFromString('{ "name": "long string', true));

      Check.IsNil(JsonDocument.TryFromString('{"name":{"nested":1}'));
      Check.IsNil(JsonDocument.TryFromString('{"name":{"nested":1}', false));
      Check.IsNotNil(JsonDocument.TryFromString('{"name":{"nested":1}', true));

      Check.IsNil(JsonDocument.TryFromString('{"name":{"nested":"value"}'));
      Check.IsNil(JsonDocument.TryFromString('{"name":{"nested":"value"}', false));
      Check.IsNotNil(JsonDocument.TryFromString('{"name":{"nested":"value"}', true));
    end;

    method TryFromStringOutExceptionRejectsIncompleteJson;
    begin
      var lException: Exception;
      var lJson := JsonDocument.TryFromString('{"name":"value"', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('{"name":"value', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('{ "name": "long string', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);
      Check.IsTrue(lException is JsonUnexpectedEndOfFileException);
      Check.AreEqual(lException.Message, "Unexpected end of string at 1/23 for string node started at 1/11.");

      lException := nil;
      lJson := JsonDocument.TryFromString('{"name":{"nested":1}', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('{"name":{"nested":"value"}', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);
    end;

    method TryFromStringRejectsMalformedObjectSyntax;
    begin
      Check.IsNil(JsonDocument.TryFromString('{:'));
      Check.IsNil(JsonDocument.TryFromString('{:', false));
      Check.IsNil(JsonDocument.TryFromString('{:', true));

      Check.IsNil(JsonDocument.TryFromString('{]'));
      Check.IsNil(JsonDocument.TryFromString('{]', false));
      Check.IsNil(JsonDocument.TryFromString('{]', true));

      Check.IsNil(JsonDocument.TryFromString('{"a":1, ]'));
      Check.IsNil(JsonDocument.TryFromString('{"a":1, ]', false));
      Check.IsNil(JsonDocument.TryFromString('{"a":1, ]', true));

      Check.IsNil(JsonDocument.TryFromString('{123: 4}'));
      Check.IsNil(JsonDocument.TryFromString('{123: 4}', false));
      Check.IsNil(JsonDocument.TryFromString('{123: 4}', true));
    end;

    method TryFromStringOutExceptionRejectsMalformedObjectSyntax;
    begin
      var lException: Exception;
      var lJson := JsonDocument.TryFromString('{:', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('{]', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('{"a":1, ]', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('{123: 4}', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);
    end;

    method TryFromStringOutExceptionFormatsExpectedTokensForMalformedObjectSyntax;
    begin
      var lException: Exception;
      var lJson := JsonDocument.TryFromString('{:', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);
      Check.IsTrue(lException is JsonUnexpectedTokenException);
      Check.AreEqual(lException.Message, "Unexpected token at 1/2; expected 'String, Identifier', got 'NameSeperator'.");

      lException := nil;
      lJson := JsonDocument.TryFromString('{"a":1, ]', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);
      Check.IsTrue(lException is JsonUnexpectedTokenException);
      Check.AreEqual(lException.Message, "Unexpected token at 1/9; expected 'String, Identifier', got 'ArrayEnd'.");
    end;

    method TryFromStringParsesTopLevelStringValue;
    begin
      var lException: Exception;
      var lJson := JsonDocument.TryFromString('"hello"', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed: {lException.Message}");

      if not assigned(lJson) then
        raise new Exception("Parser returned nil without an exception.");

      Check.AreEqual(lJson.NodeKind, JsonNodeKind.String);
      Check.AreEqual(lJson.StringValue, "hello");
    end;

    method TryFromStringParsesTopLevelPrimitiveValues;
    begin
      var lException: Exception;

      var lJson := JsonDocument.TryFromString('123', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for integer root: {lException.Message}");
      Check.IsNotNil(lJson);
      Check.AreEqual(lJson.ToJsonString, '123');

      lException := nil;
      lJson := JsonDocument.TryFromString('-45.5', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for float root: {lException.Message}");
      Check.IsNotNil(lJson);
      Check.AreEqual(lJson.ToJsonString, '-45.5');

      lException := nil;
      lJson := JsonDocument.TryFromString('true', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for true root: {lException.Message}");
      Check.IsNotNil(lJson);
      Check.AreEqual(lJson.ToJsonString, 'true');

      lException := nil;
      lJson := JsonDocument.TryFromString('false', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for false root: {lException.Message}");
      Check.IsNotNil(lJson);
      Check.AreEqual(lJson.ToJsonString, 'false');

      lException := nil;
      lJson := JsonDocument.TryFromString('null', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for null root: {lException.Message}");
      Check.IsNotNil(lJson);
      Check.AreEqual(lJson.ToJsonString, 'null');

      lException := nil;
      lJson := JsonDocument.TryFromString('  123  ', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for whitespace-wrapped integer root: {lException.Message}");
      Check.IsNotNil(lJson);
      Check.AreEqual(lJson.ToJsonString, '123');

      lException := nil;
      lJson := JsonDocument.TryFromString('  -45.5  ', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for whitespace-wrapped float root: {lException.Message}");
      Check.IsNotNil(lJson);
      Check.AreEqual(lJson.ToJsonString, '-45.5');

      lException := nil;
      lJson := JsonDocument.TryFromString('  true  ', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for whitespace-wrapped true root: {lException.Message}");
      Check.IsNotNil(lJson);
      Check.AreEqual(lJson.ToJsonString, 'true');

      lException := nil;
      lJson := JsonDocument.TryFromString('  false  ', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for whitespace-wrapped false root: {lException.Message}");
      Check.IsNotNil(lJson);
      Check.AreEqual(lJson.ToJsonString, 'false');

      lException := nil;
      lJson := JsonDocument.TryFromString('  null  ', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for whitespace-wrapped null root: {lException.Message}");
      Check.IsNotNil(lJson);
      Check.AreEqual(lJson.ToJsonString, 'null');
    end;

    method TryFromStringRejectsExtraTokensAfterTopLevelPrimitive;
    begin
      var lException: Exception;

      var lJson := JsonDocument.TryFromString('"hello" 1', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('true false', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('null []', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('123 456', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('"hello"x', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);
    end;

    method TryFromStringParsesWhitespaceWrappedTopLevelStringValue;
    begin
      var lException: Exception;
      var lJson := JsonDocument.TryFromString('  "trimmed"  ', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for whitespace-wrapped string root: {lException.Message}");

      if not assigned(lJson) then
        raise new Exception("Parser returned nil without an exception.");

      Check.AreEqual(lJson.NodeKind, JsonNodeKind.String);
      Check.AreEqual(lJson.StringValue, 'trimmed');

      lException := nil;
      lJson := JsonDocument.TryFromString('  [1,2,3]  ', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for whitespace-wrapped array root: {lException.Message}");

      if not assigned(lJson) then
        raise new Exception("Parser returned nil without an exception.");

      Check.AreEqual(lJson.NodeKind, JsonNodeKind.Array);
      Check.AreEqual(lJson.Count, 3);
      Check.AreEqual((lJson as JsonArray)[0].ToJsonString, '1');
      Check.AreEqual((lJson as JsonArray)[1].ToJsonString, '2');
      Check.AreEqual((lJson as JsonArray)[2].ToJsonString, '3');

      lException := nil;
      lJson := JsonDocument.TryFromString('  {"a":1}  ', out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed for whitespace-wrapped object root: {lException.Message}");

      if not assigned(lJson) then
        raise new Exception("Parser returned nil without an exception.");

      Check.AreEqual(lJson.NodeKind, JsonNodeKind.Object);
      Check.AreEqual(lJson.Count, 1);
      Check.IsTrue((lJson as JsonObject).ContainsKey('a'));
      var lObjectValue := (lJson as JsonObject)[String('a')];
      Check.AreEqual(lObjectValue.ToJsonString, '1');
    end;

    method TryFromStringRejectsExtraTokensAfterTopLevelContainer;
    begin
      var lException: Exception;

      var lJson := JsonDocument.TryFromString('{"name":5} xyz', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('[1,2,3] false', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);
    end;

    method TryFromStringParsesLargeEscapedFtpClientSource;
    begin
      var lJsonText: String := ###""""
"/*---------------------------------------------------------------------------\n  RemObjects Internet Pack for .NET\n  (c)opyright RemObjects Software, LLC. 2003-2016. All rights reserved.\n---------------------------------------------------------------------------*/\n\nusing RemObjects.InternetPack.CommandBased;\nusing RemObjects.InternetPack.Events;\nusing RemObjects.Elements.RTL;\n\nnamespace RemObjects.InternetPack.Ftp\n{\n    // ftp://ftp.rfc-editor.org/in-notes/rfc959.txt\n#if DESIGN\n    [System.Drawing.ToolboxBitmap(typeof(RemObjects.InternetPack.Server), \"Glyphs.FtpClient.bmp\")]\n#endif\n    public class FtpClient : CommandBasedClient\n    {\n        #region Private fields\n        private IPAddress fDataAddress;\n        private Int32 fDataPort;\n        private Connection fDataConnection;\n        private SimpleServer fDataServer;\n        private String fCurrentDirectory;\n        #endregion\n\n        public FtpClient()\n        {\n            this.Passive = false;\n            this.AutoRetrieveListing = true;\n            this.fCurrentDirectory = String.Empty;\n            this.fCurrentDirectoryContents = new FtpListing();\n        }\n\n        #region Properties\n        public String UserName { get; set; }\n\n        public String Password { get; set; }\n\n        public String Account { get; set; }\n\n        public Boolean Passive { get; set; }\n\n        public Boolean ShowHiddenFiles { get; set; }\n\n        public Encoding Encoding\n        {\n            get\n            {\n                return this.fEncoding ?? (this.fEncoding = Encoding.UTF8);\n            }\n            set\n            {\n                this.fEncoding = value;\n            }\n        }\n        private Encoding fEncoding;\n\n        public Boolean AutoRetrieveListing { get; set; }\n\n        public FtpListing CurrentDirectoryContents\n        {\n            get\n            {\n                return this.fCurrentDirectoryContents;\n            }\n        }\n        private readonly FtpListing fCurrentDirectoryContents;\n        #endregion\n\n        public override void Open()\n        {\n            base.Open();\n\n            this.CurrentConnection.Encoding = Encoding;\n\n            if (!this.WaitForResponse(220))\n            {\n                this.Close();\n                throw new CmdResponseException(\"Invalid connection reply\", this.LastResponseNo, this.LastResponseText);\n            }\n        }\n\n        public override void Close()\n        {\n            base.Close();\n\n            if (this.fDataConnection != null && this.fDataConnection.Connected)\n                this.fDataConnection.Close();\n        }\n\n        public void Login()\n        {\n            if (!this.SendAndWaitForResponse(\"USER \" + this.UserName, 331, 230))\n                throw new CmdResponseException(\"Login unsuccessful\", this.LastResponseNo, this.LastResponseText);\n\n            switch (this.LastResponseNo)\n            {\n                case 331:\n                    if (!this.SendAndWaitForResponse(\"PASS \" + this.Password, 230, 332))\n                        throw new CmdResponseException(\"Login unsuccessful\", this.LastResponseNo, this.LastResponseText);\n\n                    switch (this.LastResponseNo)\n                    {\n                        case 232:\n                            SendAccount();\n                            break;\n\n                        case 230:\n                            break;\n                    }\n                    break;\n\n                case 230:\n                    break;\n            }\n        }\n\n        public void SendAccount()\n        {\n            if (this.Account.Length == 0)\n                throw new Exception(\"Account cannot be blank\");\n\n            if (!this.SendAndWaitForResponse(\"ACCT \" + this.Account, 230, 202))\n                throw new CmdResponseException(\"Account command unsuccessful\", this.LastResponseNo, this.LastResponseText);\n        }\n\n        public void Quit()\n        {\n            if (!this.SendAndWaitForResponse(\"QUIT\", 221))\n                throw new CmdResponseException(\"Quit unsuccessful\", this.LastResponseNo, this.LastResponseText);\n        }\n\n        public void ChangeDirectory(String directory)\n        {\n            if (!this.SendAndWaitForResponse(\"CWD \" + directory, 250))\n                throw new CmdResponseException(\"Error changing directory\", this.LastResponseNo, this.LastResponseText);\n\n            if (this.AutoRetrieveListing)\n                this.List();\n        }\n\n        public void ChangeToParentDirectory()\n        {\n            if (!this.SendAndWaitForResponse(\"CDUP\", 250))\n                throw new CmdResponseException(\"Error changing directory\", this.LastResponseNo, this.LastResponseText);\n\n            if (this.AutoRetrieveListing)\n                this.List();\n        }\n\n        public String GetCurrentDirectory()\n        {\n            if (!this.SendAndWaitForResponse(\"PWD\", 257))\n                throw new CmdResponseException(\"Could not retrieve current directory\", this.LastResponseNo, this.LastResponseText);\n\n            StringBuilder lResult = new StringBuilder();\n\n            Int32 i = 1;\n            while (i < this.LastResponseText.Length)\n            {\n                if (this.LastResponseText[i] == '\"')\n                {\n                    if (i < this.LastResponseText.Length - 1 && this.LastResponseText[i + 1] == '\"')\n                    {\n                        lResult.Append('\"');\n                        i++; // skip extra doubled quote\n                    }\n                    else\n                    {\n                        break;\n                    }\n                }\n                else\n                {\n                    lResult.Append(this.LastResponseText[i]);\n                }\n                i++;\n            }\n\n            this.fCurrentDirectory = lResult.ToString();\n\n            return this.fCurrentDirectory;\n        }\n\n        public void RemoveDirectory(String directory)\n        {\n            if (!this.SendAndWaitForResponse(\"RMD \" + directory, 250))\n                throw new CmdResponseException(\"Error removing directory\", LastResponseNo, LastResponseText);\n\n            if (this.AutoRetrieveListing)\n                this.List();\n        }\n\n        public void RemoveDirectory(String directory, Boolean recursive)\n        {\n            if (recursive)\n            {\n                this.ChangeDirectory(directory);\n                try\n                {\n                    this.List(true);\n                    foreach (FtpListingItem ftpItem in this.CurrentDirectoryContents)\n                    {\n                        if (ftpItem.FileName != \"..\")\n                        {\n                            if (ftpItem.Directory)\n                                this.RemoveDirectory(ftpItem.FileName);\n                            else\n                                this.Delete(ftpItem.FileName);\n                        }\n                    }\n                }\n                finally\n                {\n                    this.ChangeToParentDirectory();\n                }\n            }\n\n            this.RemoveDirectory(directory);\n        }\n\n        public void MakeDirectory(String directory)\n        {\n            if (!this.SendAndWaitForResponse(\"MKD \" + directory, 257))\n                throw new CmdResponseException(\"Error making directory\", LastResponseNo, LastResponseText);\n\n            if (this.AutoRetrieveListing)\n                this.List();\n        }\n\n        private static String[] ParsePasiveResponse(String response)\n        {\n            var lPos = response.IndexOf('(');\n            if (lPos >= 0)\n            {\n                // this is the standard: 227 Entering Passive Mode (213,229,112,130,216,4)\n                var lEndPos = response.IndexOf(')');\n                if (lEndPos >= 0)\n                {\n                    var lString = response.Substring(lPos + 1, lEndPos - lPos - 1);\n                    var lGroups = lString.Split(',');\n                    var lResult = new String[lGroups.Count];\n                    for (int i = 0; i < lGroups.Count; i++)\n                    {\n                        lResult[i] = lGroups[i].Trim();\n                    }\n                    return lResult;\n                }\n            }\n            else\n            {\n                // non standard servers, looking for x1,x2,x3,x4,p1,p2\n                lPos = response.IndexOf(',');\n                if (lPos >= 0)\n                {\n                    var lGroups = response.Split(',');\n                    var lResult = new String[lGroups.Count];\n                    if (lGroups.Count > 0)\n                    {\n                        var lItem = lGroups[0].Trim();\n                        var lPointer = lItem.Length - 1;\n                        while((lPointer > 0) && (ord(lItem[lPointer]) >= ord('0') && (ord(lItem[lPointer]) <= ord('9'))))\n                            lPointer--;\n                        lResult[0] = lItem.Substring(lPointer + 1);\n\n                        lItem = lGroups[lGroups.Count - 1];\n                        lPointer = 0;\n                        while((lPointer < lItem.Length) && (ord(lItem[lPointer]) >= ord('0') && (ord(lItem[lPointer]) <= ord('9'))))\n                            lPointer++;\n                        lResult[lResult.Count() - 1] = lItem.Substring(0, lPointer);\n\n                        for(int i = 1; i < lGroups.Count - 1; i++)\n                            lResult[i] = lGroups[i].Trim();\n\n                        return lResult;\n                    }\n                }\n            }\n\n            throw new Exception(\"Error processing PASV command\");\n        }\n\n        public void StartPassiveConnection()\n        {\n            if (!this.SendAndWaitForResponse(\"PASV\", 227))\n                throw new CmdResponseException(\"Could not set passive mode\", this.LastResponseNo, this.LastResponseText);\n\n            //Match lMatch = Regex.Match(LastResponseText, @\"(?<A1>\\d+),(?<A2>\\d+),(?<A3>\\d+),(?<A4>\\d+),(?<P1>\\d+),(?<P2>\\d+)\");\n            //GroupCollection lGroups = lMatch.Groups;\n\n            //this.fDataAddress = IPAddress.Parse(String.Format(\"{0}.{1}.{2}.{3}\", lGroups[\"A1\"].Value, lGroups[\"A2\"].Value, lGroups[\"A3\"].Value, lGroups[\"A4\"].Value));\n            var lGroups = ParsePasiveResponse(LastResponseText);\n            this.fDataAddress = IPAddress.Parse(String.Format(\"{0}.{1}.{2}.{3}\", lGroups[0], lGroups[1], lGroups[2], lGroups[3]));\n            this.fDataPort = (Convert.ToByte(lGroups[4]) * 256) + Convert.ToByte(lGroups[5]);\n\n            this.SendLog(TransferDirection.None, \"Connecting to {0}:{1}\", this.fDataAddress, this.fDataPort);\n            this.fDataConnection = this.NewConnection(CurrentConnection.Binding);\n            this.fDataConnection.Connect(this.fDataAddress, this.fDataPort);\n            this.fDataConnection.Encoding = Encoding;\n            this.SendLog(TransferDirection.None, \"Connected to {0} port {1}\", this.fDataAddress, this.fDataPort);\n\n            this.fDataConnection.OnBytesReceived += this.TriggerOnBytesReceived;\n            this.fDataConnection.OnBytesSent += this.InternalOnBytesSent;\n        }\n\n        public void StartActiveConnection()\n        {\n            if (this.fDataConnection != null)\n            {\n                if (this.fDataConnection.Connected)\n                    this.fDataConnection.Close();\n                this.fDataConnection = null;\n            }\n\n            if (this.fDataServer == null)\n            {\n                this.fDataServer = new SimpleServer();\n                this.fDataServer.Binding.Address = ((IPEndPoint)CurrentConnection.LocalEndPoint).Address;\n                this.fDataServer.Open();\n            }\n\n            Byte[] lAddress;\n#if FULLFRAMEWORK\n            lAddress = ((IPEndPoint)this.fDataServer.Binding.ListeningSocket.LocalEndPoint).Address.GetAddressBytes();\n#endif\n#if COMPACTFRAMEWORK\n            IPAddress lIPAddress = ((IPEndPoint)this.fDataServer.Binding.ListeningSocket.LocalEndPoint).Address;\n            String[] lIPAddressstr = lIPAddress.ToString().Split(new Char[] {'.'});\n            lAddress = new Byte[lIPAddressstr.Length];\n            for (Int32 i = 0; i < lIPAddressstr.Length; i++)\n                lAddress[i] = Byte.Parse(lIPAddressstr[i]);\n#endif\n\n            Int32 lPort = ((IPEndPoint)this.fDataServer.Binding.ListeningSocket.LocalEndPoint).Port;\n            #if echoes\n            String lPortCommand = String.Format(\"PORT {0},{1},{2},{3},{4},{5}\", lAddress[0], lAddress[1], lAddress[2], lAddress[3], unchecked((Byte)(lPort >> 8)), unchecked((Byte)lPort));\n            #else\n            String lPortCommand = String.Format(\"PORT {0},{1},{2},{3},{4},{5}\", lAddress[0], lAddress[1], lAddress[2], lAddress[3], (Byte)(lPort >> 8), (Byte)lPort);\n            #endif\n\n            if (!SendAndWaitForResponse(lPortCommand, 200))\n                throw new CmdResponseException(\"Error in PORT command\", LastResponseNo, LastResponseText);\n        }\n\n        private void RetrieveDataConnection()\n        {\n            if (!this.Passive)\n            {\n                if (this.fDataServer == null)\n                    throw new Exception(\"DataServer is not assigned\");\n\n                Connection lConnection = this.fDataServer.WaitForConnection();\n                this.fDataServer.Close();\n                this.fDataServer = null;\n                this.fDataConnection = lConnection;\n                this.fDataConnection.Encoding = this.Encoding;\n            }\n        }\n\n        public String List()\n        {\n            return this.List(false);\n        }\n\n        public String List(Boolean showHiddenFiles)\n        {\n            String lResult;\n\n            this.SetType(\"A\");\n            this.CheckDataConnection();\n\n            if (!this.SendAndWaitForResponse(this.ShowHiddenFiles || showHiddenFiles ? \"LIST -a\" : \"LIST\", 125, 150))\n                throw new CmdResponseException(\"Could not start LIST command\", LastResponseNo, LastResponseText);\n\n            this.RetrieveDataConnection();\n            Byte[] lResponse = this.fDataConnection.ReceiveAllRemaining();\n            this.fDataConnection.Close();\n\n            if (lResponse != null)\n            {\n                try\n                {\n                    lResult = this.fDataConnection.Encoding.GetString(lResponse, 0, lResponse.Length);\n                    this.CurrentDirectoryContents.Parse(lResult, this.fCurrentDirectory != \"/\");\n                }\n                catch\n                {\n                    // we don't want any exception here\n                    lResult = null;\n                    this.fCurrentDirectoryContents.Clear();\n                }\n            }\n            else\n            {\n                lResult = null;\n                this.CurrentDirectoryContents.Clear();\n            }\n            this.WaitForResponse(226);\n\n            this.TriggerOnNewListing();\n\n            return lResult;\n        }\n\n        public void Delete(String filename)\n        {\n            if (!this.SendAndWaitForResponse(\"DELE \" + filename, 250))\n                throw new CmdResponseException(\"Error deleting file\", this.LastResponseNo, this.LastResponseText);\n\n            if (this.AutoRetrieveListing)\n                this.List();\n        }\n\n        public void SetType(String type)\n        {\n            if (!SendAndWaitForResponse(\"TYPE \" + type, 200))\n                throw new CmdResponseException(\"Error sending TYPE command\", this.LastResponseNo, this.LastResponseText);\n        }\n\n        private void CheckDataConnection()\n        {\n            if (this.fDataConnection == null || (this.fDataConnection != null && !this.fDataConnection.Connected))\n            {\n                if (this.Passive)\n                    this.StartPassiveConnection();\n                else\n                    this.StartActiveConnection();\n            }\n        }\n\n        public void Retrieve(FtpListingItem item, Stream stream)\n        {\n            this.Retrieve(item.FileName, item.Size, stream);\n        }\n\n        public void Retrieve(String filename, Int64 size, Stream stream)\n        {\n            this.SetType(\"I\");\n            this.CheckDataConnection();\n\n            if (!this.SendAndWaitForResponse(\"RETR \" + filename, 150, 125))\n                throw new CmdResponseException(\"Error retrieving file\", this.LastResponseNo, this.LastResponseText);\n\n            this.TriggerOnTransferStart(this, new TransferStartEventArgs(TransferDirection.Receive, size));\n\n            this.RetrieveDataConnection();\n            this.fDataConnection.ReceiveToStream(stream, size);\n            this.fDataConnection.Close();\n\n            this.WaitForResponse(226);\n        }\n\n        public void Store(String filename, Stream stream)\n        {\n            this.SetType(\"I\");\n            this.CheckDataConnection();\n\n            if (!this.SendAndWaitForResponse(\"STOR \" + filename, 150, 125))\n                throw new CmdResponseException(\"Error storing file\", LastResponseNo, LastResponseText);\n\n            this.TriggerOnTransferStart(this, new TransferStartEventArgs(TransferDirection.Receive, stream.Length));\n\n            this.RetrieveDataConnection();\n            this.fDataConnection.SendFromStream(stream);\n            this.fDataConnection.Close();\n\n            this.WaitForResponse(226);\n\n            if (this.AutoRetrieveListing)\n                this.List();\n        }\n\n        public void Rename(String from, String to)\n        {\n            if (!this.SendAndWaitForResponse(\"RNFR \" + from, 350))\n                throw new CmdResponseException(\"Error renaming file\", this.LastResponseNo, this.LastResponseText);\n\n            if (!this.SendAndWaitForResponse(\"RNTO \" + to, 250))\n                throw new CmdResponseException(\"Error renaming file\", this.LastResponseNo, this.LastResponseText);\n\n            if (this.AutoRetrieveListing)\n                this.List();\n        }\n\n        #region Events\n        public event TransferStartEventHandler OnTransferStart;\n\n        protected virtual void TriggerOnTransferStart(Object sender, TransferStartEventArgs e)\n        {\n            if (this.OnTransferStart != null)\n                this.OnTransferStart(sender, e);\n        }\n\n        public event TransferProgressEventHandler OnTransferProgress;\n\n        protected virtual void TriggerOnBytesReceived(Object sender, EventArgs e)\n        {\n            if (this.OnTransferProgress != null)\n                this.OnTransferProgress(sender, new TransferProgressEventArgs(TransferDirection.Receive, ((Connection)sender).BytesReceived));\n        }\n\n        protected virtual void InternalOnBytesSent(Object sender, EventArgs e)\n        {\n            if (this.OnTransferProgress != null)\n                this.OnTransferProgress(sender, new TransferProgressEventArgs(TransferDirection.Send, ((Connection)sender).BytesSent));\n        }\n\n        public event EventHandler OnNewListing;\n\n        protected virtual void TriggerOnNewListing()\n        {\n            if (this.OnNewListing != null)\n                this.OnNewListing(this, new EventArgs());\n        }\n        #endregion\n    }\n}"
""""; 

      lJsonText := lJsonText.Replace(String(#13), "").Replace(String(#10), "");

      var lException: Exception;
      var lJson := JsonDocument.TryFromString(lJsonText, out lException);
      if assigned(lException) then
        raise new Exception($"Parser failed: {lException.Message}");

      if not assigned(lJson) then
        raise new Exception("Parser returned nil without an exception.");

      Check.AreEqual(lJson.NodeKind, JsonNodeKind.String);
      Check.IsTrue(lJson.StringValue.StartsWith("/*---------------------------------------------------------------------------"));
      Check.IsTrue(lJson.StringValue.Contains("namespace RemObjects.InternetPack.Ftp"));
      Check.IsTrue(lJson.StringValue.Contains('throw new CmdResponseException("Could not set passive mode", this.LastResponseNo, this.LastResponseText);'));
      Check.IsTrue(lJson.StringValue.EndsWith("}"));
    end;

    method StringToYaml;
    begin
      Check.AreEqual(JsonStringValue("yes: null").ToYamlString, '"yes: null"');
      Check.AreEqual(JsonNullValue.Null.ToYamlString, 'null');
      Check.AreEqual(JsonBooleanValue.True.ToYamlString, 'true');
    end;

    method ArrayToYaml;
    begin
      var lBreak := Environment.LineBreak;
      var lJson := new JsonArray(new JsonStringValue("first value"), new JsonObject(), JsonNullValue.Null);

      Check.AreEqual(lJson.ToYamlString,
        '- "first value"'+lBreak+
        '- {}'+lBreak+
        '- null');
    end;

    method ObjectToYaml;
    begin
      var lBreak := Environment.LineBreak;
      var lJson := new JsonObject();
      lJson["items"] := new JsonArray(new JsonStringValue("first"), new JsonArray(), JsonNullValue.Null);

      Check.AreEqual(lJson.ToYamlString,
        '"items":'+lBreak+
        '  - "first"'+lBreak+
        '  - []'+lBreak+
        '  - null');
    end;

    method YamlOptionsAreApplied;
    begin
      var lOptions := new YamlOptions();
      lOptions.Indentation := #9;
      lOptions.NewLine := #10;
      lOptions.AlwaysQuoteKeys := false;
      lOptions.AlwaysQuoteStrings := false;
      lOptions.EmitDocumentMarker := true;

      var lJson := new JsonObject();
      lJson["name"] := new JsonStringValue("plain");
      lJson["items"] := new JsonArray(new JsonStringValue("two words"), new JsonObject());

      Check.AreEqual(lJson.ToYamlString(lOptions),
        '---'#10+
        'name: plain'#10+
        'items:'#10+
        #9'- two words'#10+
        #9'- {}');
    end;

  end;


end.
