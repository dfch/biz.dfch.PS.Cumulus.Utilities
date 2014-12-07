function Get-KeyNameValue {
<#

.SYNOPSIS

Retrieves keyed name/value pairs from the Cumulus server.


.DESCRIPTION

Retrieves keyed name/value pairs from the Cumulus server.

The K/N/V store stores arbitrary data that can be selected by either key, name, value or a combination of both. Besides specifying a selection you can furthermore define the order, the selected columns and the return format.
If you specify 'object' as output type then all filter options such as 'Select' are ignored.


.OUTPUTS

default | json | json-pretty | xml | xml-pretty


.INPUTS

You basically specify key, name and value to be retrieved. If one or more of these parameters are omitted all entities are returned that match these criteria.
If you specify 'object' as output type then all filter options such as 'Select' are ignored.


.EXAMPLE

Retrieves the first 5 entities from the entity set. Not specifing Key, Name or Value is the same as you would specify the 'ListAvailable' parameter.

Get-CumulusKeyNameValue | Select -First 5

Key                               Name              Value
---                               ----              -----
com.acme.infrastructure.inventory ApplicationSystem Application Server
com.acme.infrastructure.inventory ApplicationSystem Exchange
com.acme.infrastructure.inventory ApplicationSystem Other
com.acme.infrastructure.inventory ApplicationSystem Print Server
com.acme.infrastructure.inventory ApplicationSystem Term Server


.EXAMPLE
Get-CumulusKeyNameValue biz.dfch.infrastructure.inventory


Gets all entris with Key 'biz.dfch.infrastructure.inventory'.

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
Get-CumulusKeyNameValue biz.dfch.infrastructure.inventory ServerRole

As previous example. Gets all entris with Key 'biz.dfch.infrastructure.inventory' but now also specifies Name 'ServerRole'.

Key                               Name       Value
---                               ----       -----
biz.dfch.infrastructure.inventory ServerRole DEV
biz.dfch.infrastructure.inventory ServerRole INT
biz.dfch.infrastructure.inventory ServerRole PROD


.EXAMPLE
Get-CumulusKeyNameValue biz.dfch.infrastructure.inventory ServerRole -First 2

As previous example. Gets all entris with Key 'biz.dfch.infrastructure.inventory' and Name 'ServerRole' but only return first 2 entries.

Key                               Name       Value
---                               ----       -----
biz.dfch.infrastructure.inventory ServerRole DEV
biz.dfch.infrastructure.inventory ServerRole INT


.EXAMPLE
Get-CumulusKeyNameValue biz.dfch.infrastructure.inventory -As json-pretty

As previous example. Gets all entris with Key 'biz.dfch.infrastructure.inventory' but now also specifies Name 'ServerRole' and also specify return format as 'json-pretty'.

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
(Get-CumulusKeyNameValue ExistingKey NonExistingName -Select Value -DefaultValue "myDefaultValue").Value

myDefaultValue


.EXAMPLE
(Get-CumulusKeyNameValue biz.dfch.infrastructure.inventory ServerTier -Select Value).Value

Gets all entris with Key 'biz.dfch.infrastructure.inventory' and Name 'ServerTier' but only return the Value.

Tier 2
Tier 3
Tier 4


.EXAMPLE
Get-CumulusKeyNameValue biz.dfch.infrastructure.inventory ServerTier -ValueOnly

As previous example. Gets all entris with Key 'biz.dfch.infrastructure.inventory' 
and Name 'ServerTier' but only return the Value. This example makes use of the 
new 'ValueOnly' switch that facilitates the return of values only.

Tier 2
Tier 3
Tier 4


.EXAMPLE
PS > Get-KeyNameValue ConvertFromJsonTest

Key         Name  Value
---         ----  -----
ConvertFromJsonTest Name1 ["arr11","arr12"]
ConvertFromJsonTest Name2 ["arr21","arr22"]
ConvertFromJsonTest Name3 ["arr31","arr32"]

PS > Get-KeyNameValue ConvertFromJsonTest -ValueOnly
["arr11","arr12"]
["arr21","arr22"]
["arr31","arr32"]

PS > Get-KeyNameValue ConvertFromJsonTest -ValueOnly -Convert json
arr11
arr12
arr21
arr22
arr31
arr32

PS > Get-KeyNameValue ConvertFromJsonTest -ValueOnly -Convert json -First 1
arr11
arr12

PS > Set-KeyNameValue ConvertFromJsonTest Name20 Non-Valid-Json
PS > Set-KeyNameValue ConvertFromJsonTest Name20 Non-Valid-Json -CreateIfNotExist;
PS > Get-KeyNameValue ConvertFromJsonTest -ValueOnly
["arr11","arr12"]
["arr21","arr22"]
Non-Valid-Json
["arr31","arr32"]
PS > Get-KeyNameValue ConvertFromJsonTest -ValueOnly -Convert json -as json-pretty
[
  [
    "arr11",
    "arr12"
  ],
  [
    "arr21",
    "arr22"
  ],
  "Non-Valid-Json",
  [
    "arr31",
    "arr32"
  ]
]

This example shows how to decode JSON values while querying them from the KNV store.
When the returned data is not JSON it returned unchanged


.EXAMPLE
$r =  Get-KeyNameValue SCCM.OSDOperatingSystemType -as object ; $r.GetType()
IsPublic IsSerial Name         BaseType
-------- -------- ----         --------
True     False    KeyNameValue System.Object
PS > $r[0]
Id         : 125
Key        : SCCM.OSDOperatingSystemType
Name       : Windows 2008 R2 STD
Value      : 2008STDR2x64
CreatedBy  : SERVER1\Administrator
Created    : 8/16/2014 4:31:04 PM +00:00
ModifiedBy : SERVER1\Administrator
Modified   : 8/16/2014 4:31:04 PM +00:00
RowVersion : {0, 0, 0, 0...}

In this example the KNV is returned as an object, so it could be piped to 
another Cmdlet like 'Remove-Entity'.
Specifying 'object' as a return format overrides options like 'Select'.


.LINK

Online Version: http://dfch.biz/biz/dfch/PS/Cumulus/Utilities/Get-KeyNameValue/




.NOTES

See module manifest for dependencies and further requirements.

#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = "Low"
	,
	HelpURI='http://dfch.biz/biz/dfch/PS/Cumulus/Utilities/Get-KeyNameValue/'
	,
	DefaultParameterSetName = 'list'
)]
PARAM 
(
	# Specifies the Key property of the entity.
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'name')]
	[Alias("k")]
	[string] $Key
	,
	# Specifies the Name property of the entity.
	[Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'name')]
	[Alias("n")]
	[string] $Name
	,
	# Specifies the Value property of the entity.
	[Parameter(Mandatory = $false, Position = 2, ParameterSetName = 'name')]
	[Alias("v")]
	[string] $Value
	,
	# Specifies the order of the returned entites. You can specify more than one property (e.g. Key and Name).
	[ValidateSet('Key', 'Name', 'Value')]
	[Parameter(Mandatory = $false, Position = 3)]
	[string[]] $OrderBy = @('Key','Name','Value')
	,
	# Specifies what to return from the search
	[ValidateSet('Key', 'Name', 'Value')]
	[Parameter(Mandatory = $false, Position = 4)]
	[Alias("s")]
	[Alias("Return")]
	[string[]] $Select = @('Key','Name','Value')
	,
	# Specifies to return only values without header information. 
	# This parameter takes precendes over the 'Select' parameter.
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Alias("HideTableHeaders")]
	[switch] $ValueOnly
	,
	# Specifies to deserialize JSON payloads
	[ValidateSet('json')]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Alias("Convert")]
	[string] $ConvertFrom
	,
	# Limits the output to the specified number of entries
	[Parameter(Mandatory = $false)]
	[Alias("top")]
	[int] $First
	,
	# This value is only returned if the regular search would have returned no results
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Alias("default")]
	$DefaultValue
	,
	# Specifies a references to the cumulus endpoints
	[Parameter(Mandatory = $false)]
	[Alias("Services")]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	# Specifies to return all existing KNV entities
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[switch] $ListAvailable = $false
	,
	# Specifies the return format of the search
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty', 'object')]
	[Parameter(Mandatory = $false)]
	[alias("ReturnFormat")]
	[string] $As = 'default'
)

