from build123d import *
from ocp_vscode import *


class TraptailJoin(BasePartObject):
    """
    Create a Dovetail made of trapezoids.

    Args:
    - xsize (float): The x-axis length of the joined edge.
    - ysize (float): The y-axis height of the joined edge.
    - teeth (float): Total number of teeth along the join.

    - xlen (float, optional): The x-axis length of the top of the tooth. Default = xsize / (3*teeth).
    - ylen (float, optional): The y-axis height of the top of the tooth. Default = ysize / 6.
    - depth (float, optional): The z-axis depth of the dovetail. Default = ysize / 2.
    - clearance (float, optional): An offset subtracted from each tooth so that opposing parts can mesh together..
    - align (Align, optional): Align the x-axis of the teeth. Default = Align.CENTER.
    """

    def __init__(
        self,
        xsize: float,
        ysize: float,
        teeth: int,
        xlen: float | None = None,
        ylen: float | None = None,
        depth: float | None = None,
        clearance: float = 0.03,
        align: Align = (Align.CENTER),
        invert: bool = False,
    ):
        if not xlen:
            xlen = xsize / teeth / 3
        if not ylen:
            ylen = ysize / 6 # 45deg
        if not depth:
            depth = ysize / 2
        xspace = xsize / teeth - xlen

        assert xlen * teeth < xsize, 'xlen is too large for given number of teeth'
        assert xlen <= xspace, 'xlen is too large compared to base of tooth'

        with BuildPart() as p:
            with GridLocations(
                x_spacing=xspace+xlen, x_count=teeth+1,
                y_spacing=0, y_count=1,
            ):
                edge = {False: 1, True: -1}[invert] * (ylen/2 + clearance)
                zmin = {False: 0, True: ysize-2*ylen}
                zmax = {False: ylen, True: ysize-ylen}

                with Locations((0, edge, -clearance)):
                    Wedge(xspace, depth, ysize-ylen,
                        xmin=(xspace-xlen)/2, xmax=(xspace+xlen)/2,
                        zmin=zmin[invert], zmax=zmax[invert],
                        align=(align, Align.MIN, Align.CENTER),
                        rotation=(90, 0, 0),
                    )

                sign = {Align.CENTER: 1, Align.MAX: 1, Align.MIN: -1}[align]
                with Locations((sign*(xspace+xlen)/2, -edge, -clearance)):
                    Wedge(xspace, depth, ysize-ylen,
                          xmin=(xspace-xlen)/2, xmax=(xspace+xlen)/2,
                          zmin=zmin[not invert], zmax=zmax[not invert],
                          align=(align, Align.MIN, Align.CENTER),
                          rotation=(90, 0, 0),
                    )

            if clearance:
                offset(p.part, -clearance, kind=Kind.INTERSECTION)

            # Cut off the extra
            with Locations((xsize/2, 0, 0)):
                Box(xsize, ysize, depth, align=(Align.MIN, Align.CENTER, Align.MIN), mode=Mode.SUBTRACT)
            with Locations((-xsize/2, 0, 0)):
                Box(xsize, ysize, depth, align=(Align.MAX, Align.CENTER, Align.MIN), mode=Mode.SUBTRACT)

        super().__init__(part=p.part)


if __name__ == '__main__':
    with BuildPart() as p:
        Box(24, 3, 6, align=(Align.MIN, Align.MIN, Align.MIN))

        top_face = p.faces().sort_by(Axis.Z)[-1]
        #fillet(top_face.edges(), 0.2)

        with Locations(top_face):
            tj0 = TraptailJoin(24, 3, teeth=2, align=Align.CENTER)
            tj0.color = Color('red')

        with Locations(-top_face.offset(1.5)):
            tj1 = TraptailJoin(24, 3, teeth=2, align=Align.CENTER)
            tj1.color = Color('blue')

    show_object([p, tj0, tj1], reset_camera=Camera.KEEP)
