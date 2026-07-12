// Parametric Storage Bin with SVG Front
// Parameters with default values
height = 50;     // Height of the bin
width = 169;      // Width of the bin
depth = 127;     // Depth of the bin
thickness = 3;   // Thickness of the walls and bottom

// Scaling factor for the SVG
// The SVG has a viewBox of "0 0 215.35 70.36"
// We need to scale it to match our bin width and height
svg_scale_x = width / 215.35;
svg_scale_y = height / 70.36;

module storage_bin(height=height, width=width, depth=depth, thickness=thickness) {
    difference() {
        union() {
            // Left wall
            translate([0, 0, 0])
                cube([thickness, depth, height]);
            
            // Right wall
            translate([width - thickness, 0, 0])
                cube([thickness, depth, height]);
            
            // Back wall
            translate([0, depth - thickness, 0])
                cube([width, thickness, height]);
            
            // Bottom
            translate([0, 0, 0])
                cube([width, depth, thickness]);
            
            // Front SVG (correctly oriented)
            translate([0, thickness, 0])
                rotate([90, 0, 0])  // Rotate -90 degrees around X-axis
                linear_extrude(height = thickness)
                resize([width, height, 0])  // Resize to match bin dimensions
                scale([svg_scale_x, svg_scale_y, 1])
                import("drawer.svg", center = false);
        }
        
        // Inner cutout
        translate([thickness, thickness, thickness])
            cube([width - 2*thickness, depth - 2*thickness, height - thickness + 1]);
    }
}

// Create the bin with default parameters
storage_bin();

// Uncomment and modify to create a bin with custom parameters
// storage_bin(height=50, width=120, depth=150, thickness=2);