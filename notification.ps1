Import-Module "C:\dev\projects\WindowsConfigManager\src\Manage-Access.psm1" -Force
Import-Module "C:\dev\projects\WindowsConfigManager\src\Send-Notification.psm1" -Force

$Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone"
$Verbose = $true
$CurrentValue = $null
$global:NotificationVisible = $false
$CurrentValue = Get-AccessPropertyItem -Path $Path -Verbose $Verbose

while ($true) {
    $CurrentValuePreview = $CurrentValue
    # Retrieve the current access value
    $CurrentValue = Get-AccessPropertyItem -Path $Path -Verbose $Verbose

    if ((-not [string]::IsNullOrEmpty($CurrentValue)) -and (($CurrentValue -ne $CurrentValuePreview))) {
        # Exemplo de uso
        if (-not $global:NotificationVisible) {
            Send-Notification -Title "Configuração Alterada" -Message "O microfone foi ativado!"

            # Dispensar notificações pendentes (forçando um "reset" do ícone)
            $global:NotificationVisible = $false
        } else {
            Write-Host "Notificação já está visível. Nenhuma nova notificação será exibida."
        }
    }

}