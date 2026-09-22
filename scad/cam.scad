// cam.scad - flat cam plate with integral shaft and toothed spline.
// Module library: expects config.scad to be included by the caller.
// Origin: centre of the plate underside. Z up.

function _pol(a, r) = [ r * cos(a), r * sin(a) ];
function _ang(p) = atan2(p[1], p[0]);

// Protrusion of lobe i, using the optional per-lobe override.
function lobe_height_of(i) = len(lobes[i]) > 2 ? lobes[i][2] : lobe_height;

// One lobe as a 2D polygon: root arc (inside the trough circle for overlap),
// two straight leaning edge faces, tip arc at R + out. Each face passes
// through its mid-height point at the lobes angle and is rotated from
// radial by the lean, toward the middle of the lobe.
module lobe_2d(i) {
    R = trough_d / 2;
    o = lobe_height_of(i);
    ov = 1;
    s = lobes[i][0] + lobe_rot;
    e = lobes[i][1] + lobe_rot;
    us = [ cos(s + ramp_lean), sin(s + ramp_lean) ];
    ue = [ cos(e - drop_lean),   sin(e - drop_lean) ];
    ms = _pol(s, R + o / 2);
    me = _pol(e, R + o / 2);
    dts = (o / 2) / cos(ramp_lean);   drs = (o / 2 + ov) / cos(ramp_lean);
    dte = (o / 2) / cos(drop_lean);     dre = (o / 2 + ov) / cos(drop_lean);
    tip_s = ms + dts * us;  root_s = ms - drs * us;
    tip_e = me + dte * ue;  root_e = me - dre * ue;
    at_s = _ang(tip_s); at_e = _ang(tip_e);
    ar_s = _ang(root_s); ar_e = _ang(root_e);
    at_e2 = (at_e < at_s) ? at_e + 360 : at_e;
    ar_e2 = (ar_e < ar_s) ? ar_e + 360 : ar_e;
    n = max(4, ceil((at_e2 - at_s) / 2));
    polygon(concat(
        [ root_s, tip_s ],
        [ for (k = [1 : n - 1]) _pol(at_s + (at_e2 - at_s) * k / n, norm(tip_s)) ],
        [ tip_e, root_e ],
        [ for (k = [n - 1 : -1 : 1]) _pol(ar_s + (ar_e2 - ar_s) * k / n, norm(root_s)) ]
    ));
}

// 2D outline of the plate: trough circle plus the lobes.
module plate_outline_2d() {
    mirror([0, cam_mirror ? 1 : 0, 0])
    offset(r = plate_corner_round) offset(delta = -plate_corner_round)
    union() {
        circle(r = trough_d / 2, $fn = 360);
        for (i = [0 : len(lobes) - 1]) lobe_2d(i);
    }
}

// 2D spline profile at nominal size (an involute pinion).
module spline_2d(grow = 0) {
    offset(delta = grow)
        gear_2d(spline_teeth, gear_module_from_od(spline_od, spline_teeth, spline_addendum), pa = 20,
                addendum = spline_addendum, dedendum = spline_dedendum);
}

// Toothed plug (used under the gear) with a lead-in chamfer on its free end
// at z = h.
module plug(h) {
    if (spline_lead_in > 0) {
        rt = spline_od / 2;
        intersection() {
            linear_extrude(h) spline_2d();
            union() {
                cylinder(h = h - spline_lead_in + eps, r = rt + 1);
                translate([0, 0, h - spline_lead_in])
                    cylinder(h = spline_lead_in, r1 = rt + 0.01, r2 = rt - spline_lead_in);
            }
        }
    } else {
        linear_extrude(h) spline_2d();
    }
}

// The socket as a cutting solid, standing on z = 0 and open upward. Split out
// so the fit test coupon cuts the same geometry the cam does, at a clearance
// of its choosing, rather than a copy that could drift.
module socket_cut(clearance = spline_clearance) {
    linear_extrude(plug_h + socket_extra + 1) spline_2d(clearance);
}

// Toothed socket cut into the top of the hub, grown by the clearance.
module socket() {
    depth = plug_h + socket_extra;
    translate([0, 0, plate_t + hub_h - depth]) socket_cut();
}

// Z of the gear underside above the cam bottom (the hub shoulder).
function shoulder_z() = plate_t + hub_h;

// The moulding number, cut into both faces of the plate as the OEM cam
// carries it. The digit comes from cam_version, so "v1" marks a 1. Engraved
// rather than raised: the cam side prints against the bed, where a raised
// character cannot go, and a recess on the gear side cannot foul the gear.
module version_mark() {
    if (cam_version_number_size > 0) {
        digit = cam_version[1];
        p = _pol(cam_version_number_angle, cam_version_number_r);
        // gear side, into the top of the plate
        translate([0, 0, plate_t - cam_version_number_depth])
            linear_extrude(cam_version_number_depth + eps)
                translate(p)
                    text(digit, size = cam_version_number_size, halign = "center", valign = "center");
        // cam side, into the underside, mirrored so it reads the right way
        // round when the part is turned over
        translate([0, 0, -eps])
            linear_extrude(cam_version_number_depth + eps)
                translate(p)
                    mirror([1, 0, 0])
                        text(digit, size = cam_version_number_size, halign = "center", valign = "center");
    }
}

module cam() {
    difference() {
        union() {
            linear_extrude(plate_t) plate_outline_2d();
            cylinder(h = plate_t + hub_h, d = hub_d);
        }
        socket();
        version_mark();
        translate([0, 0, -1]) cylinder(h = plate_t + hub_h + 2, d = bore_d, $fn = 64);
    }
}

// Slicer modifier volume for the cam: a ring covering the rim band of the
// plate, from rim_band inside the trough circle to just outside the crests,
// slightly taller than the plate so it covers the top and bottom layers too.
// Sized from the taller of the two versions' lobes so ONE modifier serves both
// cams. On the shorter one the ring simply reaches past the crests, which does
// not matter: a modifier only has to cover the region, not match its outline.
module cam_rim_modifier() {
    rim_lobe_h = max(v1_lobe_height, v2_lobe_height);
    translate([0, 0, -0.5])
        difference() {
            cylinder(h = plate_t + 1, r = trough_d / 2 + rim_lobe_h + 2);
            translate([0, 0, -1]) cylinder(h = plate_t + 3, r = trough_d / 2 - rim_band);
        }
}

// Spacer washer.
module spacer_washer() {
    if (washer_t > 0)
        difference() {
            cylinder(h = washer_t, d = washer_od);
            translate([0, 0, -1]) cylinder(h = washer_t + 2, d = bore_d, $fn = 64);
        }
}
