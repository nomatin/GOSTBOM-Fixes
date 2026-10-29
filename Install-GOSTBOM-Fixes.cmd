@echo off
setlocal DisableDelayedExpansion
set "PSModulePath=%SystemRoot%\System32\WindowsPowerShell\v1.0\Modules;%PSModulePath%"
set "GOSTBOM_SELF=%~f0"
set "GOSTBOM_SOURCE=%~dp0"
set "GOSTBOM_TEMP=%TEMP%\GOSTBOM-installer-%RANDOM%-%RANDOM%"
if exist "%GOSTBOM_TEMP%" exit /b 1
mkdir "%GOSTBOM_TEMP%"
if errorlevel 1 exit /b 1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { $s=[IO.File]::ReadAllText($env:GOSTBOM_SELF); $marker='# GOSTBOM_'+'POWERSHELL_START'; $i=$s.IndexOf($marker); if($i -lt 0){throw 'Installer marker missing'}; [IO.File]::WriteAllText((Join-Path $env:GOSTBOM_TEMP 'install.ps1'),$s.Substring($i+$marker.Length),[Text.UTF8Encoding]::new($true)); foreach($name in @('GOSTBOM2.dll','Vedomost.dll','GostBomNoPcb.dll')){Copy-Item -LiteralPath (Join-Path $env:GOSTBOM_SOURCE $name) -Destination $env:GOSTBOM_TEMP}; exit 0 } catch { Write-Host $_; exit 1 }"
if errorlevel 1 (
    set "result=1"
    goto cleanup
)
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%GOSTBOM_TEMP%\install.ps1" %*
set "result=%errorlevel%"
:cleanup
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "foreach($name in @('install.ps1','GOSTBOM2.dll','Vedomost.dll','GostBomNoPcb.dll')){ $p=Join-Path $env:GOSTBOM_TEMP $name; if(Test-Path -LiteralPath $p){Remove-Item -LiteralPath $p -Force} }; Remove-Item -LiteralPath $env:GOSTBOM_TEMP"
endlocal & exit /b %result%
# GOSTBOM_POWERSHELL_START
#Requires -Version 5.1
<#
Installs the tested GOST BOM fixes without downloading software.
Russian instructions are supplied in README.md. Keep this file intact.
#>
[CmdletBinding()]
param(
    [string]$ExtensionPath,
    [switch]$CheckOnly,
    [string]$RestoreFrom,
    [switch]$Quiet,
    [switch]$SkipElevation,
    [string]$ResultFile
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$Package = @'
{"Version":"2026.10.29.1","Files":[{"Name":"GostBomNoPcb.dll","FinalHash":"005D229130DFBBC5BF25375589544312B6D3D1483DEDE77546BC5A3CA300A617","AcceptedHashes":["ABSENT","005D229130DFBBC5BF25375589544312B6D3D1483DEDE77546BC5A3CA300A617","0EEED36904B3077FFD269D2D9AE37D21BFEC6D984671DBD7DFDFFC36E94AD6D8","0094704356E460F9793CE69857F4BDC5856A5619D2EE3FEBB193D701DDBF3779","AF5BB0BEA43D3918144BD2DE1067B26C7C5CF87E47DDFB479274BD92A665C875"]},{"Name":"GOSTBOM2.dll","FinalHash":"75AF179AC3A92F9109C6D9241A375AACD126D4B5FDA1C6ED9C1602E7A7F0BB29","AcceptedHashes":["8112E11420E56B5084BA6C16E17ECA0C790BC077AF28C3DF364473BDD5B6B5AE","BB6573040FA499A01EFD33A91538618136962D9D4438EB40D5E65038A25BFDF8","9F9384197A66945838B2A62246AF84528128FDD49E5CD41C514FC72FC0625F4E","16FAF740DE9CC0D71CE6DBB47C0CB2766D9CBDE3687BC7EEA99FFB20B164DF7A","5B82D0300185CCC90CD30C161D4373A4D4F3915B73B1624A99D9FFBAB7506385","49F7E92CA5377ACCECD96BD4D1C9B0C8C097A0D008AFDCD7FB563381E1BAD1F2","75AF179AC3A92F9109C6D9241A375AACD126D4B5FDA1C6ED9C1602E7A7F0BB29"]},{"Name":"Vedomost.dll","FinalHash":"CFDD08F7B94D14C1044548666CDFDC3104EA91A759421E5EE1D67DC3384A691D","AcceptedHashes":["86FDC2EC9405A20B021E751C62A6BBF4C74B3A5FA610DB851CD8E47C88226951","9DDCEBBE1E61B57C5FC41B58C40D2AB60D1CC85F0C95AA6F0C10B12BA2D224B6","CFDD08F7B94D14C1044548666CDFDC3104EA91A759421E5EE1D67DC3384A691D"]}],"Dependencies":[{"Name":"Constants.dll","SHA256":"93A6EB451CDBC1989A3BBDCE9513C45E84AF88692C7AFE4BE9CAA8CED059432C"},{"Name":"FileWriter.dll","SHA256":"0067EC2CC003E5EB596B11988031C82DD40B4134DECEAA553C3A694718736958"},{"Name":"Notes.dll","SHA256":"F37B22835BA6B219C35DA28A0799E391D159C891732DF7CFCCB2A6EE2A1E044B"},{"Name":"NotesDefaultValues.dll","SHA256":"FE65CD337612636373122062B167D7D3087F276330A22ADCF095F0DF275F6E4B"},{"Name":"ProjectProperties.dll","SHA256":"67E11258E13639E85C7D42BBF677975827D96D54F6B7065801484725B0ECF204"},{"Name":"ReadXML.dll","SHA256":"FEEB9916975AB15617C4902E046B6FE3468517C4D3E492325146C03B77439630"},{"Name":"ResourceTemplate.dll","SHA256":"5A8B9375EACE9CAD04600ADC5BD6E6B9B788F247FD1527244C5A100C9B4003D1"},{"Name":"Section.dll","SHA256":"5C333BDA23B85C4E1B0B7BF81FF8D96BD84A65F7BEB6161AB33CF0A412A1A1B4"},{"Name":"SelectConfiguration.dll","SHA256":"C5774A7E079C8816E830AE8D74DC32E5C736F950121B1B94695392D68F140EDF"},{"Name":"WpfNotes.dll","SHA256":"7F36905DFA148B5F17853A0D2CEBF3A530CDB592CDA469B1A72D3093E6164BAB"},{"Name":"Altium.SDK.dll","SHA256":"9151CF30E377BB86D08CAA9C2834FF8E23C2A976D709509E85744BA8773B9263"},{"Name":"Altium.SDK.Interfaces.dll","SHA256":"1F976E27C5A428729E33F6220572EA9C65BD702161F1B3341745363DCC80326A"},{"Name":"NPOI.dll","SHA256":"F3E032AF32C27606A98936E3FCE29A99524267898707DE5A29520E64ADA9B8C4"}]}
'@ | ConvertFrom-Json

function Get-Sha256([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return 'ABSENT' }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Copy-FileState([string]$Source, [string]$Target) {
    if (Test-Path -LiteralPath $Source -PathType Leaf) { Copy-Item -LiteralPath $Source -Destination $Target -Force }
    elseif ([IO.Path]::GetFileName($Target) -eq 'GostBomNoPcb.dll') { if(Test-Path -LiteralPath $Target){Remove-Item -LiteralPath $Target -Force} }
    else { throw "Missing required backup file: $Source" }
}
function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-Compatibility([string]$Folder) {
    $issues = New-Object 'System.Collections.Generic.List[string]'
    $changed = $false
    foreach ($item in $Package.Files) {
        $path = Join-Path $Folder $item.Name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            if ('ABSENT' -in @($item.AcceptedHashes)) { $changed = $true; continue }
            $issues.Add("Missing file: $($item.Name)")
            continue
        }
        $hash = Get-Sha256 $path
        if ($hash -notin @($item.AcceptedHashes)) {
            $issues.Add("Unsupported version: $($item.Name), SHA256=$hash")
        }
        if ($hash -ne $item.FinalHash) { $changed = $true }
    }
    foreach ($item in $Package.Dependencies) {
        $path = Join-Path $Folder $item.Name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            $issues.Add("Missing dependency: $($item.Name)")
        } elseif ((Get-Sha256 $path) -ne $item.SHA256) {
            $issues.Add("Unsupported dependency version: $($item.Name)")
        }
    }
    return [pscustomobject]@{ Path=$Folder; Compatible=($issues.Count -eq 0); AlreadyInstalled=(-not $changed -and $issues.Count -eq 0); Issues=@($issues.ToArray()) }
}

