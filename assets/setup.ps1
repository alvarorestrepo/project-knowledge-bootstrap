# project-knowledge-bootstrap Windows Setup
# Version: 1.1.1
# Configures AI coding assistants on Windows using PowerShell
# Usage:
#   .\setup.ps1              # Interactive mode
#   .\setup.ps1 -All         # All AI assistants (project)
#   .\setup.ps1 -All -Global # All AI assistants (global)
#   .\setup.ps1 -Claude      # Only Claude Code

param(
    [switch]$All,
    [switch]$Global,
    [switch]$Claude,
    [switch]$Cursor,
    [switch]$OpenCode,
    [switch]$Gemini,
    [switch]$Copilot,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$SkillsSource = $ScriptDir
$ProjectName = Split-Path -Leaf $RepoRoot

# Windows-friendly paths for global config
$HomeDir = $env:USERPROFILE

function Show-Help {
    Write-Host "Usage: setup.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Configure AI coding assistants for $ProjectName development."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -All       Configure all AI assistants"
    Write-Host "  -Global    Install globally (user profile) instead of project"
    Write-Host "  -Claude    Configure Claude Code"
    Write-Host "  -Cursor    Configure Cursor"
    Write-Host "  -OpenCode  Configure OpenCode"
    Write-Host "  -Gemini    Configure Gemini CLI"
    Write-Host "  -Copilot   Configure GitHub Copilot"
    Write-Host "  -Help      Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\setup.ps1             # Interactive selection (project)"
    Write-Host "  .\setup.ps1 -All        # All AI assistants (project)"
    Write-Host "  .\setup.ps1 -All -Global # All AI assistants (global)"
}

function Show-Menu {
    $scopeLabel = if ($Global) { "global" } else { "project" }
    Write-Host "Which AI assistants do you use? ($scopeLabel)" -ForegroundColor White -BackgroundColor Black
    Write-Host "(Use numbers to toggle, Enter to confirm)" -ForegroundColor Cyan
    Write-Host ""

    $options = @("Claude Code", "Cursor", "OpenCode", "Gemini CLI", "GitHub Copilot")
    $selected = @($true, $false, $false, $false, $false)

    while ($true) {
        for ($i = 0; $i -lt $options.Count; $i++) {
            $mark = if ($selected[$i]) { "[x]" } else { "[ ]" }
            $color = if ($selected[$i]) { "Green" } else { "White" }
            Write-Host "  $mark $($i + 1). $($options[$i])" -ForegroundColor $color
        }
        Write-Host ""
        Write-Host "  a. Select all" -ForegroundColor Yellow
        Write-Host "  n. Select none" -ForegroundColor Yellow
        Write-Host ""
        $choice = Read-Host "Toggle (1-5, a, n) or Enter to confirm"

        switch ($choice) {
            "1" { $selected[0] = -not $selected[0] }
            "2" { $selected[1] = -not $selected[1] }
            "3" { $selected[2] = -not $selected[2] }
            "4" { $selected[3] = -not $selected[3] }
            "5" { $selected[4] = -not $selected[4] }
            "a" { $selected = @($true, $true, $true, $true, $true) }
            "A" { $selected = @($true, $true, $true, $true, $true) }
            "n" { $selected = @($false, $false, $false, $false, $false) }
            "N" { $selected = @($false, $false, $false, $false, $false) }
            "" { break }
            default { Write-Host "Invalid option" -ForegroundColor Red }
        }

        if ($choice -eq "") { break }
    }

    $global:SETUP_CLAUDE = $selected[0]
    $global:SETUP_CURSOR = $selected[1]
    $global:SETUP_OPENCODE = $selected[2]
    $global:SETUP_GEMINI = $selected[3]
    $global:SETUP_COPILOT = $selected[4]
}

function Copy-SkillsDirectory {
    param(
        [string]$Target,
        [string]$Parent
    )

    if (-not (Test-Path $Parent)) {
        New-Item -ItemType Directory -Path $Parent -Force | Out-Null
    }

    if (Test-Path $Target) {
        if ((Get-Item $Target).PSIsContainer) {
            $backup = "$Target.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Move-Item -Path $Target -Destination $backup -Force
            Write-Host "  ! Existing skills/ backed up" -ForegroundColor Yellow
        } else {
            Remove-Item $Target -Force
        }
    }

    Copy-Item -Path $SkillsSource -Destination $Target -Recurse -Force
}

function Copy-AgentsMd {
    param(
        [string]$TargetName,
        [string]$SearchRoot
    )

    $agentsFiles = Get-ChildItem -Path $SearchRoot -Filter "AGENTS.md" -Recurse -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch 'node_modules' -and
            $_.FullName -notmatch '\.git' -and
            $_.FullName -notmatch 'vendor' -and
            $_.FullName -notmatch '\.next' -and
            $_.FullName -notmatch 'dist' -and
            $_.FullName -notmatch '\.claude' -and
            $_.FullName -notmatch '\.cursor' -and
            $_.FullName -notmatch '\.gemini'
        }

    $count = 0
    foreach ($file in $agentsFiles) {
        $dest = Join-Path $file.DirectoryName $TargetName
        Copy-Item -Path $file.FullName -Destination $dest -Force
        $count++
    }

    if ($count -gt 0) {
        Write-Host "  Copied $count AGENTS.md -> $TargetName" -ForegroundColor Green
    } else {
        Write-Host "  ! No AGENTS.md files found to copy" -ForegroundColor Yellow
    }
}

