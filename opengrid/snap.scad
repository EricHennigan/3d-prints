/* OpenGrid Snap

Based on models created by David D
  https://www.printables.com/model/1214361-opengrid-walldesk-mounting-framework-and-ecosystem
  https://makerworld.com/en/models/1179191-opengrid-wall-desk-mounting-framework-ecosystem
*/

// DONE: make the bumps, tile them around the snap
// DONE: make the relief cutouts, tile them around the snap
// TODO: Choose between Lite and Full
// TODO: make a bin above the snap
// TODO: Add other options?
//       - mounting screw
//       - multiconnect threads


include <BOSL2/std.scad>

/* [Grid Dimensions] */
gridX = 28;
gridY = 28;
gridZ = 4.0; // lite = 4.0, full = 6.8
gridH = 4.0;

baseMarginX = 1.6; // distance to grid sheet
baseMarginY = 1.6; // distance to grid sheet

tileX = gridX - 2*baseMarginX;
tileY = gridY - 2*baseMarginY;


/* [Nub Configuration] */
nub_right = true;
nub_left = true;
nub_bottom = true;
nub_top = true;

nub_directional = false; // removes strain relief from the 'top' nub

// 'lite' only
module nub(pos) {
    w = 10.8;
    h =  1.8;
    d =  0.4; // depth above surface
    chamfer = .6;
    offset = 0.2; // from the bottom of the snap
    
    ws = 3.8; // width for top of the chamfer
    y = (d*d + (ws/2)*(ws/2) - (w/2)*(w/2)) / (2*d);
    r = sqrt((w/2)*(w/2) + y*y);
    
    module draw() {
        move([0, -gridZ + h/2 + offset, 0])
        intersection() {
            prismoid([w, h], [w-2*chamfer, h-2*chamfer], h=d, anchor=BOTTOM);
            zmove(y) ymove(h/2) xrot(90) cylinder(h, r=r, $fn=512); // rounding
        };
    }
    if (pos == "right")  { move([ tileX/2, 0, 0]) xrot(90) yrot( 90) draw(); }
    if (pos == "left")   { move([-tileX/2, 0, 0]) xrot(90) yrot(-90) draw(); }
    if (pos == "bottom") { move([0, -tileY/2, 0]) xrot(90) yrot(  0) draw(); }
    if (pos == "top")    { move([0,  tileY/2, 0]) xrot(90) yrot(180) draw(); }
    // TODO: larger bump when directional
}

// 'lite' only
module relief(pos, nub_directional=nub_directional) {
    r = 0.6 / 2; // global rounding, corresponds to draw_v.d
    
    module draw_v() {
        w = 12.0;
        d =  0.6;
        h =  2.8;
        d_offset = 0.6; // from edge face
        
        move([0, -d/2 - d_offset, -gridZ])
        cuboid([w, d, h], anchor=BOTTOM, rounding=r, edges="Z", $fn=16);
    }
    module draw_h() {
        w = 12.0;
        d =  1.2;
        h =  0.4;
        h_offset = 0.8; // from the top
        
        move([0, -d/2, -h_offset])
        cuboid([w, d, h], anchor=TOP, rounding=r, edges=[FRONT+RIGHT, FRONT+LEFT], $fn=16);
    }
    module draw_guide() {
        offset = 4.25; // from edge face
        s = 3.29;      // equilateral triangle side
        d = 0.2;       // recessed
        
        move([0, -offset - s/3, -gridZ]) zrot(-30)
        cylinder(h=d, 2*s/3, 2*(s-0.4)/3, $fn=3, anchor=BOTTOM);
    }
    module draw() {
      if (pos != "top")          { draw_v(); draw_h(); }
      else if (!nub_directional) { draw_v(); draw_h(); }
      else                       { draw_guide(); }
    }
    
    if (pos == "right")  { zrot(-90) move([0, tileX/2, 0]) draw(); }
    if (pos == "left")   { zrot( 90) move([0, tileX/2, 0]) draw(); }
    if (pos == "top")    { zrot(  0) move([0, tileY/2, 0]) draw(); }
    if (pos == "bottom") { zrot(180) move([0, tileY/2, 0]) draw(); }
}

// 'lite' only
module snap(
    nub_directional=nub_directional,
) {
    top = -0.4;
    mid = -1.1;
    bot = -gridZ;
    
    // TODO: assert that gridZ >= top + mid
    
    r0 = rect([tileX, tileY], chamfer=3.26);
    r1 = rect([tileX, tileY], chamfer=4.82);
    
    xrot(-90)
    difference() {
        union() {
            skin([r0, r0], z=[  0, top], slices=0);
            skin([r0, r1], z=[top, mid], slices=0);
            skin([r1, r1], z=[mid, bot], slices=0);
            if (nub_right) nub("right");
            if (nub_left) nub("left");
            if (nub_top) nub("top");
            if (nub_bottom) nub("bottom");
        }
        // Cut out the strain reliefs
        if (nub_right) relief("right", nub_directional=nub_directional);
        if (nub_left) relief("left", nub_directional=nub_directional);
        if (nub_top) relief("top", nub_directional=nub_directional);
        if (nub_bottom) relief("bottom", nub_directional=nub_directional);
    }
}
