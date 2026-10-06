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
// the owner's straight-down photo reference/cam_v2/own_cam_top_v2.jpg scaled to the
// 71 mm rim, (est) still an estimate.

include <lib/involute_gear.scad>

/* [Steel pin and bore] */
// Diameter of the steel pin the cam spins on. (owner) An earlier reading of
// the worn OEM bore gave 6.3; the v1 photo traces read it at 6.1 to 6.4. The
// pin itself is 6.00. The printed bore is pin + clearance.
pin_d = 6.00;
// Extra diameter so the cam spins freely on the pin. 0.3-0.4 typical for FDM.
bore_clearance = 0.4;
bore_d = pin_d + bore_clearance;

/* [Cam version] */
// The cam is moulded with a version number on both faces. The two versions
// share every dimension measured so far except the lobe pattern and the lobe
// height, so only those two are switched below. (owner)
cam_version = "v1"; // ["v1", "v2"]
// The OEM cam carries its number moulded into both faces. The printed cam
// engraves the same digit, taken from cam_version, so a printed part can be
// told apart from the other version once it is off the bed. 0 = no mark.
cam_version_number_size = 8;
// How deep the digit is cut into each face.
cam_version_number_depth = 0.5;
// Where the digit sits: radius from the centre, and angle around the plate.
// Must clear the hub and stay inside the trough circle.
cam_version_number_r = 22;
cam_version_number_angle = 270;
// The spline_clearance value (e.g. "0.05") is engraved the same way on the
// opposite side of the plate, so a cam sliced from a stale STL shows the
// clearance it was cut at. Same depth and radius as the digit. 0 = no mark.
cam_clearance_mark_size = 5;

/* [Cam plate] */
// Diameter of the trough circle of the rim, not across the lobes. (owner)
trough_d = 71;
// Plate thickness. This is the height of the lobe face the follower runs on. (owner)
plate_t = 6.6;
// How far each lobe protrudes beyond the trough circle, per version.
// (owner; v1 trace 4.15, v2 trace 4.5)
v1_lobe_height = 4;
v2_lobe_height = 5;
// Lobes as [start_deg, end_deg] at mid-height of the lobe, counter-clockwise
// seen from the gear side, 0 deg = +X. An optional third value overrides
// lobe_height for that lobe.
// v1 (trace) measured from reference/cam_v1/own_cam_top_v1.jpg, scaled by the
// cutting-mat grid and anchored to the 71.5 mm trough circle read off
// reference/cam_v1/own_cam_top_ruler_v1.jpg.
v1_lobes = [ [20.2, 70.1], [90.4, 131.5], [164, 210], [235, 284.9], [305.5, 355] ];
// v2 (trace) from reference/cam_v2/own_cam_top_v2.jpg. Re-measuring that photo
// with the v1 pipeline reproduces these widths to within 1.5 deg.
v2_lobes = [ [15, 65], [90, 133], [168.5, 209.5], [230, 279.5], [305, 354.5] ];
// The two differ in the narrow pair of lobes (v1 41.1 and 46.0 deg wide
// against v2 43 and 41) and in the largest trough (v1 32.5, v2 35.5 deg).
lobes       = cam_version == "v1" ? v1_lobes : v2_lobes;
lobe_height = cam_version == "v1" ? v1_lobe_height : v2_lobe_height;
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
// Not an OEM dimension: the OEM gear and cam mate differently, so the spline
// is free design. (design) Sized to match the reduction gear pinion at
// 11 T / 16 mm so the project has one small tooth size rather than two nearly
// identical ones. Deliberately a SEPARATE parameter from rg_pinion_teeth /
// rg_pinion_od even though the values agree: the pinion is constrained by its
// mesh with the cam gear, this is constrained by the hub wall and by the press
// fit, and a change made for one must not silently alter the other.
spline_teeth = 11;
// Tip to tip diameter of the spline. Must be < hub_d, and
// leave at least 1.3 mm of wall between the bore and the tooth roots.
spline_od = 16;
// Tooth depth factors for the spline. Shallower than a real gear so the core
// stays thick around the bore.
spline_addendum = 0.9;
spline_dedendum = 0.9;
// Height of the plug under the gear = engagement depth in the hub.
plug_h = 5;
// The socket is this much deeper than the plug so the gear seats on the
// shoulder, not on the plug end.
socket_extra = 0.3;
// The whole of the joint's tolerance, applied as offset(delta = clearance) on
// the socket profile, so it is the gap normal to every flank, root and tip.
// It does not scale with tooth count or diameter.
// Printer dependent: run the fit test coupon (part = "fit_test") and set your
// own value. On the owner's Prusa MK4 in PETG the coupon found 0.05 best at
// 11 T / 16 mm, and 0.15 failed on both cam prints. A contributor's printer
// gripped best at 0.15. The value is engraved on the cam (clearance_mark).
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
// on the owner's gear-side photo (reference/cam_v2/own_gear_side_v2.jpg) the OEM teeth
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
// One of the gearbox reduction gears: a ring plus a pinion on top. It is a
// different part from the cam gear and owns its ring dimensions outright.
// They happen to read the same today, but nothing forces them to move
// together: changing the cam gear must not silently reshape this part.
rg_ring_teeth = 36;        // (owner) same count as the cam gear, measured separately
rg_ring_od = 47;           // (owner)
rg_ring_thickness = 4.6;   // (owner)
rg_ring_module = gear_module_from_od(rg_ring_od, rg_ring_teeth);
// The pinion drives the cam gear, so its module must match the cam gear's.
// That is a mesh constraint, not a shared parameter: the value is set here and
// assembly.scad echoes a warning if the two modules drift apart.
// At 11 T / 16 mm the module is 1.2308 against the cam gear's 1.2368, a 0.5
// percent match. The earlier 12 T / 14.4 estimate was 17 percent out and
// could not have meshed at all.
rg_pinion_teeth = 11;      // (owner) counted; the photo suggested 11-12
rg_pinion_od = 16;         // (owner) across the tips
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

