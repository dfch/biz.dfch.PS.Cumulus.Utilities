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
Param 
(
	# The name of the ManagementCredential entity
	[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'name')]
	[string] $Name
	,
	# A ManagementCredential you have retrieved by returning entities from the ApplicationData.ManagementCredentials entity set
	[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'o')]
	[CumulusWrapper.ApplicationData.ManagementCredential] $ManagementCredential
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'scrambled')]
	[alias("Password")]
	[string] $ScrambledPassword
	,
	# Specifies the reference to the Cumulus service reference
	[Parameter(Mandatory = $false)]
	[alias("Services")]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[alias("Registered")]
	[switch] $ListAvailable = $false
	,
	# Decrypt a specified crypted password
	[Parameter(Mandatory = $false, ParameterSetName = 'o')]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[alias("Decrypt")]
	[switch] $UnScramble = $false
	,
	# Specifies the return format of this Cmdlet
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty', 'PSCredential', 'Clear')]
	[Parameter(Mandatory = $false, ParameterSetName = 'o')]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'scrambled')]
	[alias("ReturnFormat")]
	[string] $As = 'default'
) 

BEGIN 
{

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. MgmtContext '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;

} 
# BEGIN

PROCESS 
{

# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;

try 
{

	# Parameter validation
	if($svc.Utilities -isnot [CumulusWrapper.Utilities.Utilities]) 
	{
		$msg = "svc: Parameter validation FAILED. Connect to the server before using the Cmdlet.";
		$e = New-CustomErrorRecord -m $msg -cat InvalidData -o $svc.Utilities;
		throw($gotoError);
	}

	if($PSCmdlet.ParameterSetName -eq 'list') 
	{
		# $null = $svc.ApplicationData.ManagementCredentials.AddQueryOption('$top',1);
		# $OutputParameter = $svc.ApplicationData.ManagementCredentials.AddQueryOption('$orderby', 'Name').AddQueryOption('$select','Name').Name;
		$OutputParameter = $svc.ApplicationData.ManagementCredentials.AddQueryOption('$orderby', 'Name').Name;
		$fReturn = $true;
		throw($gotoSuccess);
	}

	if($PSCmdlet.ParameterSetName -eq 'name') 
	{
		# Load credentials of management endpoint
		$mc = $svc.Utilities.ManagementCredentialHelpers.AddQueryOption('$filter',("Name eq '{0}'" -f $Name)).AddQueryOption('$top',1) | Select;
		if(!$mc) 
		{
			$msg = "Name: Parameter validation FAILED: '{0}'" -f $Name;
			$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
			throw($gotoError);
		}
	} 
	elseif($PSCmdlet.ParameterSetName -eq 'o') 
	{
		$mc = $svc.Utilities.ManagementCredentialHelpers.AddQueryOption('$filter',("Id eq {0}" -f $ManagementCredential.Id)) | Select;
		if(!$mc) 
		{
			$msg = "Id: Parameter validation FAILED: '{0}'" -f $ManagementCredential.Id;
			$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $mc;
			throw($gotoError);
		}
	} 
	else 
	{
		$msg = "ParameterSetName: Not implemented: '{0}'" -f $PSCmdlet.ParameterSetName;
		$e = New-CustomErrorRecord -m $msg -cat NotImplemented -o $PSCmdlet;
		throw($gotoError);
	}

	$r = $mc;
	switch($As) 
	{
		'xml' { $OutputParameter = (ConvertTo-Xml -InputObject $r).OuterXml; }
		'xml-pretty' { $OutputParameter = Format-Xml -String (ConvertTo-Xml -InputObject $r).OuterXml; }
		'json' { $OutputParameter = ConvertTo-Json -InputObject $r -Compress; }
		'json-pretty' { $OutputParameter = ConvertTo-Json -InputObject $r; }
		'PSCredential' { $Cred = New-Object System.Management.Automation.PSCredential($r.Username, (ConvertTo-SecureString -String $r.Password -AsPlainText -Force)); $OutputParameter = $Cred; }
		'Clear' { $OutputParameter = @{'UserName' = $r.UserName; 'Password' = $r.Password; }}
		Default { $OutputParameter = $r; }
	}
	$fReturn = $true;

} # try
catch 
{
	if($gotoSuccess -eq $_.Exception.Message) 
	{
		$fReturn = $true;
	} 
	else 
	{
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) 
		{
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Status, $_);
			Log-Debug $fn $ErrorText -fac 3;
		}
		else 
		{
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) 
			{
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} 
			elseif($gotoFailure -ne $_.Exception.Message) 
			{ 
				Write-Verbose ("$fn`n$ErrorText"); 
			} 
			else 
			{
				# N/A
			}
		}
		$fReturn = $false;
		$OutputParameter = $null;
	}
}
finally 
{
	# Clean up
	# N/A
}

} 
# PROCESS

END 
{

$datEnd = [datetime]::Now;
Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;

# Return values are always and only returned via OutputParameter.
return $OutputParameter;

} 
# END

} # function
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

# SIG # Begin signature block
# MIIW3AYJKoZIhvcNAQcCoIIWzTCCFskCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtu36s/Hm6I9uwwiziCHQFX9U
# mLegghGYMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTP5BqRRYTP9ShA7dF/
# dkTiQACZHzANBgkqhkiG9w0BAQEFAASCAQB5Pe8/DF80jRi7Fph6u9dWA/b9A49Y
# ZXDqz9CER/LhBes3Mi5voxIOtDkCGSA8teheQTlJ5o7yHlL1iyV5M1nu70aQob8B
# KZxG2grC9sxuyqicYFxG6yd0aTFhCvXicWgdzzz3/0k3Kx3YkvDSfz9xM2IKWsSK
# pNFixl5Re+MmQ7GVtoiv2USnLdaz1rZotxQNl9Pm1I7HXBNhC3lGRVhbo5gbds72
# AK9ko0h8kR5Tc4D11/Z+8OAB7PSMOpINHuZ3xBOOPt74B76CTyjgjIUBiIwzOZGf
# r5VnO3YxOkaS6TGIr97WTTHbBtdrsQHHVElhP8YrNGVxLN2lwuSxciv8oYICojCC
# Ap4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gRzICEhEhQFwfDtJYiCvlTYaGuhHqRTAJBgUrDgMCGgUAoIH9
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE0MTIw
# NTA4NTA0MFowIwYJKoZIhvcNAQkEMRYEFOEUQS0eMquSib0LWqfAZtNiyX1pMIGd
# BgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUjOafUBLh0aj7OV4uMeK0K947NDsw
# bDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# KDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEhQFwf
# DtJYiCvlTYaGuhHqRTANBgkqhkiG9w0BAQEFAASCAQCYThkCGnCOADM28f8ebmob
# pFen2hlJbi9A/zrgdCK1DlbHiaRVcXbnIvKe07QcBNGKfyy1h0T7zQj1MMNr9zmK
# DXcbDPQGM/GEUoTYEKkwr299vj6pxS9F43w2ycvtsHlVCgtBTkpy5DqsZvF682bP
# 8wNi72/BORPHwOVUWubHaXYgAcEy1z07I3NLP4GFmo538plS3REgWODOvgwDCp/O
# 0V2E8xOOwU+QCrh0eTesPxgnqtAkPiibtfm+pzQH2OYYgWQwUi96TXbbcFkFlSIr
# d+w391Z806fTHdipR1WX+gT9MMR4EfA1LG/YVO12uNEG1VxmP+jBfnq3dHcQPSRC
# SIG # End signature block
