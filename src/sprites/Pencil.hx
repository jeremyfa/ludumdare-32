package sprites;

import luxe.Sprite;
import luxe.options.SpriteOptions;

class Pencil extends Sprite {

    public function new(options:SpriteOptions)
    {
            // Pencil's specific setup
        options.texture = Luxe.loadTexture("assets/pencil_default.png");
        options.texture.filter = phoenix.Texture.FilterType.nearest;

            // Call parent constructor
        super(options);
    }



}
