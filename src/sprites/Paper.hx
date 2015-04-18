package sprites;

import luxe.Sprite;
import luxe.options.SpriteOptions;

class Paper extends Sprite {

    public function new(options:SpriteOptions)
    {
            // Pencil's specific setup
        options.texture = Luxe.loadTexture("assets/paper.png");
        options.texture.filter = phoenix.Texture.FilterType.nearest;

            // Call parent constructor
        super(options);
    }



}