function Resolve-ExtensionFolder {
    if ($ExtensionPath) {
        $folder = [IO.Path]::GetFullPath($ExtensionPath)
        if (-not (Test-Path -LiteralPath $folder -PathType Container)) { throw "Folder not found: $folder" }
        return $folder
    }
    $root = Join-Path $env:ProgramData 'Altium'
    $candidates = @()
    if (Test-Path -LiteralPath $root) {
        foreach ($installation in @(Get-ChildItem -LiteralPath $root -Directory)) {
            $folder = Join-Path $installation.FullName 'Extensions\GOST BOM'
            if (Test-Path -LiteralPath $folder -PathType Container) { $candidates += $folder }
        }
    }
    if ($candidates.Count -eq 0) { throw 'GOST BOM not found. Install the extension first, or specify -ExtensionPath.' }
    if ($candidates.Count -eq 1) { return $candidates[0] }
    $compatible = @($candidates | Where-Object { (Get-Compatibility $_).Compatible })
    if ($compatible.Count -eq 1) { return $compatible[0] }
    throw ('Several installations found. Specify -ExtensionPath. Candidates: ' + ($candidates -join '; '))
}

function Assert-AltiumClosed {
    if (@(Get-Process -Name X2,AltiumDesigner -ErrorAction SilentlyContinue).Count -gt 0) {
        throw 'Altium is running. Save the project, close Altium, and run the script again.'
    }
}

