// -----------------------------
// Parameters
// -----------------------------
// "All" - Shows how it is assembled. Please select and download each individual component. "Upper Beam" and "Lower Beam" - In some cases when adjusting the Upright Width, you may have different number of pegs for each row which means you will need two different beams (Ex upright_width of 70 and alternate_pattern is false)
component_type = "All"; // [All, Upright, Upper Beam, Lower Beam, End Cap]


/* [Upright Parameters] */
// Offsets pattern on opposite side. This allows you to have a thin upright while still being able to use both sides of the upright pegholes.
alternate_pattern = true;
upright_height = 140;
upright_width = 135;
upright_depth = 15;


// Adds pegholes at top of upright. Use if you'd like to add a beam to the very top.
has_top_holes = false;
// Pegholes at bottom of upright. Use if you'd like to add a beam to the very bottom.
has_bottom_holes = false;


/* [End Cap Parameters] */
// Portion that sits above upright
end_cap_height = 2;
// Portion that is inserted into upright
end_cap_insert_height = 5;
// If the end cap does not fit, try increasing this value.
end_cap_tolerance = 0.1;
// Used to connect and stack uprights
add_end_cap_connector = false;


/* [Beam Parameters] */
// Thickness of beam
beam_height = 3;
// Length of front beams
beam_length = 135;
// Adds a wall that extrudes in the front and back of the beam
add_beam_wall = true;
// Wall height: negative = downward, positive = upward
beam_wall_height = -5;
// Adds ventilation pattern to beam
add_beam_ventilation = true;
// Size of hexagon pattern (flat edge to flat edge)
beam_pattern_size = 8;
// Spacing between hexagons in pattern
beam_pattern_spacing = 3;
// If the pegs do not fit, try increasing this value.
peg_tolerance = 0.1;




/* [Hidden] */
// Peg Dimensions
peg_width = 5 - peg_tolerance;
lower_peg_h = 5.1;
peg_diameter = peg_width;
upper_peg_thickness = 5 - peg_tolerance;
horizontal_pegs = 1; // Number of horizontal pegs
horizontal_peg_spacing = 20; // Spacing between horizontal pegs
// Margin safe area that restricts peg holes being created too close to edge
top_margin = 10;
// Wall thickness of upright
shell_thickness = 5;


// Peg Hole Dimensions
peg_hole_width = 5;
peg_hole_height = 10;
peg_hole_circle_d = 5;
column_spacing = 20;
num_front_columns = floor((upright_width - peg_hole_width - 20)/column_spacing) + 1;
num_side_columns = floor((upright_depth - peg_hole_width - 10)/column_spacing) + 1;


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
// Function to create peg
// -----------------------------
module create_peg() {
for (i = [0 : horizontal_pegs - 1]) {
  z_offset = 10 + (peg_width + peg_tolerance) / 2 + i * horizontal_peg_spacing;
  // Small base rectangle
  translate([0, -5, z_offset - peg_width / 2])
    cube([lower_peg_h, 5, peg_width]);
  // Cylinder stem between base and tall rectangle
  translate([0, 0, z_offset])
    rotate([0, 90, 0])
    cylinder(h = lower_peg_h, r = peg_diameter / 2, $fn = 30);
  // Peg at tall rectangle on top
  translate([lower_peg_h, 5.5, z_offset])
    rotate([0, 90, 0])
    cylinder(h = upper_peg_thickness, r = peg_diameter / 2, $fn = 30);
  // Tall rectangle on top
  translate([lower_peg_h, -5, z_offset - peg_width / 2])
    cube([upper_peg_thickness, 10.5, peg_width]);
}
}


