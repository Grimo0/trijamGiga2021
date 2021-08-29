package en;

class Character extends h2d.Object {
	var type : ECharacter;

	public function new(?parent : h2d.Object, type : ECharacter) {
		super(parent);
		this.type = type;

		var bmp = Assets.entities.getBitmap(type.getName());
		addChild(bmp);
	}
}