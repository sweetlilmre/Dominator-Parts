// assembly.scad - open this file in OpenSCAD. Use the Customizer panel
// (Window > Customizer) to pick the part and tune every dimension from
// config.scad. Export STLs from here or with render.ps1.
//
//   part = "cam"       flat cam plate with shaft and socket (print as shown)
//   part = "gear"      ring gear with plug, shown plug up for printing
//   part = "washer"    spacer washer
//   part = "reduction_gear"  optional gearbox reduction gear (ring as the gear, plus pinion)
//   part = "assembly"  cam with the gear seated, for checking fit and height
//   part = "cam_rim_modifier"    PrusaSlicer modifier: solid rim band on the cam
//   part = "gear_tooth_modifier" PrusaSlicer modifier: solid tooth band on the gear
//   part = "gear_plug_modifier"  PrusaSlicer modifier: solid plug on the gear
//   part = "all"       everything laid out
INVOLUTE_GEAR_NO_DEMO = true;
include <config.scad>
include <cam.scad>
include <cam_gear.scad>
include <reduction_gear.scad>

/* [Part selection] */
part = "all"; // ["all", "cam", "gear", "washer", "reduction_gear", "assembly", "cam_rim_modifier", "gear_tooth_modifier", "gear_plug_modifier"]

module assembled() {
    cam();
    translate([0, 0, shoulder_z()]) cam_gear();
}

if (part == "cam") {
    cam();
} else if (part == "gear") {
    cam_gear_printable();
} else if (part == "washer") {
    spacer_washer();
} else if (part == "reduction_gear") {
    reduction_gear();
} else if (part == "assembly") {
    assembled();
} else if (part == "cam_rim_modifier") {
    cam_rim_modifier();
} else if (part == "gear_tooth_modifier") {
    gear_tooth_modifier();
} else if (part == "gear_plug_modifier") {
    gear_plug_modifier();
} else {
    cam();
    translate([trough_d + 20, 0, 0]) cam_gear_printable();
    translate([trough_d + 20, -(gear_od / 2 + washer_od), 0]) spacer_washer();
    translate([trough_d + 20, gear_od + 8, 0]) reduction_gear();
}

echo(str("gear module = ", gear_module, " mm, pitch dia = ", gear_module * gear_teeth,
         " mm, OD = ", gear_outer_diameter(gear_teeth, gear_module), " mm"));
echo(str("stack: washer ", washer_t, " + plate ", plate_t, " + shaft ", hub_h, " + gear ", gear_thickness,
         " = ", washer_t + plate_t + hub_h + gear_thickness, " mm wall to gear top; plug engages ",
         plug_h, " mm into the hub, socket floor ", hub_h - plug_h - socket_extra,
         " mm above the plate"));
echo(str("cam outer span = ", trough_d + 2 * lobe_height, " mm; spline root dia = ",
         2 * gear_root_radius(spline_teeth, gear_module_from_od(spline_od, spline_teeth, spline_addendum), spline_dedendum),
         " mm vs bore ", bore_d, " mm"));
