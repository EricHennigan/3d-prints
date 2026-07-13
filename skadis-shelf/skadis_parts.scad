// -----------------------------
// Peg Hole Shape (2D)
// -----------------------------

_TOP = 0;
_RIGHT = 1;
_BOTTOM = 2;
_LEFT = 3;

// [* Peg Hole Parameters *]
peg_tolerance = 0.1;
peg_hole_width = 5;
peg_hole_height = 10;
peg_hole_circle_d = 5;

module skadis_peg_hole() {
  union() {
    square([peg_hole_width, peg_hole_height]);
    translate([peg_hole_width / 2, 0])
      circle(d=peg_hole_circle_d, $fn=30);
    translate([peg_hole_width / 2, peg_hole_height])
      circle(d=peg_hole_circle_d, $fn=30);
  }
}

module skadis_peg_fill() {
  union() {
    translate([peg_tolerance, peg_tolerance])
      square([peg_hole_width - 2 * peg_tolerance, peg_hole_height - 2 * peg_tolerance]);
    translate([peg_hole_width / 2, 0])
      circle(d=peg_hole_circle_d - 2 * peg_tolerance, $fn=30);
    translate([peg_hole_width / 2, peg_hole_height])
      circle(d=peg_hole_circle_d - 2 * peg_tolerance, $fn=30);
  }
}

// [* Wall Parameters *]
peg_spacing_x = 20;
peg_spacing_y = 20;

module skadis_wall(cols, rows, margin=[5, 15], alternate=false, top_holes=false, bottom_holes=false) {
  thickness = 5;

  // Wall dimensions derived from the pattern
  width  = 2 * margin[0] + (cols - 1) * peg_spacing_x + peg_hole_width;
  height = 2 * margin[1] + (rows - 1) * peg_spacing_y + peg_hole_height;

  difference() {
    cube([width, height, thickness]);

    for (i = [0 : cols - 1]) {
      x_pos = margin[0] + i * peg_spacing_x;
      for (j = [0 : rows - 1]) {
        if ((i + j + (alternate ? 0 : 1)) % 2 == 0) {
          y_pos = margin[1] + j * peg_spacing_y;
          translate([x_pos, y_pos, -0.01])
            linear_extrude(height = thickness + 0.02)
              skadis_peg_hole();
        }
      }
    }

    if (top_holes) {
      for (i = [0 : cols - 1]) {
        x_pos = margin[0] + i * peg_spacing_x;
        y_pos = margin[1] + rows * peg_spacing_y;
        translate([x_pos, y_pos, -0.01])
          linear_extrude(height = thickness + 0.02)
              skadis_peg_hole();
      }
    }
    if (bottom_holes) {
      for (i = [0 : cols - 1]) {
        x_pos = margin[0] + i * peg_spacing_x;
        y_pos = margin[1] - peg_spacing_y;
        translate([x_pos, y_pos, -0.01])
          linear_extrude(height = thickness + 0.02)
              skadis_peg_hole();
      }
    }
  }
}

// Note the margin[1] will be encroached by peg_hole_width/2 top and bottom
module skadis_sparse_wall(cols, rows, margin=[5, 5], alternate=false, top_holes=false, bottom_holes=false) {
  thickness = 5;

  function int(x) = x ? 1 : 0;

  width  = 2 * margin[0] + (cols-1) * peg_spacing_x/2 + peg_hole_width;
  height = 2 * margin[1] + (rows-1) * peg_spacing_y/2 + peg_hole_height;

  difference() {
    cube([width, height, thickness]);

    // We use a 10mm grid for pattern logic
    for (i = [0 + int(alternate): 2 : cols - 1]) {
      x_pos = margin[0] + i * peg_spacing_x/2;
      for (j = [0 - int(bottom_holes) : (rows - 1)/2 + int(top_holes)]) {
        y_pos = margin[1] + j * peg_spacing_y;

        translate([x_pos, y_pos, -0.01])
          linear_extrude(height = thickness + 0.02)
            skadis_peg_hole();
      }
    }
    for (i = [1 - int(alternate): 2 : cols - 1]) {
      x_pos = margin[0] + i * peg_spacing_x/2;
      for (j = [1 - int(bottom_holes) : rows/2 + int(top_holes)]) {
        y_pos = margin[1] + j * peg_spacing_y - peg_spacing_y/2;

        translate([x_pos, y_pos, -0.01])
          linear_extrude(height = thickness + 0.02)
            skadis_peg_hole();
      }
    }
  }
}
//translate([0, 0, 10]) skadis_wall(3, 4, top_holes=true, bottom_holes=true);
//skadis_sparse_wall(3, 5, top_holes=true, bottom_holes=true, alternate=true);

