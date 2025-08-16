
include <BOSL2/std.scad>

// WARN: size here must correspond to fit inside /grid.cut_connector
module lite_connector() {
    // TODO: add attachments
    // TODO: could not get the outside fillet on that dimple!

    height = 2.2;
    width = 5;
    depth = 5;
    thick = 0.8;
    radius = width/2;

    module quarter() {
        round2d(ir=0.5) {
            xmove(depth-radius) ring(r1=radius, r2=radius-thick, angle=[0,90]);
            ymove(width/2) xmove(depth-radius) rect([1.15, thick], anchor=RIGHT+BACK);
            ymove(3.25+2.5-.25) ring(r1=4.05, r2=3.25, angle=[270,291]);
            rect([thick-0.2, 1.7], anchor=LEFT+FRONT);
        }
    }
    render($fn=60) {
        linear_extrude(height=height)
        yflip_copy() {
            union() {
                xflip_copy() {
                    quarter();
                }
            }
        }
    }
}
lite_connector() show_anchors();
