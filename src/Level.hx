class Level extends dn.Process {
	var game(get, never) : Game; inline function get_game() return Game.ME;

	public var gridSize(get, never) : Int;
	inline function get_gridSize() return Const.GRID;

	public var cWid(get, never) : Int; inline function get_cWid() return Std.int(pxWid / gridSize);
	public var cHei(get, never) : Int; inline function get_cHei() return Std.int(pxHei / gridSize);
	public var pxWid(get, never) : Int; inline function get_pxWid() return background == null ? game.pxWid : Std.int(background.width);
	public var pxHei(get, never) : Int; inline function get_pxHei() return background == null ? game.pxHei : Std.int(background.height);

	var background : h2d.Bitmap;

	public function new() {
		super(game);
		createRootInLayers(game.scroller, Const.GAME_SCROLLER_LEVEL);
	}

	public inline function isValid(cx, cy) return cx >= 0 && cx < cWid && cy >= 0 && cy < cHei;

	public inline function coordId(cx, cy) return cx + cy * cWid;

	public inline function hasCollision(cx, cy) : Bool
		return false; // TODO: collision with entities and obstacles

	public inline function getFloor(cx, cy) : Int
		return 0;

	override function init() {
		super.init();

		if (root != null)
			initLevel();
	}

	public function initLevel() {
		game.scroller.add(root, Const.GAME_SCROLLER_LEVEL);
		root.removeChildren();

		// Get level background image
		background = Assets.levels.getBitmap('Background');
		background.width = background.tile.width;
		background.height = background.tile.height;
		root.add(background, Const.GAME_LEVEL_BG);
	}

	override function onResize() {
		super.onResize();

		var scaleX = game.pxWid / background.width;
		var scaleY = game.pxHei / background.height;
		root.setScale(scaleX > scaleY ? scaleX : scaleY);
		root.x = (game.pxWid - background.width * root.scaleX) / 2;
		root.y = (game.pxHei - background.height * root.scaleY) / 2;
	}
}
