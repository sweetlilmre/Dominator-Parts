// config.scad - every tunable dimension for the Dominator cam + gear.
//
// Two printed pieces plus an optional washer:
//   cam   flat plate with the lobe outline, an integral hub rising
//         from it, and a socket in the top of the hub
//   gear  the 36 tooth ring gear with a matching plug underneath,
//         plugs into the socket and seats on the hub shoulder
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
// Diameter of the trough circle of the rim, not across the lobes. (owner)
trough_d = 71;
// Plate thickness. This is the height of the lobe face the follower runs on. (owner)
plate_t = 6.6;
// How far each lobe protrudes beyond the trough circle. (owner 4, trace 3.9)
lobe_height = 5;
// Lobes as [start_deg, end_deg] at mid-height of the lobe, counter-clockwise
// seen from the gear side, 0 deg = +X. (trace) An optional third value
// overrides lobe_height for that lobe.
lobes = [ [15, 65], [90, 133], [168.5, 209.5], [230, 279.5], [305, 354.5] ];
// Rotate the whole lobe pattern (deg). Cosmetic, the gear is round.
lobe_rot = 0;
// Mirror the whole outline (lobe order and edge leans together). The photo
// used for the trace was taken looking at the non-gear side, and the owner
// confirmed the lean runs the other way when the part is held gear side up.
// Set false if a future trace is made from the gear side.
cam_mirror = true;
// Lean of the lobe edge faces from radial, deg. Positive = the face leans
// toward the middle of its lobe going outward. (trace) In the photo's view
// the clockwise edge leans 21 and the counter-clockwise edge 9; with
// cam_mirror = true the ramp face ends up on the counter-clockwise side
// when seen from the gear side. 0 = square radial steps.
ramp_lean = 21;
drop_lean = 9;
// Rounding of the outline corners (mm). 0 = sharp.
plate_corner_round = 0.6;

/* [Hub on the cam] */
// Hub outside diameter. The gear seats on the shoulder at its top. (est)
hub_d = 22;
// Hub height from the plate top to the gear underside. (owner)
hub_h = 14;

/* [Spline joint between hub and gear] */
// As in the OEM kit: the gear carries a plug on its underside, the top
// of the hub has a matching socket. The plug is an involute
// pinion profile. The gear seats on the flat shoulder of the hub around the
// socket, so the teeth only carry torque and do not locate the gear.
spline_teeth = 12;
// Tip to tip diameter of the spline. (TV pinion 14.4) Must be < hub_d, and
// leave at least 1.3 mm of wall between the bore and the tooth roots.
spline_od = 14;
// Tooth depth factors for the spline. Shallower than a real gear so the core
// stays thick around the bore.
spline_addendum = 0.9;
spline_dedendum = 0.9;
// Height of the plug under the gear = engagement depth in the hub.
plug_h = 5;
// The socket is this much deeper than the plug so the gear seats on the
// shoulder, not on the plug end.
socket_extra = 0.3;
// Radial clearance added to the socket. First print at 0.15 had play between
// the plug teeth and the socket; 0.05 next. Go to 0 or slightly negative if
// still loose, since FDM tends to shrink holes and grow posts anyway.
spline_clearance = 0.05;
// Chamfer on the plug end to help it start into the socket (mm).
spline_lead_in = 0.6;

/* [Gear] */
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

/* [Reduction gear (optional)] */
// One of the gearbox reduction gears: a ring identical to the cam gear with a
// pinion on top. Ring teeth, diameter and thickness are taken from the gear
// so the two cannot drift apart. Pinion values are unmeasured. (est)
rg_pinion_teeth = 12;      // photo 11-12
rg_pinion_od = 14.4;       // TV
rg_pinion_h = 5;
// Raised plate between ring and pinion. 0 height = none. Real outline unknown.
rg_plate_d = 24;
rg_plate_h = 1.5;

