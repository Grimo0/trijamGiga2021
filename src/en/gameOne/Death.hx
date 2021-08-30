package en.gameOne;

enum EState {
	Passive;
	Killing;
}

class Death extends h2d.Object {
	public var game(get, never) : GameOne; inline function get_game() return cast(Game.ME, GameOne);

	public var state(default, set) : EState = Passive;
	public function set_state(s : EState) {
		return state = s;
	}

	public function new(?parent : h2d.Object) {
		super(parent);

		var bmp = Assets.entities.getBitmap('Death');
		addChild(bmp);
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