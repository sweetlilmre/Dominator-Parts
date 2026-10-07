// drive_gear.scad - the gearbox drive gears.
// Module library: expects config.scad to be included by the caller.
// Origin: centre of the larger gear's underside. Z up.
//
// Drive gear 1 is a compound gear: a 26 tooth gear with a 19 tooth gear above
// it on the same axis, turning on the pin. Both halves share one module, taken
// from the outer gear, which is also the module of the drive shaft pinion the
// gear meshes with.
//
// Drive gear 2 is a single 23 tooth gear with a spacer boss on each face. It
// meshes with drive gear 1's 19 tooth half, so it takes its module from drive
// gear 1 rather than owning one.
//
// The OEM part has a web with material saving slots on one face and spokes on
// the other. The printed part is solid: the slots exist to save moulding
// material and shrinkage, neither of which applies here, and a solid body is
// stronger and simpler to slice.
//
// Printing: larger gear down, as exported. No supports. The bore runs right
// through, so the pin passes through both halves.

module drive_gear_1() {
    difference() {
        union() {
            // 26 tooth half, on the bed
            spur_gear(dg1_outer_teeth, dg1_module, dg1_outer_h,
                      pa = gear_pressure_angle, backlash = ds_tooth_backlash, bore = 0,
                      addendum = dg_addendum, dedendum = dg_dedendum,
                      tip_round = gear_tip_round, chamfer = gear_chamfer);
            // 19 tooth half above it
            translate([0, 0, dg1_outer_h - eps])
                spur_gear(dg1_inner_teeth, dg1_module, dg1_inner_h + eps,
                          pa = gear_pressure_angle, backlash = ds_tooth_backlash, bore = 0,
                          addendum = dg_addendum, dedendum = dg_dedendum,
                          tip_round = gear_tip_round, chamfer = gear_chamfer);
        }
        translate([0, 0, -1])
            cylinder(h = dg1_outer_h + dg1_inner_h + 2, d = bore_d, $fn = 64);
    }
}

// Total height of drive gear 1, for the console echo and for anything stacking
// against it.
function dg1_height() = dg1_outer_h + dg1_inner_h;

// Drive gear 2: one gear with a spacer boss on each face. The bosses stand the
// gear off its neighbours on the pin, so they are part of the gear and not
// separate washers.
// Origin: the underside of the lower spacer. Z up.
module drive_gear_2() {
    difference() {
        union() {
            translate([0, 0, dg2_spacer_h - eps])
                spur_gear(dg2_teeth, dg2_module, dg2_h + eps,
                          pa = gear_pressure_angle, backlash = ds_tooth_backlash, bore = 0,
                          addendum = dg_addendum, dedendum = dg_dedendum,
                          tip_round = gear_tip_round, chamfer = gear_chamfer);
            // spacer below and above
            cylinder(h = dg2_spacer_h + eps, d = dg2_spacer_d);
            translate([0, 0, dg2_spacer_h + dg2_h - eps])
                cylinder(h = dg2_spacer_h + eps, d = dg2_spacer_d);
        }
        translate([0, 0, -1])
            cylinder(h = dg2_height() + 2, d = bore_d, $fn = 64);
    }
}

// Total height of drive gear 2, spacers included.
function dg2_height() = dg2_h + 2 * dg2_spacer_h;

// Drive gear 3: a 26 tooth gear with a boss on each face and an 8 lobe socket
// in each end for the drive shafts. No bore: a solid wall separates the
// sockets, and the gear is carried by the shafts rather than the pin.
// Origin: the end face of the short boss. Z up.
function dg3_height() = dg3_short_h + dg3_gear_h + dg3_long_h;
// Height of the cut plane, at mid-height of the gear.
function dg3_cut_z() = dg3_short_h + dg3_gear_h / 2;

// The drive shaft pinion profile grown by the socket clearance. Built from the
// same values the shaft uses, so a change to the shaft moves the socket with it.
module dg3_socket_2d() {
    offset(delta = dg3_socket_clearance)
        gear_2d(8, gear_module_from_od(ds_gear_od, 8), pa = 20, backlash = ds_tooth_backlash);
}

module drive_gear_3_whole() {
    H = dg3_height();
    difference() {
        union() {
            cylinder(h = H, d = dg3_boss_d);
            translate([0, 0, dg3_short_h])
                spur_gear(dg3_teeth, dg3_module, dg3_gear_h,
                          pa = gear_pressure_angle, backlash = ds_tooth_backlash, bore = 0,
                          addendum = dg_addendum, dedendum = dg_dedendum,
                          tip_round = gear_tip_round, chamfer = gear_chamfer);
        }
        // short shaft socket, open at z = 0
        translate([0, 0, -1]) linear_extrude(dg3_short_socket + 1) dg3_socket_2d();
        // long shaft socket, open at the top
        translate([0, 0, H - dg3_long_socket]) linear_extrude(dg3_long_socket + 1) dg3_socket_2d();
    }
}

// Dowel holes centred on the cut plane, reaching ds_dowel_depth into each half.
module dg3_dowels() {
    for (i = [0 : dg3_dowel_count - 1])
        rotate(i * 360 / dg3_dowel_count + 45)
            translate([dg3_dowel_r, 0, dg3_cut_z() - ds_dowel_depth])
                cylinder(h = 2 * ds_dowel_depth, d = ds_dowel_d + ds_dowel_clearance, $fn = 24);
}

// Printable layout. Split: both halves stand on their cut faces, side by side,
// so the teeth start on the bed and the dowel holes open upward. Each socket
// floor or the wall is the only bridge, over a 13 mm hole.
module drive_gear_3() {
    zc = dg3_cut_z();
    H = dg3_height();
    big = dg3_module * (dg3_teeth + 2) + 10;
    if (!dg3_split) {
        drive_gear_3_whole();
    } else {
        // half A: short boss and the lower half of the gear, short boss up
        translate([0, 0, zc]) mirror([0, 0, 1])
            difference() {
                drive_gear_3_whole();
                dg3_dowels();
                translate([-big / 2, -big / 2, zc]) cube([big, big, H]);
            }
        // half B: upper half of the gear and the long boss, long boss up
        translate([dg3_module * (dg3_teeth + 2) + 6, 0, -zc])
            difference() {
                drive_gear_3_whole();
                dg3_dowels();
                translate([-big / 2, -big / 2, -1]) cube([big, big, zc + 1]);
            }
    }
}
