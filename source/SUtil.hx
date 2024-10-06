/*package;

#if android
import android.AndroidTools;
import android.stuff.Permissions;
#end
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.Lib;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import flash.system.System;
*/

/**
 * author: Saw (M.A. Jigsaw)
 */

/*
using StringTools;

class SUtil {
	#if android
	private static var grantedPermsList:Array<Permissions> = AndroidTools.getGrantedPermissions(); // granted Permissions
	private static var aDir:String = null; // android dir 
	private static var sPath:String = AndroidTools.getExternalStorageDirectory(); // storage dir
	#end

	public static function getPath():String {
		#if android
		if (aDir != null && aDir.length > 0) {
			return aDir;
		} else {
			aDir = sPath + '/' + '.' + Application.current.meta.get('file') + '/';
		}
		return aDir;
		#else
		return '';
		#end
	}

	public static function doTheCheck() {
		#if android
		if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
			if (AndroidTools.sdkVersion > 23 || AndroidTools.sdkVersion == 23) {
				AndroidTools.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
			}
		}

		if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
			if (AndroidTools.sdkVersion > 23 || AndroidTools.sdkVersion == 23) {
				SUtil.applicationAlert('Permissions', "If you accepted the permisions for storage, good, you can continue, if you not the game can't run without storage permissions please grant them in app settings"
					+ '\n' + 'Press Ok To Close The App');
			} else {
				SUtil.applicationAlert('Permissions', "The Game can't run without storage permissions please grant them in app settings"
					+ '\n' + 'Press Ok To Close The App');
			}
		}

		if (!FileSystem.exists(sPath + '/' + '.' + Application.current.meta.get('file'))){
			FileSystem.createDirectory(sPath + '/' + '.' + Application.current.meta.get('file'));
		}

		if (!FileSystem.exists(SUtil.getPath() + 'assets')){
			SUtil.applicationAlert('Instructions:', 'You have to copy assets/assets from apk to your internal storage app directory'
				+ " ( here " + SUtil.getPath() + " )"
				+ "Whoops, it seems you didn't extract the files from the .APK! \nPlease watch the tutorial by pressing OK."
				+ '\n' + 'Press OK To close the app.');
			CoolUtil.browserLoad('https://youtu.be/zjvkTmdWvfU');
			System.exit(0);
		}
		if (!FileSystem.exists(SUtil.getPath() + 'mods')){
			SUtil.applicationAlert('Instructions:', 'You have to copy assets/mods from apk to your internal storage app directory'
				+ " ( here " + SUtil.getPath() + " )"
				+ "Whoops, it seems you didn't extract the files from the .APK! \nPlease watch the tutorial by pressing OK."
				+ '\n' + 'Press OK To close the app.');
			CoolUtil.browserLoad('https://youtu.be/zjvkTmdWvfU');
			System.exit(0);
		}
		#end
	}

	public static function gameCrashCheck() {
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
	}

	public static function onCrash(e:UncaughtErrorEvent):Void {
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		dateNow = StringTools.replace(dateNow, ' ', "_");
		dateNow = StringTools.replace(dateNow, ':', "'");
		var path:String = 'crash/' + 'crash_' + dateNow + '.txt';
		var errMsg:String = '';

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errMsg += file + ' (line ' + line + ')\n';
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += e.error;

		if (!FileSystem.exists(SUtil.getPath() + 'crash')) {
			FileSystem.createDirectory(SUtil.getPath() + 'crash');
		}

		File.saveContent(SUtil.getPath() + path, errMsg + '\n');

		Sys.println(errMsg);
		Sys.println('Crash dump saved in ' + Path.normalize(path));
		Sys.println('Making a simple alert ...');

		SUtil.applicationAlert('Uncaught Error :(, The Call Stack: ', errMsg);
		System.exit(0);
	}

	private static function applicationAlert(title:String, description:String) {
		Application.current.window.alert(description, title);
	}

	#if android
	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json', fileData:String = 'you forgot something to add in your code'){
		if (!FileSystem.exists(SUtil.getPath() + 'saves')){
			FileSystem.createDirectory(SUtil.getPath() + 'saves');
		}

		File.saveContent(SUtil.getPath() + 'saves/' + fileName + fileExtension, fileData);
		SUtil.applicationAlert('Done Action :)', 'File Saved Successfully!');
	}

	public static function saveClipboard(fileData:String = 'you forgot something to add in your code'){
		openfl.system.System.setClipboard(fileData);
		SUtil.applicationAlert('Done Action :)', 'Data Saved to Clipboard Successfully!');
	}

	public static function copyContent(copyPath:String, savePath:String) {
		if (!FileSystem.exists(savePath)) {
			var bytes = OpenFlAssets.getBytes(copyPath);
			File.saveBytes(savePath, bytes);
		}
	}
	#end
}*/
package;

