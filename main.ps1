# TODO: Separate modules
function Test-ADModule {
    
    $result = $false

    if (Get-Module -ListAvailable -Name ActiveDirectory) {
        $result = $true
    } 

    return $result
}

function Test-ADConnection {

    return Test-ComputerSecureChannel

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

function Invoke-Tests {
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

$pre_checks_result = Invoke-Tests $false
Write-Host $pre_checks_result