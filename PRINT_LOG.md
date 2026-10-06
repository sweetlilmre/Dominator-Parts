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

## Print 2, 2026-09-28

Cam v2 and gear. Meant to test `spline_clearance = 0.05` on the owner's printer, but the cam was sliced from `stl/dominator_cam_v2.stl` before it was re-exported in 9c4f0b4, so it is the export from 120f812 with the socket cut at 0.15. The gear is from 5ddb780; its plug is nominal and does not depend on the clearance. So this print tests 0.15 on the owner's printer at the current spline (11 teeth, 16 mm tip to tip), and checks tooth solidity.

| Parameter | Value |
|---|---|
| `cam_version` | v2 (lobe height 5) |
| `pin_d` / `bore_clearance` | 6.00 / 0.4 (bore 6.4) |
| `spline_teeth` / `spline_od` | 11 / 16 |
| `spline_clearance` | 0.15 in the printed socket (config at the time said 0.05) |

Slicer settings: Prusa MK4, PETG, 6 perimeters.

Observed:

- The spline joint failed at 0.15.

Followed up with a fit test coupon on the owner's printer, below.

## Spline fit test coupon, owner's printer, after print 2

`part = "fit_test"` at the current spline (11 teeth, 16 mm tip to tip), sockets at `spline_clearance` 0, 0.05, 0.10 and 0.15 with loose plugs at nominal. Printed on the owner's Prusa MK4 after print 2 failed at 0.15.

Observed:

- **0.05 works** on the owner's printer.

Changes made: none; `spline_clearance` was already 0.05. The coupon cuts its sockets with the same `socket_cut` module as the cam, so it is taken as enough evidence without a 0.05 cam print. The cam and gear at 0.05 have not been printed yet.

This settles the open question in the contributor's coupon entry below: the owner's printer wants 0.05 and the contributor's printer 0.15, so the difference is the printer, not the spline size or the part geometry.

## Spline fit test coupon, 2026-09-22

`part = "fit_test"`, printed at the spline as it now stands: 11 teeth, 16 mm
tip to tip, `spline_addendum` / `spline_dedendum` 0.9. Four sockets at
`spline_clearance` 0, 0.05, 0.10 and 0.15 with loose plugs at nominal.

Printed on a contributor's printer, not the owner's; settings not recorded.

Observed:

- **0.15 is the best fit** on that printer.

Changes made:

- `spline_clearance` 0.05 to 0.15, later reverted to 0.05 for the owner's printer (see print 2).

Open question: print 1 used 0.15 and was reported as having play. The two
disagree. The differences between them are the spline size (12 T / 14 mm then,
11 T / 16 mm now), the printer settings (print 1 was PETG, 0.2 mm layers, 2
perimeters, 15 percent infill; the coupon's settings are not recorded), and the
part geometry the joint was printed as part of (a 47 mm gear and a 71 mm cam
then, small pucks now). Which of those accounts for it is not known. The real
parts should be printed and checked before the 0.15 is trusted for good.

Resolved: the owner's coupon after print 2 found 0.05 best on the owner's printer, so the two results reflect different printers.

## Slicing note

How to make the contact regions solid without a fully solid part is written up in `SLICING.md`: Fill density 100 percent on the modifier meshes, a modest perimeter count on the object itself.

## Long drive shaft, print 1, 2026-09-10

Config as committed in 2283e47: two halves split through tooth centres, gear OD 12.45, root fillets 2, body relieved to 10 mm, single row of axis dowel holes at 4, 10, 20, 35, 60, 90, 120, 131, 145, 160, 173.

Assembly: dowels of 1.75 mm filament, halves glued with PVC pipe cement.

Observed:

- Dowels align the halves very well.
- Joint is solid; the finished shaft is strong and somewhat flexible.
- Not yet tested in the cleaner.

Slicer settings: not recorded, add if known.

No config changes.

## Drive gear 1, print 1, 2026-10-06

`part = "drive_gear_1"` as committed: a 26 tooth gear 10 mm wide with a 19
tooth gear 11 mm wide above it, tip diameters 35 and 26.25 mm, module 1.25,
total 21 mm, bore 6.4 mm, solid body. Printed with the 26 tooth gear on the
bed, no supports. Slicer settings not recorded; add them if known.

Observed:

- Correct. The gear meshes and the dimensions are right.

This confirms three things that were derived rather than measured. The module
of 1.25, taken from the 26 tooth gear because 26 is even and a caliper can span
tip to tip. The 19 tooth tip diameter of 26.25, calculated from that module
against a caliper reading of 25 to 26, which read low because 19 is odd. And
the bore, which is `bore_d` and therefore the same hole as the cam: the drive
gears run on the same pin.

The two face widths are the owner's corrected values, 10 mm for the 26 tooth
gear and 11 mm for the 19 tooth gear. They were briefly entered the other way
round.

No config changes.

