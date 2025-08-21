
/** A small 2-door cabinet to hold diamine ink bottles
 *
 */

include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

include <../opengrid/grid.scad>
use <../opengrid/grid_vars.scad>

_T = 0; _R = 1; _B = 2; _L = 3;
_W = 0; _H = 1;

/* [Cabinet Tile Size] */
Center = [8, 8]; // keep this even numbers
Corner = [2, 2];

// Make the cabinet
explode = 0; // set =5 for printing
assembly();


module assembly() {
    thick = 2.4; // thickness of the walls
    // TODO: might want some clearance for the grid inside doors and back?
    
    //module grid() {}
    
    module asm_back() {
        cab_back(thick=thick);
        /*
        color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=LEFT+FRONT+BOTTOM);
        color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=RIGHT+FRONT+BOTTOM);
        color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=LEFT+BACK+BOTTOM);
        color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=RIGHT+BACK+BOTTOM);
        */
    }
    module asm_door() {
        // Right door
        cab_door(thick=thick, anchor=RIGHT, orient=BOT);
        /*
        xmove(thick) color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=LEFT+FRONT+BOTTOM);
        xmove(thick) color("black", 0.3) grid(6, 6, chamfers=[0,0,0,0], anchor=LEFT+BACK+BOTTOM);
        */
    }
    
    zmove(-8)
      asm_back();
    zmove(8)
    xflip_copy()
        asm_door();
    
    // Left door
    //zmove(28) door(anchor=LEFT);
    // TODO: consider how to connect the pieces together
}

function grid_off(n) = (n * Tile_Size) / 2;

// TODO: add a hinge to the piece!
// TODO: add a magnet socket
module piece(gridW, gridH, 
    thick=2.4,
    edges=[0,0,0,0],
    hinges=[0,0,0,0],
    pad=[0,0],
    hinge_inner=false,
    anchor, spin, orient)
{
    function any(elems) = sum(elems) > 0 ? 1 : 0;
    depth = Tile_Thickness + 7.5 * any(edges); // taken from /shelf:shelf.height, keep same as /cabinet:back.depth
    sizeW = Tile_Size * gridW + thick * (edges[_R] + edges[_L]) + pad[_W]; 
    sizeH = Tile_Size * gridH + thick * (edges[_T] + edges[_B]) + pad[_H];
    
    $fn=60;
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
                if (hinges[_R] > 0) {
                    diff()
                    cuboid([thick, sizeH, depth], anchor=BOT+RIGHT)
                        position(TOP+RIGHT) orient(anchor=RIGHT) zmove(-0.6)                        
                        knuckle_hinge(length=sizeH, segs=hinges[_R], inner=hinge_inner,
                                      offset=1.6, arm_height=1, teardrop=true,
                                      knuckle_diam=3, knuckle_clearance=0.2);
                } else {
                    cuboid([thick, sizeH, depth], anchor=BOT+RIGHT);
                }
            }
            if (edges[_B]) {
                move([0, -sizeH/2, thick])
                cuboid([sizeW, thick, depth], anchor=BOT+FRONT);
            }
            if (edges[_L]) {
                move([-sizeW/2, 0, thick])
                if (hinges[_L] > 0) {
                    diff()
                    cuboid([thick, sizeH, depth], anchor=BOT+LEFT)
                        position(TOP+LEFT) orient(anchor=LEFT) zmove(-0.6)                        
                        knuckle_hinge(length=sizeH, segs=hinges[_L], inner=hinge_inner,
                                      offset=1.6, arm_height=1, teardrop=true,
                                      knuckle_diam=3, knuckle_clearance=0.2);
                } else {
                    cuboid([thick, sizeH, depth], anchor=BOT+LEFT);
                }
            }
        }
        children();
    }
}
//piece(2, 3, edges=[0,1,0,1], hinges=[0,3,0,3]);

    
// TODO: add clearance for the grid?
module cab_back(
    thick=2.4,
    anchor, spin, orient
) {
    depth = Tile_Thickness + 7.5; // keep same as /cabinet:piece.depth
    pad = [2 * thick + .25, 0]; // padding for the front doors
       
    sizeW = (Center[_W] + 2*Corner[_W]) * Tile_Size + 2 * thick + pad[_W];
    sizeH = (Center[_H] + 2*Corner[_H]) * Tile_Size + 2 * thick + pad[_H];
    sizeZ = thick + depth;
    
    function offW(n) = grid_off(n) + sign(n) * pad[_W]/2;
    function offH(n) = grid_off(n) + sign(n) * pad[_H]/2;
    
    attachable(anchor, spin, orient, size=[sizeW, sizeH, sizeZ]) {
        zmove(-sizeZ/2)
        union() {
            // center
            piece(Center[_W], Center[_H], edges=[0,0,0,0], thick=thick, pad=pad, anchor=BOTTOM);
            
            // edges
            xflip_copy()
                xmove(offW( Center[_W]) + explode)
                piece(Corner[_W], Center[_H], edges=[0,1,0,0], thick=thick, anchor=LEFT+BOTTOM,
                    hinges=[0,11,0,0], hinge_inner=true);
            
            ymove(offH( Center[_H]) + explode)
            piece(Center[_W], Corner[_H], edges=[1,0,0,0], thick=thick, pad=pad, anchor=FRONT+BOTTOM);
            
            ymove(offH(-Center[_H]) - explode)
            piece(Center[_W], Corner[_H], edges=[0,0,1,0], thick=thick, pad=pad, anchor=BACK+BOTTOM);
                
            // corners
            xflip_copy()
                move([offW( Center[_W]) + explode, offH( Center[_H]) + explode, 0])
                piece(Corner[_W], Corner[_H], edges=[1,1,0,0], thick=thick, anchor=FRONT+LEFT+BOTTOM,
                    hinges=[0,3,0,0]);
            
            xflip_copy()
                move([offW( Center[_W]) + explode, offH(-Center[_H]) - explode, 0])
                piece(Corner[_W], Corner[_H], edges=[0,1,1,0], thick=thick, anchor=BACK+LEFT+BOTTOM,
                    hinges=[0,3,0,0]);
        }
        children();
    }
}