/* [Drive shafts] */
// Two gearbox drive shafts. Each is an 8 tooth pinion profile running the
// full length, with round body sections, shallow-tooth (lobed) sections and
// an optional arc groove. Designed to print as two lengthwise halves lying
// flat and glued together, aligned by dowels, so the layers run along the shaft.
// Gear tip diameter, both shafts. (owner: 12.4-12.5 by caliper)
ds_gear_od = 12.45;
// Plain body diameter.
ds_body_d = 12.5;
// Tooth thickness adjustment for the shaft pinions (mm, negative = fatter).
ds_tooth_backlash = 0;
// Length of the cone that eases each body end into the tooth roots. The
// vertical print snapped exactly at this step; 0 = sharp step as the OEM.
ds_step_fillet = 2;
// Split into two halves for flat printing. false = one piece.
ds_split = true;
// Where the split plane passes through the pinion: "gaps" puts a tooth gap
// on the glue line so each half has whole teeth and misalignment only
// changes a gap width; "teeth" puts half teeth on the bed for a wider
// footprint but the glue line runs through two teeth.
ds_split_at = "teeth"; // ["gaps", "teeth"]
// Optional steel rod channel down the centre. 0 = none (default: the halves
// are aligned by dowels on the axis instead). A 3 mm rod matches the OEM's
// 2.83 mm axial hole if you want the extra bending strength.
ds_rod_d = 0;
ds_rod_clearance = 0.2;
// Dowel holes on the split face, for short pieces of 1.75 mm filament.
ds_dowel_d = 1.75;
ds_dowel_clearance = 0.25;
ds_dowel_depth = 2.5;        // depth into each half
// 0 = a single row of dowels on the axis, usable along the whole shaft
// including the gear sections. > 0 = pairs at +x and -x (needs ds_rod_d = 0
// or enough room beside the rod channel).
ds_dowel_offset = 0;
// Diameter the smooth body is turned down to in the "relief" regions, to
// save print time and material. 0 = no relief.
ds_relief_d = 10;
// Fields per shaft: length, teeth, body [[z0,z1],...], lobed [[z0,z1],...],
// lobe_core_d, groove [z_centre, width, depth, arc_r], dowels [z, ...],
// relief [[z0,z1],...] (regions of body turned down to ds_relief_d).
// Dowel positions: anywhere on the axis except inside the groove; put some
// in each gear section so the teeth of the two halves line up.
// Long shaft: 12 mm gear, body with an arc groove, 50 mm gear. Full diameter
// is kept only for 4 mm beside each gear; the dip stays, cut into the relief.
ds_long = [
    ["length", 177], ["teeth", 8],
    ["body", [[12, 127]]],
    ["groove", [45, 10, 2.075, 10.3]],
    ["relief", [[16, 123]]],
    ["dowels", [4, 10, 20, 35, 60, 90, 120, 131, 145, 160, 173]]
];
// Short shaft: 18 mm gear, lobed 10 mm, body 18 mm, lobed 12 mm, 25 mm gear.
ds_short = [
    ["length", 83], ["teeth", 8],
    ["body", [[28, 46]]],
    ["lobed", [[18, 28], [46, 58]]], ["lobe_core_d", 9.7],
    ["dowels", [4, 19, 34, 49, 64, 79]]
];

/* [Slicer modifiers] */
// Modifier volumes for PrusaSlicer. Load each as a modifier on its part and
// give it ONLY Fill density = 100 percent. Set the perimeter count on the
// object itself, not on the modifier: a perimeter override on a modifier
// makes the slicer draw perimeters around the modifier's inner boundary too.
// Radial depth of the cam rim band, inward from the trough circle.
rim_band = 8;
// Radial depth of the gear tooth band, inward from the gear root circle.
gear_band = 4;

/* [Rendering] */
$fn = 96;
// Tiny overlap so unions/differences do not leave zero-thickness skins.
eps = 0.01;
