function Get-Credential {
<#

.SYNOPSIS

Gets a ManagementCredential from a Cumulus Server.



.DESCRIPTION

Gets a ManagementCredential from a Cumulus Server.

Retrieves a ManagementCredential and decrypts the password if the caller has the 'ManagementCredentialHelperCanRead' permission.



.OUTPUTS

default | json | json-pretty | xml | xml-pretty | PSCredential | Clear



.INPUTS

You can either specify a name of a ManagementCredential or a complete ManagementCredential entity.



.PARAMETER Name

The name of the ManagementCredential entity.



.PARAMETER ManagementCredential

A ManagementCredential you have retrieved by returning entities from the ApplicationData.ManagementCredentials entity set.



.EXAMPLE

List all available ManagementCredential. Same as if you specified '-ListAvailable'.

Get-CumulusCredential

CumulusAdmin
CumulusDatabase
CumulusService
CumulusWorker01
Test-HealthCheck


.EXAMPLE

Get a ManagementCredential and return it as the native object.

$mc = Get-CumulusCredential Test-HealthCheck
$mc.GetType()

IsPublic IsSerial Name                       BaseType
-------- -------- ----                       --------
True     False    ManagementCredentialHelper System.Object

$mc

Id          : 4005
Name        : Test-HealthCheck
Description : Test-HealthCheck
Username    : Test-HealthCheck
Password    : Test-HealthCheck
Created     : 8/10/2014 8:11:31 PM
CreatedBy   : SERVER1\Administrator
Modified    : 8/10/2014 8:11:31 PM
ModifiedBy  : SERVER1\Administrator


.EXAMPLE

Get a ManagementCredential and return it as a PSCredential object.

$cred = Get-CumulusCredential Test-HealthCheck -As PSCredential
$cred.GetType()

IsPublic IsSerial Name         BaseType
-------- -------- ----         --------
True     True     PSCredential System.Object


.EXAMPLE

Get a ManagementCredential and return it as a json pretty-printed string.

Get-CumulusCredential Test-HealthCheck -As json-pretty
{
  "Id":  4005,
  "Name":  "Test-HealthCheck",
  "Description":  "Test-HealthCheck",
  "Username":  "Test-HealthCheck",
  "Password":  "Test-HealthCheck",
  "Created":  "\/Date(1407694291744)\/",
  "CreatedBy":  "SERVER1\\Administrator",
  "Modified":  "\/Date(1407694291744)\/",
  "ModifiedBy":  "SERVER1\\Administrator"
}


.LINK

Online Version: http://dfch.biz/biz/dfch/PS/Cumulus/Utilities/Get-Credential/




.NOTES

See module manifest for dependencies and further requirements.

.HELPURI

#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = "Low"
	,
	DefaultParameterSetName="list"
	,
	HelpURI='http://dfch.biz/biz/dfch/PS/Cumulus/Utilities/Get-Credential/'
)]
Param (
	[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'name')]
	[string] $Name
	,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'o')]
	[CumulusWrapper.ApplicationData.ManagementCredential] $ManagementCredential
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'scrambled')]
	[alias("Password")]
	[string] $ScrambledPassword
	,
	[Parameter(Mandatory = $false)]
	[alias("Services")]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[alias("Registered")]
	[switch] $ListAvailable = $false
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'o')]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[alias("Decrypt")]
	[switch] $UnScramble = $false
	,
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty', 'PSCredential', 'Clear')]
	[Parameter(Mandatory = $false, ParameterSetName = 'o')]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'scrambled')]
	[alias("ReturnFormat")]
	[string] $As = 'default'
) # Param

BEGIN {

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. MgmtContext '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;

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

	if($PSCmdlet.ParameterSetName -eq 'list') {
		# $null = $svc.ApplicationData.ManagementCredentials.AddQueryOption('$top',1);
		# $OutputParameter = $svc.ApplicationData.ManagementCredentials.AddQueryOption('$orderby', 'Name').AddQueryOption('$select','Name').Name;
		$OutputParameter = $svc.ApplicationData.ManagementCredentials.AddQueryOption('$orderby', 'Name').Name;
		$fReturn = $true;
		throw($gotoSuccess);
	} # if

	if($PSCmdlet.ParameterSetName -eq 'name') {
		# Load credentials of management endpoint
		$mc = $svc.Utilities.ManagementCredentialHelpers.AddQueryOption('$filter',("Name eq '{0}'" -f $Name)).AddQueryOption('$top',1) | Select;
		if(!$mc) {
			$msg = "Name: Parameter validation FAILED: '{0}'" -f $Name;
			$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
			throw($gotoError);
		} # if
	} elseif($PSCmdlet.ParameterSetName -eq 'o') {
		$mc = $svc.Utilities.ManagementCredentialHelpers.AddQueryOption('$filter',("Id eq {0}" -f $ManagementCredential.Id)) | Select;
		if(!$mc) {
			$msg = "Id: Parameter validation FAILED: '{0}'" -f $ManagementCredential.Id;
			$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $mc;
			throw($gotoError);
		} # if
	} else {
		$msg = "ParameterSetName: Not implemented: '{0}'" -f $PSCmdlet.ParameterSetName;
		$e = New-CustomErrorRecord -m $msg -cat NotImplemented -o $PSCmdlet;
		throw($gotoError);
	} # if/else

	$r = $mc;
	switch($As) {
	'xml' { $OutputParameter = (ConvertTo-Xml -InputObject $r).OuterXml; }
	'xml-pretty' { $OutputParameter = Format-Xml -String (ConvertTo-Xml -InputObject $r).OuterXml; }
	'json' { $OutputParameter = ConvertTo-Json -InputObject $r -Compress; }
	'json-pretty' { $OutputParameter = ConvertTo-Json -InputObject $r; }
	'PSCredential' { $Cred = New-Object System.Management.Automation.PSCredential($r.Username, (ConvertTo-SecureString -String $r.Password -AsPlainText -Force)); $OutputParameter = $Cred; }
	'Clear' { $OutputParameter = @{'UserName' = $r.UserName; 'Password' = $r.Password; }}
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

} # Get-Credential
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-Credential; } 

<#
2014-11-14; rrink; ADD: .HELPURI in inline help to fix HelpURI attribute in CmdletBinding
2014-11-13; rrink; ADD: ValueFromPipeline for Name and ManagementCredential.
2014-11-13; rrink; ADD: Example help. See #1
2014-11-11; rrink; CHG: dot-sourcing, Export-ModuleMember now is only invoked when loaded via module
2014-10-27; rrink; CHG: fix handling of ScrambledPassword ParameterSetName (NotImplemented)
2014-10-27; rrink; ADD: set DefaultParameterSetName to "list"
2014-10-13; rrink; CHG: module variable is now loaded via PSD1 PrivateData
2014-10-13; rrink; CHG: module is now defined via PSD1 and loads assembly via PSD1
2014-08-17; rrink; CHG: rename ls to svc
2014-08-10; rrink; ADD: Get-Credential.
#>
