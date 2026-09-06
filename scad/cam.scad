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

// Toothed socket cut into the top of the hub, grown by the clearance.
module socket() {
    depth = plug_h + socket_extra;
    translate([0, 0, plate_t + hub_h - depth]) linear_extrude(depth + 1) spline_2d(spline_clearance);
}

// Z of the gear underside above the cam bottom (the hub shoulder).
function shoulder_z() = plate_t + hub_h;

module cam() {
    difference() {
        union() {
            linear_extrude(plate_t) plate_outline_2d();
            cylinder(h = plate_t + hub_h, d = hub_d);
        }
        socket();
        translate([0, 0, -1]) cylinder(h = plate_t + hub_h + 2, d = bore_d, $fn = 64);
    }
}

// Slicer modifier volume: a ring covering the rim band of the plate, from
// rim_band inside the trough circle to just outside the crests, slightly
// taller than the plate so it covers the top and bottom layers too.
module rim_modifier() {
    translate([0, 0, -0.5])
        difference() {
            cylinder(h = plate_t + 1, r = trough_d / 2 + lobe_height + 2);
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
