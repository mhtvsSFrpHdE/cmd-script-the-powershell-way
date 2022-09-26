# Set cmd script file location
# Either full path or relative path should work
# But put the variable out side the script, and change variable name if needed.
# $CSTPW_SCRIPT_FILE = "C:\demo.cmd"
# $global:CSTPW_SCRIPT_FILE = "C:\demo.cmd"

# Confirm powershell version
$cstpw_powershellVersion = $PSVersionTable.PSVersion.Major
$cstpw_isPs6 = $cstpw_powershellVersion -GT 5

# Other default values
$cstpw_scriptEncoding = "utf8"
If ($cstpw_isPs6) {
    $cstpw_scriptEncoding = "UTF8NoBom"
}
$cstpw_envWindows = "Windows_NT"
# Error msg
$cstpw_errMsg = "Err:"
$cstpw_errMsg_MoreThanOneSwitch = "$cstpw_errMsg Do not specify more than one script format."
$cstpw_errMsg_UndocumentBehavior = "$cstpw_errMsg Undocument behavior."
$cstpw_errMsg_UnsupportPlatform = "$cstpw_errMsg Can't run the type of script on this platform."

# Global variables
$cstpw_isCmd = $false
$cstpw_isBash = $false
$cstpw_isCustomTempate = $false
$cstpw_switchCount = 0
$cstpw_haveSysInfo = $false
$cstpw_haveScriptInfo = $false
$cstpw_isWindows = $false
$cstpw_ubDetected = $false



# namespace Cstpw.Do

# CreateEmptyFile add a new file to disk
function Cstpw_Do_CreateEmptyFile {
    # Create a empty file
    New-Item -Path "$CSTPW_SCRIPT_FILE" -ItemType File -Force | Out-Null
}

# InitializeScript fill the file with script template
function Cstpw_Do_InitializeScript {
    param (
        $CommandString
    )

    $CommandString | Out-File -LiteralPath "$CSTPW_SCRIPT_FILE" -Encoding $cstpw_scriptEncoding
}

# AddCommand add new command to script line by line
function Cstpw_Do_AddCommand {
    param (
        $CommandString
    )

    $CommandString | Add-Content -LiteralPath "$CSTPW_SCRIPT_FILE" -Encoding $cstpw_scriptEncoding
}

# Grab system information
function Cstpw_Do_GrabSystemInfo {
    if ($Env:OS -eq $cstpw_envWindows) {
        $script:cstpw_isWindows = $true

        # Now I have
        $script:cstpw_haveSysInfo = $true
    }
    else {
        # Now I have
        $script:cstpw_haveSysInfo = $true
    }
}

# Grab script information
function Cstpw_Do_GrapScriptInfo {
    param (
        $Bash = $false,
        $Cmd = $false,
        $CustomTemplate = $false
    )

    # Read script format from argument
    if ($Bash) {
        $script:cstpw_isBash = $true
        ++$script:cstpw_switchCount
    }
    if ($Cmd) {
        $script:cstpw_isCmd = $true
        ++$script:cstpw_switchCount
    }
    if ($CustomTemplate -ne $false) {
        $script:cstpw_isCustomTempate = $CustomTemplate
        ++$script:cstpw_switchCount
    }
    # If no argument provided, try to match system
    # (All the three is false)
    if ( ($Bash -or $Cmd -or ($CustomTemplate -ne $false) ) -ne $true ) {
        if ($cstpw_isWindows) {
            $script:cstpw_isCmd = $true;
            ++$script:cstpw_switchCount
        }
    }
    # If all auto match failed, fallback to default format(cmd)
    if ($cstpw_switchCount -eq 0) {
        $script:cstpw_isCmd = $true;
    }
    # Check undocument behavior
    if ($cstpw_switchCount -gt 1) {
        $script:cstpw_ubDetected = $true

        Write-Error $cstpw_errMsg_UndocumentBehavior
        throw $cstpw_errMsg_MoreThanOneSwitch
    }

    # Now I have
    $script:cstpw_haveScriptInfo = $true
}

# Double grab with check
function Cstpw_Do_GrabAllInfo {
    param (
        $Bash = $false,
        $Cmd = $false,
        $CustomTemplate = $false
    )

    if (!$cstpw_haveSysInfo) {
        Cstpw_Do_GrabSystemInfo
    }
    if (!$cstpw_haveScriptInfo) {
        Cstpw_Do_GrapScriptInfo -Bash $Bash -Cmd $Cmd -CustomTemplate $CustomTemplate
    }

    # Error check
    if ( !($cstpw_haveSysInfo -and $cstpw_haveScriptInfo) ) {
        $script:cstpw_ubDetected = $true;
        throw $cstpw_errMsg_UndocumentBehavior
    }
}


# namespace Cstpw
function Cstpw_CreateScript {
    param(
        [switch] $Bash = $false,
        [switch] $Cmd = $false,
        $CustomTemplate = $false,
        $Encoding = $cstpw_scriptEncoding
    )

    # Argument fallback, if user specidifed value
    $script:cstpw_scriptEncoding = $Encoding

    # Do I have sys and script info?
    Cstpw_Do_GrabAllInfo -Bash $Bash -Cmd $Cmd -CustomTemplate $CustomTemplate

    if (!$cstpw_ubDetected) {
        Cstpw_Do_CreateEmptyFile
        # Fill script template by format
        if ($cstpw_isCustomTempate) {
            Cstpw_Do_InitializeScript -CommandString $cstpw_isCustomTempate
        }
        elseif ($cstpw_isCmd) {
            # You can use `n to divide a string into multiple line as template

            # This meanless line to trigger a common type error
            # But it can let cmd.exe ignore the unsupported UTF-8 "BOM"
            If ($cstpw_isPs6) {
                # Anti BOM statement is not necessary on powershell 6
                Cstpw_Do_InitializeScript -CommandString "cd /d %~dp0"
            }
            else {
                # Anti BOM statement
                Cstpw_Do_InitializeScript -CommandString "gUsJAzrtybEx >nul 2>nul"
                Cstpw_Do_AddCommand -CommandString "cd /d %~dp0"
            }
        }
        elseif ($cstpw_isBash) {
            # bin bash...
            Cstpw_Do_InitializeScript -CommandString "#!/bin/bash`ncd `"`$( dirname `"`$`{BASH_SOURCE`[0`]`}`" `)`""
        }
    }
    else {
        throw $cstpw_errMsg_UndocumentBehavior
    }
}
# Append content to the UTF-8 script
function Cstpw_WriteScript {
    param (
        $CommandString
    )

    if (!$cstpw_ubDetected) {
        Cstpw_Do_AddCommand -CommandString $CommandString
    }
    else {
        throw $cstpw_errMsg_UndocumentBehavior
    }
}

# Run this script
# The $Wait switch enable the Start-Process -Wait behavior
function Cstpw_RunScript {
    param (
        [switch] $Wait
    )

    # Do I have sys and script info?
    Cstpw_Do_GrabAllInfo

    if (!$cstpw_ubDetected) {
        # On Windows system, run cmd script
        if ($cstpw_isWindows -and $cstpw_isCmd) {
            if ($Wait) {
                Start-Process -FilePath "$CSTPW_SCRIPT_FILE" -Wait
            }
            else {
                Start-Process -FilePath "$CSTPW_SCRIPT_FILE"
            }
        }
        else {
            throw $cstpw_errMsg_UnsupportPlatform
        }
    }
    else {
        throw $cstpw_errMsg_UndocumentBehavior
    }
}