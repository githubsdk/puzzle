package
{
	import com.shinezone.puzzle.Puzzle;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	public class Main extends Sprite
	{
		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.color = 0xff0000ff;
			var puzzle:Puzzle = new Puzzle(this, "1.png");
		}
	}
}