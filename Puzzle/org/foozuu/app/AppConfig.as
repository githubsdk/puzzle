package foozuu.app
{
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	
	import foozuu.utils.FileUtils;

	public class AppConfig
	{
		protected var _app:NativeApplication;
		protected var _compress:Boolean;
		protected var _appData:Object;
		
		public function AppConfig()
		{
		}
		
		public function initData(app:NativeApplication, compress:Boolean=false):void
		{
			if(app==null)
				return;
			_app = app;
			_compress = compress;
			var file:File = File.applicationDirectory;
			_appData = FileUtils.ins.readBinary(file.nativePath+"/config/config.json", _compress);
			trace(_appData);
		}
		
		public function getData(key:String, toJson:Boolean=false):*
		{
			if(_appData==null)
				return null;
			if(toJson==true && _appData[key]!=null)
			{
				try
				{
					return JSON.parse(_appData[key]);
				} 
				catch(error:Error) 
				{
					return null;
				}
			}
			return _appData[key];
		}
		
		public function get appVersion():String
		{
			var ver:* = null;
			if(_app!=null)
			{
				default xml namespace= _app.applicationDescriptor.namespace();
				ver =_app.applicationDescriptor.versionNumber
			};
			return ver;
		}
	}
}