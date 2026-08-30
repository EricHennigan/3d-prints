"""Build123d port of QuackWorks' openGrid snap connector.

Reference: refs/QuackWorks/openGrid/opengrid-snap.scad
Analysis/plan: snap-plan.md (the scad instantiates lite=True, directional=True)
"""

import math
from dataclasses import dataclass

from build123d import *

import align
from objects_sketch import SlotChamfered

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

    def __init__(self, **kwargs):
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

        self.slot_tool = SlotCutter(align=Align.CKB, mode=Mode.PRIVATE)\
            .moved(Location((0, self.size/2, 0)))
        self.bump_part = Bump(align=Align.CFT, mode=Mode.PRIVATE)\
            .moved(Location((0, self.size/2, self.height-1.4)))

        with BuildPart() as cutter:
            Box(self.size, self.size, self.height, align=Align.CCB)
            with PolarLocations(0, 4, angular_range=360, rotate=True):
                add(corner_tool.part, mode=Mode.SUBTRACT)
                add(self.slot_tool, mode=Mode.SUBTRACT)
                add(self.bump_part, mode=Mode.ADD)

        super().__init__(cutter.part, **kwargs)


@dataclass(frozen=True)
class CardboardParams:
    """The Cardboard snap is 3 pieces: snap, flange, domino.

    This class helps those pieces coordinate on dimensions.
    """
    domino_width: float = 3
    domino_length: float = constants.UNIT - 10
    domino_clearance: float = 0.05
    domino_recess: Vector = Vector(0, 0, 1)
    domino_pos: Vector = Vector(0, constants.UNIT/4, 0)

    shelf_thickness: float = 5.5 # the min thickness of the expected cardboard stock

    flange_thickness: float = 6  # how much height above the front face of the snap
    flange_feather_width: float = 1

    def domino_size(self, cutter: bool = False) -> Vector:
        return Vector(
            self.domino_length + cutter * self.domino_clearance,
            self.domino_width + cutter * self.domino_clearance,
            self.flange_thickness + constants.BASE_TYPE.height - self.domino_recess.Z,
        )


class CardboardDomino(BasePartObject):
    """A domino part that holds the CardboardSnap to CardboardFlange.

    The domino has 45deg chamfer so that it can be printed flat and supply strength.

    Args:
        - cutter: will pad the XY dimensions so it can used as cutting tool.
        - params: CardboardParams that coordinate sizing across Cardboard parts.
    """

    def __init__(self, cutter=False, params=CardboardParams(), **kwargs):
        self.params = params
        size = self.params.domino_size(cutter)

        with BuildPart() as domino:
            with BuildSketch(Plane.XY):
                SlotChamfered(size.X, size.Y)
            extrude(amount=size.Z)

        super().__init__(domino.part, **kwargs)
        if cutter:
            self.color = constants.CUTTER_COLOR


class CardboardSnap(BasePartObject):
    """Take the bare Snap and cut some domino holes in it.

    Design notes:
        - Chamfers the tops of the domino hole for easier insertion.

    Args:
        - params: CardboardParams that coordinate sizing across Cardboard parts.
    """
    def __init__(self, params=CardboardParams(), **kwargs):
        self.params = params

        self.domino_cutter = CardboardDomino(
            cutter=True,
            align=Align.CCB,
            mode=Mode.PRIVATE
        ).moved(Location(self.params.domino_pos + self.params.domino_recess))

        with BuildPart() as snap:
            Snap()
            with PolarLocations(0, 2, angular_range=360, rotate=True):
                add(self.domino_cutter, mode=Mode.SUBTRACT)

            # chamfer for easy insertion
            edges = snap.edges(Select.LAST)\
                .filter_by(Plane.XY)\
                .filter_by(lambda e: e.center().Z > self.params.domino_recess.Z)
            chamfer(edges, length=0.3, length2=1.0)

        super().__init__(snap.part, **kwargs)


