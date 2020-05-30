$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Test-DomainControllers" {
    Mock Get-ADDomainController {return @("DC1", "DC2")}

    It "Returns true when domain controllers are found" {
        Test-DomainControllers | Should Be $true
    }

    Mock Get-ADDomainController {Throw 'Oooh snap! This failed'}

    It "Returns false when domain controllers are not found" {
        Test-DomainControllers | Should Be $false
    }

}

Describe "Test-ADConnection" {

    Mock Test-ComputerSecureChannel {return $true}

    It "Returns true when we're joined to the domain" {
        Test-ADConnection | Should Be $true
    }

    Mock Test-ComputerSecureChannel {Throw 'Oooh snap! This failed'}

    It "Handles exceptions when not joined to the domain" {
        Test-ADConnection | Should Be $false
    }

}

Describe "Invoke-PreChecks" {
    Mock Test-DomainControllers {return $true}
    Mock Test-ADConnection {return $true}
    Mock Test-ADModule {return $true}

    It "Returns true when the pre checks pass and we're ready to move on" {
        Invoke-PreChecks | Should Be $true
    }

    Mock Test-DomainControllers {return $false}
    Mock Test-ADConnection {return $false}
    Mock Test-ADModule {return $false}

    It "Handles failure of any of the pre-checks" {
        Invoke-PreChecks | Should Be $false
    }
}
