
/** A small 2-door cabinet to hold diamine ink bottles
 *
 */

include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

include <../opengrid/grid.scad>
use <../opengrid/grid_vars.scad>

_T = 0; _R = 1; _B = 2; _L = 3;
_W = 0; _H = 1;

clear = 0.1;

/* [Cabinet Tile Size] */
Center = [8, 8]; // keep this even numbers
Corner = [2, 2];

// Make the cabinet
explode = 5; // set =5 for printing
assembly();



module assembly() {
    thick = 2.4; // thickness of the walls
    // TODO: might want some clearance for the grid inside doors and back?
    
    //module grid() {}
    
    module asm_back() {
        //cab_back(thick=thick);
        /*
        color("black", 0.3)
        zmove(explode*thick) {
            move([ explode,  explode, 0])
                grid(6, 6, chamfers=[0,0,0,0], anchor=LEFT+FRONT+BOTTOM);
            move([-explode,  explode, 0])
                grid(6, 6, chamfers=[0,0,0,0], anchor=RIGHT+FRONT+BOTTOM);
            move([ explode, -explode, 0])
                grid(6, 6, chamfers=[0,0,0,0], anchor=LEFT+BACK+BOTTOM);
            move([-explode, -explode, 0])
                grid(6, 6, chamfers=[0,0,0,0], anchor=RIGHT+BACK+BOTTOM);
        }
        */
    }
    module asm_door() {
        // Right door
        cab_door(thick=thick, anchor=RIGHT, orient=BOT);
        /*
        zmove(-explode*thick)
        color("black", 0.3) {
            ymove( explode)
                grid(6, 6, chamfers=[0,0,0,0], anchor=LEFT+FRONT+BOTTOM);
            ymove(-explode)
                grid(6, 6, chamfers=[0,0,0,0], anchor=LEFT+BACK+BOTTOM);
        }
        */
    }
    
    zmove(-80)
      asm_back();
    zmove(80)
    xflip_copy()
        xmove(10)
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
    onlay=[0,0,0],
    anchor, spin, orient)
{
    echo(str("BOM piece(",
        "thick=", thick,
        ", edges=", edges,
        ", hinges=", hinges,
        ", pad=", pad,
        ", hinge_inner=", hinge_inner,
        ", onlay=", onlay,
        ");"));
    
    function any(elems) = sum(elems) > 0 ? 1 : 0;
    depth = Tile_Thickness + 7.5 * any(edges); // taken from /shelf:shelf.height, keep same as /cabinet:back.depth
    sizeW = Tile_Size * gridW + thick * (edges[_R] + edges[_L]) + pad[_W]; 
    sizeH = Tile_Size * gridH + thick * (edges[_T] + edges[_B]) + pad[_H];
    
    $fn=60;
    attachable(anchor, spin, orient, size=[sizeW, sizeH, thick+depth]) {
        zmove(-(thick+depth)/2)
        difference() {
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
                                          knuckle_diam=3, knuckle_clearance=0.2, pin_diam=1.8);
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
                                          knuckle_diam=3, knuckle_clearance=0.2, pin_diam=1.8);
                    } else {
                        cuboid([thick, sizeH, depth], anchor=BOT+LEFT);
                    }
                }
            }
            zmove(-clear/2)
            cuboid(onlay + [clear, clear, clear], anchor=BOT);
        }
        children();
    }
}
//piece(2, 2, edges=[1,1,0,1], hinges=[0,3,0,3], onlay=[50, 50, .1]);

    
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
                    hinges=[0,3,0,0])
            
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

            yflip_copy()
            ymove(grid_off( Center[_H]) + explode)
            piece(Corner[_W], Corner[_H], edges=[1,0,0,1], thick=thick, anchor=BOTTOM+FRONT+RIGHT,
                hinges=[0,0,0,3], hinge_inner=true, onlay=[55, 55, .2])
                position(CENTER+BOTTOM) orient(DOWN) zrot(-90)
                    corner_onlay(size=[55, 55, 1]);
        }        
        children();
    }
}

module corner_onlay(
    size = [70, 70, 5],
    anchor, spin, orient
) {
    echo(str("BOM corner_onlay(",
        "size=", size,
        ");"));
    
    attachable(anchor, spin, orient, size=size) {
        scale([size[0]/70, size[1]/70, size[2]/5])
        move([-34, -34, -1.5])
        union() {
            linear_extrude(height = 1)
            import(file="corner-onlay.svg", layer="gray0");
            
            linear_extrude(height = 2)
            import(file="corner-onlay.svg", layer="gray1");
            
            linear_extrude(height = 3)
            import(file="corner-onlay.svg", layer="gray2");
            
            linear_extrude(height = 4)
            import(file="corner-onlay.svg", layer="gray3");
            
            move([-1, -1, 0])
            cuboid([70, 70, 1], anchor=TOP+LEFT+FRONT);
        }
        children();
    }
}
//corner_onlay(size=[10, 10, 1]) show_anchors(s=1);

//thick=2.4;
//door(thick=thick, hinges=[0,1,0,0]);
