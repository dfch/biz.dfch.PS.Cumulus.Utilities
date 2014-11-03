$fn = $MyInvocation.MyCommand.Name;

Set-Variable gotoSuccess -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoSuccess';
Set-Variable gotoError -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoError';
Set-Variable gotoFailure -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoFailure';
Set-Variable gotoNotFound -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoNotFound';

[string] $ModuleConfigFile = '{0}.xml' -f (Get-Item $PSCommandPath).BaseName;
[string] $ModuleConfigurationPathAndFile = Join-Path -Path $PSScriptRoot -ChildPath $ModuleConfigFile;
$mvar = $ModuleConfigFile.Replace('.xml', '').Replace('.', '_');
if($true -eq (Test-Path -Path $ModuleConfigurationPathAndFile)) {
	if($true -ne (Test-Path variable:$($mvar))) {
		Log-Debug $fn ("Loading module configuration file from: '{0}' ..." -f $ModuleConfigurationPathAndFile);
		Set-Variable -Name $mvar -Value (Import-Clixml -Path $ModuleConfigurationPathAndFile);
	} # if()
} # if()
if($true -ne (Test-Path variable:$($mvar))) {
	Write-Error "Could not find module configuration file '$ModuleConfigFile' in 'ENV:PSModulePath'.`nAborting module import...";
	break; # Aborts loading module.
} # if()
Export-ModuleMember -Variable $mvar;

(Get-Variable -Name $mvar).Value.Credential = [System.Net.CredentialCache]::DefaultCredentials;

<#
2014-10-13; rrink; CHG: module variable is now loaded via PSD1 PrivateData
2014-10-13; rrink; CHG: module is now defined via PSD1 and loads assembly via PSD1
2014-08-17; rrink; CHG: rename ls to svc
2014-08-17; rrink; ADD: Remove-File.
2014-08-17; rrink; CHG: Remove-KeyNameValue: changed internal var name to better reflect its purpose
2014-08-17; rrink; ADD: Set-File.
2014-08-17; rrink; CHG: Enter-Server now handles BaseUrl without trailing '/'.
2014-08-17; rrink; ADD: Get-File.
2014-08-16; rrink; ADD: Remove-KeyNameValue.
2014-08-16; rrink; ADD: Set-KeyNameValue.
2014-08-16; rrink; CHG: Set-HealthCheck: change parameter CreateOrUpdate to CreateIfNotExist
2014-08-16; rrink; ADD: Get-KeyNameValue.
2014-08-16; rrink; CHG: CumulusWrapper assembly loader can now load assembly from module path (when only file name is specified)
2014-08-16; rrink; CHG: Left over code from vCAC module in finally/cleanup (Remove-VcacBackupContext)
2014-08-16; rrink; CHG: Object name CumulusWrapper.Utilities.Container to CumulusWrapper.Utilities.Utilities
2014-08-11; rrink; ADD: Set-HealthCheck.
2014-08-10; rrink; ADD: Get-HealthCheck.
2014-08-10; rrink; ADD: Get-Credential.
2014-08-10; rrink; ADD: Enter-Server
2014-08-10; rrink; ADD: Initial version.
#>
