package en;

@:allow(Game)
class Character extends h2d.Object {
	public var data(default, null) : Data.Characters;
	
	var interactive : Interactive;

	var deadFace : h2d.Bitmap;

	public var isDead(default, set) = false;
	public function set_isDead(b) {
		deadFace.visible = b;
		return isDead = b;		
	}

	public function new(data : Data.Characters) {
		super();
		this.data = data;

		var bmpData = Assets.entities.getFrameData(data.name);
		var bmp = Assets.entities.getBitmap(data.name);
		addChild(bmp);
		deadFace = Assets.entities.getBitmap(data.name + '_Dead');
		deadFace.visible = false;
		addChild(deadFace);

		interactive = new Interactive(bmpData.realWid, bmpData.realHei, this);
		interactive.onOver = onOver;
		interactive.onOut = onOut;
		interactive.onClick = onClick;
		
		filter = new h2d.filter.DropShadow(0, 0.785, 0xCCCCCC, 1., 200, 1, 1, true);
		filter.enable = false;
	}

	function onOver(e : hxd.Event) {
		filter.enable = true;
	}

	function onOut(e : hxd.Event) {
		filter.enable = false;
	}

	var onClick(default, set) : (e : hxd.Event) -> Void;
	public function set_onClick(f) {
		interactive.onClick = f;
		return onClick = f;
	}
}