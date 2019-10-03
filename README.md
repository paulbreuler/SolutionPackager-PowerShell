# SolutionPackager-PowerShell
This project is a PowerShell wrapper for the SolutionPackager utility to make working with the utility easier.

## Usage

Change PowerShell direcotry to repository directory containing the module and import the module. Alternately pass the path to the import command.

```powershell
Import-Module .\SolutionPackagerWrapper.psm1
```

Check out the [Import-Module](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/import-module?view=powershell-6) article on [docs.microsoft.com](https://docs.microsoft.com/en-us/powershell/?view=powershell-6) for more information.

Review the help page of the new command

```powershell
Get-Help Invoke-SolutionPackager -Full
```

Run the command

```powershell
Invoke-SolutionPackager -action Extract -zipFile "C:\Users\$env:Username\Downloads\WebResources_0_0_1_3.zip" -folder C:\Users\$env:Username\Documents\Repositories\contoso-university\unpacked-solutions\WebResources 
```

Note: If extracting (unpacking) a solution component folders and files are unpacked into the specified folder.