// -----------------------------
// Upright with Peg Holes
// -----------------------------
module upright() {
difference() {
  // Solid upright
  cube([upright_width, upright_height, upright_depth]);


  // Hollow core
  translate([shell_thickness, 0, shell_thickness])
    cube([upright_width - 10, upright_height, upright_depth - 10]);


  // Front/back peg holes
  if (!alternate_pattern || num_front_columns == 1) {
    // Through-holes
    for (i = [0 : num_front_columns - 1]) {
      x = (upright_width - ((num_front_columns - 1) * column_spacing + peg_hole_width)) / 2
          + i * column_spacing;
      start_y = (i % 2 == 0) ? 20 : 40;
      for (y = [start_y : 40 : upright_height - peg_hole_height / 2]) {
        if (y + peg_hole_height / 2 <= upright_height - top_margin)
          translate([x, y - peg_hole_height / 2, 0])
            linear_extrude(height = upright_depth)
              peg_hole();
      }
    }
  } else {
    // Partial front
    for (i = [0 : num_front_columns - 1]) {
      x = (upright_width - ((num_front_columns - 1) * column_spacing + peg_hole_width)) / 2
          + i * column_spacing;
      start_y = (i % 2 == 0) ? 20 : 40;
      for (y = [start_y : 40 : upright_height - peg_hole_height / 2]) {
        if (y + peg_hole_height / 2 <= upright_height - top_margin)
          translate([x, y - peg_hole_height / 2, 0])
            linear_extrude(height = shell_thickness)
              peg_hole();
      }
    }
    // Partial back (flipped pattern)
    for (i = [0 : num_front_columns - 1]) {
      x = (upright_width - ((num_front_columns - 1) * column_spacing - peg_hole_width)) / 2
          + i * column_spacing;
      start_y = (i % 2 == 0) ? 40 : 20;
      for (y = [start_y : 40 : upright_height - peg_hole_height / 2]) {
        if (y + peg_hole_height / 2 <= upright_height - top_margin)
          translate([x, y - peg_hole_height / 2, upright_depth])
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
      z = (upright_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      start_y = (i % 2 == 0) ? 20 : 40;
      for (y = [start_y : 40 : upright_height - peg_hole_height / 2]) {
        if (y + peg_hole_height / 2 <= upright_height - top_margin)
          translate([0, y - peg_hole_height / 2, z])
            rotate([0, 90, 0])
            translate([-peg_hole_width / 2, 0, 0])
            linear_extrude(height = upright_width)
              peg_hole();
      }
    }
  } else {
    // Partial left
    for (i = [0 : num_side_columns - 1]) {
      z = (upright_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      start_y = (i % 2 == 0) ? 20 : 40;
      for (y = [start_y : 40 : upright_height - peg_hole_height / 2]) {
        if (y + peg_hole_height / 2 <= upright_height - top_margin)
          translate([0, y - peg_hole_height / 2, z])
            rotate([0, 90, 0])
            translate([-peg_hole_width / 2, 0, 0])
            linear_extrude(height = shell_thickness)
              peg_hole();
      }
    }
    // Partial right (flipped)
    for (i = [0 : num_side_columns - 1]) {
      z = (upright_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      start_y = (i % 2 == 0) ? 40 : 20;
      for (y = [start_y : 40 : upright_height - peg_hole_height / 2]) {
        if (y + peg_hole_height / 2 <= upright_height - top_margin)
          translate([upright_width, y - peg_hole_height / 2, z])
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
      x = (upright_width - ((num_front_columns - 1) * column_spacing + peg_hole_width)) / 2
          + i * column_spacing;
      translate([x, -peg_hole_height / 2, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
    // back
    for (i = [0 : num_front_columns - 1]) {
      x = (upright_width - ((num_front_columns - 1) * column_spacing - peg_hole_width)) / 2
          + i * column_spacing;
      translate([x, -peg_hole_height / 2, upright_depth])
        rotate([0, 180, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
  }


  // Half-cut peg holes at bottom edge of left side face
  if (has_bottom_holes) {
    // left
    for (i = [0 : num_side_columns - 1]) {
      z = (upright_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      translate([0, -peg_hole_height / 2, z])
        rotate([0, 90, 0])
        translate([-peg_hole_width / 2, 0, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
    // right
    for (i = [0 : num_side_columns - 1]) {
      z = (upright_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      translate([upright_width, -peg_hole_height / 2, z])
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
      x = (upright_width - ((num_front_columns - 1) * column_spacing + peg_hole_width)) / 2
          + i * column_spacing;
      translate([x, upright_height - peg_hole_height / 2, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
    // back
    for (i = [0 : num_front_columns - 1]) {
      x = (upright_width - ((num_front_columns - 1) * column_spacing - peg_hole_width)) / 2
          + i * column_spacing;
      translate([x, upright_height - peg_hole_height / 2, upright_depth])
        rotate([0, 180, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
  }


  // Half-cut peg holes at top edge of left side face
  if (has_top_holes) {
    // left
    for (i = [0 : num_side_columns - 1]) {
      z = (upright_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      translate([0, upright_height - peg_hole_height / 2, z])
        rotate([0, 90, 0])
        translate([-peg_hole_width / 2, 0, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
    // right
    for (i = [0 : num_side_columns - 1]) {
      z = (upright_depth - ((num_side_columns - 1) * column_spacing + peg_hole_width)) / 2
          + peg_hole_width / 2 + i * column_spacing;
      translate([upright_width, upright_height - peg_hole_height / 2, z])
        rotate([0, -90, 0])
        translate([-peg_hole_width / 2, 0, 0])
        linear_extrude(height = shell_thickness)
          peg_hole();
    }
  }
}
}


// -----------------------------
// Module for front beam with pegs and ventilation pattern
// -----------------------------
module front_beam_with_pegs(y_position, include_odd_columns, include_even_columns) {
beam_width = upright_width;
beam_top_y = y_position - beam_height;


difference() {
  union() {
    translate([0, beam_top_y, -beam_length])
      cube([beam_width, beam_height, beam_length]);


    if (add_beam_wall) {
      if (beam_wall_height < 0) {
        translate([0, beam_top_y + beam_wall_height, -beam_length])
          cube([beam_height, abs(beam_wall_height), beam_length]);
        translate([beam_width - beam_height, beam_top_y + beam_wall_height, -beam_length])
          cube([beam_height, abs(beam_wall_height), beam_length]);
      } else {
        translate([0, beam_top_y + beam_height, -beam_length])
          cube([beam_height, beam_wall_height, beam_length]);
        translate([beam_width - beam_height, beam_top_y + beam_height, -beam_length])
          cube([beam_height, beam_wall_height, beam_length]);
      }
    }
  }


  if (add_beam_ventilation) {
    margin = 10;
    avail_w = beam_width - 2 * margin;
    avail_l = beam_length - 2 * margin;
    hex_spacing = beam_pattern_size + beam_pattern_spacing;
    num_cols = floor(avail_w / hex_spacing);
    num_rows = ceil(avail_l / hex_spacing);
    pat_w = num_cols * hex_spacing - beam_pattern_spacing;
    pat_l = num_rows * hex_spacing - beam_pattern_spacing;
    start_x = (beam_width - pat_w) / 2;
    start_z = -beam_length + (beam_length - pat_l) / 2;


    for (col = [0 : num_cols - 1])
      for (row = [0 : num_rows - 1]) {
        x_off = (row % 2 == 1) ? hex_spacing / 2 : 0;
        hx = start_x + col * hex_spacing + x_off;
        hz = start_z + row * hex_spacing;


        if (hx - beam_pattern_size / 2 >= margin &&
            hx + beam_pattern_size / 2 <= beam_width - margin &&
            hz + beam_pattern_size / 2 <= -margin &&
            hz - beam_pattern_size / 2 >= -beam_length + margin)
          translate([hx, beam_top_y + beam_height, hz])
            rotate([90, 0, 0])
            linear_extrude(height = beam_height)
              hexagon(beam_pattern_size);
      }
  }
}


// Add pegs - FRONT SIDE
for (i = [0 : num_front_columns - 1]) {
  col_idx = i + 1;
  if ((col_idx % 2 == 1 && include_odd_columns) ||
      (col_idx % 2 == 0 && include_even_columns)) {
    x = (upright_width - ((num_front_columns - 1) * column_spacing + peg_hole_width)) / 2
        + i * column_spacing;
    // The peg needs to be centered on the hole
    // The hole starts at x, and its center is at x + peg_hole_width/2
    // But create_peg() has an offset of 10 + (peg_width + peg_tolerance)/2
    // So we need to adjust for this offset
    peg_x = x + peg_hole_width/2 - 10 - (peg_width + peg_tolerance)/2;
    translate([peg_x, y_position - 5, 0])
      rotate([180, 270, 0])
      create_peg();
  }
}


// Add pegs - BACK SIDE
if (alternate_pattern && num_front_columns > 1) {
  // For alternating pattern, back pegs use opposite column pattern
  for (i = [0 : num_front_columns - 1]) {
    col_idx = i + 1;
    // Use opposite pattern: if front used odd, back uses even, and vice versa
    back_include_odd = include_even_columns;
    back_include_even = include_odd_columns;
   
    if ((col_idx % 2 == 1 && back_include_odd) ||
        (col_idx % 2 == 0 && back_include_even)) {
      // Use the shifted formula for back face positioning
      x = (upright_width - ((num_front_columns - 1) * column_spacing - peg_hole_width)) / 2
          + i * column_spacing;
      // The back formula already shifts by peg_hole_width, but we need to account for
      // the fact that the holes are rotated 180 degrees on the back face
      // This means the hole position is effectively shifted
      peg_x = x + peg_hole_width/2 - 10 - (peg_width + peg_tolerance)/2 - peg_hole_width;
      translate([peg_x, y_position - 5, -beam_length])
        mirror([0, 0, 1])
        rotate([180, 270, 0])
        create_peg();
    }
  }
} else {
  // Original behavior: back pegs same as front pegs
  for (i = [0 : num_front_columns - 1]) {
    col_idx = i + 1;
    if ((col_idx % 2 == 1 && include_odd_columns) ||
        (col_idx % 2 == 0 && include_even_columns)) {
      x = (upright_width - ((num_front_columns - 1) * column_spacing + peg_hole_width)) / 2
          + i * column_spacing;
      // Same centering adjustment
      peg_x = x + peg_hole_width/2 - 10 - (peg_width + peg_tolerance)/2;
      translate([peg_x, y_position - 5, -beam_length])
        mirror([0, 0, 1])
        rotate([180, 270, 0])
        create_peg();
    }
  }
}
}


// -----------------------------
// Module for end cap that sits on top of upright
// -----------------------------
module end_cap() {
lower_w = upright_width - 2 * shell_thickness - 2 * end_cap_tolerance;
lower_d = upright_depth - 2 * shell_thickness - 2 * end_cap_tolerance;


union() {
  if (add_end_cap_connector) {
    translate([shell_thickness + end_cap_tolerance, upright_height, shell_thickness + end_cap_tolerance])
      cube([lower_w, end_cap_insert_height * 2 + end_cap_height, lower_d]);
  } else {
    translate([shell_thickness + end_cap_tolerance, upright_height, shell_thickness + end_cap_tolerance])
      cube([lower_w, end_cap_insert_height, lower_d]);
  }
  translate([0, upright_height + end_cap_insert_height, 0])
    cube([upright_width, end_cap_height, upright_depth]);
}
}


// -----------------------------
// Generate the complete structure, rotate & recenter
// -----------------------------
lower_beam_y = 20;
upper_beam_y = lower_beam_y + 20;

total_width = beam_length + upright_depth*2 - 10;
total_height = upright_height;

translate([-upright_width/2, -total_width/2, -upright_height/2])
rotate([90, 0, 0]) {
  // First upright at origin
  if (component_type == "All" || component_type == "Upright")
    color("LightBlue", 1) upright();


  // Second upright at the other end of the beam
  if (component_type == "All") {
    translate([0, 0, -beam_length - upright_depth])
      color("LightBlue", 1) upright();
  }


  if (num_front_columns > 0) {
    if (component_type == "All" || component_type == "Lower Beam")
      color("Salmon", 1) front_beam_with_pegs(lower_beam_y, true, false);
    if ((component_type == "All" || component_type == "Upper Beam") && num_front_columns > 1)
      color("Khaki", 1) front_beam_with_pegs(upper_beam_y, false, true);
  }


  // End caps for both uprights
  if (component_type == "All" || component_type == "End Cap") {
    // First upright end cap
    color("Gold", 1) end_cap();
  }


  if (component_type == "All") {
    // Second upright end cap
    translate([0, 0, -beam_length - upright_depth])
      color("Gold", 1) end_cap();
  }
}



