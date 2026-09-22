# Measurement guide

The cam is moulded with a version number on both faces. The owner has one of
each, and the two differ, so the measurement sheets are kept apart:

| Folder | Part |
|---|---|
| [`v1/`](v1/) | the cam stamped 1 |
| [`v2/`](v2/) | the cam stamped 2 |

Each folder holds annotated photos with lettered callouts and a README listing
what each letter means and what is still to be measured. Every callout names a
parameter in `scad/config.scad` using the vocabulary in `CONTEXT.md`.

## What differs between the versions

Only two parameters, both on the cam plate:

| | v1 | v2 |
|---|---|---|
| `lobe_height` | 4 mm | 5 mm |
| `lobes` | 20.2-70.1, 90.4-131.5, 164-210, 235-284.9, 305.5-355 | 15-65, 90-133, 168.5-209.5, 230-279.5, 305-354.5 |

Everything else measured so far reads the same on both: trough circle 71 mm,
plate 6.6 mm, hub 22 x 14 mm, gear 36 T at 47 mm, bore for a 6.0 mm pin.

## How the traces were made

The outline is segmented from the owner's straight-down photograph, sampled as
a radius-versus-angle profile about the part's centroid, and scaled by the
cutting-mat grid anchored to the trough circle read off the ruler photograph.

Two cautions learned the hard way:

- **Parallax.** A ruler resting on the part sits about 12 mm closer to the lens
  than the mat it lies on, which magnifies it by roughly 4 percent at phone
  range. Scale from a feature in the same plane as the thing being measured.
- **EXIF rotation.** Some of the photographs carry an orientation flag. Image
  libraries that ignore it read the array unrotated, which silently rotates
  every angle measured from it.

Running this pipeline over the v2 photograph reproduces the v2 lobe widths
already in the config to within 1.5 degrees. That is the accuracy these traced
angles should be trusted to; anything finer needs calipers.
