function Get-KeyNameValue {
<#

.SYNOPSIS

Retrieves keyed name/value pairs from the Cumulus server.



.DESCRIPTION

Retrieves keyed name/value pairs from the Cumulus server.

The K/N/V store stores arbitrary data that can be selected by either key, name, value or a combination of both. Besides specifying a selection you can furthermore define the order, the selected columns and the return format.



.OUTPUTS

default | json | json-pretty | xml | xml-pretty



.INPUTS

You basically specify key, name and value to be retrieved. If one or more of these parameters are omitted all entities are returned that match these criteria.



.PARAMETER Key

Specifies the Key property of the entity. Most of the time this will be a specifier like 'cumulus.topic.subtopic'.



.PARAMETER Name

Specifies the Name property of the entity.



.PARAMETER Value

Specifies the Name property of the entity.



.PARAMETER OrderBy

Specifies the order of the returned entites. You can specify more than one property (e.g. Key and Name).



.EXAMPLE

Retrieves the first 5 entities from the entity set. Not specifing Key, Name or Value is the same as you would specify the 'ListAvailable' parameter.

Get-CumulusKeyNameValue | Select -First 5

Key                               Name              Value
---                               ----              -----
com.ebay.infrastructure.inventory ApplicationSystem Application Server
com.ebay.infrastructure.inventory ApplicationSystem Genesys
com.ebay.infrastructure.inventory ApplicationSystem Other
com.ebay.infrastructure.inventory ApplicationSystem Print Server
com.ebay.infrastructure.inventory ApplicationSystem Term Server


.EXAMPLE

Gets all entris with Key 'biz.dfch.infrastructure.inventory'.

Get-CumulusKeyNameValue biz.dfch.infrastructure.inventory

Key                               Name       Value
---                               ----       -----
biz.dfch.infrastructure.inventory ServerRole DEV
biz.dfch.infrastructure.inventory ServerRole INT
biz.dfch.infrastructure.inventory ServerRole PROD
biz.dfch.infrastructure.inventory ServerTier Tier 2
biz.dfch.infrastructure.inventory ServerTier Tier 3
biz.dfch.infrastructure.inventory ServerTier Tier 4
biz.dfch.infrastructure.inventory ServerTier Tier 5
biz.dfch.infrastructure.inventory ServerTier Unknown
biz.dfch.infrastructure.inventory Status     Deployed
biz.dfch.infrastructure.inventory Status     Disposed


.EXAMPLE

As previous example. Gets all entris with Key 'biz.dfch.infrastructure.inventory' but now also specifies Name 'ServerRole'.

Get-CumulusKeyNameValue biz.dfch.infrastructure.inventory

Key                               Name       Value
---                               ----       -----
biz.dfch.infrastructure.inventory ServerRole DEV
biz.dfch.infrastructure.inventory ServerRole INT
biz.dfch.infrastructure.inventory ServerRole PROD


.EXAMPLE

As previous example. Gets all entris with Key 'biz.dfch.infrastructure.inventory' but now also specifies Name 'ServerRole' and also specify return format as 'json-pretty'.

Get-CumulusKeyNameValue biz.dfch.infrastructure.inventory -As json-pretty

[
  {
    "Key":  "biz.dfch.infrastructure.inventory",
    "Name":  "ServerRole",
    "Value":  "DEV"
  },
  {
    "Key":  "biz.dfch.infrastructure.inventory",
    "Name":  "ServerRole",
    "Value":  "INT"
  },
  {
    "Key":  "biz.dfch.infrastructure.inventory",
    "Name":  "ServerRole",
    "Value":  "PROD"
  }
]


.EXAMPLE

Gets all entris with Key 'biz.dfch.infrastructure.inventory' and Name 'ServerTier' but only return the Value.

(Get-CumulusKeyNameValue biz.dfch.infrastructure.inventory ServerTier -Select Value).Value

Tier 2
Tier 3
Tier 4


.LINK

Online Version: http://dfch.biz/PS/Cumulus/Utilities/Get-KeyNameValue/




.NOTES

See module manifest for dependencies and further requirements.

#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = "Low"
	,
	HelpURI='http://dfch.biz/PS/Cumulus/Utilities/Get-KeyNameValue/'
	,
	DefaultParameterSetName = 'list'
)]
Param (
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'name')]
	[Alias("k")]
	[string] $Key
	,
	[Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'name')]
	[Alias("n")]
	[string] $Name
	,
	[Parameter(Mandatory = $false, Position = 2, ParameterSetName = 'name')]
	[Alias("v")]
	[string] $Value
	,
	[ValidateSet('Key', 'Name', 'Value')]
	[Parameter(Mandatory = $false, Position = 3)]
	[string[]] $OrderBy = @('Key','Name','Value')
	,
	[ValidateSet('Key', 'Name', 'Value')]
	[Parameter(Mandatory = $false, Position = 4)]
	[Alias("s")]
	[Alias("Return")]
	[string[]] $Select = @('Key','Name','Value')
	,
	# [Parameter(Mandatory = $false)]
	# [Alias("Desc")]
	# [Switch] $Descending = $false
	# ,
	[Parameter(Mandatory = $false)]
	[Alias("Services")]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[switch] $ListAvailable = $false
	,
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	[Parameter(Mandatory = $false)]
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
	if($svc.ApplicationData -isnot [CumulusWrapper.ApplicationData.ApplicationData]) {
		$msg = "svc: Parameter validation FAILED. Connect to the server before using the Cmdlet.";
		$e = New-CustomErrorRecord -m $msg -cat InvalidData -o $svc.ApplicationData;
		throw($gotoError);
	} # if

	$OrderBy = $OrderBy | Select -Unique;
	$OrderByString = [string]::Join(',', $OrderBy);
	$Select = $Select | Select -Unique;
	# if($Descending) {
		# $OrderByDirection = 'desc'; 
	# } else {
		# $OrderByDirection = 'asc'; 
	# } #if
	
	if($PSCmdlet.ParameterSetName -eq 'list') {
		# $OutputParameter = $svc.ApplicationData.KeyNameValues.AddQueryOption('$orderby', ('{0} {1}' -f $OrderByString, $OrderByDirection));
		$knv = $svc.ApplicationData.KeyNameValues.AddQueryOption('$orderby', $OrderByString) | Select -Property $Select -Unique;
	} else {
		$Exp = @();
		if($Key) { 
			$Key = $Key.ToLower();
			$Exp += ("(tolower(Key) eq '{0}')" -f $Key);
		} # if
		if($Name) { 
			$Key = $Name.ToLower();
			$Exp += ("(tolower(Name) eq '{0}')" -f $Name);
		} # if
		if($Value) { 
			$Value = $Value.ToLower();
			$Exp += ("(tolower(Value) eq '{0}')" -f $Value);
		} # if
		$FilterExpression = [String]::Join(' and ', $Exp);

		$knv = $svc.ApplicationData.KeyNameValues.AddQueryOption('$filter',$FilterExpression).AddQueryOption('$orderby', $OrderByString) | Select -Property $Select -Unique;
	} # if

	$r = $knv;
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
if($MyInvocation.PSScriptRoot) { Export-ModuleMember -Function Get-KeyNameValue; } 

<#
2014-11-13; rrink; ADD: Example help. See #1
2014-11-12; rrink; ADD: DefaultParameterSetName is now list. See #2
2014-11-11; rrink; CHG: dot-sourcing, Export-ModuleMember now is only invoked when loaded via module
2014-10-13; rrink; CHG: module variable is now loaded via PSD1 PrivateData
2014-10-13; rrink; CHG: module is now defined via PSD1 and loads assembly via PSD1
2014-08-17; rrink; CHG: rename ls to svc
2014-08-16; rrink; ADD: Get-KeyNameValue
2014-08-16; rrink; CHG: CumulusWrapper assembly loader can now load assembly from module path (when only file name is specified)
2014-08-16; rrink; CHG: Left over code from vCAC module in finally/cleanup (Remove-VcacBackupContext)
2014-08-16; rrink; CHG: Object name CumulusWrapper.Utilities.Container to CumulusWrapper.Utilities.Utilities
#>
