// drive_shaft.scad - Dominator gearbox drive shafts as one parametric model,
// designed to print lying down for strength.
// Module library: expects config.scad to be included by the caller.
//
// Construction, along Z from the "A" end at z = 0:
//   an 8 tooth involute pinion profile runs the FULL length of the shaft;
//   round body sections are unioned over it where the body is plain, with a
//   cone at each end of every body section that tapers into the tooth roots,
//   so there is no sharp step where the gear meets the body (the break point
//   on vertical prints);
//   a core cylinder fills the tooth roots in the "lobed" sections;
//   a circular arc groove is cut where specified;
//   a full length core channel takes a steel rod, and dowel holes on the
//   split face take short pieces of filament.
//
// Printing: the shaft is split lengthwise into two identical halves. Each is
// printed with its flat face on the bed, so the layers run along the shaft
// and the teeth are printed on their sides. The two halves are glued around
// the rod with the dowels for alignment. Set ds_split = false for a whole
// shaft (vertical print, weak at the steps).
//
// A shaft spec is a list of named fields, see ds_long / ds_short in config.

function ds_get(s, k, dflt = undef) =
    let(i = search([k], s, 1)[0]) (i == [] ? dflt : s[i][1]);

module drive_shaft_solid(s) {
    L        = ds_get(s, "length");
    teeth    = ds_get(s, "teeth", 8);
    od       = ds_get(s, "gear_od", ds_gear_od);
    body_d   = ds_get(s, "body_d", ds_body_d);
    body     = ds_get(s, "body", []);
    lobed    = ds_get(s, "lobed", []);
    core_d   = ds_get(s, "lobe_core_d", 0);
    groove   = ds_get(s, "groove", []);
    mod      = gear_module_from_od(od, teeth);
    rr       = gear_root_radius(teeth, mod);
    fl       = ds_step_fillet;
    difference() {
        union() {
            // full length pinion. ds_split_at = "gaps" rotates it so a tooth
            // gap lies on the split plane (each half carries whole teeth, the
            // glue line is in the gaps); "teeth" puts tooth centres on the
            // split plane (half teeth lie flat on the bed, wider footprint).
            rotate(ds_split_at == "gaps" ? 180 / teeth : 0)
                spur_gear(teeth, mod, L, pa = 20, backlash = ds_tooth_backlash, bore = 0);
            for (b = body) {
                translate([0, 0, b[0]]) cylinder(h = b[1] - b[0], d = body_d);
                // root fillets: cones from the body down into the teeth
                if (fl > 0) {
                    if (b[0] > 0)
                        translate([0, 0, b[0] - fl]) cylinder(h = fl + eps, r1 = rr, r2 = body_d / 2);
                    if (b[1] < L)
                        translate([0, 0, b[1] - eps]) cylinder(h = fl + eps, r1 = body_d / 2, r2 = rr);
                }
            }
            if (core_d > 0) for (b = lobed) translate([0, 0, b[0]]) cylinder(h = b[1] - b[0], d = core_d);
        }
        // body relief: turn the smooth body down to ds_relief_d over each
        // [z0, z1] in the shaft's "relief" list, with 45 degree transitions
        for (rg = ds_get(s, "relief", [])) if (ds_relief_d > 0 && ds_relief_d < body_d) {
            rd = ds_relief_d / 2; bd = body_d / 2; t = bd - rd;
            rotate_extrude($fn = 96)
                polygon([ [rd, rg[0] + t], [rd, rg[1] - t], [bd, rg[1]], [bd + 1, rg[1]],
                          [bd + 1, rg[0]], [bd, rg[0]] ]);
        }
        if (len(groove) == 4) {
            zc = groove[0]; w = groove[1]; dpt = groove[2]; ar = groove[3];
            rb = body_d / 2 - dpt;
            translate([0, 0, zc])
                rotate_extrude($fn = 96)
                    intersection() {
                        translate([rb + ar, 0]) circle(r = ar, $fn = 180);
                        translate([rb, -w / 2]) square([body_d, w]);
                    }
        }
        // steel rod channel, full length
        if (ds_rod_d > 0)
            translate([0, 0, -1]) cylinder(h = L + 2, d = ds_rod_d + ds_rod_clearance, $fn = 48);
    }
}

// Dowel holes on the split face, at the z positions in the shaft's "dowels"
// list. With ds_dowel_offset = 0 they sit on the axis, one per position,
// which works everywhere along the shaft: on the axis the material above the
// flat face is the full radius, even in the gear sections. With an offset
// they come in pairs at +x and -x so identical halves still register.
module ds_dowel_holes(s) {
    for (z = ds_get(s, "dowels", []))
        for (sx = (ds_dowel_offset > 0 ? [-1, 1] : [0]))
            translate([sx * ds_dowel_offset, 0, z])
                rotate([90, 0, 0]) cylinder(h = 2 * ds_dowel_depth, d = ds_dowel_d + ds_dowel_clearance, center = true, $fn = 24);
}

// One half, cut on the plane y = 0, laid flat with the cut face on z = 0 and
// the shaft axis along +Y.
module drive_shaft_half(s) {
    L = ds_get(s, "length"); R = ds_body_d / 2 + 2;
    rotate([90, 0, 0])
        difference() {
            drive_shaft_solid(s);
            translate([-R, -2 * R, -1]) cube([2 * R, 2 * R, L + 2]);   // remove y < 0
            ds_dowel_holes(s);
        }
}

// Both halves side by side, ready to print.
module drive_shaft_print(s) {
    R = ds_body_d / 2;
    translate([-R - 3, 0, 0]) drive_shaft_half(s);
    translate([ R + 3, 0, 0]) drive_shaft_half(s);
}

module drive_shaft(s) {
    if (ds_split) drive_shaft_print(s); else drive_shaft_solid(s);
}
