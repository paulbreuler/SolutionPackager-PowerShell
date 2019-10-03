<#
.Synopsis
   Tool that can reversibly decompose a Dynamics 365 Customer Engagement compressed solution file
.DESCRIPTION
   SolutionPackager is a tool that can reversibly decompose a Dynamics 365 Customer Engagement compressed solution file into multiple XML files and other files so that these files can be easily managed by a source control system. 
.EXAMPLE
   Solution-Packager -action Extract -zipFile "C:\Users\$env:Username\Downloads\WebResources_0_0_1_3.zip" -folder C:\Users\$env:Username\Documents\Repositories\contoso-university\unpacked-solutions\WebResources -packageType Unmanaged
#>
function Invoke-SolutionPackager {
  [CmdletBinding(DefaultParameterSetName = 'Packager Settings', 
    SupportsShouldProcess = $true, 
    PositionalBinding = $false,
    HelpUri = 'https://docs.microsoft.com/en-us/dynamics365/customerengagement/on-premises/developer/compress-extract-solution-file-solutionpackager',
    ConfirmImpact = 'Medium')]
  [Alias()]
  [OutputType([String])]
  Param
  (
    # {Extract|Pack} The action to perform. The action can be either to extract a solution .zip file to a folder, or to pack a folder into a .zip file.
    [Parameter(Mandatory = $true, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Extract", "Pack")]
    [Alias("a")] 
    [String]
    $action,

    # <file path>	The path and name of a solution .zip file. When extracting, the file must exist and will be read from. When packing, the file is replaced.
    [Parameter(Mandatory = $true, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [Alias("z")]
    [String] 
    $zipFile,

    # <folder path> The path to a folder. When extracting, this folder is created and populated with component files. When packing, this folder must already exist and contain previously extracted component files.
    [Parameter(Mandatory = $true, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [Alias("f")]
    [String] 
    $folder,

    # {Unmanaged|Managed|Both}	Optional. The type of package to process. The default value is Unmanaged. This argument may be omitted in most occasions because the package type can be read from inside the .zip file or component files. When extracting and Both is specified, managed and unmanaged solution .zip files must be present and are processed into a single folder. When packing and Both is specified, managed and unmanaged solution .zip files will be produced from one folder. For more information, see the section on working with managed and unmanaged solutions later in this topic.
    [Parameter(Mandatory = $false, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Unmanaged", "Managed", "Both")]
    [Alias("pt")]
    [String] 
    $packageType = "Unmanaged",

    # This argument is used only during an extraction. When /allowWrite:No is specified, the tool performs all operations but is prevented from writing or deleting any files. The extract operation can be safely assessed without overwriting or deleting any existing files.
    [Parameter(Mandatory = $false, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Yes", "No")]
    [String] 
    $allowWrite = "Yes",
    
    # This argument is used only during an extraction. When /allowDelete:Yes is specified, any files present in the folder specified by the /folder parameter that are not expected are automatically deleted. When /allowDelete:No is specified, no deletes will occur. When /allowDelete:Prompt is specified, the user is prompted through the console to allow or deny all delete operations. Note that if /allowWrite:No is specified, no deletes will occur even if /allowDelete:Yes is also specified.
    [Parameter(Mandatory = $false, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Yes", "No", "Prompt")]
    [String] 
    $allowDelete = "Prompt",

    # This argument is used only during an extraction. When /clobber is specified, files that have the read-only attribute set are overwritten or deleted. When not specified, files with the read-only attribute aren’t overwritten or deleted.
    [Parameter(Mandatory = $false, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [Alias("c")]
    [switch] 
    $clobber,
    
    # {Off|Error|Warning|Info|Verbose} The default value is Info. This argument indicates the level of logging information to output.
    [Parameter(Mandatory = $false, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Off", "Error", "Warning", "Info", "Verbose")]
    [String] 
    $errorlevel = "Info",

    # The path and name of an .xml file containing file mapping directives. When used during an extraction, files typically read from inside the folder specified by the /folder parameter are read from alternate locations as specified in the mapping file. During a pack operation, files that match the directives aren’t written.
    [Parameter(Mandatory = $false, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [String] 
    $map,

    # Suppress the banner at runtime.
    [Parameter(Mandatory = $false, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [switch] 
    $nologo,

    # A path and name to a log file. If the file already exists, new logging information is appended to the file.
    [Parameter(Mandatory = $false, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]  
    [String] 
    $log,

    # A path and name to a file that contains command-line arguments for the tool
    [Parameter(Mandatory = $false, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]  
    [String] 
    $argumentTemplate,

    # Extract or merge all string resources into .resx files. You can use the short form of the command: /loc.
    [Parameter(Mandatory = $false, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [Alias("loc")]
    [switch] 
    $localize
  )

  Begin {
  }
  Process {
    if ($pscmdlet.ShouldProcess("Target", "Operation")) {
                
      $argumentList = New-Object System.Collections.ArrayList
      $cmdName = $MyInvocation.InvocationName
      $paramList = (Get-Command -Name $cmdName).Parameters

      # Compile arguments for solution packager
      foreach ( $key in $paramList.Keys ) {
        
        $value = (Get-Variable $key -ErrorAction SilentlyContinue).Value

        if ( $value -or $value -eq 0 ) { 
          
          # Handle input edge cases 
          switch ($key) {
            { @("clobber", "nologo", "localize") -contains $_ } {
              [void]$argumentList.Add("/$($key)"); #Cast to void to silence output
              break;
            }
            default {
              [void]$argumentList.Add("/$($key): $value"); #Cast to void to silence output
              break;
            }
          }
          
        }
      }

      if (-not (Test-Path $env:APPDATA\D365-Tools\CoreTools\SolutionPackager.exe)) {
        Install-CoreTools
      }

      $processInfo = New-Object System.Diagnostics.ProcessStartInfo
      $processInfo.FileName = "$env:APPDATA\D365-Tools\CoreTools\SolutionPackager.exe" # TODO parameterize 
      $processInfo.RedirectStandardError = $true
      $processInfo.RedirectStandardOutput = $true
      $processInfo.UseShellExecute = $false
      $processInfo.Arguments = $argumentList
      $process = New-Object System.Diagnostics.Process
      $process.StartInfo = $processInfo
      $process.Start() | Out-Null
      $process.WaitForExit()
      $stdout = $process.StandardOutput.ReadToEnd()
      $stderr = $process.StandardError.ReadToEnd()
      
      # Actually throw an error instead of passing error output to stdout
      switch ($process.ExitCode) {
        "1" {
          Write-Error "Stdout: $stdout"
          Write-Error "Stderr: $stderr"
          break;
        }
        default {
          Write-Host "Stdout: $stdout"
          break;
        }
      }
      
      Write-Host "exit code: " + $process.ExitCode
    
    }
  }
  End {
  }
}


<#
.Synopsis
   Install core tools for use by module
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Install-Nuget {
  Write-Verbose "Installing Nuget"
  $sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
  $targetNugetExe = "$env:AppData\nuget.exe"
  Remove-Item $env:AppData\D365-Tools -Force -Recurse -ErrorAction Ignore
  Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe
  Set-Alias nuget $targetNugetExe -Scope Global -Verbose
}

function Install-CoreTools {

  $isAlias = Get-Alias nuget*
  if ($isAlias.count -lt 1) {
    Write-Verbose "Nuget is not installed."

    $promptReturn = Show-Prompt("Nugget is required to install core tools.", "Install Nuget to your AppData directory?")

    if ($promptReturn) {
      Install-Nuget
    }
  }

  # TODO Allow force install to clean install
  if (-not (Test-Path $env:APPDATA\D365-Tools\CoreTools\SolutionPackager.exe)) {
    $promptReturn = Show-Prompt("SolutionPackager was not found at $env:APPDATA\D365-Tools\CoreTools\", "Install now?")
    Write-Host "Installing Core Tools from Nuget"
    ##
    ##Download CoreTools
    ##
    nuget install  Microsoft.CrmSdk.CoreTools -O $env:APPDATA\D365-Tools
    mkdir $env:APPDATA\D365-Tools\CoreTools
    $coreToolsFolder = Get-ChildItem $env:APPDATA\D365-Tools | Where-Object { $_.Name -match 'Microsoft.CrmSdk.CoreTools.' }
    Move-Item $env:APPDATA\D365-Tools\$coreToolsFolder\content\bin\coretools\*.* $env:APPDATA\D365-Tools\CoreTools
    Remove-Item $env:AppData\D365-Tools\$coreToolsFolder -Force -Recurse
  }
  else {
    Write-Host "Skipping core tools installation. Already exists."
  }
}

function Show-Prompt ($title, $message) {
    
  $_title = $title
  $_message = $message

  $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "This means Yes"
  $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "This means No"

  $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

  $result = $host.ui.PromptForChoice($_title, $_message, $Options, 0)

  Switch ($result) {
    0 { return $true }
    1 { return $false }
  }
}


Export-ModuleMember -Function Invoke-SolutionPackager
Export-ModuleMember -Function Install-Nuget
Export-ModuleMember -Function Install-CoreTools