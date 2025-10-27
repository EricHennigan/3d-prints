from build123d import *

class BoxJoin(BasePartObject):
  """
  Create a box comb for joining two parts.
  """

  def __init__(
    self,
    xsize: float,
    ysize: float,
    fdepth: float,
    fwidth: float,
    clearance: float = 0.03,
    align: Align = (Align.CENTER),
    invert: bool = False,
  ):
    """
    The face of the join is xsize x ysize.
    Each finger is fwidth (in X-axis) across and fdepth (in Z-axis) long.

    A clearance amount is taken from the width and depth of the fingers.
    """

    with BuildPart() as p:
      if invert:
        a = (Align.CENTER, Align.CENTER, Align.MIN)
        Box(xsize, ysize, fdepth-clearance, align=a)

      fnum = int(xsize/fwidth)
      fnum = 2 * int(fnum/2) + 1 # force odd number for alignment
      with GridLocations(
          x_spacing=2*fwidth, x_count=fnum,
          y_spacing=0, y_count=1,
      ) as locs:
        a = (align, Align.CENTER, Align.MIN)
        m = {False: Mode.ADD, True: Mode.SUBTRACT}[invert]
        c = {False: -1, True: 1}[invert] * clearance
        Box(fwidth+c, ysize, fdepth-clearance, mode=m, align=a)

      # trim any excess
      a = (Align.CENTER, Align.CENTER, Align.MIN)
      Box(xsize, ysize, fdepth, align=a, mode=Mode.INTERSECT)

    super().__init__(part=p.part)


if __name__ == '__main__':
  from ocp_vscode import *
  with BuildPart() as p:
    Box(20, 3, 6, align=(Align.MIN, Align.MIN, Align.MIN))

    top_face = p.faces().sort_by(Axis.Z)[-1]
    with Locations(top_face):
      j0 = BoxJoin(20, 3, fwidth=5, fdepth=5, align=Align.MIN)
      j0.color = Color('red')

    with Locations(top_face.offset(5)):
      j1 = BoxJoin(20, 3, fwidth=5, fdepth=2, align=Align.MIN, invert=True)
      j1.color = Color('blue')

  show_all(reset_camera=Camera.KEEP)
