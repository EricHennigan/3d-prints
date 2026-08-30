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

Align_LF  = (Align.MIN,    Align.MIN)
Align_LC  = (Align.MIN,    Align.CENTER)
Align_LK  = (Align.MIN,    Align.MAX)

Align_CF  = (Align.CENTER, Align.MIN)
Align_CC  = (Align.CENTER, Align.CENTER)
Align_CK  = (Align.CENTER, Align.MAX)

Align_RF  = (Align.MAX,    Align.MIN)
Align_RC  = (Align.MAX,    Align.CENTER)
Align_RK  = (Align.MAX,    Align.MAX)

Align_LFB = (Align.MIN,    Align.MIN,    Align.MIN)
Align_LFC = (Align.MIN,    Align.MIN,    Align.CENTER)
Align_LFT = (Align.MIN,    Align.MIN,    Align.MAX)

Align_LCB = (Align.MIN,    Align.CENTER, Align.MIN)
Align_LCC = (Align.MIN,    Align.CENTER, Align.CENTER)
Align_LCT = (Align.MIN,    Align.CENTER, Align.MAX)

Align_LKB = (Align.MIN,    Align.MAX,    Align.MIN)
Align_LKC = (Align.MIN,    Align.MAX,    Align.CENTER)
Align_LKT = (Align.MIN,    Align.MAX,    Align.MAX)

Align_CFB = (Align.CENTER, Align.MIN,    Align.MIN)
Align_CFC = (Align.CENTER, Align.MIN,    Align.CENTER)
Align_CFT = (Align.CENTER, Align.MIN,    Align.MAX)

Align_CCB = (Align.CENTER, Align.CENTER, Align.MIN)
Align_CCC = (Align.CENTER, Align.CENTER, Align.CENTER)
Align_CCT = (Align.CENTER, Align.CENTER, Align.MAX)

Align_CKB = (Align.CENTER, Align.MAX,    Align.MIN)
Align_CKC = (Align.CENTER, Align.MAX,    Align.CENTER)
Align_CKT = (Align.CENTER, Align.MAX,    Align.MAX)

Align_RFB = (Align.MAX,    Align.MIN,    Align.MIN)
Align_RFC = (Align.MAX,    Align.MIN,    Align.CENTER)
Align_RFT = (Align.MAX,    Align.MIN,    Align.MAX)

Align_RCB = (Align.MAX,    Align.CENTER, Align.MIN)
Align_RCC = (Align.MAX,    Align.CENTER, Align.CENTER)
Align_RCT = (Align.MAX,    Align.CENTER, Align.MAX)

Align_RKB = (Align.MAX,    Align.MAX,    Align.MIN)
Align_RKC = (Align.MAX,    Align.MAX,    Align.CENTER)
Align_RKT = (Align.MAX,    Align.MAX,    Align.MAX)