# =============================================================================
# TOOL-SPECIFIC SETUP FUNCTIONS
# =============================================================================

function Setup-Claude {
    if ($Global) {
        $target = Join-Path $HomeDir ".claude\skills"
        Copy-SkillsDirectory -Target $target -Parent (Join-Path $HomeDir ".claude")
        Write-Host "  ~\.claude\skills -> $SkillsSource" -ForegroundColor Green

        $agentsMd = Join-Path $RepoRoot "AGENTS.md"
        if (Test-Path $agentsMd) {
            Copy-Item -Path $agentsMd -Destination (Join-Path $HomeDir "CLAUDE.md") -Force
            Write-Host "  AGENTS.md -> ~\CLAUDE.md" -ForegroundColor Green
        }
    } else {
        $target = Join-Path $RepoRoot ".claude\skills"
        Copy-SkillsDirectory -Target $target -Parent (Join-Path $RepoRoot ".claude")
        Write-Host "  .claude\skills -> skills\" -ForegroundColor Green
        Copy-AgentsMd -TargetName "CLAUDE.md" -SearchRoot $RepoRoot
    }
}

function Setup-Cursor {
    if ($Global) {
        $target = Join-Path $HomeDir ".cursor\skills"
        Copy-SkillsDirectory -Target $target -Parent (Join-Path $HomeDir ".cursor")
        Write-Host "  ~\.cursor\skills -> $SkillsSource" -ForegroundColor Green

        $agentsMd = Join-Path $RepoRoot "AGENTS.md"
        if (Test-Path $agentsMd) {
            Copy-Item -Path $agentsMd -Destination (Join-Path $HomeDir ".cursorrules") -Force
            Write-Host "  AGENTS.md -> ~\.cursorrules" -ForegroundColor Green
        }
    } else {
        $target = Join-Path $RepoRoot ".cursor\skills"
        Copy-SkillsDirectory -Target $target -Parent (Join-Path $RepoRoot ".cursor")
        Write-Host "  .cursor\skills -> skills\" -ForegroundColor Green

        $agentsMd = Join-Path $RepoRoot "AGENTS.md"
        if (Test-Path $agentsMd) {
            Copy-Item -Path $agentsMd -Destination (Join-Path $RepoRoot ".cursorrules") -Force
            Write-Host "  AGENTS.md -> .cursorrules" -ForegroundColor Green
        }
    }
}

