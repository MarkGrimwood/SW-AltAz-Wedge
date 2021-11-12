$fa = 1;
$fs = 1;

//-------------------------------------------------------------------------------------------------------------------------------
// Constants section
//-------------------------------------------------------------------------------------------------------------------------------
// Various
bodyThickness = 5;
tolerance = 0.2;

// Heights
gap = 5;
bodyHeightOfBottom = 43;
bodyHeightOfTop = 41;
offsetToTop = bodyHeightOfBottom + bodyThickness + gap;

// Alignment holes
rAlignHoleInnerEdge = 37.5;
lAlignHoleBottom = 7;
wAlignHoleBottom = 3.5;
lAlignHoleTop = 7;
wAlignHoleTop = 4.5;
countAlignHoleBottom = 45;
countAlignHoleTop = 15;

// Ring definitions
rSmallerRingOutside = rAlignHoleInnerEdge + lAlignHoleBottom + bodyThickness;//55;
rLargerRingInside = 63;
ringWidth = 5;
rLargerRingOutside = rLargerRingInside + ringWidth;

// Support definitions
strutWidth = 15;
strutEllipseAngle = 13;
strutEllipseMajorRadius = 258.62 / 2;
strutEllipseMinorRadius = 189.97 / 2;
strutEllipseXOffset = 33.5;
supportAngle = 15;

// Hinge definitions
rHingeRod = 3.2;
rHinge = 7.5;
hingeWidth = 65;
hingePlateOffset = ringWidth;
zHingeOffset = bodyHeightOfBottom + (offsetToTop - bodyHeightOfBottom + bodyThickness)/2;

// Adjustment definitions
rScrewThread = 7.5;
screwThreadDepth = 2;
screwLength = 200;
adjustmentBlockDepth = 10;
adjustmentBlockAddition = 10;
adjustmentBlockAdditionalToThread = 5;
adjustmentBlockWH = (rScrewThread + adjustmentBlockAdditionalToThread) * 2;
adjustmentBlockPlateWidth = adjustmentBlockWH + adjustmentBlockAddition * 2;
adjustmentBlockPlateLength = rLargerRingInside + 14 + adjustmentBlockWH / 2+1;

// Adjustment pivot definitions
// These are based on the M3x20 bolts I'm using
adjustmentPivotBoltLength = 20;
adjustmentPivotBoltDiameter = 3;
adjustmentPivotCylinderLength = adjustmentPivotBoltLength - adjustmentBlockAdditionalToThread;

// I found some information for 1/4" UNC on https://www.engineeringtoolbox.com/unified-screw-threads-unc-unf-d_1809.html
threadMajorDiameter = 6.35;
threadMinorDiameter = 5.35;
threadPitch = 1.27;
attachmentCylinderHeight = 20;

// It seems that the actual dimensions required don't closely match that 1/4" UNC description though
thread_tol1 = 0.0;
thread_tol2 = 0.6;

//-------------------------------------------------------------------------------------------------------------------------------
// Code section
//-------------------------------------------------------------------------------------------------------------------------------

// Start the build
//test_bottom_section();
//test_top_section();
bottom_section();
//top_section();
//threaded_adjustment_block();
//adjustment_thread_full();
//grooved_adjustment_block();
//threaded_attachment();

//-------------------------------------------------------------------------------------------------------------------------------

module threaded_attachment() {
    cylinder(h = 20, d = threadMinorDiameter - thread_tol2, center = false);
    translate([0, 0, 5]) thread(15, threadMajorDiameter - thread_tol2, threadMinorDiameter - thread_tol2, threadPitch);
    translate([0, 0, -10]) cylinder(h = 10, d = 20, center = false);
}

module bottom_section() {
    union() {
        // Bottom base
        difference() {
            union() {
                build_base_bottom(wAlignHoleBottom, lAlignHoleBottom);
                // Base attachment cylinder (thread comes later)
                cylinder(h = attachmentCylinderHeight, d = 10, center = false);
            }
            // Base attachment thread
            thread(attachmentCylinderHeight, threadMajorDiameter + thread_tol1, threadMinorDiameter + thread_tol1, threadPitch);
        }
        
