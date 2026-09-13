param(
    [Parameter(Mandatory=$false)]
    [string]$Drive24Path,

    [Parameter(Mandatory=$false)]
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$docPath = Join-Path $ProjectRoot "doc"
$linkPath = Join-Path $docPath "conception"

if (-not (Test-Path $docPath)) {
    throw "Le dossier doc est introuvable : $docPath"
}

if ([string]::IsNullOrWhiteSpace($Drive24Path)) {
    Write-Host ""
    Write-Host "Indiquez le chemin LOCAL du dossier Google Drive synchronisé contenant la documentation de 24."
    Write-Host "Exemple : G:\Mon Drive\24 - Jeu"
    $Drive24Path = Read-Host "Chemin Google Drive"
}

$Drive24Path = $Drive24Path.Trim('"')

if (-not (Test-Path $Drive24Path)) {
    throw "Le chemin Google Drive n'existe pas : $Drive24Path"
}

if (Test-Path $linkPath) {
    $item = Get-Item -LiteralPath $linkPath -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        Write-Host "Une liaison existe déjà : $linkPath"
        exit 0
    }

    $children = Get-ChildItem -LiteralPath $linkPath -Force
    if ($children.Count -gt 0) {
        throw "Le dossier $linkPath existe et n'est pas vide. Il n'a pas été remplacé."
    }
    Remove-Item -LiteralPath $linkPath -Force
}

New-Item -ItemType Junction -Path $linkPath -Target $Drive24Path | Out-Null

Write-Host ""
Write-Host "Liaison créée :"
Write-Host "  $linkPath"
Write-Host "    -> $Drive24Path"
Write-Host ""
Write-Host "Le dossier doc/conception est exclu de Git par .gitignore."
