function Enter-Server {
<#

.SYNOPSIS

Performs a login to a Cumulus server.



.DESCRIPTION

Performs a login to a Cumulus server.

For more information about Cmdlets see 'about_Functions_CmdletBindingAttribute'.



.OUTPUTS

This Cmdlet returns a WebRequestSession parameter. On failure the string contains $null.

For more information about output parameters see 'help about_Functions_OutputTypeAttribute'.



.INPUTS

See PARAMETER section for a description of input parameters.

For more information about input parameters see 'help about_Functions_Advanced_Parameters'.



.PARAMETER Uri

URI of the Cumulus server.



.PARAMETER Credential

Encrypted credentials as [System.Management.Automation.PSCredential] with which to perform login.



.EXAMPLE

Perform a login to a Cumulus server with username and plaintext password.

Enter-ServerDeprecated -Uri 'https://promo.ds01.swisscom.com' -Username 'PeterLustig' -Password 'S0nnensch3!n'



.EXAMPLE

Perform a login to a Cumulus server with username and encrypted password.

Enter-ServerDeprecated -Uri 'https://promo.ds01.swisscom.com' -Credentials [PSCredentials]



.LINK

Online Version: http://dfch.biz/PS/Cumulus/Utilities/Enter-Server/

Exit-Cumulus



.NOTES

Requires Powershell v3.

Requires module 'biz.dfch.PS.System.Logging'.

#>
[CmdletBinding(
	HelpURI='http://dfch.biz/PS/Cumulus/Utilities/Enter-Server/'
)]
[OutputType([hashtable])]
Param (
	[Parameter(Mandatory = $false, Position = 0)]
	[Uri] $ServerBaseUri = $biz_dfch_PS_Cumulus_Utilities.ServerBaseUri
	, 
	[Parameter(Mandatory = $false, Position = 1)]
	[string] $BaseUrl = $biz_dfch_PS_Cumulus_Utilities.BaseUrl
	, 
	[Parameter(Mandatory = $false, Position = 2)]
	[alias("cred")]
	$Credential = $biz_dfch_PS_Cumulus_Utilities.Credential
) # Param
BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug $fn ("CALL. ServerBaseUri '{0}'; BaseUrl '{1}'. Username '{2}'" -f $ServerBaseUri, $BaseUrl, $Credential.Username ) -fac 1;
}
PROCESS {

[boolean] $fReturn = $false;

try {
	# Parameter validation
	# N/A
	
	[Uri] $Uri = '{0}{1}' -f $ServerBaseUri.AbsoluteUri.TrimEnd('/'), ('{0}/' -f $BaseUrl.TrimEnd('/'));
	foreach($k in $biz_dfch_PS_Cumulus_Utilities.Controllers.Keys) { 
		[Uri] $UriService = '{0}{1}' -f $Uri.AbsoluteUri, $biz_dfch_PS_Cumulus_Utilities.Controllers.$k;
		Log-Debug $fn ("Creating service '{0}': '{1}' ..." -f $k, $UriService.AbsoluteUri);
		switch($k) {
		'Utilities' {
			$o = New-Object CumulusWrapper.Utilities.Utilities($UriService.AbsoluteUri);
			$o.Credentials = $Credential;
			if($biz_dfch_PS_Cumulus_Utilities.Format -eq 'JSON') { $o.Format.UseJson(); }
			$biz_dfch_PS_Cumulus_Utilities.Services.$k = $o;
		}
		'ApplicationData' {
			$o = New-Object CumulusWrapper.ApplicationData.ApplicationData($UriService.AbsoluteUri);
			$o.Credentials = $Credential;
			if($biz_dfch_PS_Cumulus_Utilities.Format -eq 'JSON') { $o.Format.UseJson(); }
			$biz_dfch_PS_Cumulus_Utilities.Services.$k = $o;
		}
		'SecurityData' {
			$o = New-Object CumulusWrapper.SecurityData.SecurityData($UriService.AbsoluteUri);
			$o.Credentials = $Credential;
			if($biz_dfch_PS_Cumulus_Utilities.Format -eq 'JSON') { $o.Format.UseJson(); }
			$biz_dfch_PS_Cumulus_Utilities.Services.$k = $o;
		}
		default {
			Log-Error $fn ("Unknown service '{0}': '{1}'. Skipping ..." -f $k, $UriService.AbsoluteUri);
		}
		} # switch
	} # foreach

	$OutputParameter = $biz_dfch_PS_Cumulus_Utilities.Services;
	$fReturn = $true;

} # try
catch {
	if($gotoSuccess -eq $_.Exception.Message) {
			$fReturn = $true;
	} else {
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) {
			Log-Critical $fn "Login to Uri '$Uri' with Username '$Username' FAILED [$_].";
			Log-Debug $fn $ErrorText -fac 3;
		} # [System.Net.WebException]
		else {
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) {
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} elseif($gotoFailure -ne $_.Exception.Message) { 
				Write-Verbose ("$fn`n$ErrorText"); 
			} else {
				# N/A
			} # if
		} # other exceptions
		$fReturn = $false;
		$OutputParameter = $null;
	} # !$gotoSuccess
} # catch
finally {
	# Clean up
	# N/A
} # finally
return $OutputParameter;

} # PROCESS
END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg "RET. fReturn: [$fReturn]. Execution time: [$(($datEnd - $datBegin).TotalMilliseconds)]ms. Started: [$($datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz'))]." -fac 2;
} # END
} # function
Set-Alias -Name Connect- -Value 'Enter-Server';
Set-Alias -Name Enter- -Value 'Enter-Server';
Export-ModuleMember -Function Enter-Server -Alias Connect-, Enter-;

<#
2014-10-13; rrink; CHG: module variable is now loaded via PSD1 PrivateData
2014-10-13; rrink; CHG: module is now defined via PSD1 and loads assembly via PSD1
2014-08-17; rrink; CHG: rename ls to svc
2014-08-17; rrink; CHG: Enter-Server now handles BaseUrl without trailing '/'.
2014-08-16; rrink; CHG: CumulusWrapper assembly loader can now load assembly from module path (when only file name is specified)
2014-08-16; rrink; CHG: Left over code from vCAC module in finally/cleanup (Remove-VcacBackupContext)
2014-08-16; rrink; CHG: Object name CumulusWrapper.Utilities.Container to CumulusWrapper.Utilities.Utilities
2014-08-10; rrink; ADD: Enter-Server
2014-08-10; rrink; ADD: Initial version.
#>
