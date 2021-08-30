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
	public var targetData(default, set) : Data.Characters;
	public function set_targetData(d) {
		targetData = d;
		hud.targetUpdated();
		return targetData;
	}
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
		
		var targets = new Array<Array<Bool>>();
		var allAttrs = EAttribute.createAll();
		targets.resize(nbPeople);
		for (i in 0...targets.length) {
			targets[i] = new Array<Bool>();
			for (j in 0...allAttrs.length) {
				targets[i][j] = false;
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
					targets[i][HairColor.getIndex()] = true;
					targets[j][HairColor.getIndex()] = true;
					links[i][j]++;
					links[j][i]++;
				}
				if (chosenChars[i].trouser == chosenChars[j].trouser) {
					targets[i][Trouser.getIndex()] = true;
					targets[j][Trouser.getIndex()] = true;
					links[i][j]++;
					links[j][i]++;
				}
				if (chosenChars[i].eyesClosed == chosenChars[j].eyesClosed) {
					targets[i][EyesClosed.getIndex()] = true;
					targets[j][EyesClosed.getIndex()] = true;
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
			var nbClues = 0;
			for (b in clues) {
				if (b) nbClues++;
			}
			if (nbClues >= higherClues) {
				if (higherClues < nbClues) {
					nbTargets = 1;
					higherClues = nbClues;
				} else
					nbTargets++;
			}
		}

		// Pick the target among the ones with the highest # of clues
		var target = M.randRange(0, nbTargets - 1);
		for (i in 0...targets.length) {
			var clues = targets[i];
			var nbClues = 0;
			for (b in clues) {
				if (b) nbClues++;
			}
			if (nbClues == higherClues){
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
			// If too many potential targets, remove cat from the ones with the more links with the target
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
					cats.remove(i);
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
			targets[c][Cat.getIndex()] = true;

			var catBg = Assets.levels.getBitmap('Background${levelUID}_Cat${c + 1}');
			level.root.add(catBg, Const.GAME_LEVEL_BG);
		}

		// Remove a clue if too many
		var nbClues = 0;
		for (b in targets[target]) {
			if (b) nbClues++;
		}
		if (nbClues > 3) {
			var removedClue = M.randRange(0, nbClues - 1);
			for (i in 0...targets[target].length) {
				if (targets[target][i] && removedClue == 0) {
					targets[target][i] = false;
					break;
				}
				removedClue--;
			}
		}

		// -- Save the target's attrs list
		targetAttrs = targets[target];
		targetData = chosenChars[target];
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
				Main.ME.startMainMenu();
		});
	}
}