
/** A small 2-door cabinet to hold diamine ink bottles
 *
 */

include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

include <../opengrid/grid.scad>
use <../opengrid/grid_vars.scad>
use <../opengrid/connectors.scad>

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
    
    module asm_back() {
        pad = [0, (thick + .12)/2, 0, (thick + .12)/2];
        cab_back(thick=thick);
        zmove(Tile_Size * 1.2 * (explode > 1 ? 1 : 0)) {
            move([ explode,  explode, 0])
                grid(6, 6, chamfers=[0,0,0,0], pad=pad, anchor=LEFT+FRONT+BOTTOM);
            move([-explode,  explode, 0])
                grid(6, 6, chamfers=[0,0,0,0], pad=pad, anchor=RIGHT+FRONT+BOTTOM);
            move([ explode, -explode, 0])
                grid(6, 6, chamfers=[0,0,0,0], pad=pad, anchor=LEFT+BACK+BOTTOM);
            move([-explode, -explode, 0])
                grid(6, 6, chamfers=[0,0,0,0], pad=pad, anchor=RIGHT+BACK+BOTTOM);
        }
    }
    
    module asm_door() {
        xmove(400)
        xrot(180)
        xflip_copy()
            xmove(10)
            cab_door(thick=thick, anchor=RIGHT, orient=BOT);
    }

    asm_back();
    asm_door();
    
    xmove(-200) ymove(-10) butterfly();
    xmove(-200) ymove(10) lite_connector();
}

function grid_off(n) = (n * Tile_Size) / 2;

module butterfly(
  thick=2.4-.5,
  cut=false,
  anchor, spin, orient)
{
    clearance = 0.2 * (cut ? 1 : 0);
    attachable(anchor, spin, orient, size=[15, 10, thick+clearance]) {
        union() {
            cuboid([10, 5+clearance*2, thick+clearance]);
            xmove(5)
                cuboid([5+clearance, 10+clearance*2, thick+clearance],
                       chamfer=2.5, edges=[FWD+LEFT, BACK+LEFT]);
            xflip()
            xmove(5)
                cuboid([5+clearance, 10+clearance*2, thick+clearance],
                       chamfer=2.5, edges=[FWD+LEFT, BACK+LEFT]);
        }
        children();
    }
}
//butterfly() show_anchors(s=1);
//butterfly(cut=true);

