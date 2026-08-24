
import math

from build123d import *

from . import constants


class SnapCutter(BasePartObject):
    def __init__(self, ):
        self.side_profile = [
            (0.0, 0.0),
            (1.1, 0.0),
            (1.5, 0.4),
            (1.5, 1.4),
            (0.8, 2.4),
            (0.8, 3.4),
            (0.0, 3.4),
        ]
        shrink = 4.2 # Chamfer offset for cutting the corners
        self.corner_profile = [
            (-shrink, 0.0),
            (1.6, 0.0),
            (2.6, 1.4),
            (2.6, 3.4),
            (-shrink, 3.4),
        ]

        # The y-value of the side profile is half height
        assert constants.BASE_TYPE is constants.BaseType.NORMAL, "Only implemented for BaseType.Normal"
        assert self.side_profile[-1][-1] == constants.BASE_TYPE.height/2
        assert self.corner_profile[-1][-1] == constants.BASE_TYPE.height/2

        pts = [(x-constants.UNIT/2, z) for x,z, in self.side_profile]
        with BuildPart() as side_tool:
            with BuildSketch(Plane.YZ):
                with BuildLine():
                    Polyline(*pts, close=True)
                make_face()
            extrude(amount=constants.UNIT, both=True)
            mirror(about=Plane.XY.offset(constants.BASE_TYPE.height/2))
        self.side_tool = side_tool.part

        adj = (constants.UNIT - shrink) / math.sqrt(2)
        pts = [(x-adj, z) for x,z, in self.corner_profile]
        with BuildPart() as corner_tool:
            with BuildSketch(Plane.YZ.rotated((0,0,45))):
                with BuildLine():
                    Polyline(*pts, close=True)
                make_face()
            extrude(amount=constants.UNIT, both=True)
            mirror(about=Plane.XY.offset(constants.BASE_TYPE.height/2))
        self.corner_tool = corner_tool.part

        with BuildPart() as cutter:
            Box(constants.UNIT, constants.UNIT, constants.BASE_TYPE.height,
                align=(Align.CENTER, Align.CENTER, Align.MIN),
            )
            with PolarLocations(0, 4, angular_range=360, rotate=True):
                add(side_tool.part, mode=Mode.SUBTRACT)
            with PolarLocations(0, 4, angular_range=360, rotate=True):
                add(corner_tool.part, mode=Mode.SUBTRACT)

        super().__init__(cutter.part)
        self.color = constants.CUTTER_COLOR


if __name__ == "__main__":
    from ocp_vscode import show, set_port

    sc = SnapCutter()
    show([sc.side_tool, sc.corner_tool, sc])
    show(sc)

    export_stl(sc, "tmp_my.stl")
