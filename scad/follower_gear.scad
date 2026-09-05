// follower_gear.scad - compound gear as in the Pentair 360295 cam gear kit:
// big ring gear, raised follower plate, small pinion on top, through bore.
// The exact outline of the OEM follower plate is not known from photos; it
// is modelled as a plain disc. Adjust fg_plate_d / fg_plate_h or replace
// follower_plate() once you can trace the real one.
// Module library: expects config.scad to be included by the caller.

fg_ring_module = gear_module_from_od(fg_ring_od, fg_ring_teeth);
fg_pinion_module = gear_module_from_od(fg_pinion_od, fg_pinion_teeth);

module follower_plate() {
    if (fg_plate_h > 0) cylinder(h = fg_plate_h + eps, d = fg_plate_d);
}

module follower_gear() {
    difference() {
        union() {
            spur_gear(fg_ring_teeth, fg_ring_module, fg_ring_thickness,
                      pa = gear_pressure_angle, backlash = gear_backlash,
                      addendum = gear_addendum, dedendum = gear_dedendum,
                      tip_round = gear_tip_round, chamfer = gear_chamfer);
            translate([0, 0, fg_ring_thickness - eps]) follower_plate();
            translate([0, 0, fg_ring_thickness + fg_plate_h - eps])
                spur_gear(fg_pinion_teeth, fg_pinion_module, fg_pinion_h + eps,
                          pa = gear_pressure_angle, backlash = gear_backlash, chamfer = 0.3);
        }
        translate([0, 0, -1])
            cylinder(h = fg_ring_thickness + fg_plate_h + fg_pinion_h + 2, d = bore_d, $fn = 64);
    }
}
