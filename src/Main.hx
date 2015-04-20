import luxe.Input;
import luxe.Color;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Sprite;
import luxe.Vector;
import luxe.Visual;
import phoenix.Texture;
import snow.system.input.Keycodes;

import sprites.*;

import luxe.collision.shapes.*;
import luxe.collision.Collision;

import luxe.tween.Actuate;

import phoenix.geometry.TextGeometry;
import phoenix.geometry.Geometry;

class Main extends luxe.Game {

    var pressing_up_key: Bool;
    var pressing_down_key: Bool;
    var just_pressed_space_key: Bool;

    var current_pencil: Pencil;
    var current_pencil_speed: Float = 240.0 * 1.5;
    var current_pencil_initial_x: Float = -100;
    var current_pencil_final_x: Float = 0;

    var drawing_pencil_delay: Float = 0.1;

    var thrown_pencils: Array<Pencil> = [];
    var thrown_pencil_speed: Float = 240.0 * 1;

    var paper_half_width: Float = 250.0;
    var papers_speed: Float = 200.0 * 1;
    var papers: Array<Paper> = [];
    var last_paper_sub_depth: Float = 0.0;
    var next_paper_on_same_row_delay: Float = 5.0;
    var new_paper_frequency: Float = 0.025;

    var pencil_half_width: Float = 100;
    var pencil_half_height: Float = 10;

    var used_paper_rows: Map<Int,Bool> = new Map<Int,Bool>();

    var background1: Sprite;
    var background2: Sprite;

    var score: Int = 0;
    var score_visual: TextGeometry;

    var introduction_visual: Sprite;
    var game_over_visual: Sprite;
    var game_over_box: Visual;

    var game_is_started: Bool = false;
    var game_is_over: Bool = false;

    var level: Int = 0;

    override function ready() {
            // Init preload
        var preload = new Parcel();

            // Preload textures
        preload.add_texture("assets/censored.png");
        preload.add_texture("assets/censored_intro.png");
        preload.add_texture("assets/drawing_1.png");
        preload.add_texture("assets/drawing_2.png");
        preload.add_texture("assets/drawing_3.png");
        preload.add_texture("assets/drawing_4.png");
        preload.add_texture("assets/drawing_5.png");
        preload.add_texture("assets/paper.png");
        preload.add_texture("assets/pencil_default.png");
        preload.add_texture("assets/pencil_writing.png");
        preload.add_texture("assets/background.png");
        preload.add_texture("assets/game_over.png");

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
            // Connect input
        connect_input();
            // Initialize scene
        init_scene();

    } //assets_loaded


    function init_scene() {
        Luxe.loadTexture("assets/background.png").filter = FilterType.nearest;

            // Create background
        background1 = new Sprite({
            pos:        Luxe.screen.mid,
            texture:    Luxe.loadTexture("assets/background.png"),
            depth:      1.0001
        });
        background2 = new Sprite({
            pos:        new Vector(Luxe.screen.mid.x + Luxe.screen.w * 0.5, Luxe.screen.mid.y),
            texture:    Luxe.loadTexture("assets/background.png"),
            depth:      1.0002
        });

            // Increase speed every 10 second
        Luxe.timer.schedule(10, function() {
            if (level < 14) {
                current_pencil_speed *= 1.1;
                thrown_pencil_speed *= 1.1;
                papers_speed *= 1.1;
                new_paper_frequency *= 1.1;
                drawing_pencil_delay /= 1.1;
                next_paper_on_same_row_delay /= 1.1;
                level++;
            }
        }, true);

            // Create first pencil
        use_new_pencil();

            // Display intro
        introduction_visual = new Sprite({
            texture:    Luxe.loadTexture("assets/censored_intro.png"),
            pos:        Luxe.screen.mid,
            depth:      6
        });

    } //init_scene


    function create_menu() {
            // Create menu
        Luxe.draw.box({
            w:      Luxe.screen.w,
            h:      40,
            pos:    new Vector(0,0),
            color:  new Color(0,0,0,0.25),
            depth:  4.001
        });
        update_score_visual();

    } //create_menu


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


    function use_drawing_pencil(thrown_pencil:Pencil, paper:Paper) {
            // Get thrown pencil position
        var pos = thrown_pencil.pos;
            // Ajust position from sprite change
        pos.y = paper.pos.y - 35;

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

        var step = 0.3 / drawing_pencil_delay;
        var delay = drawing_pencil_delay;

        Actuate.timer(delay).onUpdate(function() {
            drawing_pencil.pos.y += step;
        }).onComplete(function() {
            Actuate.timer(delay).onUpdate(function() {
                drawing_pencil.pos.y -= step;
            }).onComplete(function() {
                Actuate.timer(delay).onUpdate(function() {
                    drawing_pencil.pos.y += step;
                }).onComplete(function() {
                    Actuate.timer(delay).onUpdate(function() {
                        drawing_pencil.pos.y -= step;
                    }).onComplete(function() {
                        Actuate.tween(drawing_pencil.color, delay * 2.5, {a: 0}).onComplete(function() {
                            drawing_pencil.destroy();
                        });
                    });
                });
            });
        });

    } //use_drawing_pencil


