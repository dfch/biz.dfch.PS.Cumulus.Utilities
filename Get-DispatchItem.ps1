function Get-DispatchItem {
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = "Low"
	,
	HelpURI='http://dfch.biz/PS/Cumulus/Utilities/Get-DispatchItem/'
)]
PARAM (
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'id')]
	[int] $Id
	,
	[ValidateSet('RequestItem', 'Command')]
	[Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'id')]
	[string] $EntityName
	,
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'o')]
	$Entity
	,
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'uri')]
	[Uri] $Uri
	,
	[Parameter(Mandatory = $false)]
	[string] $Requester = $ENV:COMPUTERNAME
	,
	[Parameter(Mandatory = $false)]
	[Alias("Services")]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	[Parameter(Mandatory = $false)]
	[alias("ReturnFormat")]
	[string] $As = 'default'
) # Param

BEGIN {

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. Entity '{0}'. Id '{1}'." -f $Entity, $Id) -fac 1;

} # BEGIN
PROCESS {

# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;

try {

	# Parameter validation
	if($svc.ApplicationData -isnot [CumulusWrapper.ApplicationData.ApplicationData]) {
		$msg = "svc: Parameter validation FAILED. Connect to the server before using the Cmdlet.";
		$e = New-CustomErrorRecord -m $msg -cat InvalidData -o $svc.ApplicationData;
		throw($gotoError);
	} # if
	
	if($PSCmdlet.ParameterSetName.Equals('uri')) {
		$msg = "{0}: ParameterSetName validation FAILED. Unsupported parameter set." -f $PSCmdlet.ParameterSetName;
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat NotImplemented -o $PSCmdlet;
		throw($gotoError);
	} # if

	if($PSCmdlet.ParameterSetName.Equals('id')) {
		$msg = "{0}: ParameterSetName validation FAILED. Unsupported parameter set." -f $PSCmdlet.ParameterSetName;
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat NotImplemented -o $PSCmdlet;
		throw($gotoError);
	} # if

	[xml] $md = Invoke-RestMethod $svc.Utilities.GetMetadataUri() -UseDefaultCredentials;
	$jss = New-Object System.Web.Script.Serialization.JavaScriptSerializer;

	$Action = "Acquire";
	$mdAction = ($md.Edmx.DataServices.Schema |? Namespace -eq 'Default').EntityContainer.FunctionImport |? Name -eq $Action;
	$EntitySet = $mdAction.EntitySet;
	$ReturnType = $mdAction.ReturnType.Replace('LightSwitchApplication.Models', 'CumulusWrapper.Utilities');
	# $mdAction.Parameter |? Type -Match '^Edm\.';

	$Body = @{};
	$Body.Id = $Entity.Id;
	$Body.Entity = $Entity.GetType().Name;
	$Body.EntitySet = '{0}s' -f $Body.Entity;
	$Body.Requester = $Requester;
	$r = Invoke-RestMethod -Method POST -Uri ('{0}/{1}/{2}' -f $svc.Utilities.BaseUri.AbsoluteUri, $EntitySet, $Action) -UseDefaultCredentials -ContentType 'application/json' -Body (ConvertTo-Json -InputObject $Body);
	$dh = New-Object $ReturnType;
	$dh = $jss.Deserialize((ConvertTo-Json -InputObject $r), $dh.GetType());

	$r = $dh;
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
}
Export-ModuleMember -Function Get-DispatchItem

<#
2014-10-20; rrink; ADD: Get-DispatchItem.
#>
