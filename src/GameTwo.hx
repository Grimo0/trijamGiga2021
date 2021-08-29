class GameTwo extends Game {

	public static var savData : GameSave = new GameSave();

	public static function get_sav() : GameSave {
		return savData;
	}

	public function new() {
		super();
	}

	public static function load() {		
		savData = hxd.Save.load(savData, 'save/game');
	}
}