package sprites;

import luxe.Sprite;
import luxe.options.SpriteOptions;

class DrawingPencil extends Sprite {

    public function new(options:SpriteOptions)
    {
            // Pencil's specific setup
        options.texture = Luxe.resources.texture("assets/pencil_writing.png");
        options.texture.filter_min = phoenix.Texture.FilterType.nearest;
        options.texture.filter_mag = phoenix.Texture.FilterType.nearest;

            // Call parent constructor
        super(options);
    }
}
