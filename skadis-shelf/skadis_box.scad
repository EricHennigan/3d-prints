use <skadis_parts.scad>

// [* Pro Tip *]
// Height + Depth should be an odd number, so that the pegs alternate. Then you can flip the box around to accomodate the shelf pegs.

// [* Box Dimensions *]

box_width = 1;   // in peg units
box_height = 13; // in peg units
box_depth = 20;  // in peg units
include_top_holes = true;
include_bottom_holes = true;

// Render the box
skadis_box(
    width = box_width,
    height = box_height,
    depth = box_depth,
    top_holes = include_top_holes,
    bottom_holes = include_bottom_holes
);
