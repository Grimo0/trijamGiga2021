import en.Character;
import en.ECharacterStats;
import en.gameTwo.Death;

class GameTwo extends Game {

	public static var savData : GameSave = new GameSave();

	public override function get_sav() : GameSave {
		return savData;
	}

	public var hud : ui.HudTwo;

	public var death(default, null) : Death;
	public var gauges(default, null) = new Array<Int>();
	public var charData(default, null) : Data.Characters;
	var char : Character;
	var charHistoryCurr = 0;
	var charHistory = new Array<Int>();

	public var score(default, set) = 0;
	public function set_score(s) {
		score = s;
		hud.updateScore();
		return score;
	}

	public function new() {
		name = 'GameTwo';
		super();
		
		hud = new ui.HudTwo();

		death = new Death();
		death.setScale(.8);
		
		var statsAll = ECharacterStats.createAll();
		gauges.resize(statsAll.length);
		for (stat in statsAll) {
			gauges[stat.getIndex()] = Std.int(Const.GAMETWO_GAUGE_MAX * .5);
		}

		hud.updateGauges();

		charHistory.resize(Const.GAMETWO_HISTORY_SIZE);
		
		startLevel(2);
	}

	public static function load() {		
		savData = hxd.Save.load(savData, 'save/GameTwo');
	}

	public function isGameOver() : Bool {
		var statsAll = ECharacterStats.createAll();
		for (stat in statsAll) {
			var val = gauges[stat.getIndex()];
			if (val >= Const.GAMETWO_GAUGE_MAX || val <= 0)
				return true;
		}
		return false;
	}

	override function startLevel(levelUID:Int) {
		// First init
		if (!started) {
			super.startLevel(levelUID);
			started = true;
			
			// -- Death
			level.root.add(death, Const.GAME_LEVEL_ENTITIES);
			death.x = level.pxWid * 0.37;
			death.y = level.pxHei * 0.085;
			
			// -- Interactive
			var interactive = new Interactive(level.pxWid, level.pxHei, root);
			interactive.onMove = (e : hxd.Event) -> {
				if (e.relX < pxWid * 0.4) {
					death.state = ShowLeft;
				} else if (e.relX > pxWid * 0.57) {
					death.state = ShowRight;
				} else {
					death.state = Passive;
				}
			};
			interactive.onOut = (e : hxd.Event) -> {
				death.state = Passive;
			};
			interactive.onClick = onClick;

			score = 0;
		} else
			score++;

		// -- Character random selection
		var allChars = Data.characters.all.toArrayCopy();	
		for (h in charHistory) {
			allChars.remove(Data.characters.all[h]);
		}
		var n = M.randRange(0, allChars.length - 1);
		charData = allChars[n];

		// Update History
		charHistoryCurr++;
		if (charHistoryCurr >= charHistory.length)
			charHistoryCurr = 0;
		for (i in 0...Data.characters.all.length) {
			if (Data.characters.all[i] == charData)
				charHistory[charHistoryCurr] = i;
		}
		
		// Create object
		char = new Character(charData);
		char.x = level.pxWid * 0.385;
		char.y = level.pxHei - char.getSize().yMax * .8;
		char.alpha = 0;
		level.root.add(char, Const.GAME_LEVEL_ENTITIES);
		
		tw.createMs(char.alpha, 1, 300).end(() -> locked = false);	
		
		death.state = Passive;	
		
		#if hl
		delayer.addF(() -> {
			hxd.Window.getInstance().event(new hxd.Event(hxd.Event.EventKind.EMove, root.getScene().mouseX, root.getScene().mouseY));
		}, 1);
		#end
	}
	
	function onClick(e : hxd.Event) {
		if (death.state == Passive) return;
		locked = true;

		var rnd = M.frandRange(0.2, 1.2);
		if (death.state == ShowLeft) {
			gauges[Assistance.getIndex()] += Std.int(charData.assistance * rnd);
			gauges[Generosity.getIndex()] += Std.int(charData.generosity * rnd);
			gauges[Peace.getIndex()] += Std.int(charData.peace * rnd);
		} else if (death.state == ShowRight) {
			gauges[Assistance.getIndex()] -= Std.int(charData.assistance * rnd);
			gauges[Generosity.getIndex()] -= Std.int(charData.generosity * rnd);
			gauges[Peace.getIndex()] -= Std.int(charData.peace * rnd);
		}
		
		if (gauges[Assistance.getIndex()] < 0)
			gauges[Assistance.getIndex()] = 0;
		else if (gauges[Assistance.getIndex()] > Const.GAMETWO_GAUGE_MAX)
			gauges[Assistance.getIndex()] = Const.GAMETWO_GAUGE_MAX;
		if (gauges[Generosity.getIndex()] < 0)
			gauges[Generosity.getIndex()] = 0;
		else if (gauges[Generosity.getIndex()] > Const.GAMETWO_GAUGE_MAX)
			gauges[Generosity.getIndex()] = Const.GAMETWO_GAUGE_MAX;
		if (gauges[Peace.getIndex()] < 0)
			gauges[Peace.getIndex()] = 0;
		else if (gauges[Peace.getIndex()] > Const.GAMETWO_GAUGE_MAX)
			gauges[Peace.getIndex()] = Const.GAMETWO_GAUGE_MAX;

		hud.updateGauges();

		if (isGameOver()) {
			tw.createMs(char.alpha, 0, 300).end(() -> {
				cd.setMs('GameOver', 100, () -> Main.ME.startMainMenu());
			});
		} else {
			tw.createMs(char.alpha, 0, 300).end(() -> {
				char.remove();
				locked = false;
				startLevel(2);
			});
		}
	}
}