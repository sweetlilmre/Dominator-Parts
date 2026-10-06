// drive_gear.scad - the gearbox drive gears.
// Module library: expects config.scad to be included by the caller.
// Origin: centre of the larger gear's underside. Z up.
//
// Drive gear 1 is a compound gear: a 26 tooth gear with a 19 tooth gear above
// it on the same axis, turning on the pin. Both halves share one module, taken
// from the outer gear, which is also the module of the drive shaft pinion the
// gear meshes with.
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
                      addendum = dg1_addendum, dedendum = dg1_dedendum,
                      tip_round = gear_tip_round, chamfer = gear_chamfer);
            // 19 tooth half above it
            translate([0, 0, dg1_outer_h - eps])
                spur_gear(dg1_inner_teeth, dg1_module, dg1_inner_h + eps,
                          pa = gear_pressure_angle, backlash = ds_tooth_backlash, bore = 0,
                          addendum = dg1_addendum, dedendum = dg1_dedendum,
                          tip_round = gear_tip_round, chamfer = gear_chamfer);
        }
        translate([0, 0, -1])
            cylinder(h = dg1_outer_h + dg1_inner_h + 2, d = bore_d, $fn = 64);
    }
}

// Total height of drive gear 1, for the console echo and for anything stacking
// against it.
function dg1_height() = dg1_outer_h + dg1_inner_h;
