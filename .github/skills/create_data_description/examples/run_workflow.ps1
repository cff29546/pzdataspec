param(
    [string]$Example = "all"
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $Root "..\..\..\..")).Path
$UnifiedParser = Join-Path $RepoRoot "data_spec\scripts\parse.py"

$Examples = @(
    @{
        Name = "01_variable_conditional_bitmap"
        Lang = "java"
        SourceFile = "DictionaryData.java"
        MainClass = "DictionaryData"
        BinaryOut = "dictionary_data.bin"
        Ksy = "dictionary_data.ksy"
        Module = "dictionary_data"
        Params = ""
    },
    @{
        Name = "02_dynamic_abstract_dispatch"
        Lang = "csharp"
        SourceFile = "EntityComponentSerializer.cs"
        MainClass = "Program"
        BinaryOut = "entity_component.bin"
        Ksy = "entity_component.ksy"
        Module = "entity_component"
        Params = ""
    },
    @{
        Name = "03_substructure_with_mock_verification"
        Lang = "java"
        SourceFile = "ChunkTopLevel.java"
        MainClass = "ChunkTopLevel"
        BinaryOut = "chunk_top_level.bin"
        Ksy = "chunk_top_level.ksy"
        Module = "chunk_top_level"
        Params = ""
    },
    @{
        Name = "04_version_gated_substructures"
        Lang = "java"
        SourceFile = "IsoGridSquareLite.java"
        MainClass = "IsoGridSquareLite"
        BinaryOut = "iso_grid_square_lite.bin"
        Ksy = "iso_grid_square_lite.ksy"
        Module = "iso_grid_square_lite"
        Params = "160"
        GeneratorArgs = @()
        ExtraRuntimeFiles = @()
    },
    @{
        Name = "05_polymorphic_dispatch_table"
        Lang = "java"
        SourceFile = "IsoObjectFactoryInitSnippet.java"
        MainClass = "IsoObjectFactoryInitSnippet"
        BinaryOut = "iso_object_dispatch_table.bin"
        Ksy = "iso_object_dispatch_table.ksy"
        Module = "iso_object_dispatch_table"
        Params = ""
        GeneratorArgs = @()
        ExtraRuntimeFiles = @()
    },
    @{
        Name = "06_loop_native_ksy_expressions"
        Lang = "python"
        SourceFile = "gen_test.py"
        BinaryOut = "loop_native_ksy_expressions.bin"
        Ksy = "loop_native_ksy_expressions.ksy"
        Module = "loop_native_ksy_expressions"
        Params = ""
        GeneratorArgs = @("--size", "10")
        ExtraRuntimeFiles = @()
    },
    @{
        Name = "07_remaining_stream_conditional_typing"
        Lang = "python"
        SourceFile = "gen_test.py"
        BinaryOut = "remaining_stream_conditional_typing.bin"
        Ksy = "remaining_stream_conditional_typing.ksy"
        Module = "remaining_stream_conditional_typing"
        Params = ""
        GeneratorArgs = @("--optional")
        ExtraRuntimeFiles = @()
    },
    @{
        Name = "08_custom_process_length_calc"
        Lang = "python"
        SourceFile = "gen_test.py"
        BinaryOut = "custom_process_length_calc.bin"
        Ksy = "custom_process_length_calc.ksy"
        Module = "custom_process_length_calc"
        Params = ""
        GeneratorArgs = @("--rows", "8")
        ExtraRuntimeFiles = @("bit_count.py")
    }
)

if ($Example -ne "all") {
    $Examples = $Examples | Where-Object { $_.Name -eq $Example }
    if ($Examples.Count -eq 0) {
        throw "Unknown example: $Example"
    }
}

$errors = New-Object System.Collections.Generic.List[string]

function Invoke-Step {
    param(
        [string]$Label,
        [scriptblock]$Action
    )
    Write-Host "  -> $Label"
    & $Action
}

function Ensure-Command {
    param([string]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw "Required command not found: $Name"
    }
}

