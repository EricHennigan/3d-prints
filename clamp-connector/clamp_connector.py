'''
Connects the ends of two bar clamps.
 - Caveat: have to use the socket parts of the existing ends
 - https://amazon.com/HORUSDY-Leveling-Connector-Woodworking-Compatible/dp/B0DMR17Z3S/
'''

from build123d import *
from ocp_vscode import *

length, width, thickness = 80.0, 60.0, 10.0

sx, sy, sz = 30.5, 30.5, 26.0

with BuildPart() as clamp_connector:

    with BuildSketch(Location((0, -1, 0))) as r0:
        Rectangle(sx, sy+2)
        chamfer(r0.vertices().sort_by(Axis.Y)[-2:], length=2.5)
    with BuildSketch(Plane.XY.offset(4)) as r1:
        Rectangle(sx+4, sy+4)
        chamfer(r1.vertices().sort_by(Axis.Y)[-2:], length=4)
    with BuildSketch(Plane.XY.offset(sz-2.5-4)) as r2:
        Rectangle(sx+4, sy+4)
        chamfer(r2.vertices().sort_by(Axis.Y)[-2:], length=4)
    with BuildSketch(Location((0, -1, sz-2.5))) as r3:
        Rectangle(sx, sy+2)
        chamfer(r3.vertices().sort_by(Axis.Y)[-2:], length=2.5)
    with BuildSketch(Location((0, -1, sz))) as r4:
        Rectangle(sx, sy+2)
        chamfer(r4.vertices().sort_by(Axis.Y)[-2:], length=2.5)
    loft(ruled=True)

    border = 3.25
    with BuildSketch(Plane.XY.offset(sz)) as hole_top:
        Rectangle(sx-border, sy-border)
        fillet(hole_top.vertices(), radius=2)
    extrude(amount=-10.5, mode=Mode.SUBTRACT)

    with BuildSketch(Plane.XY.offset(sz-10.5)) as spring:
        Circle(9.4/2)
    extrude(amount=2)

    with BuildSketch() as hole_bot:
        Rectangle(sx-border, sy-border)
        fillet(hole_bot.vertices(), radius=2)
    extrude(amount=7, mode=Mode.SUBTRACT)

    with BuildSketch(Plane.XY.offset(7)) as guide:
        Circle(10/2)
    extrude(amount=-0.8)

    with BuildSketch() as center_hole:
        Circle(5.5/2)
    extrude(amount=sz, mode=Mode.SUBTRACT)

    with BuildSketch(Location((10.65, 0, 0))) as top_screw:
        Circle(4.75/2)
    extrude(amount=sz, mode=Mode.SUBTRACT)

    with BuildSketch(Location((-10.65, 0, 0))) as bot_screw:
        Circle(4.75/2)
    extrude(amount=sz, mode=Mode.SUBTRACT)


    mirror(clamp_connector.part, about=Plane.XZ.offset(sy/2+2))

    pts = [
        (0, 0),
        (0, 1.6),
        (3, 1.6),
        (7.3-3.4, 2.75),
        (7.3, 2.75),
        (7.3, 0),
    ]
    #with BuildSketch(Plane.XZ) as ibeam:
    with BuildSketch(clamp_connector.faces().sort_by(Axis.Y)[0]) as ibeam:
        with BuildLine() as ln:
            l1 = Polyline(pts)
            l2 = Line(l1 @ 1, l1 @ 0)
            #mirror(ln.line, about=Plane.YZ)
        make_face()
        mirror(about=Plane.XZ)
        mirror(about=Plane.YZ)
    extrude(amount=-2*(sy+4), mode=Mode.SUBTRACT)

    with BuildSketch(Location((0, -sy/2+0.5, sz))) as txt:
        Text("Push", font_size=7, align=(Align.CENTER, Align.MAX))
    extrude(amount=-0.5, mode=Mode.SUBTRACT)

show_object(clamp_connector, reset_camera=Camera.KEEP)
export_stl(clamp_connector.part, 'clamp_connector.stl')
