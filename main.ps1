Param(
    [int] $Delay = -1,
    [int] $Left = -1,
    [int] $Top = -1,
    [int] $Width = -1,
    [int] $Height = -1,
    [switch] $StartUp = $false
)

Function Set-QQWindow {
    Begin {
        Try {
            [void][Window]
        }
        Catch {
            Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Window {
    [DllImport("user32.dll")]
    public static extern int FindWindow(String sClassName, String sAppName);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool MoveWindow(IntPtr hWnd, int x, int y, int width, int height, bool repaint);
}
public struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
}
"@
        }
    }
    Process {
        # Init
        $HWnd = 0
        $ChangeCount = 0
        $WaitCount = 0
        # Wait for QQ launched
        Do {
            if (++$WaitCount -gt 600) {
                Write-Error "QQ launch timeout!"
                Exit
            }
            Start-Sleep -Milliseconds 100
            $newHWnd = [Window]::FindWindow("TXGuiFoundation", "QQ")
            if (($HWnd -ne $newHWnd) -and ($newHWnd -ne 0)) {
                $HWnd = $newHWnd
                $ChangeCount++
            }
        } While ($ChangeCount -lt 2)
        if ($Delay -ne -1) {
            Start-Sleep -Milliseconds $Delay
            $HWnd = [Window]::FindWindow("TXGuiFoundation", "QQ")
        }
        # Set window style and position
        if (($Left -ne -1) -and ($Top -ne -1) -and ($Width -ne -1) -and ($Height -ne -1)) {
            [Window]::MoveWindow($HWnd, $Left, $Top, $Width, $Height, $true)
        }
        else {
            $Rect = New-Object RECT
            [Window]::GetWindowRect($HWnd, [ref]$Rect)
            [Window]::MoveWindow($HWnd, $Rect.Left, $Rect.Top - 40, $Rect.Right - $Rect.Left, $Rect.Bottom - $Rect.Top, $true)
        }
    }
}

# Stop on remote desktop
if ($StartUp -and (quser | Select-String -Quiet '\brdp-')) {
    Exit
}

$CurDir = (Resolve-Path '.').Path
$WorkDir = "$CurDir\Bin"
Start-Process -FilePath "$WorkDir\QQ.exe" -WorkingDirectory $WorkDir
Set-QQWindow
