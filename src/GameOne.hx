class GameOne extends Game {

	public static var savData : GameSave = new GameSave();

	public override function get_sav() : GameSave {
		return savData;
	}
	
	public function new() {
		super();
		name = 'gameOne';
	}

	public static function load() {		
		savData = hxd.Save.load(savData, 'save/gameOne');
	}
}