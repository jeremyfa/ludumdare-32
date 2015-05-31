package sprites;

import luxe.Sprite;
import luxe.options.SpriteOptions;
import luxe.Vector;
import luxe.Color;
import luxe.Rectangle;

import luxe.collision.shapes.Polygon;

import luxe.tween.Actuate;

typedef PaperOptions = {

    > SpriteOptions,

    censored: Bool

}

class Paper extends Sprite {

    static var paper_width: Float = 114;
    static var paper_height: Float = 144;

    static var censored_position: Vector = new Vector(114 / 2, 144 / 2);
    static var censored_rotation: Float = 60.0;
    static var censored_color: Color = new Color().set(1,1,1,0.5);

    static var drawing_position: Vector = new Vector(114 / 2, 144 / 2);

    var censored_sprite: Sprite;
    var drawing_sprite: Sprite;

    public var shape(get, null): Polygon;
    public var has_drawing: Bool = false;

    public var censored: Bool = false;

    public function new(options:PaperOptions)
    {
            // Pencil's specific setup
        options.texture = Luxe.resources.texture("assets/paper.png");
        options.texture.filter_mag = phoenix.Texture.FilterType.linear;
        options.texture.filter_min = phoenix.Texture.FilterType.linear;

            // Call parent constructor
        super(options);

        if (options.censored) {
            censored_sprite = new Sprite({
                texture:    Luxe.resources.texture("assets/censored.png"),
                parent:     this,
                depth:      depth + 0.0002,
                pos:        censored_position,
                rotation_z: censored_rotation,
                color:      censored_color
            });
        }

            // Keep censored value
        censored = options.censored;

            // Create initial shape
        shape = Polygon.rectangle(pos.x, pos.y, paper_width, paper_height, true);
        shape.rotation = rotation_z;
    }

    public function draw_on_paper(index:Int) {
        has_drawing = true;

        drawing_sprite = new Sprite({
            texture:    Luxe.resources.texture("assets/drawing_" + index + ".png"),
            parent:     this,
            depth:      depth + 0.0001,
            pos:        drawing_position,
            color:      new Color(1,1,1,0)
        });

        Actuate.tween(drawing_sprite.color, 1, {a: 1});
    }

    public function get_shape():Polygon {
        shape.x = pos.x;
        shape.y = pos.y;
        return shape;
    }

    override public function ondestroy() {
            // Destroy censored sprite if needed
        if (censored_sprite != null) {
            censored_sprite.parent = null;
            censored_sprite.destroy();
            censored_sprite = null;
        }

            // Destroy censored sprite if needed
        if (drawing_sprite != null) {
            drawing_sprite.parent = null;
            drawing_sprite.destroy();
            drawing_sprite = null;
        }

            // Destroy shape
        shape.destroy();
        shape = null;

        super.ondestroy();
    }

}
