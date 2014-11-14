function Get-File {
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = "Low"
	,
	HelpURI='http://dfch.biz/biz/dfch/PSCumulus/Utilities/Get-File/'
	,
	DefaultParameterSetName = 'list'
)]
PARAM (
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'name')]
	[Alias("n")]
	[string] $Name
	,
	[Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'name')]
	[int] $Version
	,
	[Parameter(Mandatory = $false, Position = 2, ParameterSetName = 'name')]
	[string] $CreatedBy
	,
	[Parameter(Mandatory = $false, Position = 3, ParameterSetName = 'name')]
	[string] $ModifiedBy
	,
	[ValidateSet('Name', 'Version', 'Description', 'Value', 'Checksum')]
	[Parameter(Mandatory = $false, Position = 4, ParameterSetName = 'name')]
	[Alias("s")]
	[Alias("Return")]
	[string[]] $Select = @()
	,
	[Parameter(Mandatory = $false)]
	[Alias("Services")]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[switch] $ListAvailable = $false
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Alias("a")]
	[switch] $AllVersions = $false
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[switch] $ExactName = $true
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
	
	if($PSCmdlet.ParameterSetName -eq 'list') {
		# $File = $svc.ApplicationData.Files.AddQueryOption('$orderby','Name asc,Version asc,Modified asc').AddQueryOption('$select','Name, Version, Modified, Checksum') | Select Name, Version, Modified, Checksum -Unique;
		$File = $svc.ApplicationData.Files.AddQueryOption('$orderby','Name asc,Version asc,Modified asc') | Select Name, Version, Modified, Checksum -Unique;
	} else {
		$Exp = @();
		if($Name) { 
			if($ExactName) {
				$Exp += ("(tolower(Name) eq '{0}')" -f $Name.ToLower());
			} else {
				$Exp += ("(substringof('{0}', tolower(Name)) eq true)" -f $Name.ToLower());
			} # if
		} # if
		if($Version) { 
			$Exp += ("(Version eq {0})" -f $Version);
		} # if
		if($CreatedBy) { 
			$Exp += ("(substringof('{0}', tolower(CreatedBy)) eq true)" -f $CreatedBy.ToLower());
		} # if
		if($ModifiedBy) { 
			$Exp += ("(substringof('{0}', tolower(ModifiedBy)) eq true)" -f $ModifiedBy.ToLower());
		} # if
		$FilterExpression = [String]::Join(' and ', $Exp);
	
		if($Select) {
			$Select = $Select | Select -Unique;
			$SelectString = [String]::Join(',',$Select);
		} # if
		if($AllVersions) {
			if($Select) {
				# $File = $svc.ApplicationData.Files.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby','Version desc,Modified desc').AddQueryOption('$select', $SelectString) | Select -Property $Select;
				$File = $svc.ApplicationData.Files.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby','Version desc,Modified desc') | Select -Property $Select;
			} else {
			$File = $svc.ApplicationData.Files.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby','Version desc,Modified desc') | Select;
			} # if
		} else {
			if($Select) {
				# $File = $svc.ApplicationData.Files.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby','Version desc,Modified desc').AddQueryOption('$top',1).AddQueryOption('$select', $SelectString) | Select -Property $Select;
				$File = $svc.ApplicationData.Files.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby','Version desc,Modified desc').AddQueryOption('$top',1) | Select -Property $Select;
			} else {
				$File = $svc.ApplicationData.Files.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby','Version desc,Modified desc').AddQueryOption('$top',1) | Select;
			} # if
		} # if
	} # if

	$r = $File;
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
if($MyInvocation.PSScriptRoot) { Export-ModuleMember -Function Get-File; } 

<#
2014-11-12; rrink; CHG: ListAvailable is now default parameter set. removed '$select' clause from query option as this breaks the WCF Data Service
2014-11-11; rrink; CHG: dot-sourcing, Export-ModuleMember now is only invoked when loaded via module
2014-10-13; rrink; CHG: module variable is now loaded via PSD1 PrivateData
2014-10-13; rrink; CHG: module is now defined via PSD1 and loads assembly via PSD1
2014-08-17; rrink; CHG: rename ls to svc
2014-08-17; rrink; ADD: Get-File.
#>
