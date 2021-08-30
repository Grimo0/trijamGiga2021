class GameTwo extends Game {

	public static var savData : GameSave = new GameSave();

	public override function get_sav() : GameSave {
		return savData;
	}

	public var hud : ui.HudTwo;

	public function new() {
		name = 'GameTwo';
		super();
		
		hud = new ui.HudTwo();
		
		startLevel(2);
	}

	public static function load() {		
		savData = hxd.Save.load(savData, 'save/GameTwo');
	}
}