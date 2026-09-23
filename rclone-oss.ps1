$logDir = "$env:LOCALAPPDATA\rclone"
$logFile = "$logDir\rclone.log"

New-Item -ItemType Directory -Path $logDir -Force | Out-Null

Write-Host "[INFO] Mounting Aliyun OSS..." -ForegroundColor Cyan
Write-Host "[INFO] Mount point: X:"
Write-Host "[INFO] Cache limit: 20GB"
Write-Host "[INFO] Log file: $logFile"
Write-Host "[INFO] Press Ctrl+C to stop the mount." -ForegroundColor Yellow

rclone.exe mount ali-oss:yay-waves X: `
    --volname "oss" `
    --vfs-cache-mode full `
    --vfs-cache-max-size 20G `
    --dir-cache-time 1h `
    --log-file "$logFile" `
    --log-level NOTICE

Write-Host "[INFO] rclone has exited. Mount session ended." -ForegroundColor Green
