# Script pour arrêter le projet Dräxlmaier
# Utilisation: .\stop-project.ps1

Write-Host "🛑 Arrêt du projet Dräxlmaier" -ForegroundColor Cyan
Write-Host ""

# Fonction pour tuer les processus sur un port
function Stop-ProcessOnPort {
    param([int]$Port)
    
    try {
        $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        foreach ($connection in $connections) {
            $process = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "⏹️  Arrêt du processus $($process.ProcessName) (PID: $($process.Id)) sur port $Port" -ForegroundColor Yellow
                Stop-Process -Id $process.Id -Force
            }
        }
        Write-Host "✅ Port $Port libéré" -ForegroundColor Green
    }
    catch {
        Write-Host "ℹ️  Aucun processus sur le port $Port" -ForegroundColor Gray
    }
}

# Arrêter le backend (port 3000)
Write-Host "📡 Arrêt du backend..." -ForegroundColor Cyan
Stop-ProcessOnPort -Port 3000

# Arrêter le frontend (port 8080)
Write-Host "🎨 Arrêt du frontend..." -ForegroundColor Cyan
Stop-ProcessOnPort -Port 8080

# Arrêter les processus Node.js et Dart
Write-Host ""
Write-Host "🔍 Nettoyage des processus restants..." -ForegroundColor Cyan

$nodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue
foreach ($process in $nodeProcesses) {
    if ($process.MainWindowTitle -like "*employee-communication-backend*" -or 
        $process.Path -like "*projet flutter\backend*") {
        Write-Host "⏹️  Arrêt du processus Node.js (PID: $($process.Id))" -ForegroundColor Yellow
        Stop-Process -Id $process.Id -Force
    }
}

$dartProcesses = Get-Process -Name dart -ErrorAction SilentlyContinue
foreach ($process in $dartProcesses) {
    if ($process.Path -like "*projet flutter*") {
        Write-Host "⏹️  Arrêt du processus Dart (PID: $($process.Id))" -ForegroundColor Yellow
        Stop-Process -Id $process.Id -Force
    }
}

Write-Host ""
Write-Host "✅ Projet arrêté avec succès!" -ForegroundColor Green
Write-Host ""
