# cmd-script-the-powershell-way
**Contact**  
See https://github.com/mhtvsSFrpHdE/contact-me  

**What is this**  
In some rare ancient program case that will not run in powershell environment,  
but use iex have problems with argument pass and encoding.  
So this idea is use powershell to loop and condition, but cmd script to pass argument.  
There were still issue with how the script can run in new window, and wait for exit.  

**How to use**  
Now there're function provided:
```
CreateCmdScript:
    Create a empty file and save as UTF-8 BOM format,
    a preset script save path variable is required, see script for detail.
WriteCmdScript:
    Accept string as argument, put the string as a new line to this file.
RunCmdScript:
    A method to run a completed script.
    There is a "-Wait" switch to enable powershell Start-Process -Wait.
```
The often requirement is write a "chcp 65001" to make the script to work.  
Windows XP doesn't have a real UTF-8 shell so take care.  
Edit the script to change save format.

**TODO**  
```
Add a ```-UTF8BOM``` switch to CreateCmdScript and require explicit argument,
    or the library will throw exception.
    This design to force you to confirm if you want a UTF-8 or a ANSI script.
    The BOM is a legacy design that Windows notepad default UTF-8 format have a BOM.
    DO NOT use any UTF-8 related code while under ANSI script.
```
