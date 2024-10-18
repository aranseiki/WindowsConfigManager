function Send-Notification {
    param (
        [string]$Title,
        [string]$Message,
        [int]$Duration,
        [string]$IconPath
    )
    
    try {
        # Carregar os tipos necessários
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        # Criar o NotifyIcon
        $NotifyIcon = New-Object System.Windows.Forms.NotifyIcon

        # Verificar se o ícone existe e carregá-lo corretamente
        $NotifyIcon.Icon = New-Object System.Drawing.Icon($IconPath)

        # Configurar o título e a mensagem da notificação
        $NotifyIcon.BalloonTipTitle = $Title
        $NotifyIcon.BalloonTipText = $Message
        $NotifyIcon.Visible = $true

        # Exibir a notificação
        $NotifyIcon.ShowBalloonTip($Duration)

        # Esperar a duração da notificação
        Start-Sleep -Milliseconds $Duration
    } finally {
        if ($NotifyIcon) {
            $NotifyIcon.Dispose()
        }
    }
}

Export-ModuleMember -Function Send-Notification
