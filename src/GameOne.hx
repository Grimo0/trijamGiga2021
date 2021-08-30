import en.EAttribute;
import en.Character;

class GameOne extends Game {

	public static var savData : GameSave = new GameSave();

	public override function get_sav() : GameSave {
		return savData;
	}

	public var hud : ui.HudOne;

	var death : en.gameOne.Death;
	var ghostSpr : HSprite;
	public var targetHasCat(default, null) : Bool;
	public var targetData(default, null) : Data.Characters;
	public var targetAttrs(default, null) : Array<Bool>;
	public var score(default, set) : Int;
	public function set_score(s : Int) {
		score = s;
		hud.scoreUpdated();
		return score;
	}
	
	public function new() {
		name = 'GameOne';
		super();
		
		hud = new ui.HudOne();

		death = new en.gameOne.Death();
		ghostSpr = new HSprite(Assets.entities, 'Ghost');
		ghostSpr.y = -300;
		ghostSpr.x = -50;

		score = 0;

		startLevel(1);
	}

	public static function load() {		
		savData = hxd.Save.load(savData, 'save/GameOne');
	}

	override function startLevel(levelUID:Int) {
		super.startLevel(levelUID);

		final nbPeople = 3;
		
		var peopleShare = new Array<Array<Bool>>();
		var allAttrs = EAttribute.createAll();
		peopleShare.resize(nbPeople);
		for (i in 0...peopleShare.length) {
			peopleShare[i] = new Array<Bool>();
			for (j in 0...allAttrs.length) {
				peopleShare[i][j] = false;
			}
		}
		
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

		// -- Cats
		var removedCat = M.randRange(0, 2);
		@:privateAccess(Level)
		for (i in 0...3) {
			if (i == removedCat) continue;
			peopleShare[i][Cat.getIndex()] = true;

			var catBg = Assets.levels.getBitmap('Background${levelUID}_Cat${i + 1}');
			level.root.add(catBg, Const.GAME_LEVEL_BG);
		}

		// -- Mission
		for (i in 0...chosenChars.length) {
			for (j in i + 1...chosenChars.length) {
				if (chosenChars[i].hairColor == chosenChars[j].hairColor) {
					peopleShare[i][HairColor.getIndex()] = true;
					peopleShare[j][HairColor.getIndex()] = true;
				}
				if (chosenChars[i].trouser == chosenChars[j].trouser) {
					peopleShare[i][Trouser.getIndex()] = true;
					peopleShare[j][Trouser.getIndex()] = true;
				}
				if (chosenChars[i].eyesClosed == chosenChars[j].eyesClosed) {
					peopleShare[i][EyesClosed.getIndex()] = true;
					peopleShare[j][EyesClosed.getIndex()] = true;
				}
			}
		}

		// Target must have at least 2 clues in common with the other
		var higherClues = 2;
		var nbTargets = 0;
		for (i in 0...peopleShare.length) {
			var clues = peopleShare[i];
			var nbClues = 0;
			for (b in clues) {
				if (b) nbClues++;
			}
			if (nbClues >= higherClues) {
				nbTargets++;
			}
		}
		if (nbTargets == 0) {
			startLevel(levelUID);
			return;
		}

		// Pick the target among the ones with the highest # of clues
		var target = M.randRange(0, nbTargets - 1);
		for (i in 0...peopleShare.length) {
			var clues = peopleShare[i];
			var nbClues = 0;
			for (b in clues) {
				if (b) nbClues++;
			}
			if (nbClues >= higherClues){
				if (target == 0) {
					target = i;
					break;
				}
				target--;
			}
		}

		// Pick the clues
		targetAttrs = new Array<Bool>();
		targetAttrs.resize(allAttrs.length);

		// Pick the attributes shared but not with everyone
		var nbPicked = 0;
		var peopleExcluded = new Array<Int>();
		peopleExcluded.push(target);
		for (attr in allAttrs) {
			var sharedWAll = true;
			for (i in 0...peopleShare.length) {
				if (peopleExcluded.contains(i)) continue;
				if (peopleShare[target][attr.getIndex()] != peopleShare[i][attr.getIndex()]) {
					sharedWAll = false;
					nbPicked++;
					peopleExcluded.push(i);
					break;
				}
			}
			
			targetAttrs[attr.getIndex()] = !sharedWAll;
		}
		
		while (nbPicked < 3) {
			var n = M.randRange(0, allAttrs.length - 1 - nbPicked);
			for (attr in allAttrs) {
				if (targetAttrs[attr.getIndex()]) continue;
				if (n == 0) {
					nbPicked++;
					targetAttrs[attr.getIndex()] = true;
					break;
				}
				n--;
			}
		}
		
		targetHasCat = removedCat != target;
		targetData = chosenChars[target];
		hud.targetUpdated();
	}

	public function characterKilled(char : Character) {
		locked = true;

		if (char.data == targetData)
			score++;
			
		char.isDead = true;
		ghostSpr.anim.play('Ghost').setSpeed(3 / Const.FPS).onEnd(() -> {
			ghostSpr.setFrame(0);
			ghostSpr.remove();
		});
		char.addChild(ghostSpr);

		cd.setS('NewLevel', ghostSpr.anim.getDurationS(Const.FPS) + .1, () -> {
			if (score < Const.GAMEONE_SCORE_MAX)
				startLevel(1);
			else
				Main.ME.startLetter('GameOne_LetterEnd', () -> Main.ME.startMainMenu());
		});
	}
}