        difference() {
            union() {
                // Upper ring
                translate([0, 0, bodyHeightOfBottom]) tube(rLargerRingOutside * 2, rLargerRingInside * 2, bodyThickness);
            
                // Hinge plate
                translate([0, 0, bodyHeightOfBottom]) hinge_plate(rLargerRingOutside);
            }
            // Remove the section for the opposing hinge
            hinge_excision_in_bottom();
        }

        // Hinge tubes
        hinge_for_bottom();
        mirror([1, 0, 0]) hinge_for_bottom();
        
        translate([0, 0, bodyHeightOfBottom]) adjustment_plate(rLargerRingInside + ringWidth);
        
        // Supports
        rotate([0, 0, 90]) support_bottom();
        rotate([0, 0, 210]) support_bottom();
        rotate([0, 0, 330]) support_bottom();
    }
}

module top_section() {
    difference() {
        translate([0, 0, offsetToTop]) {
            // Top base
            difference() {
                build_base_top(wAlignHoleTop, lAlignHoleBottom);
                // Hole for threaded attachment (will not require threading)
                cylinder(h = bodyThickness, d = threadMajorDiameter);
            }
            
            // Large lower ring
            tube(rLargerRingOutside * 2, rLargerRingInside * 2, bodyThickness);
            // Upper ring
            translate([0, 0, bodyHeightOfTop]) tube(rLargerRingOutside * 2, rLargerRingInside * 2, bodyThickness);
            
            hinge_plate(rLargerRingOutside);

            adjustment_plate(rLargerRingOutside);
    
            // Supports
            rotate([0, 0, 90]) support_top();
            rotate([0, 0, 210]) support_top();
            rotate([0, 0, 330]) support_top();
        }
        // Hinge tube excision
        hinge_excision_in_top();
        mirror([1, 0, 0]) hinge_excision_in_top();
    }

    // Hinge tube
    hinge_for_top();
}

module hinge_for_bottom(thisTolerance = 0) {
    tubeLength = hingeWidth / 3 + (thisTolerance == 0 ? -tolerance : thisTolerance);
    
    translate([-hingeWidth / 2, rLargerRingInside + hingePlateOffset + rHingeRod, zHingeOffset]) 
        rotate([0, 90, 0])
            tube((rHinge + thisTolerance) * 2, rHingeRod * 2, tubeLength, center = false);
}

module hinge_for_top(thisTolerance = 0) {
    tubeLength = hingeWidth / 3 + (thisTolerance == 0 ? -tolerance * 2 : thisTolerance*2);
    
    translate([-tubeLength / 2, rLargerRingInside + hingePlateOffset + rHingeRod, zHingeOffset]) 
        rotate([0, 90, 0])
            tube((rHinge + thisTolerance) * 2, rHingeRod * 2, tubeLength, center = true);
}

module hinge_excision_in_top() {
    hinge_for_bottom(tolerance);
}

module hinge_excision_in_bottom() {
    hinge_for_top(tolerance);
}

module support_bottom() {
    // Our shape here is a parallelogram plus a bit to make it mate with the ring properly
    // Definition is bottom left, bottom right, top right, top left, down a bit, across a bit
    input = [
        [rSmallerRingOutside - bodyThickness, 0],
        [rSmallerRingOutside, 0],
        [rLargerRingInside, bodyHeightOfBottom],
        [rLargerRingInside, bodyHeightOfBottom + bodyThickness],
        [rLargerRingInside - bodyThickness, bodyHeightOfBottom + bodyThickness]
    ];
    
    rotate([0, 0, -supportAngle/2]) 
        rotate_extrude(angle = supportAngle)
            polygon(points = input);
}

module support_top() {
    rotate([0, 0, -supportAngle/2]) 
        rotate_extrude(angle = supportAngle)
            translate([rLargerRingInside, 0, 0])
                square([bodyThickness, bodyHeightOfTop + bodyThickness]);
}