module piece(gridW, gridH, 
    thick=2.4,
    edges=[0,0,0,0],
    hinges=[0,0,0,0],
    pad=[0,0],
    hinge_inner=false,
    magnets=[0,0,0,0],
    butterfly=[0,0,0,0],
    anchor, spin, orient)
{
    echo(str("BOM piece(",
        gridW, ", ",
        gridH, ", ",
        "thick=", thick,
        ", edges=", edges,
        ", hinges=", hinges,
        ", pad=", pad,
        ", hinge_inner=", hinge_inner,
        ", magnets=", magnets,
        ");"));
    
    function any(elems) = sum(elems) > 0 ? 1 : 0;
    depth = (Tile_Size + Tile_Thickness + 1) * any(edges); // keep same as /cabinet:cab_back.depth, /cabinet:cab_front.depth
    sizeW = Tile_Size * gridW + thick * (edges[_R] + edges[_L]) + pad[_W]; 
    sizeH = Tile_Size * gridH + thick * (edges[_T] + edges[_B]) + pad[_H];
    echo("piece size: ", sizeW, sizeH);
    
    $fn=60;
    attachable(anchor, spin, orient, size=[sizeW, sizeH, thick+depth]) {
        zmove(-(thick+depth)/2)
        difference() {
            union() {
                cuboid([sizeW, sizeH, thick+trim], anchor=BOT, chamfer=0.2, edges=BOT);
                if (edges[_T]) {
                    w = sizeW - (thick-trim) * (edges[_R] + edges[_L]);
                    move([thick/2 * (edges[_L] - edges[_R]), sizeH/2, thick])
                    cuboid([w, thick, depth], anchor=BOT+BACK);
                    // TODO: add a hinge on this wall
                }
                if (edges[_R]) {
                    move([sizeW/2, 0, thick])
                    if (hinges[_R] > 0) {
                        diff()
                        cuboid([thick, sizeH, depth], anchor=BOT+RIGHT)
                            position(TOP+RIGHT) orient(anchor=RIGHT) zmove(-0.6)
                            knuckle_hinge(length=sizeH, segs=hinges[_R], inner=hinge_inner,
                                          offset=1.6, arm_height=1, teardrop=true,
                                          knuckle_diam=3, knuckle_clearance=0.2, pin_diam=1.85);
                    } else {
                        cuboid([thick, sizeH, depth], anchor=BOT+RIGHT);
                    }
                }
                // TODO: adjust the size of this wall, so not interfere with hinge, see edges[_T]
                if (edges[_B]) {
                    move([0, -sizeH/2, thick])
                    cuboid([sizeW, thick, depth], anchor=BOT+FRONT);
                    // TODO: add a hinge on this wall
                }
                if (edges[_L]) {
                    move([-sizeW/2, 0, thick])
                    if (hinges[_L] > 0) {
                        diff()
                        cuboid([thick, sizeH, depth], anchor=BOT+LEFT)
                            position(TOP+LEFT) orient(anchor=LEFT) zmove(-0.6)
                            knuckle_hinge(length=sizeH, segs=hinges[_L], inner=hinge_inner,
                                          offset=1.6, arm_height=1, teardrop=true,
                                          knuckle_diam=3, knuckle_clearance=0.2, pin_diam=1.85);
                    } else {
                        cuboid([thick, sizeH, depth], anchor=BOT+LEFT);
                    }
                }
            }
            
            // Cut out a recess for the LiteThickness grid
            move([(edges[_L]-edges[_R])*thick/2, (edges[_B]-edges[_T])*thick/2, thick])
            cuboid([Tile_Size * gridW + pad[_W] + .2, Tile_Size * gridH + pad[_H] + .2, 4.0 + .4],
                chamfer=.1, edges=TOP, anchor=BOTTOM);
                
            // Cut out a butterfly connector to join adjacent panels
            if (edges[_T]) {
                move([sizeW/2, sizeH/2-thick-trim, depth/2])
                    butterfly(anchor=TOP, orient=FWD, spin=0, cut=true);
                move([-sizeW/2, sizeH/2-thick-trim, depth/2])
                    butterfly(anchor=TOP, orient=FWD, spin=0, cut=true);
            }
            if (edges[_R]) {
                move([sizeW/2-thick-trim, sizeH/2, depth/2])
                    butterfly(anchor=TOP, orient=LEFT, spin=90, cut=true);
                move([sizeW/2-thick-trim, -sizeH/2, depth/2])
                    butterfly(anchor=TOP, orient=LEFT, spin=90, cut=true);
            }
            if (edges[_B]) {
                move([sizeW/2, -sizeH/2+thick+trim, depth/2])
                    butterfly(anchor=BOT, orient=FWD, spin=0, cut=true);
                move([-sizeW/2, -sizeH/2+thick+trim, depth/2])
                    butterfly(anchor=BOT, orient=FWD, spin=0, cut=true);
            }
            if (edges[_L]) {
                move([-sizeW/2+thick+trim, sizeH/2, depth/2])
                    butterfly(anchor=BOT, orient=LEFT, spin=90, cut=true);
                move([-sizeW/2+thick+trim, -sizeH/2, depth/2])
                    butterfly(anchor=BOT, orient=LEFT, spin=90, cut=true);
            }
            if (butterfly[_T]) {
                xcopies(spacing=sizeW/butterfly[_T], n=butterfly[_T])
                    move([0, sizeH/2, thick+trim])
                    butterfly(anchor=TOP, spin=90, cut=true);
            }
            if (butterfly[_R]) {
                ycopies(spacing=sizeH/butterfly[_R], n=butterfly[_R])
                    move([sizeW/2, 0, thick+trim])
                    butterfly(anchor=TOP, cut=true);
            }
            if (butterfly[_B]) {
                xcopies(spacing=sizeW/butterfly[_B], n=butterfly[_B])
                    move([0, -sizeH/2, thick+trim])
                    butterfly(anchor=TOP, spin=90, cut=true);
            }
            if (butterfly[_L]) {
                ycopies(spacing=sizeH/butterfly[_L], n=butterfly[_L])
                    move([-sizeW/2, 0, thick+trim])
                    butterfly(anchor=TOP, cut=true);
            }
            
            if (magnets[_T] > 0) {
                ymove(sizeH/2 + trim)
                zmove(thick)
                xcopies(spacing=sizeW/magnets[_T], n=magnets[_T])
                    teardrop(h=1.2, d=8+clear/2, anchor=BOT+BACK, ang=60);
            }
            if (magnets[_R] > 0) {
                zrot(-90)
                ymove(sizeW/2 + trim)
                zmove(thick)
                xcopies(spacing=sizeH/magnets[_R], n=magnets[_R])
                    teardrop(h=1.2, d=8+clear/2, anchor=BOT+BACK, ang=60);
            }
            if (magnets[_B] > 0) {
                ymove(-sizeH/2 - trim)
                zmove(thick)
                xcopies(spacing=sizeW/magnets[_B], n=magnets[_B])
                    teardrop(h=1.2, d=8+clear/2, anchor=BOT+FRONT, ang=60);

            }
            if (magnets[_L] > 0) {
                zrot(90)
                ymove(sizeW/2 + trim)
                zmove(thick)
                xcopies(spacing=sizeH/magnets[_L], n=magnets[_L])
                    teardrop(h=1.2, d=8+clear/2, anchor=BOT+BACK, ang=60);
            }
        }
        children();
    }
}
//piece(2, 3, thick=2.4, edges=[0, 0, 0, 1], hinges=[0, 0, 0, 3], pad=[0, 0], hinge_inner=true, magnets=[0,2,3,4], butterfly=[4,2,3,1]);



    
// TODO: add clearance for the grid?
module cab_back(
    thick=2.4,
    anchor, spin, orient
) {
    depth = Tile_Size + Tile_Thickness + 1; // keep same as /cabinet:piece.depth, /cabinet:cab_front.depth
    pad = [2 * thick + .24, 0]; // padding for the front doors
       
    sizeW = (Center[_W] + 2*Corner[_W]) * Tile_Size + 2 * thick + pad[_W];
    sizeH = (Center[_H] + 2*Corner[_H]) * Tile_Size + 2 * thick + pad[_H];
    sizeZ = thick + depth;
    
    echo("cab_back internal size", sizeW - 2*thick, sizeH - 2*thick);
    echo("cab_back external size", sizeW, sizeH);
    
    function offW(n) = grid_off(n) + sign(n) * pad[_W]/2;
    function offH(n) = grid_off(n) + sign(n) * pad[_H]/2;
    
    attachable(anchor, spin, orient, size=[sizeW, sizeH, sizeZ]) {
        zmove(-sizeZ/2)
        union() {
            // center
            piece(Center[_W], Center[_H], edges=[0,0,0,0], thick=thick, pad=pad, anchor=BOTTOM,
                butterfly=[5,5,5,5]);

            // edges
            xflip_copy()
                xmove(offW( Center[_W]) + explode)
                piece(Corner[_W], Center[_H], edges=[0,1,0,0], thick=thick, anchor=LEFT+BOTTOM,
                    hinges=[0,11,0,0], hinge_inner=true, butterfly=[2,0,2,5]);
            
            ymove(offH( Center[_H]) + explode)
            piece(Center[_W], Corner[_H], edges=[1,0,0,0], thick=thick, pad=pad, anchor=FRONT+BOTTOM,
                butterfly=[0,2,5,2]);
            
            ymove(offH(-Center[_H]) - explode)
            piece(Center[_W], Corner[_H], edges=[0,0,1,0], thick=thick, pad=pad, anchor=BACK+BOTTOM,
                butterfly=[5,2,0,2]);
                
            // corners
            xflip_copy()
                move([offW( Center[_W]) + explode, offH( Center[_H]) + explode, 0])
                piece(Corner[_W], Corner[_H], edges=[1,1,0,0], thick=thick, anchor=FRONT+LEFT+BOTTOM,
                    hinges=[0,3,0,0], butterfly=[0,0,2,2]);
            
            xflip_copy()
                move([offW( Center[_W]) + explode, offH(-Center[_H]) - explode, 0])
                piece(Corner[_W], Corner[_H], edges=[0,1,1,0], thick=thick, anchor=BACK+LEFT+BOTTOM,
                    hinges=[0,3,0,0], butterfly=[2,0,0,2]);
        }
        children();
    }
}
//cab_back();


