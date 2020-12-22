// doors and windows

include <../constants.scad>
use <../scale.scad>

// A typical human-sized door
module steel_door(width=36, height=80, window=false, thickness=.75) {
    translate([0, 0, inch(2)])
    difference() {
        cube([inch(width + 6), inch(height + 3), inch(1.5)]);
        translate([inch(3), -0.01, -0.05])
        cube([inch(width), inch(height), inch(1.5)+0.1]);
    }
    
    translate([inch(2), 0, 0])
    cube([inch(width + 2), inch(height + 0.1), thickness]);
    
}