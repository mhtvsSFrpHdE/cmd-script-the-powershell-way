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

# Double grab with check
function Cstpw_Do_GrabAllInfo {
    if(!$cstpw_haveSysInfo){
        Cstpw_Do_GrabSystemInfo
    }
    if(!$cstpw_haveScriptInfo){
        Cstpw_Do_GrapScriptInfo
    }

    if($cstpw_haveSysInfo -and $cstpw_haveScriptInfo){
        return
    }
    else{
        $Script:cstpw_ubDetected = $true;
        Write-Error $errMsg_UndocumentBehavior

        return
    }
}


# namespace Cstpw
function Cstpw_CreateScript {
    param(
        [switch] $Bash = $false,
        [switch] $Cmd = $false,
        $Encoding = $cstpw_scriptEncoding
    )

    # Argument fallback, if user specidifed value
    $Script:cstpw_scriptEncoding = $Encoding

    # Do I have sys and script info?
    Cstpw_Do_GrabAllInfo

    if (!$cstpw_ubDetected){
        # Fill script template by format
        if($cstpw_isCmd){
            Cstpw_Do_CreateEmptyFile
            # This meanless line to trigger a common type error
            # But it can let cmd.exe ignore the unsupported UTF-8 "BOM"
            #TODO I guess actually BOM is not necessary to handle Windows cmd script?
            #Cstpw_Do_InitializeScript -CommandString "gUsJAzrtybEx >nul 2>nul"
            #TODO Test `n work or not
            Cstpw_Do_InitializeScript -CommandString "cd /d %~dp0`nchcp 65001"
        }
        elseif($cstpw_isBash){
            Cstpw_Do_CreateEmptyFile
            # bin bash...
            Cstpw_Do_InitializeScript -CommandString "#!/bin/bash"
        }
    }
    else{
        Write-Error $errMsg_UndocumentBehavior

        return
    }
}
# Append content to the UTF-8 script
function Cstpw_WriteScript {
    param (
        $CommandString
    )
    
    if (!$cstpw_ubDetected){
        Cstpw_Do_AddCommand -CommandString $CommandString
    }
    else{
        Write-Error $errMsg_UndocumentBehavior

        return
    }
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