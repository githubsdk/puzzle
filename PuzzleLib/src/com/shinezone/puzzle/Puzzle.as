package com.shinezone.puzzle
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BevelFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;

	public class Puzzle
	{
		/**
		 * Private members
		 */
		//////////加载图片长宽///////////
		private var _imageW:Number;
		private var _imageH:Number;
		//////////设置最大宽高///////////
		private var _imageMaxW:Number = 800;
		private var _imageMaxH:Number = 500;
		////////////////////////////////
		////////////////////////////////
		private var _oldURL:String;
		private var _x:Number;
		private var _y:Number;
		private var _row:Number;
		private var _line:Number;
		private var _pieceBoard:MovieClip;
		private var _imageLoader:Loader;
		private var _imageBitmap:BitmapData;
		private var _pieceW:Number;
		private var _pieceH:Number;
		private var _pieceMinWH:Number;
		private var _pieceD:Number;
		///////////内切矩形宽高(通过矩形画近似椭圆)///////////
		private var _pieceOW:Number;
		private var _pieceOH:Number;
		///////////////比例系数///////////////
		private var _pieceD_k:Number = 10;
		private var _pieceO_k:Number = 4;
		private var _pieceOWH_k:Number = 3/4;
		
		private var _container:DisplayObjectContainer;
		private var _source:Object;
		
		private const START:Number = 20;
		/////////////////////////////////
		/**
		 * Constructor
		 */
		public function Puzzle(container:DisplayObjectContainer, source:Object) {
			_container = container;
			_source = source;
			loadImage(_source);
		}

		public function get pieceH():Number
		{
			return _pieceH;
		}

		public function get pieceW():Number
		{
			return _pieceW;
		}

		public function get chips():Array
		{
			return _chips;
		}

		/**
		 * Public methods
		 */
		public function set _url(url:String):void {
			loadImage(url);
		}
		public function get _url():String {
			return _oldURL;
		}
		public function set row(r:Number):void {
			_row = r;
		}
		public function set line(l:Number):void {
			_line = l;
		}
		public function removeAllPiece():void {
			for (var all:Object in _pieceBoard) {
				_pieceBoard[all].removeMovieClip();
			}
		}
		private var _chips:Array;
		public function bitmapCut() :void{
			pieceSet();
			removeAllPiece();
			_chips ||= new Array();
			_chips.length = 0;
			var index:int = 0;
			for (var i:Number = 0; i<_row; i++) {
				for (var j:Number = 0; j<_line; j++) {
					//var chip:Chip = new Chip(_imageBitmap, i, j, _pieceW, _pieceH);
					var chip:Chip = new Chip();
					_chips[_line*i+j] = chip;
					chip.name = index.toString();
					index++;
					//if(j%2==0)
					var scale:Number = 1;
						chip.graphics.beginBitmapFill(_imageBitmap, new Matrix(scale, 0, 0, scale, -j*_pieceW, -i*_pieceH), true, true);
					/*else
					{
						if(i%2==0)
							chip.graphics.beginFill(0xff00ff);
						else
							chip.graphics.beginFill(0xff0000);
					}*/
					//chip.graphics.drawRect(0, 0, _pieceW, _pieceH);
					chip.x = START + j*_pieceW;
					chip.y = START + i*_pieceH;
					drawPiece(chip, getAllDotArray(chip, i, j, _line*i+j));
					chip.filters = [new BevelFilter(3, 30)];
					_container.addChild(chip);
					var rect:Rectangle = chip.getBounds(chip);
					trace(chip.name + "_" + _pieceW + "_" + _pieceH + "_" + rect.toString());
				}
			}
		}
		public function setMaxWH(w:Number, h:Number) :void{
			//设置允许的最大宽高
			_imageMaxW = w;
			_imageMaxH = h;
		}
		public function setRowAndLine(row:Number, line:Number):void {
			//设置切割的 行/列
			if (row<=0 || line<=0) {
				trace("行/列不能为0,按默认10*10进行切图");
				return;
			}
			if (row*line>900) {
				trace("数量太大,运算困难,按默认10*10进行切图");
				return;
			}
			_row = row;
			_line = line;
		}
		public function setPosition(x:Number, y:Number):void {
			//设置
			if (x<0 || y<0) {
				trace("超出场景范围,按默认(0,0)位置进行摆放");
				return;
			}
			_x = x;
			_y = y;
			if (_pieceBoard!=null) {
				_pieceBoard.x = _x;
				_pieceBoard.y = _y;
			}
		}
		public function getPieceBoard():MovieClip {
			//取得碎片载体
			return _pieceBoard;
		}
		public function toString():String {
			return "Puzzle::凹凸形状的拼图切割";
		}
		/**
		 * Private methods
		 */
		private function loadImage(source:Object):void {
			try {
				if(source is String)
				{
					_imageLoader ||= new Loader();
					_imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
					_imageLoader.load(new URLRequest(String(source)));
				}else if(source is DisplayObject){
					onLoadInit(DisplayObject(source));
				}
			} catch (e:Error) {
				trace(e);
			}
		}
		
		private function onComplete(e:Event):void
		{
			_imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			onLoadInit(_imageLoader);
		}
		
		private function onLoadInit(target:DisplayObject):void {
			if (target.width<10 || target.height<10) {
				throw new Error("图片太小,不适合切割!");
			}
			if (isNaN(_imageMaxW+_imageMaxH)) {
				_imageMaxW = _imageMaxH=600;
			}
			if (isNaN(_row+_line)) {
				_row = 4;
				_line = 4;
			}
			_imageW = target.width>_imageMaxW ? _imageMaxW : target.width;
			_imageH = target.height>_imageMaxH ? _imageMaxH : target.height;
			mcToBitmap(target);
		}
		private function mcToBitmap(mc:DisplayObject):void {
			_imageBitmap = new BitmapData(_imageW, _imageH);
			var scale:Number = 1;
			_imageBitmap.draw(mc, new Matrix(scale, 0, 0, scale));
			
			var bmp:Bitmap = new Bitmap(_imageBitmap);
			bmp.x = bmp.width+START*2;
			bmp.y = START;
			_container.addChild(bmp);
			//隐藏掉
			_pieceBoard = new MovieClip();
			_pieceBoard.x = _x;
			_pieceBoard.y = _y;
			bitmapCut();
		}
		private function pieceSet():void {
			_pieceW = _imageW/_line;
			_pieceH = _imageH/_row;
			_pieceMinWH = Math.min(_pieceW, _pieceH);
			_pieceD = _pieceMinWH/_pieceD_k;
			_pieceOW = _pieceMinWH/_pieceO_k;
			_pieceOH = _pieceOW/_pieceOWH_k;
		}
		private function getRndD():Number {
			//返回与边界错开的高度
			return _pieceD-Math.random()*2*_pieceD;
		}
		private function drawPiece(mc:Sprite, dotArr:Array):void {
			mc.graphics.lineStyle(0);
			mc.graphics.moveTo(0, 0);
			for (var k:Number = 0; k<dotArr.length; k++) {
				if (dotArr[k] is Point) {
					mc.graphics.lineTo(dotArr[k].x, dotArr[k].y);
				} else {
					mc.graphics.curveTo(dotArr[k][0].x, dotArr[k][0].y, dotArr[k][1].x, dotArr[k][1].y);
				}
			}
			mc.graphics.endFill();
		}
		private function getOvalDotArray(mc:Sprite, position:String):Array {
			var rnd:Number = Math.random()>0.5 ? 1 : -1;
			var circleDotArr:Array = [];
			switch (position) {
				case "right" :
					var a0:Point = new Point(_pieceW+getRndD(), (_pieceH-_pieceOW)/2+_pieceOW/4-Math.random()*_pieceOW/2);
					var a1:Array = [new Point(a0.x+rnd*(_pieceOH/2), a0.y-_pieceOW/2), new Point(a0.x+rnd*_pieceOH, a0.y)];
					var a2:Array = [new Point(a0.x+rnd*(_pieceOH+_pieceOW/3), a0.y+_pieceOW/2), new Point(a0.x+rnd*_pieceOH, a0.y+_pieceOW)];
					var a3:Array = [new Point(a0.x+rnd*_pieceOH/2, a0.y+_pieceOW+_pieceOW/2), new Point(a0.x, a0.y+_pieceOW)];
					circleDotArr = [a0, a1, a2, a3];
					break;
				case "down" :
					a0 = new Point(_pieceW-((_pieceW-_pieceOW)/2+_pieceOW/4-Math.random()*_pieceOW/2), _pieceH+getRndD());
					a1 = [new Point(a0.x+_pieceOW/2, a0.y+rnd*(_pieceOH/2)), new Point(a0.x, a0.y+rnd*_pieceOH)];
					a2 = [new Point(a0.x-_pieceOW/2, a0.y+rnd*(_pieceOH+_pieceOW/3)), new Point(a0.x-_pieceOW, a0.y+rnd*_pieceOH)];
					a3 = [new Point(a0.x-_pieceOW-_pieceOW/2, a0.y+rnd*_pieceOH/2), new Point(a0.x-_pieceOW, a0.y)];
					circleDotArr = [a0, a1, a2, a3];
					break;
			}
			return circleDotArr;
		}
		private function getAllDotArray(mc:Chip, i:int, j:int, key:int):Array {
			var allDotArray:Array = [];
			//a,b,c,d四面
			if (i == 0) {
			} else {
				var tempArray:Array = _chips[key -_line].c;
				mc.a[0] = new Point(tempArray[3][1].x, tempArray[3][1].y-_pieceH);
				mc.a[1] = [new Point(tempArray[3][0].x, tempArray[3][0].y-_pieceH), new Point(tempArray[2][1].x, tempArray[2][1].y-_pieceH)];
				mc.a[2] = [new Point(tempArray[2][0].x, tempArray[2][0].y-_pieceH), new Point(tempArray[1][1].x, tempArray[1][1].y-_pieceH)];
				mc.a[3] = [new Point(tempArray[1][0].x, tempArray[1][0].y-_pieceH), new Point(tempArray[0].x, tempArray[0].y-_pieceH)];
			}
			if (j == 0) {
				
			} else {
				tempArray = _chips[key-1].b;
				mc.d[0] = new Point(tempArray[3][1].x-_pieceW, tempArray[3][1].y);
				mc.d[1] = [new Point(tempArray[3][0].x-_pieceW, tempArray[3][0].y), new Point(tempArray[2][1].x-_pieceW, tempArray[2][1].y)];
				mc.d[2] = [new Point(tempArray[2][0].x-_pieceW, tempArray[2][0].y), new Point(tempArray[1][1].x-_pieceW, tempArray[1][1].y)];
				mc.d[3] = [new Point(tempArray[1][0].x-_pieceW, tempArray[1][0].y), new Point(tempArray[0].x-_pieceW, tempArray[0].y)];
			}
			if (i == _row-1) {
				
			} else {
				mc.c = getOvalDotArray(mc, "down");
			}
			if (j == _line-1) {
				
			} else {
				mc.b = getOvalDotArray(mc, "right");
			}
			allDotArray = allDotArray.concat(mc.a);
			allDotArray.push(new Point(_pieceW, 0));
			allDotArray = allDotArray.concat(mc.b);
			allDotArray.push(new Point(_pieceW, _pieceH));
			allDotArray = allDotArray.concat(mc.c);
			allDotArray.push(new Point(0, _pieceH));
			allDotArray = allDotArray.concat(mc.d);
			return allDotArray;
		}
	}
}