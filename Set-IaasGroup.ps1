function Set-IaasGroup {
<#

.SYNOPSIS

Creates or updates an IaasGroup.



.DESCRIPTION

Creates or updates an IaasGroup.



.PARAMETER Name

The name of the vCenter to process.



.PARAMETER mu

The ManagementUri object of the vCenter to process.



.PARAMETER DatacenterName

The name of the DataCenter to process.



.PARAMETER ClusterName

The name of the Cluster to process. This will be the name of the IaasGroup to create or update.



.PARAMETER Site

A site name for this IaasGroup.



.PARAMETER Tiering

A tiering level for this IaasGroup.



.PARAMETER CreateIfNotExist

Specify this switch to create a new IaasGroup if no existing is found.



.PARAMETER Type

The type of IaasGroup to create or update.



.PARAMETER Version

The version of the IaasGroup Parameters for the given Type.



.PARAMETER ExcludedDatastores

An array of regular expressions that will be matched against the datastore display names that should be skipped from import.



.PARAMETER ExcludedNetworks

An array of regular expressions that will be matched against the network display names that should be skipped from import.



.PARAMETER svc

A reference to the array of DataServiceContexts.



.PARAMETER As

Specify the return format of this Cmdlet (e.g. json or xml output).



.EXAMPLE

Create or update a vCenter type IaasGroup (default) with name "Cluster01" by specifying vCenter, Datastore, Cluster. All networks with name containing "local" will be skipped, as well as all datastores with either "vMotion", "Console", or "Mangement". Name of IaasGroup will be ABC and will have a Tiering level of GOLD.

Set-IaasGroup -Name vCenter1 -Site ABC -Tiering GOLD -Datacenter "Datacenter01" -Cluster "Cluster01" -CreateIfNotExist -ExcludedNetworks @("vMotion","Management","Console") -ExcludedDatastores @("local")



.EXAMPLE

Similar as previous example but by specifying IaasGroup type and version explicitly. In addition there is not blacklist specified so all networks and datastores are possible for import. Cmdlet will fail if the IaasGroup does not already exist.

Set-IaasGroup -Name vCenter1 -Site ABC -Tiering GOLD -Datacenter "Datacenter01" -Cluster "Cluster01" -Type vCenter -Version 3



.LINK

Online Version: http://dfch.biz/PS/Cumulus/Utilities/Set-IaasGroup/



.NOTES

Requires Powershell v3.

Requires module 'biz.dfch.PS.System.Logging'.

#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = "High"
	,
	DefaultParameterSetName="list"
	,
	HelpURI='http://dfch.biz/PS/Cumulus/Utilities/Set-IaasGroup/'
)]
PARAM (
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'name')]
	[string] $Name
	,
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'o')]
	[Alias('ManagementUri')]
	[CumulusWrapper.ApplicationData.ManagementUri] $mu
	,
	[Parameter(Mandatory = $true, Position = 1)]
	[string] $DatacenterName
	,
	[Parameter(Mandatory = $true, Position = 2)]
	[string] $ClusterName
	,
	[Parameter(Mandatory = $true, Position = 3)]
	[string] $Site
	,
	[Parameter(Mandatory = $true, Position = 4)]
	[ValidateSet('GOLD', 'SILVER', 'BRONZE')]
	[string] $Tiering
	,
	[Parameter(Mandatory = $false)]
	[ValidateSet('vCenter')]
	[string] $Type = 'vCenter'
	,
	[Parameter(Mandatory = $false)]
	[int] $Version = 1
	,
	[Parameter(Mandatory = $false)]
	[Alias("c")]
	[switch] $CreateIfNotExist = $false
	,
	[Parameter(Mandatory = $false)]
	[string[]] $ExcludedDatastores
	,
	[Parameter(Mandatory = $false)]
	[string[]] $ExcludedNetworks
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
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat InvalidData -o $svc.ApplicationData;
		throw($gotoError);
	} # if
	
	if($PSCmdlet.ParameterSetName -eq 'name') {
		$mu = $svc.ApplicationData.ManagementUris.AddQueryOption('$filter',("Name eq '{0}'" -f $Name)).AddQueryOption('$top',1) | Select;
	} # if
	if(!$mu) {
		$msg = "Name: Parameter validation FAILED. ManagementUri '{0}'." -f $Name;
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
	} # if
	$muParameters = $mu.Value | ConvertFrom-Json;
	
	$ig = $svc.ApplicationData.IaasGroups.AddQueryOption('$filter',("Name eq '{0}'" -f $ClusterName)).AddQueryOption('$top',1) | Select;
	if(!$ig) {
		if(!$CreateIfNotExist) {
			$msg = "ClusterName: Parameter validation FAILED. IaasGroup '{0}' does not exist." -f $ClusterName;
			Log-Error $fn $msg;
			$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $ClusterName;
			throw($gotoError);
		} else {
			$ig = New-Object CumulusWrapper.ApplicationData.IaasGroup;
		} # if
	} # if
	
	$igParameters = $ig.Parameters | ConvertFrom-Json -ErrorAction:SilentlyContinue;
	if(!$igParameters) {
		$igParameters = @{};
		$igParameters.Networks = @();
		$igParameters.Datatores = @();
	}
	$DatacenterConfig = $muParameters.Datacenters.$DatacenterName;
	if(!$DatacenterConfig) {
		$msg = "DatacenterName: Parameter validation FAILED. DatacenterName '{0}'." -f $DatacenterName;
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
	} # if
	$ClusterConfig = $DatacenterConfig.Clusters.$ClusterName;
	if(!$ClusterConfig) {
		$msg = "ClusterName: Parameter validation FAILED. ClusterName '{0}'." -f $ClusterName;
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
	} # if
	
	$ig.Version = $Version;
	$ig.Type = $Type;
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
	foreach($ds in $htds.GetEnumerator()) { 
		$fSkip = $false;
		foreach($excl in $ExcludedDatastores) {
			if($ds.Value.Name -imatch $excl) {
				Log-Warn $fn ("{0}: match found in ExcludedDatastores. Skipping import of this network ..." -f $ds.Value.Name);
				$fSkip = $true;
				break;
			} # if
		} # foreach
		if($fSkip) { continue; }
		$paramsds = $igParameters.Datastores |? DisplayName -eq $ds.Value.Name;
		if(!$paramsds) { 
			$paramsds = @{}; 
			$paramsds.DisplayName = $ds.Value.Name;
		} # if
		$paramsds.AvailableDiskGB = [Math]::Floor($ds.Value.FreeSpaceGB);
		$paramsds.TotalDiskGB = [Math]::Floor($ds.Value.CapacityGB);
		if($PSCmdlet.ShouldProcess(("vCenter '{0}'. DatacenterName '{1}'. ClusterName '{2}': set the following Datastore to ACTIVE ?`r`n{3}" -f $mu.Name, $DatacenterName, $ClusterName, ($paramsds | Out-String)))) {
			$paramsds.Active = $true;
		} else {
			$paramsds.Active = $false;
		} # if
		$params.Datastores += $paramsds;
	} # foreach
	
	$params.Networks = @();
	foreach($net in $ClusterConfig.Networks) { 
		$fSkip = $false;
		foreach($excl in $ExcludedNetworks) {
			if($net -imatch $excl) {
				Log-Warn $fn ("{0}: match found in ExcludedNetworks. Skipping import of this network ..." -f $net);
				$fSkip = $true;
				break;
			} # if
		} # foreach
		if($fSkip) { continue; }
		$paramsnet = $igParameters.Networks |? DisplayName -eq $net;
		if(!$paramsnet) {
			$paramsnet = @{};
			$paramsnet.DisplayName = $net;
		} # if
		$fReturn = $net -imatch 'VLAN\ *(\d\d\d?)';
		if($fReturn) {
			$paramsnet.VlanId = $Matches[1];
		} else {
			$paramsnet.VlanId = 0;
		} # if
		if($PSCmdlet.ShouldProcess(("vCenter '{0}'. DatacenterName '{1}'. ClusterName '{2}': set the following Network to ACTIVE ?`r`n{3}" -f $mu.Name, $DatacenterName, $ClusterName, ($paramsnet | Out-String)))) {
			$paramsnet.Active = $true;
		} else {
			$paramsnet.Active = $false;
		} # if
		$params.Networks += $paramsnet;
	} # foreach

	$ig.Parameters = $params | ConvertTo-Json;
	if($PSCmdlet.ShouldProcess(("vCenter '{0}'. DatacenterName '{1}'. ClusterName '{2}': add or update the following IaasGroup information?`r`n{3}" -f $mu.Name, $DatacenterName, $ClusterName, ($params | ConvertTo-Json)))) {
		if(!$ig.Id) {
			$svc.ApplicationData.AddToIaasGroups($ig);
		} # if
		$svc.ApplicationData.UpdateObject($ig);
		$r = $svc.ApplicationData.SaveChanges();
	} else {
		$null = $svc.ApplicationData.Detach($ig);
		$r = $null;
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
if($MyInvocation.PSScriptRoot) { Export-ModuleMember -Function Set-IaasGroup; } 

<#
2014-11-11; rrink; CHG: dot-sourcing, Export-ModuleMember now is only invoked when loaded via module
2014-10-30; rrink; ADD: Initial version.
#>
