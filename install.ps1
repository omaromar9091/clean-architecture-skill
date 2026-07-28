# install-clean-architecture-skill.ps1
#
# Installs the Clean Architecture Claude Skill into the current project.
# For Windows / PowerShell. For macOS/Linux, use install.sh instead.
#
# Usage (from the project's root folder, in PowerShell):
#   iwr -useb https://raw.githubusercontent.com/omaromar9091/clean-architecture-skill/main/install.ps1 | iex
#   # or, after cloning the repo:
#   .\install.ps1

$ErrorActionPreference = "Stop"

$Repo = "omaromar9091/clean-architecture-skill"
$Branch = "main"
$TargetDir = ".claude\skills\clean-architecture"
$RawBase = "https://raw.githubusercontent.com/$Repo/$Branch"

$ReferenceFiles = @(
    "authority-model.md",
    "code-examples.md",
    "cross-cutting-concerns.md",
    "domain-events.md",
    "error-handling.md",
    "file-granularity.md",
    "framework-exceptions.md",
    "legacy-and-conflicts.md",
    "port-versioning.md",
    "shared-validation.md",
    "verification.md"
)

Write-Host "==> Installing Clean Architecture Skill into .\$TargetDir"

New-Item -ItemType Directory -Force -Path "$TargetDir\references" | Out-Null

function Get-SkillFile {
    param(
        [string]$RemotePath,
        [string]$LocalPath
    )
    Invoke-WebRequest -Uri "$RawBase/$RemotePath" -OutFile $LocalPath -UseBasicParsing
}

Write-Host "==> Downloading SKILL.md"
Get-SkillFile -RemotePath "SKILL.md" -LocalPath "$TargetDir\SKILL.md"

Write-Host "==> Downloading reference files"
foreach ($f in $ReferenceFiles) {
    Write-Host "    - references/$f"
    Get-SkillFile -RemotePath "references/$f" -LocalPath "$TargetDir\references\$f"
}

Write-Host ""
Write-Host "Done. The skill is now available at: $TargetDir" -ForegroundColor Green
Write-Host "Any Claude-based agent (Claude Code, etc.) reading .claude\skills\"
Write-Host "in this project will pick it up automatically."
