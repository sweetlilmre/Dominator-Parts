// fit_test.scad - a coupon for finding the press fit of the spline joint
// without reprinting the cam and the gear each time.
// Module library: expects config.scad and cam.scad to be included by the caller.
//
// The joint is a plug on the gear's underside pressed into a socket in the top
// of the hub. The only tolerance is `spline_clearance`, applied as
// offset(delta = clearance) on the socket profile, so the gap is that value
// normal to every flank, root and tip. Print 1 used 0.15 and had play; the
// config now says 0.05, which has never been printed.
//
// The coupon prints one socket per candidate clearance and a few plugs at
// nominal, in the same orientation the real parts use: sockets are holes
// going down into an upright boss, plugs stand up from the bed. Print it with
// the settings you will use for the real parts, then press a plug into each
// socket and keep the clearance that grips without splitting.
//
// Both features are cut with the same modules the cam and the gear use, so the
// coupon cannot drift away from the parts it is standing in for.

// Clearances to try, one socket each, left to right.
ft_clearances = [0, 0.05, 0.10, 0.15];
// Spare plugs to press into them.
ft_plugs = 2;
// Boss height. Must leave a floor under the socket, which is
// plug_h + socket_extra deep.
ft_boss_h = 9;
// Base plate under everything.
ft_base_t = 3;
// Engraved label size and depth.
ft_label_size = 5;
ft_label_depth = 0.6;

function ft_pitch() = hub_d + 9;
function ft_cols()  = max(len(ft_clearances), ft_plugs);

// One boss with a socket at the given clearance, standing on z = 0.
module ft_socket_boss(clearance) {
    depth = plug_h + socket_extra;
    difference() {
        cylinder(h = ft_boss_h, d = hub_d);
        // the socket cut, positioned so it opens at the top of the boss
        translate([0, 0, ft_boss_h - depth]) socket_cut(clearance);
        // the bore runs through the real hub, so it runs through here too:
        // it sets how much the socket walls can flex
        translate([0, 0, -1]) cylinder(h = ft_boss_h + 2, d = bore_d, $fn = 64);
    }
}

// A plug standing on z = 0, lead-in chamfer up, as it prints on the gear.
module ft_plug() {
    difference() {
        plug(plug_h);
        translate([0, 0, -1]) cylinder(h = plug_h + 2, d = bore_d, $fn = 64);
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
    // Base plate carries only the sockets and their labels. The plugs stand
    // loose on the bed beside it: they have to come off to be pressed in, and
    // snapping them off a plate would damage the teeth being tested.
    difference() {
        translate([-p / 2, -p * 0.58, 0]) cube([w, p * 1.20, ft_base_t]);
        for (i = [0 : len(ft_clearances) - 1])
            translate([i * p, -p * 0.36, 0])
                ft_label(str(ft_clearances[i]));
    }
    for (i = [0 : len(ft_clearances) - 1])
        translate([i * p, p * 0.10, ft_base_t - eps]) ft_socket_boss(ft_clearances[i]);
    for (j = [0 : ft_plugs - 1])
        translate([j * p, -p * 1.15, 0]) ft_plug();
}
