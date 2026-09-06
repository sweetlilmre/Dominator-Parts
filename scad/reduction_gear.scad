// reduction_gear.scad - one of the gearbox reduction gears (kit 360295
// style): a ring identical to the cam gear, a raised plate, a small pinion on
// top, through bore. The exact outline of the OEM plate is not known from
// photos; it is modelled as a plain disc. Adjust rg_plate_d / rg_plate_h or
// replace pinion_plate() once you can trace the real one.
// Module library: expects config.scad to be included by the caller.

rg_pinion_module = gear_module_from_od(rg_pinion_od, rg_pinion_teeth);

module pinion_plate() {
    if (rg_plate_h > 0) cylinder(h = rg_plate_h + eps, d = rg_plate_d);
}

module reduction_gear() {
    difference() {
        union() {
            spur_gear(gear_teeth, gear_module, gear_thickness,
                      pa = gear_pressure_angle, backlash = gear_backlash,
                      addendum = gear_addendum, dedendum = gear_dedendum,
                      tip_round = gear_tip_round, chamfer = gear_chamfer);
            translate([0, 0, gear_thickness - eps]) pinion_plate();
            translate([0, 0, gear_thickness + rg_plate_h - eps])
                spur_gear(rg_pinion_teeth, rg_pinion_module, rg_pinion_h + eps,
                          pa = gear_pressure_angle, backlash = gear_backlash, chamfer = 0.3);
        }
        translate([0, 0, -1])
            cylinder(h = gear_thickness + rg_plate_h + rg_pinion_h + 2, d = bore_d, $fn = 64);
    }
}
