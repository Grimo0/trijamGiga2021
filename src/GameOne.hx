import en.Character;
import en.ECharacter;

class GameOne extends Game {

	public static var savData : GameSave = new GameSave();

	public override function get_sav() : GameSave {
		return savData;
	}

	var death : en.Death;
	
	public function new() {
		name = 'GameOne';
		super();

		death = new en.Death();
		startLevel(1);
	}

	public static function load() {		
		savData = hxd.Save.load(savData, 'save/GameOne');
	}

	override function startLevel(levelUID:Int) {
		super.startLevel(levelUID);

		level.root.add(death, Const.GAME_LEVEL_ENTITIES);
		death.y = level.pxHei * 1.05 - death.getSize().height;

		var allChars = ECharacter.createAll();
		var chosenChars = new Array<ECharacter>();
		for (i in 0...3) {
			var n = M.randRange(0, allChars.length - 1);
			var char = allChars[n];
			allChars.remove(char);
			chosenChars.push(char);
		}

		var x = level.pxWid * .35;
		var offset = level.pxWid * .2;
		for (character in chosenChars) {
			var char = new Character(character);
			char.x = x;
			char.y = level.pxHei - char.getSize().yMax;
			x += offset;
			level.root.add(char, Const.GAME_LEVEL_ENTITIES);
		}
	}
}