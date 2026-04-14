# project-knowledge-bootstrap Windows Setup
# Version: 1.1.2
# Configures AI coding assistants on Windows using PowerShell

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
$HomeDir = $env:USERPROFILE

function Write-Banner {
    $scopeLabel = if ($Global) { "global" } else { "project" }
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  🧠  project-knowledge-bootstrap                           ║" -ForegroundColor Cyan
    Write-Host "║      Configure AI assistants for                           ║" -ForegroundColor Cyan
    Write-Host "║      $ProjectName ($scopeLabel)                              ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Box($Icon, $Text, $Color = "Green") {
    Write-Host "┌────────────────────────────────────────────────────────────┐" -ForegroundColor $Color
    Write-Host "│ $Icon  $Text" -ForegroundColor $Color
    Write-Host "└────────────────────────────────────────────────────────────┘" -ForegroundColor $Color
}

function Show-Help {
    Write-Host "Usage: setup.ps1 [OPTIONS]"
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
}

function Show-Menu {
    $scopeLabel = if ($Global) { "global" } else { "project" }
    Write-Host "🎛️  Which AI assistants do you use? ($scopeLabel)" -ForegroundColor White
    Write-Host "   (Use numbers to toggle, Enter to confirm)" -ForegroundColor DarkGray
    Write-Host ""

    $options = @("🟣 Claude Code", "⚫ Cursor", "🔵 OpenCode", "🔴 Gemini CLI", "🟠 GitHub Copilot")
    $selected = @($true, $false, $false, $false, $false)

    while ($true) {
        for ($i = 0; $i -lt $options.Count; $i++) {
            $mark = if ($selected[$i]) { "[✓]" } else { "[ ]" }
            $color = if ($selected[$i]) { "Green" } else { "DarkGray" }
            Write-Host "     $mark $($i + 1). $($options[$i])" -ForegroundColor $color
        }
        Write-Host ""
        Write-Host "     a. Select all    n. Select none" -ForegroundColor Yellow
        Write-Host ""
        $choice = Read-Host "   Toggle (1-5, a, n) or press Enter"

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
            default { Write-Host "   Invalid option" -ForegroundColor Red }
        }

        if ($choice -eq "") { break }
        [console]::SetCursorPosition(0, [console]::CursorTop - 10)
        for ($i = 0; $i -lt 10; $i++) {
            Write-Host (" " * 60)
        }
        [console]::SetCursorPosition(0, [console]::CursorTop - 10)
    }

    $global:SETUP_CLAUDE = $selected[0]
    $global:SETUP_CURSOR = $selected[1]
    $global:SETUP_OPENCODE = $selected[2]
    $global:SETUP_GEMINI = $selected[3]
    $global:SETUP_COPILOT = $selected[4]
}

function Copy-SkillsDirectory {
    param($Target, $Parent)
    if (-not (Test-Path $Parent)) {
        New-Item -ItemType Directory -Path $Parent -Force | Out-Null
    }
    if (Test-Path $Target) {
        if ((Get-Item $Target).PSIsContainer) {
            $backup = "$Target.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Move-Item -Path $Target -Destination $backup -Force
            Write-Host "     ⚠️  Existing skills/ backed up" -ForegroundColor Yellow
        } else {
            Remove-Item $Target -Force
        }
    }
    Copy-Item -Path $SkillsSource -Destination $Target -Recurse -Force
    Write-Host "     📦 Copied skills/ → $Target" -ForegroundColor Green
}

# ─── Tool Setup Functions ────────────────────────────────────────────

function Setup-Claude {
    Write-Host "   🟣 Claude Code" -ForegroundColor Magenta
    if ($Global) {
        Copy-SkillsDirectory -Target (Join-Path $HomeDir ".claude\skills") -Parent (Join-Path $HomeDir ".claude")
        $agentsMd = Join-Path $RepoRoot "AGENTS.md"
        if (Test-Path $agentsMd) {
            Copy-Item -Path $agentsMd -Destination (Join-Path $HomeDir "CLAUDE.md") -Force
            Write-Host "     📝 Copied AGENTS.md → ~\CLAUDE.md" -ForegroundColor Green -NoNewline; Write-Host ""
        }
    } else {
        Copy-SkillsDirectory -Target (Join-Path $RepoRoot ".claude\skills") -Parent (Join-Path $RepoRoot ".claude")
        $agentsMd = Join-Path $RepoRoot "AGENTS.md"
        if (Test-Path $agentsMd) {
            Copy-Item -Path $agentsMd -Destination (Join-Path $RepoRoot "CLAUDE.md") -Force
            Write-Host "     📝 Copied AGENTS.md → CLAUDE.md" -ForegroundColor Green -NoNewline; Write-Host ""
        }
    }
}

