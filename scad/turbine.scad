// turbine.scad - the turbine that drives the cleaner.
// Module library: expects config.scad to be included by the caller.
//
// Water sucked through the turbine turns its blades, which turn the gear
// train. The OEM part is a single moulding: two end discs with the blades
// formed between them, each disc carrying a gear on a shaft outside it. That
// shape cannot be printed without heavy support, so it is made here as three
// parts that glue together:
//
//   turbine_drive_side      disc, 11 tooth gear on its shaft, 5 blade cutouts
//   turbine_reduction_side  disc, 13 tooth gear on a necked shaft, 5 cutouts
//   turbine_blade           printed 5 times
//
// The cutouts pass right through each disc and match the blade profile, so the
// blade is a press fit through both discs and is glued. The blade is longer
// than the gap between the discs by one disc thickness at each end, and
// finishes flush with both outer faces.
//
// Printing: each disc stands on its inner face, which is flat once the blades
// are separate, with its shaft pointing up. No supports and no overhangs. The
// blade has the same cross section along its whole length, so it can stand on
// end and every layer is identical.
//
// Origin for both discs: the inner face, on the blade side. Z up, away from
// the blades, so the shaft runs up the positive Z axis.

// Thickness of the disc where the blades pass through it. The recess leaves a
// full thickness ring only at the rim; everything inside is a thinner web.
function turbine_web_t() = turbine_disc_t - turbine_recess_h;
// Total blade length: the gap between the discs plus the web at each end, so
// the blade finishes flush with the floor of each recess.
function turbine_blade_l() = turbine_blade_gap + 2 * turbine_web_t();
// Overall width of the assembled turbine, for the console echo.
function turbine_width() = turbine_drive_shaft_l + turbine_disc_t
                         + turbine_blade_gap + turbine_disc_t
                         + turbine_reduction_shaft_l;

// One blade cross section at its traced position, rotated to blade i.
module turbine_blade_2d(i = 0, grow = 0) {
    rotate(i * 360 / turbine_blades)
        offset(delta = grow)
            polygon(turbine_blade_profile);
}

// The five cutouts through a disc, grown by the fit clearance.
module turbine_blade_cutouts() {
    for (i = [0 : turbine_blades - 1])
        translate([0, 0, -1])
            linear_extrude(turbine_disc_t + 2)
                turbine_blade_2d(i, turbine_blade_clearance);
}

// Z of the floor of the recess, which is where a blade finishes.
function turbine_recess_z() = turbine_disc_t - turbine_recess_h;

// A disc with its blade cutouts and the bore, without the shaft.
module turbine_disc() {
    difference() {
        cylinder(h = turbine_disc_t, d = turbine_disc_d);
        turbine_blade_cutouts();
        // the recess: everything inside the rim, on the outer face, so the
        // disc is a thin web with a full thickness ring around its edge
        translate([0, 0, turbine_disc_t - turbine_recess_h])
            cylinder(h = turbine_recess_h + eps, d = turbine_disc_d - 2 * turbine_rim_w);
        translate([0, 0, -1])
            cylinder(h = turbine_disc_t + 2, d = bore_d, $fn = 64);
    }
}

// A toothed shaft standing on the outer face of a disc. It runs, in order: a
// short plain boss off the disc, then the teeth, then a narrower plain neck to
// the end. The bore runs through the lot.
//   boss_l  plain length against the disc
//   teeth_l toothed length, in the middle
//   neck_l  plain length beyond the teeth
module turbine_shaft(teeth, od, boss_l, teeth_l, neck_l) {
    // the boss is as wide as the gear, so the teeth run straight out of it;
    // only the reduction side has anything beyond the teeth, and it is narrow
    mod = gear_module_from_od(od, teeth);
    total = boss_l + teeth_l + neck_l;
    difference() {
        union() {
            if (boss_l > 0) cylinder(h = boss_l + eps, d = od);
            translate([0, 0, boss_l])
                spur_gear(teeth, mod, teeth_l,
                          pa = gear_pressure_angle, backlash = ds_tooth_backlash, bore = 0,
                          addendum = dg_addendum, dedendum = dg_dedendum,
                          tip_round = gear_tip_round, chamfer = gear_chamfer);
            if (neck_l > 0)
                translate([0, 0, boss_l + teeth_l - eps])
                    cylinder(h = neck_l + eps, d = turbine_neck_d);
        }
        translate([0, 0, -1]) cylinder(h = total + 2, d = bore_d, $fn = 64);
    }
}

// The boss is whatever the measured total leaves after the teeth and any
// neck, so each shaft always comes to the length that was measured.
function turbine_drive_boss_l() =
    turbine_drive_shaft_l - turbine_drive_teeth_l - turbine_drive_neck_l;
function turbine_reduction_boss_l() =
    turbine_reduction_shaft_l - turbine_reduction_teeth_l - turbine_reduction_neck_l;

// The drive gear side. The boss starts at the floor of the recess, so the
// shaft still stands turbine_drive_shaft_l proud of the disc's outer face.
// The teeth are the end of this shaft; there is nothing beyond them.
module turbine_drive_side() {
    turbine_disc();
    translate([0, 0, turbine_recess_z() - eps])
        turbine_shaft(turbine_drive_teeth, turbine_drive_od,
                      turbine_drive_boss_l() + turbine_recess_h,
                      turbine_drive_teeth_l, turbine_drive_neck_l);
}

// The reduction gear side: the same, plus a narrow tube beyond the teeth.
module turbine_reduction_side() {
    turbine_disc();
    translate([0, 0, turbine_recess_z() - eps])
        turbine_shaft(turbine_reduction_teeth, turbine_reduction_od,
                      turbine_reduction_boss_l() + turbine_recess_h,
                      turbine_reduction_teeth_l, turbine_reduction_neck_l);
}

// One blade, standing on end at the origin, with the same cross section all
// the way along. Printed five times.
module turbine_blade() {
    linear_extrude(turbine_blade_l()) turbine_blade_2d(0);
}

// One blade, moved to the origin for printing. Print it five times.
module turbine_blade_printable() {
    translate([-23, -27, 0]) turbine_blade();
}

// The three parts assembled, for checking fit and overall width.
module turbine_assembly() {
    translate([0, 0, turbine_blade_gap + turbine_disc_t])
        turbine_drive_side();
    mirror([0, 0, 1]) turbine_reduction_side();
    for (i = [0 : turbine_blades - 1])
        translate([0, 0, -turbine_web_t()])
            linear_extrude(turbine_blade_l()) turbine_blade_2d(i);
}
