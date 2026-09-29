// cam_gear.scad - the ring gear with a plug on its underside that
// plugs into the socket in the top of the hub.
// Module library: expects config.scad and cam.scad to be included by the caller.
// Origin: underside of the gear face (the face that seats on the hub
// shoulder). The plug hangs below z = 0.

module cam_gear() {
    difference() {
        union() {
            spur_gear(gear_teeth, gear_module, gear_thickness,
                      pa = gear_pressure_angle, backlash = gear_backlash, bore = 0,
                      addendum = gear_addendum, dedendum = gear_dedendum,
                      tip_round = gear_tip_round, chamfer = gear_chamfer);
            // plug: built pointing +z then flipped so its chamfer is at the free end
            translate([0, 0, -plug_h]) mirror([0, 0, 1]) translate([0, 0, -plug_h - eps])
                plug(plug_h + eps);
        }
        translate([0, 0, -plug_h - 1]) cylinder(h = plug_h + gear_thickness + 2, d = bore_d, $fn = 64);
    }
}

// Printable orientation: flat side on the bed, plug pointing up.
module cam_gear_printable() {
    translate([0, 0, gear_thickness]) mirror([0, 0, 1]) cam_gear();
}

// Slicer modifier volumes for the gear, in the printable orientation.
// Tooth band: ring from gear_band inside the root circle to outside the tips.
module gear_tooth_modifier() {
    rr = gear_root_radius(gear_teeth, gear_module, gear_dedendum);
    rt = gear_tip_radius(gear_teeth, gear_module, gear_addendum);
    translate([0, 0, -0.5])
        difference() {
            cylinder(h = gear_thickness + 1, r = rt + 2);
            translate([0, 0, -1]) cylinder(h = gear_thickness + 3, r = rr - gear_band);
        }
}
// Core: cylinder over the centre of a gear. On the gear it covers the plug
// and the gear body under it; on the reduction gear the pinion, the plate and
// the ring under them. Sized from the taller and wider of the two, so one
// modifier serves both.
module gear_core_modifier() {
    h = max(gear_thickness + plug_h, rg_ring_thickness + rg_plate_h + rg_pinion_h);
    r = max(spline_od, rg_pinion_od) / 2 + 1.5;
    translate([0, 0, -0.5]) cylinder(h = h + 1, r = r);
}
