
include <BOSL2/std.scad>
include <snap.scad>

/* [Diamine Ink Bottle] */

// WARNING: x and y may not correspond to gridX gridY
base_x = 27;
base_y = 27;
fillet = 3;
wall_thickness = .45;

cap_radius = 21 / 2;
clip_thickness = 3;

y_offset = (base_y + wall_thickness) / 2;  // center of the bottle

module shelf() {
    clearance = 0.05;
    height = 7;

    assert(base_x + 2 * wall_thickness < gridX - 0.05, "overflow to grid neighbor X");
    assert(base_y + 2 * wall_thickness < gridY - 0.05, "overflow to grid neighbor Y");

    assert((gridY - tileY) / 2 > 1.01, "overflow to grid neighbor")
    union() {
        zmove(tileY/2)
        yrot(180)
        snap(nub_directional=true);

        zmove(-.4) // the height nub on the snap
        ymove(y_offset + wall_thickness/2)
        difference() {
            cuboid([base_x + 2*wall_thickness, base_y + 2*wall_thickness, height],
                   anchor=BOTTOM);

            zmove(2)
            cuboid([base_x + clearance, base_y + clearance, height+.01],
                   anchor=BOTTOM, rounding=fillet,
                   edges=[BOTTOM, "Z"], $fn=32);
        }
    }
    // TODO: add chamfer 45deg on the front, for print orientation?
    //       or line up a 45def chamfer on the back with corner of the snap?
    //       that option would have better balance when printing
    // noticed that the bottom nub doesn't print well, meaning it snaps poorly into grid
}

module clip() {
    clearance = 0.5; // distance from ink cap

    outer = cap_radius + 2;
    inner = cap_radius - clearance;
    cut_r = .9 * cap_radius;

    up(clip_thickness/2)
    ymove(y_offset)
    difference() {
        union() {
            cylinder(r=outer, h=clip_thickness, anchor=CENTER);
            cuboid([2*outer, y_offset + gridZ, clip_thickness], anchor=BACK);
        }
        cylinder(r=cap_radius-clearance, h=clip_thickness+.01, anchor=CENTER);
        cylinder(r=cut_r, h=clip_thickness+.01, anchor=FRONT);
        ymove(-y_offset - gridZ/2)
            cuboid([gridX/3, gridZ+inner, clip_thickness+.01], anchor=FRONT);
    }
}

module clip_mount() {
    clearance = 0.1; // distance between parts

    union() {
        difference() {
            up(tileY/2 - 4.82) // TODO: sync number from snap, review it with FreeCAD
            yrot(180)
            snap(nub_directional=true);
            cuboid([gridY, gridZ, clip_thickness+clearance], anchor=BOTTOM+BACK);
        }

        // add support for the relief
        // TODO: synchronize the variables with snap.scad
        move([ tileY/2, -1, clip_thickness+clearance])
            cuboid([.6, .4, .4], anchor=BOTTOM+RIGHT);
        move([-tileY/2, -1, clip_thickness+clearance])
            cuboid([.6, .4, .4], anchor=BOTTOM+LEFT);
        // restore a support from the clip
        cuboid([gridX/3-clearance, gridZ/2-clearance, clip_thickness+clearance], anchor=BOTTOM+BACK);
    }
}


clip();
clip_mount();
