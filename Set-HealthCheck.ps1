function Set-HealthCheck {

[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = "Low"
	,
	HelpURI='http://dfch.biz/biz/dfch/PSCumulus/Utilities/Set-HealthCheck/'
)]
Param (
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'name')]
	[alias("Id")]
	[alias("Key")]
	[string] $Name
	,
	[Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'name')]
	[string] $Description
	,
	[ValidateSet('OK', 'FAILED', 'DEGRADED', 'INIT')]
	[Parameter(Mandatory = $true, Position = 2, ParameterSetName = 'name')]
	[string] $Status
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[alias("DateTime")]
	[DateTime] $TimeStamp = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ss.ffffffzzz')
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[switch] $Active = $true
	,
	# [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'o')]
	# [alias("hc")]
	# [CumulusWrapper.Utilities.HealthCheck] $InputObject
	# ,
	[Parameter(Mandatory = $false)]
	[switch] $CreateIfNotExist = $false
	,
	[Parameter(Mandatory = $false)]
	[alias("Services")]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'o')]
	[alias("ReturnFormat")]
	[string] $As = 'default'
) # Param

BEGIN {

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. ls '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;

} # BEGIN
PROCESS {

# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;

try {

	# Parameter validation
	if($svc.Utilities -isnot [CumulusWrapper.Utilities.Utilities]) {
		$msg = "svc: Parameter validation FAILED. Connect to the server before using the Cmdlet.";
		$e = New-CustomErrorRecord -m $msg -cat InvalidData -o $svc.Utilities;
		throw($gotoError);
	} # if

	if($PSCmdlet.ParameterSetName -eq 'name') {
	} # if
	
	$hc = $svc.Utilities.HealthChecks.AddQueryOption('$filter',("Id eq '{0}'" -f $Name)).AddQueryOption('$top',1) | Select;
	If(!$CreateIfNotExist -And !$hc) {
		$msg = "Name: Parameter validation FAILED. Entity does not exist. Use '-CreateIfNotExist' to create resource: '{0}'" -f $Name;
		$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
	} # if
	if(!$hc) {
		$hc = New-Object CumulusWrapper.Utilities.HealthCheck;
		$svc.Utilities.AddToHealthChecks($hc);
	} else {
		if($hc.Id -ne $Name) {
			$msg = "Name: Entity already exists with different Id: '{0}'" -f $hc.Id;
			$e = New-CustomErrorRecord -m $msg -cat InvalidData -o $hc.Id;
			throw($gotoError);
		} # if
	} # if
	$hc.Id = $Name;
	$hc.Description = $Description;
	$hc.TimeStamp = $TimeStamp;
	$hc.Status = $Status;
	$hc.Active = $Active;
	$svc.Utilities.UpdateObject($hc);
	$r = $svc.Utilities.SaveChanges();
	
	# $r = $hc;
	switch($As) {
	'xml' { $OutputParameter = (ConvertTo-Xml -InputObject $r).OuterXml; }
	'xml-pretty' { $OutputParameter = Format-Xml -String (ConvertTo-Xml -InputObject $r).OuterXml; }
	'json' { $OutputParameter = ConvertTo-Json -InputObject $r -Compress; }
	'json-pretty' { $OutputParameter = ConvertTo-Json -InputObject $r; }
	Default { $OutputParameter = $r; }
	} # switch
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
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Status, $_);
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

} # PROCESS

END {

$datEnd = [datetime]::Now;
Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;

# Return values are always and only returned via OutputParameter.
return $OutputParameter;

} # END

} # Set-HealthCheck
if($MyInvocation.PSScriptRoot) { Export-ModuleMember -Function Set-HealthCheck; } 

<#
2014-11-11; rrink; CHG: dot-sourcing, Export-ModuleMember now is only invoked when loaded via module
2014-10-13; rrink; CHG: module variable is now loaded via PSD1 PrivateData
2014-10-13; rrink; CHG: module is now defined via PSD1 and loads assembly via PSD1
2014-08-17; rrink; CHG: rename ls to svc
2014-08-16; rrink; CHG: Set-HealthCheck: change parameter CreateOrUpdate to CreateIfNotExist
2014-08-11; rrink; ADD: Set-HealthCheck.
#>
