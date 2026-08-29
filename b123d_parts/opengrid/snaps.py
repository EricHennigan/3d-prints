"""Build123d port of QuackWorks' openGrid snap connector.

Reference: refs/QuackWorks/openGrid/opengrid-snap.scad
Analysis/plan: snap-plan.md (the scad instantiates lite=True, directional=True)
"""

import math

from build123d import *

from . import constants

class Bump(BasePartObject):
    def __init__(self, **kwargs):
        with BuildPart() as bump:
            Box(10.8, 0.4001, 2.0)
            front = lambda: bump.faces().sort_by(Axis.Y)[-1]
            chamfer(front().edges().filter_by(Axis.Z), length=0.4, length2=2)
            chamfer(front().edges().filter_by(Axis.X), length=0.4, length2=0.6)
            fillet(front().edges().filter_by(Axis.Z), radius=15)

        super().__init__(bump.part, **kwargs)


class SlotCutter(BasePartObject):
    height = constants.BASE_TYPE.height

    def __init__(self, **kwargs):
        with BuildPart() as slot:
            with BuildSketch(Plane.XY):
                SlotOverall(11.8 + 0.6, 0.6)
            extrude(amount=self.height-0.6)
            with BuildSketch(Plane.XZ.moved(Location((0, self.height-1.0, 0)))):
                Rectangle(12, 0.4)
            extrude(amount=-1)

        super().__init__(slot.part, **kwargs)
        self.color = constants.CUTTER_COLOR


class Snap(BasePartObject):
    shrink = 4.2 # Chamfer offset for cutting the corners
    height = constants.BASE_TYPE.height
    corner_profile = [
        (-shrink, 0.0),
        (2.7, 0.0),
        (2.7, height-1.5),
        (1.6, height-.4),
        (1.6, height),
        (-shrink, height),
    ]
    size = constants.UNIT - 3.2

    def __init__(self):
        adj = (constants.UNIT - self.shrink) / math.sqrt(2)
        pts = [(x-adj, z) for x,z in self.corner_profile]
        with BuildPart() as corner_tool:
            with BuildSketch(Plane.YZ.rotated((0,0,45))):
                with BuildLine():
                    Polyline(*pts, close=True)
                make_face()
            extrude(amount=constants.UNIT, both=True)
        self.corner_tool = corner_tool.part
        self.corner_tool.color = constants.CUTTER_COLOR

        self.slot_tool = SlotCutter(align=constants.Align_CFB)\
            .moved(Location((0, self.size/2, 0)))
        self.bump_part = Bump(align=constants.Align_CKT)\
            .moved(Location((0, self.size/2, self.height-1.4)))

        with BuildPart() as cutter:
            Box(self.size, self.size, self.height, align=constants.Align_CCB)
            with PolarLocations(0, 4, angular_range=360, rotate=True):
                add(corner_tool.part, mode=Mode.SUBTRACT)
                add(self.slot_tool, mode=Mode.SUBTRACT)
                add(self.bump_part, mode=Mode.ADD)

        super().__init__(cutter.part)


if __name__ == "__main__":
    from ocp_vscode import show
    snap = Snap()
    show(snap)
