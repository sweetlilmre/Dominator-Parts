# Measurement guide

Open the four annotated photos in this folder. Each lettered callout is one value in `scad/config.scad`. Measure with calipers on your worn part and write the numbers next to the letter below, then copy them into the config.

## 1_cam_top_view.png

| Letter | Parameter | What to measure | Value |
|---|---|---|---|
| A | `cam_od` | Diameter of the base circle (orange), rim outside face to outside face where there is no bump | |
| C | `cam_ear_out` | How far a bump sticks out past the base circle | |
| D | `hub_d` | Diameter of the centre boss the gear sits on | |
| E | `shaft_d` | Bore diameter (or the steel shaft, whichever you can measure cleanly) | |
| F | `cam_tray_inner_d` | Diameter of the raised centre plateau (the inner groove ring) | |
| 1 to 5 | `cam_bumps` | Start and end angle of each bump (green). Traced from your straight-down photo: 15-65, 90-133, 168.5-209.5, 230-279.5, 305-354.5 degrees. Already in config. | done |

The sheet is now built from your own photo (`reference/own_cam_top.jpg`), scaled by your 71 mm rim reading. The trace gives a bump height of 3.9 mm against your 4, and a bore of 6.2 mm. Items B, D and F from the earlier sheet are gone with the flat style.

## 5_bump_edge_lean.png

Zoom on bump 2 with radial reference lines. The edge faces are straight but not radial: seen from above with 0 degrees to the right, the clockwise edge of each bump (its start angle) leans about 21 degrees toward the middle of the bump as it goes outward, and the counter-clockwise edge (end angle) leans about 9 degrees the same way. All five bumps agree within a degree. These are `cam_lean_start` and `cam_lean_end` in the config; the `cam_bumps` angles are taken at mid-height so the lean pivots about that point.

The photo turned out to be of the non-gear side: held gear side up, the owner sees the steep face on the counter-clockwise side. The model therefore mirrors the whole traced outline (`cam_mirror = true`), which flips both the bump sequence and the leans together. The traced angles and leans in the config are still the photo's values.

## 2_cam_side_view.png

| Letter | Parameter | What to measure | Value |
|---|---|---|---|
| G | `gear_od` | Gear diameter tip to tip, take the biggest of a few readings | |
| H | `gear_thickness` | Gear face width (have 4.6) | done |
| I | `hub_h` | Shaft height, top of the OEM rim to the underside of the gear (have 10) | done |
| J | not used | Flat plate design: the rim height is covered by `cam_t` | |
| K | `cam_t` | Plate thickness: OEM rim bottom edge to rim top edge (have 6.6) | done |
| L | not used | No rim wall in the flat design | |
| M | (check) | Total height, rim bottom to gear top. Should equal K + I + H = 21.2 | |
| | `gear_teeth` | 36 counted | done |
| | `washer_t` | Gearbox wall to the underside of the OEM rim | |

## 3_follower_gear.png (only if you also print the cam gear kit gears)

| Letter | Parameter | What to measure | Value |
|---|---|---|---|
| N | `fg_ring_od` | Big gear diameter tip to tip | |
| O | `fg_pinion_od` | Small pinion diameter tip to tip | |
| P | `fg_plate_d` | Raised plate diameter | |
| Q | `fg_ring_thickness`, `fg_plate_h`, `fg_pinion_h` | Thickness of ring, plate and pinion, measured on the edge | |
| | `fg_ring_teeth`, `fg_pinion_teeth` | Count both (photo: 36 and 11 or 12) | |

## 4_cam_underside.png

Not needed any more: the flat design has a flat underside and a washer sets the spacing. Kept for reference only.

## Not in the photos but worth checking

- The direction the cam turns in the gearbox, and which face of each bump the pawl or follower rides against. That decides whether the bumps need a sharp edge on one side.
- Whether the gear is moulded as one piece with the cam (the model can do either).
