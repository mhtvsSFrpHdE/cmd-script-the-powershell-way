# Set cmd script file location
# Either full path or relative path should work
# But put the variable out side the script, and change variable name if needed.
# $CSTPW_SCRIPT_FILE = "C:\demo.cmd"

# Other default values
$cstpw_scriptEncoding = "UTF8NoBOM"
$cstpw_envWindows = "Windows_NT"
# Error msg
$errMsg = "Err:"
$errMsg_MoreThanOneSwitch = "$errMsg Do not specify more than one script format."
$errMsg_UndocumentBehavior = "$errMsg Undocument behavior."
$errMsg_UnsupportPlatform = "$errMsg Can't run the type of script on this platform."

# Global variables
$cstpw_isCmd = $false
$cstpw_isBash = $false
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
    
    $CommandString | Add-Content -LiteralPath "$CSTPW_SCRIPT_FILE" -Encoding = $cstpw_scriptEncoding
}

# Grab system information
function Cstpw_Do_GrabSystemInfo {
    if($Env:OS -eq $cstpw_envWindows){
        $Script:cstpw_isWindows = $true

        # Now I have
        $Script:cstpw_haveSysInfo = $true
    }
    else{
        # Now I have
        $Script:cstpw_haveSysInfo = $true
    }
}

# Grab script information
function Cstpw_Do_GrapScriptInfo {
    param (
        $Bash = $false,
        $Cmd = $false
    )
    
    # Read script format from argument
    if ($Bash){
        $Script:cstpw_isBash = $true
        ++$Script:cstpw_switchCount
    }
    if ($Cmd){
        $Script:cstpw_isCmd = $true
        ++$Script:cstpw_switchCount
    }
    # If no argument provided, try to match system
    if ( !($Bash -or $Cmd) ){
        if($cstpw_isWindows){
            $Script:cstpw_isCmd = $true;
            ++$Script:cstpw_switchCount
        }
    }
    # If all auto match failed, fallback to default format(cmd)
    if($cstpw_switchCount -eq 0){
        $Script:cstpw_isCmd = $true;
    }
    # Check undocument behavior
    if ($cstpw_switchCount -gt 1){
        $Script:cstpw_ubDetected = $true

        Write-Error $errMsg_MoreThanOneSwitch
        Write-Error $errMsg_UndocumentBehavior
        
        return
    }

    # Now I have
    $Script:cstpw_haveScriptInfo = $true
}
    }
    }

}
# Append content to the UTF-8 script
function Cstpw_WriteScript {
    param (
        $CommandString
    )
    
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