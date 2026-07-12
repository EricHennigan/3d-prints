// -----------------------------
// Parameters
// -----------------------------
// "All" - Shows how it is assembled. Please select and download each individual component.
component_type = "All"; // [All, Box, Lid]


/* [Upright Parameters] */
// When enabled the peg holes on the opposite side will not line up. Gives the effect of not being able to see through the box. Will be more obvious with a shorter box depth. (Ex box_depth of 40)
alternate_pattern = true;
box_height = 140;
box_width = 135;
box_depth = 135;


// Adds pegholes at top of upright. Use if you'd like to add a beam to the very top.
has_top_holes = false;
// Pegholes at bottom of upright. Use if you'd like to add a beam to the very bottom.
has_bottom_holes = false;


/* [Lid Parameters] */
// Portion that sits above upright
lid_height = 5;
// Portion that is inserted into upright
lid_insert_height = 5;
// If the lid does not fit, try increasing this value.
lid_tolerance = 0.1;
// Used to connect and stack uprights
lid_connector = false;
// Thickness of the lid insert perimeter
lid_insert_thickness = 5; 






/* [Hidden] */
top_margin = 10;
// Wall thickness of upright
shell_thickness = 5;


// Peg Hole Dimensions
peg_hole_width = 5;
peg_hole_height = 10;
peg_hole_circle_d = 5;
column_spacing = 20;
num_front_columns = floor((box_width - peg_hole_width - 20)/column_spacing) + 1;
num_side_columns = floor((box_depth - peg_hole_width - 10)/column_spacing) + 1;


// -----------------------------
// Hexagon Module for Ventilation Pattern
// -----------------------------
module hexagon(size) {
// For a hexagon where size is the distance between parallel sides (flat-to-flat)
// To get points-to-points distance, multiply by 2/sqrt(3)
point_to_point = size * 2 / sqrt(3);
radius = point_to_point / 2;  // Radius to the points
angles = [30, 90, 150, 210, 270, 330];  // 30° offset for points at top/bottom
points = [for (a = angles) [radius * cos(a), radius * sin(a)]];
polygon(points);
}


// -----------------------------
// Peg Hole Shape (2D)
// -----------------------------
module peg_hole() {
union() {
  square([peg_hole_width, peg_hole_height]);
  translate([peg_hole_width / 2, 0])
    circle(d = peg_hole_circle_d, $fn = 30);
  translate([peg_hole_width / 2, peg_hole_height])
    circle(d = peg_hole_circle_d, $fn = 30);
}
}



