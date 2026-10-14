<#
.SYNOPSIS
    jarvis-opencode-framework injection script (Windows / PowerShell 5.1)
.DESCRIPTION
    Injects the framework (config / slim / agent-os / skills) into the user's
    existing opencode config dir (~/.config/opencode). Assumes opencode is
    already installed. Steps:
      1) Back up existing ~/.config/opencode
      2) Key-guard: never overwrite a config that already has real keys
      3) Deploy config / slim / agent-os / skills
      4) Write install-receipt.json
.NOTES
    Pure PowerShell 5.1, no external deps. Use -DryRun to rehearse in a temp dir.
    Does NOT install opencode itself (use a separate opencode installer).
#>
[CmdletBinding()]
param(
    [string]$RepoDir = "",
    [string]$TargetDir = "$env:USERPROFILE\.config\opencode",
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

# resolve repo dir if not passed (robust across -File / dot-source / nested invoke)
if (-not $RepoDir) {
    if ($PSScriptRoot) {
        $RepoDir = $PSScriptRoot
    } elseif ($script:MyInvocation.MyCommand.Path) {
        $RepoDir = Split-Path -Parent $script:MyInvocation.MyCommand.Path
    } else {
        $RepoDir = (Get-Location).Path
    }
}

function Write-Step($msg) { Write-Host "`n[STEP] $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  [ERR] $msg" -ForegroundColor Red }

# ---- 0. init ----
Write-Step "init"
if ($DryRun) {
    $TargetDir = Join-Path $env:TEMP ("opencode-framework-dryrun-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    Write-Warn "DryRun: target changed to $TargetDir (real config untouched)"
}
Write-Ok "repo: $RepoDir"
Write-Ok "target: $TargetDir"

# ---- 1. back up existing target ----
Write-Step "backup existing"
if (Test-Path $TargetDir) {
    $backup = "$TargetDir.backup-" + (Get-Date -Format 'yyyyMMdd-HHmmss')
    if (-not $DryRun) { Copy-Item -Path $TargetDir -Destination $backup -Recurse -Force }
    Write-Ok "backed up to: $backup"
} else {
    Write-Ok "target does not exist, no backup needed"
}

# ---- 2. key guard ----
Write-Step "key-guard check"
$existingCfg = Join-Path $TargetDir "opencode.jsonc"
$guardHit = $false
if (Test-Path $existingCfg) {
    $content = Get-Content $existingCfg -Raw
    if ($content -match 'sk-[A-Za-z0-9]|gho_|figd_|fc-[0-9]|AGNES_API_KEY=|GITHUB_TOKEN=|apiKey') {
        $guardHit = $true
        Write-Warn "existing opencode.jsonc appears to contain real keys/tokens; will NOT overwrite it."
        Write-Warn "Manually merge config/opencode.jsonc (this repo) into your existing file."
    }
}

# ---- 3. deploy ----
Write-Step "deploy framework files"
if (-not $DryRun) { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }

$receiptItems = @()

# 3a. config/AGENTS.md (as-is, no rendering needed)
$srcAgents = Join-Path $RepoDir "config\AGENTS.md"
$dstAgents = Join-Path $TargetDir "AGENTS.md"
if (Test-Path $srcAgents) {
    if (-not $DryRun) { Copy-Item $srcAgents $dstAgents -Force }
    $receiptItems += "AGENTS.md"
}

# 3b. config/opencode.jsonc (as-is, unless key-guard hit)
$srcCfg = Join-Path $RepoDir "config\opencode.jsonc"
$dstCfg = Join-Path $TargetDir "opencode.jsonc"
if (Test-Path $srcCfg) {
    if (-not $guardHit) {
        if (-not $DryRun) { Copy-Item $srcCfg $dstCfg -Force }
        $receiptItems += "opencode.jsonc"
    } else {
        $pending = Join-Path $TargetDir "opencode.jsonc.pending-merge"
        if (-not $DryRun) { Copy-Item $srcCfg $pending -Force }
        Write-Warn "key-guard: framework config written to $pending; merge manually."
    }
}

# 3c. config/tui.json (as-is)
$srcTui = Join-Path $RepoDir "config\tui.json"
if (Test-Path $srcTui) {
    if (-not $DryRun) { Copy-Item $srcTui (Join-Path $TargetDir "tui.json") -Force }
    $receiptItems += "tui.json"
}

# 3d. slim / agent-os / skills (recursive copy, as-is)
foreach ($dir in @("slim", "agent-os", "skills")) {
    $src = Join-Path $RepoDir $dir
    if (Test-Path $src) {
        if (-not $DryRun) { robocopy.exe $src (Join-Path $TargetDir $dir) /E /NFL /NDL /NJH /NJS | Out-Null }
        $receiptItems += "$dir/"
    }
}

# ---- 4. receipt ----
Write-Step "write receipt"
$receipt = @{
    package   = "jarvis-opencode-framework"
    version   = "1.0.0"
    installed = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    target    = $TargetDir
    dryrun    = [bool]$DryRun
    items     = $receiptItems
}
$receiptPath = Join-Path $TargetDir "install-receipt.json"
if (-not $DryRun) {
    [System.IO.File]::WriteAllText($receiptPath, ($receipt | ConvertTo-Json -Depth 3), [System.Text.UTF8Encoding]::new($false))
}
Write-Ok "receipt: $receiptPath"

# ---- 5. done ----
Write-Step "done"
Write-Host ""
Write-Host "Framework injected. Next (manual):" -ForegroundColor White
Write-Host "  1. Edit ~/.config/opencode/opencode.jsonc: set 'model'/'small_model' to your provider+model." -ForegroundColor White
Write-Host "  2. Run 'opencode' in terminal." -ForegroundColor White
Write-Host "Optional: agent-os/ EVO mechanism and slim/ multi-agent routing enable per TEAM_PROTOCOL.md." -ForegroundColor White
Write-Host "Unfilled optionals (dp-brain / ollama / local-rag) can stay disabled; they do not block startup." -ForegroundColor White
