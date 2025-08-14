
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

/* [Chamfer Options] */
Chamfer_TL = true;
Chamfer_TR = true;
Chamfer_BL = true;
Chamfer_BR = true;


module grid(
    boardWidth = Board_Width,
    boardHeight = Board_Height,
    tileSize = Tile_Size,
    tileThickness = Tile_Thickness,
    anchor = CENTER,
    spin = 0,
    orient = UP,
) {
    boardSize = tileSize * boardWidth;
    
    chamfers = [
      Chamfer_TL ? BACK+RIGHT: 0,
      Chamfer_TR ? BACK+LEFT : 0,
      Chamfer_BL ? FRONT+RIGHT : 0,
      Chamfer_BR ? FRONT+LEFT : 0,
    ];
    
    attachable(anchor, spin, orient, size=[boardSize, boardSize, tileThickness]) {
        difference() {
            cuboid([boardSize, boardSize, tileThickness], chamfer=4.2, edges=chamfers);
            union() {
                grid_copies(spacing=tileSize, n=[boardWidth, boardHeight])
                cut_tile(tileSize, tileThickness);
                
                // TODO: cut connector pins
                // TODO: cut screw holes
            }
        }
        children();
    }
}
// grid();


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
    
    render() {
        attachable(anchor, spin, orient, size=[tileSize, tileSize, tileThickness]) {
            down((Full_Thickness - tileThickness) + tileThickness/2)
                skin(profiles = [for(p = profile_params) make_profile(p)],
                     z = [for(p = profile_params) p[_height]],
                     slices = 0,
                );
            children();
        }
    }
}
// cut_tile() show_anchors();


module lite_connector() {
    // TODO: could not get the outside fillet on that dimple!
    module p() {
        round2d(ir=0.5) {
            xmove(2.5) ring(r1=2.5, r2=1.7, angle=[0,90]);
            ymove(2.5) xmove(2.5) rect([1.15, 0.8], anchor=RIGHT+BACK);
            ymove(3.25+2.5-.25) ring(r1=4.05, r2=3.25, angle=[270,291]);
            rect([0.6, 1.7], anchor=LEFT+FRONT);
        }
    }
    render($fn=60) {
        linear_extrude(height=2.2)
        yflip_copy() {
            union() {
                xflip_copy() {
                    p();
                }
            }
        }
    }
}
lite_connector() show_anchors();