foreach ($cfg in $Examples) {
    $exampleDir = Join-Path $Root $cfg.Name
    $inputDir = Join-Path $exampleDir "input"
    $outputDir = Join-Path $exampleDir "output"
    $outLibDir = Join-Path $outputDir "lib"
    $binaryPath = Join-Path $outputDir $cfg.BinaryOut
    $ksyPath = Join-Path $outputDir $cfg.Ksy
    $parseOutPath = Join-Path $outputDir "parsed.txt"

    Write-Host ""
    Write-Host "=== $($cfg.Name) ==="

    try {
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir | Out-Null
        }
        if (-not (Test-Path $outLibDir)) {
            New-Item -ItemType Directory -Path $outLibDir | Out-Null
        }

        if ($cfg.Lang -eq "java") {
            Invoke-Step "Step 1: compile Java input" {
                Ensure-Command "javac"
                Push-Location $inputDir
                try {
                    & javac $cfg.SourceFile
                    if ($LASTEXITCODE -ne 0) { throw "javac failed" }
                } finally { Pop-Location }
            }
            Invoke-Step "Step 1: run Java generator" {
                Ensure-Command "java"
                Push-Location $inputDir
                try {
                    & java $cfg.MainClass $binaryPath
                    if ($LASTEXITCODE -ne 0) { throw "java run failed" }
                } finally { Pop-Location }
            }
        }

        if ($cfg.Lang -eq "python") {
            Invoke-Step "Step 1: run Python generator" {
                Ensure-Command "python"
                Push-Location $inputDir
                try {
                    $args = @($cfg.SourceFile, "--output", $binaryPath)
                    if ($null -ne $cfg.GeneratorArgs -and $cfg.GeneratorArgs.Count -gt 0) {
                        $args += $cfg.GeneratorArgs
                    }
                    & python @args
                    if ($LASTEXITCODE -ne 0) { throw "python generator failed" }
                } finally { Pop-Location }
            }
        }

        if ($cfg.Lang -eq "csharp") {
            $hasCsc = $null -ne (Get-Command csc -ErrorAction SilentlyContinue)
            $hasDotnet = $null -ne (Get-Command dotnet -ErrorAction SilentlyContinue)

            if ($hasCsc) {
                Invoke-Step "Step 1: compile C# input (csc)" {
                    Push-Location $inputDir
                    try {
                        & csc /nologo /out:example_gen.exe $cfg.SourceFile
                        if ($LASTEXITCODE -ne 0) { throw "csc failed" }
                    } finally { Pop-Location }
                }
                Invoke-Step "Step 1: run C# generator (csc output)" {
                    Push-Location $inputDir
                    try {
                        & .\example_gen.exe $binaryPath
                        if ($LASTEXITCODE -ne 0) { throw "C# run failed" }
                    } finally { Pop-Location }
                }
            }
            elseif ($hasDotnet) {
                Invoke-Step "Step 1: compile C# input (dotnet build)" {
                    Push-Location $inputDir
                    try {
                        & dotnet build -nologo -v minimal
                        if ($LASTEXITCODE -ne 0) { throw "dotnet build failed" }
                    } finally { Pop-Location }
                }
                Invoke-Step "Step 1: run C# generator (dotnet run)" {
                    Push-Location $inputDir
                    try {
                        & dotnet run --no-build -- $binaryPath
                        if ($LASTEXITCODE -ne 0) { throw "dotnet run failed" }
                    } finally { Pop-Location }
                }
            }
            else {
                throw "Required command not found: csc or dotnet"
            }
        }

        Invoke-Step "Step 2: compile .ksy to Python parser" {
            Ensure-Command "ksc"
            & ksc -t python $ksyPath -d $outLibDir
            if ($LASTEXITCODE -ne 0) { throw "ksc failed" }

            if ($null -ne $cfg.ExtraRuntimeFiles -and $cfg.ExtraRuntimeFiles.Count -gt 0) {
                foreach ($runtimeFile in $cfg.ExtraRuntimeFiles) {
                    $src = Join-Path $outputDir $runtimeFile
                    if (-not (Test-Path $src)) {
                        throw "Missing runtime helper file: $src"
                    }
                    Copy-Item $src -Destination (Join-Path $outLibDir $runtimeFile) -Force
                }
            }
        }

        Invoke-Step "Step 3: parse binary with generated parser" {
            Ensure-Command "python"
            if (-not (Test-Path $UnifiedParser)) {
                throw "Unified parser not found: $UnifiedParser"
            }
            if ([string]::IsNullOrWhiteSpace($cfg.Params)) {
                & python $UnifiedParser $cfg.Module $binaryPath -nv -o $parseOutPath -l $outLibDir
            } else {
                & python $UnifiedParser $cfg.Module $binaryPath -nv -o $parseOutPath -l $outLibDir --params $cfg.Params
            }
            if ($LASTEXITCODE -ne 0) { throw "python parse failed" }
        }

        Write-Host "  OK: workflow completed"
    }
    catch {
        $msg = "[$($cfg.Name)] $($_.Exception.Message)"
        $errors.Add($msg)
        Write-Host "  ERROR: $msg"
    }
}

Write-Host ""
if ($errors.Count -gt 0) {
    Write-Host "Workflow finished with errors:" -ForegroundColor Red
    foreach ($e in $errors) {
        Write-Host "- $e"
    }
    exit 1
}

Write-Host "Workflow finished successfully for all selected examples."
exit 0
