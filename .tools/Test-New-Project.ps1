[CmdletBinding()]
param(
    [string]$PythonVersion = '3.13'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$workspaceRoot = Split-Path -Parent $PSScriptRoot
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('workspace-project-' + [guid]::NewGuid().ToString('N'))
$scriptPath = Join-Path $PSScriptRoot 'New-Project.ps1'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

$config = Get-Content -LiteralPath (Join-Path $workspaceRoot '.vscode\tasks.json') -Encoding UTF8 -Raw | ConvertFrom-Json
$creationTasks = @($config.tasks | Where-Object { $_.label -like 'New:*' })
Assert-True ($creationTasks.Count -eq 1) 'Only one VBA-Python creation task must be configured.'
foreach ($task in $creationTasks) {
    Assert-True ($task.type -eq 'shell' -and $task.command -eq 'powershell.exe') 'Creation tasks must not require a custom extension.'
    $typeIndex = [Array]::IndexOf($task.args, '-ProjectType')
    Assert-True ($typeIndex -eq -1) 'Project type selection must not be exposed.'
    $nameIndex = [Array]::IndexOf($task.args, '-ProjectName')
    Assert-True ($nameIndex -ge 0) 'Each task must request a name.'
    $nameArgument = $task.args[$nameIndex + 1]
    Assert-True ($nameArgument.value -eq '${input:projectName}' -and $nameArgument.quoting -eq 'strong') 'Project names must be strongly quoted.'
    $versionIndex = [Array]::IndexOf($task.args, '-PythonVersion')
    Assert-True ($versionIndex -ge 0) 'The creation task must request Python.'
    Assert-True ($task.args[$versionIndex + 1] -eq '${input:pythonVersion}') 'Python version input must be passed through.'
}
Assert-True ('projectName' -in $config.inputs.id -and 'pythonVersion' -in $config.inputs.id) 'Task inputs must be defined.'
Assert-True (-not (Get-Command $scriptPath).Parameters.ContainsKey('ProjectType')) 'The script must not expose project type selection.'
Write-Host 'PASS: one creation task, quoted names, and Python version input.'

$userFormScripts = @('Export-UserFormCsv.ps1', 'Import-UserFormCsv.ps1')
foreach ($scriptName in $userFormScripts) {
    $matchedTasks = @($config.tasks | Where-Object {
        @($_.args | Where-Object { $_ -like "*\$scriptName" }).Count -gt 0
    })
    Assert-True ($matchedTasks.Count -eq 1) "Expected one task for script: $scriptName"
    $task = $matchedTasks[0]
    Assert-True ($task.command -eq 'powershell.exe' -and '-STA' -in $task.args) 'UserForm tasks must use STA PowerShell.'
    $fileIndex = [Array]::IndexOf($task.args, '-File')
    Assert-True ($fileIndex -ge 0) 'UserForm tasks must specify a script path.'
    $relativePath = $task.args[$fileIndex + 1].Replace('${workspaceFolder}', $workspaceRoot)
    Assert-True (Test-Path -LiteralPath $relativePath -PathType Leaf) "Missing UserForm script: $relativePath"
    Assert-True ((Split-Path -Leaf $relativePath) -eq $scriptName) 'UserForm task points to the wrong script.'
    $tokens = $null
    $parseErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($relativePath, [ref]$tokens, [ref]$parseErrors)
    Assert-True (@($parseErrors).Count -eq 0) "PowerShell syntax errors in $scriptName"
}
Write-Host 'PASS: unique UserForm tasks point to existing STA scripts with valid PowerShell syntax.'

try {
    New-Item -ItemType Directory -Path (Join-Path $testRoot 'Projects') -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $workspaceRoot 'Projects\_Template_Combined') -Destination (Join-Path $testRoot 'Projects') -Recurse -Force
    & $scriptPath -ProjectName 'Combined Sample' -PythonVersion $PythonVersion -WorkspaceRoot $testRoot
    $project = Join-Path $testRoot 'Projects\Project Combined Sample'
    foreach ($entry in @('Pysource', 'VBsource', 'Sandbox\README.md', 'README.md', 'requirements.txt', '.git', '.vscode\settings.json')) {
        Assert-True (Test-Path -LiteralPath (Join-Path $project $entry)) "Missing: $entry"
    }
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $project '.venv'))) 'Combined project must not create a virtual environment.'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $project 'Pysource\.git'))) 'Python source must use the shared repository.'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $project 'VBsource\.git'))) 'VBA source must use the shared repository.'
    $settings = Get-Content -LiteralPath (Join-Path $project '.vscode\settings.json') -Raw | ConvertFrom-Json
    Assert-True (Test-Path -LiteralPath $settings.'python.defaultInterpreterPath' -PathType Leaf) 'Configured Python must exist.'
    & $settings.'python.defaultInterpreterPath' -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)'
    Assert-True ($LASTEXITCODE -eq 0) 'Configured Python must run.'
    $staged = @(& git -C $project diff --cached --name-only)
    Assert-True ($LASTEXITCODE -eq 0) 'Cannot inspect staged files.'
    Assert-True ('Pysource/.gitkeep' -in $staged -and 'VBsource/.gitkeep' -in $staged) 'Both source directories must be staged.'
    & git -C $project check-ignore --quiet 'Example.xlsm'
    Assert-True ($LASTEXITCODE -eq 0) 'Excel workbooks must be ignored.'
    & git -C $project check-ignore --quiet 'VBsource/Example/UserForm1.frx'
    Assert-True ($LASTEXITCODE -eq 1) 'UserForm resources must not be ignored.'
    $before = (Get-FileHash -LiteralPath (Join-Path $project 'README.md')).Hash
    $rejected = $false
    try {
        & $scriptPath -ProjectName 'Combined Sample' -PythonVersion $PythonVersion -WorkspaceRoot $testRoot
    } catch {
        if ($_.Exception.Message -notlike 'Project already exists;*') { throw }
        $rejected = $true
    }
    Assert-True $rejected 'An existing project must be rejected.'
    Assert-True ((Get-FileHash -LiteralPath (Join-Path $project 'README.md')).Hash -eq $before) 'Existing files must be preserved.'

    foreach ($projectType in @('Python', 'Excel')) {
        $rejected = $false
        try {
            & $scriptPath -ProjectName "Unsupported $projectType" -ProjectType $projectType -WorkspaceRoot $testRoot
        } catch [System.Management.Automation.ParameterBindingException] {
            if ($_.FullyQualifiedErrorId -notlike '*NamedParameterNotFound*') { throw }
            $rejected = $true
        }
        Assert-True $rejected "Standalone $projectType creation must be rejected."
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $testRoot "Projects\Project Unsupported $projectType"))) 'Rejected calls must not create files.'
    }
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $testRoot 'Python'))) 'Standalone Python output must not be created.'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $testRoot 'ExcelVBE'))) 'Standalone Excel output must not be created.'
    Write-Host 'PASS: VBA-Python structure, shared Git, system Python, ignore rules, overwrite protection, and standalone creation rejection.'
} finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}