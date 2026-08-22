
# 2026-08-22 Working out the dimensions

| Shelf | Width | Height | Depth |
|-------|-------|--------|-------|
| top   |  900  |  540   |  580  |
| m1    |  900  |  470   |  580  |


Kuggis Boxes:
| Size  | Width | Depth | Height |
|-------|-------|-------|--------|
| Small |  130  |  180  |   80   |
| Med   |  180  |  260  |   80   |
| Large |  260  |  350  |  150   |

openGrid size is 28:
1,   2,  3,   4,   5,   6,   7,   8,   9,  10
28, 56, 84, 112, 140, 168, 196, 224, 252, 280

Since I need room for horizontal support and fingers to grab the boxes,
we have spaces that look like:
 - Height: 4 grids (not 3)
 - Depth:  9 grids (nearly the 260 for Med box)

the m1 shelf is 16.78 grids high, so openGrid plates of 8 x 9 will work

# 2026-08-22 Working 

Print:
 - 9x8, "Heavy", ScrewMounting="None"
