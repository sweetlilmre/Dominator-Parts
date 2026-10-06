# Cam v1 measurements

The cam stamped **1** on both faces. Source photographs are in
`reference/cam_v1/`.

## 1_cam_top_view_v1.png

Traced from `reference/cam_v1/own_cam_top_v1.jpg`, scaled by the cutting-mat
grid and anchored to the 71.5 mm trough circle read off
`reference/cam_v1/own_cam_top_ruler_v1.jpg`.

| Letter | Parameter | What it is | Value |
|---|---|---|---|
| A | `trough_d` | Diameter of the trough circle, rim outside face to outside face where there is no lobe | 71.5 traced, config 71 |
| C | `lobe_height` | How far a lobe stands out past the trough circle | 4, trace 4.15 |
| E | `pin_d` | Bore, or the steel pin if you can measure it cleanly | bore 6.1-6.4, pin set 6.0 |
| 1 to 5 | `v1_lobes` | Start and end angle of each lobe, at mid-height | done, see below |

Lobe angles as traced, counter-clockwise, 0 degrees to the right:

| Lobe | Start | End | Width | Trough after it |
|---|---|---|---|---|
| 1 | 20.2 | 70.1 | 49.9 | 20.3 |
| 2 | 90.4 | 131.5 | 41.1 | 32.5 |
| 3 | 164 | 210 | 46.0 | 25.0 |
| 4 | 235 | 284.9 | 49.9 | 20.6 |
| 5 | 305.5 | 355 | 49.5 | 25.2 |

The photograph is of the cam side, not the gear side, so the model mirrors the
whole outline (`cam_mirror = true`), which flips the lobe order and the two
edge leans together.

## Against v2

| | v1 | v2 |
|---|---|---|
| Lobe 2 width | 41.1 | 43 |
| Lobe 3 width | 46.0 | 41 |
| Largest trough | 32.5 | 35.5 |
| `lobe_height` | 4 | 5 |
| Outer span across the crests | 79 | 81 |

Lobes 1, 4 and 5 are the same width on both within a degree.

## Still to measure on v1

Calipers needed; none of these can be read from the photographs to better than
the trace accuracy of about 1.5 degrees and half a millimetre.

| Parameter | Note |
|---|---|
| `plate_t` | Plate thickness. v2 reads 6.6. |
| `hub_h`, `hub_d` | Hub height and diameter. v2 reads 14 and 22. |
| `gear_od`, `gear_thickness` | The gear is a separate part; v2 reads 47 and 4.6, and the v1 photo trace agrees on the tooth count. |
| `washer_t` | Gearbox wall to the underside of the cam. Never measured on either version. |
| `ramp_lean`, `drop_lean` | Edge leans. Taken from the v2 trace (21 and 9 degrees) and assumed to carry over; not yet checked on v1. |

## Not in the photographs

- Whether the edge leans really are the same as v2. The lobe widths differ, so
  the faces may too.
- The direction the cam turns in the gearbox. Observed on v2 as
  counter-clockwise seen from the gear side, ramp face meeting the follower
  first; assumed the same for v1.
