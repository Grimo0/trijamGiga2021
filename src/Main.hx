import ui.MainMenu;
import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;

	/** Used to create "Access" instances that allow controller checks (keyboard or gamepad) **/
	public var controller : dn.heaps.Controller;

	/** Controller Access created for Main & Boot **/
	public var ca : dn.heaps.Controller.ControllerAccess;

	public var debug = false;

	public function new(s : h2d.Scene) {
		super();
		ME = this;

		createRoot(s);

		// Engine settings
		hxd.Timer.wantedFPS = Const.FPS;
		engine.backgroundColor = 0xff << 24 | 0x111133;
		#if (hl && !debug)
		engine.fullScreen = true;
		#end

		sys.FileSystem.createDirectory('save');

		// Assets & data init
		hxd.snd.Manager.get(); // force sound manager init on startup instead of first sound play
		Assets.init();
		new ui.Console(Assets.fontTiny, s);
		Lang.init("en");

		// Game controller & default key bindings
		controller = new dn.heaps.Controller(s);
		ca = controller.createAccess("main");
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(AXIS_LEFT_Y_POS, Key.UP, Key.Z);
		controller.bind(AXIS_LEFT_Y_NEG, Key.DOWN, Key.S);
		controller.bind(X, Key.F);
		controller.bind(Y, Key.C);
		controller.bind(A, Key.E);
		controller.bind(B, Key.SPACE);
		controller.bind(SELECT, Key.R);
		controller.bind(START, Key.ESCAPE);

		// Focus helper (process that suspend the game when the focus is lost)
		new GameFocusHelper();

		new Options();
		Options.ME.load();

		// Start
		hxd.Timer.skip();
		delayer.addF(startMainMenu, 1);
		#if debug
		debug = true;
		#end
	}

	public function startMainMenu() {
		killAllChildrenProcesses();

		if (MainMenu.ME != null) {
			MainMenu.ME.destroy();
			delayer.addF(function() {
				new MainMenu();
			}, 1);
		} else
			new MainMenu();
	}

	/** Start game process **/
	public function startGame() {
		if (Game.ME != null) {
			Game.ME.destroy();
			delayer.addF(function() {
				new Game();
			}, 1);
		} else
			new Game();
	}

	override function update() {
		super.update();

		#if debug
		if (debug) {
			updateImGui();
		}
		#end
	}

	#if debug
	function updateImGui() {
		var halfBtnSize : ImVec2 = {x: ImGui.getColumnWidth() / 2 - 5, y: ImGui.getTextLineHeightWithSpacing()};
		if (ImGui.button('New game', halfBtnSize)) {
			hxd.Save.delete('save/game');
			delayer.addF(startGame, 1);
		}
		if (Options.ME != null && ImGui.treeNodeEx('Options')) {
			if (ImGui.button('Save', halfBtnSize))
				Options.ME.save();
			ImGui.sameLine(0, 5);
			if (ImGui.button('Load', halfBtnSize))
				Options.ME.load();

			Options.ME.imGuiDebugFields();

			ImGui.treePop();
		}
		ImGui.separator();
	}
	#end

	#if debug
	var imguiCaptureMouse = false;
	#end
	override function postUpdate() {
		super.postUpdate();

		#if debug
		if (hxd.Key.isPressed(hxd.Key.F1)) {
			debug = !debug;
			if (!debug) {
				imguiCaptureMouse = false;
				controller.unlock();
			}
		}

		if (debug) {
			if (ImGui.wantCaptureMouse()) {
				if (!imguiCaptureMouse && !controller.isLocked()) {
					imguiCaptureMouse = true;
					controller.lock();
				}
			} else if (imguiCaptureMouse) {
				imguiCaptureMouse = false;
				controller.unlock();
			}
		}
		#end
	}
}
