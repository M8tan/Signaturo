Powershell Script Signature Generator
Program to digitally sign ps1
run Installer.exe as administrator
go to c:\PSSG and run Signaturo.exe {or type signaturo in the run command, if u ran CopyToRunCommand.cmd as admin}.
enter the path to the script that u want to digitally sign and the name of the script {without extension}, choose extension then press Sign.
hopefully it will create the pfx and cer files required to run the script {and also back them up, in c:\PSSG}

4 example:
the file location is c:\Projects\Cleaner\DailyCleaner.ps1
enter:
Path - c:\Projects\Cleaner
Name - DailyCleaner
Extension - .ps1
and done!
notice - it is case sensitive