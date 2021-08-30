package en.gameTwo;

import h2d.Bitmap;

enum EState {
	Passive;
	ShowLeft;
	ShowRight;
}

class Death extends h2d.Object {
	public var game(get, never) : GameTwo; inline function get_game() return cast(Game.ME, GameTwo);

	var body : HSprite;
	var armLeft : Bitmap;
	var armRight : Bitmap;

	public var state(default, set) : EState = Passive;
	public function set_state(s : EState) {
		state = s;
		switch s {
			case ShowLeft:
				armLeft.visible = true;
				body.set('Death2');
			case ShowRight:
				armRight.visible = true;
				body.set('Death2');
			case Passive:
				armLeft.visible = false;
				armRight.visible = false;
				body.set('Death2_Passive');
		}
		game.hud.updateHelp();
		return state;
	}

	public function new(?parent : h2d.Object) {
		super(parent);

		body = new HSprite(Assets.entities, 'Death2_Passive', this);
		
		armLeft = Assets.entities.getBitmap('Death2_ArmLeft', this);
		armLeft.visible = false;
		armRight = Assets.entities.getBitmap('Death2_ArmRight', this);
		armRight.visible = false;
	}
}