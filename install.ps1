<#
.SYNOPSIS
    jarvis-opencode-framework installer (Windows / PowerShell 5.1)
.DESCRIPTION
    1) Detect and (optionally) globally install opencode
    2) Back up existing ~/.config/opencode
    3) Key-guard: never overwrite a config that already has real keys
    4) Render $XXX placeholders from config/.env
    5) Deploy config / slim / agent-os / skills
    6) Write install-receipt.json
.NOTES
    Pure PowerShell 5.1, no external deps. Use -DryRun to rehearse in a temp dir.
#>
[CmdletBinding()]
param(
    [string]$RepoDir = "",
    [string]$TargetDir = "$env:USERPROFILE\.config\opencode",
    [switch]$DryRun,
    [switch]$SkipOpenCodeInstall
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

# ---- 1. install opencode globally ----
if (-not $SkipOpenCodeInstall) {
    Write-Step "check opencode"
    $oc = Get-Command opencode -ErrorAction SilentlyContinue
    if ($oc) {
        Write-Ok "found: $($oc.Source)"
    } else {
        Write-Warn "opencode not found, attempting global install (requires Node.js)"
        $node = Get-Command node -ErrorAction SilentlyContinue
        if (-not $node) {
            Write-Err "node not found. Install Node.js LTS first (winget install OpenJS.NodeJS.LTS), then rerun."
            Write-Err "Or install opencode manually and rerun with -SkipOpenCodeInstall."
            exit 2
        }
        Write-Host "  running: npm i -g opencode-ai@latest"
        try {
            npm i -g opencode-ai@latest 2>&1 | Out-Null
            $oc = Get-Command opencode -ErrorAction SilentlyContinue
            if (-not $oc) { throw "opencode still not on PATH after npm install" }
            Write-Ok "opencode installed: $($oc.Source)"
        } catch {
            Write-Err "auto-install failed: $_"
            Write-Err "Please run 'npm i -g opencode-ai@latest' then rerun with -SkipOpenCodeInstall."
            exit 3
        }
    }
    try { $ver = & opencode --version 2>&1; Write-Ok "opencode version: $ver" }
    catch { Write-Warn "could not get opencode --version (may need network on first run)" }
}

# ---- 2. read .env (placeholder values) ----
Write-Step "read .env"
$envFile = Join-Path $RepoDir "config\.env"
$values = @{}
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith('#') -and $line.Contains('=')) {
            $parts = $line.Split('=', 2)
            $values[$parts[0].Trim()] = $parts[1].Trim()
        }
    }
    Write-Ok "read $($values.Count) vars from .env"
} else {
    Write-Warn "config/.env not found; only placeholders with defaults will render, others stay as-is."
}

function Render-Placeholders($text) {
    # these are not real template vars: $XXX is a literal example in comments, $PROFILE is a PowerShell concept
    $skip = @('XXX', 'PROFILE')
    $pattern = '\$([A-Z][A-Z0-9_]*)'
    $sb = New-Object System.Text.StringBuilder
    $last = 0
    foreach ($m in [regex]::Matches($text, $pattern)) {
        $null = $sb.Append($text.Substring($last, $m.Index - $last))
        $name = $m.Groups[1].Value
        if ($skip -contains $name) {
            $null = $sb.Append($m.Value)
        } elseif ($values.ContainsKey($name) -and $values[$name] -ne '') {
            $null = $sb.Append($values[$name])
        } else {
            $null = $sb.Append($m.Value)
            Write-Warn "placeholder `$$name has no value, kept as-is (fill .env)"
        }
        $last = $m.Index + $m.Length
    }
    $null = $sb.Append($text.Substring($last))
    return $sb.ToString()
}

# ---- 3. back up existing target ----
Write-Step "backup existing"
if (Test-Path $TargetDir) {
    $backup = "$TargetDir.backup-" + (Get-Date -Format 'yyyyMMdd-HHmmss')
    if (-not $DryRun) { Copy-Item -Path $TargetDir -Destination $backup -Recurse -Force }
    Write-Ok "backed up to: $backup"
} else {
    Write-Ok "target does not exist, no backup needed"
}

