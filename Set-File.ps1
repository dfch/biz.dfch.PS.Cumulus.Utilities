function Set-File {
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = "Medium"
	,
	HelpURI='http://dfch.biz/PS/Cumulus/Utilities/Set-File/'
	,
	DefaultParameterSetName = 'path'
)]
PARAM (
	[Parameter(Mandatory = $false, Position = 0)]
	[Alias("n")]
	[string] $Name = $Path.Name
	,
	[Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'value')]
	[AllowEmptyString()]
	[string] $Value
	,
	[ValidatePattern('^([a-f0-9]{2}-){31}[a-f0-9]{2}$')]
	[Parameter(Mandatory = $false, Position = 2, ParameterSetName = 'value')]
	[string] $Checksum
	,
	[ValidateScript( { Test-Path($_); } )]
	[Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'path')]
	[System.IO.FileInfo] $Path
	,
	[Parameter(Mandatory = $false, Position = 2)]
	[AllowEmptyString()]
	[string] $Description = [String]::Empty
	,
	[Parameter(Mandatory = $false)]
	[int] $Version = 0
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
	
	if($PSCmdlet.ParameterSetName -eq 'path') {
		$Value = Get-Content -Path $Path -Raw;
	} # if
	
	$r = $false
	if($PSCmdlet.ShouldProcess($Name)) {
		$file = New-Object CumulusWrapper.ApplicationData.File;
		$file.Name = $Name;
		$file.Description = $Description;
		$file.Value = $Value;
		$file.Version = $Version;
		if($Checksum) { $file.Checksum = $Checksum; }
		$svc.ApplicationData.AddToFiles($file);
		$svc.ApplicationData.UpdateObject($file);
		$r = $svc.ApplicationData.SaveChanges();
	} # if

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
if($MyInvocation.PSScriptRoot) { Export-ModuleMember -Function Set-File; } 

<#
2014-11-12; rrink; ADD: Checksum parameter. You can now optionally specify an empty Value and only a checksum
2014-11-12; rrink; ADD: DefaultParameterSetName is now path
2014-11-11; rrink; CHG: dot-sourcing, Export-ModuleMember now is only invoked when loaded via module
2014-10-13; rrink; CHG: module variable is now loaded via PSD1 PrivateData
2014-10-13; rrink; CHG: module is now defined via PSD1 and loads assembly via PSD1
2014-08-17; rrink; CHG: rename ls to svc
2014-08-17; rrink; ADD: Set-File.
#>