class CardboardFlange(BasePartObject):
    """A Flags with featherboard that permits 3-4mm cardboard to pass.

    Design notes:
        - Wanted to use a featherboard to flex with larger cardboard pieces, but
          it turns out that cardboard is pretty soft and the feathers are pretty
          stiff, so that's not working as intended.
        - Also wanted the feathers to prevent the shelf panel from pulling out
          with any item being dragged off the shelf. But it turns out the fillet
          doesn't catch on the cardboard as intended.

    Args:
        - params: CardboardParams that coordinate sizing across Cardboard parts.
    """

    def size(self):
        return constants.UNIT / 2 - self.params.shelf_thickness

    def feather_spacing(self, copies):
      """Compute the spacing for feathers"""
      thick = self.params.flange_feather_width
      return thick + (self.params.domino_size().X - copies * thick) / copies

    def feather_length(self):
      return self.size() / math.sqrt(2)

    def __init__(self, params=CardboardParams(), **kwargs):
        self.params = params
        self.domino_cutter = CardboardDomino(
            cutter=True,
            align=Align.CCB,
            mode=Mode.PRIVATE
        )

        copies = 8
        dx = self.feather_spacing(copies)
        adj = self.params.domino_size().X / 2 - dx
        feather_locs = [(i * dx - adj, 0, 0) for i in range(copies+2)]

        with BuildPart() as flange:
            # create some feathers
            with BuildSketch():
                with Locations(feather_locs):
                    SlotOverall(
                      height=self.params.flange_feather_width,
                      width=self.feather_length(),
                      align=Align.RC,
                      rotation=45)
            extrude(amount=6)

            # cutoff feathers exceeding the snap
            with BuildSketch():
                with Locations([(0, 2, 0)]):
                    Rectangle(
                        height=constants.UNIT/2 - self.params.shelf_thickness,
                        width=Snap.size, align=Align.CK)
            extrude(amount=6, mode=Mode.INTERSECT)

            # put a box around the domino slot
            with BuildSketch():
                with Locations([(0, 0, 0)]):
                    Rectangle(
                        height=self.size()/2,
                        width=Snap.size,
                        align=Align.CF)
                    Rectangle(
                        height=self.params.domino_width/2 + 1.2,
                        width=Snap.size,
                        align=Align.CK)
            extrude(amount=6)

            # cut a chamfer where the snap top face also has a chamfer
            c_length = 4.6 / math.sqrt(2)
            c_adj = self.size()/2 + self.params.domino_pos.Y - Snap.size/2
            snap_corners = flange.edges().filter_by(Axis.Z).sort_by(Axis.Y)[-2:]
            chamfer(snap_corners, length=c_length + c_adj)

            # round everything to avoid sharp corners
            fillet(flange.edges().filter_by(Axis.Z), radius=0.2)

            # cut out the domino, and chamfer for easy insertion
            add(self.domino_cutter, mode=Mode.SUBTRACT)
            edges = flange.edges(Select.LAST).filter_by(Plane.XY)
            chamfer(edges, length=0.3, length2=1.0)

            # emboss text to say the shelf_thickness
            with BuildSketch(Plane.XY.offset(self.params.flange_thickness)):
                with Locations([(0, self.params.domino_width + .1, 0)]):
                    Text(f"{self.params.shelf_thickness} mm", font_size=2.5)
            extrude(amount=-0.21, mode=Mode.SUBTRACT)

        super().__init__(flange.part, **kwargs)


def cardboard_assembly():
    height = constants.BASE_TYPE.height
    d = CardboardParams.domino_pos.Y
    h = CardboardParams.domino_recess.Z

    snap = CardboardSnap()
    snap.label = 'snap'
    flangeUp = CardboardFlange().moved(Location((0, d, height)))
    flangeUp.label = 'flange upper'
    flangeDn = CardboardFlange().moved(Location((0, -d, height)))
    flangeDn.label = 'flange lower'
    dominoUp = CardboardDomino().moved(Location((0, d, h)))
    dominoUp.label = 'domino upper'
    dominoDn = CardboardDomino().moved(Location((0, -d, h)))
    dominoDn.label = 'domino lower'

    asm = Compound(label="cardboard assembly", children=[
        snap, flangeUp, flangeDn, dominoUp, dominoDn,
    ])
    return asm


def cardboard_parts():
    """Create parts for distribution"""
    parts = {
        'cardboard_snap': CardboardSnap(),
        'cardboard_domino': CardboardDomino(),
    }
    for t in [2.5, 3.0, 3.5, 4, 4.5, 5, 5.5, 6.0]:
        params = CardboardParams(shelf_thickness = t)
        parts[f'cardboard_flange_s{int(t*10)}'] = CardboardFlange(params)
    return parts


if __name__ == "__main__":
    from ocp_vscode import show

    asm = cardboard_assembly()
    show([asm])

    for name, part in cardboard_parts().items():
        export_stl(part, f'/tmp/cardboard_snap/{name}.stl')
