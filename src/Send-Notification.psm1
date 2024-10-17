Arquivo módulo Send-Notification:
function Send-Notification {
    param (
        [string]$Title = "Alteração Detectada",
        [string]$Message = "Configuração do sistema foi modificada.",
        [int]$Duration = 3000  # Duração da notificação em milissegundos
    )

    # Carregar o tipo necessário
    Add-Type -AssemblyName System.Windows.Forms

    # Criar e configurar o ícone de notificação (usando variável estática)
    if (-not $script:NotifyIcon) {
        $script:NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
        $script:NotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$env:SystemRoot\System32\shell32.dll")
        $script:NotifyIcon.Visible = $true
    }

    $script:NotifyIcon.Visible = $true

    # Configurar e exibir a notificação
    $script:NotifyIcon.BalloonTipTitle = $Title
    $script:NotifyIcon.BalloonTipText = $Message
    $script:NotifyIcon.ShowBalloonTip($Duration)

    # Esperar a duração da notificação
    Start-Sleep -Milliseconds $Duration
}

Export-ModuleMember -Function Send-Notification