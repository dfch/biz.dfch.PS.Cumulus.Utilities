function Set-IaasGroup {
<#
.SYNOPSIS
Creates or updates an IaasGroup.


.DESCRIPTION
Creates or updates an IaasGroup.

This Cmdlet is not a typical 'Set'-Cmdlet as it not just sets (or creates) 
the contents of an IaasGroup 


.EXAMPLE
Create or update a vCenter type IaasGroup (default) with name "Cluster01" by specifying vCenter, Datastore, Cluster. All networks with name containing "local" will be skipped, as well as all datastores with either "vMotion", "Console", or "Mangement". Name of IaasGroup will be ABC and will have a Tiering level of GOLD.

Set-IaasGroup -Name vCenter1 -Site ABC -Tiering GOLD -Datacenter "Datacenter01" -Cluster "Cluster01" -CreateIfNotExist -ExcludedNetworks @("vMotion","Management","Console") -ExcludedDatastores @("local")


.EXAMPLE
Similar as previous example but by specifying IaasGroup type and version explicitly. In addition there is not blacklist specified so all networks and datastores are possible for import. Cmdlet will fail if the IaasGroup does not already exist.

Set-IaasGroup -Name vCenter1 -Site ABC -Tiering GOLD -Datacenter "Datacenter01" -Cluster "Cluster01" -Type vCenter -Version 3


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Cumulus/Utilities/Set-IaasGroup/


.NOTES
See module manifest for dependencies and requirements.


#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = "High"
	,
	DefaultParameterSetName="list"
	,
	HelpURI='http://dfch.biz/biz/dfch/PS/Cumulus/Utilities/Set-IaasGroup/'
)]
PARAM 
(
	# The name of the vCenter to process.
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'name')]
	[string] $Name
	,
	# The ManagementUri object of the vCenter to process.
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'o')]
	[Alias('ManagementUri')]
	[CumulusWrapper.ApplicationData.ManagementUri] $mu
	,
	# The name of the DataCenter to process.
	[Parameter(Mandatory = $true, Position = 1)]
	[string] $DatacenterName
	,
	# The name of the Cluster to process. This will be the name of the IaasGroup to create or update.
	[Parameter(Mandatory = $true, Position = 2)]
	[string] $ClusterName
	,
	# A site name for this IaasGroup.
	[Parameter(Mandatory = $true, Position = 3)]
	[string] $Site
	,
	# A tiering level for this IaasGroup.
	[Parameter(Mandatory = $true, Position = 4)]
	[ValidateSet('GOLD', 'SILVER', 'BRONZE')]
	[string] $Tiering
	,
	# Specifies the IaasGroup type to set or update
	[Parameter(Mandatory = $false)]
	[ValidateSet('vCenter')]
	[string] $Type = 'vCenter'
	,
	# Specifies the IaasGroup version set or update
	[Parameter(Mandatory = $false)]
	[int] $Version = 1
	,
	# Specifies whether the IaasGroup shoud be active or not
	[Parameter(Mandatory = $false)]
	[Switch] $Active = $true
	,
	# Specify this switch to create a new IaasGroup if no existing is found.
	[Parameter(Mandatory = $false)]
	[Alias("c")]
	[switch] $CreateIfNotExist = $false
	,
	# An array of regular expressions that will be matched against the datastore display names that should be skipped from import.
	[Parameter(Mandatory = $false)]
	[string[]] $ExcludedDatastores
	,
	# An array of regular expressions that will be matched against the network display names that should be skipped from import.
	[Parameter(Mandatory = $false)]
	[string[]] $ExcludedNetworks
	,
	# A reference to the array of DataServiceContexts.
	[Parameter(Mandatory = $false)]
	[Alias("Services")]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	# Specify the return format of this Cmdlet (e.g. json or xml output).
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	[Parameter(Mandatory = $false)]
	[alias("ReturnFormat")]
	[string] $As = 'default'
)

