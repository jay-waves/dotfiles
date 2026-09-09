# using utf-8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# diable auto-update detect 
[Environment]::SetEnvironmentVariable( 'POWERSHELL_UPDATECHECK', 'Off', 'User')


# auto completion
$completionDir = Join-Path (Split-Path -Parent $PROFILE) 'Completions'

if (Test-Path $completionDir) {
    Get-ChildItem -Path $completionDir -Filter *.ps1 |
    ForEach-Object {
        . $_.FullName
    }
}


Import-Module CompletionPredictor

# PSReadLine
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -Colors @{
    InlinePrediction = "`e[38;2;100;100;110;3m"
}


$env:VISUAL = 'nvim'
$env:EDITOR = 'nvim'
$env:PAGER = 'bat --pager=builtin'
$env:SHELL = 'pwsh'

function OnViModeChange {
    param($mode)

    if ($mode -eq 'Command') {
        Write-Host -NoNewline "`e[2 q" # steady block
    }
    else {
        Write-Host -NoNewline "`e[0 q" # terminal default
    }
}
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange

Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# prompt
function prompt {

    $ok = $?
    $exitCode = $LASTEXITCODE
    $time = Get-Date -Format "HH:mm:ss"

    $checkIcon = [char]::ConvertFromUtf32(0xe63f)
    $errorIcon = [char]::ConvertFromUtf32(0xf071)

    $gitBranch = git symbolic-ref --quiet --short HEAD 2>$null
    $gitResult = $LASTEXITCODE

    Write-Host ""
    Write-Host ("─" * 80) -ForegroundColor DarkGray

    Write-Host " $time" -ForegroundColor DarkGray -NoNewline

    if ($ok) {
        Write-Host " $checkIcon" -ForegroundColor Green -NoNewline
    } else {
        Write-Host " $errorIcon($exitCode)" -ForegroundColor Red -NoNewline
    }

    Write-Host ""

    Write-Host " $(Get-Location)" -ForegroundColor Blue -NoNewline

	if ($gitResult -eq 0) {
        Write-Host "   $gitBranch" -ForegroundColor DarkYellow -NoNewline
    }

    return "`n ❯❯ "
}


# zoxide
Invoke-Expression (& {
    zoxide init powershell | Out-String
})


# alias
Remove-Alias `
    ls,cat,cp,mv,rm,curl,wget,sort,tee,where,clear,man `
    -Force `
    -ErrorAction SilentlyContinue

# Powershell Development Environment for VS2022
# $vsDevShellModule = "C:\Program Files\Microsoft Visual Studio\18\Insiders\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
# Import-Module -Name $vsDevShellModule -ErrorAction Stop

#Enter-VsDevShell -VsInstanceId 69a2bc64 `
#                -SkipAutomaticLocation `
#                -DevCmdArguments "-arch=x64 -host_arch=x64"


