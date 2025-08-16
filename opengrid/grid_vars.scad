// TODO: add support for Bill Of Materials
trim = 0.001;

/* [Board Size] */
Board_Style = "Lite"; //[Full, Lite]
Board_Width = 2;
Board_Height = 2;

/* [Advanced: Tile Parameters] */
Full_Thickness = 6.8;
Lite_Thickness = 4.0;
Tile_Thickness = Board_Style == "Full" ? Full_Thickness : Lite_Thickness;
Tile_Size = 28;

/* [Chamfer Options] */
Chamfer_TL = true;
Chamfer_TR = true;
Chamfer_BL = true;
Chamfer_BR = true;

/* [Connector Options] */
Connectors_T = true;
Connectors_R = true;
Connectors_B = true;
Connectors_L = true;
