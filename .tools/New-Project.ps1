[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,
    [ValidatePattern('^3\.\d+$')]
    [string]$PythonVersion = '3.13',
    [string]$WorkspaceRoot
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = Split-Path -Parent $PSScriptRoot
}

function Copy-Template {
    param([string]$Source, [string]$Destination)

    foreach ($item in Get-ChildItem -LiteralPath $Source -Force) {
        if ($item.Name -in @('.git', '.venv', 'venv', '__pycache__')) {
            continue
        }
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            throw "Template links are not supported: $($item.FullName)"
        }
        $target = Join-Path $Destination $item.Name
        if ($item.PSIsContainer) {
            New-Item -ItemType Directory -Path $target -ErrorAction Stop | Out-Null
            Copy-Template -Source $item.FullName -Destination $target
        } else {
            Copy-Item -LiteralPath $item.FullName -Destination $target
        }
    }
}

$projectName = $ProjectName.Trim()
if ([string]::IsNullOrWhiteSpace($projectName) -or
    $projectName.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ge 0 -or
    $projectName -match '[\x00-\x1f]' -or $projectName.EndsWith('.') -or
    $projectName -in @('.', '..')) {
    throw 'Enter a valid Windows folder name, without a path.'
}

$parent = Join-Path $WorkspaceRoot 'Projects'
$template = Join-Path $parent '_Template_Combined'
$destination = Join-Path $parent "Project $projectName"
if (Test-Path -LiteralPath $destination) {
    throw "Project already exists; nothing was changed: $destination"
}
if (-not (Test-Path -LiteralPath $template -PathType Container)) {
    throw "Template not found: $template"
}
$messagePath = Join-Path $PSScriptRoot 'New-Project.messages.json'
$gitViewMessages = Get-Content -LiteralPath $messagePath -Encoding UTF8 -Raw | ConvertFrom-Json
Get-Command git -ErrorAction Stop | Out-Null
& git --version
if ($LASTEXITCODE -ne 0) { throw 'Git is not available.' }
Get-Command py -ErrorAction Stop | Out-Null
& py "-$PythonVersion" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)'
if ($LASTEXITCODE -ne 0) { throw "Python $PythonVersion (3.10 or later) is required." }
$systemPython = & py "-$PythonVersion" -c 'import sys; print(sys.executable)'
if ($LASTEXITCODE -ne 0) { throw 'Python executable could not be resolved.' }
$systemPython = $systemPython.Trim()

$created = $false
try {
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -ErrorAction Stop | Out-Null
    }
    New-Item -ItemType Directory -Path $destination -ErrorAction Stop | Out-Null
    $created = $true
    Copy-Template -Source $template -Destination $destination

    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $gitignore = Join-Path $destination '.gitignore'
    $ignoreText = ''
    if (Test-Path -LiteralPath $gitignore) {
        $ignoreText = [System.IO.File]::ReadAllText($gitignore)
    }
    $ignoreLines = @($ignoreText -split '\r?\n')
    foreach ($pattern in @('.venv/', 'venv/', '__pycache__/', '*.py[cod]', '.env')) {
        if ($pattern -notin $ignoreLines) {
            $ignoreText += "`r`n$pattern`r`n"
        }
    }
    [System.IO.File]::WriteAllText($gitignore, $ignoreText, $utf8)

    & git -C $destination init -b main
    if ($LASTEXITCODE -ne 0) { throw 'Git initialization failed.' }

    $vscode = Join-Path $destination '.vscode'
    if (-not (Test-Path -LiteralPath $vscode)) {
        New-Item -ItemType Directory -Path $vscode | Out-Null
    }
    $settings = Join-Path $vscode 'settings.json'
    if (-not (Test-Path -LiteralPath $settings)) {
        $settingsText = @{
            'python.defaultInterpreterPath' = $systemPython
        } | ConvertTo-Json
        [System.IO.File]::WriteAllText($settings, $settingsText, $utf8)
    } else {
        Write-Host "Existing VS Code settings preserved. Select interpreter: $systemPython"
    }
    Write-Host "Using installed Python (no virtual environment or package installation): $systemPython"

    & git -C $destination add -A
    if ($LASTEXITCODE -ne 0) { throw 'Git staging failed.' }

    Write-Host "Created: $destination"
    Write-Host 'Project files are ready to use in VS Code.'
    Write-Host 'Initial project files have been staged in Git; no commit, remote repository, or push was created.'
    Write-Host 'Review staged files before your first commit:'
    Write-Host "git -C `"$destination`" status"
    Write-Host "git -C `"$destination`" diff --cached"
    Write-Host "git -C `"$destination`" commit -m `"Initial project setup`""
    foreach ($message in $gitViewMessages) {
        Write-Host ($message.Replace('{projectPath}', $destination))
    }
} catch {
    if ($created) {
        Write-Warning "Setup failed. Partial files were kept for inspection: $destination"
    }
    throw
}
