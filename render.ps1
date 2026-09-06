# render.ps1 - export all parts to STL with the OpenSCAD command line.
# Usage:  pwsh ./render.ps1              (all parts)
#         pwsh ./render.ps1 cam gear     (selected parts)
# Requires OpenSCAD (official download: https://openscad.org/downloads.html)
# on PATH or in the default install folder.
param([string[]]$Parts = @("cam", "gear", "washer", "follower", "rim_modifier"))

$found = Get-Command openscad -ErrorAction SilentlyContinue
$candidates = @()
if ($found) { $candidates += $found.Source }
$candidates += "$env:ProgramFiles\OpenSCAD\openscad.exe"
$candidates += "$env:ProgramFiles\OpenSCAD (Nightly)\openscad.exe"
$candidates += "$env:LOCALAPPDATA\Programs\OpenSCAD\openscad.exe"
$openscad = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $openscad) {
    Write-Error "openscad.exe not found. Install from https://openscad.org/downloads.html"
    exit 1
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
New-Item -ItemType Directory -Force (Join-Path $root "stl") | Out-Null
foreach ($p in $Parts) {
    $out = Join-Path $root "stl\dominator_$p.stl"
    Write-Host "Rendering $p -> $out"
    $define = 'part="' + $p + '"'
    & $openscad -o $out -D $define (Join-Path $root "scad\assembly.scad")
}