#if android
import android.content.Context;
import android.widget.Toast;
import android.os.Environment;
#end
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import lime.system.System as LimeSystem;
import lime.utils.Assets as LimeAssets;
import lime.utils.Log as LimeLogger;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

enum StorageType
{
	DATA;
	EXTERNAL;
	EXTERNAL_DATA;
	MEDIA;
}

/**
 * ...
 * @author Mihai Alexandru (M.A. Jigsaw)
 * @modified mcagabe19
 */
class SUtil
{
	/**
	 * This returns the external storage path that the game will use by the type.
	 */
	public static function getPath(type:StorageType = MEDIA):String
	{
		var daPath:String = '';

		#if android
		switch (type)
		{
			case DATA:
				daPath = Context.getFilesDir() + '/';
			case EXTERNAL_DATA:
				daPath = Context.getExternalFilesDir(null) + '/';
			case EXTERNAL:
				daPath = Environment.getExternalStorageDirectory() + '/.' + Application.current.meta.get('file') + '/';
			case MEDIA:
				daPath = Environment.getExternalStorageDirectory() + '/Android/media/' + Application.current.meta.get('packageName') + '/';
		}
		#elseif ios
		daPath = LimeSystem.applicationStorageDirectory;
		#end

		return daPath;
	}

	/**
	 * A simple function that checks for game files/folders.
	 */
	public static function checkFiles():Void
	{
		#if mobile
		if (!FileSystem.exists(SUtil.getPath()))
		{
                        try {
			FileSystem.createDirectory(SUtil.getPath());
                        }
                        catch (e){
                        Lib.application.window.alert('Please create folder to\n' + SUtil.getPath() + '\nPress Ok to close the app', 'Error!');
			LimeSystem.exit(1);
                        }
		}
		if (!FileSystem.exists(SUtil.getPath() + 'assets') && !FileSystem.exists(SUtil.getPath() + 'mods'))
		{
			Lib.application.window.alert("Whoops, seems like you didn't extract the files from the .APK!\nPlease copy the files from the .APK to\n" + SUtil.getStorageDirectory(),
				'Error!');
			LimeSystem.exit(1);
		}
		else if ((FileSystem.exists(SUtil.getPath() + 'assets') && !FileSystem.isDirectory(SUtil.getPath() + 'assets'))
			&& (FileSystem.exists(SUtil.getPath() + 'mods') && !FileSystem.isDirectory(SUtil.getPath() + 'mods')))
		{
			Lib.application.window.alert("Why did you create two files called assets and mods instead of copying the folders from the .APK?, expect a crash.",
				'Error!');
			LimeSystem.exit(1);
		}
		else
		{
			if (!FileSystem.exists(SUtil.getPath() + 'assets'))
			{
				Lib.application.window.alert("Whoops, seems like you didn't extract the assets/assets folder from the .APK!\nPlease copy the assets/assets folder from the .APK to\n" + SUtil.getStorageDirectory(),
					'Error!');
				LimeSystem.exit(1);
			}
			else if (FileSystem.exists(SUtil.getPath() + 'assets') && !FileSystem.isDirectory(SUtil.getPath() + 'assets'))
			{
				Lib.application.window.alert("Why did you create a file called assets instead of copying the assets directory from the .APK?, expect a crash.",
					'Error!');
				LimeSystem.exit(1);
			}

			if (!FileSystem.exists(SUtil.getPath() + 'mods'))
			{
				Lib.application.window.alert("Whoops, seems like you didn't extract the assets/mods folder from the .APK!\nPlease copy the assets/mods folder from the .APK to\n" + SUtil.getStorageDirectory(),
					'Error!');
				LimeSystem.exit(1);
			}
			else if (FileSystem.exists(SUtil.getPath() + 'mods') && !FileSystem.isDirectory(SUtil.getPath() + 'mods'))
			{
				Lib.application.window.alert("Why did you create a file called mods instead of copying the mods directory from the .APK?, expect a crash.",
					'Error!');
				LimeSystem.exit(1);
			}
		}
		#end
	}

