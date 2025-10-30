
'''
Single Gang mold for holding the Phillips Hue dimmer remote.
'''

from build123d import *
from ocp_vscode import *

class HueRocker(Compound):
    def __init__(self):
        height = 91.7
        width = 34.7
        depth = 5.6
        recess = 2.5

        ALIGN_TOP = (Align.CENTER, Align.CENTER, Align.MAX)

        with BuildPart() as block:
            Box(width+2, height, depth)
            RigidJoint(
                label="center",
                joint_location=Location((0,0,depth/2)),
            )
            bot_face = block.faces().sort_by(Axis.Z)[0]

            top_face = block.faces().sort_by(Axis.Z)[-1]
            with BuildPart(top_face, mode=Mode.SUBTRACT) as face_cutout:
                Box(width-.01, height-.01, recess, align=ALIGN_TOP)
            edges = face_cutout.faces().sort_by(Axis.Z)[0].edges()
            edges += face_cutout.edges().filter_by(Axis.Z)
            fillet(edges, radius=recess-.01)

            top_face = -face_cutout.faces().sort_by(Axis.Z)[0]

            buffer = .2
            # put the center of the slot 5.5 from the end of the object
            with BuildPart(top_face, mode=Mode.SUBTRACT) as slot_cutout:
                with Locations((0, height/2 - 5.5, 0)):
                    b = Box(26, 1 + 2*buffer, 1, align=ALIGN_TOP)
            fillet(slot_cutout.edges().filter_by(Axis.Z), radius=2*buffer)

            # Decora rocker switch border is 66.5mm x 33mm
            center_bar_height = 18
            with BuildPart(mode=Mode.SUBTRACT) as interior:
                h = 66.5/2 - center_bar_height/2
                with Locations((0, center_bar_height/2)):
                    b = Box(33, h, depth, align=(Align.CENTER, Align.MIN, Align.CENTER))
                    fillet(b.edges().filter_by(Axis.Z), radius=2)
                mirror(interior.part, about=Plane.XZ)

            thick = .55
            with BuildPart(top_face.offset(-thick), mode=Mode.SUBTRACT) as magnet:
                c = Cylinder(radius=7.6, height=depth, align=ALIGN_TOP)
                mag_face = c.faces().sort_by(Axis.Z)[-1]

            mag_depth = abs(bot_face.center().Z - mag_face.center().Z)
            print('Magnet depth', mag_depth)
            assert mag_depth > 2.5, 'insufficent space for magnet'


        super().__init__(block.part.wrapped, joints=block.part.joints)


if __name__ == '__main__':
    hr = HueRocker()

    show_object([hr], reset_camera=Camera.KEEP)
    sys.exit(0)

    with BuildPart() as part:
        Box(*hr.bounding_box().size)

    show_object([part], reset_camera=Camera.KEEP)
    