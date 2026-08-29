from enum import Enum

from build123d import MM, Color, Align

UNIT = 28 * MM

class BaseType(Enum):
    LIGHT = 4.0 * MM
    NORMAL = 6.8 * MM
    HEAVY = 13.8 * MM

    @property
    def height(self) -> float:
        return self.value


BASE_TYPE = BaseType.NORMAL

CUTTER_COLOR = Color('#FF7E70')  # salmon

# Convenience Alignment tuples:
#  x: (Left, Center, Right)
#  y: (Front, Center, bacK)
#  z: (Bottom, Center, Top)
Align_CFB = (Align.CENTER, Align.MAX, Align.MIN)
Align_CKT = (Align.CENTER, Align.MIN, Align.MAX)
Align_CCB = (Align.CENTER, Align.CENTER, Align.MIN)
