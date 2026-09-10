# Continuation notes

State of the Dominator parts project as of 2026-09-10, written so a fresh session can resume with no other context. Read `CONTEXT.md` for vocabulary before touching anything; use its terms (lobe, trough, ramp face, drop face, hub, plug, socket, pin, follower, reduction gear, drive shaft).

## What this repo is

Parametric OpenSCAD replacements for wearing parts of a Kreepy Krauly Dominator pool cleaner gearbox. Owner: Peter (the user). Remote: private GitHub repo `sweetlilmre/Dominator-Parts`, branch `main`. Every design revision is committed on its own and pushed. Commit messages end with `Co-authored-by: Claude <noreply@anthropic.com>`.

Files: `scad/assembly.scad` is the entry point (Customizer `part` selector), `scad/config.scad` holds every parameter with a source tag, `scad/lib/involute_gear.scad` is a dependency-free involute gear library. `render.ps1` exports all parts to `stl/`. `renders/` has previews. `PRINT_LOG.md` records each physical print. `SLICING.md` explains perimeters versus infill and the PrusaSlicer modifier meshes. `measure/` has annotated photos of the owner's parts. `reference/own_*.jpg` are the owner's photos and are tracked.

OpenSCAD 2021.01 is at `C:\Program Files\OpenSCAD\openscad.com`. Python tooling for STL analysis (trimesh, shapely, scipy, pillow) lives in a uv venv in the session scratchpad; recreate with `uv venv` and `uv pip install trimesh shapely scipy pillow rtree networkx` if needed.

## Committed and pushed (HEAD 34292b5)

Cam assembly, finished design pending print 2 feedback:

- Cam: flat plate 6.6 thick, trough circle 71, five lobes 5 mm high with traced angles [15-65, 90-133, 168.5-209.5, 230-279.5, 305-354.5] at mid-height, ramp face lean 21, drop face lean 9, `cam_mirror = true` (trace photo was of the cam side; confirmed against a gear-side photo). Hub 22 dia, 14 high, with a 12 tooth involute socket 14 mm across.
- Gear: 36 teeth, 47 OD, 4.6 thick, backlash -0.2 (fatter teeth like the OEM), dedendum 1.0 (stubbier), tip round 0.3, with a plug that fits the socket, clearance 0.05. Prints flat side down, plug up.
- Washer 2 x 16. Pin 6.3, bore clearance 0.4.
- Reduction gear (optional, unmeasured pinion): ring identical to the gear plus a 12 T pinion.
- Slicer modifiers as OpenSCAD parts: cam rim band, gear tooth band, gear plug. Fill density 100 percent goes on the modifier, perimeters on the object (a perimeter override on a modifier draws perimeters at the modifier boundary).
- Print 1 (PETG, 0.2 layers, 2 perimeters, 15 percent grid): spline had play, gear teeth thin. Fixes above are in config. Print 2 not yet reported.
- Rotation direction observed: counter-clockwise from the gear side; the ramp face meets the follower first.

## Drive shafts (committed 2026-09-10, print feedback pending)

Two gearbox drive shafts, long (177) and short (83), in `scad/drive_shaft.scad` with presets `ds_long` and `ds_short` in `config.scad`, parts `shaft_long` / `shaft_short` in assembly and `render.ps1`, STLs in `stl/`, renders in `renders/`, plus README and CONTEXT entries. Committed at the user's request on 2026-09-10 before a test print; expect changes after print feedback.

Design, agreed with the user so far:

- 8 tooth involute pinion profile running the full length, gear OD 12.45 (owner caliper 12.4-12.5), body 12.5.
- Long: gear 0-12, body 12-127 with an arc groove (the "dip") centred at 45, width 10, depth 2.075, arc radius 10.3; gear 127-177. The smooth body is relieved to 10 mm over 16-123 (`ds_relief_d`, `relief` list), including across the dip; only 4 mm seats at each gear stay at full diameter. Collars either side of the dip were removed on request.
- Short: gear 0-18, lobed 18-28 (tooth roots filled to 9.7), body 28-46, lobed 46-58, gear 58-83. No relief.
- 2 mm cone fillets where each body section meets a gear (`ds_step_fillet`), because a vertical print snapped exactly at that step.
- Printed as two identical lengthwise halves lying flat (`ds_split = true`), split plane through two opposite tooth centres (`ds_split_at = "teeth"`) so no tooth overhangs near the bed. "gaps" mode exists but overhanging teeth did not print.
- No steel rod channel (`ds_rod_d = 0`, option kept). Alignment by a single row of dowel holes on the axis, 1.75 filament + 0.25 clearance, 2.5 deep, at explicit positions in each preset's `dowels` list, including inside the gear sections: long [4, 10, 20, 35, 60, 90, 120, 131, 145, 160, 173], short [4, 19, 34, 49, 64, 79] (reduced from 8 to 6 on request, even 15 mm spacing). Verified none break through.
- Both halves glue together (CA or epoxy).

The previous solid version is backed up in `backup/drive_shaft_v1/` (untracked, excluded locally).

Next steps for the shafts: user prints a test half, reports fit of the half teeth on the bed and the dowels; then add a shaft section to README and SLICING, a print log entry, and commit as one revision, then push.

## Standing rules from the user

- Commit each revision separately so it can be reverted; push after committing.
- Never commit images downloaded from the internet. The owner's own photos are fine.
- Do not describe where the shaft geometry was derived from in any tracked file or commit message. Local working folders (`backup/` and one other) are excluded via `.git/info/exclude`, not `.gitignore`.
- Ask before changing the shaft design further; the user wants to discuss changes first.
- Keep all terminal output filtered to printable ASCII (`| tr -cd '\11\12\15\40-\176'`); binary in tool output breaks the session on this network. Never cat PDFs, images or STLs.
- Use glossary terms in code, comments and docs.

## Open items

- `washer_t`: gearbox wall to the underside of the OEM rim, not yet measured.
- Stack check: washer + plate + hub + gear = 2 + 6.6 + 14 + 4.6 = 27.2 should equal OEM wall to gear top.
- Print 2 of the cam and gear: outcome not yet reported.
- Reduction gear pinion size unmeasured; only matters if those gears are printed.
- Whether the dip on the long shaft needs its original depth (something may clip into it); currently 0.8 mm deep on the relieved body.
