

from build123d import *

def cut(
    part : BasePartObject, # the part to cut
    plane : Plane, # the plane of the cut
    kerf : float = 0.0, # the width of the sawblade
    join_cls : type = None, # the class that will create the join
    join_args : dict = dict(), # arguments to instantiate the join
    trim_dir: VectorLike = None, # direction to trim the joined interfaces
) -> Compound:
    # TODO: can we auto-compute the kerf?
    #       maybe the join_cls can have a method for it?

    p1 = part.split(plane.offset(-kerf/2), keep=Keep.BOTTOM)
    f1 = p1.faces().filter_by(plane)
    with BuildPart(plane.offset(-kerf/2)) as j1:
        if join_cls:
            join_cls(**join_args)
        if trim_dir:
            extrude(f1, amount=2*kerf, mode=Mode.INTERSECT, dir=trim_dir)
    p1 = p1 + j1.part

    p2 = part.split(plane.offset(kerf/2), keep=Keep.TOP)
    f2 = p2.faces().filter_by(plane)
    with BuildPart(plane.offset(kerf/2)) as j2:
        if join_cls:
            # TODO: detect if an invert param is needed?
            join_cls(**join_args, invert=True)
            mirror(about=plane.offset(kerf/2))
        if trim_dir:
            extrude(f2, amount=-2*kerf, mode=Mode.INTERSECT, dir=trim_dir)
    p2 = p2 + j2.part

    return Compound(children=[p1, p2])