// -----------------------------
// Upright with Peg Holes
// -----------------------------
module upright() {
difference() {
  // Solid upright
  cube([box_width, box_height, box_depth]);


  // Hollow core
  translate([shell_thickness, 0, shell_thickness])
    cube([box_width - 10, box_height, box_depth - 10]);


  // Front/back peg holes
  if (!alternate_pattern || num_front_columns == 1) {
    // Through-holes
    for (i = [0 : num_front_columns - 1]) {
      x = (box_width - ((num_front_columns - 1) * column_spacing + peg_hole_width)) / 2
          + i * column_spacing;
      start_y = (i % 2 == 0) ? 20 : 40;
      for (y = [start_y : 40 : box_height - peg_hole_height / 2]) {
        if (y + peg_hole_height / 2 <= box_height - top_margin)
          translate([x, y - peg_hole_height / 2, 0])
            linear_extrude(height = box_depth)
              peg_hole();
      }
    }
  } else {
    // Partial front
    for (i = [0 : num_front_columns - 1]) {
      x = (box_width - ((num_front_columns - 1) * column_spacing + peg_hole_width)) / 2
          + i * column_spacing;
      start_y = (i % 2 == 0) ? 20 : 40;
      for (y = [start_y : 40 : box_height - peg_hole_height / 2]) {
        if (y + peg_hole_height / 2 <= box_height - top_margin)
          translate([x, y - peg_hole_height / 2, 0])
            linear_extrude(height = shell_thickness)
              peg_hole();
      }
    }
    // Partial back (flipped pattern)
    for (i = [0 : num_front_columns - 1]) {
      x = (box_width - ((num_front_columns - 1) * column_spacing - peg_hole_width)) / 2
          + i * column_spacing;
      start_y = (i % 2 == 0) ? 40 : 20;
      for (y = [start_y : 40 : box_height - peg_hole_height / 2]) {
        if (y + peg_hole_height / 2 <= box_height - top_margin)
          translate([x, y - peg_hole_height / 2, box_depth])
            rotate([0, 180, 0])
            linear_extrude(height = shell_thickness)
              peg_hole();
      }
    }
  }


  // Left/right peg holes
  if (!alternate_pattern || num_side_columns == 1) {
    // Through
    for (i = [0 : num_side_columns - 1]) {
      z = (box_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      start_y = (i % 2 == 0) ? 20 : 40;
      for (y = [start_y : 40 : box_height - peg_hole_height / 2]) {
        if (y + peg_hole_height / 2 <= box_height - top_margin)
          translate([0, y - peg_hole_height / 2, z])
            rotate([0, 90, 0])
            translate([-peg_hole_width / 2, 0, 0])
            linear_extrude(height = box_width)
              peg_hole();
      }
    }
  } else {
    // Partial left
    for (i = [0 : num_side_columns - 1]) {
      z = (box_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      start_y = (i % 2 == 0) ? 20 : 40;
      for (y = [start_y : 40 : box_height - peg_hole_height / 2]) {
        if (y + peg_hole_height / 2 <= box_height - top_margin)
          translate([0, y - peg_hole_height / 2, z])
            rotate([0, 90, 0])
            translate([-peg_hole_width / 2, 0, 0])
            linear_extrude(height = shell_thickness)
              peg_hole();
      }
    }
    // Partial right (flipped)
    for (i = [0 : num_side_columns - 1]) {
      z = (box_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      start_y = (i % 2 == 0) ? 40 : 20;
      for (y = [start_y : 40 : box_height - peg_hole_height / 2]) {
        if (y + peg_hole_height / 2 <= box_height - top_margin)
          translate([box_width, y - peg_hole_height / 2, z])
            rotate([0, -90, 0])
            translate([-peg_hole_width / 2, 0, 0])
            linear_extrude(height = shell_thickness)
              peg_hole();
      }
    }
  }


  // Half-cut peg holes at bottom edge of front face
  if (has_bottom_holes) {
    // front
    for (i = [0 : num_front_columns - 1]) {
      x = (box_width - ((num_front_columns - 1) * column_spacing + peg_hole_width)) / 2
          + i * column_spacing;
      translate([x, -peg_hole_height / 2, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
    // back
    for (i = [0 : num_front_columns - 1]) {
      x = (box_width - ((num_front_columns - 1) * column_spacing - peg_hole_width)) / 2
          + i * column_spacing;
      translate([x, -peg_hole_height / 2, box_depth])
        rotate([0, 180, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
  }


  // Half-cut peg holes at bottom edge of left side face
  if (has_bottom_holes) {
    // left
    for (i = [0 : num_side_columns - 1]) {
      z = (box_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      translate([0, -peg_hole_height / 2, z])
        rotate([0, 90, 0])
        translate([-peg_hole_width / 2, 0, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
    // right
    for (i = [0 : num_side_columns - 1]) {
      z = (box_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      translate([box_width, -peg_hole_height / 2, z])
        rotate([0, -90, 0])
        translate([-peg_hole_width / 2, 0, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
  }


  // Half-cut peg holes at top edge of front face
  if (has_top_holes) {
    // front
    for (i = [0 : num_front_columns - 1]) {
      x = (box_width - ((num_front_columns - 1) * column_spacing + peg_hole_width)) / 2
          + i * column_spacing;
      translate([x, box_height - peg_hole_height / 2, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
    // back
    for (i = [0 : num_front_columns - 1]) {
      x = (box_width - ((num_front_columns - 1) * column_spacing - peg_hole_width)) / 2
          + i * column_spacing;
      translate([x, box_height - peg_hole_height / 2, box_depth])
        rotate([0, 180, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
  }


  // Half-cut peg holes at top edge of left side face
  if (has_top_holes) {
    // left
    for (i = [0 : num_side_columns - 1]) {
      z = (box_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      translate([0, box_height - peg_hole_height / 2, z])
        rotate([0, 90, 0])
        translate([-peg_hole_width / 2, 0, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
    // right
    for (i = [0 : num_side_columns - 1]) {
      z = (box_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      translate([box_width, box_height - peg_hole_height / 2, z])
        rotate([0, -90, 0])
        translate([-peg_hole_width / 2, 0, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
  }
}
}

// -----------------------------
// Module for end cap that sits on top of upright
// -----------------------------
module end_cap() {
  lower_w = box_width - 2 * shell_thickness - 2 * lid_tolerance;
  lower_d = box_depth - 2 * shell_thickness - 2 * lid_tolerance;

  union() {
    // Insert portion (now hollow with perimeter thickness)
    difference() {
      translate([shell_thickness + lid_tolerance, box_height, shell_thickness + lid_tolerance])
        cube([lower_w, lid_insert_height, lower_d]);

      translate([
        shell_thickness + lid_tolerance + lid_insert_thickness,
        box_height,
        shell_thickness + lid_tolerance + lid_insert_thickness
      ])
        cube([
          lower_w - 2 * lid_insert_thickness,
          lid_insert_height,
          lower_d - 2 * lid_insert_thickness
        ]);
    }

    // Solid top cap
    translate([0, box_height + lid_insert_height, 0])
      cube([box_width, lid_height, box_depth]);
  }
}



// -----------------------------
// Generate the complete structure, rotate & recenter
// -----------------------------

translate([-box_width/2, box_depth/2, -box_height/2])
rotate([90, 0, 0]) {
  // First upright at origin
  if (component_type == "All" || component_type == "Box")
    color("LightBlue", 1) upright();


  // Second upright at the other end of the beam
  if (component_type == "All") {
    translate([0, 0, 0])
      color("LightBlue", 1) upright();
  }


  // End caps for both uprights
  if (component_type == "All" || component_type == "Lid") {
    // First upright end cap
    color("Gold", 1) end_cap();
  }


  if (component_type == "All") {
    // Second upright end cap
    translate([0, 0, 0])
      color("Gold", 1) end_cap();
  }
}



