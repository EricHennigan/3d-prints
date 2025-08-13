
include <BOSL2/std.scad>

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
) {
    // TODO: add screw holes
    // TODO: add chamfers
    // TODO: add connector pins
    difference() {
        cuboid([tileSize * boardWidth, tileSize * boardHeight, tileThickness]);
        union() {
            grid_copies(spacing=tileSize+0.5, n=[boardWidth, boardHeight])
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
    _reduction = 1;
    _chamfer = 2;
    
    // grabbed these numbers from openGrid model in FreeCAD
    profile = [
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

    // The LITE version is just a chopped off FULL version
    attachable(anchor, spin, orient, size=[tileSize, tileSize, tileThickness]) {
        down((Full_Thickness - tileThickness) + tileThickness/2)
        union() {
            for(i = [0:len(profile)-2]) {
                d0 = profile[i];
                ts0 = tileSize - 2*d0[_reduction];
                r0 = rect([ts0, ts0], chamfer = d0[_chamfer]);
                
                d1 = profile[i+1];
                ts1 = tileSize - 2*d1[_reduction];
                r1 = rect([ts1, ts1], chamfer = d1[_chamfer]);
                
                skin([r0, r1], z = [d0[_height], d1[_height]+trim], slices = 0);
            }
            // TODO: add a chamfer at the tileThickness
            //       or always print TOP facing buildplate (elephants foot)
        }
        children();
    }
}

//cut_tile() show_anchors();
grid();