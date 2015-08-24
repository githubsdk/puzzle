package foozuu.app
{
	public class App
	{
		static private var _ins:App = new App();
		private var _appData:AppData;
		private var _appConfig:AppConfig;
		public function App()
		{
		}

		public static function get ins():App
		{
			return _ins;
		}

		public function get appConfig():AppConfig
		{
			return _appConfig;
		}

		public function set appConfig(value:AppConfig):void
		{
			_appConfig = value;
		}

		public function get appData():AppData
		{
			return _appData;
		}

		public function set appData(value:AppData):void
		{
			_appData = value;
		}

	}
}