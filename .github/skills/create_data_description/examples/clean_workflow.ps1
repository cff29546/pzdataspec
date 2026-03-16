param(
    [ValidateSet("build", "generated", "all")]
    [string]$Mode = "build"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

$ExampleDirs = Get-ChildItem -Path $Root -Directory |
    Where-Object { $_.Name -match '^[0-9]{2}_' }

function Remove-IfExists {
    param([string]$Path)
    if (Test-Path $Path) {
        Remove-Item -Path $Path -Recurse -Force
        Write-Host "Removed: $Path"
    }
}

foreach ($dir in $ExampleDirs) {
    $inputDir = Join-Path $dir.FullName "input"
    $outputDir = Join-Path $dir.FullName "output"

    if ($Mode -eq "build" -or $Mode -eq "all") {
        Get-ChildItem -Path $inputDir -Filter "*.class" -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-IfExists $_.FullName
        }
        Remove-IfExists (Join-Path $inputDir "example_gen.exe")
        Remove-IfExists (Join-Path $inputDir "bin")
        Remove-IfExists (Join-Path $inputDir "obj")
    }

    if ($Mode -eq "generated" -or $Mode -eq "all") {
        Remove-IfExists (Join-Path $outputDir "lib")
        Get-ChildItem -Path $outputDir -Filter "*.bin" -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-IfExists $_.FullName
        }
        Remove-IfExists (Join-Path $outputDir "parsed.txt")
    }
}

Write-Host "Cleanup complete. Mode=$Mode"
