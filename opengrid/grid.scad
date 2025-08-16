
include <BOSL2/std.scad>
include <grid_vars.scad>

module grid(
    boardWidth = Board_Width,
    boardHeight = Board_Height,
    tileSize = Tile_Size,
    tileThickness = Tile_Thickness,
    chamfers = [Chamfer_TR, Chamfer_BR, Chamfer_BL, Chamfer_TL],
    connectors = [Connectors_T, Connectors_R, Connectors_B, Connectors_L],
    anchor = CENTER,
    spin = 0,
    orient = UP,
) {
    boardSizeW = tileSize * boardWidth;
    boardSizeH = tileSize * boardHeight;
    
    chamfer_edges = [
      chamfers[0] ? BACK+RIGHT : [0],
      chamfers[1] ? FRONT+RIGHT : [0],
      chamfers[2] ? FRONT+LEFT : [0],
      chamfers[3] ? BACK+LEFT: [0],
    ];
    
    // affine transform: 1 at Lite, 2.2 at Full
    connector_offset = (1.2/2.8)*tileThickness + (1-4*(1.2/2.8));
    
    attachable(anchor, spin, orient, size=[boardSizeW, boardSizeH, tileThickness]) {
        difference() {
            cuboid([boardSizeW, boardSizeH, tileThickness], chamfer=4.2, edges=chamfer_edges);
            union() {
                grid_copies(spacing=tileSize, n=[boardWidth, boardHeight])
                    cut_tile(tileSize, tileThickness);
                
                if (connectors[0]) { // top
                    zmove(tileThickness/2 - connector_offset)
                    ymove(boardSizeH/2)
                    xcopies(n=boardWidth-1, spacing=tileSize)
                        cut_connector(spin=180, anchor=FRONT+TOP);
                }
                if (connectors[1]) { // right
                    zmove(tileThickness/2 - connector_offset)
                    xmove(boardSizeW/2)
                    ycopies(n=boardHeight-1, spacing=tileSize)
                        cut_connector(spin=90, anchor=FRONT+TOP);
                }
                if (connectors[2]) { // bottom
                    zmove(tileThickness/2 - connector_offset)
                    ymove(-boardSizeH/2)
                    xcopies(n=boardWidth-1, spacing=tileSize)
                        cut_connector(spin=0, anchor=FRONT+TOP);
                }
                if (connectors[3]) { // left
                    zmove(tileThickness/2 - connector_offset)
                    xmove(-boardSizeW/2)
                    ycopies(n=boardHeight-1, spacing=tileSize)
                        cut_connector(spin=270, anchor=FRONT+TOP);
                }
                
                // TODO: cut screw holes
            }
        }
        children();
    }
}
//grid();


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


// LITE and FULL have the same connector socket
// WARN: size here must correspond to /connectors.lite_connector
module cut_connector(
    anchor = CENTER,
    spin = 0,
    orient = UP,
) {
    height = 2.4;
    width = 5.2;
    depth = 5.10;

    // numbers measured in FreeCAD
    module quarter() {
        path = turtle([
            "left", 90,
            "move", depth,
            "left", 90,
            "arcleft", width/2, 90,
            "move", 1.14,
            "arcleft", 0.5, 24.25,
            "arcright", 2.8, 18.8, // a bit extra to extend front face extend past anchor
            "arcright", 0.25, 95.5,
        ]);
        polygon(path);
    }
    attachable(anchor, spin, orient, size=[width, depth, height]) {
        render($fn=60) {
            ymove(-depth/2)
            zmove(-height/2)
            linear_extrude(height=height)
            xflip_copy() {
                quarter();
            }
        }
        children();
    }
}
//cut_connector(anchor=FRONT) show_anchors(s=1);


