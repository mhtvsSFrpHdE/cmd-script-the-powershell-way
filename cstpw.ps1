# Set cmd script file location
# Either full path or relative path should work
# But put the variable out side the script, and change variable name if needed.
# $CMD_SCRIPT_FILE = "C:\demo.cmd"

# Create a empty cmd script file by using UTF-8 format hack
function CreateCmdScript {
    # Create a empty file
    New-Item -Path "$CMD_SCRIPT_FILE" -ItemType File -Force | Out-Null
    # This meanless line to trigger a common type error
    # But it can let cmd.exe ignore the unsupported UTF-8 "BOM"
    "gUsJAzrtybEx >nul 2>nul" | Out-File -LiteralPath "$CMD_SCRIPT_FILE" -Encoding UTF8
}
# Append content to the UTF-8 script
function WriteCmdScript {
    param (
        $string
    )
    
    $string | Add-Content -LiteralPath "$CMD_SCRIPT_FILE" -Encoding UTF8
}
# Run this script
# The $Wait switch enable the Start-Process -Wait behavior
function RunCmdScript {
    param (
        [switch] $Wait
    )
    
    if ($Wait){
        Start-Process -FilePath "$CMD_SCRIPT_FILE" -Wait
    }
    else {
        Start-Process -FilePath "$CMD_SCRIPT_FILE"
    }
}