BEGIN 
{
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. svc '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;
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
	if($svc.ApplicationData -isnot [CumulusWrapper.ApplicationData.ApplicationData]) {
		$msg = "svc: Parameter validation FAILED. Connect to the server before using the Cmdlet.";
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat InvalidData -o $svc.ApplicationData;
		throw($gotoError);
	}
	
	if($PSCmdlet.ParameterSetName -eq 'name') 
	{
		$mu = $svc.ApplicationData.ManagementUris.AddQueryOption('$filter',("Name eq '{0}'" -f $Name)).AddQueryOption('$top',1) | Select;
	}
	if(!$mu) 
	{
		$msg = "Name: Parameter validation FAILED. ManagementUri '{0}'." -f $Name;
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
	}
	$muParameters = $mu.Value | ConvertFrom-Json;
	
	$ig = $svc.ApplicationData.IaasGroups.AddQueryOption('$filter',("Name eq '{0}'" -f $ClusterName)).AddQueryOption('$top',1) | Select;
	if(!$ig) 
	{
		if(!$CreateIfNotExist) 
		{
			$msg = "ClusterName: Parameter validation FAILED. IaasGroup '{0}' does not exist." -f $ClusterName;
			Log-Error $fn $msg;
			$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $ClusterName;
			throw($gotoError);
		} 
		else 
		{
			$ig = New-Object CumulusWrapper.ApplicationData.IaasGroup;
		}
	}
	
	$igParameters = $ig.Parameters | ConvertFrom-Json -ErrorAction:SilentlyContinue;
	if(!$igParameters) 
	{
		$igParameters = @{};
		$igParameters.Networks = @();
		$igParameters.Datatores = @();
	}
	$DatacenterConfig = $muParameters.Datacenters.$DatacenterName;
	if(!$DatacenterConfig) 
	{
		$msg = "DatacenterName: Parameter validation FAILED. DatacenterName '{0}'." -f $DatacenterName;
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
	}
	$ClusterConfig = $DatacenterConfig.Clusters.$ClusterName;
	if(!$ClusterConfig) 
	{
		$msg = "ClusterName: Parameter validation FAILED. ClusterName '{0}'." -f $ClusterName;
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
	}
	
	$ig.Version = $Version;
	$ig.Type = $Type;
	$ig.Active = $Active;
	$ig.Name = $ClusterName;
	$ig.Description = $mu.Description;

	$params = @{}
	$params.Name = $ClusterName
	$params.vCenter = $mu.Name
	$params.Datacenter = $DatacenterName
	$params.Site = $Site
	$params.Tiering = $Tiering

	$params.Datastores = @();
	$htds = @{};
	$ClusterConfig.Datastores.psobject.properties | % { $htds[$_.Name] = $_.Value }
	foreach($ds in $htds.GetEnumerator()) 
	{ 
		$fSkip = $false;
		foreach($excl in $ExcludedDatastores) 
		{
			if($ds.Value.Name -imatch $excl) 
			{
				Log-Warn $fn ("{0}: match found in ExcludedDatastores. Skipping import of this network ..." -f $ds.Value.Name);
				$fSkip = $true;
				break;
			}
		}
		if($fSkip) 
		{ 
			continue; 
		}
		$paramsds = $igParameters.Datastores |? DisplayName -eq $ds.Value.Name;
		if(!$paramsds) 
		{ 
			$paramsds = @{}; 
			$paramsds.DisplayName = $ds.Value.Name;
		}
		$paramsds.AvailableDiskGB = [Math]::Floor($ds.Value.FreeSpaceGB);
		$paramsds.TotalDiskGB = [Math]::Floor($ds.Value.CapacityGB);
		if($PSCmdlet.ShouldProcess(("vCenter '{0}'. DatacenterName '{1}'. ClusterName '{2}': set the following Datastore to ACTIVE ?`r`n{3}" -f $mu.Name, $DatacenterName, $ClusterName, ($paramsds | Out-String)))) 
		{
			$paramsds.Active = $true;
		} 
		else 
		{
			$paramsds.Active = $false;
		}
		$params.Datastores += $paramsds;
	}
	
	$params.Networks = @();
	foreach($net in $ClusterConfig.Networks) 
	{ 
		$fSkip = $false;
		foreach($excl in $ExcludedNetworks) 
		{
			if($net -imatch $excl) 
			{
				Log-Warn $fn ("{0}: match found in ExcludedNetworks. Skipping import of this network ..." -f $net);
				$fSkip = $true;
				break;
			}
		}
		if($fSkip) { 
			continue; 
		}
		$paramsnet = $igParameters.Networks |? DisplayName -eq $net;
		if(!$paramsnet) 
		{
			$paramsnet = @{};
			$paramsnet.DisplayName = $net;
		}
		$fReturn = $net -imatch 'VLAN\ *(\d\d\d?)';
		if($fReturn) 
		{
			$paramsnet.VlanId = $Matches[1];
		} 
		else 
		{
			$paramsnet.VlanId = 0;
		}
		if($PSCmdlet.ShouldProcess(("vCenter '{0}'. DatacenterName '{1}'. ClusterName '{2}': set the following Network to ACTIVE ?`r`n{3}" -f $mu.Name, $DatacenterName, $ClusterName, ($paramsnet | Out-String)))) 
		{
			$paramsnet.Active = $true;
		} 
		else 
		{
			$paramsnet.Active = $false;
		}
		$params.Networks += $paramsnet;
	}

	$ig.Parameters = $params | ConvertTo-Json;
	if($PSCmdlet.ShouldProcess(("vCenter '{0}'. DatacenterName '{1}'. ClusterName '{2}': add or update the following IaasGroup information?`r`n{3}" -f $mu.Name, $DatacenterName, $ClusterName, ($params | ConvertTo-Json)))) 
	{
		if(!$ig.Id) 
		{
			$svc.ApplicationData.AddToIaasGroups($ig);
		}
		$svc.ApplicationData.UpdateObject($ig);
		$r = $svc.ApplicationData.SaveChanges();
	} 
	else 
	{
		$null = $svc.ApplicationData.Detach($ig);
		$r = $null;
	}

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
		
		if($_.Exception -is [System.Net.WebException]) {
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Exception.Status, $_);
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Set-IaasGroup; } 

