"""
Sketch Objects

name: objects_sketch.py
by:   Eric Hennigan
date: 2026-08-30

desc:
    Module containing objects (classes) that create 2D Sketches.

License:

    Copyright (C) 2026 Eric Hennigan

    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the Free
    Software Foundation; either version 2 of the License, or (at your option)
    any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
    more details.
"""

from typing import Tuple

from build123d import Align
from build123d import BaseSketchObject
from build123d import BuildLine
from build123d import BuildSketch
from build123d import make_face
from build123d import Mode
from build123d import Polyline

class SlotChamfered(BaseSketchObject):
    """Sketch Object: Slot Chamfered

    Create a slot defined by the overall width and height with chamfered sides.
    Similar to SlotOverall, but sides have 45deg chamfer rather than half-circle.

    Args:
      width (float): overall width of slot
      height (float): overall height of slot
      rotation (float, optional): angle to rotate the object. Defaults to 0
      align (Align | tuple[Align, Align], optional): align MIN, CENTER, or MAX of object.
          Defaults to (Align.CENTER, Align.CENTER)
      mode (Mode, optional): combination mode. Defaults to Mode.ADD
    """

    _applies_to = [BuildSketch._tag]

    def __init__(self,
        width: float,
        height: float,
        rotation: float = 0,
        align: Align | Tuple[Align, Align] | None = (Align.CENTER, Align.CENTER),
        mode = Mode.ADD,
    ):
        if width < height:
            raise ValueError(f"slot requires that width > height. Got {width=}, {height=}")

        self.width = width
        self.slot_height = height

        pts = [
          (width/2,           height/2),
          (width/2+height/2,  0),
          (width/2,           -height/2),
          (-width/2,          -height/2),
          (-width/2-height/2, 0),
          (-width/2,          height/2),
        ]
        with BuildSketch() as slot:
            with BuildLine():
                Polyline(*pts, close=True)
            make_face()

        super().__init__(slot.sketch, rotation, align, mode)

