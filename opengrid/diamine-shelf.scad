
include <BOSL2/std.scad>
include <snap.scad>

/* [Diamine Ink Bottle] */

base_x = 27;
base_y = 27;
fillet = 3;

module shelf() {
    margin = .45;
    clearance = 0.2;

    assert(base_x + 2 * margin < gridX, "overflow to grid neighbor X");
    assert(base_y + 2 * margin < gridY, "overflow to grid neighbor Y");

    ymove((base_y + margin) / 2)
    difference() {
        cuboid([base_x + margin, base_y + margin, 5], anchor=BOTTOM);
        zmove(2) cuboid([base_x + clearance, base_y + clearance, 5], anchor=BOTTOM, rounding=fillet, edges=[BOTTOM, "Z"], $fn=32);
    }
}

union() {
  zmove(tileY/2) snap();
  assert((gridY - tileY) / 2 > 1.01)
  zmove(-1) shelf();
}
