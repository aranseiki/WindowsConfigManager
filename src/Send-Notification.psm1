function Send-Notification {
    param (
        [string]$Title,
        [string]$Message,
        [int]$Duration,
        [System.Drawing.Icon]$Icon
    )

    try {
        # Carregar o tipo necessário
        Add-Type -AssemblyName System.Windows.Forms

        # Criar e configurar o ícone de notificação (usando variável estática)
        if (-not $script:NotifyIcon) {
            $script:NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
        }
        
        $script:NotifyIcon.Icon = $Icon
        $script:NotifyIcon.BalloonTipTitle = $Title
        $script:NotifyIcon.BalloonTipText = $Message
        $script:NotifyIcon.Visible = $true
        $script:NotifyIcon.ShowBalloonTip($Duration)

        # Esperar a duração da notificação
        Start-Sleep -Milliseconds $Duration
    } finally {
        if ($script:NotifyIcon) {
            $script:NotifyIcon.Dispose()
        }
    }
}

Export-ModuleMember -Function Send-Notification
