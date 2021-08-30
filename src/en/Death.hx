package en;

import h2d.Bitmap;

enum EState {
	Passive;
	ShowLeft;
	ShowRight;
	Killing;
}

class Death extends h2d.Object {
	public var game(get, never) : Game;
	inline function get_game() return Game.ME;

	var arm : Bitmap;

	public var state(default, set) : EState = Passive;
	public function set_state(s : EState) {
		switch s {
			case ShowLeft:
				arm.visible = true;
				arm.x = 0;
				arm.scaleX = 1;
			case ShowRight:
				arm.visible = true;
				arm.x = 50;
				arm.scaleX = -1;
			case Killing:
				arm.visible = false;
			case Passive:
				arm.visible = false;
		}
		return state = s;
	}

	public function new(?parent : h2d.Object) {
		super(parent);

		var bmp = Assets.entities.getBitmap('Death');
		addChild(bmp);
		
		arm = Assets.entities.getBitmap('Death_Arm');
		arm.visible = false;
		addChild(arm);
	}

	public function kill(character : Character) {
		if (state != Passive) return;

		var dir = 1;
		if (character.absX < absX)
			dir = -1;

		state = Killing;

		var prevX = x;
		var prevY = y;
		game.tw.createMs(x, x + 400, 500);
		game.tw.createMs(y, y - 10, 100).chainMs(prevY, 400);
		game.tw.createMs(rotation, -dir * M.PIHALF * 0.1, 100).chainMs(dir * M.PIHALF * 0.3, 400).end(() -> {
			state = Passive;
			game.tw.createMs(x, prevX, 200);
			game.tw.createMs(y, prevY, 200);
			game.tw.createMs(rotation, 0, 200);
		});
		game.cd.setMs('CharacterKilled', 200, () -> cast(game, GameOne).characterKilled(character));
	}
}