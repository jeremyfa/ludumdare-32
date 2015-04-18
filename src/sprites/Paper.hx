package sprites;

import luxe.Sprite;
import luxe.options.SpriteOptions;
import luxe.Vector;
import luxe.Color;

typedef PaperOptions = {

    > SpriteOptions,

    censored: Bool

}

class Paper extends Sprite {

    static var censored_position: Vector = new Vector(114 / 2, 144 / 2);
    static var censored_rotation: Float = 60.0;

    var censored_sprite: Sprite;

    public function new(options:PaperOptions)
    {
            // Pencil's specific setup
        options.texture = Luxe.loadTexture("assets/paper.png");
        options.texture.filter = phoenix.Texture.FilterType.nearest;

            // Call parent constructor
        super(options);

        if (options.censored) {
            censored_sprite = new Sprite({
                texture:    Luxe.loadTexture("assets/censored.png"),
                parent:     this,
                depth:      depth + 0.0001,
                pos:        censored_position,
                rotation_z: censored_rotation,
                color:      new Color().set(1,1,1,0.5)
            });
        }
    }

    override public function ondestroy() {
            // Destroy censored sprite if needed
        if (censored_sprite != null) {
            censored_sprite.parent = null;
            censored_sprite.destroy();
            censored_sprite = null;
        }
    }

}
