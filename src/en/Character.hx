package en;

@:allow(Game)
class Character extends h2d.Object {
	var type : ECharacter;
	
	var interactive : Interactive;

	public function new(?parent : h2d.Object, type : ECharacter) {
		super(parent);
		this.type = type;

		var bmpData = Assets.entities.getFrameData(type.getName());
		var bmp = Assets.entities.getBitmap(type.getName());
		addChild(bmp);

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