# ---- 4. key guard ----
Write-Step "key-guard check"
$existingCfg = Join-Path $TargetDir "opencode.jsonc"
$guardHit = $false
if (Test-Path $existingCfg) {
    $content = Get-Content $existingCfg -Raw
    if ($content -match 'sk-[A-Za-z0-9]|gho_|figd_|fc-[0-9]|AGNES_API_KEY=|GITHUB_TOKEN=') {
        $guardHit = $true
        Write-Warn "existing opencode.jsonc appears to contain real keys; will NOT overwrite it."
        Write-Warn "Manually merge the rendered template into the existing file."
    }
}

# ---- 5. deploy (with render) ----
Write-Step "deploy framework files"
if (-not $DryRun) { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }

$receiptItems = @()

# 5a. config/AGENTS.md
$srcAgents = Join-Path $RepoDir "config\AGENTS.md"
$dstAgents = Join-Path $TargetDir "AGENTS.md"
$txt = Get-Content $srcAgents -Raw -Encoding UTF8
$txt = Render-Placeholders $txt
if (-not $DryRun) { [System.IO.File]::WriteAllText($dstAgents, $txt, [System.Text.UTF8Encoding]::new($false)) }
$receiptItems += "AGENTS.md"

# 5b. config/opencode.template.jsonc -> opencode.jsonc
$srcCfg = Join-Path $RepoDir "config\opencode.template.jsonc"
$dstCfg = Join-Path $TargetDir "opencode.jsonc"
if (-not $guardHit) {
    $cfg = Get-Content $srcCfg -Raw -Encoding UTF8
    $cfg = Render-Placeholders $cfg
    if (-not $DryRun) { [System.IO.File]::WriteAllText($dstCfg, $cfg, [System.Text.UTF8Encoding]::new($false)) }
    $receiptItems += "opencode.jsonc"
} else {
    $dstCfgPending = Join-Path $TargetDir "opencode.jsonc.pending-render"
    $cfg = Get-Content $srcCfg -Raw -Encoding UTF8
    $cfg = Render-Placeholders $cfg
    if (-not $DryRun) { [System.IO.File]::WriteAllText($dstCfgPending, $cfg, [System.Text.UTF8Encoding]::new($false)) }
    Write-Warn "key-guard: rendered result written to $dstCfgPending; merge manually."
}

# 5c. config/tui.json (as-is)
$srcTui = Join-Path $RepoDir "config\tui.json"
if (Test-Path $srcTui) {
    if (-not $DryRun) { Copy-Item $srcTui (Join-Path $TargetDir "tui.json") -Force }
    $receiptItems += "tui.json"
}

# 5d. slim / agent-os / skills (recursive copy, as-is)
foreach ($dir in @("slim", "agent-os", "skills")) {
    $src = Join-Path $RepoDir $dir
    if (Test-Path $src) {
        if (-not $DryRun) { robocopy.exe $src (Join-Path $TargetDir $dir) /E /NFL /NDL /NJH /NJS | Out-Null }
        $receiptItems += "$dir/"
    }
}

# ---- 6. receipt ----
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

# ---- 7. next steps ----
Write-Step "done"
Write-Host ""
Write-Host "Next steps (manual):" -ForegroundColor White
Write-Host "  1. Copy config/.env.example to config/.env, fill your model API key + paths." -ForegroundColor White
Write-Host "  2. Rerun this script to render (or manually replace $XXX in AGENTS.md / opencode.jsonc)." -ForegroundColor White
Write-Host "  3. At minimum set MAIN_MODEL so opencode can start." -ForegroundColor White
Write-Host "  4. Run 'opencode' in terminal." -ForegroundColor White
Write-Host "Optional: agent-os/ EVO mechanism and slim/ multi-agent routing enable per TEAM_PROTOCOL.md." -ForegroundColor White
Write-Host "Unfilled optionals (dp-brain / ollama / local-rag) can stay empty; they do not block startup." -ForegroundColor White