function Expand-Payload([object]$Item, [string]$Target) {
    $source = Join-Path $PSScriptRoot $Item.Name
    if ((Get-Sha256 $source) -ne $Item.FinalHash) { throw "Package DLL verification failed: $($Item.Name)" }
    Copy-Item -LiteralPath $source -Destination $Target
    if ((Get-Sha256 $Target) -ne $Item.FinalHash) { throw "Payload verification failed: $($Item.Name)" }
}

function Invoke-Restore([string]$Folder, [string]$BackupPath) {
    $backup = [IO.Path]::GetFullPath($BackupPath)
    $manifestPath = Join-Path $backup 'backup-manifest.json'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw 'Backup manifest not found.' }
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ([IO.Path]::GetFullPath($manifest.ExtensionPath).TrimEnd('\') -ine $Folder.TrimEnd('\')) {
        throw 'This backup belongs to another installation. No files were changed.'
    }
    $names = @($Package.Files | ForEach-Object { $_.Name })
    if (@($manifest.Files).Count -ne $names.Count -or @($manifest.Files | Where-Object { $_.Name -notin $names }).Count -gt 0 -or @($manifest.Files.Name | Select-Object -Unique).Count -ne $names.Count) {
        throw 'Unexpected backup file list.'
    }
    foreach ($item in $manifest.Files) {
        $source = Join-Path $backup $item.Name
        $definition = $Package.Files | Where-Object { $_.Name -eq $item.Name }
        if ((Get-Sha256 $source) -ne $item.SHA256 -or $item.SHA256 -notin @($definition.AcceptedHashes)) {
            throw "Backup validation failed: $($item.Name)"
        }
        $current = Join-Path $Folder $item.Name
        if ((Get-Sha256 $current) -notin @($definition.AcceptedHashes)) {
            throw "Current DLL is unknown; restore stopped: $($item.Name)"
        }
    }
    Assert-AltiumClosed
    $restoreSnapshot = Join-Path $backup ('before-restore-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $restoreSnapshot | Out-Null
    foreach ($item in $manifest.Files) { Copy-FileState (Join-Path $Folder $item.Name) (Join-Path $restoreSnapshot $item.Name) }
    try {
        foreach ($item in $manifest.Files) {
            Copy-FileState (Join-Path $backup $item.Name) (Join-Path $Folder $item.Name)
            if ((Get-Sha256 (Join-Path $Folder $item.Name)) -ne $item.SHA256) { throw "Restore verification failed: $($item.Name)" }
        }
    } catch {
        $restoreError = $_.Exception.Message
        $rollbackErrors = @()
        foreach ($item in $manifest.Files) {
            try {
                $snapshot = Join-Path $restoreSnapshot $item.Name
                $current = Join-Path $Folder $item.Name
                if ((Get-Sha256 $current) -ne (Get-Sha256 $snapshot)) { Copy-FileState $snapshot $current }
            } catch { $rollbackErrors += $_.Exception.Message }
        }
        throw ($restoreError + '; restore snapshot: ' + $restoreSnapshot + '; rollback errors: ' + ($rollbackErrors -join '; '))
    }
    return [pscustomobject]@{ Status='Restored'; Message='Previous DLLs restored.'; ExtensionPath=$Folder; BackupPath=$backup; BeforeRestoreSnapshot=$restoreSnapshot }
}

function Invoke-Install([string]$Folder) {
    $compatibility = Get-Compatibility $Folder
    if (-not $compatibility.Compatible) { throw ('Unsupported GOST BOM version. No files were changed. ' + ($compatibility.Issues -join '; ')) }
    if ($compatibility.AlreadyInstalled) {
        return [pscustomobject]@{ Status='AlreadyInstalled'; Message='All fixes are already installed. No changes needed.'; ExtensionPath=$Folder }
    }
    Assert-AltiumClosed
    $backup = Join-Path $Folder ('GOSTBOM-backups\' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0,8))
    $stage = Join-Path $backup 'new-files'
    New-Item -ItemType Directory -Path $stage -Force | Out-Null
    $backupFiles = @()
    foreach ($item in $Package.Files) {
        $source = Join-Path $Folder $item.Name
        $hash = Get-Sha256 $source
        Copy-FileState $source (Join-Path $backup $item.Name)
        if ((Get-Sha256 (Join-Path $backup $item.Name)) -ne $hash) { throw "Backup verification failed: $($item.Name)" }
        $backupFiles += [pscustomobject]@{ Name=$item.Name; SHA256=$hash }
        Expand-Payload $item (Join-Path $stage $item.Name)
    }
    [pscustomobject]@{ PackageVersion=$Package.Version; ExtensionPath=$Folder; CreatedUtc=[DateTime]::UtcNow.ToString('o'); Files=$backupFiles } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $backup 'backup-manifest.json') -Encoding UTF8
    # Recheck after staging, before replacing either DLL.
    $currentCompatibility = Get-Compatibility $Folder
    if (-not $currentCompatibility.Compatible) { throw 'Extension changed during staging. No DLLs were replaced.' }
    foreach ($item in $backupFiles) { if ((Get-Sha256 (Join-Path $Folder $item.Name)) -ne $item.SHA256) { throw 'DLL changed during staging. No DLLs were replaced.' } }
    Assert-AltiumClosed
    try {
        foreach ($item in $Package.Files) {
            Copy-Item -LiteralPath (Join-Path $stage $item.Name) -Destination (Join-Path $Folder $item.Name) -Force
            if ((Get-Sha256 (Join-Path $Folder $item.Name)) -ne $item.FinalHash) { throw "Installed file verification failed: $($item.Name)" }
        }
    } catch {
        $installError = $_.Exception.Message
        $rollbackErrors = @()
        foreach ($item in $backupFiles) {
            try {
                $current = Join-Path $Folder $item.Name
                if (-not (Test-Path -LiteralPath $current) -or (Get-Sha256 $current) -ne $item.SHA256) {
                    Copy-FileState (Join-Path $backup $item.Name) $current
                }
                if ((Get-Sha256 $current) -ne $item.SHA256) { throw "Rollback verification failed: $($item.Name)" }
            } catch { $rollbackErrors += $_.Exception.Message }
        }
        if ($rollbackErrors.Count) { throw ($installError + '; automatic rollback incomplete: ' + ($rollbackErrors -join '; ') + '; backup: ' + $backup) }
        throw ($installError + '; original DLLs restored automatically. Backup: ' + $backup)
    }
    return [pscustomobject]@{ Status='Installed'; Message='All GOST BOM fixes installed and verified. Open Project Properties, click OK / Apply and save the project.'; ExtensionPath=$Folder; BackupPath=$backup }
}

$exitCode = 0
try {
    $folder = Resolve-ExtensionFolder
    if ($CheckOnly) {
        $result = Get-Compatibility $folder
        if (-not $result.Compatible) { $exitCode = 2 }
    } elseif (-not $RestoreFrom -and -not (Get-Compatibility $folder).Compatible) {
        $compatibility = Get-Compatibility $folder
        throw ('Unsupported GOST BOM version. No files were changed. ' + ($compatibility.Issues -join '; '))
    } elseif (-not $RestoreFrom -and (Get-Compatibility $folder).AlreadyInstalled) {
        $result = [pscustomobject]@{ Status='AlreadyInstalled'; Message='All fixes are already installed. No changes needed.'; ExtensionPath=$folder }
    } elseif (-not $SkipElevation -and -not (Test-Administrator)) {
        $reportPath = Join-Path ([IO.Path]::GetTempPath()) ('GOSTBOM-install-' + [guid]::NewGuid().ToString('N') + '.json')
        $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $PSCommandPath + '" -ExtensionPath "' + $folder + '" -Quiet -SkipElevation -ResultFile "' + $reportPath + '"'
        if ($RestoreFrom) { $arguments += ' -RestoreFrom "' + [IO.Path]::GetFullPath($RestoreFrom) + '"' }
        $engine = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
        $child = Start-Process -FilePath $engine -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -Wait -PassThru
        if (Test-Path -LiteralPath $reportPath) { $result = Get-Content -LiteralPath $reportPath -Raw -Encoding UTF8 | ConvertFrom-Json }
        else { throw 'Elevated process did not return a result.' }
        $exitCode = $child.ExitCode
    } elseif ($RestoreFrom) {
        $result = Invoke-Restore $folder $RestoreFrom
    } else {
        $result = Invoke-Install $folder
    }
} catch {
    $exitCode = 1
    $result = [pscustomobject]@{ Status='Error'; Message=$_.Exception.Message }
}
if ($ResultFile) { $result | ConvertTo-Json -Depth 7 | Set-Content -LiteralPath $ResultFile -Encoding UTF8 }
$result | ConvertTo-Json -Depth 7
if (-not $Quiet) {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $message = if ($result.PSObject.Properties['Message']) { [string]$result.Message } else { $result | ConvertTo-Json -Depth 5 }
        if ($result.PSObject.Properties['BackupPath']) { $message += "`r`n`r`nBackup: " + $result.BackupPath }
        $icon = if ($exitCode -eq 0) { [Windows.Forms.MessageBoxIcon]::Information } else { [Windows.Forms.MessageBoxIcon]::Warning }
        [Windows.Forms.MessageBox]::Show($message,'GOST BOM fixes',[Windows.Forms.MessageBoxButtons]::OK,$icon) | Out-Null
    } catch { Write-Host 'Result is printed above.' }
}
exit $exitCode