module cab_door(
    thick=2.4,
    hinges=[0,0,0,0],
    anchor, spin, orient
) {
    depth = Tile_Size + Tile_Thickness + 1; // keep same as /cabinet:piece.depth, /cabinet:cab_back.depth
    
    sizeW = (Center[_W]/2 + Corner[_W]) * Tile_Size + 2 * thick;
    sizeH = (Center[_H] + 2*Corner[_H]) * Tile_Size + 2 * thick;
    sizeZ = thick + depth;
    
    echo("cab_door internal size", sizeW - 2*thick, sizeH - 2*thick);
    echo("cab_door external size", sizeW, sizeH);
    
    sideR = Center[_W]/2 * Tile_Size + thick;

    attachable(anchor, spin, orient, size=[sizeW, sizeH, sizeZ]) {
        zmove(-sizeZ/2)
        xmove((Corner[_W]-Center[_W]/2)/2 * Tile_Size)
        union() {
            // center-side
            xmove(explode) {
                difference() {
                    piece(Center[_W]/2, Center[_H], edges=[0,1,0,0], thick=thick, anchor=BOTTOM+LEFT,
                        magnets=[0,5,0,0], butterfly=[3,0,3,5]);
                    
                    ymove(-6.65)
                    xmove(Center[_W]/2*Tile_Size + thick+trim)
                    zmove(0.5-trim)
                    {
                        nib_relief(size=[100, 200, 0.5+2*trim], anchor=RIGHT);
                        
                        ymove(20.5)
                        sphere(d=20.4);
                    }
                }
                ymove(-6.65)
                xmove(Center[_W]/2*Tile_Size + thick)
                zmove(0.5-trim)
                    nib_onlay(size=[100, 200, 0.5+2*trim], anchor=RIGHT);
            }
            
            xmove(explode)
            ymove(grid_off( Center[_H]) + explode)
            piece(Center[_W]/2, Corner[_H], edges=[1,1,0,0], thick=thick, anchor=BOTTOM+FRONT+LEFT,
                magnets=[0,1,0,0], butterfly=[0,0,3,2]);
            
            xmove(explode)
            ymove(grid_off(-Center[_H]) - explode)
            piece(Center[_W]/2, Corner[_H], edges=[0,1,1,0], thick=thick, anchor=BOTTOM+BACK+LEFT,
                magnets=[0,1,0,0], butterfly=[3,0,0,2]);
            
            // edge-side
            piece(Corner[_W], Center[_H], edges=[0,0,0,1], thick=thick, anchor=BOTTOM+RIGHT,
                hinges=[0,0,0,11], butterfly=[2,5,2,0]);

            // corner
            yflip_copy()
            ymove(grid_off( Center[_H]) + explode)
            union() {
                difference() {
                    piece(Corner[_W], Corner[_H], edges=[1,0,0,1], thick=thick, anchor=BOTTOM+FRONT+RIGHT,
                        hinges=[0,0,0,3], butterfly=[0,2,2,0], hinge_inner=true);
                
                    move([-thick, thick, -trim])
                    corner_relief(size=[55, 55, 0.5+2*trim], anchor=BOTTOM+FRONT+RIGHT);
                }
                move([-thick, thick, -trim])
                corner_onlay(size=[55, 55, 0.5+2*trim], anchor=BOTTOM+FRONT+RIGHT);
            }

            // grids
            ymove(explode/2)
            zmove(Tile_Size * 1.2 * (explode > 1 ? 1 : 0))
            difference() {
                xmove(Corner[_W]/2*Tile_Size)
                zmove(thick)
                    grid(6, 6, chamfers=[0,0,0,0], anchor=BOTTOM+FRONT);

                // see sphere cutout above
                ymove(-6.65 + 20.5)
                xmove(Center[_W]/2*Tile_Size + thick)
                zmove(0.5-trim)
                    sphere(d=20.4);
            }
            
            ymove(-explode/2)
            zmove(Tile_Size * 1.2 * (explode > 1 ? 1 : 0))
            xmove(Corner[_W]/2*Tile_Size)
                grid(6, 6, chamfers=[0,0,0,0], anchor=BOTTOM+BACK);
        }        
        children();
    }
}
//cab_door();


