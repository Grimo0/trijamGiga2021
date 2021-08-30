package ui;

import en.EAttribute;

class HudOne extends dn.Process {
	public var game(get, never) : GameOne; inline function get_game() return cast(Game.ME, GameOne);

	var scores = new Array<h2d.Bitmap>();
	var cluesArea = new h2d.Object();

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.MAIN_LAYER_UI);

		Assets.ui.getBitmap('GameOne', root);

		var x = 16;
		var y = 32;
		var offsetX = 66;
		for (i in 0...Const.GAMEONE_SCORE_MAX) {
			var bmp = Assets.ui.getBitmap('Score', root);
			bmp.x = x;
			bmp.y = y;
			bmp.filter = new h2d.filter.Glow(0xFFFFFF, .7, 10, 1, 1, true);
			x += offsetX;
			scores.push(bmp);
		}

		root.addChild(cluesArea);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}

	public function targetUpdated() {
		cluesArea.removeChildren();
		
		var nbClues = 0;
		for (b in game.targetAttrs) {
			if (b) nbClues++;
		}
		
		var x = 48;
		var y = 144;
		var offsetX = Std.int(300 / nbClues);
		for (i in 0...game.targetAttrs.length) {
			if (!game.targetAttrs[i]) continue;
			var attr = EAttribute.createByIndex(i);
			var bmp = Assets.ui.getBitmap('Clues_$attr', cluesArea);
			bmp.x = x;
			bmp.y = y;

			var striked = switch attr {
				case HairColor: !game.targetData.hairColor;
				case Trouser: !game.targetData.trouser;
				case EyesClosed: !game.targetData.eyesClosed;
				case Cat: !game.targetHasCat;
				default: false;
			};
			if (striked) {
				var strike = Assets.ui.getBitmap('Clues_Strike', cluesArea);
				strike.x = x;
				strike.y = y;
			}

			x += offsetX;
		}
	}

	public function scoreUpdated() {
		for (i in 0...game.score) {
			scores[i].alpha = 1;
			scores[i].filter.enable = true;
		}
		for (i in game.score...Const.GAMEONE_SCORE_MAX) {
			scores[i].alpha = .5;
			scores[i].filter.enable = false;
		}
	}
}