	/**
	 * Uncaught error handler, original made by: Sqirra-RNG and YoshiCrafter29
	 */
	public static function gameCrashCheck():Void
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
		Lib.application.onExit.add(function(exitCode:Int)
		{
			if (Lib.current.loaderInfo.uncaughtErrorEvents.hasEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR))
				Lib.current.loaderInfo.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
		});
	}

	private static function onError(e:UncaughtErrorEvent):Void
	{
		var stack:Array<String> = [];
		stack.push(e.error);

		for (stackItem in CallStack.exceptionStack(true))
		{
			switch (stackItem)
			{
				case CFunction:
					stack.push('C Function');
				case Module(m):
					stack.push('Module ($m)');
				case FilePos(s, file, line, column):
					stack.push('$file (line $line)');
				case Method(classname, method):
					stack.push('$classname (method $method)');
				case LocalFunction(name):
					stack.push('Local Function ($name)');
			}
		}

		e.preventDefault();
		e.stopPropagation();
		e.stopImmediatePropagation();

		final msg:String = stack.join('\n');

		#if sys
		try
		{
			if (!FileSystem.exists(SUtil.getStorageDirectory() + 'logs'))
				FileSystem.createDirectory(SUtil.getStorageDirectory() + 'logs');

			File.saveContent(SUtil.getStorageDirectory()
				+ 'logs/'
				+ Lib.application.meta.get('file')
				+ '-'
				+ Date.now().toString().replace(' ', '-').replace(':', "'")
				+ '.txt',
				msg + '\n');
		}
		catch (e:Dynamic)
		{
			#if (android && debug)
			Toast.makeText("Error!\nClouldn't save the crash dump because:\n" + e, Toast.LENGTH_LONG);
			#else
			LimeLogger.println("Error!\nClouldn't save the crash dump because:\n" + e);
			#end
		}
		#end

		LimeLogger.println(msg);
		Lib.application.window.alert(msg, 'Error!');
		LimeSystem.exit(1);
	}

	/**
	 * This is mostly a fork of https://github.com/openfl/hxp/blob/master/src/hxp/System.hx#L595
	 */
	#if sys
	public static function mkDirs(directory:String):Void
	{
		var total:String = '';
		if (directory.substr(0, 1) == '/')
			total = '/';

		var parts:Array<String> = directory.split('/');
		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part != '')
			{
				if (total != '' && total != '/')
					total += '/';

				total += part;

				if (!FileSystem.exists(total))
					FileSystem.createDirectory(total);
			}
		}
	}

	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json',
			fileData:String = 'you forgot to add something in your code lol'):Void
	{
		try
		{
			if (!FileSystem.exists(SUtil.getStorageDirectory() + 'saves'))
				FileSystem.createDirectory(SUtil.getStorageDirectory() + 'saves');

			File.saveContent(SUtil.getStorageDirectory() + 'saves/' + fileName + fileExtension, fileData);
		}
		catch (e:Dynamic)
		{
			#if (android && debug)
			Toast.makeText("Error!\nClouldn't save the file because:\n" + e, Toast.LENGTH_LONG);
			#else
			LimeLogger.println("Error!\nClouldn't save the file because:\n" + e);
			#end
		}
	}

	/**
	 * Copies the content of copyPath and pastes it in savePath.
	 */
	public static function copyContent(copyPath:String, savePath:String):Void
	{
		try
		{
			if (!FileSystem.exists(savePath) && LimeAssets.exists(copyPath))
			{
				if (!FileSystem.exists(Path.directory(savePath)))
					SUtil.mkDirs(Path.directory(savePath));

				File.saveBytes(savePath, LimeAssets.getBytes(copyPath));
			}
		}
		catch (e:Dynamic)
		{
			#if (android && debug)
			Toast.makeText('Error!\nClouldn\'t copy the $copyPath because:\n' + e, Toast.LENGTH_LONG);
			#else
			LimeLogger.println('Error!\nClouldn\'t copy the $copyPath because:\n' + e);
			#end
		}
	}
	#end
}
