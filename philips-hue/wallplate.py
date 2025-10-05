
from build123d import *
from ocp_vscode import *
from hue_rocker import HueRocker
import copy
import sys

height = 5 * IN
width = (1 + 13/16) * IN
depth = 15
recess = 5


# Notes for re-design
#  - Gang (mm): 46.04 wide spacing
#  - Rocker Switch Cutout (mm): # 32.68 wide, 66.15 tall, 1.2 displacement
#  - Hue Remote: https://www.reddit.com/r/Hue/comments/1g8xz56/new_v2_dimmer_remotes_have_different_dimensions/
#    - wide:  35.08 and 35.31
#    - tall:  91.59 and 91.88
#    - thick: 11.09 and 11.39
#    - looks like the cradle is only as deep as the fillet => not enough for flex centering
#  - https://images.philips.com/is/content/PhilipsConsumer/PDFDownloads/Global/Meethue/product-support/ODLI20170713-001-UPD-en_AA-Hue-Dimmer-Switch-NAM.pdf
#    - remote: 1.38 x 3.6 x 0.43 IN
#    - with wall mount plate: 2.76 x 4.5 x 0.55 IN


gangs = [HueRocker()]

with BuildPart() as plate:
    thick = 4
    border_w = 0.5 * IN
    w = len(gangs) * width + 2 * border_w

    box = Box(w, height, depth)
    fillet(plate.edges().filter_by(Axis.Z), radius=3)

    top_face = plate.faces().sort_by(Axis.Z)[0]
    offset(amount=-thick, openings=top_face)

    bot_face = plate.faces().sort_by(Axis.Z)[-1]
    chamfer(bot_face.edges(), length=2)

    # Add bracing
    Box(w, thick, depth-recess)
    with GridLocations(x_spacing=width, x_count=len(gangs), y_spacing=0, y_count=1):
        Box(thick, height, depth-recess)
    with GridLocations(x_spacing=width, x_count=len(gangs), y_spacing=(3 + 13/16)*IN, y_count=2):
        Cylinder(radius=4, height=depth-recess)
    fillet(plate.edges().filter_by(Axis.Z), radius=2)

    # Place the gang switches
    with Locations(Plane.XY.offset(depth/2)):
        gang_locs = GridLocations(x_spacing=width, x_count=len(gangs), y_spacing=0, y_count=1)
        for n, loc in enumerate(gang_locs):
            g = gangs[n]
            s = g.bounding_box().size
            loc = Location(loc.position + (0, 0, -s.Z/2))
            with BuildPart(loc, mode=Mode.SUBTRACT) as gang_cutout:
                s.Z += 10
                Box(*s)
            with BuildPart(loc) as gang_switch:
                add(g)

    # Add the screw bores
    with GridLocations(x_spacing=width, x_count=len(gangs), y_spacing=(3 + 13/16)*IN, y_count=2):
        with Locations(bot_face):
            CounterSinkHole(radius=2, counter_sink_radius=4)
            

show([plate], reset_camera=Camera.KEEP)
export_stl(plate.part, 'wallplate.stl')