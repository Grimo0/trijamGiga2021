package ui;

import hxd.Event;
import hxd.Event.EventKind;
import dn.Process;

class Letter extends Process {
	public var ca(default, null) : dn.heaps.Controller.ControllerAccess;	
	
	public var pxWid(get, never) : Int;
	function get_pxWid() return M.ceil(w() / Const.UI_SCALE);

	public var pxHei(get, never) : Int;
	function get_pxHei() return M.ceil(h() / Const.UI_SCALE);
	
	var letter : h2d.Bitmap;

	public function new(name: String, cb : Void -> Void) {
		super(Main.ME);

		ca = Main.ME.controller.createAccess("letter");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);

		createRootInLayers(Main.ME.root, Const.MAIN_LAYER_UI);

		letter = Assets.ui.getBitmap(name, root);
		letter.x = -letter.tile.dx;
		letter.y = -letter.tile.dy;
		letter.width = letter.tile.width;
		letter.height = letter.tile.height;

		var interactive = new Interactive(letter.width, letter.height, root);
		interactive.onClick = (e : hxd.Event) -> {
			cb();
		};

		Process.resizeAll();
		
		delayer.addF(() -> {
			hxd.Window.getInstance().event(new hxd.Event(hxd.Event.EventKind.EMove, root.getScene().mouseX, root.getScene().mouseY));
		}, 1);
	}

	override function onResize() {
		super.onResize();

		var scaleX = pxWid / letter.width;
		var scaleY = pxHei / letter.height;
		root.setScale(scaleX < scaleY ? scaleX : scaleY);
		root.x = (pxWid - letter.width * root.scaleX) / 2;
		root.y = (pxHei - letter.height * root.scaleY) / 2;
	}
}
