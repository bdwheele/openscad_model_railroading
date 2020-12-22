include <constants.scad>
use <scale.scad>
use <buildings/siding.scad>
use <buildings/doors_windows.scad>

$SCALE="ho";
$MIN_THICKNESS=0.1;

/*
translate([48, 0, 0])
metal_siding_1_peak(8, 8, holes=[[2.5, 0.25, 3, 6.66]], pitch=5);

translate([-40, 0, 0])
metal_siding_1_peak(8, 8, pitch=5);

translate([0, 40, 0])
metal_siding_1(12, 8);

translate([0, -40, 0])
metal_siding_1(12, 8);

translate([0, 20, 0])
metal_roofing_1(12, 4, 5);

metal_roofing_1(12, 4, 5);
*/

steel_door();