/* [Drive gear 1] */
// A compound gearbox drive gear: a 26 tooth gear with a 19 tooth gear above it
// on one axis, turning on the same pin as the rest of the train. The OEM part
// has a web with material saving slots; the printed one is solid throughout.
// The bore is bore_d, the same hole as the cam and the gear, not a value of its
// own. (owner) Confirmed on the part: the drive gears run on the same pin. A
// trace of the owner's photograph reads the bore at 6.48 against the 6.40 that
// pin_d plus bore_clearance gives. If a drive gear ever needs a different pin,
// give the drive gears their own diameter rather than widening bore_clearance,
// which would loosen the cam as a side effect.
// Outer gear, measured tip to tip. (owner) That reading is trustworthy because
// 26 is even, so the caliper straddles two opposite tooth tips, and 35 mm over
// 26 teeth gives a module of exactly 1.25.
dg1_outer_teeth = 26;
dg1_outer_od = 35;
// Face widths. (owner) The 19 tooth gear is the taller of the two at 11 mm and
// the 26 tooth gear is 10 mm, as in own_drive_gears_measurements.txt. They were
// briefly entered the other way round here, from a reading that put the 11 mm
// section at the spoked face; the owner corrected it. The two widths add to the
// 21 mm overall height, which was measured separately, so all three agree.
dg1_outer_h = 10;
dg1_inner_teeth = 19;
dg1_inner_h = 11;
// One module for both halves, taken from the outer gear. It also matches the
// drive shaft pinion this gear meshes with to within 0.4 percent: that pinion
// reads 1.245 only because ds_gear_od is 12.45 rather than 12.5.
dg1_module = gear_module_from_od(dg1_outer_od, dg1_outer_teeth);
// Derived rather than measured. 19 is odd, so no tooth lies opposite another
// and a caliper cannot span tip to tip; it reads low. The owner read 25 to 26
// against the 26.25 this gives. If a better measurement ever contradicts it,
// replace this with the measured value.
dg1_inner_od = dg1_module * (dg1_inner_teeth + 2);
// Tooth depth factors, shared by every drive gear. Standard, unlike the cam
// gear's deliberately stubby teeth: the root to tip ratio measured on drive
// gear 1's outer gear implies a dedendum near 1.29, and the drive shaft pinion
// the train meshes with takes the library defaults. Backlash is shared with
// that pinion for the same reason.
dg_addendum = 1.0;
dg_dedendum = 1.25;

/* [Drive gear 2] */
// A single gear with a spacer boss on each face, so it stands off its
// neighbours on the pin. The OEM part has material saving slots in its web;
// the printed one is solid.
// (owner) Counted twice.
dg2_teeth = 23;
// The module is drive gear 1's, not an independent value: this gear meshes
// with drive gear 1's 19 tooth half, and meshing gears must share a module.
dg2_module = dg1_module;
// Derived rather than measured, for the same reason as drive gear 1's inner
// gear: 23 is odd, so no tooth lies opposite another, a caliper cannot span
// tip to tip and reads low. The owner read 30 against this 31.25.
dg2_od = dg2_module * (dg2_teeth + 2);
// Face width of the gear body, without the spacers. (owner) A trace of the side
// photograph suggested 17 to 19 and was wrong; the printed gear at 15 is
// correct, so the caliper reading stands and the trace is not to be trusted for
// a dimension along the axis of a part photographed from the side.
dg2_h = 15;
// Spacer boss on each face. Height (owner); a trace of the side photograph
// gives 1.56. The diameter is from the same trace and is not critical: it only
// has to clear the root circle, which is 25.6 mm.
dg2_spacer_h = 1.5;
dg2_spacer_d = 14;

/* [Slicer modifiers] */
// Modifier volumes for PrusaSlicer. Load each as a modifier on its part and
// give it ONLY Fill density = 100 percent. Set the perimeter count on the
// object itself, not on the modifier: a perimeter override on a modifier
// makes the slicer draw perimeters around the modifier's inner boundary too.
// Radial depth of the cam rim band, inward from the trough circle. The same
// for both cam versions, so one modifier fits both. (owner: 8 and 5 were
// too deep, 3 too shallow)
rim_band = 4;
// Radial depth of the gear tooth band, inward from the gear root circle.
gear_band = 4;
// How far the cam socket modifier reaches below the socket floor.
socket_band = 1.5;

/* [Rendering] */
$fn = 96;
// Tiny overlap so unions/differences do not leave zero-thickness skins.
eps = 0.01;
