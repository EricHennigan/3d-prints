
/** A small 2-door cabinet to hold diamine ink bottles
 *
 */

include <BOSL2/std.scad>
include <../opengrid/grid.scad>
use <../opengrid/grid_vars.scad>

_T = 0; _R = 1; _B = 2; _L = 3;
_W = 0; _H = 1;

module assembly() {
/*
    color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=LEFT+FRONT+BOTTOM);
    color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=RIGHT+FRONT+BOTTOM);
    color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=LEFT+BACK+BOTTOM);
    color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=RIGHT+BACK+BOTTOM);
*/
    zmove(-28) back();
    // TODO: consider how to connect the pieces together
}

function any(elems) = sum(elems) > 0 ? 1 : 0;

// TODO: add a hinge to the piece!
// TODO: add a magnet socket
module piece(gridW, gridH, edges=[0,0,0,0], pad=[0,0], anchor, spin, orient) {
    thick = 2.5; // keep same as /cabinet:back.thick
    depth = Tile_Thickness + 7.5 * any(edges); // taken from /shelf:shelf.height, keep same as /cabinet:back.depth
    sizeW = Tile_Size * gridW + thick * (edges[_R] + edges[_L]) + pad[_W]; 
    sizeH = Tile_Size * gridH + thick * (edges[_T] + edges[_B]) + pad[_H];
    
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
    pad = [2 * thick + .25, 0]; // padding for the front doors
    
    sizeW = 12 * Tile_Size + 2 * thick + pad[_W];
    sizeH = 12 * Tile_Size + 2 * thick + pad[_H];
    sizeZ = thick + depth;
    
    function offW(n) = grid_off(n) + sign(n) * pad[_W]/2;
    function offH(n) = grid_off(n) + sign(n) * pad[_H]/2;
    
    attachable(anchor, spin, orient, size=[sizeW, sizeH, sizeZ]) {
        zmove(-sizeZ/2)
        union() {
            // center
            piece(6, 6, edges=[0,0,0,0], pad=pad, anchor=BOTTOM);
            
            // edges
            xmove(offW(-6)) piece(3, 6, edges=[0,0,0,1], anchor=RIGHT+BOTTOM);
            xmove(offW( 6)) piece(3, 6, edges=[0,1,0,0], anchor=LEFT+BOTTOM);
            ymove(offH( 6)) piece(6, 3, edges=[1,0,0,0], pad=pad, anchor=FRONT+BOTTOM);
            ymove(offH(-6)) piece(6, 3, edges=[0,0,1,0], pad=pad, anchor=BACK+BOTTOM);
                
            // corners
            move([offW( 6), offH( 6), 0]) piece(3, 3, edges=[1,1,0,0], anchor=FRONT+LEFT+BOTTOM);
            move([offW( 6), offH(-6), 0]) piece(3, 3, edges=[0,1,1,0], anchor=BACK+LEFT+BOTTOM);
            move([offW(-6), offH(-6), 0]) piece(3, 3, edges=[0,0,1,1], anchor=BACK+RIGHT+BOTTOM);
            move([offW(-6), offH( 6), 0]) piece(3, 3, edges=[1,0,0,1], anchor=FRONT+RIGHT+BOTTOM);
        }
        children();
    }
}

assembly();
