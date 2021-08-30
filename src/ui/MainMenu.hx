package ui;

import hxd.Event;
import hxd.Event.EventKind;
import dn.Process;

class MainMenu extends Process {
	public static var ME : MainMenu;

	public var ca(default, null) : dn.heaps.Controller.ControllerAccess;
	
	var background : h2d.Bitmap;

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

		var interactive = new Interactive(background.width, background.height, root);
		interactive.onClick = (e : hxd.Event) -> {
			var bgSize = background.getSize();
			if (e.relX < bgSize.width * 0.5) {
				Main.ME.startGameOne();
			} else {
				Main.ME.startGameTwo();
			}
		};

		Process.resizeAll();
	}

	override function onResize() {
		super.onResize();

		var scaleX = Const.DEFAULT_WIDTH / background.width;
		var scaleY = Const.DEFAULT_HEIGHT / background.height;
		root.setScale(scaleX > scaleY ? scaleX : scaleY);
		root.x = (Const.DEFAULT_WIDTH - background.width * root.scaleX) / 2;
		root.y = (Const.DEFAULT_HEIGHT - background.height * root.scaleY) / 2;
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
