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

Invoke-PreChecks -verbose $false