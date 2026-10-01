// Emo Star Gyro Keychain: "IT'S NOT A PHASE!"
// A faceted nautical star with a spinning ring and a broken heart that turns on a second axis.
// Print-in-place: prints flat in one piece, no supports, no assembly.
// Two colors the easy way: change filament at 4.6 mm (the raised inner star and the heart become the second color).
// Designed by the AI board of "An AI's Road to Its First $1,000" (lifeasanai.github.io). License: CC BY 4.0

/* [Text] */
// Text around the spinning ring
phrase = "IT'S NOT A PHASE!";
// Letter size in mm (larger reads better, but long phrases may overlap)
letter_size = 2.8; // [2.2:0.1:3.4]

/* [Print tolerances] */
// Gap between rings in mm (raise if the rings fuse, lower if loose)
ring_gap = 0.5; // [0.3:0.05:0.8]
// Extra clearance around each pivot in mm
pivot_clearance = 0.35; // [0.2:0.05:0.6]

/* [Hidden] */
$fn = 120;
demo_angle = 0;          // only for preview images
show_colors = false;     // only for preview images: shows the two-color split
color_change = 4.6;      // filament change height for the two-color version

ring_thickness = 4.5;
ring_width = 5;
pivot_tip = 1.2;
pivot_root = 2.5;
engrave = 0.6;
heart_relief = 1.2;

star_outer = 30;         // tip radius (60 mm across)
star_inner = 19;         // notch radius
edge_height = 3.2;       // star thickness at the notches
tip_height = 2.6;        // star thickness at the tips
ridge_height = 10.0;     // star thickness at the (cut away) center; about 6 mm where the ridges meet the ring
collar = 3.2;            // solid band around the track so the pivots always have material

r1_in = 15.5;
r2_out = r1_in - ring_gap;
r2_in = r2_out - ring_width;
r3_out = r2_in - ring_gap;

module cone45_x(apex, len) {
    translate([apex - len, 0, ring_thickness / 2]) rotate([0, 90, 0]) cylinder(r1 = len, r2 = 0, h = len);
}
module slab() { translate([-60, -60, 0]) cube([120, 120, ring_thickness]); }
module pins(r, a) {
    for (b = [a, a + 180]) rotate([0, 0, b])
        intersection() { cone45_x(r + ring_gap + pivot_tip, pivot_tip + ring_gap + pivot_root); slab(); }
}
module sockets(r, a) {
    o = pivot_clearance * sqrt(2);
    for (b = [a, a + 180]) rotate([0, 0, b]) cone45_x(r + ring_gap + pivot_tip + o, pivot_tip + ring_gap + o + 0.01);
}
module tilt(axis_angle, amount) {
    translate([0, 0, ring_thickness / 2]) rotate([0, 0, axis_angle]) rotate([amount, 0, 0])
        rotate([0, 0, -axis_angle]) translate([0, 0, -ring_thickness / 2]) children();
}

function pt(r, a, z) = [r * cos(a), r * sin(a), z];

// One faceted star point: a sharp ridge from tip to center, sloping down to both notches
module star_point(a) {
    hull()
        for (p = [pt(star_outer, a, 0), pt(star_inner, a - 36, 0), pt(star_inner, a + 36, 0), pt(0, a, 0),
                  pt(star_outer, a, tip_height), pt(star_inner, a - 36, edge_height),
                  pt(star_inner, a + 36, edge_height), pt(0, a, ridge_height)])
            translate(p) cube(0.01, center = true);
}

module heart2d(s) {
    translate([0, -s * 0.16]) rotate(45) {
        square(s, center = true);
        translate([0, s / 2]) circle(d = s);
        translate([s / 2, 0]) circle(d = s);
    }
}
module broken_heart2d(s) {
    difference() {
        heart2d(s);
        polygon([[-0.45, s], [0.45, s], [1.9, s * 0.35], [-1.0, s * 0.05], [1.7, -s * 0.3],
                 [0.35, -s], [-0.55, -s], [0.85, -s * 0.3], [-1.9, s * 0.05], [1.05, s * 0.35]]);
    }
}

module ring_text(txt, r, size) {
    n = len(txt);
    span = 320;
    for (i = [0 : n - 1])
        rotate([0, 0, 90 + span / 2 - i * span / (n - 1)])
            translate([r, 0, 0]) rotate([0, 0, -90])
                text(txt[i], size = size, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
}

module star_frame() {
    difference() {
        union() {
            for (k = [0 : 4]) star_point(90 + k * 72);
            cylinder(r = r1_in + collar, h = ring_thickness);
            translate([0, star_outer + 1.4, 0]) cylinder(r = 3.8, h = tip_height);
        }
        translate([0, 0, -1]) cylinder(r = r1_in, h = ridge_height + 2);
        sockets(r2_out, 0);
        translate([0, star_outer + 1.4, -1]) cylinder(r = 1.9, h = ridge_height);
    }
}

module phrase_ring() {
    difference() {
        union() {
            difference() { cylinder(r = r2_out, h = ring_thickness); translate([0, 0, -1]) cylinder(r = r2_in, h = ring_thickness + 2); }
            pins(r2_out, 0);
        }
        sockets(r3_out, 90);
        translate([0, 0, ring_thickness - engrave])
            linear_extrude(engrave + 1) ring_text(phrase, (r2_out + r2_in) / 2, letter_size);
    }
}

module heart_disc() {
    disc_body();
    heart_relief_part();
}
module disc_body() {
    cylinder(r = r3_out, h = ring_thickness);
    pins(r3_out, 90);
}
module heart_relief_part() {
    translate([0, 0, ring_thickness - 0.01]) linear_extrude(heart_relief) broken_heart2d(r3_out * 1.05);
}

black = "#1b1b1f";
pink = "#ff2d8a";

if (show_colors) {
    // Preview images only: the colors each part gets with a filament change at color_change.
    // Rings and disc are fully below it (black); star ridges and the heart are above it (pink).
    // render() forces exact geometry, so the preview shows the real color split
    color(black) render() intersection() { star_frame(); translate([-60, -60, -1]) cube([120, 120, color_change + 1]); }
    color(pink) render() intersection() { star_frame(); translate([-60, -60, color_change]) cube([120, 120, 20]); }
    tilt(0, demo_angle) {
        color(black) phrase_ring();
        tilt(90, demo_angle * 1.5) { color(black) disc_body(); color(pink) heart_relief_part(); }
    }
} else {
    star_frame();
    tilt(0, demo_angle) {
        phrase_ring();
        tilt(90, demo_angle * 1.5) heart_disc();
    }
}
