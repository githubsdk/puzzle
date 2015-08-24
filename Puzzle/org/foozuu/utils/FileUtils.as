package foozuu.utils
{
	
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class FileUtils
	{
		private var _file:File;
		private var _fileStream:FileStream;
		private var _func:Function;
		private var _fileArray:Array;
		
		static private var _ins:FileUtils = new FileUtils();;
		
		public function FileUtils()
		{
			_fileStream = new FileStream();
		}
		
		public static function get ins():FileUtils
		{
			return _ins;
		}
		
		public function openAndSelect(title:String, typeFilter:Array, func:Function=null, file:File=null, openDirectory:Boolean=false):void
		{
			_file = file;
			_file ||= File.desktopDirectory;
			if(openDirectory==true)
				_file.browseForDirectory(title);
			else
				_file.browseForOpenMultiple(title, typeFilter);
			_func = func;
			if(_func!=null)
			{
				_file.addEventListener(Event.SELECT, fileSelectFunc);
				_file.addEventListener(FileListEvent.SELECT_MULTIPLE, fileSelectFunc);
				_file.addEventListener(Event.CANCEL, fileSelectFunc);
			}
		}
		
		private function fileSelectFunc(e:Event):void
		{
			_file.removeEventListener(FileListEvent.SELECT_MULTIPLE, fileSelectFunc);
			_file.removeEventListener(Event.CANCEL, fileSelectFunc);
			_file.removeEventListener(Event.SELECT, fileSelectFunc);
			if(_func!=null)
				_func(e.type, e.type==Event.CANCEL? null : ( ( e is FileListEvent)==true ? FileListEvent(e).files : e.target) );
		}
		
		public function saveBinary(fileOrPath:*, value:*, compress:Boolean=false):void
		{
			if(fileOrPath is File)
			{
				_fileStream.open(fileOrPath, FileMode.WRITE);
			}else if(fileOrPath is String)
			{
				_fileStream.open(new File(fileOrPath), FileMode.WRITE);
			}else
				return;
			var content:ByteArray = new ByteArray();
			content.writeUTFBytes(value);
			if(compress==true)
				content.compress();
			_fileStream.writeBytes(content);
			content.clear();
			content = null;
			_fileStream.close();
		}
		
		/**
		 *读取Json格式二进文本并尝试转换到Object 
		 * @param fileOrPath File对象或者文件路径
		 * @param uncompress 是否需要解压缩
		 * @param textMode 返回文本结果而不转换成Object
		 * @return 
		 * 
		 */		
		public function readBinary(fileOrPath:*, uncompress:Boolean=true, textMode:Boolean=false):*
		{
			if(fileOrPath!=null)
			{
				try
				{
					if(fileOrPath is File)
					{
						_fileStream.open(fileOrPath, FileMode.READ);
					}else if(fileOrPath is String)
					{
						_fileStream.open(new File(fileOrPath), FileMode.READ);
					}
					_fileStream.position = 0;
					var content:ByteArray = new ByteArray();
					_fileStream.readBytes(content);
					_fileStream.close();
					if(uncompress==true)
						content.uncompress();
					if(textMode==false)
					{
						var obj:Object = JSON.parse(content.toString());
						content.clear();
						content = null;
						return obj;
					}else{
						return content.toString();
					}
				} 
				catch(error:Error) 
				{
					
				}
			}
			return null;
		}
		
	}
}