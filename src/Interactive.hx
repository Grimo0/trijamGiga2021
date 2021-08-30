class Interactive extends h2d.Interactive {
	#if debug
	static var ALL : Array<Interactive> = [];

	public static function renderDebugBounds() {
		for (interactive in ALL) {
			interactive.renderBounds();
		}
	}

	public static function clearDebugBounds() {
		for (interactive in ALL) {
			interactive.debugBounds.remove();
		}
	}
	#end

	override function onAdd() {
		super.onAdd();
		#if debug
		ALL.push(this);
		#end
	}

	override function onRemove() {
		super.onRemove();
		#if debug
		ALL.remove(this);
		#end
	}

	override public function handleEvent( e : hxd.Event ) {
		if (e.kind == EMove)
			e.propagate = true;
		if (Main.ME.controller.isLocked() || (Game.ME != null && Game.ME.ca.locked())) return;
		super.handleEvent(e);
	}
	
	#if debug
	var debugBounds = new h2d.Graphics();
	public function renderBounds() {
		var c = Color.makeColorHsl(Math.random(), 1, 1);
		debugBounds.clear();

		// Bounds rect
		var size = new h2d.col.Bounds();
		getBoundsRec(scene, size, true);
		var global = localToGlobal();
		debugBounds.lineStyle(3, c, 0.5);
		debugBounds.drawRect(global.x, global.y, size.width, size.height);
		
		scene.add(debugBounds, Const.GAME_SCROLLER_FX_FRONT);
	}
	#end
}