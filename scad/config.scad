// config.scad - every tunable dimension for the Dominator cam + gear.
//
// Two printed pieces plus an optional washer:
//   cam   flat plate with the bump outline, an integral shaft (hub) rising
//         from it, and a toothed pocket in the top of the shaft
//   gear  the 36 tooth ring gear with a matching toothed boss underneath,
//         plugs into the pocket and seats on the shaft shoulder
// The steel pin runs through the bore of both.
//
// Sources: (owner) caliper readings on the worn part, (trace) measured from
// the owner's straight-down photo reference/own_cam_top.jpg scaled to the
// 71 mm rim, (TV) Thingiverse remake thing:6097557, (est) still an estimate.

include <lib/involute_gear.scad>

/* [Steel pin and bore] */
// Diameter of the steel pin the cam spins on. Owner measured the OEM bore at
// 6.3, so the pin is likely a touch under that; 6.3 plus clearance is safe. (owner)
pin_d = 6.30;
// Extra diameter so the cam spins freely on the pin. 0.3-0.4 typical for FDM.
bore_clearance = 0.4;
bore_d = pin_d + bore_clearance;

/* [Cam plate] */
// Diameter of the base circle of the rim, not across the bumps. (owner)
cam_od = 71;
// Plate thickness. This is the height of the bump face the follower runs on. (owner)
cam_t = 6.6;
// How far each bump protrudes beyond the base circle. (owner 4, trace 3.9)
cam_ear_out = 5;
// Bumps as [start_deg, end_deg] at mid-height of the bump, counter-clockwise
// seen from the gear side, 0 deg = +X. (trace) An optional third value
// overrides cam_ear_out for that bump.
cam_bumps = [ [15, 65], [90, 133], [168.5, 209.5], [230, 279.5], [305, 354.5] ];
// Rotate the whole bump pattern (deg). Cosmetic, the gear is round.
cam_bump_rot = 0;
// Mirror the whole outline (bump order and edge leans together). The photo
// used for the trace was taken looking at the non-gear side, and the owner
// confirmed the lean runs the other way when the part is held gear side up.
// Set false if a future trace is made from the gear side.
cam_mirror = true;
// Lean of the bump edge faces from radial, deg. Positive = the face leans
// toward the middle of its bump going outward. (trace) In the photo's view
// the clockwise edge leans 21 and the counter-clockwise edge 9; with
// cam_mirror = true the steep face ends up on the counter-clockwise side
// when seen from the gear side. 0 = square radial steps.
cam_lean_start = 21;
cam_lean_end = 9;
// Rounding of the outline corners (mm). 0 = sharp.
cam_outline_round = 0.6;

/* [Shaft (hub) on the cam] */
// Shaft outside diameter. The gear seats on the shoulder at its top. (est)
hub_d = 22;
// Shaft height from the plate top to the gear underside. (owner)
hub_h = 14;

/* [Spline joint between shaft and gear] */
// As in the OEM kit: the gear carries a toothed boss on its underside, the top
// of the cam shaft has a matching toothed pocket. The boss is an involute
// pinion profile. The gear seats on the flat shoulder of the shaft around the
// pocket, so the teeth only carry torque and do not locate the gear.
spline_teeth = 12;
// Tip to tip diameter of the spline. (TV pinion 14.4) Must be < hub_d, and
// leave at least 1.3 mm of wall between the bore and the tooth roots.
spline_od = 14;
// Tooth depth factors for the spline. Shallower than a real gear so the core
// stays thick around the bore.
spline_addendum = 0.9;
spline_dedendum = 0.9;
// Height of the toothed boss under the gear = engagement depth in the shaft.
spline_boss_h = 5;
// The pocket is this much deeper than the boss so the gear seats on the
// shoulder, not on the boss end.
spline_pocket_extra = 0.3;
// Radial clearance added to the pocket. First print at 0.15 had play between
// the boss teeth and the socket; 0.05 next. Go to 0 or slightly negative if
// still loose, since FDM tends to shrink holes and grow posts anyway.
spline_clearance = 0.05;
// Chamfer on the boss end to help it start into the pocket (mm).
spline_lead_in = 0.6;

/* [Ring gear] */
// Tooth count, counted on the original by the owner. (owner)
gear_teeth = 36;
// Tip to tip diameter. Module is derived. (owner)
gear_od = 47;
gear_module = gear_module_from_od(gear_od, gear_teeth);
// Face width. (owner)
gear_thickness = 4.6;
gear_pressure_angle = 20;
// Backlash removed per tooth (mm). Negative makes the teeth fatter. Measured
// on the owner's gear-side photo (reference/own_gear_side.jpg) the OEM teeth
// are about 0.1 of the pitch wider than a textbook involute at every depth,
// i.e. roughly 0.3 mm, though photo bloom inflates that a little. -0.2 is
// the estimate after allowing for bloom. If the mesh binds, move toward 0.
gear_backlash = -0.2;
// Tooth depth factors. The OEM teeth are stubbier than standard: measured
// working depth is about 2.4 mm against 2.78 for a standard 1.25 dedendum,
// so the dedendum is reduced to 1.0 (root diameter about 42 mm).
gear_addendum = 1.0;
gear_dedendum = 1.0;
// Chamfer on tooth faces. 0 to disable.
gear_chamfer = 0.4;
// Rounding of tooth tips (mm). The OEM tips are visibly rounded.
gear_tip_round = 0.3;

/* [Spacer washer] */
// Printed washer between the gearbox wall and the cam underside. 0 = none.
washer_t = 2;
washer_od = 16;

/* [Follower / compound gear (optional, kit 360295 style)] */
fg_ring_teeth = 36;
fg_ring_od = 47;
fg_ring_thickness = 4.6;
fg_pinion_teeth = 12;      // photo 11-12
fg_pinion_od = 14.4;       // TV
fg_pinion_h = 5;
// Raised plate between ring and pinion. 0 height = none.
fg_plate_d = 24;
fg_plate_h = 1.5;

/* [Rendering] */
$fn = 96;
// Tiny overlap so unions/differences do not leave zero-thickness skins.
eps = 0.01;
