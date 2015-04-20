package sprites;

import luxe.Sprite;
import luxe.options.SpriteOptions;

import luxe.collision.shapes.Polygon;

class Pencil extends Sprite {

    static var pencil_width: Float = 100;
    static var pencil_height: Float = 20;

    public var shape(get, null): Polygon;

    public function new(options:SpriteOptions)
    {
            // Pencil's specific setup
        options.texture = Luxe.loadTexture("assets/pencil_default.png");
        options.texture.filter = phoenix.Texture.FilterType.nearest;

            // Call parent constructor
        super(options);

            // Create initial shape
        shape = Polygon.rectangle(pos.x, pos.y, pencil_width, pencil_height, true);
    }


    public function get_shape():Polygon {
        shape.x = pos.x;
        shape.y = pos.y;
        return shape;
    }

    override public function ondestroy() {

            // Destroy shape
        shape.destroy();
        shape = null;

        super.ondestroy();
    }

}