module cab_door(
    thick=2.4,
    hinges=[0,0,0,0],
    anchor, spin, orient
) {
    depth = Tile_Thickness + 7.5; // keep same as /cabinet:piece.depth
    
    sizeW = (Center[_W]/2 + Corner[_W]) * Tile_Size + 2 * thick;
    sizeH = (Center[_H] + 2*Corner[_H]) * Tile_Size + 2 * thick;
    sizeZ = thick + depth;
    
    sideR = Center[_W]/2 * Tile_Size + thick;

    attachable(anchor, spin, orient, size=[sizeW, sizeH, sizeZ]) {
        zmove(-sizeZ/2)
        xmove((Corner[_W]-Center[_W]/2)/2 * Tile_Size)
        union() {
            difference() {
                union() {
                    // center-side
                    xmove(explode)
                    piece(Center[_W]/2, Center[_H], edges=[0,1,0,0], thick=thick, anchor=BOTTOM+LEFT);
                    
                    xmove(explode)
                    ymove(grid_off( Center[_H]) + explode)
                    piece(Center[_W]/2, Corner[_H], edges=[1,1,0,0], thick=thick, anchor=BOTTOM+FRONT+LEFT);
                    
                    xmove(explode)
                    ymove(grid_off(-Center[_H]) - explode)
                    piece(Center[_W]/2, Corner[_H], edges=[0,1,1,0], thick=thick, anchor=BOTTOM+BACK+LEFT);
                    
                    // edge-side
                    piece(Corner[_W], Center[_H], edges=[0,0,0,1], thick=thick, anchor=BOTTOM+RIGHT,
                        hinges=[0,0,0,11]);
                    
                    ymove(grid_off( Center[_H]) + explode)
                    piece(Corner[_W], Corner[_H], edges=[1,0,0,1], thick=thick, anchor=BOTTOM+FRONT+RIGHT,
                        hinges=[0,0,0,3], hinge_inner=true);
                    
                    ymove(grid_off(-Center[_H]) - explode)
                    piece(Corner[_W], Corner[_H], edges=[0,0,1,1], thick=thick, anchor=BOTTOM+BACK+RIGHT,
                        hinges=[0,0,0,3], hinge_inner=true);
                    }
                }
        }
        
        children();
    }
}

//thick=2.4;
//door(thick=thick, hinges=[0,1,0,0]);
