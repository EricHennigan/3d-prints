
# Existing Work
 - https://github.com/FrameworkComputer/Framework-Desktop/tree/main/Tiles
 - https://www.pri ntables.com/model/1402690-framework-desktop-3d-print-optimized-tile/files
 - https://www.printables.com/model/1378192-blank-triple-and-double-tiles-for-framework-deskto

# Framework Neural Network Tile

Really struggled with this one. Printing only looks good when the Neural Net design is on the TOP, but that means the clips are on the bottom, and the whole body is raised up and needs supports! Those were really challenging to work with. I attempted to add my own supports (the squares), they hit the clips and help hold those in place. Model is a tight fit. Supports in the slicer need to be spaced away from the clips and alignment pin, so that the support raft doesn't squish into those features.

The framework tile design specs don't have all the measurements! Ended up using their stl model to make measurements.

 - For airflow:
   ```
   Top shell layers: 0
   Bottom shell layers: 0
   Sparse infill density: 35%
   Sparse infill pattern: Honeycomb
   ```

 - For supports: manually painted (bucket fill) areas outside the squares
   ```
   Enable support: true
   Support/object xy distance: 0.6mm
   Support/object first layer gap: 0.6mm
   Don't support bridges: true
   ```

 - For a good-looking pattern:
   ```
   Layer height: 0.1mm
   First layer height: 0.1mm
   Pause at layer 34 for a color change
   ```
