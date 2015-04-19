import luxe.Input;
import luxe.Color;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Sprite;
import luxe.Vector;
import phoenix.Texture;
import snow.system.input.Keycodes;

import sprites.*;

import luxe.collision.shapes.*;
import luxe.collision.Collision;

import motion.Actuate;

class Main extends luxe.Game {

    var pressing_up_key: Bool;
    var pressing_down_key: Bool;
    var just_pressed_space_key: Bool;

    var current_pencil: Pencil;
    var current_pencil_speed: Float = 190.0;
    var current_pencil_initial_x: Float = -150;
    var current_pencil_final_x: Float = 0;

    var thrown_pencils: Array<Pencil> = [];
    var thrown_pencil_speed: Float = 240.0;

    var paper_half_width: Float = 250.0;
    var papers_speed: Float = 200.0;
    var papers: Array<Paper> = [];
    var last_paper_sub_depth: Float = 0.0;

    var pencil_half_width: Float = 100;
    var pencil_half_height: Float = 10;

    override function ready() {
            // Init preload
        var preload = new Parcel();

            // Preload textures
        preload.add_texture("assets/censored.png");
        preload.add_texture("assets/drawing_1.png");
        preload.add_texture("assets/drawing_2.png");
        preload.add_texture("assets/drawing_3.png");
        preload.add_texture("assets/drawing_4.png");
        preload.add_texture("assets/drawing_5.png");
        preload.add_texture("assets/paper.png");
        preload.add_texture("assets/pencil_default.png");
        preload.add_texture("assets/pencil_writing.png");

            // Progress bar
        new ParcelProgress({
            parcel: preload,
            background: new Color().rgb(0x888888),
            oncomplete: assets_loaded
        });

            // Start preload
        preload.load();

    } //ready


    function assets_loaded(_) {
            // Initialize scene
        init_scene();
            // Connect input
        connect_input();

    } //assets_loaded


    function init_scene() {
            // Create background
        Luxe.draw.box({
            w:      Luxe.screen.w,
            h:      Luxe.screen.h,
            pos:    Luxe.screen.mid,
            depth:  1,
            color:  new Color().rgb(0x777777)
        });

        use_new_pencil();

    } //init_scene


    function connect_input() {

            // Bind keys
        Luxe.input.bind_key('up', Keycodes.up);
        Luxe.input.bind_key('down', Keycodes.down);
        Luxe.input.bind_key('space', Keycodes.space);

    } //connect_input


        /* Create a new pencil instance. If there was an existing one, `throw it` */
    function use_new_pencil() {

            // Setup initial position
        var initial_position = new Vector(current_pencil_initial_x, Luxe.screen.mid.y);

            // If there is already an existing pencil, get it's Y position
            // And add it to the list of throw pencils
        if (current_pencil != null) {
                // Get Y position
            initial_position.y = current_pencil.pos.y;

                // `throw` pencil
            thrown_pencils.push(current_pencil);
        }

            // Create pencil sprite
        current_pencil = new Pencil({
            depth:      3,
            pos:        initial_position
        });

    } //create_new_pencil


    function use_drawing_pencil(thrown_pencil:Pencil) {
            // Get thrown pencil position
        var pos = thrown_pencil.pos;
            // Ajust position from sprite change
        pos.y -= 40;

            // Remove throw pencil
        thrown_pencils.remove(thrown_pencil);
        thrown_pencil.destroy();

            // Create drawing pencil
        var drawing_pencil = new DrawingPencil({
            pos:    pos,
            depth:  3
        });

            // Do some animation (move the pencil up and down)
        var initial_y = pos.y;
        var step = 3.0;
        Actuate.timer(0.1).onUpdate(function() {
            drawing_pencil.pos.y += step;
        }).onComplete(function() {
            Actuate.timer(0.2).onUpdate(function() {
                drawing_pencil.pos.y -= step;
            }).onComplete(function() {
                Actuate.timer(0.1).onUpdate(function() {
                    drawing_pencil.pos.y += step;
                }).onComplete(function() {
                    Actuate.timer(0.2).onUpdate(function() {
                        drawing_pencil.pos.y -= step;
                    }).onComplete(function() {
                        Actuate.tween(drawing_pencil.color, 0.5, {a: 0}).onComplete(function() {
                            drawing_pencil.destroy();
                        });
                    });
                });
            });
        });

    } //use_drawing_pencil


