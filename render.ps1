# render.ps1 - export all parts to STL with the OpenSCAD command line.
# Usage:  ./render.ps1                       (all parts, cam version v1)
#         ./render.ps1 cam gear              (selected parts)
#         ./render.ps1 -CamVersion v2        (the other cam moulding)
# Requires OpenSCAD (official download: https://openscad.org/downloads.html)
# on PATH or in the default install folder.
param(
    # ValueFromRemainingArguments so several part names can be given
    # positionally. Without it PowerShell gives the second name to the next
    # positional parameter, and the extra parts are silently dropped.
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Parts = @("cam", "gear", "washer", "reduction_gear", "shaft_long", "shaft_short", "cam_rim_modifier", "gear_tooth_modifier", "gear_plug_modifier", "fit_test"),
    [ValidateSet("v1", "v2")][string]$CamVersion = "v1"
)

# Parts whose geometry depends on cam_version; their STLs carry the suffix.
# The rim modifier is deliberately not here: it is sized from the taller lobes
# so a single file covers both versions.
$versioned = @("cam")

# openscad.com is the console build: it blocks until the render finishes and
# writes its output to the console. openscad.exe is the GUI build, which
# detaches immediately and silently renders nothing, so it is the last resort.
$candidates = @()
$candidates += "$env:ProgramFiles\OpenSCAD\openscad.com"
$candidates += "$env:ProgramFiles\OpenSCAD (Nightly)\openscad.com"
$candidates += "$env:LOCALAPPDATA\Programs\OpenSCAD\openscad.com"
$found = Get-Command openscad -ErrorAction SilentlyContinue
if ($found) { $candidates += $found.Source }
$candidates += "$env:ProgramFiles\OpenSCAD\openscad.exe"
$candidates += "$env:ProgramFiles\OpenSCAD (Nightly)\openscad.exe"
$candidates += "$env:LOCALAPPDATA\Programs\OpenSCAD\openscad.exe"
$openscad = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $openscad) {
    Write-Error "openscad not found. Install from https://openscad.org/downloads.html"
    exit 1
}

# Builds a -D assignment of an OpenSCAD string, e.g. part="cam". Windows
# PowerShell 5.1 and pwsh before 7.3 pass arguments to native programs raw,
# so the quotes must be backslash-escaped to reach OpenSCAD. pwsh 7.3+
# (PSNativeCommandArgumentPassing = Windows or Standard) escapes them itself,
# and a pre-escaped \" arrives literally and breaks the parse.
function Format-ScadString([string]$name, [string]$value) {
    $legacy = -not (Test-Path variable:PSNativeCommandArgumentPassing) -or
        $PSNativeCommandArgumentPassing -eq "Legacy"
    if ($legacy) { return "$name=\`"$value\`"" }
    return "$name=`"$value`""
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
New-Item -ItemType Directory -Force (Join-Path $root "stl") | Out-Null
$failed = @()
foreach ($p in $Parts) {
    $name = if ($versioned -contains $p) { "dominator_${p}_$CamVersion" } else { "dominator_$p" }
    $out = Join-Path $root "stl\$name.stl"
    Write-Host "Rendering $p -> $out"
    # The inner quotes must survive PowerShell's native-argument handling, or
    # OpenSCAD sees an undefined variable, warns, and falls through to the
    # "all parts" branch - producing a wrong STL with no visible error.
    & $openscad -o $out -D (Format-ScadString "part" $p) -D (Format-ScadString "cam_version" $CamVersion) (Join-Path $root "scad\assembly.scad")
    if ($LASTEXITCODE -ne 0) { $failed += $p }
}
if ($failed.Count -gt 0) {
    Write-Error ("Failed: " + ($failed -join ", "))
    exit 1
}
