<#
.Synopsis
   Tool that can reversibly decompose a Dynamics 365 Customer Engagement compressed solution file
.DESCRIPTION
   SolutionPackager is a tool that can reversibly decompose a Dynamics 365 Customer Engagement compressed solution file into multiple XML files and other files so that these files can be easily managed by a source control system. 
.EXAMPLE
   Solution-Packager -action Extract -zipFile "C:\Users\$env:Username\Downloads\WebResources_0_0_1_3.zip" -folder C:\Users\$env:Username\Documents\Repositories\contoso-university\unpacked-solutions\WebResources -packageType Unmanaged
.INPUTS
    /action: {Extract|Pack}	Required. The action to perform. The action can be either to extract a solution .zip file to a folder, or to pack a folder into a .zip file.
    /zipfile: <file path>	Required. The path and name of a solution .zip file. When extracting, the file must exist and will be read from. When packing, the file is replaced.
    /folder: <folder path>	Required. The path to a folder. When extracting, this folder is created and populated with component files. When packing, this folder must already exist and contain previously extracted component files.
    /packagetype: {Unmanaged|Managed|Both}	Optional. The type of package to process. The default value is Unmanaged. This argument may be omitted in most occasions because the package type can be read from inside the .zip file or component files. When extracting and Both is specified, managed and unmanaged solution .zip files must be present and are processed into a single folder. When packing and Both is specified, managed and unmanaged solution .zip files will be produced from one folder. For more information, see the section on working with managed and unmanaged solutions later in this topic.
#>
function Solution-Packager {
  [CmdletBinding(DefaultParameterSetName = 'Packager Settings', 
    SupportsShouldProcess = $true, 
    PositionalBinding = $false,
    HelpUri = 'https://docs.microsoft.com/en-us/dynamics365/customerengagement/on-premises/developer/compress-extract-solution-file-solutionpackager',
    ConfirmImpact = 'Medium')]
  [Alias()]
  [OutputType([String])]
  Param
  (
    # Param1 help description
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

    [Parameter(Mandatory = $false, 
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true, 
      ValueFromRemainingArguments = $false, 
      ParameterSetName = 'Packager Settings')]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Unmanaged", "Managed", "Both")]
    [Alias("c")] 
    $clobber
  
  )

  Begin {
  }
  Process {
    if ($pscmdlet.ShouldProcess("Target", "Operation")) {

      $processInfo = New-Object System.Diagnostics.ProcessStartInfo
      $processInfo.FileName = "C:\Users\$env:UserName\Desktop\Tools\CoreTools\SolutionPackager.exe" # TODO parameterize 
      $processInfo.RedirectStandardError = $true
      $processInfo.RedirectStandardOutput = $true
      $processInfo.UseShellExecute = $false
      $processInfo.Arguments = `
        "/action: $action", `
        "/zipfile: $zipFile", `
        "/folder: $folder", `
        "/packagetype: $packageType" 
      $process = New-Object System.Diagnostics.Process
      $process.StartInfo = $processInfo
      $process.Start() | Out-Null
      $process.WaitForExit()
      $stdout = $process.StandardOutput.ReadToEnd()
      $stderr = $process.StandardError.ReadToEnd()
      
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