    function add_paper() {

        var paper = new Paper({
            pos:        new Vector(Luxe.screen.w + paper_half_width, Math.round(Luxe.screen.h * Luxe.utils.random.get())),
            depth:      2 + last_paper_sub_depth,
            rotation_z: Math.round(Luxe.utils.random.float(-90, 90)),
            censored:   Luxe.utils.random.bool()
        });

            // Increase depth a little bit to be sure papers
            // will overlap each other in a natural way
        if (last_paper_sub_depth > 0.9) {
            last_paper_sub_depth = 0.0;
        }
        else {
            last_paper_sub_depth += 0.001;
        }

        papers.push(paper);

    } //add_paper


    override function update(dt:Float) {

            // Let's not do something silly. Be patient.
        if (current_pencil == null) return;

            // If the current pencil is not at it's final X position,
            // just move it a bit more to the right
        if (current_pencil.pos.x < current_pencil_final_x) {
                // Update X
            current_pencil.pos.x = Math.min(current_pencil.pos.x + dt * current_pencil_speed * 2, current_pencil_final_x);

                // Allow pressing space only when the pencil is at its final X position
            just_pressed_space_key = false;
        }
        else {
                // Allow pressing space only when the pencil is at its final X position
            just_pressed_space_key = Luxe.input.inputpressed('space');
        }

            // Look for what is pressed on the keyboard
            // Are we pressing something we care about?
        pressing_up_key = Luxe.input.inputdown('up');
        pressing_down_key = Luxe.input.inputdown('down');

            // Move current pencil upward
        if (pressing_up_key) {
            current_pencil.pos.y = Math.max(current_pencil.pos.y - dt * current_pencil_speed, pencil_half_height);
        }
            // Move current pencil downward
        else if (pressing_down_key) {
            current_pencil.pos.y = Math.min(current_pencil.pos.y + dt * current_pencil_speed, Luxe.screen.h - pencil_half_height);
        }

            // Throw the pencil?
        if (just_pressed_space_key) {
                // Throw the pencil and use a new one
            use_new_pencil();
        }

            // Add paper?
        if (Luxe.utils.random.bool(0.01)) {
            add_paper();
        }

            // Update thrown pencils position
        for (thrown_pencil in thrown_pencils) {
            thrown_pencil.pos.x += dt * thrown_pencil_speed;

                // Remove pencils outside screen
            if (thrown_pencil.pos.x - pencil_half_width > Luxe.screen.w) {
                thrown_pencils.remove(thrown_pencil);
                thrown_pencil.destroy();
            }
        }

            // Update papers position
        for (paper in papers) {
            paper.pos.x -= dt * papers_speed;

                // Remove papers outside screen
            if (paper.pos.x + paper_half_width < 0) {
                papers.remove(paper);
                paper.destroy();
            }
        }

            // Detect collisions
        detect_collisions();

    } //update


    function detect_collisions() {
            // Update papers position
        for (paper in papers) {
                // Don't draw several times on the same paper
            if (paper.has_drawing) continue;

            var paper_shape = paper.shape;

            for (thrown_pencil in thrown_pencils) {
                var pencil_shape = thrown_pencil.shape;

                var collide_info = Collision.shapeWithShape(paper_shape, pencil_shape);
                if (collide_info != null) {
                        // Collision detected
                        // Draw on paper
                    paper.draw_on_paper(Std.int(Math.min(5, Math.floor(1 + Math.random() * 5))));

                        // And use drawing pencil
                    use_drawing_pencil(thrown_pencil);
                    break;
                }
            }
        }
    }


    override function onkeyup( e:KeyEvent ) {

        if (e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup


} //Main
