// involute_gear.scad - self-contained involute spur gear for OpenSCAD.
// No external libraries required.
//
// Conventions: all lengths in mm, angles in degrees. A tooth is centred on
// the +X axis so two gears mesh when one is rotated by 180/teeth degrees.

function gear_pitch_radius(teeth, mod)   = mod * teeth / 2;
function gear_tip_radius(teeth, mod, addendum = 1.0) = gear_pitch_radius(teeth, mod) + addendum * mod;
function gear_root_radius(teeth, mod, dedendum = 1.25) = gear_pitch_radius(teeth, mod) - dedendum * mod;
function gear_outer_diameter(teeth, mod, addendum = 1.0) = 2 * gear_tip_radius(teeth, mod, addendum);
// Module from a measured outside diameter and a tooth count.
function gear_module_from_od(od, teeth, addendum = 1.0) = od / (teeth + 2 * addendum);
// Centre distance between two meshing gears of the same module.
function gear_centre_distance(t1, t2, mod) = mod * (t1 + t2) / 2;

// Involute function in degrees: inv(a) = tan(a) - a.
function _inv_deg(a) = (tan(a) - a * PI / 180) * 180 / PI;
// Pressure angle at radius r for a base radius rb.
function _pa_at(r, rb) = acos(min(1, rb / r));

// One flank of one tooth as a list of [x, y] points, from the root to the tip.
function _flank(teeth, mod, pa, backlash, addendum, dedendum, steps) =
    let(
        rp = gear_pitch_radius(teeth, mod),
        rb = rp * cos(pa),
        rt = gear_tip_radius(teeth, mod, addendum),
        rr = gear_root_radius(teeth, mod, dedendum),
        // half tooth thickness angle at the pitch circle, reduced for backlash
        half = 90 / teeth - (backlash / 2) / rp * 180 / PI,
        // polar offset so the flank passes through the pitch point at angle "half"
        off = half + _inv_deg(pa),
        r0 = max(rb, rr),
        pts = [ for (i = [0 : steps]) let(r = r0 + (rt - r0) * i / steps,
                                          a = off - _inv_deg(_pa_at(r, rb)))
                [ r * cos(a), r * sin(a) ] ]
    )
    // if the root is below the base circle, add a radial segment down to the root
    (rr < rb) ? concat([[rr * cos(off), rr * sin(off)]], pts) : pts;

module gear_tooth_2d(teeth, mod, pa = 20, backlash = 0, addendum = 1.0, dedendum = 1.25, steps = 8) {
    f = _flank(teeth, mod, pa, backlash, addendum, dedendum, steps);
    upper = f;
    lower = [ for (i = [len(f) - 1 : -1 : 0]) [ f[i][0], -f[i][1] ] ];
    polygon(concat([[0, 0]], upper, lower));
}

// 2D involute spur gear outline.
//   teeth      number of teeth
//   mod        module (mm per tooth, = pitch diameter / teeth)
//   pa         pressure angle, 20 is standard
//   backlash   total circumferential backlash to remove from each tooth (mm)
//   addendum   tip height factor (1.0 standard)
//   dedendum   root depth factor (1.25 standard, gives 0.25 m clearance)
//   tip_round  optional rounding of the tip corners (mm), 0 = sharp
module gear_2d(teeth, mod, pa = 20, backlash = 0, addendum = 1.0, dedendum = 1.25, tip_round = 0, steps = 8) {
    rr = gear_root_radius(teeth, mod, dedendum);
    offset(r = tip_round) offset(delta = -tip_round)
    union() {
        circle(r = rr, $fn = max(48, teeth * 4));
        for (i = [0 : teeth - 1])
            rotate(i * 360 / teeth)
                gear_tooth_2d(teeth, mod, pa, backlash, addendum, dedendum, steps);
    }
}

// 3D spur gear.
//   thickness  face width (mm)
//   bore       through-hole diameter, 0 for none
//   chamfer    chamfer on both tooth faces (mm), 0 for none. Helps first-layer
//              adhesion and mesh entry, and hides elephant foot.
module spur_gear(teeth, mod, thickness, pa = 20, backlash = 0, bore = 0,
                 addendum = 1.0, dedendum = 1.25, tip_round = 0, chamfer = 0, steps = 8) {
    difference() {
        if (chamfer > 0) {
            rt = gear_tip_radius(teeth, mod, addendum);
            intersection() {
                linear_extrude(thickness) gear_2d(teeth, mod, pa, backlash, addendum, dedendum, tip_round, steps);
                // double cone limits the tips near the faces
                union() {
                    cylinder(h = chamfer, r1 = rt - chamfer, r2 = rt + 0.01, $fn = 96);
                    translate([0, 0, chamfer - 0.001]) cylinder(h = thickness - 2 * chamfer + 0.002, r = rt + 1, $fn = 96);
                    translate([0, 0, thickness - chamfer]) cylinder(h = chamfer, r1 = rt + 0.01, r2 = rt - chamfer, $fn = 96);
                }
            }
        } else {
            linear_extrude(thickness) gear_2d(teeth, mod, pa, backlash, addendum, dedendum, tip_round, steps);
        }
        if (bore > 0)
            translate([0, 0, -1]) cylinder(h = thickness + 2, d = bore, $fn = 64);
    }
}

// Quick visual test when opened directly.
if ($preview && is_undef(INVOLUTE_GEAR_NO_DEMO)) {
    spur_gear(36, 1.0, 4, bore = 6.4, chamfer = 0.4);
    translate([gear_centre_distance(36, 12, 1.0), 0, 0]) rotate(180 / 12)
        spur_gear(12, 1.0, 4, bore = 3);
}
