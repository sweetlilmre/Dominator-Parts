# Print log

One entry per physical print. Records the config values used, what was observed, and what changed for the next print. Settings not listed were at the defaults in `scad/config.scad` at that commit.

## Print 1, 2026-09-05

Reconstructed from the session history; the repo had no commits yet. This is the config as it stood when the print was reported, which was after the outline mirror and the pin measurement had gone in. If the print actually started earlier, the differences would be `cam_mirror = false`, `pin_d = 6.35` and `hub_d = 18`.

Design: flat cam plate with integral shaft and toothed pocket, separate gear with toothed boss, spacer washer.

| Parameter | Value |
|---|---|
| `pin_d` | 6.3 |
| `bore_clearance` | 0.4 (bore 6.7) |
| `cam_od` | 71 |
| `cam_t` | 6.6 |
| `cam_ear_out` | 4 |
| `cam_bumps` | [15, 65], [90, 133], [168.5, 209.5], [230, 279.5], [305, 354.5] |
| `cam_bump_rot` | 0 |
| `cam_mirror` | true |
| `cam_lean_start` / `cam_lean_end` | 21 / 9 |
| `cam_outline_round` | 0.6 |
| `hub_d` | 22 |
| `hub_h` | 14 |
| `spline_teeth` | 12 |
| `spline_od` | 14 |
| `spline_addendum` / `spline_dedendum` | 0.9 / 0.9 |
| `spline_boss_h` | 5 |
| `spline_pocket_extra` | 0.3 |
| `spline_clearance` | 0.15 |
| `spline_lead_in` | 0.6 |
| `gear_teeth` | 36 |
| `gear_od` | 47 (module 1.237) |
| `gear_thickness` | 4.6 |
| `gear_pressure_angle` | 20 |
| `gear_backlash` | 0.15 |
| tooth depth | standard, addendum 1.0, dedendum 1.25 (not yet parameters) |
| `gear_chamfer` | 0.4 |
| `gear_tip_round` | 0.15 |
| `washer_t` / `washer_od` | 2 / 16 |

Stack: washer 2 + plate 6.6 + shaft 14 + gear 4.6 = 27.2 mm wall to gear top.

Slicer settings (PrusaSlicer): PETG, 0.2 mm layers, 2 perimeters, 15 percent grid infill.

Observed:

- Overall fit and appearance good for a first attempt.
- Play between the gear's toothed boss and the shaft pocket.
- Gear teeth thinner than the original.

Changes made for print 2:

- `spline_clearance` 0.15 to 0.05.
- `gear_backlash` 0.15 to -0.2 (teeth about 0.35 mm fatter in total).
- `gear_dedendum` 1.25 to 1.0 (root diameter about 42 mm, stubbier teeth like the OEM).
- `gear_tip_round` 0.15 to 0.3.
- `gear_addendum` and `gear_dedendum` added as parameters.
- Tooth count briefly changed to 35 from a photo estimate, then reverted to 36 after counting.

## Rename, 2026-09-06

Parameters were renamed to match the glossary in `CONTEXT.md`. Shape verified identical before and after. Print 1 above uses the old names.

| Old | New |
|---|---|
| `cam_od` | `trough_d` |
| `cam_t` | `plate_t` |
| `cam_ear_out` | `lobe_height` |
| `cam_bumps` | `lobes` |
| `cam_bump_rot` | `lobe_rot` |
| `cam_lean_start` | `ramp_lean` |
| `cam_lean_end` | `drop_lean` |
| `cam_outline_round` | `plate_corner_round` |
| `spline_boss_h` | `plug_h` |
| `spline_pocket_extra` | `socket_extra` |

## Print 2

Not yet printed. Config as committed after print 1 feedback.
