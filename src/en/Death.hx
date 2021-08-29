package en;

import h2d.Bitmap;

enum EState {
	ShowLeft;
	ShowRight;
}

class Death extends h2d.Object {
	var arm : Bitmap;

	public var state(default, set) : EState = null;
	public function set_state(s : EState) {
		switch s {
			case ShowLeft:
				arm.visible = true;
				arm.x = 0;
				arm.scaleX = 1;
			case ShowRight:
				arm.visible = true;
				arm.x = 50;
				arm.scaleX = -1;
			default:
				arm.visible = false;
		}
		return state = s;
	}

	public function new(?parent : h2d.Object) {
		super(parent);

		var bmp = Assets.entities.getBitmap('Death');
		addChild(bmp);
		
		arm = Assets.entities.getBitmap('Death_Arm');
		arm.visible = false;
		addChild(arm);
	}
}