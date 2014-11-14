function Set-File {
<#

.SYNOPSIS

Sets or updates a file in the Cumulus file repository.



.DESCRIPTION

Sets or updates a file in the Cumulus file repository. Set-File writes arbitrary data to the Cumulus file repository. You can either specify a path to a file to upload the contents of a file or a string value. Upon insert or update the Cumulus server calculates a checksum of the contents uploaded. You can also just specify a checksum without a value to only keep track of checksums (for larger external files). If an entry with the same name already exists in the file repository a new entry with an incremented version is automatically created.



.EXAMPLE

Creates or updates a file name 'myFile' with contents from path 'G:\Github\biz.dfch.PS.Cumulus.Utilities\Set-File.ps1'. Version is automatically incremented if file entity already exists.

$r = Set-CumulusFile myFile -Path G:\Github\biz.dfch.PS.Cumulus.Utilities\Set-File.ps1
$r.Descriptor.Entity

Id          : 7011
Name        : myFile
Version     : 2
Description :
Value       : [...]
Checksum    : 7E-3A-A8-31-E7-D9-E1-01-1E-7C-A3-3A-A5-29-6D-0C-6F-78-0B-2D-48-3A-75-D2-F9-EE-62-A8-E2-38-12-1D
CreatedBy   : SERVER1\Edgar.Schnittenfittich
Created     : 11/12/2014 8:33:25 AM +00:00
ModifiedBy  : SERVER1\Edgar.Schnittenfittich
Modified    : 11/12/2014 8:33:25 AM +00:00
RowVersion  : {0, 0, 0, 0...}

POST http://cumulus/ApplicationData.svc/Files HTTP/1.1
DataServiceVersion: 3.0;NetFx
MaxDataServiceVersion: 3.0;NetFx
Content-Type: application/json;odata=minimalmetadata
Accept: application/json;odata=minimalmetadata
Accept-Charset: UTF-8
User-Agent: Microsoft ADO.NET Data Services
Host: cumulus
Content-Length: 6570
Expect: 100-continue

{
	"odata.type": "LightSwitchApplication.File",
	"Checksum": null,
	"Created": null,
	"CreatedBy": null,
	"Description": "",
	"Id": 0,
	"Modified": null,
	"ModifiedBy": null,
	"Name": "myFile",
	"RowVersion": null,
	"Value": "[...]",
	"Version": 0
}

.EXAMPLE

Creates or updates a file name 'myFile' with contents value string ("Hello, world`r`n"). Version is automatically incremented if file entity already exists.

$r = Set-CumulusFile myFile -Value 'Write-Host "Hello, world`r`n"'
$r.Descriptor.Entity


Id          : 7012
Name        : myFile
Version     : 3
Description :
Value       : Write-Host "Hello, world`r`n"
Checksum    : A0-36-A8-C1-8E-8D-E3-14-28-A0-8A-D5-68-6E-E6-2C-C0-45-FC-4C-CE-4D-CE-30-F1-36-96-BC-04-90-A1-09
CreatedBy   : SERVER1\Edgar.Schnittenfittich
Created     : 11/12/2014 8:34:22 AM +00:00
ModifiedBy  : SERVER1\Edgar.Schnittenfittich
Modified    : 11/12/2014 8:34:22 AM +00:00
RowVersion  : {0, 0, 0, 0...}

POST http://cumulus/ApplicationData.svc/Files HTTP/1.1
DataServiceVersion: 3.0;NetFx
MaxDataServiceVersion: 3.0;NetFx
Content-Type: application/json;odata=minimalmetadata
Accept: application/json;odata=minimalmetadata
Accept-Charset: UTF-8
User-Agent: Microsoft ADO.NET Data Services
Host: cumulus
Content-Length: 238
Expect: 100-continue

{
	"odata.type": "LightSwitchApplication.File",
	"Checksum": null,
	"Created": null,
	"CreatedBy": null,
	"Description": "",
	"Id": 0,
	"Modified": null,
	"ModifiedBy": null,
	"Name": "myFile",
	"RowVersion": null,
	"Value": "Write-Host \"Hello, world`r`n\"","Version":0
}


.EXAMPLE

Creates or updates a file name 'myLargeIsoFile' with no contents but specify a checksum instead. Version is automatically incremented if file entity already exists.

$r = Set-CumulusFile myLargeIsoFile -Description "Actual file is at \\CORPORATE\Share1\myLargeIso.iso" -Checksum 7E-3A-A8-31-E7-D9-E1-01-1E-7C-A3-3A-A5-29-6D-0C-6F-78-0B-2D-48-3A-75-D2-F9-EE-62-A8-E2-38-12-1D
$r.Descriptor.Entity


Id          : 7013
Name        : myLargeIsoFile
Version     : 0
Description : Actual file is at \\CORPORATE\Share1\myLargeIso.iso
Value       :
Checksum    : 7E-3A-A8-31-E7-D9-E1-01-1E-7C-A3-3A-A5-29-6D-0C-6F-78-0B-2D-48-3A-75-D2-F9-EE-62-A8-E2-38-12-1D
CreatedBy   : SERVER1\Edgar.Schnittenfittich
Created     : 11/12/2014 8:35:48 AM +00:00
ModifiedBy  : SERVER1\Edgar.Schnittenfittich
Modified    : 11/12/2014 8:35:48 AM +00:00
RowVersion  : {0, 0, 0, 0...}

POST http://cumulus/ApplicationData.svc/Files HTTP/1.1
DataServiceVersion: 3.0;NetFx
MaxDataServiceVersion: 3.0;NetFx
Content-Type: application/json;odata=minimalmetadata
Accept: application/json;odata=minimalmetadata
Accept-Charset: UTF-8
User-Agent: Microsoft ADO.NET Data Services
Host: cumulus
Content-Length: 363
Expect: 100-continue

{
	"odata.type": "LightSwitchApplication.File",
	"Checksum": "7E-3A-A8-31-E7-D9-E1-01-1E-7C-A3-3A-A5-29-6D-0C-6F-78-0B-2D-48-3A-75-D2-F9-EE-62-A8-E2-38-12-1D",
	"Created": null,
	"CreatedBy": null,
	"Description": "Actual file is at \\\\CORPORATE\\Share1\\myLargeIso.iso",
	"Id": 0,
	"Modified": null,
	"ModifiedBy": null,
	"Name": "myLargeIsoFile",
	"RowVersion": null,
	"Value": "",
	"Version": 0
}



.LINK

Online Version: http://dfch.biz/PS/Cumulus/Utilities/Set-File/



.NOTES

See module manifest for required software versions and dependencies at: http://dfch.biz/PS/Cumulus/Utilities/biz.dfch.PS.Cumulus.Utilities.psd1/

.HELPURI

#>
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
2014-11-14; rrink; ADD: .HELPURI in inline help to fix HelpURI attribute in CmdletBinding
2014-11-12; rrink; ADD: example and help, see #1
2014-11-12; rrink; ADD: Checksum parameter. You can now optionally specify an empty Value and only a checksum
2014-11-12; rrink; ADD: DefaultParameterSetName is now path
2014-11-11; rrink; CHG: dot-sourcing, Export-ModuleMember now is only invoked when loaded via module
2014-10-13; rrink; CHG: module variable is now loaded via PSD1 PrivateData
2014-10-13; rrink; CHG: module is now defined via PSD1 and loads assembly via PSD1
2014-08-17; rrink; CHG: rename ls to svc
2014-08-17; rrink; ADD: Set-File.
#>
