import en.Character;
import en.ECharacter;

class GameOne extends Game {

	public static var savData : GameSave = new GameSave();

	public override function get_sav() : GameSave {
		return savData;
	}

	var death : en.Death;
	var ghostSpr : HSprite;
	var targetData : Data.Characters;
	var targetAttrs : Array<en.EAttribute>;
	public var note : Int;
	
	public function new() {
		name = 'GameOne';
		super();

		death = new en.Death();
		ghostSpr = new HSprite(Assets.entities, 'Ghost');
		ghostSpr.y = -300;
		ghostSpr.x = -50;

		note = 0;

		startLevel(1);
	}

	public static function load() {		
		savData = hxd.Save.load(savData, 'save/GameOne');
	}

	override function startLevel(levelUID:Int) {
		super.startLevel(levelUID);

		final nbPeople = 3;
		
		var targets = new Array<Array<en.EAttribute>>();
		targets.resize(nbPeople);
		for (i in 0...targets.length)
			targets[i] = new Array<en.EAttribute>();
		
		// -- Death
		level.root.add(death, Const.GAME_LEVEL_ENTITIES);
		death.y = level.pxHei * 1.05 - death.getSize().height;

		// -- Pick characters
		var allChars = Data.characters.all.toArrayCopy();
		var chosenChars = new Array<Data.Characters>();
		for (i in 0...nbPeople) {
			var n = M.randRange(0, allChars.length - 1);
			var char = allChars[n];
			allChars.remove(char);
			chosenChars.push(char);
		}

		var x = level.pxWid * .34;
		var offset = level.pxWid * .24;
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

		// -- Mission
		var links = new Array<Array<Int>>();
		for (i in 0...chosenChars.length) {
			var others = new Array<Int>();
			links.push(others);
			for (j in 0...chosenChars.length)
				others[j] = 0;
		}

		for (i in 0...chosenChars.length) {
			for (j in i + 1...chosenChars.length) {
				if (chosenChars[i].hairColor == chosenChars[j].hairColor) {
					targets[i].push(HairColor);
					targets[j].push(HairColor);
					links[i][j]++;
					links[j][i]++;
				}
				if (chosenChars[i].trouser == chosenChars[j].trouser) {
					targets[i].push(Trouser);
					targets[j].push(Trouser);
					links[i][j]++;
					links[j][i]++;
				}
				if (chosenChars[i].eyesClosed == chosenChars[j].eyesClosed) {
					targets[i].push(EyesClosed);
					targets[j].push(EyesClosed);
					links[i][j]++;
					links[j][i]++;
				}
			}
		}

		// Target must have at least 2 clues
		var higherClues = 2;
		var nbTargets = 0;
		for (i in 0...targets.length) {
			var clues = targets[i];
			if (clues.length >= higherClues) {
				if (higherClues < clues.length) {
					nbTargets = 1;
					higherClues = clues.length;
				} else
					nbTargets++;
			}
		}

		// Pick the target among the ones with the highest # of clues
		var target = M.randRange(0, nbTargets - 1);
		for (i in 0...targets.length) {
			var clues = targets[i];
			if (clues.length == higherClues){
				if (target == 0) {
					target = i;
					break;
				}
				target--;
			}
		}

		// -- Cats
		var cats = new Array<Int>();
		for (i in 0...3) 
			cats[i] = i;

		if (nbTargets > 1) {
			// If too many potential targets, remove cat from the one with the more links with the target
			var higherLinks = 0;
			for (i in 0...M.imin(cats.length, targets.length)) {
				var nbLinks = links[target][i];
				if (higherLinks < nbLinks) {
					higherLinks = nbLinks;
				}
			}
			for (i in 0...M.imin(cats.length, targets.length)) {
				var nbLinks = links[target][i];
				if (higherLinks == nbLinks) {
					cats.remove(cats[i]);
				}
			}
		} else if (targets[target].length < 3) {
			// The cat is one more clue to give to the target
			var removedCat = M.randRange(0, cats.length - 2);
			if (removedCat >= target) removedCat++;
			cats.remove(cats[removedCat]);
		} else {
			var removedCat = M.randRange(0, cats.length - 1);
			cats.remove(cats[removedCat]);
		}

		@:privateAccess(Level)
		for (c in cats) {
			targets[c].push(Cat);

			var catBg = Assets.levels.getBitmap('Background${levelUID}_Cat${c + 1}');
			level.root.add(catBg, Const.GAME_LEVEL_BG);
		}

		// -- Save the target's attrs list
		targetAttrs = targets[target];
		targetData = chosenChars[target];
	}

	public function characterKilled(char : Character) {
		locked = true;

		if (char.data == targetData)
			note++;
			
		char.isDead = true;
		ghostSpr.anim.play('Ghost').setSpeed(3 / Const.FPS).onEnd(() -> {
			ghostSpr.setFrame(0);
			ghostSpr.remove();
		});
		char.addChild(ghostSpr);

		cd.setS('NewLevel', ghostSpr.anim.getDurationS(Const.FPS) + .1, () -> {
			startLevel(1);
		});
	}
}