package ui;

import hxd.Event;
import hxd.Event.EventKind;
import dn.Process;

class MainMenu extends Process {
	public static var ME : MainMenu;

	public var ca(default, null) : dn.heaps.Controller.ControllerAccess;	
	
	public var pxWid(get, never) : Int;
	function get_pxWid() return M.ceil(w() / Const.UI_SCALE);

	public var pxHei(get, never) : Int;
	function get_pxHei() return M.ceil(h() / Const.UI_SCALE);
	
	var background : h2d.Bitmap;
	var gameOne : h2d.Bitmap;
	var gameTwo : h2d.Bitmap;

	public function new() {
		super(Main.ME);
		ME = this;

		ca = Main.ME.controller.createAccess("mainMenu");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);

		createRootInLayers(Main.ME.root, Const.MAIN_LAYER_UI);

		background = Assets.ui.getBitmap('MainMenu', root);
		background.width = background.tile.width;
		background.height = background.tile.height;
		
		gameOne = Assets.ui.getBitmap('MainMenu_GameOne', root);
		gameOne.width = gameOne.tile.width;
		gameOne.height = gameOne.tile.height;
		gameOne.filter = new h2d.filter.Glow(0xBB3333, .8, 100, 1, 1, true);
		gameOne.filter.enable = false;

		gameTwo = Assets.ui.getBitmap('MainMenu_GameTwo', root);
		gameTwo.width = gameTwo.tile.width;
		gameTwo.height = gameTwo.tile.height;
		gameTwo.filter = new h2d.filter.Glow(0xBB3333, .8, 100, 1, 1, true);
		gameTwo.filter.enable = false;

		var interactive = new Interactive(background.width, background.height, root);
		interactive.onMove = (e : hxd.Event) -> {
			var bgSize = background.getSize();
			if (e.relX < bgSize.width * 0.5) {
				gameOne.filter.enable = true;
				gameTwo.filter.enable = false;
			} else {
				gameOne.filter.enable = false;
				gameTwo.filter.enable = true;
			}
		};
		interactive.onOut = (e : hxd.Event) -> {
			gameOne.filter.enable = false;
			gameTwo.filter.enable = false;
		};
		interactive.onClick = (e : hxd.Event) -> {
			var bgSize = background.getSize();
			if (e.relX < bgSize.width * 0.5) {
				Main.ME.startLetter('GameOne_LetterIntro', () -> Main.ME.startGameOne());
			} else {
				Main.ME.startLetter('GameTwo_LetterIntro', () -> Main.ME.startGameTwo());
			}
		};

		Process.resizeAll();
		
		delayer.addF(() -> {
			hxd.Window.getInstance().event(new hxd.Event(hxd.Event.EventKind.EMove, root.getScene().mouseX, root.getScene().mouseY));
		}, 1);
	}

	override function onResize() {
		super.onResize();

		var scaleX = pxWid / background.width;
		var scaleY = pxHei / background.height;
		root.setScale(scaleX > scaleY ? scaleX : scaleY);
		root.x = (pxWid - background.width * root.scaleX) / 2;
		root.y = (pxHei - background.height * root.scaleY) / 2;
	}

	override function update() {
		super.update();

		#if debug
		// Exit
		if (ca.bPressed()) {
			#if hl
			if (!cd.hasSetS("exitWarn", 3))
				trace(Lang.t._("Press ESCAPE again to exit."));
			else
				hxd.System.exit();
			#end

			return;
		}
		#end
	}
}
