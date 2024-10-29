<#
Auto upgrade of New Relic Infrastructure Agent
#>

$serverName = Read-Host -Prompt "Enter server name"

try {
    Write-Host "Transferring installer to $serverName..."
    Copy-Item "\\fileserver\share\newrelic-infra.msi" -Destination "\\$serverName\c$\temp" -ErrorAction Stop
}

catch {
    <#Do this if a terminating exception happens#>
    Write-Host "Could not transfer installer to $serverName, checking for existing installer at C:\temp..." -ForegroundColor Yellow
}

try {
    Write-Host "Starting upgrade of New Relic agent..."
    $session = New-PSSession -ComputerName $serverName -ErrorAction Stop
    Invoke-Command -Session $session -ScriptBlock {
        msiexec.exe /qn /i c:\temp\newrelic-infra.msi
    Start-Sleep -Seconds 30
    Restart-Service newrelic-infra -Force -ErrorAction SilentlyContinue
    Write-Host -ForegroundColor Green "Upgrade Complete on $env:COMPUTERNAME"
    }
    Remove-PSSession -Session $session
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Error "Unable to open PS session on $serverName, exiting..."
    exit
}
