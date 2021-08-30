package ui;

import en.ECharacterStats;

class HudTwo extends dn.Process {
	public var game(get, never) : GameTwo; inline function get_game() return cast(Game.ME, GameTwo);

	var gauges = new Array<ui.Bar>();
	var helps = new Array<h2d.Object>();
	var score : h2d.Text;
	var ghostSpr : HSprite;

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.MAIN_LAYER_UI);
		
		var statsAll = ECharacterStats.createAll();
		var width = 300;
		var x = (game.pxWid -  width) * .45;
		var y = 50;
		var offsetY = 50;
		for (stat in statsAll) {
			var gauge = new Bar(width, 10, 0x937b69, root);
			gauge.x = x;
			gauge.y = y;
			gauges.push(gauge);
			
			var iconData = Assets.ui.getFrameData('GameTwoAttrs/$stat');
			var icon = Assets.ui.getBitmap('GameTwoAttrs/$stat', root);
			icon.x = x - iconData.realWid;
			icon.y = y - iconData.realHei * .5;

			y += offsetY;
		}

		ghostSpr = new HSprite(Assets.entities, 'Ghost', root);
		ghostSpr.x = x + width - 100;
		ghostSpr.y = -50;
		ghostSpr.setScale(.5);

		score = new h2d.Text(Assets.fontLarge, root);
		score.x = x + width + 25;
		score.y = 75;
		score.dropShadow = {
			dx: 0,
			dy: 0,
			color: 0x000000,
			alpha: 1
		};
	}

	public function updateGauges() {
		var statsAll = ECharacterStats.createAll();
		for (stat in statsAll) {
			var val = game.gauges[stat.getIndex()];
			var gauge = gauges[stat.getIndex()];
			gauge.set(val, Const.GAMETWO_GAUGE_MAX);
			gauge.color = switch val {
				case t if (t < Const.GAMETWO_GAUGE_MAX * 0.1 || t > Const.GAMETWO_GAUGE_MAX * 0.9): 0xc30000;
				case t if (t < Const.GAMETWO_GAUGE_MAX * 0.2 || t > Const.GAMETWO_GAUGE_MAX * 0.8): 0xd36c00;
				case _ : gauge.defaultColor;
			};
		}
	}
	
	public function updateHelp() {
		if (game.death.state == Passive) {
			for (object in helps) {
				object.remove();
			}
		} else {
			var statsAll = ECharacterStats.createAll();
			for (stat in statsAll) {
				var val = switch stat {
					case Assistance: game.charData.assistance;
					case Generosity: game.charData.generosity;
					case Peace: game.charData.peace;
				};
				if (val != 0) {
					if (game.death.state == ShowRight)
						val = -val;
					var gauge = gauges[stat.getIndex()];

					var help = Assets.ui.getBitmap('Arrows_${val > 0 ? 'Up' : 'Down'}', root);
					help.x = gauge.x;
					help.y = gauge.y - help.tile.height * .5;

					helps.push(help);
				}
			}
		}
	}

	public function updateScore() {
		score.text = Std.string(game.score);
		ghostSpr.setFrame(M.imin(ghostSpr.totalFrames() - 1, Std.int(game.score / 10)));
		ghostSpr.y = 20 * ghostSpr.frame - 50;
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}
}
