package ui;

class HudOne extends dn.Process {
	public var game(get, never) : GameOne; inline function get_game() return cast(Game.ME, GameOne);

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.MAIN_LAYER_UI);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}
}
