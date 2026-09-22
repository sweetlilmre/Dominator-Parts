# Continuation notes

State of the Dominator parts project as of 2026-09-22, written so a fresh session can resume with no other context. Read `CONTEXT.md` for vocabulary before touching anything; use its terms (lobe, trough, ramp face, drop face, hub, plug, socket, pin, follower, reduction gear, drive shaft, cam version).

## What this repo is

Parametric OpenSCAD replacements for wearing parts of a Kreepy Krauly Dominator pool cleaner gearbox. Owner: Peter. Remote: GitHub `sweetlilmre/Dominator-Parts`. Work is on branch `cam_alt_version`. Commit messages end with a `Co-authored-by` trailer.

Files: `scad/assembly.scad` is the entry point (Customizer `part` and `cam_version` selectors), `scad/config.scad` holds every parameter with a source tag, `scad/lib/involute_gear.scad` is a dependency-free involute gear library. `render.ps1` exports STLs, `render_previews.ps1` regenerates the PNGs in `renders/`. `PRINT_LOG.md` records each physical print. `SLICING.md` explains perimeters versus infill and the modifier meshes. `measure/v1/` and `measure/v2/` hold the annotated measurement sheets. `reference/cam_v1/` and `reference/cam_v2/` hold the owner's photographs, and are tracked.

OpenSCAD 2021.01 is at `C:\Program Files\OpenSCAD\openscad.com`. Use the `.com`, not the `.exe`: the `.exe` is the GUI build and detaches without rendering.

## The two cam versions

The cam is moulded with a number on both faces. The owner has one of each. They differ in exactly two parameters, both on the plate:

| | v1 | v2 |
|---|---|---|
| `lobe_height` | 4 | 5 |
| Lobe widths | 49.9, 41.1, 46.0, 49.9, 49.5 | 50, 43, 41, 49.5, 49.5 |
| Largest trough | 32.5 deg | 35.5 deg |
| Outer span | 79 mm | 81 mm |

Everything else reads the same: trough circle 71, plate 6.6, hub 22 x 14, gear 36 T at 47, bore for a 6.0 mm pin. Select with `cam_version`, or `-CamVersion` on the scripts. Only the cam STL carries a `_v1` / `_v2` suffix; the rim modifier is sized from the taller lobes so one file serves both.

The printed cam engraves its version digit 0.5 mm into both faces, as the OEM moulding carries it (`cam_version_number_*`).

## Current design state

- **Cam**: flat plate 6.6 thick, trough circle 71, five lobes at the traced angles above, ramp face lean 21, drop face lean 9, `cam_mirror = true`. Hub 22 dia, 14 high, with an 11 tooth socket 16 mm across.
- **Gear**: 36 teeth, 47 OD, 4.6 thick, backlash -0.2, dedendum 1.0, tip round 0.3, with a matching 11 T / 16 mm plug. Prints flat side down, plug up.
- **Spline joint**: 11 T, 16 mm tip to tip, `spline_clearance = 0.15`. Sized to match the reduction gear pinion so the project has one small tooth size, but kept as separate parameters so a change to one cannot silently alter the other.
- **Washer** 2 x 16. Pin 6.0, bore clearance 0.4, bore 6.4.
- **Reduction gear**: owns its ring dimensions (`rg_ring_*`, 36 T at 47, 4.6 thick) rather than borrowing the cam gear's. Pinion measured at 11 T / 16 mm.
- **Drive shafts**: unchanged since 2026-09-10.
- **Fit test coupon** (`part = "fit_test"`): sockets at several clearances with loose plugs, for finding the press fit without reprinting the real parts.

## Decisions worth not relitigating

- **The reduction gear ring is decoupled from the cam gear.** They are different parts. The earlier arrangement, where the ring read `gear_teeth` and `gear_thickness` directly, meant editing the cam gear reshaped the reduction gear silently.
- **The pinion module is checked, not shared.** The pinion must mesh with the cam gear, so `assembly.scad` echoes a warning if the two modules differ by more than 2 percent. The old 12 T / 14.4 mm estimate was 16.8 percent out and could never have meshed; that is what the check exists to catch.
- **The spline is not an OEM dimension.** Earlier revisions of the README claimed the printed pieces were joined the same way as the OEM kit. Nothing in the photographs supports that, and the mating faces are never visible in any of them. The plug, socket and every `spline_*` value are this project's own design. How the OEM assembly divides is unresolved.
- **Tolerance scheme.** `spline_clearance` is applied as `offset(delta = clearance)` on the socket profile, so it is the gap normal to every flank, root and tip, and it does not scale with tooth count or diameter. Changing the spline size does not require retuning the fit.

## Measurement method and its traps

Outlines are segmented from the owner's straight-down photographs, sampled as radius against angle about the centroid, and scaled by the cutting-mat grid anchored to the trough circle from the ruler photograph. Running the pipeline over the v2 photograph reproduces the v2 lobe widths already in the config to within 1.5 degrees, which is the accuracy to trust.

Two traps, both hit during this work:

- **Parallax.** A ruler resting on the part sits about 12 mm closer to the lens than the mat it lies on, magnifying it by roughly 4 percent at phone range. Scale from a feature in the same plane as the thing being measured.
- **EXIF rotation.** Some photographs carry an orientation flag; `reference/cam_v2/own_cam_top_v2.jpg` is flagged 180 degrees. Libraries that ignore it read the array unrotated, silently rotating every angle measured from it.

## Open questions

1. **`spline_clearance` disagreement.** The fit test coupon says 0.15 grips best. Print 1 used 0.15 at the older 12 T / 14 mm spline and reported play. The differences are the spline size, the slicer settings (print 1 was PETG, 0.2 mm, 2 perimeters, 15 percent infill; the coupon's are unrecorded) and the host geometry (a 47 mm gear and 71 mm cam then, small pucks now). Unresolved; check the real parts.
2. **`washer_t`** has never been measured on either version: gearbox wall to the underside of the cam.
3. **v1 is only partly measured.** `plate_t`, `hub_h`, `hub_d`, `gear_od`, `gear_thickness` and both edge leans are assumed the same as v2. The leans are the ones worth checking, since the lobe widths differ.
4. **Print 2 of the cam assembly** has still never been reported.
