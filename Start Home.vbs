' Starts Home.ps1 without a black console window flashing up.

' If you need to hard code the location of the files, say to C:\Home, uncomment the following line and comment out the "same folder" lines, listed below
'CreateObject("Wscript.Shell").Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\Home\Home.ps1""", 0, False

' if you want to store the files in the same folder and not hardcode the location in this file, uncomment the lines below and comment out the hard coded location line above
Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName)
CreateObject("Wscript.Shell").Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & dir & "\Home.ps1""", 0, False
