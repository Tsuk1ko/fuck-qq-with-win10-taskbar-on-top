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
        $Rect = New-Object RECT
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
            if ($HWnd -ne $newHWnd) {
                $HWnd = $newHWnd
                $ChangeCount++
            }
        } While ($ChangeCount -lt 2)
        # Set window style and position
        [Window]::GetWindowRect($HWnd, [ref]$Rect)
        [Window]::MoveWindow($HWnd, $Rect.Left, $Rect.Top - 40, $Rect.Right - $Rect.Left, $Rect.Bottom - $Rect.Top, $true)
    }
}

$CurDir = (Resolve-Path '.').Path
$WorkDir = "$CurDir\Bin"
Start-Process -FilePath "$WorkDir\QQ.exe" -WorkingDirectory $WorkDir
Set-QQWindow
