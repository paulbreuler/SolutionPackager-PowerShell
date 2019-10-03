# SolutionPackager-PowerShell
This project is a PowerShell wrapper for the SolutionPackager utility to make working with the utility easier.

## Usage

Change PowerShell directory to repository directory containing the module and import the module. Alternately pass the path to the import command.

```powershell
Import-Module .\SolutionPackagerWrapper.psm1
```

Check out the [Import-Module](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/import-module?view=powershell-6) article on [docs.microsoft.com](https://docs.microsoft.com/en-us/powershell/?view=powershell-6) for more information.

Review the help page of the new command

```powershell
Get-Help Invoke-SolutionPackager -Full
```


### Extract 

The solution zip file is decomposed into a logic folder and file structure that is emitted into the directory you specify in the folder argument.

```powershell
Invoke-SolutionPackager -action Extract -zipFile "C:\Users\$env:Username\Downloads\WebResources_0_0_1_3.zip" -folder C:\Users\$env:Username\Documents\Repositories\contoso-university\unpacked-solutions\WebResources 
```

```powershell
Invoke-SolutionPackager -action Extract -zipFile "C:\Users\$env:Username\Downloads\WebResources_0_0_1_3.zip" -folder C:\Users\$env:Username\Documents\Repositories\contoso-university\unpacked-solutions\WebResources -clobber -nologo
```

### Pack

```powershell
Invoke-SolutionPackager -action pack -zipFile "C:\Users\$env:Username\Desktop\WebResources_packed.zip" -folder C:\Users\$env:Username\Documents\Repositories\contoso-university\unpacked-solutions\WebResources -nologo
```
