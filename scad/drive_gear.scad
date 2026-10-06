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
