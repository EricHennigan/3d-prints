
include <BOSL2/std.scad>

// TODO: add support for BOM
trim = 0.001;

/* [Board Size] */
Board_Style = "Lite"; //[Full, Lite]
Board_Width = 2;
Board_Height = 2;

/* [Advanced: Tile Parameters] */
Full_Thickness = 6.8;
Lite_Thickness = 4.0;
Tile_Thickness = Board_Style == "Full" ? Full_Thickness : Lite_Thickness;
Tile_Size = 28;

module grid(
    boardWidth = Board_Width,
    boardHeight = Board_Height,
    tileSize = Tile_Size,
    tileThickness = Tile_Thickness,
    anchor = CENTER,
    spin = 0,
    orient = UP,
) {
    // TODO: add screw holes
    // TODO: add chamfers
    // TODO: add connector pins
    // TODO: add anchors
    difference() {
        cuboid([tileSize * boardWidth, tileSize * boardHeight, tileThickness]);
        union() {
            grid_copies(spacing=tileSize, n=[boardWidth, boardHeight])
            cut_tile(tileSize, tileThickness);
        }
    }
}

// Note: cut_tile Z anchor points are at tileThickness
//           though cutting object is always greater, at Full size and trim above
//       cut_tile X+Y anchor points are at tileSize,
//           though cutting object is smaller
module cut_tile(
    tileSize = Tile_Size,
    tileThickness = Tile_Thickness,
    anchor = CENTER,
    spin = 0,
    orient = UP,
) {
    _height = 0;
    _width = 1;
    _chamfer = 2;
    
    // grabbed these numbers from openGrid model in FreeCAD
    profile_params = [
        [-trim, 1.1, 3.70],
        [  0, 1.1, 3.70],
        [0.4, 1.5, 3.46],
        [1.5, 1.5, 4.88],  // 6.28 - 2*0.7
        [2.4, 0.8, 6.28],
        [4.5, 0.8, 6.28],
        [5.4, 1.5, 4.88],  // 6.28 - 2*0.7
        [6.4, 1.5, 3.46],
        [6.8, 1.1, 3.70],
        [6.8+trim, 1.1, 3.70],
    ];
    
    function make_profile(params) = 
        rect([tileSize - 2*params[_width], tileSize-2*params[_width]], chamfer = params[_chamfer]);
    
    attachable(anchor, spin, orient, size=[tileSize, tileSize, tileThickness]) {
        down((Full_Thickness - tileThickness) + tileThickness/2)
            skin(profiles = [for(p = profile_params) make_profile(p)],
                 z = [for(p = profile_params) p[_height]],
                 slices = 0,
            );
        children();
    }
}

//cut_tile() show_anchors();
grid();


