# Kreepy Krauly Dominator cam and gear, parametric OpenSCAD replacement

A 3D printable replacement for the Dominator steering cam (Pool Mecca SKU 8880219510109; the Pentair Rebel/Warrior equivalent is cam kit 360294). Every dimension lives in `scad/config.scad` and can be tuned from the OpenSCAD Customizer.

The design is two printed pieces plus a washer, joined the same way as the OEM kit, where the gear carries a small toothed boss that plugs into the cam's hub:

- **cam**: a flat plate with the five-bump outline and an integral shaft rising from its centre, with a toothed pocket in the top of the shaft.
- **gear**: the 36 tooth ring gear with a matching toothed boss on its underside. The boss plugs into the pocket and the gear seats on the shaft shoulder, so the teeth only carry torque. Being separate, the wear item can be reprinted alone or in a tougher material.
- **washer**: a spacer between the gearbox wall and the cam underside to set the axial position.

The steel pin runs through the bore of all of them.

## Files

| Path | What it is |
|---|---|
| `scad/assembly.scad` | Open this. Pick `part` in the Customizer, tune values, export STL. |
| `scad/config.scad` | All parameters, each tagged with where its value came from. |
| `scad/cam.scad` | Cam plate, bump outline with leaning edges, shaft with toothed pocket, washer. |
| `scad/cam_gear.scad` | Ring gear with the toothed boss. |
| `scad/follower_gear.scad` | Optional: the compound gear from the cam gear kit (36 T ring + 12 T pinion). |
| `scad/lib/involute_gear.scad` | Self contained involute spur gear library, no external dependencies. |
| `render.ps1` | Exports every part to `stl/` using the OpenSCAD command line. |
| `PRINT_LOG.md` | One entry per physical print: config used, what was observed, what changed. |
| `renders/` | PNG previews of the current model. |
| `measure/` | Annotated photos with lettered callouts plus a fill-in table of what to measure. |
| `stl/` | Exported STLs with the current config values. |
| `reference/` | Product photos, the owner's photos, and the Thingiverse remake used for research. |

## Where the numbers come from

| Item | Value | Source |
|---|---|---|
| Rim base diameter | 71 mm | owner's calipers |
| Plate thickness | 6.6 mm | owner's calipers |
| Bump height | 4 mm (trace 3.9) | owner's calipers, photo trace |
| Bump angles | 15-65, 90-133, 168.5-209.5, 230-279.5, 305-354.5 deg | traced from `reference/own_cam_top.jpg` |
| Bump edge lean | 21 deg on one edge, 9 deg on the other, both toward the bump middle | line fit per edge on the same photo |
| Outline mirrored | `cam_mirror = true` | the trace photo was of the non-gear side; confirmed by tracing the gear-side photo `reference/own_gear_side.jpg`, which shows the steep face on the counter-clockwise edge and the mirrored gap sequence |
| Gear | 36 T, 47 mm OD, 4.6 mm thick | owner's count and calipers |
| Gear tooth thickness | about 0.1 of pitch wider than a textbook involute at every depth, so `gear_backlash = -0.2` | `reference/own_gear_side.jpg`, tooth fraction vs radius |
| Gear tooth depth | about 2.4 mm working depth, stubbier than standard, so `gear_dedendum = 1.0` | same photo |
| Shaft height, plate top to gear underside | 14 mm | owner |
| Shaft OD | 22 mm | owner |
| Pin | 6.3 mm, OEM bore measured 6.3 | owner |
| Spline size, washer | 14, 2 mm | estimates, not critical to fit |

## First print feedback (2026-09-05)

- Spline joint had play: `spline_clearance` reduced from 0.15 to 0.05. Next step if still loose is 0 or slightly negative.
- Gear teeth thinner than the original: from the gear-side photo the OEM teeth are wider and shorter than a textbook involute. `gear_backlash` is now -0.2, `gear_dedendum` 1.0, and tip rounding is increased. Tooth count confirmed at 36 by the owner; a photo-based pitch estimate of 35 was wrong.

## Still to confirm

1. `washer_t`: gearbox wall to the underside of the OEM rim.
2. Stack check: washer plus plate plus shaft plus gear thickness should equal the OEM distance from wall to gear top. The console echo prints the total.
3. After mirroring, the steep 21 degree face should be on the counter-clockwise side of each bump when the part is held gear side up with 0 degrees to your right. If your part differs, set `cam_mirror = false` and swap the two lean values instead.

## Tuning

- `gear_backlash` 0.1 to 0.2 mm for FDM. Increase if the mesh binds, decrease if it rattles.
- `spline_clearance` 0.1 for a press fit, 0.2 for an easy slide you can glue.
- `spline_boss_h` sets how deep the boss engages in the shaft; the pocket is `spline_pocket_extra` deeper so the gear seats on the shoulder.
- `bore_clearance` 0.3 to 0.5 mm depending on how well your printer holds small holes.
- `cam_lean_start` and `cam_lean_end` set to 0 give square radial bump edges.

## Printing

- Cam: plate down, shaft up, no supports. 100 percent infill or at least 4 walls. Slow the outer wall for the bump faces.
- Gear: gear face down, boss up, as exported. No supports. 100 percent infill, 0.12 to 0.2 mm layers, 0.4 mm nozzle.
- Washer: flat.
- Material: PETG, ASA or nylon. PLA goes soft in a hot pool box.

## Rendering from the command line

```powershell
pwsh .\render.ps1                 # cam, gear, washer, follower to .\stl\
pwsh .\render.ps1 cam gear        # selected parts
```

## Sources

- Pool Mecca product page: https://poolmecca.co.za/product/pool-cleaner-kreepy-krauly-dominator-cam/
- Amazon 360294 cam kit listing (Pentair Rebel / Kreepy Krauly Warrior): https://www.amazon.com/dp/B0GXPCLR29
- ePoolSupply cam gear kit 360295 photos: https://www.epoolsupply.com/products/pentair-kreepy-krauly-warrior-rebel-cam-gear-kit
- Thingiverse remake, CC BY, just-sean: https://www.thingiverse.com/thing:6097557
- Pool Zoom Rebel parts diagram: https://www.poolzoom.com/diagram/rebel-pool-cleaner-parts.html