function Setup-Cursor {
    Write-Host "   ⚫ Cursor" -ForegroundColor White
    if ($Global) {
        Copy-SkillsDirectory -Target (Join-Path $HomeDir ".cursor\skills") -Parent (Join-Path $HomeDir ".cursor")
        $agentsMd = Join-Path $RepoRoot "AGENTS.md"
        if (Test-Path $agentsMd) {
            Copy-Item -Path $agentsMd -Destination (Join-Path $HomeDir ".cursorrules") -Force
            Write-Host "     📝 Copied AGENTS.md → ~\.cursorrules" -ForegroundColor Green -NoNewline; Write-Host ""
        }
    } else {
        Copy-SkillsDirectory -Target (Join-Path $RepoRoot ".cursor\skills") -Parent (Join-Path $RepoRoot ".cursor")
        $agentsMd = Join-Path $RepoRoot "AGENTS.md"
        if (Test-Path $agentsMd) {
            Copy-Item -Path $agentsMd -Destination (Join-Path $RepoRoot ".cursorrules") -Force
            Write-Host "     📝 Copied AGENTS.md → .cursorrules" -ForegroundColor Green -NoNewline; Write-Host ""
        }
    }
}

function Setup-OpenCode {
    Write-Host "   🔵 OpenCode" -ForegroundColor Blue
    if ($Global) {
        Copy-SkillsDirectory -Target (Join-Path $HomeDir ".opencode\skills") -Parent (Join-Path $HomeDir ".opencode")
        Write-Host "     ✅ OpenCode uses AGENTS.md natively" -ForegroundColor Green
    } else {
        Copy-SkillsDirectory -Target (Join-Path $RepoRoot ".opencode\skills") -Parent (Join-Path $RepoRoot ".opencode")
        Write-Host "     ✅ OpenCode uses AGENTS.md natively" -ForegroundColor Green
    }
}

function Setup-Gemini {
    Write-Host "   🔴 Gemini CLI" -ForegroundColor Red
    if ($Global) {
        Copy-SkillsDirectory -Target (Join-Path $HomeDir ".gemini\skills") -Parent (Join-Path $HomeDir ".gemini")
        $agentsMd = Join-Path $RepoRoot "AGENTS.md"
        if (Test-Path $agentsMd) {
            Copy-Item -Path $agentsMd -Destination (Join-Path $HomeDir "GEMINI.md") -Force
            Write-Host "     📝 Copied AGENTS.md → ~\GEMINI.md" -ForegroundColor Green -NoNewline; Write-Host ""
        }
    } else {
        Copy-SkillsDirectory -Target (Join-Path $RepoRoot ".gemini\skills") -Parent (Join-Path $RepoRoot ".gemini")
        $agentsMd = Join-Path $RepoRoot "AGENTS.md"
        if (Test-Path $agentsMd) {
            Copy-Item -Path $agentsMd -Destination (Join-Path $RepoRoot "GEMINI.md") -Force
            Write-Host "     📝 Copied AGENTS.md → GEMINI.md" -ForegroundColor Green -NoNewline; Write-Host ""
        }
    }
}

function Setup-Copilot {
    Write-Host "   🟠 GitHub Copilot" -ForegroundColor Yellow
    if ($Global) {
        Write-Host "     ⚠️  Project-only. Skipped globally." -ForegroundColor Yellow
        return
    }
    $agentsMd = Join-Path $RepoRoot "AGENTS.md"
    if (Test-Path $agentsMd) {
        $githubDir = Join-Path $RepoRoot ".github"
        New-Item -ItemType Directory -Path $githubDir -Force | Out-Null
        Copy-Item -Path $agentsMd -Destination (Join-Path $githubDir "copilot-instructions.md") -Force
        Write-Host "     📝 Copied AGENTS.md → .github\copilot-instructions.md" -ForegroundColor Green -NoNewline; Write-Host ""
    } else {
        Write-Host "     ⚠️  No root AGENTS.md found" -ForegroundColor Yellow
    }
}

# ─── Main ────────────────────────────────────────────────────────────

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

Write-Banner

$skillFiles = Get-ChildItem -Path $SkillsSource -Filter "SKILL.md" -Recurse | Where-Object { $_.DirectoryName -ne $SkillsSource }
$skillCount = $skillFiles.Count

if ($skillCount -eq 0) {
    Write-Host "❌ No skills found in $SkillsSource" -ForegroundColor Red
    exit 1
}

Write-Host "   Found $skillCount skills to configure" -ForegroundColor DarkGray
Write-Host ""