module adjustment_plate(rExcision) {
    rotate([0, 0, 180]) {
        difference() {
            union() {
                difference() {
                    translate([-adjustmentBlockPlateWidth/2, 0, 0]) 
                        cube([adjustmentBlockPlateWidth, adjustmentBlockPlateLength, bodyThickness]);
                    cylinder(h = bodyThickness, r = rExcision);
                    translate([-adjustmentBlockWH/2, adjustmentBlockPlateLength - (adjustmentBlockWH + 2) / 2, 0]) 
                        cube([adjustmentBlockWH, adjustmentBlockWH + 2, bodyThickness]);
                }
                adjustment_plate_pivot();
                mirror([1, 0, 0]) adjustment_plate_pivot();
            }
            adjustment_plate_pivot_hole();
            mirror([1, 0, 0]) adjustment_plate_pivot_hole();
        }
    }
}

module adjustment_plate_pivot() {
    translate([adjustmentBlockWH/2, adjustmentBlockPlateLength, bodyThickness / 2])
        rotate([0, 90, 0]) 
            cylinder(h = adjustmentPivotCylinderLength, d = adjustmentPivotBoltDiameter + 6);
}

module adjustment_plate_pivot_hole() {
    translate([adjustmentBlockWH/2, adjustmentBlockPlateLength, bodyThickness / 2])
        rotate([0, 90, 0]) 
            cylinder(h = adjustmentPivotCylinderLength, d = adjustmentPivotBoltDiameter + tolerance * 2);
}

module threaded_adjustment_block() {
    difference() {
        rotate([0, 0, 180]) translate([0, adjustmentBlockPlateLength, bodyHeightOfBottom + bodyThickness / 2]) adjustment_block_common();
        adjustment_thread(adjustmentBlockDepth, threadTolerance = -tolerance);
    }
}

module grooved_adjustment_block() {
    catchBlockW = 2;
    catchBlockH = 3;
    catchBlockL = 5;
    catchHoleW = catchBlockW + tolerance;
    catchHoleH = catchBlockH + tolerance;
    catchHoleL = catchBlockL + tolerance;
    
    rotate([0, 0, 180]) 
        translate([0, adjustmentBlockPlateLength, offsetToTop + bodyThickness / 2]) {
            translate([-catchBlockH/2, -(rScrewThread + 2.5), 0]) cube([catchBlockH, catchBlockW, catchBlockL], center = true);
            difference() {
                union() {
                    intersection() {
                        adjustment_block_common();
                        translate([adjustmentBlockWH/2, 0, 0]) 
                            cube([adjustmentBlockWH, adjustmentBlockWH, adjustmentBlockDepth], center = true);
                        }
            }
            adjustment_groove(-tolerance*2);
            translate([catchHoleH/2, (rScrewThread + 2.5), 0]) cube([catchHoleH, catchHoleW, catchHoleL], center = true);
        }
    }
}

module adjustment_groove(agTol = 0) {
    grooveOffset = adjustmentBlockDepth / 2 - screwThreadDepth;
    
    input = [
        [0, 0],
        [rScrewThread - agTol, 0],
        [rScrewThread - agTol, grooveOffset - agTol],
        [rScrewThread - screwThreadDepth - agTol, adjustmentBlockDepth / 2 - agTol],
        [rScrewThread - agTol, adjustmentBlockDepth - grooveOffset - agTol],
        [rScrewThread - agTol, adjustmentBlockDepth - agTol],
        [0, adjustmentBlockDepth]
    ];
    
    translate([0, 0, -adjustmentBlockDepth/2]) rotate_extrude(angle = 360) polygon(points = input);
}

module adjustment_block_common() {
    difference() {
        intersection() {
            cube([adjustmentBlockWH - tolerance * 2, adjustmentBlockWH, adjustmentBlockDepth], center = true);
            rotate([0, 90, 0]) cylinder(h = adjustmentBlockWH - tolerance * 2, d = adjustmentBlockWH, center = true);
        }
        rotate([0, 90, 0]) cylinder(h = adjustmentBlockWH, d = adjustmentPivotBoltDiameter, center = true);
    }
}

module adjustment_thread(height, threadTolerance = 0) {
    threadDepth = screwThreadDepth - threadTolerance;
    innerRadius = rScrewThread - screwThreadDepth - threadTolerance;
    
	function ra(x, z) = [x * sin(360 * z), x * cos(360 * z)];
	input = [
		for (lp = [0:0.05:1]) ra(innerRadius + (threadDepth * lp), lp / 4),
        for (lp = [0:0.05:1]) ra(innerRadius + threadDepth, 0.25 + lp / 4),
		for (lp = [0:0.05:1]) ra(innerRadius + (threadDepth * (1 - lp)), 0.5 + lp / 4),
        for (lp = [0:0.05:1]) ra(innerRadius + 0, 0.75 + lp / 4)
	];
	
