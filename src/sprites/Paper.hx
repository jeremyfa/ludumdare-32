package sprites;

import luxe.Sprite;
import luxe.options.SpriteOptions;

typedef PaperOptions = {

    > SpriteOptions,

    censored: Bool

}

class Paper extends Sprite {

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

            });
        }
    }



}
