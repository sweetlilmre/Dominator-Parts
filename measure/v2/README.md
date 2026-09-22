# Cam v2 measurements

The cam stamped **2** on both faces. Source photographs are in
`reference/cam_v2/`. This is the version the project was originally built
around, so most values in `config.scad` came from here.

## 1_cam_top_view_v2.png

Traced from `reference/cam_v2/own_cam_top_v2.jpg`, scaled by the owner's 71 mm
rim reading.

| Letter | Parameter | What it is | Value |
|---|---|---|---|
| A | `trough_d` | Diameter of the trough circle, rim outside face to outside face where there is no lobe | 71, owner's calipers |
| C | `lobe_height` | How far a lobe stands out past the trough circle | 5, trace 4.5 |
| E | `pin_d` | Bore, or the steel pin if you can measure it cleanly | photo reads 6.2, pin set 6.0 |
| 1 to 5 | `v2_lobes` | Start and end angle of each lobe, at mid-height | done, see below |

The callout letters on the image predate the `CONTEXT.md` glossary and still
read `cam_od`, `cam_ear_out`, `shaft_d` and `cam_bumps`. Those are now
`trough_d`, `lobe_height`, `pin_d` and `lobes`. The image has not been
regenerated.

Lobe angles, counter-clockwise, 0 degrees to the right:

| Lobe | Start | End | Width | Trough after it |
|---|---|---|---|---|
| 1 | 15 | 65 | 50 | 25 |
| 2 | 90 | 133 | 43 | 35.5 |
| 3 | 168.5 | 209.5 | 41 | 20.5 |
| 4 | 230 | 279.5 | 49.5 | 25.5 |
| 5 | 305 | 354.5 | 49.5 | 20.5 |

Re-tracing this photograph with the v1 pipeline reproduces these widths to
within 1.5 degrees, which is what sets the confidence in both versions.

The photograph is of the cam side, so the model mirrors the outline
(`cam_mirror = true`). Confirmed against the gear-side photograph
`reference/cam_v2/own_gear_side_v2.jpg`, which shows the ramp face on the
counter-clockwise edge and the mirrored trough sequence.

## 5_lobe_edge_lean_v2.png

Zoom on lobe 2 with radial reference lines. The edge faces are straight but not
radial: seen from the cam side with 0 degrees to the right, the clockwise edge
of each lobe leans about 21 degrees toward the middle of the lobe as it goes
outward, and the counter-clockwise edge about 9 degrees the same way. All five
lobes agree within a degree. These are `ramp_lean` and `drop_lean`; the `lobes`
angles are taken at mid-height so the lean pivots about that point.

## 7_top_lobe_faces_v2.png

The lobe faces seen from above, used to confirm which face is the ramp and
which the drop.

## Gear

From `reference/cam_v2/own_gear_side_v2.jpg`:

| Parameter | Value | How |
|---|---|---|
| `gear_teeth` | 36 | counted by the owner |
| `gear_od` | 47 | calipers |
| `gear_thickness` | 4.6 | calipers |
| `gear_backlash` | -0.2 | teeth read about 0.1 of the pitch wider than a textbook involute at every depth, allowing for photo bloom |
| `gear_dedendum` | 1.0 | working depth about 2.4 mm against 2.78 for a standard 1.25 dedendum |

## Still to measure

| Parameter | Note |
|---|---|
| `washer_t` | Gearbox wall to the underside of the cam. Never measured. |
| Stack check | `washer_t` + `plate_t` + `hub_h` + `gear_thickness` should equal the wall-to-gear-top distance. The console echo prints the total. |