    translate([0, -adjustmentBlockPlateLength, offsetToTop - bodyThickness / 2]) rotate([0, 180, 0])
        linear_extrude(height = height, twist = -(height/(screwThreadDepth*4)*360)) 
                polygon(points = input);
}

module adjustment_thread_full() {
    adjustment_thread(screwLength);
    rotate([0, 0, 180]) 
        translate([0, adjustmentBlockPlateLength, offsetToTop + bodyThickness / 2]) {
            adjustment_groove();
            translate([0, 0, adjustmentBlockDepth/2]) cylinder(r = rScrewThread, h = 1);
            translate([0, 0, adjustmentBlockDepth/2 + 1]) cylinder(r = 10, h = 10);
        }
}

module hinge_plate(rExcision) {
    // Hinge plate
    difference() {
        translate([-hingeWidth/2, 0, 0]) cube([hingeWidth, rLargerRingInside + hingePlateOffset, bodyThickness]);
        cylinder(h = bodyThickness, r = rExcision);
    }
}

module build_base_bottom(ahW, ahL) {
    rInsideEdge = rAlignHoleInnerEdge - bodyThickness;
    repeats = countAlignHoleBottom;
    
    // The flat base
    difference() {
        union() {
            tube(rSmallerRingOutside * 2, rInsideEdge * 2, bodyThickness);
            // The struts
            for (lp = [0:360/3:360]) rotate([0, 0, lp]) translate([-strutWidth/2, 0, 0]) cube([strutWidth, rInsideEdge, bodyThickness]);
        }
        for (lp = [0:360/repeats:360]) rotate([0, 0, lp]) translate([-ahW/2, rAlignHoleInnerEdge, 0]) cube([ahW, ahL, bodyThickness]);
    }
}

module build_base_top(ahW, ahL) {
    rInsideEdge = rAlignHoleInnerEdge - bodyThickness;
    repeats = countAlignHoleTop;
    
    // The flat base
    difference() {
        union() {
            tube(rSmallerRingOutside * 2, rInsideEdge * 2, bodyThickness);
            // The struts
            for (lp = [0:360/3:360]) rotate([0, 0, lp]) translate([-strutWidth/2, 0, 0]) cube([strutWidth, rLargerRingInside, bodyThickness]);
        }
        for (lp = [0:360/repeats:360]) rotate([0, 0, lp]) translate([-ahW/2, rAlignHoleInnerEdge, 0]) cube([ahW, ahL, bodyThickness]);
    }
}

module buttom_base_thread() {
    difference() {
        cylinder(h = 8, d = 10, center = true);
        thread(8, threadMajorDiameter + thread_tol1, threadMinorDiameter + thread_tol1, threadPitch);
    }
}

module thread(height, outerDiameter, innerDiameter, pitch) {
	threadHeight = pitch / 2;
    outerRadius = outerDiameter / 2;
    innerRadius = innerDiameter / 2;
	
	function r(x, z) = [x * sin(360 * z / pitch), x * cos(360 * z / pitch)];
	input = [
		for (lp = [0:0.05:1]) r(innerRadius + (threadHeight * lp), pitch * (1 - lp / 2)),
		for (lp = [1:-0.05:0]) r(innerRadius + (threadHeight * lp), pitch * (lp / 2))
	];
	
    linear_extrude(height = height, twist = -(height/pitch*360)) polygon(points = input);
}

module tube(outsideDiameter, insideDiameter, height, center = false) {
    difference() {
        cylinder(h = height, d = outsideDiameter, center);
        cylinder(h = height, d = insideDiameter, center);
    }
}

module test_top_section() {
    intersection() {
        top_section();
        test_blocks();
    }
}

module test_bottom_section() {
    intersection() {
        bottom_section();
        test_blocks();
    }
}

module test_blocks() {
    union() {
        translate([0, 90, 100]) cube([10, 200, 200], true);
        rotate([0, 0, 120]) translate([0, 90, 100]) cube([10, 200, 200], true);
    }
}
