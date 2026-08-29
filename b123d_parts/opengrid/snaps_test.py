"""Verification tests: b123d Snap() vs Shapr3D reference part(s).

Compares the build123d ``Snap`` (snaps.py) against the ground-truth Shapr
reference STEP(s) under ``refs/.../Snap modeling files`` across layered checks:

  - placement  : centered on origin, seated on z=0
  - size       : bounding box matches 25.6 x 25.6 x 6.8
  - volume     : global volume within a tight % tolerance
  - fidelity   : cross-sectional area matches at every xyz-band (+/- 2 mm^2)
  - topology   : the model is a single fused solid (ref is a 9-solid compound)

The suite is parameterized over reference file(s) (each paired with a model
builder) so additional snap variants can be added to TEST_CASES.

Run with pytest:
    pytest opengrid/snaps_test.py -v
"""

import os
import pytest
import sys
import tempfile
import requests
import zipfile
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

from build123d import Box, Location, ShapeList, import_step

from .snaps import Snap



REF_LINK = 'https://files.printables.com/media/prints/1214361/packs/6265667_eaed4818-d267-4590-a38d-c7c6be00e076/opengrid-walldesk-mounting-framework-and-ecosystem-model_files.zip'

def _download(url):
  dest = Path(tempfile.gettempdir()) / 'opengrid_refs' / 'files.zip'
  dest.parent.mkdir(parents=True, exist_ok=True)
  headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
  }
  if not dest.exists():
      print('Downloading ', REF_LINK, ' -> ', str(dest))
      with requests.get(url, headers=headers, stream=True, timeout=120) as r:
          r.raise_for_status()
          with open(dest, 'wb') as f:
              for chunk in r.iter_content(chunk_size=1 << 20): # 1 MiB
                  f.write(chunk)

      with zipfile.ZipFile(dest) as zf:
          zf.extractall(dest.parent)

  return dest.parent


REF_STEP_DIR = _download(REF_LINK) / 'Snap modeling files'


def _cross_section_area(shape, pos, axis, thickness=0.02):
    """Area of ``shape``'s horizontal cross-section at height ``z`` (mm^2).

    Computed as (volume of shape intersected with a thin slab at z) / thickness,
    which is robust for both a fused solid and a multi-solid compound.
    """
    d = {
        "X": (thickness, 1000, 1000),
        "Y": (1000, thickness, 1000),
        "Z": (1000, 1000, thickness),
    }[axis]
    loc = {
        "X": (pos, 0, 0),
        "Y": (0, pos, 0),
        "Z": (0, 0, pos),
    }[axis]
    slab = Box(*d).moved(Location(loc))
    res = shape.intersect(slab)
    sols = res.solids() if isinstance(res, ShapeList) else [res]
    return sum(s.volume for s in sols) / thickness


TEST_CASES = {
  'opengrid-bare-snap.step': lambda: Snap(),
}

@pytest.mark.parametrize(
  "fname",
  TEST_CASES.keys()
)
class TestSnapAgainstRef:
    """Compare the model against the (parametrized) reference part."""

    @pytest.fixture(autouse=True)
    def setup_models(self, fname):
      self.path = REF_STEP_DIR / fname
      self.step = import_step(str(self.path))
      self.part = TEST_CASES[fname]()

    def test_bbox_size(self, tol=0.001):
        """Both parts have the same size in each dimension."""
        part_bb = self.part.bounding_box()
        step_bb = self.step.bounding_box()
        for axis in "XYZ":
            got = getattr(part_bb.size, axis)
            want = getattr(step_bb.size, axis)
            assert abs(got - want) < tol, (
                f"bbox size {axis}={got:.4f} vs ref {want:.4f} (tol {tol})")

    def test_bbox_placement(self, tol=0.0001):
        """Both parts are centered on the origin."""
        part_bb = self.part.bounding_box()
        step_bb = self.step.bounding_box()
        for axis in "XYZ":
            got = getattr(part_bb.center(), axis)
            want = getattr(part_bb.center(), axis)
            assert abs(got - want) < tol, (
                f"bbox center {axis}={got:0.4f} vs ref {want:.4f} (tol {tol})")
        assert abs(part_bb.min.Z) < tol, "part not seated on z=0"
        assert abs(step_bb.min.Z) < tol, "ref not seated on z=0"

    def test_relative_volume(self, rel_tol=0.05/100):
        """Model volume matches the reference within a tight relative tolerance."""
        got = self.part.volume
        want = self.step.volume
        err = abs(got - want) / want
        assert abs(got - want) / want < rel_tol, (
            f"volume {got:.4f} vs ref {want:.4f} "
            f"(rel err {err:.4%} > {rel_tol:.4%})")

    def test_com(self, tol=0.0005):
        """Centroid z matches the reference; x/y are ~0 by symmetry."""
        part_c = self.part.center()
        step_c = self.step.center()
        for axis in "XYZ":
            got = getattr(part_c, axis)
            want = getattr(step_c, axis)
            assert abs(got - want) < tol, (
                f"CoM {axis}={got:0.4f} vs ref {want:0.4f} (tol {tol}")

    def test_cross_sections(self, tol=0.5):
        bb = self.step.bounding_box()
        bands = []
        for axis in "XYZ":
            min_v = int(getattr(bb.min, axis))*10 + 2 # stay away from min face
            max_v = int(getattr(bb.max, axis))*10
            for v in range(min_v, max_v, 2):
                bands.append((axis, v / 10.))
        worst, worst_b = 0.0, None

        # There are a bunch of cross-sections, processes avoid GIL
        with ProcessPoolExecutor(
            max_workers=os.cpu_count(),
            initializer=_init_worker,
            initargs=(self.path,),
        ) as pool:
            for axis, b, delta in pool.map(_worker_check_band, bands):
                if delta > worst:
                    worst, worst_b = (delta, (axis, b))
        axis, band = worst_b
        assert worst < tol, (
            f"max cross-section |delta| {worst:.4f} mm^2 at {axis}={band:.1f} exceeds {tol}")

    def test_single_fused_solid(self):
        """The model is one fused solid."""
        assert len(self.part.solids()) == 1


def _init_worker(path):
    global _worker_step, _worker_part
    _worker_step = import_step(path)
    _worker_part = TEST_CASES[path.name]()


def _worker_check_band(band):
    axis, v = band
    part_area = _cross_section_area(_worker_part, v, axis)
    step_area = _cross_section_area(_worker_step, v, axis)
    return axis, v, abs(part_area - step_area)


if __name__ == "__main__":
    raise SystemExit(pytest.main([__file__, "-v", "-s"]))
