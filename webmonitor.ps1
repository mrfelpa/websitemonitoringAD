
$secureCfgPath = "website_monitor.cfg"
if (-not (Test-Path $secureCfgPath)) {
    $adDomain = Read-Host "Enter Active Directory domain name:"
    $adContainer = Read-Host "Enter Active Directory container with web servers:"
    $password = Read-Host "Enter password to encrypt configuration (will not be displayed):" -AsSecureString
    $encryptedCfg = ConvertTo-SecureString -AsPlainText -Force -StringData ("adDomain=$adDomain`nadContainer=$adContainer")
    Set-Content -Value $encryptedCfg -Path $secureCfgPath -Force
}
$secureCfg = Get-SecureConfig -filePath $secureCfgPath

$adDomain = $secureCfg.adDomain
$adContainer = $secureCfg.adContainer
$websiteListFile = "websites.txt"
$logFile = "website_monitoring.log"
$monitoringInterval = 10 

function Get-SecureConfig {
    param(
        [string]$filePath
    )
    $password = Read-Host "Enter password to decrypt configuration file:" -AsSecureString
    $encryptedContent = Get-Content $filePath
    ConvertFrom-SecureString $encryptedContent -AsPlainText -Force -Key $password
}

function Test-DnsResolution($hostname) {
    try {
        Resolve-DnsName -Name $hostname -ErrorAction SilentlyContinue
        return $true
    } catch {
        return $false
    }
}

function Test-ADMembership($hostname) {
    $computer = Get-ADComputer -Filter "Name -eq '$hostname'" -ErrorAction SilentlyContinue
    return $computer -ne $null
}

function Test-Website($url) {
    try {
        $response = Invoke-WebRequest -Uri $url -Timeout 10 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            return "Success - Status Code: $($response.StatusCode)"
        } else {
            return "Error - Status Code: $($response.StatusCode)"
        }
    } catch {
        return "Error: $($_.Exception.Message)"
    }
}

function Write-Log {
    param(
        [string]$message
    )
    $log.WriteLine("[$($currentDateTime)] - $message")
}

$log = New-Object System.IO.StreamWriter($logFile, $true)

foreach ($website in Get-Content $websiteListFile) {
    if (Test-DnsResolution $website) {
        # Obtém o endereço IP do registro de DNS
        $ip = (Resolve-DnsName $website).IPAddress[0]
        
        if (Test-ADMembership -ComputerName $ip) {
            $result = Test-Website $website
            Write-Log "Monitoring website: $website (IP: $ip) - $result"
            Write-Host "Website: $website (IP: $ip) - $result"
        } else {
            Write-Log "Ignoring website: $website (IP: $ip) - Not hosted on domain server"
            Write-Host "Ignoring website: $website (IP: $ip) - Not hosted on domain server"
        }
    } else {
        Write-Log "Error: DNS resolution failed for website: $website"
        Write-Host "Error: DNS resolution failed for website: $website"
    }
}

$log.Close()

Start-Sleep -Seconds ($monitoringInterval * 60)

while ($true) {
    Write-Host "Enter 'q' to quit or press Enter to continue monitoring..."
    $userInput = Read-Host
    if ($userInput -eq 'q') {
        break
    }
}

function Clear-Log {
    $log = New-Object System.IO.StreamWriter($logFile, $true)
    $log.WriteLine("Log cleared at $(Get-Date)")
    $log.Close()
}

Clear-Log
