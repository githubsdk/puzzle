package foozuu.app
{
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	
	import foozuu.utils.FileUtils;

	public class AppData extends AppConfig
	{
		static private var _ins:AppData = new AppData();
		
		static private const EXTENSION:String = ".fad";
		
		public function AppData()
		{
		}
		
		override public function initData(app:NativeApplication, compress:Boolean=false):void
		{
			if(app==null)
				return;
			_app = app;
			_compress = compress;
			var file:File = File.applicationStorageDirectory;
			_appData = FileUtils.ins.readBinary(file.nativePath+"/"+_app.applicationID+EXTENSION, _compress);
			var version:String = getData("version");
			if(version==null || version!=appVersion)
			{
				//重置app数据
				_appData = new Object();
				saveData("version",appVersion);
			}
		}
		
		public function saveData(key:String, value:*, bImmediately:Boolean=true):void
		{
			if(_appData==null)
				_appData = new Object();
			if(value==null)
				delete _appData[key];
			else
				_appData[key] = value;
			
			var file:File = File.applicationStorageDirectory;
			FileUtils.ins.saveBinary(file.nativePath+"/"+_app.applicationID+EXTENSION, JSON.stringify(_appData), _compress);
		}
		
		public function appName(addVersion:Boolean=false):String
		{
			if(_app!=null)
			{
				if(addVersion==false)
					return _app.applicationID;
				return _app.applicationID + appVersion;
			}
			return null;
		}
	}
}