function Setup-OpenCode {
    if ($Global) {
        $target = Join-Path $HomeDir ".opencode\skills"
        Copy-SkillsDirectory -Target $target -Parent (Join-Path $HomeDir ".opencode")
        Write-Host "  ~\.opencode\skills -> $SkillsSource" -ForegroundColor Green
        Write-Host "  OpenCode uses AGENTS.md natively" -ForegroundColor Green
    } else {
        $target = Join-Path $RepoRoot ".opencode\skills"
        Copy-SkillsDirectory -Target $target -Parent (Join-Path $RepoRoot ".opencode")
        Write-Host "  .opencode\skills -> skills\" -ForegroundColor Green
        Write-Host "  OpenCode uses AGENTS.md natively" -ForegroundColor Green
    }
}

function Setup-Gemini {
    if ($Global) {
        $target = Join-Path $HomeDir ".gemini\skills"
        Copy-SkillsDirectory -Target $target -Parent (Join-Path $HomeDir ".gemini")
        Write-Host "  ~\.gemini\skills -> $SkillsSource" -ForegroundColor Green

        $agentsMd = Join-Path $RepoRoot "AGENTS.md"
        if (Test-Path $agentsMd) {
            Copy-Item -Path $agentsMd -Destination (Join-Path $HomeDir "GEMINI.md") -Force
            Write-Host "  AGENTS.md -> ~\GEMINI.md" -ForegroundColor Green
        }
    } else {
        $target = Join-Path $RepoRoot ".gemini\skills"
        Copy-SkillsDirectory -Target $target -Parent (Join-Path $RepoRoot ".gemini")
        Write-Host "  .gemini\skills -> skills\" -ForegroundColor Green
        Copy-AgentsMd -TargetName "GEMINI.md" -SearchRoot $RepoRoot
    }
}

function Setup-Copilot {
    if ($Global) {
        Write-Host "  ! GitHub Copilot setup is project-only. Skipping global." -ForegroundColor Yellow
        return
    }

    $agentsMd = Join-Path $RepoRoot "AGENTS.md"
    if (Test-Path $agentsMd) {
        $githubDir = Join-Path $RepoRoot ".github"
        New-Item -ItemType Directory -Path $githubDir -Force | Out-Null
        Copy-Item -Path $agentsMd -Destination (Join-Path $githubDir "copilot-instructions.md") -Force
        Write-Host "  AGENTS.md -> .github\copilot-instructions.md" -ForegroundColor Green
    } else {
        Write-Host "  ! No root AGENTS.md found for Copilot" -ForegroundColor Yellow
    }
}

# =============================================================================
# PARSE ARGUMENTS
# =============================================================================

if ($Help) {
    Show-Help
    exit 0
}

if ($All) {
    $SETUP_CLAUDE = $true
    $SETUP_CURSOR = $true
    $SETUP_OPENCODE = $true
    $SETUP_GEMINI = $true
    $SETUP_COPILOT = $true
}

# =============================================================================
# MAIN
# =============================================================================

$scopeLabel = if ($Global) { "global" } else { "project" }

Write-Host ""
Write-Host "AI Skills Setup — $ProjectName ($scopeLabel)" -ForegroundColor White
Write-Host "========================================"
Write-Host ""

$skillCount = (Get-ChildItem -Path $SkillsSource -Filter "SKILL.md" -Recurse | Where-Object { $_.DirectoryName -ne $SkillsSource }).Count

if ($skillCount -eq 0) {
    Write-Host "No skills found in $SkillsSource" -ForegroundColor Red
    exit 1
}

Write-Host "Found $skillCount skills to configure" -ForegroundColor Blue
Write-Host ""

# Interactive mode if no flags provided
if (-not ($SETUP_CLAUDE -or $SETUP_CURSOR -or $SETUP_OPENCODE -or $SETUP_GEMINI -or $SETUP_COPILOT)) {
    Show-Menu
    Write-Host ""
}

if (-not ($SETUP_CLAUDE -or $SETUP_CURSOR -or $SETUP_OPENCODE -or $SETUP_GEMINI -or $SETUP_COPILOT)) {
    Write-Host "No AI assistants selected. Nothing to do." -ForegroundColor Yellow
    exit 0
}

