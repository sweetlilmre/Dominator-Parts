# Kreepy Krauly Dominator cam and gear, parametric OpenSCAD replacement

A 3D printable replacement for the Dominator steering cam (Pool Mecca SKU 8880219510109; the Pentair Rebel/Warrior equivalent is cam kit 360294). Every dimension lives in `scad/config.scad` and can be tuned from the OpenSCAD Customizer.

The design is two printed pieces plus a washer, joined the same way as the OEM kit, where the gear carries a small plug that plugs into the cam's hub:

- **cam**: a flat plate with the five-lobe outline and an integral shaft rising from its centre, with a socket in the top of the hub.
- **gear**: the 36 tooth ring gear with a matching plug on its underside. The plug plugs into the socket and the gear seats on the hub shoulder, so the teeth only carry torque. Being separate, the wear item can be reprinted alone or in a tougher material.
- **washer**: a spacer between the gearbox wall and the cam underside to set the axial position.

The steel pin runs through the bore of all of them.

## Files

| Path | What it is |
|---|---|
| `scad/assembly.scad` | Open this. Pick `part` in the Customizer, tune values, export STL. |
| `scad/config.scad` | All parameters, each tagged with where its value came from. |
| `scad/cam.scad` | Cam plate, lobe outline with leaning edges, shaft with socket, washer. |
| `scad/cam_gear.scad` | Ring gear with the plug. |
| `scad/reduction_gear.scad` | Optional: a gearbox reduction gear, ring identical to the gear plus a 12 T pinion. Pinion unmeasured. |
| `scad/drive_shaft.scad` | The two gearbox drive shafts, long and short, as one parametric module. Presets `ds_long` and `ds_short` in the config. |
| `scad/lib/involute_gear.scad` | Self contained involute spur gear library, no external dependencies. |
| `render.ps1` | Exports every part to `stl/` using the OpenSCAD command line. |
| `PRINT_LOG.md` | One entry per physical print: config used, what was observed, what changed. |
| `SLICING.md` | How to slice in PrusaSlicer: where perimeters and infill go, and the modifier meshes. |
| `renders/` | PNG previews of the current model. |
| `measure/` | Annotated photos with lettered callouts plus a fill-in table of what to measure. |
| `stl/` | Exported STLs with the current config values. |
| `reference/` | Product photos, the owner's photos, and the Thingiverse remake used for research. |

## Where the numbers come from

| Item | Value | Source |
|---|---|---|
| Rim base diameter | 71 mm | owner's calipers |
| Plate thickness | 6.6 mm | owner's calipers |
| Lobe height | 4 mm (trace 3.9) | owner's calipers, photo trace |
| Lobe angles | 15-65, 90-133, 168.5-209.5, 230-279.5, 305-354.5 deg | traced from `reference/own_cam_top.jpg` |
| Lobe edge lean | 21 deg on one edge, 9 deg on the other, both toward the lobe middle | line fit per edge on the same photo |
| Outline mirrored | `cam_mirror = true` | the trace photo was of the non-gear side; confirmed by tracing the gear-side photo `reference/own_gear_side.jpg`, which shows the ramp face on the counter-clockwise edge and the mirrored gap sequence |
| Gear | 36 T, 47 mm OD, 4.6 mm thick | owner's count and calipers |
| Gear tooth thickness | about 0.1 of pitch wider than a textbook involute at every depth, so `gear_backlash = -0.2` | `reference/own_gear_side.jpg`, tooth fraction vs radius |
| Gear tooth depth | about 2.4 mm working depth, stubbier than standard, so `gear_dedendum = 1.0` | same photo |
| Hub height, plate top to gear underside | 14 mm | owner |
| Hub OD | 22 mm | owner |
| Pin | 6.3 mm, OEM bore measured 6.3 | owner |
| Spline size, washer | 14, 2 mm | estimates, not critical to fit |

## First print feedback (2026-09-05)

