#if debug
import imgui.ImGuiDrawable;
#end

/**
	This class is the entry point for the app.
	It doesn't do much, except creating Main and taking care of app speed ()
**/
class Boot extends hxd.App {
	public static var ME : Boot;

	#if debug
	var tmodSpeedMul = 1.0;
	var ca(get, never) : dn.heaps.Controller.ControllerAccess;
	inline function get_ca() return Main.ME.ca;
	#end

	/**
		App entry point
	**/
	static function main() {
		new Boot();
	}

	var speed = 1.0;

	#if debug
	var imguiDrawable : ImGuiDrawable;
	#end

	/**
		Called when engine is ready, actual app can start
	**/
	override function init() {
		ME = this;
		new Main(s2d);

		#if debug
		imguiDrawable = new ImGuiDrawable(s2d);
		var style : ImGuiStyle = ImGui.getStyle();
		style.WindowBorderSize = 0;
		style.WindowRounding = 0;
		style.WindowPadding.x = 2;
		style.WindowPadding.y = 2;
		ImGui.setStyle(style);
		#end

		onResize();
	}

	override function onResize() {
		super.onResize();

		#if debug
		ImGui.setDisplaySize(s2d.width, s2d.height);
		#end

		Const.update_SCALE();

		dn.Process.resizeAll();
	}

	override function update(deltaTime : Float) {
		super.update(deltaTime);

		#if debug
		imguiDrawable.update(deltaTime);
		ImGui.newFrame();

		var debug = Main.ME.debug;
		if (debug) {
			ImGui.setNextWindowPos({x: 0, y: 0});
			ImGui.setNextWindowSize({x: 300, y: s2d.height});
			ImGui.begin('Debug (F1)###Debug##Default', ImGuiWindowFlags.NoResize & ImGuiWindowFlags.NoMove);
		}
		#end

		dn.heaps.Controller.beforeUpdate();
		var tmod = hxd.Timer.tmod * speed;
		dn.Process.updateAll(tmod);

		#if debug
		if (debug) {
			ImGui.end();
		}

		ImGui.render();
		#end
	}
}
