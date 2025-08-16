
/** A small 2-door cabinet to hold diamine ink bottles
 *
 */

include <BOSL2/std.scad>
include <../opengrid/grid.scad>
use <../opengrid/grid_vars.scad>

_T = 0; _R = 1; _B = 2; _L = 3;

module assembly() {
/*
    color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=LEFT+FRONT+BOTTOM);
    color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=RIGHT+FRONT+BOTTOM);
    color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=LEFT+BACK+BOTTOM);
    color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=RIGHT+BACK+BOTTOM);
*/
    back() show_anchors();
    // TODO: you have to make the back assembly a tiny bit larger
    //       to account for the inner edges on the front doors
    //       e.g. center tile not exactly square
    //            top and bottom edges a bit longer
    // TODO: consider how to connect the pieces together
}

function any(elems) = sum(elems) > 0 ? 1 : 0;

// TODO: add a hinge to the piece!
// TODO: add a magnet socket
module piece(gridW, gridH, edges=[0,0,0,0], anchor, spin, orient) {
    thick = 2.5; // keep same as /cabinet:back.thick
    depth = Tile_Thickness + 7.5 * any(edges); // taken from /shelf:shelf.height, keep same as /cabinet:back.depth
    sizeW = Tile_Size * gridW + thick * (edges[_R] + edges[_L]);
    sizeH = Tile_Size * gridH + thick * (edges[_T] + edges[_B]);
    
    attachable(anchor, spin, orient, size=[sizeW, sizeH, thick+depth]) {
        zmove(-(thick+depth)/2)
        union() {
            cuboid([sizeW, sizeH, thick], anchor=BOT);
            if (edges[_T]) {
                move([0, sizeH/2, thick])
                cuboid([sizeW, thick, depth], anchor=BOT+BACK);
            }
            if (edges[_R]) {
                move([sizeW/2, 0, thick])
                cuboid([thick, sizeH, depth], anchor=BOT+RIGHT);
            }
            if (edges[_B]) {
                move([0, -sizeH/2, thick])
                cuboid([sizeW, thick, depth], anchor=BOT+FRONT);
            }
            if (edges[_L]) {
                move([-sizeW/2, 0, thick])
                cuboid([thick, sizeH, depth], anchor=BOT+LEFT);
            }
        }
        children();
    }
}

function grid_off(n) = (n * Tile_Size) / 2;

module back(anchor, spin, orient) {
    // TODO: how to access the size of inner pieces?
    thick = 2.5; // keep same as /cabinet:piece.thick
    depth = Tile_Thickness + 7.5; // keep same as /cabinet:piece.depth
    
    sizeW = 12 * Tile_Size + 2 * thick;
    sizeH = 12 * Tile_Size + 2 * thick;
    sizeZ = thick + depth;
    
    attachable(anchor, spin, orient, size=[sizeW, sizeH, sizeZ]) {
        zmove(-sizeZ/2)
        union() {
            // center
            piece(6, 6, edges=[0,0,0,0], anchor=BOTTOM);
            // edges
            xmove(grid_off(-6))
                piece(3, 6, edges=[0,0,0,1], anchor=RIGHT+BOTTOM);
            xmove(grid_off(6))
                piece(3, 6, edges=[0,1,0,0], anchor=LEFT+BOTTOM);
            ymove(grid_off(6))
                piece(6, 3, edges=[1,0,0,0], anchor=FRONT+BOTTOM);
            ymove(grid_off(-6))
                piece(6, 3, edges=[0,0,1,0], anchor=BACK+BOTTOM);
            // corners
            move([grid_off(6), grid_off(6), 0])
                piece(3, 3, edges=[1,1,0,0], anchor=FRONT+LEFT+BOTTOM);
            move([grid_off(6), grid_off(-6), 0])
                piece(3, 3, edges=[0,1,1,0], anchor=BACK+LEFT+BOTTOM);
            move([grid_off(-6), grid_off(-6), 0])
                piece(3, 3, edges=[0,0,1,1], anchor=BACK+RIGHT+BOTTOM);
            move([grid_off(-6), grid_off(6), 0])
                piece(3, 3, edges=[1,0,0,1], anchor=FRONT+RIGHT+BOTTOM);
        }
        children();
    }
}

assembly();
