package
{
	import com.adobe.images.PNGEncoder;
	import com.shinezone.puzzle.Chip;
	import com.shinezone.puzzle.Puzzle;
	
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
	
	public class Main extends Sprite
	{
		private var _file:File;
		private var _controls:Controls;
		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.color = 0x339966;
			_controls = new Controls();
			addChild(_controls);
			_controls.input.type = TextFieldType.INPUT;
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
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			var cls:Class = _loader.contentLoaderInfo.applicationDomain.getDefinition("Templete") as Class;
			var puzzle:Puzzle = new Puzzle(this, new cls(), 1);
			var path:String = _file.nativePath;
			var patharray:Array = path.split("\\");
			patharray.pop();
			path = patharray.join("\\");
			var info:File = new File(path+"\\info.txt");
			var content:String = "";
			var fs:FileStream = new FileStream();
			var scale:Number = 1;
			for each(var chip:Chip in puzzle.chips)
			{
				var bmp:Bitmap = new Bitmap();
				bmp.bitmapData = new BitmapData(chip.width * scale, chip.height * scale, true, 0x00000000);
				var rect:Rectangle = chip.getBounds(chip);
				bmp.bitmapData.draw(chip, new Matrix(scale,0,0,scale,-rect.x*scale, -rect.y*scale));
				var ba:ByteArray = PNGEncoder.encode(bmp.bitmapData);
				var id:int = int(_controls.input.text) + int(chip.name);
				var fp:String = path+"\\"+ id +".png";
				var fl:File = new File(fp);
				fs.open(fl, FileMode.WRITE);
				fs.writeBytes(ba);
				fs.close();
				content = content + id + ","+(rect.x * scale) + "," + (rect.y * scale) + "|";
				var text:TextField = new TextField();
				text.width = 50;
				text.autoSize = TextFieldAutoSize.RIGHT;
				text.text = id.toString();
				/*text.x = chip.width/2;
				text.y = chip.height/2;*/
				text.filters = [new GlowFilter(0xff00ff)];
				chip.addChild(text);
			}
			content = content.substr(0,content.length-1);
			fs.open(info, FileMode.WRITE);
			content = content + ";"+(puzzle.pieceW*scale)+","+(puzzle.pieceH*scale);
			fs.writeMultiByte(content,"utf-8");
			fs.close();
			
			var all:File = new File(path+"\\sampler.png");
			bmp = new Bitmap();
			bmp.bitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000);
			bmp.bitmapData.draw(this);
			ba = PNGEncoder.encode(bmp.bitmapData);
			fs.open(all, FileMode.WRITE);
			fs.writeBytes(ba);
			fs.close();
			
			//var jsfl:String = File.applicationDirectory.nativePath + "\\export\\puzzle_export.jsfl";
			var jsfl:File = File.applicationDirectory.resolvePath("export\\puzzle_export.jsfl");
			jsfl.openWithDefaultApplication();
		}
	}
}