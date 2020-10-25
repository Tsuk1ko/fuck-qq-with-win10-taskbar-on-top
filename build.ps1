$version = (git rev-list --tags --max-count=1 | git describe --tags) -replace 'v', ''
Remove-Item qq-launcher.exe -Force -ErrorAction SilentlyContinue
ps2exe main.ps1 qq-launcher.exe -noConsole -iconFile logo.ico -title "QQ Launcher" -product "QQ Launcher" -copyright "Tsuk1ko/fuck-qq-with-win10-taskbar-on-top" -requireAdmin -noOutput -version $version
