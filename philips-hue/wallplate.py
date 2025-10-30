
from build123d import *
from ocp_vscode import *
from hue_rocker import HueRocker

height = 5 * IN
width = (1 + 13/16) * IN
depth = 14

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

AlignCCT = (Align.CENTER, Align.CENTER, Align.MAX)

gangs = [HueRocker()]*4

with BuildPart() as plate:
    thick = 2
    border_w = 0.5 * IN
    w = len(gangs) * width + 2 * border_w

    box = Box(w, height, depth)
    fillet(plate.edges().filter_by(Axis.Z), radius=3)

    wall_face = plate.faces().sort_by(Axis.Z)[0]
    room_face = plate.faces().sort_by(Axis.Z)[-1]
    offset(amount=-thick, openings=wall_face)

    # Place the screw supports
    plate_clearance = 2.5 # Distance between wall and screw supports
    with GridLocations(x_spacing=width, x_count=len(gangs), y_spacing=width + 2*IN, y_count=2):
        with Locations(wall_face.offset(-plate_clearance)):
            c = Cylinder(radius=5, height=depth-plate_clearance,
                    align=(Align.CENTER, Align.CENTER, Align.MAX))
            wall_screws = c.faces().sort_by(Axis.Z)[0]

    # Place the gang switches
    with Locations(Plane.XY.offset(depth/2)):
        gang_locs = GridLocations(x_spacing=width, x_count=len(gangs), y_spacing=0, y_count=1)
        for n, loc in enumerate(gang_locs):
            g = gangs[n]
            s = g.bounding_box().size
            loc = Location(loc.position + (0, 0, -s.Z/2))
            with BuildPart(loc, mode=Mode.SUBTRACT) as gang_cutout:
                b = Box(*s)
            with BuildPart(loc) as gang_switch:
                add(g)
            # hack to add a border that closes a visual gap to screws
            # decora rocker switch border is 66.5mm x 33mm
            with BuildPart(loc) as border:
                z = loc.position.Z - wall_screws.center().Z - 0.2
                bord = Box(33+1.3, 66.5+1.3, z, align=AlignCCT)
                bord = offset(amount=-0.6, openings=bord.faces().filter_by(Plane.XY))
                fillet(bord.edges().filter_by(Axis.Z), radius=0.25)

            # The rocker switch has a crossbar and needs clearance
            f = b.faces().sort_by(Axis.Z)[0]
            gang_clearance = abs(f.center().Z - wall_screws.center().Z)
            print('Gang clearance', gang_clearance)
            assert gang_clearance >= 5.89, "Insufficent clearance for gang"

    # Bore the screws
    with GridLocations(x_spacing=width, x_count=len(gangs), y_spacing=width+2*IN, y_count=2):
        with Locations((0, 0, wall_screws.center().Z + 3)):
            CounterSinkHole(radius=2, counter_sink_radius=4)

    # fillet where possible
    for num, edge in enumerate(plate.edges().filter_by(Axis.Z)):
        try:
            fillet([edge], radius=2)
        except Exception:
            continue
    chamfer(room_face.edges(), length=2)
    chamfer(plate.faces().sort_by(Axis.Z)[0].edges(), length=0.2)

    # For shim adjustment
    #with Locations(room_face.offset(-depth+1)):
    #    Box(w, height, depth, align=(Align.CENTER, Align.CENTER, Align.MIN), mode=Mode.SUBTRACT)



import os
os.chdir(os.path.dirname(__file__))

show([plate], reset_camera=Camera.KEEP)
export_stl(plate.part, 'wallplate.stl')