    function update_score_visual() {

        if (score_visual != null) {
            score_visual.text = ("score: " + score);
        }
        else {
            score_visual = Luxe.draw.text({
                text: ("score: " + score),
                point_size: 16,
                depth: 4.002,
                pos: new Vector(9, 9)
            });
        }

    } //update_score_visual


    function add_paper() {

            // Compute the best row
        var row:Int = Math.floor(Math.random() * 4.99999);
        var number_of_used_rows:Int = 0;
        for (key in used_paper_rows) {
            number_of_used_rows++;
        }
        if (number_of_used_rows >= 5) return;
        while (used_paper_rows.exists(row)) {
            row = Math.round(Math.random() * 4.99999);
        }
        used_paper_rows.set(row, true);
        Luxe.timer.schedule(next_paper_on_same_row_delay, function() {
            used_paper_rows.remove(row);
        });

            // Create paper
        var paper = new Paper({
            pos:        new Vector(Luxe.screen.w + paper_half_width, Math.round(Luxe.screen.h * 0.2 + Luxe.screen.h * 0.7 * row / 5.0)),
            depth:      2 + last_paper_sub_depth,
            rotation_z: Math.round(Luxe.utils.random.float(-90, 90)),
            censored:   (Math.random() > 0.25)
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


    function start_game() {
        create_menu();
        introduction_visual.destroy();
        game_is_started = true;
    }


    function restart_game() {
            // Cleanup
        for (paper in papers) {
            paper.destroy();
        }
        papers = [];
        for (pencil in thrown_pencils) {
            pencil.destroy();
        }
        thrown_pencils = [];
        current_pencil_speed = 240.0 * 1.5;
        thrown_pencil_speed = 240.0 * 1;
        papers_speed = 200.0 * 1;
        new_paper_frequency = 0.025;
        drawing_pencil_delay = 0.1;
        next_paper_on_same_row_delay = 5.0;
        level = 0;

        game_over_visual.destroy();
        game_over_box.destroy();

            // Start again
        game_is_over = false;
        game_is_started = true;

        score = 0;
        update_score_visual();

    }


    function game_over() {
        game_over_box = new Visual({
            color:      new Color(0.5,0,0,0.2),
            size:       new Vector(Luxe.screen.w, Luxe.screen.h),
            pos:        new Vector(0, 0),
            depth:      7.0001,
        });

        Luxe.loadTexture("assets/game_over.png").filter = FilterType.nearest;
        game_over_visual = new Sprite({
            texture:    Luxe.loadTexture("assets/game_over.png"),
            pos:        Luxe.screen.mid,
            depth:      7.0002
        });

        game_is_over = true;
    }


    override function update(dt:Float) {

            // Let's not do something silly. Be patient.
        if (current_pencil == null) return;
        if (!game_is_started) {
            if (Luxe.input.inputpressed('space')) {
                start_game();
            }
            return;
        }
        else if (game_is_over) {
            if (Luxe.input.inputpressed('space')) {
                restart_game();
            }
            return;
        }

            // If the current pencil is not at it's final X position,
            // just move it a bit more to the right
        if (current_pencil.pos.x < current_pencil_final_x) {
                // Update X
            current_pencil.pos.x = Math.min(current_pencil.pos.x + dt * thrown_pencil_speed, current_pencil_final_x);

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
        if (Math.random() < new_paper_frequency) {
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
            if (!paper.censored && !paper.has_drawing) {
                    // Game over it it was a free paper
                if (paper.pos.x + paper_half_width * 0.25 < 0) {
                    game_over();
                    return;
                }
            } else {
                if (paper.pos.x + paper_half_width < 0) {
                    papers.remove(paper);
                    paper.destroy();
                }
            }
        }

            // Update background position
        background1.pos.x -= dt * papers_speed;
        background2.pos.x -= dt * papers_speed;
        if (background1.pos.x < 0) {
            background1.pos.x += Luxe.screen.w;
        }
        if (background2.pos.x < 0) {
            background2.pos.x += Luxe.screen.w;
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

                    if (paper.censored) {
                            // Game over
                        game_over();
                        return;
                    }
                    else {
                            // Collision detected
                            // Draw on paper
                        paper.draw_on_paper(Std.int(Math.min(5, Math.floor(1 + Math.random() * 5))));

                            // And use drawing pencil
                        use_drawing_pencil(thrown_pencil, paper);

                            // Update score
                        score++;
                        update_score_visual();

                        break;
                    }
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