<#
2014-11-14; rrink; ADD: .HELPURI in inline help to fix HelpURI attribute in CmdletBinding
2014-11-11; rrink; CHG: dot-sourcing, Export-ModuleMember now is only invoked when loaded via module
2014-10-30; rrink; ADD: Initial version.
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULTKQNo/mTslNFtHYrT/QQRQ6
# ZZ+gghGYMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBReQ0xWzakPpb2Avrl0
# r7WpGnCKXjANBgkqhkiG9w0BAQEFAASCAQBleQE0agW0OOR5pp2onAcgffTaI6J4
# qsnLuwhrkCNtbbtY45iZdGUOtlppF+gp2o+5Nb+c30ol536n2OzfHhix2mg/QCRM
# 25VsIRrIfsWwl4YsTHDwt2axyTgENJ/rrjk0tA/w8s+6gKwqlJ3gqqlpxBy4vO4G
# Xoi+o6YH5794Zn26lbrnHCpJNxfVN4CdrIcQuXPfIthUn/1NiQ4eFkNTLMt3NaMJ
# QnA0kdgV43RLumGITswQ6wwu2YhS9eUl8c7wUKGwiLEm/aJIuZ0r1qqBC1MpUT1m
# Sm/p+alYZq6hu/s97CLbfeLWHOVNxATOEFDeiRtkVdlRyN2nRC4qhpngoYICojCC
# Ap4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gRzICEhEhQFwfDtJYiCvlTYaGuhHqRTAJBgUrDgMCGgUAoIH9
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1MDEx
# NDE3MjAwNlowIwYJKoZIhvcNAQkEMRYEFCez/LJxGg3xjgKWiejLIsSofHO4MIGd
# BgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUjOafUBLh0aj7OV4uMeK0K947NDsw
# bDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# KDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEhQFwf
# DtJYiCvlTYaGuhHqRTANBgkqhkiG9w0BAQEFAASCAQApOoMqZkVBFpraQt+XmXEW
# mt8EaDhu8xa2oSm47a4Y+4kQ3j+q5iepcp91Ut/LTeA7nG7BSiDy/Q+K8DQljNhF
# lwWYNCfHJGOtOEu6CUseT8Vf8OK/YPGaE1j9MY/KeWE5gQpHL55F34czj1gWQjta
# 1OmtYaA4nVVtAStYMvt9ExfSqrmMtJyextu/GCc7s2EdbEz2WotgLeOi1xOp+Eym
# gaxKA+MsWUaEigV1tjTB/erPBFPi9Wq1w1kzbDMdITsW46u2dR8/INr+rnqYovGl
# +aUoaYzLeSh3lTcdVTXC4/QDsL+3VaJxgaXx6Zh8jOZs79i/bLdpTvY5XvIreGdW
# SIG # End signature block
