
'''
Single Gang mold for holding the Phillips Hue dimmer remote.
'''

from build123d import *
from ocp_vscode import *

class HueRocker(Compound):
    def __init__(self):
        height = 92.2
        width = 35.2
        depth = 10

        ALIGN_TOP = (Align.CENTER, Align.CENTER, Align.MAX)

        with BuildPart() as block:
            Box(width, height, depth)
            RigidJoint(
                label="center",
                joint_location=Location((0,0,depth/2)),
            )

            top_face = block.faces().sort_by(Axis.Z)[-1]
            with BuildPart(top_face, mode=Mode.SUBTRACT) as face_cutout:
                Box(width-.01, height-.01, 3, align=ALIGN_TOP)
            edges = face_cutout.faces().sort_by(Axis.Z)[0].edges()
            edges += face_cutout.edges().filter_by(Axis.Z)
            fillet(edges, radius=2.99)

            top_face = -face_cutout.faces().sort_by(Axis.Z)[0]

            loc = Location((0, height/2-6, depth/2-3))
            with BuildPart(loc, mode=Mode.SUBTRACT) as slot_cutout:
                Box(26, 2.25, 1, align=ALIGN_TOP)
            fillet(slot_cutout.edges().filter_by(Axis.Z), radius=0.75)

            with BuildPart(mode=Mode.SUBTRACT) as interior:
                Box(width-2*3, height-2*10, depth)

            with BuildPart(top_face) as center_bar:
                Box(width, 18, 3+.2+.2, align=ALIGN_TOP)
            with BuildPart(top_face.offset(-.2), mode=Mode.SUBTRACT):
                Cylinder(radius=7.6, height=4, align=ALIGN_TOP)

        super().__init__(block.part.wrapped, joints=block.part.joints)


if __name__ == '__main__':
    #show_object([HueRocker()], reset_camera=Camera.KEEP)

    hr = HueRocker()
    with BuildPart() as part:
        Box(*hr.bounding_box().size)

    show_object([part], reset_camera=Camera.KEEP)
    