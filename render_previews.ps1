# render_previews.ps1 - regenerate the PNG previews in renders/.
# Usage:  ./render_previews.ps1              (every preview, both cam versions)
#         ./render_previews.ps1 cam_iso      (selected views)
#
# The previews used to be made by hand, which is how they came to disagree with
# the model. Everything here is derived: the framing comes from --viewall, so a
# view stays correct when the geometry changes underneath it.
param([Parameter(Position = 0, ValueFromRemainingArguments = $true)][string[]]$Views = @())

$scheme = "Tomorrow"           # background #f8f8f8, matching the original set
$iso    = "0,0,0,55,0,25,0"    # gimbal: translate, rotate, distance (0 = viewall)
$top    = "0,0,0,0,0,0,0"

# name = part, camera, size, versioned, extra args
$all = @(
    @{ name="cam_iso";            part="cam";            cam=$iso; size="1400,1050"; ver=$true  },
    @{ name="cam_top";            part="cam";            cam=$top; size="1400,1050"; ver=$true  },
    @{ name="assembly";           part="assembly";       cam=$iso; size="1400,1050"; ver=$true  },
    @{ name="all_parts";          part="all";            cam=$iso; size="1400,1050"; ver=$true  },
    @{ name="gear_iso";           part="gear";           cam=$iso; size="1400,1050"; ver=$false },
    @{ name="gear_top";           part="gear";           cam=$top; size="1400,1050"; ver=$false },
    @{ name="reduction_gear_iso"; part="reduction_gear"; cam=$iso; size="1400,1050"; ver=$false },
    @{ name="fit_test";           part="fit_test";       cam=$iso; size="1400,900";  ver=$false },
    # Close-up on the socket in the top of the hub. Fixed camera, not viewall:
    # the point is the joint, not the whole part.
    @{ name="spline_closeup";     part="cam";            cam="0,0,16,72,0,25,72"; size="1400,1050"; ver=$false; noviewall=$true }
)

$candidates = @(
    "$env:ProgramFiles\OpenSCAD\openscad.com",
    "$env:ProgramFiles\OpenSCAD (Nightly)\openscad.com",
    "$env:LOCALAPPDATA\Programs\OpenSCAD\openscad.com"
)
$openscad = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $openscad) {
    Write-Error "openscad.com not found. Install from https://openscad.org/downloads.html"
    exit 1
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$scad = Join-Path $root "scad\assembly.scad"
New-Item -ItemType Directory -Force (Join-Path $root "renders") | Out-Null

$todo = if ($Views.Count -gt 0) { $all | Where-Object { $Views -contains $_.name } } else { $all }
foreach ($v in $todo) {
    $versions = if ($v.ver) { @("v1", "v2") } else { @("v1") }
    foreach ($cv in $versions) {
        $name = if ($v.ver) { "$($v.name)_$cv" } else { $v.name }
        $out = Join-Path $root "renders\$name.png"
        Write-Host "Rendering $name"
        # $args is an automatic variable in PowerShell; do not assign to it.
        $oargs = @("-o", $out, "--imgsize=$($v.size)", "--colorscheme=$scheme", "--camera=$($v.cam)")
        if (-not $v.noviewall) { $oargs += @("--viewall", "--autocenter") }
        $oargs += @("-D", "part=\`"$($v.part)\`"", "-D", "cam_version=\`"$cv\`"", $scad)
        & $openscad @oargs 2>&1 | Where-Object { $_ -match "ERROR|WARNING" }
    }
}
