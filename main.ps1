
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
        Get-ADDomainController -Discover -ErrorAction Stop
        $result = $true
    }
    catch {
        $result = $false
    }

    return $result
}


$ModuleReady = Test-ADModule
Write-Host $ModuleReady

$ADReady = Test-ADConnection
Write-Host $ADReady

$DCsReady = Test-DomainControllers
Write-Host $DCsReady



