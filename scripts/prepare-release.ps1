param(
    [string]$OutputRoot = "release",
    [string]$Version = "",
    [switch]$IncludeUserData,
    [switch]$SlimRuntime
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")

if ([string]::IsNullOrWhiteSpace($Version)) {
    $Version = (Get-Date -Format "yyyy.MM.dd")
}

$releaseName = "OpenClaw-$Version"
$outputRootAbs = Resolve-Path $repoRoot | ForEach-Object { Join-Path $_ $OutputRoot }
$releaseDir = Join-Path $outputRootAbs $releaseName

if (Test-Path $releaseDir) {
    $suffix = Get-Date -Format "HHmmss"
    $releaseName = "$releaseName-$suffix"
    $releaseDir = Join-Path $outputRootAbs $releaseName
    Write-Host "[release] existing version dir found, fallback to: $releaseName"
}

New-Item -ItemType Directory -Path $releaseDir | Out-Null
Write-Host "[release] output: $releaseDir"
$includeOpenClawSource = -not $SlimRuntime
if ($includeOpenClawSource) {
    Write-Host "[release] mode: full-source"
} else {
    Write-Host "[release] mode: slim-runtime"
}

function Copy-PathSafe {
    param(
        [string]$SourceRelative,
        [string]$TargetRelative = ""
    )
    $sourcePath = Join-Path $repoRoot $SourceRelative
    if (-not (Test-Path $sourcePath)) {
        Write-Host "[release] skip missing: $SourceRelative"
        return
    }

    $targetBase = if ([string]::IsNullOrWhiteSpace($TargetRelative)) {
        $releaseDir
    } else {
        Join-Path $releaseDir $TargetRelative
    }

    if (-not (Test-Path $targetBase)) {
        New-Item -ItemType Directory -Path $targetBase -Force | Out-Null
    }

    $sourceItem = Get-Item -LiteralPath $sourcePath
    if ($sourceItem.PSIsContainer) {
        $targetPath = Join-Path $targetBase $sourceItem.Name
        if (-not (Test-Path $targetPath)) {
            New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        }

        robocopy $sourcePath $targetPath /E /R:2 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -ge 8) {
            throw "robocopy failed for $SourceRelative with exit code $LASTEXITCODE"
        }
    } else {
        Copy-Item -Path $sourcePath -Destination $targetBase -Force
    }
    Write-Host "[release] copied: $SourceRelative"
}

# Required runtime artifacts
Copy-PathSafe -SourceRelative "OpenClawManager.exe"
Copy-PathSafe -SourceRelative ".env"
Copy-PathSafe -SourceRelative "env"
Copy-PathSafe -SourceRelative "openclaw_app/openclaw.json" -TargetRelative "openclaw_app"
Copy-PathSafe -SourceRelative "openclaw_app/dist" -TargetRelative "openclaw_app"
Copy-PathSafe -SourceRelative "openclaw_app/extensions" -TargetRelative "openclaw_app"
Copy-PathSafe -SourceRelative "openclaw_app/skills" -TargetRelative "openclaw_app"
Copy-PathSafe -SourceRelative "openclaw_app/openclaw.mjs" -TargetRelative "openclaw_app"
Copy-PathSafe -SourceRelative "openclaw_app/package.json" -TargetRelative "openclaw_app"
Copy-PathSafe -SourceRelative "openclaw_app/package-lock.json" -TargetRelative "openclaw_app"
Copy-PathSafe -SourceRelative "openclaw_app/docs" -TargetRelative "openclaw_app"
Copy-PathSafe -SourceRelative "openclaw_app/skillhub_runtime" -TargetRelative "openclaw_app"
Copy-PathSafe -SourceRelative "openclaw_app/.browser_cache" -TargetRelative "openclaw_app"
Copy-PathSafe -SourceRelative "openclaw_app/.npm-cache" -TargetRelative "openclaw_app"

if ($includeOpenClawSource) {
    $sourceApp = Join-Path $repoRoot "openclaw_app"
    $targetApp = Join-Path $releaseDir "openclaw_app"
    Write-Host "[release] include source: syncing openclaw_app (excluding dist/node_modules/caches) ..."
    robocopy $sourceApp $targetApp /E /R:2 /W:1 /NFL /NDL /NJH /NJS /NP /XD dist node_modules .browser_cache .npm-cache .git .github | Out-Null
    if ($LASTEXITCODE -ge 8) {
        throw "robocopy failed while syncing openclaw source with exit code $LASTEXITCODE"
    }
    Write-Host "[release] included: openclaw_app source tree"
}

# Build runtime dependencies inside release package to avoid symlink copy issues.
$releaseNodeExe = Join-Path $releaseDir "env/node/node.exe"
$releaseNpmCli = Join-Path $releaseDir "env/node/npm/bin/npm-cli.js"
$releaseAppDir = Join-Path $releaseDir "openclaw_app"

if ((Test-Path $releaseNodeExe) -and (Test-Path $releaseNpmCli) -and (Test-Path (Join-Path $releaseAppDir "package.json"))) {
    Write-Host "[release] installing production dependencies in release/openclaw_app ..."
    Push-Location $releaseAppDir
    try {
        & $releaseNodeExe $releaseNpmCli install --omit=dev --ignore-scripts --install-strategy=hoisted
        if ($LASTEXITCODE -ne 0) {
            throw "npm install failed with exit code $LASTEXITCODE"
        }
    } finally {
        Pop-Location
    }
    Write-Host "[release] installed: openclaw_app/node_modules"
} else {
    Write-Host "[release] skip dependency install: missing node/npm/package.json"
}

if ($IncludeUserData) {
    Copy-PathSafe -SourceRelative "openclaw_data"
}

# Release docs
Copy-PathSafe -SourceRelative "release-manifest.md"
Copy-PathSafe -SourceRelative "README.md"
Copy-PathSafe -SourceRelative "FAQ.md"

Write-Host ""
Write-Host "[release] done."
Write-Host "[release] entry: OpenClawManager.exe"
if ($includeOpenClawSource) {
    Write-Host "[release] excluded by design: start.bat, *.zip, node_modules from openclaw_app source sync"
} else {
    Write-Host "[release] excluded by design: start.bat, *.zip, source trees"
}
