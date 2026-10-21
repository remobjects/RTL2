namespace RemObjects.Elements.RTL
{
	//
	// Ported from RemObjects.Mono.Helpers
	//

	#if ECHOES
	using System;
	using System.Collections.Generic;
	using System.Linq;
	using System.Text;
	using System.Runtime.InteropServices;

	internal enum MacDomains: short
	{
		kSystemDomain = -32766, // Usually the root (like /Library/Application Support)
		kLocalDomain = -32765,
		kNetworkDomain = -32764,
		kUserDomain = -32763, // Inside the user directory (/Users/*/Library/Application Support)
		kClassicDomain = -32762
	}

	internal static class MacFolderTypes
	{
		/*
		public static readonly uint kDesktopFolderType = FourCharCode("desk");
		// the desktop folder; objects in this folder show on the desktop.
		public static readonly uint kTrashFolderType = FourCharCode("trsh"); // the trash folder; objects in this folder show up in the trash
		public static readonly uint kWhereToEmptyTrashFolderType = FourCharCode("empt"); // the "empty trash" folder; Finder starts empty from here down
		public static readonly uint kFontsFolderType = FourCharCode("font"); // Fonts go here
		public static readonly uint kPreferencesFolderType = FourCharCode("pref"); // preferences for applications go here
		public static readonly uint kSystemPreferencesFolderType = FourCharCode("sprf"); // the PreferencePanes folder, where Mac OS X Preference Panes go
		public static readonly uint kTemporaryFolderType = FourCharCode("temp"); //    On Mac OS X, each user has their own temporary items folder, and the Folder Manager attempts to set permissions of these
		//    folders such that other users can not access the data inside.  On Mac OS X 10.4 and later the data inside the temporary
		//    items folder is deleted at logout and at boot, but not otherwise.  Earlier version of Mac OS X would delete items inside
		//    the temporary items folder after a period of inaccess.  You can ask for a temporary item in a specific domain or on a
		//    particular volume by FSVolumeRefNum.  If you want a location for temporary items for a short time, then use either
		//    ( kUserDomain, kkTemporaryFolderType ) or ( kSystemDomain, kTemporaryFolderType ).  The kUserDomain varient will always be
		//    on the same volume as the user's home folder, while the kSystemDomain version will be on the same volume as /var/tmp/ ( and
		//    will probably be on the local hard drive in case the user's home is a network volume ).  If you want a location for a temporary
		//    file or folder to use for saving a document, especially if you want to use FSpExchangeFile() to implement a safe-save, then
		//    ask for the temporary items folder on the same volume as the file you are safe saving.
		//    However, be prepared for a failure to find a temporary folder in any domain or on any volume.  Some volumes may not have
		//    a location for a temporary folder, or the permissions of the volume may be such that the Folder Manager can not return
		//    a temporary folder for the volume.
		//    If your application creates an item in a temporary items older you should delete that item as soon as it is not needed,
		//    and certainly before your application exits, since otherwise the item is consuming disk space until the user logs out or
		//    restarts.  Any items left inside a temporary items folder should be moved into a folder inside the Trash folder on the disk
		//    when the user logs in, inside a folder named "Recovered items", in case there is anything useful to the end user.
		public static readonly uint kTemporaryItemsInCacheDataFolderType = FourCharCode("vtmp"); // A folder inside the kCachedDataFolderType for the given domain which can be used for transient data
		public static readonly uint kApplicationsFolderType = FourCharCode("apps"); //    Applications on Mac OS X are typically put in this folder ( or a subfolder ).
		public static readonly uint kVolumeRootFolderType = FourCharCode("root"); // root folder of a volume or domain
		public static readonly uint kDomainTopLevelFolderType = FourCharCode("dtop"); // The top-level of a Folder domain, e.g. "/System"*/
		public static readonly uint kDomainLibraryFolderType = FourCharCode("dlib"); // the Library subfolder of a particular domain
		/*public static readonly uint kUsersFolderType = FourCharCode("usrs"); // "Users" folder, usually contains one folder for each user.
		public static readonly uint kCurrentUserFolderType = FourCharCode("cusr"); // The folder for the currently logged on user; domain passed in is ignored.
		public static readonly uint kSharedUserDataFolderType = FourCharCode("sdat"); // A Shared folder, readable & writeable by all users
		public static readonly uint kDocumentsFolderType = FourCharCode("docs");
		*/
		public static readonly uint kApplicationSupportFolderType = FourCharCode("asup");
		//public static readonly uint kFavoritesFolderType = FourCharCode("favs");
		//public static readonly uint kInstallerLogsFolderType = FourCharCode("ilgf");
		//public static readonly uint kFolderActionsFolderType = FourCharCode("fasf");
		//public static readonly uint kKeychainFolderType = FourCharCode("kchn");
		//public static readonly uint kColorSyncFolderType = FourCharCode("sync");
		//public static readonly uint kPrintersFolderType = FourCharCode("impr");
		//public static readonly uint kSpeechFolderType = FourCharCode("spch");
		//public static readonly uint kDocumentationFolderType = FourCharCode("info");
		//public static readonly uint kUserSpecificTmpFolderType = FourCharCode("utmp");
		public static readonly uint kCachedDataFolderType = FourCharCode("cach");
		//public static readonly uint kFrameworksFolderType = FourCharCode("fram");
		//public static readonly uint kDeveloperFolderType = FourCharCode("devf");
		//public static readonly uint kSystemSoundsFolderType = FourCharCode("ssnd");
		//public static readonly uint kComponentsFolderType = FourCharCode("cmpd");
		//public static readonly uint kQuickTimeComponentsFolderType = FourCharCode("wcmp");
		//public static readonly uint kPictureDocumentsFolderType = FourCharCode("pdoc");
		//public static readonly uint kMovieDocumentsFolderType = FourCharCode("mdoc");
		//public static readonly uint kMusicDocumentsFolderType = FourCharCode("µdoc");
		//public static readonly uint kInternetSitesFolderType = FourCharCode("site");
		//public static readonly uint kPublicFolderType = FourCharCode("pubb");
		//public static readonly uint kAudioSupportFolderType = FourCharCode("adio");
		//public static readonly uint kAudioSoundsFolderType = FourCharCode("asnd");
		//public static readonly uint kAudioSoundBanksFolderType = FourCharCode("bank");
		//public static readonly uint kAudioAlertSoundsFolderType = FourCharCode("alrt");
		//public static readonly uint kAudioPlugInsFolderType = FourCharCode("aplg");
		//public static readonly uint kAudioComponentsFolderType = FourCharCode("acmp");
		//public static readonly uint kKernelExtensionsFolderType = FourCharCode("kext");
		//public static readonly uint kInstallerReceiptsFolderType = FourCharCode("rcpt");
		//public static readonly uint kFileSystemSupportFolderType = FourCharCode("fsys");
		//public static readonly uint kMIDIDriversFolderType = FourCharCode("midi");
		public static uint FourCharCode(string p)
		{
			unchecked
			{
				return (byte)p[3] | ((uint)p[2]) << 8 | ((uint)p[1]) << 16 | ((uint)p[0]) << 24;
			}
		}
	}

	internal class MacFolders
	{

		[StructLayout(LayoutKind.Sequential)]
		private struct CFRange
		{
			public IntPtr location;
			public IntPtr length;
		}

		[DllImport("/usr/lib/libobjc.A.dylib")]
		private extern static IntPtr objc_autoreleasePoolPush();

		[DllImport("/usr/lib/libobjc.A.dylib")]
		private extern static void objc_autoreleasePoolPop(IntPtr pool);

		[DllImport(Foundation.FoundationLib)]
		private extern static IntPtr NSSearchPathForDirectoriesInDomains(UIntPtr directory, UIntPtr domainMask, [MarshalAs(UnmanagedType.I1)] bool expandTilde);

		[DllImport(CoreFoundation.CFLib)]
		private extern static IntPtr CFArrayGetCount(IntPtr array);

		[DllImport(CoreFoundation.CFLib)]
		private extern static IntPtr CFArrayGetValueAtIndex(IntPtr array, IntPtr index);

		[DllImport(CoreFoundation.CFLib)]
		private extern static IntPtr CFStringGetLength(IntPtr theString);

		[DllImport(CoreFoundation.CFLib, CharSet = CharSet.Unicode)]
		private extern static void CFStringGetCharacters(IntPtr theString, CFRange range, [Out]char[] buffer);

		public static string GetFolder(MacDomains domain, uint folderType)
		{
			UIntPtr directory;
			if (folderType == MacFolderTypes.kApplicationSupportFolderType)
				directory = new UIntPtr(14); // NSApplicationSupportDirectory
			else if (folderType == MacFolderTypes.kCachedDataFolderType)
				directory = new UIntPtr(13); // NSCachesDirectory
			else if (folderType == MacFolderTypes.kDomainLibraryFolderType)
				directory = new UIntPtr(5); // NSLibraryDirectory
			else
				throw new ArgumentOutOfRangeException("folderType");

			UIntPtr domainMask;
			switch (domain)
			{
				case MacDomains.kUserDomain: domainMask = new UIntPtr(1); break;
				case MacDomains.kLocalDomain: domainMask = new UIntPtr(2); break;
				case MacDomains.kNetworkDomain: domainMask = new UIntPtr(4); break;
				case MacDomains.kSystemDomain: domainMask = new UIntPtr(8); break;
				default: throw new ArgumentOutOfRangeException("domain");
			}

			// FSFindFolder registers a volume observer even for a local folder lookup.
			// Its background volume inspection can block process exit on a stuck mount.
			var pool = objc_autoreleasePoolPush();
			try
			{
				var paths = NSSearchPathForDirectoriesInDomains(directory, domainMask, true);
				if (paths == IntPtr.Zero || CFArrayGetCount(paths) == IntPtr.Zero)
					throw new InvalidOperationException(string.Format("No folder for domain: {0} type: {1}", domain, folderType));

				var str = CFArrayGetValueAtIndex(paths, IntPtr.Zero);
				var range = new CFRange();
				range.location = IntPtr.Zero;
				range.length = CFStringGetLength(str);
				var strdata = new char[range.length.ToInt32()];
				CFStringGetCharacters(str, range, strdata);
				return new String(strdata);
			}
			finally
			{
				// The array and its strings are borrowed; copy the string before draining.
				objc_autoreleasePoolPop(pool);
			}
		}
	}
	#endif
}
