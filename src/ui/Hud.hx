package ui;

class Hud extends dn.Process {
	public var game(get, never) : Game; inline function get_game() return Game.ME;

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.MAIN_LAYER_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}
}
