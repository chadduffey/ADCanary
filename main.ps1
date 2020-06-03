# TODO: Separate modules
function Test-ADModule {

    $result = $false

    try {
        Get-Module -ListAvailable -Name ActiveDirectory
        $result = $true
    }
    catch {
        $result = $false
    }

    return $result
}

function Test-ADConnection {

    $result = $false

    try {
        Test-ComputerSecureChannel -ErrorAction Stop
        $result = $true
    }
    catch {
        $result = $false
    }
    
    return $result
}

function Test-DomainControllers {

    $result = $false

    try {
        $dcs = (Get-ADDomainController -filter * -ErrorAction Stop)
        if ($dcs.Count -gt 0) {$result = $true}
    }
    catch {
        $result = $false
    }

    return $result
}

function Invoke-PreChecks {
    param (
        $verbose = $false
    )

    $ModuleReady = Test-ADModule
    if ($verbose){Write-Host "Test-ADModule:" $ModuleReady}
    if ($ModuleReady -eq $false) {return $false}

    $ADReady = Test-ADConnection
    if ($verbose){Write-Host "Test-ADConnection:" $ADReady}
    if ($ADReady -eq $false) {return $false}

    $DCsReady = Test-DomainControllers
    if ($verbose){Write-Host "Test-DomainControllers:" $DCsReady}
    if ($DCsReady -eq $false) {return $false}

    return $true
}

function Get-CanaryName {
    $canary_name = Get-Date -Format "yyyy_MM_dd___HH-mm-ss"
    return $canary_name
}

function Get-CanaryDN {
    param(
        [Parameter(Mandatory=$true)][psobject]$name
    )
    $DN = Get-ADObject -Filter 'Name -eq $name'
    return $DN
}

function Get-AllDomainControllers{
    return (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }
}

function Get-UpdateStatus{
    param(
        [Parameter(Mandatory=$true)][psobject]$canary,
        [Parameter(Mandatory=$true)][psobject]$dcName
    )
    Get-ADObject -Identity $canary.DistinguishedName -Server $dcName
}

function Confirm-Updates{
    param (
        [Parameter(Mandatory=$true)][psobject]$domainControllers,
        [Parameter(Mandatory=$true)][psobject]$canary,
        $verbosemode=$false
    )
    
    foreach($dc in $domainControllers){
        write-host "Processing" $dc.Name
        #Create Job Object Loop here:
        Get-UpdateStatus -canary $canaryName -dcName $dc
    }
    
}

$CANARYPATH = "OU=Canaries,DC=jmpesp,DC=xyz"

Invoke-PreChecks -verbose $false | out-null
$canary_name = Get-CanaryName
New-ADObject -type contact -path $CANARYPATH -Name $canary_name
$canary_dn = Get-CanaryDN -name $canary_name
Write-Host $canary_dn.DistinguishedName

#$allDomainControllers = Get-AllDomainControllers
#Confirm-Updates -domainControllers $allDomainControllers -canary $canary -verbosemode $true

#TESTONLY: Update-ADObject -objectDN $CANARYDistinguishedName | out-null