module skadis_box(width, height, depth, top_holes=false, bottom_holes=false) {
  t = 5; // wall thickness (matches skadis_wall)
  margin = [10, 5];

  // Actual dimensions from peg counts
  xw = 2 * margin[1] + (width - 1) * peg_spacing_x + peg_hole_width;
  yw = 2 * margin[0] + (depth - 1) * peg_spacing_x + peg_hole_width;

  // Front wall (XZ plane, outside face at Y=0)
  translate([0, t, 0])
    rotate([90, 0, 0])
      skadis_sparse_wall(width, height, alternate=true, top_holes=top_holes, bottom_holes=bottom_holes);

  // Back wall (XZ plane, outside face at Y=yw)
  translate([0, (yw + t)/2, 0])
    rotate([90, 0, 0])
      skadis_sparse_wall(width, height, alternate = (depth%2 == 1), top_holes=top_holes, bottom_holes=bottom_holes);

  // Left wall (YZ plane, outside face at X=0)
  rotate([90, 0, 90])
    skadis_sparse_wall(depth, height, top_holes=top_holes, bottom_holes=bottom_holes);

  // Right wall (YZ plane, outside face at X=xw)
  translate([xw - t, 0, 0])
    rotate([90, 0, 90])
      skadis_sparse_wall(depth, height, top_holes=top_holes, bottom_holes=bottom_holes);
}
//skadis_box(1, 13, 20, top_holes=true, bottom_holes=true);


module skadis_crown_connection(cols, rows, margin=10) {
  wall_width=peg_hole_width;
  size_x = (cols - 1) * peg_spacing_x + peg_hole_width - peg_tolerance;
  size_y = (rows - 1) * peg_spacing_y + peg_hole_width - peg_tolerance + margin;

  union() {
    cube([size_x, size_y, peg_hole_height + peg_hole_width]);

    for (i = [0 : cols - 1]) {
      translate([i * peg_spacing_x, 0, wall_width/2])
        rotate([90, 0, 0])
        linear_extrude(height = wall_width)
          skadis_peg_fill();
    }
    // Alternation math, because I did not update this
    // when I changed the peg counting for skadis_sparse_wall
    is_int = 1 - (rows * 2) % 2;
    for (i = [0 : 1 : cols - 1 - 1 * is_int]) {
      translate([(i + 0.5 * is_int) * peg_spacing_x, size_y+wall_width, wall_width/2])
        rotate([90, 0, 0])
        linear_extrude(height = wall_width)
          skadis_peg_fill();
    }

    for (i = [0 : rows - 1]) {
      translate([-wall_width, margin + i * peg_spacing_y, wall_width/2])
        rotate([90, 0, 90])
        linear_extrude(height = wall_width)
          skadis_peg_fill();
      translate([size_x, margin + i * peg_spacing_y, wall_width/2])
        rotate([90, 0, 90])
        linear_extrude(height = wall_width)
          skadis_peg_fill();
    }
  }
}
//translate([5, 5, -peg_hole_height + 5/2]) skadis_crown_connection(1, 8);

/*
module skadis_peg() {
  z_offset = 10 + (peg_width + peg_tolerance) / 2 + i * horizontal_peg_spacing;
  // Small base rectangle
  translate([0, -5, z_offset - peg_width / 2])
    cube([lower_peg_h, 5, peg_width]);
  // Cylinder stem between base and tall rectangle
  translate([0, 0, z_offset])
    rotate([0, 90, 0])
      cylinder(h=lower_peg_h, r=peg_diameter / 2, $fn=30);
  // Peg at tall rectangle on top
  translate([lower_peg_h, 5.5, z_offset])
    rotate([0, 90, 0])
      cylinder(h=upper_peg_thickness, r=peg_diameter / 2, $fn=30);
  // Tall rectangle on top
  translate([lower_peg_h, -5, z_offset - peg_width / 2])
    cube([upper_peg_thickness, 10.5, peg_width]);
}
*/
