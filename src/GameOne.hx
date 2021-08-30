import en.Character;
import en.ECharacter;

class GameOne extends Game {

	public static var savData : GameSave = new GameSave();

	public override function get_sav() : GameSave {
		return savData;
	}

	var death : en.Death;
	var ghostSpr : HSprite;
	
	public function new() {
		name = 'GameOne';
		super();

		death = new en.Death();
		ghostSpr = new HSprite(Assets.entities, 'Ghost');
		ghostSpr.y = -300;
		startLevel(1);
	}

	public static function load() {		
		savData = hxd.Save.load(savData, 'save/GameOne');
	}

	override function startLevel(levelUID:Int) {
		super.startLevel(levelUID);

		// -- Pick characters
		var allChars = Data.characters.all.toArrayCopy();
		var chosenChars = new Array<Data.Characters>();
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
			char.onClick = (e : hxd.Event) -> {
				char.filter.enable = false;
				death.kill(char);
			};
			char.x = x;
			char.y = level.pxHei - char.getSize().yMax;
			x += offset;
			level.root.add(char, Const.GAME_LEVEL_ENTITIES);
		}
		
		// -- Death
		level.root.add(death, Const.GAME_LEVEL_ENTITIES);
		death.y = level.pxHei * 1.05 - death.getSize().height;
	}

	public function characterKilled(char : Character) {
		locked = true;
			
		char.isDead = true;
		ghostSpr.anim.play('Ghost').setSpeed(3 / Const.FPS).onEnd(() -> {
			ghostSpr.setFrame(0);
			ghostSpr.remove();
		});
		char.addChild(ghostSpr);

		cd.setS('CharacterKilled', ghostSpr.anim.getDurationS(Const.FPS) + .1, () -> {
			startLevel(1);
		});
	}
}