if (-not ($SETUP_CLAUDE -or $SETUP_CURSOR -or $SETUP_OPENCODE -or $SETUP_GEMINI -or $SETUP_COPILOT)) {
    Show-Menu
    Write-Host ""
}

if (-not ($SETUP_CLAUDE -or $SETUP_CURSOR -or $SETUP_OPENCODE -or $SETUP_GEMINI -or $SETUP_COPILOT)) {
    Write-Host "⚠️  No AI assistants selected. Nothing to do." -ForegroundColor Yellow
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
    Write-Host "   ── Step $step/$total ──" -ForegroundColor Cyan
    Setup-Claude
    $step++
}
if ($SETUP_CURSOR) {
    Write-Host "   ── Step $step/$total ──" -ForegroundColor Cyan
    Setup-Cursor
    $step++
}
if ($SETUP_OPENCODE) {
    Write-Host "   ── Step $step/$total ──" -ForegroundColor Cyan
    Setup-OpenCode
    $step++
}
if ($SETUP_GEMINI) {
    Write-Host "   ── Step $step/$total ──" -ForegroundColor Cyan
    Setup-Gemini
    $step++
}
if ($SETUP_COPILOT) {
    Write-Host "   ── Step $step/$total ──" -ForegroundColor Cyan
    Setup-Copilot
}

# ─── Summary ─────────────────────────────────────────────

Write-Host ""
Write-Box -Icon "🎉" -Text "Installation Complete — $skillCount skills configured" -Color "Green"
Write-Host ""

$scopeLabel = if ($Global) { "global" } else { "project" }
Write-Host "   Installed locations ($scopeLabel):" -ForegroundColor DarkGray
Write-Host ""

if ($Global) {
    if ($SETUP_CLAUDE) {
        Write-Host "   🟣 Claude Code    $(Join-Path $HomeDir '.claude\skills')" -ForegroundColor DarkGray
        Write-Host "                    $(Join-Path $HomeDir 'CLAUDE.md')" -ForegroundColor DarkGray
    }
    if ($SETUP_CURSOR) {
        Write-Host "   ⚫ Cursor         $(Join-Path $HomeDir '.cursor\skills')" -ForegroundColor DarkGray
        Write-Host "                    $(Join-Path $HomeDir '.cursorrules')" -ForegroundColor DarkGray
    }
    if ($SETUP_OPENCODE) {
        Write-Host "   🔵 OpenCode       $(Join-Path $HomeDir '.opencode\skills')" -ForegroundColor DarkGray
    }
    if ($SETUP_GEMINI) {
        Write-Host "   🔴 Gemini CLI     $(Join-Path $HomeDir '.gemini\skills')" -ForegroundColor DarkGray
        Write-Host "                    $(Join-Path $HomeDir 'GEMINI.md')" -ForegroundColor DarkGray
    }
    if ($SETUP_COPILOT) {
        Write-Host "   🟠 GitHub Copilot project-only (skipped globally)" -ForegroundColor Yellow
    }
} else {
    if ($SETUP_CLAUDE) {
        Write-Host "   🟣 Claude Code    $(Join-Path $RepoRoot '.claude\skills')" -ForegroundColor DarkGray
        Write-Host "                    $(Join-Path $RepoRoot 'CLAUDE.md')" -ForegroundColor DarkGray
    }
    if ($SETUP_CURSOR) {
        Write-Host "   ⚫ Cursor         $(Join-Path $RepoRoot '.cursor\skills')" -ForegroundColor DarkGray
        Write-Host "                    $(Join-Path $RepoRoot '.cursorrules')" -ForegroundColor DarkGray
    }
    if ($SETUP_OPENCODE) {
        Write-Host "   🔵 OpenCode       $(Join-Path $RepoRoot '.opencode\skills')" -ForegroundColor DarkGray
        Write-Host "                    $(Join-Path $RepoRoot 'AGENTS.md') (native)" -ForegroundColor DarkGray
    }
    if ($SETUP_GEMINI) {
        Write-Host "   🔴 Gemini CLI     $(Join-Path $RepoRoot '.gemini\skills')" -ForegroundColor DarkGray
        Write-Host "                    $(Join-Path $RepoRoot 'GEMINI.md')" -ForegroundColor DarkGray
    }
    if ($SETUP_COPILOT) {
        Write-Host "   🟠 GitHub Copilot $(Join-Path $RepoRoot '.github\copilot-instructions.md')" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "┌────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "│  💡 Next step: Restart your AI assistant to load skills    │" -ForegroundColor Cyan
Write-Host "│  📝 Pro tip:   AGENTS.md is the source of truth — edit it  │" -ForegroundColor Cyan
Write-Host "│                then re-run this script to sync changes     │" -ForegroundColor Cyan
Write-Host "└────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
Write-Host ""
