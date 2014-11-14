function Set-KeyNameValue {
<#
.SYNOPSIS

Sets or creates a K/N/V entry in Cumulus.



.DESCRIPTION

Sets or creates a K/N/V entry in Cumulus.

By updating a K/N/V entry you can specify if you want to update the Key, Name, Value or any combination thereof.



.OUTPUTS

default | json | json-pretty | xml | xml-pretty | PSCredential | Clear

.EXAMPLE

Create a new K/N/V entry if it not exists.

Set-CumulusKeyNameValue myKey myName myValue -CreateIfNotExist

Id         : 3131
Key        : myKey
Name       : myName
Value      : myValue
CreatedBy  : SERVER1\Administrator
Created    : 11/13/2014 11:08:46 PM +00:00
ModifiedBy : SERVER1\Administrator
Modified   : 11/13/2014 11:08:46 PM +00:00
RowVersion : {0, 0, 0, 0...}


.EXAMPLE

Update an existing K/N/V with new key and new value.

Set-CumulusKeyNameValue myKey -NewKey myNewKey myName myValue -NewValue myNewValue

Id         : 3131
Key        : myNewKey
Name       : myName
Value      : myNewValue
CreatedBy  : SERVER1\Administrator
Created    : 11/13/2014 11:08:46 PM +00:00
ModifiedBy : SERVER1\Administrator
Modified   : 11/13/2014 11:08:46 PM +00:00
RowVersion : {0, 0, 0, 0...}


.EXAMPLE

Update an existing K/N/V with new key and new value. Return format is json with pretty-print.


Set-CumulusKeyNameValue myNewKey -NewKey myNewKey2 myName myNewValue -NewValue myNewValue2 -as json-pretty
{
  "Id":  3131,
  "Key":  "myNewKey2",
  "Name":  "myName",
  "Value":  "myNewValue2",
  "CreatedBy":  "SERVER1\\Administrator",
  "Created":  "\/Date(1415920126010)\/",
  "ModifiedBy":  "SERVER1\\Administrator",
  "Modified":  "\/Date(1415920126010)\/",
  "RowVersion":  [
	0,
	0,
	0,
	0,
	0,
	2,
	152,
	17
    ]
}

.LINK

Online Version: http://dfch.biz/PS/Cumulus/Utilities/Set-KeyNameValue/


.NOTES

See module manifest for dependencies and further requirements.

.HELPURI

#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = "Low"
	,
	HelpURI='http://dfch.biz/PS/Cumulus/Utilities/Set-KeyNameValue/'
)]
Param (
	[Parameter(Mandatory = $true, Position = 0)]
	[Alias("k")]
	[string] $Key
	,
	[Parameter(Mandatory = $false)]
	[string] $NewKey
	,
	[Parameter(Mandatory = $true, Position = 1)]
	[Alias("n")]
	[string] $Name
	,
	[Parameter(Mandatory = $false)]
	[string] $NewName
	,
	[Parameter(Mandatory = $true, Position = 2)]
	[Alias("v")]
	[string] $Value
	,
	[Parameter(Mandatory = $false)]
	[string] $NewValue
	,
	[Parameter(Mandatory = $false)]
	[Alias("c")]
	[switch] $CreateIfNotExist = $false
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
$AddedEntity = $null;

try {

	# Parameter validation
	if($svc.ApplicationData -isnot [CumulusWrapper.ApplicationData.ApplicationData]) {
		$msg = "svc: Parameter validation FAILED. Connect to the server before using the Cmdlet.";
		$e = New-CustomErrorRecord -m $msg -cat InvalidData -o $svc.ApplicationData;
		throw($gotoError);
	} # if

	$Exp = @();
	$KeyNameValueContents = @();
	if($Key) { 
		$Exp += ("(tolower(Key) eq '{0}')" -f $Key.ToLower());
		$KeyNameValueContents += $Key;
	} # if
	if($Name) { 
		$Exp += ("(tolower(Name) eq '{0}')" -f $Name.ToLower());
		$KeyNameValueContents += $Name;
	} # if
	if($Value) { 
		$Exp += ("(tolower(Value) eq '{0}')" -f $Value.ToLower());
		$KeyNameValueContents += $Value;
	} # if
	$FilterExpression = [String]::Join(' and ', $Exp);
	$KeyNameValueContentsString = [String]::Join(',', $KeyNameValueContents);

	$knv = $svc.ApplicationData.KeyNameValues.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top',1) | Select;
	If(!$CreateIfNotExist -And !$knv) {
		$msg = "Key/Name/Value: Parameter validation FAILED. Entity does not exist. Use '-CreateIfNotExist' to create resource: '{0}'" -f $KeyNameValueContentsString;
		$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
	} # if
	if(!$knv) {
		$knv = New-Object CumulusWrapper.ApplicationData.KeyNameValue;
		$knv.Key = $Key;
		$knv.Name = $Name;
		$knv.Value = $Value;
		$svc.ApplicationData.AddToKeyNameValues($knv);
		$AddedEntity = $knv;
	} # if
	if($NewKey) { $knv.Key = $NewKey; }
	if($NewName) { $knv.Name = $NewName; }
	if($NewValue) { $knv.Value = $NewValue; }
	$svc.ApplicationData.UpdateObject($knv);
	$r = $svc.ApplicationData.SaveChanges();

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
		
		if($AddedEntity) { $svc.ApplicationData.DeleteObject($AddedEntity); }

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
if($MyInvocation.PSScriptRoot) { Export-ModuleMember -Function Set-KeyNameValue; } 

<#
2014-11-14; rrink; ADD: .HELPURI in inline help to fix HelpURI attribute in CmdletBinding
2014-11-13; rrink; ADD: examples, see #1
2014-11-11; rrink; CHG: dot-sourcing, Export-ModuleMember now is only invoked when loaded via module
2014-10-13; rrink; CHG: module variable is now loaded via PSD1 PrivateData
2014-10-13; rrink; CHG: module is now defined via PSD1 and loads assembly via PSD1
2014-08-17; rrink; CHG: rename ls to svc
2014-08-16; rrink; ADD: Set-KeyNameValue.
#>