BEGIN {

	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. svc '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;

	$EntitySetName = 'KeyNameValues';
	
	if($svc.ApplicationData -isnot [CumulusWrapper.ApplicationData.ApplicationData]) 
	{
		$msg = "svc: Parameter validation FAILED. Connect to the server before using the Cmdlet.";
		$e = New-CustomErrorRecord -m $msg -cat InvalidData -o $svc.ApplicationData;
		throw($gotoError);
	}
	$OrderBy = $OrderBy | Select -Unique;
	$OrderByString = [string]::Join(',', $OrderBy);
	$Select = $Select | Select -Unique;
	if($ValueOnly)
	{
		if('object' -eq $As)
		{
			throw ("'ReturnFormat':'object' and 'ValueOnly' must not be specified at the same time." );
			$e = New-CustomErrorRecord -m $msg -cat InvalidArgument -o $PSCmdlet;
			$PSCmdlet.ThrowTerminatingError($e);
		}
		$Select = 'Value';
	}
	if($PSBoundParameters.ContainsKey('Select') -And 'object' -eq $As)
	{
		$msg = ("'ReturnFormat':'object' and 'Select' must not be specified at the same time." );
		$e = New-CustomErrorRecord -m $msg -cat InvalidArgument -o $PSCmdlet;
		$PSCmdlet.ThrowTerminatingError($e);
	}
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
	# N/A
	
	if($PSCmdlet.ParameterSetName -eq 'list') 
	{
		if($Select -And 'object' -ne $As) 
		{
			if($PSBoundParameters.ContainsKey('First'))
			{
				$Response = $svc.ApplicationData.$EntitySetName.AddQueryOption('$orderby','Name').AddQueryOption('$top', $First) | Select -Property $Select;
			}
			else
			{
				$Response = $svc.ApplicationData.$EntitySetName.AddQueryOption('$orderby','Name') | Select -Property $Select;
			}
		}
		else 
		{
			if($PSBoundParameters.ContainsKey('First'))
			{
				$Response = $svc.ApplicationData.$EntitySetName.AddQueryOption('$orderby','Name').AddQueryOption('$top', $First) | Select;
			}
			else
			{
				$Response = $svc.ApplicationData.$EntitySetName.AddQueryOption('$orderby','Name') | Select;
			}
		}
	} 
	else 
	{
		$Exp = @();
		if($Key) 
		{ 
			$Key = $Key.ToLower();
			$Exp += ("(tolower(Key) eq '{0}')" -f $Key);
		}
		if($Name) 
		{ 
			$Key = $Name.ToLower();
			$Exp += ("(tolower(Name) eq '{0}')" -f $Name);
		}
		if($Value) 
		{ 
			$Value = $Value.ToLower();
			$Exp += ("(tolower(Value) eq '{0}')" -f $Value);
		}
		$FilterExpression = [String]::Join(' and ', $Exp);

		if($Select -And 'object' -ne $As) 
		{
			if($PSBoundParameters.ContainsKey('First'))
			{
				$Response = $svc.ApplicationData.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby', $OrderByString).AddQueryOption('$top', $First) | Select -Property $Select;
			}
			else
			{
				$Response = $svc.ApplicationData.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby', $OrderByString) | Select -Property $Select;
			}
		}
		else 
		{
			if($PSBoundParameters.ContainsKey('First'))
			{
				$Response = $svc.ApplicationData.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby', $OrderByString).AddQueryOption('$top', $First) | Select;
			}
			else
			{
				$Response = $svc.ApplicationData.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby', $OrderByString) | Select;
			}
		}
		if('Value' -eq $Select -And $ValueOnly)
		{
			$Response = ($Response).Value;
		}
		if($PSBoundParameters.ContainsKey('DefaultValue') -And !$Response)
		{
			$Response = $DefaultValue;
		}
		if('Value' -eq $Select -And $ConvertFrom)
		{
			$ResponseTemp = New-Object System.Collections.ArrayList;
			foreach($item in $Response)
			{
				try
				{
					$null = $ResponseTemp.Add((ConvertFrom-Json -InputObject $item));
				}
				catch
				{
					$null = $ResponseTemp.Add($item);
				}
			}
			$Response = $ResponseTemp.ToArray();
			Remove-Variable ResponseTemp -Confirm:$false;
		}
	}
	
	$r = $Response;
	switch($As) 
	{
		'xml' { $OutputParameter = (ConvertTo-Xml -InputObject $r).OuterXml; }
		'xml-pretty' { $OutputParameter = Format-Xml -String (ConvertTo-Xml -InputObject $r).OuterXml; }
		'json' { $OutputParameter = ConvertTo-Json -InputObject $r -Compress; }
		'json-pretty' { $OutputParameter = ConvertTo-Json -InputObject $r; }
		Default { $OutputParameter = $r; }
	} 
	$fReturn = $true;

}
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-KeyNameValue; } 

