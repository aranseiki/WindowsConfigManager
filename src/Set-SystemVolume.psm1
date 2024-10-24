function Set-MuteSystemAudio {
    try {
        Add-Type -TypeDefinition "
        using System;
        using System.Runtime.InteropServices;
        public class Audio {
            [DllImport(`"user32.dll`")]
            public static extern int SendMessageW(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
        }
        "

        # Constantes para controlar o volume
        $WM_APPCOMMAND = 0x319
        $APPCOMMAND_VOLUME_MUTE = 0x80000

        # Alternar o estado de mudo
        [Audio]::SendMessageW([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle, $WM_APPCOMMAND, 0, $APPCOMMAND_VOLUME_MUTE)
        return $true
    } catch {
        return $false
    }
}

Export-ModuleMember -Function Set-MuteSystemAudio
