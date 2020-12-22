// scale.scad
include <constants.scad>


// scale parameters -- override in your code
//$MIN_THICKNESS = 0.1;  // default minimum thickness when scaling
//$SCALE = "ho"; // default scale to use:  ho, n, o

function scale_factor(s) = 1 / (s == "ho"? 87 : 
                               (s == "n"? 160 : 
                               (s == "o"? 48 :
                               (s == "s"? 64: 1))));

// Imperial Units
function inch(n) = max($MIN_THICKNESS, 25.4 * n * scale_factor($SCALE));
function foot(n) = max($MIN_THICKNESS, 25.4 * 12 * n * scale_factor($SCALE));

// Metric Units
function mm(n) = max($MIN_THICKNESS, n * scale_factor($SCALE));
function cm(n) = max($MIN_THICKNESS, n * 10 * scale_factor($SCALE));
function meter(n) = max($MIN_THICKNESS, n * 1000 * scale_factor($SCALE));