- Spline joint had play: `spline_clearance` reduced from 0.15 to 0.05. Next step if still loose is 0 or slightly negative.
- Gear teeth thinner than the original: from the gear-side photo the OEM teeth are wider and shorter than a textbook involute. `gear_backlash` is now -0.2, `gear_dedendum` 1.0, and tip rounding is increased. Tooth count confirmed at 36 by the owner; a photo-based pitch estimate of 35 was wrong.

## Drive shafts

`stl/dominator_shaft_long.stl` and `stl/dominator_shaft_short.stl` are the two gearbox drive shafts, each exported as two identical lengthwise halves lying flat, ready to print. Each shaft is an 8 tooth involute pinion running its full length, with round body sections unioned over it, and on the short shaft two sections where the tooth roots are filled to 9.7 mm. The long shaft has a shallow arc dip centred 45 mm from its short-gear end.

| | Long | Short |
|---|---|---|
| Length | 177 | 83 |
| Gear tip diameter, module | 12.45, 1.245 | 12.45, 1.245 |
| Gear lengths, A end / B end | 12 / 50 | 18 / 25 |
| Body diameter | 12.5, relieved to 10 between the gear seats | 12.5 |

Design choices, all parameters in the `[Drive shafts]` section of the config:

- **Printed in halves, flat.** A one-piece vertical print snapped where the gear meets the body, because the layer lines lay across the shaft there. The halves print with the flat face down so the layers run along the shaft. `ds_split = false` gives the one-piece version.
- **Split through tooth centres** (`ds_split_at = "teeth"`): each half has three whole teeth standing up and a half tooth lying flat on the bed at each side, so nothing overhangs. Splitting through the gaps left overhanging teeth that did not print.
- **Root fillets** (`ds_step_fillet = 2`): a 2 mm cone eases each body end into the tooth roots instead of a square step.
- **Dowel alignment**: a single row of holes on the axis, 2.5 mm deep, for pieces of 1.75 mm filament, at the positions in each shaft's `dowels` list, including inside the gear sections so the teeth of the two halves register. An optional steel rod channel (`ds_rod_d`) exists but is off.
- **Body relief** (`ds_relief_d = 10`, `relief` list): the long shaft's smooth body is turned down between 4 mm seats at each gear to save print time. The dip is cut into the relieved body and is 0.8 mm deep there.

Assembly: dry fit the halves with the dowels, then glue with CA or a thin layer of epoxy and clamp along the length. Print each half with 3 perimeters and 100 percent infill; they are small enough that a modifier is not worth the effort.

## Still to confirm

1. `washer_t`: gearbox wall to the underside of the OEM rim.
2. Stack check: washer plus plate plus shaft plus gear thickness should equal the OEM distance from wall to gear top. The console echo prints the total.
3. After mirroring, the ramp face should be on the counter-clockwise side of each lobe when the part is held gear side up with 0 degrees to your right. If your part differs, set `cam_mirror = false` and swap the two lean values instead.

## Tuning

- `gear_backlash` 0.1 to 0.2 mm for FDM. Increase if the mesh binds, decrease if it rattles.
- `spline_clearance` 0.1 for a press fit, 0.2 for an easy slide you can glue.
- `plug_h` sets how deep the plug engages in the hub; the socket is `socket_extra` deeper so the gear seats on the shoulder.
- `bore_clearance` 0.3 to 0.5 mm depending on how well your printer holds small holes.
- `ramp_lean` and `drop_lean` set to 0 give square radial lobe edges.

## Printing

- Cam: plate down, hub up, no supports. Set Perimeters = 3 on the object and load `stl/dominator_cam_rim_modifier.stl` as a modifier with only Fill density = 100 percent, so the lobes and troughs are solid. Full reasoning and steps in `SLICING.md`.
- Gear: flat side down, plug up, as exported. No supports. Perimeters = 3 on the object; load `stl/dominator_gear_tooth_modifier.stl` and `stl/dominator_gear_plug_modifier.stl` as modifiers with Fill density = 100 percent. 0.12 to 0.2 mm layers, 0.4 mm nozzle. See `SLICING.md`.
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
