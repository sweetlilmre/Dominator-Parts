// cam_gear.scad - the ring gear with a toothed boss on its underside that
// plugs into the pocket in the top of the cam shaft.
// Module library: expects config.scad and cam.scad to be included by the caller.
// Origin: underside of the gear face (the face that seats on the shaft
// shoulder). The boss hangs below z = 0.

module cam_gear() {
    difference() {
        union() {
            spur_gear(gear_teeth, gear_module, gear_thickness,
                      pa = gear_pressure_angle, backlash = gear_backlash, bore = 0,
                      addendum = gear_addendum, dedendum = gear_dedendum,
                      tip_round = gear_tip_round, chamfer = gear_chamfer);
            // boss: built pointing +z then flipped so its chamfer is at the free end
            translate([0, 0, -spline_boss_h]) mirror([0, 0, 1]) translate([0, 0, -spline_boss_h - eps])
                spline_boss(spline_boss_h + eps);
        }
        translate([0, 0, -spline_boss_h - 1]) cylinder(h = spline_boss_h + gear_thickness + 2, d = bore_d, $fn = 64);
    }
}

// Printable orientation: gear face on the bed, boss pointing up.
module cam_gear_printable() {
    translate([0, 0, gear_thickness]) mirror([0, 0, 1]) cam_gear();
}
