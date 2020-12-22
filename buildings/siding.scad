// sections of building siding
include <../constants.scad>
use <../scale.scad>


/*
Metal building siding with this pattern:
                 <- 8"->
 ___   ___ ___   ___ ___   ___   
v   \_/   v   \_/   v   \_/   
      <- 16" -->

and 1 1/4" depth on major grooves, small depth on 'v' grooves.

Parameters:
* width = width of panel (in scale feet), rounded to multiples of 4 feet
* height = height of panel (in scale feet)
* left_edge = how the left edge should be treated (corner or butt joint)
* right_edge = how the right edge should be treated (corner or butt joint)
* holes = what holes to cut into the panel:  list of [h_offset, v_offset,
    width, height] quads measured in scale feet from the lower left corner
* crown = whether or not there's a crown on the panel.
* thickness = thickness of the panel, in real mm.


*/
module metal_siding_1(width, height, left_edge=JOINT_OUTSIDE, right_edge=JOINT_OUTSIDE, holes=[], crown=true, thickness=1.5) {
    width = floor(width / 4) * 4;  // round to lowest 4' boundary
    difference() {
        cube([foot(width), foot(height), thickness]);
        // major grooves   
        for(x = [4:16:width*12]) {
            translate([inch(x), foot(height + 0.05), thickness+0.01])
            rotate([90, 0, 0])
            linear_extrude(foot(height + 0.1)) 
            polygon(points=[[0, 0], [inch(8), 0], 
                            [inch(6), -inch(1.25)], [inch(2), -inch(1.25)]]);
        }
        // notch grooves
        for(x = [0 : 16 : width * 12]) {
            translate([inch(x), foot(height + 0.05), thickness + 0.01])
            rotate([90, 0, 0])
            cylinder(d=inch(1), h=foot(height + 0.1), $fn=64);
        }
        
        // left edge
        if(left_edge == JOINT_INSIDE) {
            translate([-0.1 , foot(height + 0.1), thickness])
            rotate([90, 90, 0])
            linear_extrude(foot(height + 0.2)) 
            polygon(points=[[-0.1, -0.1], 
                            [thickness + 0.2, -0.1], 
                            [-0.1, thickness + 0.2]]);
        } else if(left_edge == JOINT_OUTSIDE) {
            translate([-0.1, foot(height + 0.1), 0])
            rotate([90, 0, 0])
            linear_extrude(foot(height + 0.2)) 
            polygon(points=[[-0.1, -0.1], 
                            [thickness + 0.2, -0.1], 
                            [-0.1, thickness + 0.2]]);
        }
        
        // right edge
        if(right_edge == JOINT_INSIDE) {
            translate([foot(width) + 0.05 , foot(height + 0.1), thickness - 0.05])
            rotate([90, 180, 0])
            linear_extrude(foot(height + 0.2)) 
            polygon(points=[[-0.1, -0.1], 
                            [thickness + 0.1, -0.1], 
                            [-0.1, thickness + 0.1]]);

        } else if(right_edge == JOINT_OUTSIDE) {
            translate([foot(width), foot(height + 0.1), -0.05])
            rotate([90, 270, 0])
            linear_extrude(foot(height + 0.2)) 
            polygon(points=[[-0.1, -0.1], 
                            [thickness + 0.2, -0.1], 
                            [-0.1, thickness + 0.2]]);
        }
        
        // holes
        for(hole = holes) {
            translate([foot(hole[0]), foot(hole[1]), -0.1])
            cube([foot(hole[2]), foot(hole[3]), thickness + 0.2]);
        }        
    }
    if(crown == true) {
     t = 6;
     translate([0, foot(height) - inch(t/3), thickness])
     rotate([90, 0, 90])
     cylinder(d=inch(t), h=foot(width), $fn=6);   
    }
}

/*
This is the same as metal_siding_1, except that it includes a pitch parameter
(expressed in degrees) to allow for the ends of buildings with a roof profile.

*/
module metal_siding_1_peak(width, height, left_edge=JOINT_OUTSIDE, right_edge=JOINT_OUTSIDE, holes=[], crown=true, pitch=15, thickness=1.5) {

    // do the 4' rounding here so our height matches what metal_siding_1
    // thinks we're working with.
    width = floor(width / 4) * 4; 
    pheight = height + (sin(pitch) * width / 2);
    
    difference() {
        // build a wall the height of the pitch, with explicitly no crown
        metal_siding_1(width, pheight, left_edge, right_edge, holes, 
                       crown=false, thickness);
        // take away the material for the pitch
        translate([-0.01, foot(pheight) + 0.01, thickness+0.1])
        rotate([180, 0, 0])
        linear_extrude(thickness + 0.2)
        polygon([[0, 0],
                 [foot(width) / 2, 0],                 
                 [0, sin(pitch) * foot(width) / 2]]);
        translate([foot(width) + 0.01, foot(pheight) + 0.01, -0.1])
        rotate([180, 180, 0])
        linear_extrude(thickness + 0.2)
        polygon([[0, 0],
                 [foot(width) / 2, 0],                 
                 [0, sin(pitch) * foot(width) / 2]]);
    }
    if(crown == true) {
        t = 6;
        half = foot(width) / 2;        
        // left hand side
        multmatrix([[1, 0, 0, 0],
                    [sin(pitch), 1, 0, 0],
                    [0, 0, 1, 0]]) 
        translate([0, foot(height) - inch(t / 3), thickness])
        rotate([0, 90, 0])
        cylinder(d=inch(t), h=half, $fn=6);    
        // right hand side
        translate([half, foot(pheight) - inch(t/3), thickness])
        multmatrix([[1, 0, 0, 0],
                    [-sin(pitch), 1, 0, 0],
                    [0, 0, 1, 0]])    
        rotate([0, 90, 0])
        cylinder(d=inch(t), h=half, $fn=6);    
    }
}


/*
Create a section of metal roofing with the dimensions in scale feet.
Width must be a in units of a whole foot.  Height can be fractional feet.

If the pitch value is set, is will modify the height to be lengthened to 
fit a roof with that angle and will chamfer the edges for a flush fit.

thickness is the thickness of the panel in real mm.
*/
module metal_roofing_1(width, height, pitch=0, thickness=.5) {
    s = height * sin(pitch);
    height = pitch == 0? height : sqrt((s * s) + (height * height));
    width = floor(width);  // always round down.
 
    multmatrix([[1, 0, 0, 0],
                [0, 1, sin(pitch), 0],
                [0, 0, 1, 0]])
    union() {
        cube([foot(width), foot(height), thickness]);    
        // major ridges
        for(i=[6: 12 : width * 12]) {        
            translate([inch(i), 0, thickness])
            rotate([-90, 0, 0])
            cylinder(d=inch(2), h=foot(height), $fn=60);
        }
        // minor ridges
        for(i=[2 : 4 : width * 12]) {
            translate([inch(i), 0, thickness])
            rotate([-90, 0, 0])
            cylinder(d=inch(1), h=foot(height), $fn=60);
        }        
    }    
    
    
}

