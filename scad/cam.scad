// cam.scad - flat cam plate with integral shaft and toothed spline.
// Module library: expects config.scad to be included by the caller.
// Origin: centre of the plate underside. Z up.

function _pol(a, r) = [ r * cos(a), r * sin(a) ];
function _ang(p) = atan2(p[1], p[0]);

// Protrusion of bump i, using the optional per-bump override.
function cam_bump_out(i) = len(cam_bumps[i]) > 2 ? cam_bumps[i][2] : cam_ear_out;

// One bump as a 2D polygon: root arc (inside the base circle for overlap),
// two straight leaning edge faces, tip arc at R + out. Each face passes
// through its mid-height point at the cam_bumps angle and is rotated from
// radial by the lean, toward the middle of the bump.
module cam_bump_2d(i) {
    R = cam_od / 2;
    o = cam_bump_out(i);
    ov = 1;
    s = cam_bumps[i][0] + cam_bump_rot;
    e = cam_bumps[i][1] + cam_bump_rot;
    us = [ cos(s + cam_lean_start), sin(s + cam_lean_start) ];
    ue = [ cos(e - cam_lean_end),   sin(e - cam_lean_end) ];
    ms = _pol(s, R + o / 2);
    me = _pol(e, R + o / 2);
    dts = (o / 2) / cos(cam_lean_start);   drs = (o / 2 + ov) / cos(cam_lean_start);
    dte = (o / 2) / cos(cam_lean_end);     dre = (o / 2 + ov) / cos(cam_lean_end);
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

// 2D outline of the plate: base circle plus the bumps.
module cam_outline_2d() {
    mirror([0, cam_mirror ? 1 : 0, 0])
    offset(r = cam_outline_round) offset(delta = -cam_outline_round)
    union() {
        circle(r = cam_od / 2, $fn = 360);
        for (i = [0 : len(cam_bumps) - 1]) cam_bump_2d(i);
    }
}

// 2D spline profile at nominal size (an involute pinion).
module spline_2d(grow = 0) {
    offset(delta = grow)
        gear_2d(spline_teeth, gear_module_from_od(spline_od, spline_teeth, spline_addendum), pa = 20,
                addendum = spline_addendum, dedendum = spline_dedendum);
}

// Toothed boss (used under the gear) with a lead-in chamfer on its free end
// at z = h.
module spline_boss(h) {
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

// Toothed pocket cut into the top of the shaft, grown by the clearance.
module spline_pocket() {
    depth = spline_boss_h + spline_pocket_extra;
    translate([0, 0, cam_t + hub_h - depth]) linear_extrude(depth + 1) spline_2d(spline_clearance);
}

// Z of the gear underside above the cam bottom (the shaft shoulder).
function cam_gear_z() = cam_t + hub_h;

module cam() {
    difference() {
        union() {
            linear_extrude(cam_t) cam_outline_2d();
            cylinder(h = cam_t + hub_h, d = hub_d);
        }
        spline_pocket();
        translate([0, 0, -1]) cylinder(h = cam_t + hub_h + 2, d = bore_d, $fn = 64);
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
