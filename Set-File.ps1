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

Online Version: http://dfch.biz/biz/dfch/PS/Cumulus/Utilities/Set-File/



.NOTES

See module manifest for required software versions and dependencies at: http://dfch.biz/biz/dfch/PS/Cumulus/Utilities/biz.dfch.PS.Cumulus.Utilities.psd1/

#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = "Medium"
	,
	HelpURI='http://dfch.biz/biz/dfch/PS/Cumulus/Utilities/Set-File/'
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
Log-Debug -fn $fn -msg ("CALL. svc '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;

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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Set-File; } 

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

# 
# Copyright 2014-2015 Ronald Rink, d-fens GmbH
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 

# SIG # Begin signature block
# MIIW3AYJKoZIhvcNAQcCoIIWzTCCFskCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU20oXbsXWic2dBi346h4iPPkt
# dB6gghGYMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BCgwggMQoAMCAQICCwQAAAAAAS9O4TVcMA0GCSqGSIb3DQEBBQUAMFcxCzAJBgNV
# BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMRAwDgYDVQQLEwdSb290
# IENBMRswGQYDVQQDExJHbG9iYWxTaWduIFJvb3QgQ0EwHhcNMTEwNDEzMTAwMDAw
# WhcNMTkwNDEzMTAwMDAwWjBRMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFs
# U2lnbiBudi1zYTEnMCUGA1UEAxMeR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAt
# IEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsk8U5xC+1yZyqzaX
# 71O/QoReWNGKKPxDRm9+KERQC3VdANc8CkSeIGqk90VKN2Cjbj8S+m36tkbDaqO4
# DCcoAlco0VD3YTlVuMPhJYZSPL8FHdezmviaJDFJ1aKp4tORqz48c+/2KfHINdAw
# e39OkqUGj4fizvXBY2asGGkqwV67Wuhulf87gGKdmcfHL2bV/WIaglVaxvpAd47J
# MDwb8PI1uGxZnP3p1sq0QB73BMrRZ6l046UIVNmDNTuOjCMMdbbehkqeGj4KUEk4
# nNKokL+Y+siMKycRfir7zt6prjiTIvqm7PtcYXbDRNbMDH4vbQaAonRAu7cf9DvX
# c1Qf8wIDAQABo4H6MIH3MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/
# AgEAMB0GA1UdDgQWBBQIbti2nIq/7T7Xw3RdzIAfqC9QejBHBgNVHSAEQDA+MDwG
# BFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20v
# cmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2NybC5nbG9iYWxz
# aWduLm5ldC9yb290LmNybDATBgNVHSUEDDAKBggrBgEFBQcDAzAfBgNVHSMEGDAW
# gBRge2YaRQ2XyolQL30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEAIlzF3T30
# C3DY4/XnxY4JAbuxljZcWgetx6hESVEleq4NpBk7kpzPuUImuztsl+fHzhFtaJHa
# jW3xU01UOIxh88iCdmm+gTILMcNsyZ4gClgv8Ej+fkgHqtdDWJRzVAQxqXgNO4yw
# cME9fte9LyrD4vWPDJDca6XIvmheXW34eNK+SZUeFXgIkfs0yL6Erbzgxt0Y2/PK
# 8HvCFDwYuAO6lT4hHj9gaXp/agOejUr58CgsMIRe7CZyQrFty2TDEozWhEtnQXyx
# Axd4CeOtqLaWLaR+gANPiPfBa1pGFc0sGYvYcJzlLUmIYHKopBlScENe2tZGA7Bo
# DiTvSvYLJSTvJDCCBJ8wggOHoAMCAQICEhEhQFwfDtJYiCvlTYaGuhHqRTANBgkq
# hkiG9w0BAQUFADBSMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBu
# di1zYTEoMCYGA1UEAxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMjAe
# Fw0xMzA4MjMwMDAwMDBaFw0yNDA5MjMwMDAwMDBaMGAxCzAJBgNVBAYTAlNHMR8w
# HQYDVQQKExZHTU8gR2xvYmFsU2lnbiBQdGUgTHRkMTAwLgYDVQQDEydHbG9iYWxT
# aWduIFRTQSBmb3IgTVMgQXV0aGVudGljb2RlIC0gRzEwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQCwF66i07YEMFYeWA+x7VWk1lTL2PZzOuxdXqsl/Tal
# +oTDYUDFRrVZUjtCoi5fE2IQqVvmc9aSJbF9I+MGs4c6DkPw1wCJU6IRMVIobl1A
# cjzyCXenSZKX1GyQoHan/bjcs53yB2AsT1iYAGvTFVTg+t3/gCxfGKaY/9Sr7KFF
# WbIub2Jd4NkZrItXnKgmK9kXpRDSRwgacCwzi39ogCq1oV1r3Y0CAikDqnw3u7sp
# Tj1Tk7Om+o/SWJMVTLktq4CjoyX7r/cIZLB6RA9cENdfYTeqTmvT0lMlnYJz+iz5
# crCpGTkqUPqp0Dw6yuhb7/VfUfT5CtmXNd5qheYjBEKvAgMBAAGjggFfMIIBWzAO
# BgNVHQ8BAf8EBAMCB4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAyAR4wNDAyBggrBgEF
# BQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYD
# VR0TBAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8EOzA5MDegNaAz
# hjFodHRwOi8vY3JsLmdsb2JhbHNpZ24uY29tL2dzL2dzdGltZXN0YW1waW5nZzIu
# Y3JsMFQGCCsGAQUFBwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5n
# bG9iYWxzaWduLmNvbS9jYWNlcnQvZ3N0aW1lc3RhbXBpbmdnMi5jcnQwHQYDVR0O
# BBYEFNSihEo4Whh/uk8wUL2d1XqH1gn3MB8GA1UdIwQYMBaAFEbYPv/c477/g+b0
# hZuw3WrWFKnBMA0GCSqGSIb3DQEBBQUAA4IBAQACMRQuWFdkQYXorxJ1PIgcw17s
# LOmhPPW6qlMdudEpY9xDZ4bUOdrexsn/vkWF9KTXwVHqGO5AWF7me8yiQSkTOMjq
# IRaczpCmLvumytmU30Ad+QIYK772XU+f/5pI28UFCcqAzqD53EvDI+YDj7S0r1tx
# KWGRGBprevL9DdHNfV6Y67pwXuX06kPeNT3FFIGK2z4QXrty+qGgk6sDHMFlPJET
# iwRdK8S5FhvMVcUM6KvnQ8mygyilUxNHqzlkuRzqNDCxdgCVIfHUPaj9oAAy126Y
# PKacOwuDvsu4uyomjFm4ua6vJqziNKLcIQ2BCzgT90Wj49vErKFtG7flYVzXMIIE
# rTCCA5WgAwIBAgISESFgd9/aXcgt4FtCBtsrp6UyMA0GCSqGSIb3DQEBBQUAMFEx
# CzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMScwJQYDVQQD
# Ex5HbG9iYWxTaWduIENvZGVTaWduaW5nIENBIC0gRzIwHhcNMTIwNjA4MDcyNDEx
# WhcNMTUwNzEyMTAzNDA0WjB6MQswCQYDVQQGEwJERTEbMBkGA1UECBMSU2NobGVz
# d2lnLUhvbHN0ZWluMRAwDgYDVQQHEwdJdHplaG9lMR0wGwYDVQQKDBRkLWZlbnMg
# R21iSCAmIENvLiBLRzEdMBsGA1UEAwwUZC1mZW5zIEdtYkggJiBDby4gS0cwggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDTG4okWyOURuYYwTbGGokj+lvB
# go0dwNYJe7HZ9wrDUUB+MsPTTZL82O2INMHpQ8/QEMs87aalzHz2wtYN1dUIBUae
# dV7TZVme4ycjCfi5rlL+p44/vhNVnd1IbF/pxu7yOwkAwn/iR+FWbfAyFoCThJYk
# 9agPV0CzzFFBLcEtErPJIvrHq94tbRJTqH9sypQfrEToe5kBWkDYfid7U0rUkH/m
# bff/Tv87fd0mJkCfOL6H7/qCiYF20R23Kyw7D2f2hy9zTcdgzKVSPw41WTsQtB3i
# 05qwEZ3QCgunKfDSCtldL7HTdW+cfXQ2IHItN6zHpUAYxWwoyWLOcWcS69InAgMB
# AAGjggFUMIIBUDAOBgNVHQ8BAf8EBAMCB4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAy
# ATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVw
# b3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzA+BgNVHR8E
# NzA1MDOgMaAvhi1odHRwOi8vY3JsLmdsb2JhbHNpZ24uY29tL2dzL2dzY29kZXNp
# Z25nMi5jcmwwUAYIKwYBBQUHAQEERDBCMEAGCCsGAQUFBzAChjRodHRwOi8vc2Vj
# dXJlLmdsb2JhbHNpZ24uY29tL2NhY2VydC9nc2NvZGVzaWduZzIuY3J0MB0GA1Ud
# DgQWBBTwJ4K6WNfB5ea1nIQDH5+tzfFAujAfBgNVHSMEGDAWgBQIbti2nIq/7T7X
# w3RdzIAfqC9QejANBgkqhkiG9w0BAQUFAAOCAQEAB3ZotjKh87o7xxzmXjgiYxHl
# +L9tmF9nuj/SSXfDEXmnhGzkl1fHREpyXSVgBHZAXqPKnlmAMAWj0+Tm5yATKvV6
# 82HlCQi+nZjG3tIhuTUbLdu35bss50U44zNDqr+4wEPwzuFMUnYF2hFbYzxZMEAX
# Vlnaj+CqtMF6P/SZNxFvaAgnEY1QvIXI2pYVz3RhD4VdDPmMFv0P9iQ+npC1pmNL
# mCaG7zpffUFvZDuX6xUlzvOi0nrTo9M5F2w7LbWSzZXedam6DMG0nR1Xcx0qy9wY
# nq4NsytwPbUy+apmZVSalSvldiNDAfmdKP0SCjyVwk92xgNxYFwITJuNQIto4zGC
# BK4wggSqAgEBMGcwUTELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExJzAlBgNVBAMTHkdsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBHMgIS
# ESFgd9/aXcgt4FtCBtsrp6UyMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQow
# CKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcC
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRx0t1NdzYkdr96iqHS
# pQDtA1zWmTANBgkqhkiG9w0BAQEFAASCAQB9BQz2TrVy5+06Ts+5CnkYkOeCPegR
# ISEd9/LGHyLdnqnPh3Dnl0Pj+iQzH/QpxZCdg0eqQBOco1dxSqJcDuKikFwwBLXZ
# 1Y+Dph22TWcaJezEEUFsXiE4PUoYFvaUnRFL2d/l3YqIDcp7DFbVeRT5APRmzhhK
# R2/Jvjre1L+r56cyZqG3RuQjReORM/Ip8OEreghmtewWYbX5/fb4S1r18A0WcnoJ
# 5mV5/W+nWphyCnuyT8RApC1FvybrE5zCWZQUQ7cmRZSyXXfJA2X6CLWbk9Jp4PTq
# 8eSfzPs+eLWyZ0Hn39PxvbJw52QDuU0pYhcY6lqEhEV2rRht+wWc7P1aoYICojCC
# Ap4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gRzICEhEhQFwfDtJYiCvlTYaGuhHqRTAJBgUrDgMCGgUAoIH9
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1MDEx
# MzE4MjY1MlowIwYJKoZIhvcNAQkEMRYEFJPpQrJWN5eEziaZbnu9e90MljSJMIGd
# BgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUjOafUBLh0aj7OV4uMeK0K947NDsw
# bDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# KDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEhQFwf
# DtJYiCvlTYaGuhHqRTANBgkqhkiG9w0BAQEFAASCAQBgafyTbSFYVa9arCaBvLjF
# u6DBepxd/aR00xd0B+U39UI54YisfIf6XD7ZUASzwz3KmOltHNl8JUlzHpRbL/gc
# Gzu4XDqV9Ya4EXDvDbCFQqc+nxDd+mEHK4zqisSoOVQzAKQyD7ooxlGai86rOBEA
# u21TNsnEu+CBIfSiSeHX4uHJvHsLBLjER8oIXR3Ysx+XyCmIo65QX3+15K8uOM6e
# D5c/t44bAEizKADg8+UnykrnUZs5SawFSPCag2e1olLgwcw2IKllkJWnOMcBCir3
# 0Po2ReVnND4XagCzQYMwQ7gk4l3wDnDYckg58ZsnpTo+NJItwiF4CTY4qrHSDGGu
# SIG # End signature block
