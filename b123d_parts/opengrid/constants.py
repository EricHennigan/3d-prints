from enum import Enum

from build123d import MM, Color

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