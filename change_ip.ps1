# Script to change backend IP address in Flutter project
# Usage: .\change_ip.ps1 <new_ip_address>

param(
    [Parameter(Mandatory=$true)]
    [string]$NewIP
)

$OldIP = "192.168.1.11"
$ProjectRoot = "otp_phone_auth"

Write-Host "=" * 80
Write-Host "Changing IP address from $OldIP to $NewIP"
Write-Host "=" * 80

# Find all Dart files
$dartFiles = Get-ChildItem -Path $ProjectRoot -Filter "*.dart" -Recurse

$totalFiles = 0
$totalReplacements = 0

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    $newContent = $content -replace [regex]::Escape($OldIP), $NewIP
    
    if ($content -ne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        $replacements = ([regex]::Matches($content, [regex]::Escape($OldIP))).Count
        $totalReplacements += $replacements
        $totalFiles++
        Write-Host "✅ Updated: $($file.Name) ($replacements occurrences)"
    }
}

Write-Host ""
Write-Host "=" * 80
Write-Host "✅ Complete! Updated $totalReplacements occurrences in $totalFiles files"
Write-Host "=" * 80
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Run backend: cd django-backend && python manage.py runserver 0.0.0.0:8000"
Write-Host "2. Run Flutter: cd otp_phone_auth && flutter run"