$step = 1
$total = 0
if ($SETUP_CLAUDE) { $total++ }
if ($SETUP_CURSOR) { $total++ }
if ($SETUP_OPENCODE) { $total++ }
if ($SETUP_GEMINI) { $total++ }
if ($SETUP_COPILOT) { $total++ }

if ($SETUP_CLAUDE) {
    Write-Host "[$step/$total] Setting up Claude Code..." -ForegroundColor Yellow
    Setup-Claude
    Write-Host ""
    $step++
}

if ($SETUP_CURSOR) {
    Write-Host "[$step/$total] Setting up Cursor..." -ForegroundColor Yellow
    Setup-Cursor
    Write-Host ""
    $step++
}

if ($SETUP_OPENCODE) {
    Write-Host "[$step/$total] Setting up OpenCode..." -ForegroundColor Yellow
    Setup-OpenCode
    Write-Host ""
    $step++
}

if ($SETUP_GEMINI) {
    Write-Host "[$step/$total] Setting up Gemini CLI..." -ForegroundColor Yellow
    Setup-Gemini
    Write-Host ""
    $step++
}

if ($SETUP_COPILOT) {
    Write-Host "[$step/$total] Setting up GitHub Copilot..." -ForegroundColor Yellow
    Setup-Copilot
    Write-Host ""
}

# =============================================================================
# SUMMARY
# =============================================================================

Write-Host "Done! Configured $skillCount AI skills." -ForegroundColor Green
Write-Host ""
Write-Host "Installation report ($scopeLabel):"
Write-Host ""

if ($Global) {
    if ($SETUP_CLAUDE) {
        Write-Host "  Claude Code    $(Resolve-Path (Join-Path $HomeDir '.claude\skills') -ErrorAction SilentlyContinue)"
        Write-Host "                 $(Join-Path $HomeDir 'CLAUDE.md')"
    }
    if ($SETUP_CURSOR) {
        Write-Host "  Cursor         $(Resolve-Path (Join-Path $HomeDir '.cursor\skills') -ErrorAction SilentlyContinue)"
        Write-Host "                 $(Join-Path $HomeDir '.cursorrules')"
    }
    if ($SETUP_OPENCODE) {
        Write-Host "  OpenCode       $(Resolve-Path (Join-Path $HomeDir '.opencode\skills') -ErrorAction SilentlyContinue)"
    }
    if ($SETUP_GEMINI) {
        Write-Host "  Gemini CLI     $(Resolve-Path (Join-Path $HomeDir '.gemini\skills') -ErrorAction SilentlyContinue)"
        Write-Host "                 $(Join-Path $HomeDir 'GEMINI.md')"
    }
    if ($SETUP_COPILOT) {
        Write-Host "  GitHub Copilot project-only (skipped globally)"
    }
} else {
    if ($SETUP_CLAUDE) {
        Write-Host "  Claude Code    $(Join-Path $RepoRoot '.claude\skills')"
        Write-Host "                 $(Join-Path $RepoRoot 'CLAUDE.md')"
    }
    if ($SETUP_CURSOR) {
        Write-Host "  Cursor         $(Join-Path $RepoRoot '.cursor\skills')"
        Write-Host "                 $(Join-Path $RepoRoot '.cursorrules')"
    }
    if ($SETUP_OPENCODE) {
        Write-Host "  OpenCode       $(Join-Path $RepoRoot '.opencode\skills')"
        Write-Host "                 $(Join-Path $RepoRoot 'AGENTS.md') (native)"
    }
    if ($SETUP_GEMINI) {
        Write-Host "  Gemini CLI     $(Join-Path $RepoRoot '.gemini\skills')"
        Write-Host "                 $(Join-Path $RepoRoot 'GEMINI.md')"
    }
    if ($SETUP_COPILOT) {
        Write-Host "  GitHub Copilot $(Join-Path $RepoRoot '.github\copilot-instructions.md')"
    }
}

Write-Host ""
Write-Host "Note: Restart your AI assistant to load the skills." -ForegroundColor Blue
Write-Host "      AGENTS.md is the source of truth — edit it, then re-run this script." -ForegroundColor Blue
