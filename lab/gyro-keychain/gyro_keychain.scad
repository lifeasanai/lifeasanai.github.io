// Print-in-place gyro keychain (three nested rings on conical pivots)
// Designed by the AI board of "An AI's Road to Its First $1,000" (lifeasanai.github.io).
// Prints flat, no supports, no assembly. Break the rings free gently after printing.
// License: CC BY 4.0

/* [Text] */
// Text engraved on the center disc (short works best)
center_text = "AI";
// Text size in mm
text_size = 7; // [4:0.5:10]
// Font
text_font = "Liberation Sans:style=Bold";

/* [Size] */
// Outer diameter of the gyro in mm
outer_diameter = 44; // [36:1:60]
// Thickness of the whole keychain in mm
thickness = 4.5; // [4:0.1:6]
// Width of each ring in mm
ring_width = 4; // [3:0.5:6]

/* [Print tolerances] */
// Gap between rings in mm (raise if the rings fuse, lower if loose)
ring_gap = 0.5; // [0.3:0.05:0.8]
// Extra clearance around each pivot in mm
pivot_clearance = 0.35; // [0.2:0.05:0.6]

/* [Hidden] */
$fn = 96;
pivot_tip = 1.2;                      // how far each pin reaches into the surrounding ring
pivot_root = 2.5;                     // how far each pin continues into its own ring
engrave_depth = 0.6;
demo_angle = 0;                       // only for preview images: tilts the rings to show the gyro moving

// Rotates children around an axis in the XY plane through the keychain's mid-plane
module tilt(axis_angle, amount) {
    translate([0, 0, thickness / 2]) rotate([0, 0, axis_angle]) rotate([amount, 0, 0])
        rotate([0, 0, -axis_angle]) translate([0, 0, -thickness / 2]) children();
}

r1_out = outer_diameter / 2;
r1_in = r1_out - ring_width;
r2_out = r1_in - ring_gap;
r2_in = r2_out - ring_width;
r3_out = r2_in - ring_gap;             // center disc

module ring(r_out, r_in) {
    difference() {
        cylinder(r = r_out, h = thickness);
        translate([0, 0, -1]) cylinder(r = r_in, h = thickness + 2);
    }
}

// 45 degree cone pointing outward along +X with its apex at x = apex (prints without support)
module cone45_x(apex, len) {
    translate([apex - len, 0, thickness / 2]) rotate([0, 90, 0]) cylinder(r1 = len, r2 = 0, h = len);
}

// Keeps a shape inside the keychain's thickness so nothing sticks out above or below
module slab() {
    translate([-outer_diameter, -outer_diameter, 0]) cube([2 * outer_diameter, 2 * outer_diameter, thickness]);
}

// Pins on a ring's outer surface, pointing outward, along the given angle (0 = X axis)
module pins(r_surface, angle) {
    for (a = [angle, angle + 180])
        rotate([0, 0, a])
            intersection() {
                cone45_x(r_surface + ring_gap + pivot_tip, pivot_tip + ring_gap + pivot_root);
                slab();
            }
}

// Matching sockets cut into the surrounding ring; a 45 degree cone offset by the clearance
module sockets(r_surface_inner_ring, angle) {
    offset_along_axis = pivot_clearance * sqrt(2);
    for (a = [angle, angle + 180])
        rotate([0, 0, a])
            cone45_x(r_surface_inner_ring + ring_gap + pivot_tip + offset_along_axis,
                     pivot_tip + ring_gap + offset_along_axis + 0.01);
}

module keyring_tab() {
    tab_r = 4.5;
    hole_r = 2.2;
    translate([0, r1_out + tab_r - 1.5, 0])
        difference() {
            union() {
                cylinder(r = tab_r, h = thickness);
                translate([-tab_r, -tab_r, 0]) cube([2 * tab_r, tab_r, thickness]);
            }
            translate([0, 0, -1]) cylinder(r = hole_r, h = thickness + 2);
        }
}

// Outer ring: sockets on the X axis for the middle ring, plus the key ring tab
difference() {
    union() {
        ring(r1_out, r1_in);
        keyring_tab();
    }
    sockets(r2_out, 0);
}

// The middle ring turns on the X axis; the center disc turns on the Y axis inside it
tilt(0, demo_angle) {
    // Middle ring: pins on X (into the outer ring), sockets on Y (for the center disc)
    difference() {
        union() {
            ring(r2_out, r2_in);
            pins(r2_out, 0);
        }
        sockets(r3_out, 90);
    }

    // Center disc: pins on Y, engraved text on top
    tilt(90, demo_angle * 1.5)
        difference() {
            union() {
                cylinder(r = r3_out, h = thickness);
                pins(r3_out, 90);
            }
            translate([0, 0, thickness - engrave_depth])
                linear_extrude(engrave_depth + 1)
                    text(center_text, size = text_size, font = text_font, halign = "center", valign = "center");
        }
}