module corner_relief(
    size = [70, 70, 1],
    anchor, spin, orient
) {
    attachable(anchor, spin, orient, size=size) {
        scale([size[0]/70, size[1]/70, size[2]/1])
        move([-34, -34, -0.5])
        linear_extrude(height=1)
            import(file="corner-onlay.svg", layer="Outline", convexity=10);
        
        children();
    }
}
//corner_relief() show_anchors();


module corner_onlay(
    size = [70, 70, 1],
    anchor, spin, orient
) {
    layers = [
        "gray0",
        "gray1",
        "gray2",
        "gray3",
    ];

    attachable(anchor, spin, orient, size=size) {
        scale([size[0]/70, size[1]/70, size[2]/1])
        move([-34, -34, -0.5])
        for(layer = layers) {
            linear_extrude(height=1)
            import(file="corner-onlay.svg", layer=layer);
         }
         //move([-1, -1, 0])
         //cuboid([70, 70, 1], anchor=TOP+LEFT+FRONT);
        
        children();
    }
}
//corner_onlay() show_anchors(s=1);


module nib_relief(
    size = [100, 200, 1],
    anchor, spin, orient
) {
    attachable(anchor, spin, orient, size=size) {
        move([50, -100, -0.5])
        scale([size[0]/100, size[1]/200, size[2]/1])
        xmove(-99.7)
        linear_extrude(height=1)
            import(file="nib-onlay.svg", layer="Outline", convexity=10);
        
        children();
    }
}
//zmove(-2) nib_relief(anchor=TOP);


module nib_onlay(
    size = [100, 200, 1],
    anchor, spin, orient
) {
    //echo()
    layers = [
        "Nib-gold",
        "Nib-silver",
        "Fleur",
        "Ribs",
        "Barrel",
        "Neck",
    ];
    
    attachable(anchor, spin, orient, size=size) {
        move([50, -100, -0.5])
        difference() {
            scale([size[0]/100, size[1]/200, size[2]/1])
            xmove(-99.7)
            for(layer = layers) {
                linear_extrude(height=1)
                import(file="nib-onlay.svg", layer=layer, convexity=10);
            }
            
            // chop off the parts that are outside the canvas
            ymove(-5)
            cuboid([30, 210, 10], anchor=FRONT+LEFT);
            
            cuboid([50, 20, 10], anchor=BACK);
        }
        children();
    }
}
//nib_onlay(); //show_anchors(s=3);
