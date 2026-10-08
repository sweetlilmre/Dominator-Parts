// fit_test.scad - a coupon for finding the press fits on your own printer,
// without reprinting the real parts each time.
// Module library: expects config.scad, cam.scad and turbine.scad to be
// included by the caller.
//
// Three joints in this project are a press fit, and all three are set by one
// clearance applied as offset(delta = clearance) on the female side, so the
// gap is that value normal to every edge:
//
//   spline  the plug on the gear into the socket in the cam's hub
//   axle    the pin through the bore of every part that turns on it
//   blade   the turbine blade through the cutout in each turbine disc
//
// The spline and the blade take the engraved number as the clearance itself.
// The axle does not: bore_clearance of 0.4 already prints well even on a good
// printer, so there the number is added on top of it and the column is fine
// tuning. The 0 column is therefore the production bore, not a zero bore.
//
// The range starts at zero. A printer never lands on the nominal size: it
// tends to shrink holes and grow posts, so a cutout at a nominal 0 already
// comes out slightly tight, which is what a press fit is after. No printer
// tested so far has wanted less than 0 (owner's Prusa i3 MK4: spline 0.05;
// a contributor's Ender 3 V3 KE: spline 0.15, blade 0), so the columns spend
// their range above zero, in finer steps, where the answers have fallen.
//
// The coupon prints one column per candidate clearance, with all three
// features in that column and the value engraved between them, so one number
// reads across the lot. Print it with the settings you will use for the real
// parts, then try each feature and keep the clearance that grips without
// splitting:
//
//   spline  press in the plug of an actual printed gear
//   axle    push the steel pin through the bore
//   blade   press an actual printed turbine blade through the cutout
//
// Testing with the real mating parts is the point: they are what has to fit,
// and they carry the printing errors of their own geometry and orientation
// with them. Every feature here is cut with the same module the real part
// uses, so the coupon cannot drift away from what it stands in for.
//
// Clearances to try, one column each, left to right. Steps of 0.05 cover the
// range seen so far in four columns; if the best fit is at either end, extend
// the list past it and print again. A column may be too tight to assemble at
// all, which is a result, not a fault.
ft_clearances = [0, 0.05, 0.10, 0.15];
// Boss height. Must leave a floor under the socket, which is
// plug_h + socket_extra deep.
ft_boss_h = 9;
// Base plate under everything. It is as thick as the turbine disc's web, so
// the blade cutout is as deep here as it is in the real disc.
ft_base_t = turbine_web_t();
// Engraved label size and depth.
ft_label_size = 5;
ft_label_depth = 0.6;

// Column spacing: just enough to clear the bosses, so the coupon stays small.
function ft_pitch() = hub_d + 4;
// Row positions down the plate, in mm rather than as a fraction of the pitch:
// the rows are set by the size of the features, which does not change when the
// columns move closer together.
function ft_boss_y()  =  hub_d / 2 + 2;
function ft_label_y() = -4;
function ft_blade_y() = -20;

// A clearance as engraved, always with two decimals ("0.00", "0.10"), so the
// labels read alike and match the values written in config.scad. Positive
// values only, as the columns are.
function ft_label_text(c) = let (h = round(c * 100))
    str(floor(h / 100), ".", h % 100 < 10 ? "0" : "", h % 100);

// The axle bore for a column: the production bore plus the column's value, so
// the engraved number is how much has been added for fine tuning.
function ft_bore_d(clearance) = bore_d + clearance;

// The axle bore as a cutting solid, long enough to pass through both the boss
// and the plate beneath it. It is cut from both, so the pin goes right through
// the coupon as it does through a real part.
module ft_bore_cut(clearance) {
    translate([0, 0, -(ft_base_t + 2)])
        cylinder(h = ft_boss_h + ft_base_t + 4, d = ft_bore_d(clearance), $fn = 64);
}

// One boss with a socket at the given clearance, standing on z = 0.
module ft_socket_boss(clearance) {
    depth = plug_h + socket_extra;
    difference() {
        cylinder(h = ft_boss_h, d = hub_d);
        // the socket cut, positioned so it opens at the top of the boss
        translate([0, 0, ft_boss_h - depth]) socket_cut(clearance);
        ft_bore_cut(clearance);
    }
}

// Text engraved into the top of the base plate.
module ft_label(txt) {
    translate([0, 0, ft_base_t - ft_label_depth])
        linear_extrude(ft_label_depth + eps)
            text(txt, size = ft_label_size, halign = "center", valign = "center");
}

module fit_test() {
    p = ft_pitch();
    w = len(ft_clearances) * p;
    y0 = ft_blade_y() - 13;
    y1 = ft_boss_y() + hub_d / 2 + 2;
    // Base plate carries the labels, the blade cutouts and the axle bores. The
    // bores are cut from the plate as well as from the boss above, so each one
    // passes right through the coupon.
    difference() {
        translate([-p / 2, y0, 0]) cube([w, y1 - y0, ft_base_t]);
        for (i = [0 : len(ft_clearances) - 1]) {
            c = ft_clearances[i];
            translate([i * p, ft_label_y(), 0]) ft_label(ft_label_text(c));
            // blade cutout, right through the plate
            translate([i * p, ft_blade_y(), -1])
                linear_extrude(ft_base_t + 2)
                    turbine_blade_2d_centred(c);
            // axle bore, right through the plate under the boss
            translate([i * p, ft_boss_y(), 0]) ft_bore_cut(c);
        }
    }
    for (i = [0 : len(ft_clearances) - 1])
        translate([i * p, ft_boss_y(), ft_base_t - eps])
            ft_socket_boss(ft_clearances[i]);
}
