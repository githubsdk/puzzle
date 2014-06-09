package com.shinezone.puzzle
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	public class Chip extends MovieClip
	{
		private var _a:Array;
		private var _b:Array;
		private var _c:Array;
		private var _d:Array;
		
		private var _bmp:Bitmap;
		public function Chip(source:BitmapData=null, i:int=0, j:int=0, w:Number=0, h:Number=0)
		{
			super();
			_a = new Array();
			_b = new Array();
			_c = new Array();
			_d = new Array();
			if(source!=null)
			{
				_bmp = new Bitmap();
				_bmp.bitmapData = new BitmapData(w, h);
				_bmp.bitmapData.draw(source, new Matrix(1, 0, 0, 1, -j*w, -i*h), null, null, null, true);
				addChild(_bmp);
			}
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseHanler);
			addEventListener(MouseEvent.MOUSE_UP, onMouseHanler);
		}
		
		protected function onMouseHanler(e:MouseEvent):void
		{
			switch(e.type)
			{
				case MouseEvent.MOUSE_DOWN:
				{
					this.startDrag();
					break;
				}
					
				case MouseEvent.MOUSE_UP:
				{
					this.stopDrag();
					break;
				}
			}
		}
		
		public function get d():Array
		{
			return _d;
		}

		public function set d(value:Array):void
		{
			_d = value;
		}

		public function get c():Array
		{
			return _c;
		}

		public function set c(value:Array):void
		{
			_c = value;
		}

		public function get b():Array
		{
			return _b;
		}

		public function set b(value:Array):void
		{
			_b = value;
		}

		public function get a():Array
		{
			return _a;
		}

		public function set a(value:Array):void
		{
			_a = value;
		}

	}
}