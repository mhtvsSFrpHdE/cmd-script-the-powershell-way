﻿# Set cmd script file location
# Either full path or relative path should work
# But put the variable out side the script, and change variable name if needed.
# $CSTPW_SCRIPT_FILE = "C:\demo.cmd"

# Other default values
$cstpw_isCmd = $false
$cstpw_isBash = $false
$cstpw_switchCount = 0
$cstpw_scriptEncoding = "UTF8NoBOM"

$errMsg = "Err:"
$errMsg_MoreThanOneSwitch = "$errMsg Do not specify more than one script format."

# Create empty file
function Cstpw_DoCreateEmptyFile {
    # Create a empty file
    New-Item -Path "$CSTPW_SCRIPT_FILE" -ItemType File -Force | Out-Null
}

# Initialize script
function Cstpw_DoInitializeScript {
    param (
        $CommandString
    )
    
    $CommandString | Out-File -LiteralPath "$CSTPW_SCRIPT_FILE" -Encoding $cstpw_scriptEncoding
}

# Add command to script
function Cstpw_DoAddCommand {
    param (
        $CommandString
    )
    
    $CommandString | Add-Content -LiteralPath "$CSTPW_SCRIPT_FILE" -Encoding = $cstpw_scriptEncoding
}

# Create a empty cmd script file by using argument
function Cstpw_CreateScript {
    param(
        [switch] $Bash = $false,
        [switch] $Cmd = $false,
        $Encoding = $cstpw_scriptEncoding
    )

    # Read argument
    if ($Bash){
        $Script:cstpw_isBash = $true
        ++$Script:cstpw_switchCount
    }
    if ($Cmd){
        $Script:cstpw_isCmd = $true
        ++$Script:cstpw_switchCount
    }

    # Check argument error
    if ($cstpw_switchCount -gt 1){
        Write-Error $errMsg_MoreThanOneSwitch
        exit 1
    }
    elseif($cstpw_switchCount -eq 0){
        $Script:cstpw_isCmd = $true;
    }

    # Create script by format
    if($cstpw_isCmd){
        Cstpw_DoCreateEmptyFile
        # This meanless line to trigger a common type error
        # But it can let cmd.exe ignore the unsupported UTF-8 "BOM"
        #TODO I guess actually BOM is not necessary to handle Windows cmd script?
        #Cstpw_DoInitializeScript -FirstLine "gUsJAzrtybEx >nul 2>nul"
    }
    elseif($cstpw_isBash){
        Cstpw_DoCreateEmptyFile
        # bin bash...
        Cstpw_DoInitializeScript -FirstLine "#!/bin/bash"
    }

}
# Append content to the UTF-8 script
function Cstpw_WriteScript {
    param (
        $CommandString
    )
    
    Cstpw_DoAddCommand -CommandString $CommandString
}
# Run this script
# The $Wait switch enable the Start-Process -Wait behavior
function Cstpw_RunScript {
    param (
        [switch] $Wait
    )
    
    if ($Wait){
        Start-Process -FilePath "$CSTPW_SCRIPT_FILE" -Wait
    }
    else {
        Start-Process -FilePath "$CSTPW_SCRIPT_FILE"
    }
}