<#
2014-11-14; rrink; ADD: .HELPURI in inline help to fix HelpURI attribute in CmdletBinding
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

# SIG # Begin signature block
# MIIW3AYJKoZIhvcNAQcCoIIWzTCCFskCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUo7Nz80ORRDPb4jyKVeNs2hHq
# V++gghGYMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTllMQsXXluZYYqO9GO
# n/lXuu1vvDANBgkqhkiG9w0BAQEFAASCAQBK8+PRlN/xYUTgTmzfdNyXY6anwjku
# gmVXexdQidYpnrDnecNN/rJ2pQKYmK0haKh191VuzfKj49pcnXeJ3PU/ChN9FVzq
# 9MnXxe171jk4clKn8c0BD1ioG0ZKmp7UYOVNi/mMN1oWA3orECm8d87fP129Bhg6
# 4nYcW8Momj8hR5zCvK2ISYCTrA1wyARdWKd8SOfALlzIbK45jHLdfp0rm8C6xK8D
# 26882v/KnrSMIELugy/BgNDJ28f459GFOpz1nRh1udqsQXmpK+kyXCPAT0SU6fAK
# h11rcHr7ulfKHWrstk1KiO8d2WnY4B2n9IAJeBsbv1QbUomgLXGksHpWoYICojCC
# Ap4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gRzICEhEhQFwfDtJYiCvlTYaGuhHqRTAJBgUrDgMCGgUAoIH9
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE0MTIw
# NzE2Mzc1NVowIwYJKoZIhvcNAQkEMRYEFFJGWRZA7n+89sX/RWbsId3ckw30MIGd
# BgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUjOafUBLh0aj7OV4uMeK0K947NDsw
# bDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# KDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEhQFwf
# DtJYiCvlTYaGuhHqRTANBgkqhkiG9w0BAQEFAASCAQB91fLSXNWhchHfQw0TxeK8
# TTY3O8kAPCjTwHq9m2zISDpZ0Ba1m5GS5hDKdKLpBp/pota2I69rAQkDTzJqL2A7
# 0vnF7LKE3TBuI0/rl4F/jYf04PTQ6KOcUACk16k/MZynGpCGs3Uc+NXckY3PzCC7
# uETEtMYtFArTftQvx7sSoDfKViiGJ0ekkeCl4yXgg32gZLPwdXJLVnLvSitYd5Xr
# siHp9oS7sHutLtOvUxlyq/wnGA58cQTHWbMykleqI12qrrOrsrACJxlA0WDzS44g
# 9UGRuLySjZnuwVpvrOgoirOTq6PdqpEip9WARVmkTSqVsKT9IYiwZ1s9XDuRkWXV
# SIG # End signature block
