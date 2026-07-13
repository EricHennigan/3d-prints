
References:
- Josh Makeshift [Create Custom IKEA Pieces with This 3D Printed System](https://www.youtube.com/watch?v=YfcZ-XtPxsY)
- https://www.printables.com/model/1315483-fully-customizable-ikea-components-parametric/files

# Mon Feb 23 17:47:35 PST 2026

Remix the files from the printables.com model [1315483](https://www.printables.com/model/1315483-fully-customizable-ikea-components-parametric/files).
 - Added options for plugs on the connector pieces of the `Mac Mini Shelf.scad`

# Tue Feb 24 17:48:21 PST 2026

Published the remix to [printables.com](https://www.printables.com/model/1615395-customizable-ikea-components-parametric-connector).

Original print was:
	180mm deep, 8 cols
	220mm tall, 10 rows
	15mm wide, 1 col

Still agonizing over how to print the remaining shelves. For some reason, I have a hard time accepting that the existing prints might be junk.
Let's just accept the fact that I should not design my own parts. And need to move on with printing.

Upright parameters:
 - upright height: 220
 - upright width: 250  (note: 230 is better, because of the mirroring)
 - upright depth: 15
 - has_top_holes: true
 - has_bottom_holes: true
 - alternate: true

End cap parameters:
 - end cap height: 0
 - end cap insert height: 8
 - add end cap connector: true
 - end cap plug placement: 'both'

Beam parameters:
 - beam height: 8
 - beam length: 180
 - add beam wall: false
 - add beam ventilation: false
 - alternate pattern: true


# Reference Values

Shelf for Skadis Large Box
  has to be split into slats because Centauri Carbon build dimensions too small
  ideal depth would be 350, but already have printed many with depth of 250
  so slat comes out to be depth 62 = floor(250/4)
  but it needs to fit the IKEA dimensions (skadis is spaced at 20mm)
  so slat comes out to be depth 59.5 mm (for some space).

  (depth) upright width: 250, but chopped to 59.5 (see below code)
  (width) beam length: 270

Code change to `Mac Mini Shelf.stl`
```
  // color("Salmon", 1) front_beam_with_pegs(lower_beam_y, true, false);

  intersection() {
    front_beam_with_pegs(lower_beam_y, true, false);
    rotate([0, 90, 0]) translate([135, 15, -2.5+37.5]) cube([310, 20, 59.5], center=true);
  }
```

Decided that the correct dimensions for the sparse walls are
 h = 13 peg units
 d = 24 peg units

# NEXT

Leaving the skadis_box.scad and skadis_parts.scad as leftover artifacts.
Was trying to use them as a way to compose my own box with more peg holes.

TODO: After migrating to the `skadis_spare_wall`, the `skadis_box` doesn't
      correctly handle width of 2 or 3.
TODO: need to update the `skadis_crown_connection` so that it takes the same
      hole counts as the current `skadis_box` using the `skadis_sparse_wall`.

