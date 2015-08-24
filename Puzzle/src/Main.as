package
{
	import com.shinezone.puzzle.Chip;
	import com.shinezone.puzzle.Puzzle;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.utils.ByteArray;
	
	import foozuu.app.App;
	import foozuu.app.AppConfig;
	import foozuu.app.AppData;
	
	import images.PNGEncoder;
	
	public class Main extends Sprite
	{
		private var _file:File;
		private var _controls:Controls;
		public function Main()
		{
			App.ins.appData = new AppData();
			App.ins.appData.initData(NativeApplication.nativeApplication);
			App.ins.appConfig = new AppConfig();
			App.ins.appConfig.initData(NativeApplication.nativeApplication);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.color = 0x339966;
			_controls = new Controls();
			addChild(_controls);
			_controls.input.type = TextFieldType.INPUT;
			var value:String = App.ins.appData.getData("rows");
			if(value==null)
			{
				value = App.ins.appConfig.getData("rows");
				//App.ins.appData.saveData("rows", value);
			}
			_controls.rows.text = value;
			value = App.ins.appData.getData("cols");
			
			_controls.help.htmlText = App.ins.appConfig.getData("help");
			if(value==null)
			{
				value = App.ins.appConfig.getData("cols");
				//App.ins.appData.saveData("cols", value);
			}
			_controls.cols.text = value;
			//_controls.input.restrict = "0-9";
			_controls.importpic.addEventListener(MouseEvent.CLICK, onMouseHandler);
			_controls.appdir.addEventListener(MouseEvent.CLICK, onMouseHandler);
		}
		
		protected function onMouseHandler(e:MouseEvent):void
		{
			switch(e.currentTarget)
			{
				case _controls.importpic:
				{
					App.ins.appData.saveData("cols", _controls.cols.text);
					App.ins.appData.saveData("rows", _controls.rows.text);
					_file = new File();
					_file.browseForOpen("打开要转换的 文件", [new FileFilter("*.swf","*.swf")]);
					_file.addEventListener(Event.SELECT, onSelected);
					break;
				}
					
				case _controls.appdir:
				{
					File.applicationDirectory.openWithDefaultApplication();
					break;
				}
			}
		}
		
		
		private var _loader:Loader;
		protected function onSelected(e:Event):void
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.load(new URLRequest(_file.url));
		}
		
		protected function onComplete(e:Event):void
		{
			var jsfl_file_path:String = "export/puzzle_export.jsfl";
			var jsfl_path:String = "export";
			var open_path:String = File.documentsDirectory.resolvePath(App.ins.appData.appName(true)).resolvePath(jsfl_file_path).nativePath;
			var jsfl:File = new File(open_path);
			var dest_path:File = File.documentsDirectory.resolvePath(App.ins.appData.appName(true)).resolvePath(jsfl_path);
			
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			var cls:Class = _loader.contentLoaderInfo.applicationDomain.getDefinition("Templete") as Class;
			var puzzle:Puzzle = new Puzzle(this, new cls(), 1, uint(_controls.rows.text), uint(_controls.cols.text) );
			var path:String = _file.url;
			var patharray:Array = path.split("/");
			patharray.pop();
			path = patharray.join("/");
			var content:String = "";
			var fs:FileStream = new FileStream();
			var scale:Number = 1;
			var content_data:Object = new Object();
			for each(var chip:Chip in puzzle.chips)
			{
				var bmp:Bitmap = new Bitmap();
				bmp.bitmapData = new BitmapData(chip.width * scale, chip.height * scale, true, 0x00000000);
				var rect:Rectangle = chip.getBounds(chip);
				bmp.bitmapData.draw(chip, new Matrix(scale,0,0,scale,-rect.x*scale, -rect.y*scale));
				var ba:ByteArray = PNGEncoder.encode(bmp.bitmapData);
				var id:int = int(_controls.input.text) + int(chip.name);
				var fp:String = path+"/"+ id +".png";
				var fl:File = new File(fp);
				fs.open(fl, FileMode.WRITE);
				fs.writeBytes(ba);
				fs.close();
				//content = content + id + ","+(rect.x * scale) + "," + (rect.y * scale) + "|";
				content_data[id] = {id:id, x:rect.x * scale, y:rect.y * scale};
				var text:TextField = new TextField();
				text.width = 50;
				text.autoSize = TextFieldAutoSize.RIGHT;
				text.text = id.toString();
				/*text.x = chip.width/2;
				text.y = chip.height/2;*/
				text.filters = [new GlowFilter(0xff00ff)];
				chip.addChild(text);
			}
			
			var save_data:Object = {};
			save_data["pos"] = content_data;
			save_data["size"] = {width:puzzle.pieceW*scale, height:puzzle.pieceH*scale};
			save_data["folder"] = path;
			content = JSON.stringify(save_data, null, 8);
			
			var info:File = File.documentsDirectory.resolvePath(App.ins.appData.appName(true)).resolvePath("info.json");
			
			fs.open(info, FileMode.WRITE);
			
			fs.writeMultiByte(content,"utf-8");
			fs.close();
			
			var all:File = new File(path+"/sampler.png");
			bmp = new Bitmap();
			bmp.bitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000);
			bmp.bitmapData.draw(this);
			ba = PNGEncoder.encode(bmp.bitmapData);
			fs.open(all, FileMode.WRITE);
			fs.writeBytes(ba);
			fs.close();
			
			//var jsfl:String = File.applicationDirectory.nativePath + "\\export\\puzzle_export.jsfl";
		//	var jsfl:File = File.applicationDirectory.resolvePath("export/puzzle_export.jsfl");
			//jsfl.openWithDefaultApplication();
			
			
			if(dest_path.exists==false)
			{
				var file:File = File.applicationDirectory.resolvePath(jsfl_path);
				file.copyTo(dest_path, true);
			}
			jsfl.openWithDefaultApplication();
		}
	}
}