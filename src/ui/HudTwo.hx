package ui;

class HudTwo extends dn.Process {
	public var game(get, never) : GameTwo; inline function get_game() return cast(Game.ME, GameTwo);

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.MAIN_LAYER_UI);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}
}
