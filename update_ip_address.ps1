# Update IP address from 192.168.1.9 to 192.168.1.2 in all Dart files

$oldIP = "192.168.1.9"
$newIP = "192.168.1.2"

Get-ChildItem -Path "otp_phone_auth/lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match $oldIP) {
        $newContent = $content -replace [regex]::Escape($oldIP), $newIP
        Set-Content -Path $_.FullName -Value $newContent -NoNewline
        Write-Host "Updated: $($_.Name)"
    }
}

Write-Host "`nDone! All IP addresses updated from $oldIP to $newIP"
