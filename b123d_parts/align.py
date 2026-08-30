"""
Sketch Objects

name: align.py
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

from build123d import Align

# --- Set convenient 2d and 3d shorthand tuples on the Align class ------------
aligns = {
    'C': Align.CENTER,
    'L': Align.MIN,  # Left
    'R': Align.MAX,  # Right
    'F': Align.MIN,  # Front
    'K': Align.MAX,  # bacK
    'B': Align.MIN,  # Bottom
    'T': Align.MAX,  # Top
}

for x in 'LCR':
    for y in 'FCK':
        setattr(Align, f'{x}{y}', (aligns[x], aligns[y]))
        for z in 'BCT':
            setattr(Align, f'{x}{y}{z}', (aligns[x], aligns[y], aligns[z]))
