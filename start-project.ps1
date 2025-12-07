# Script de démarrage du projet Dräxlmaier
# Utilisation: .\start-project.ps1 [local|atlas]

param(
    [string]$Mode = "local"
)

Write-Host "🚀 Démarrage du projet Dräxlmaier" -ForegroundColor Cyan
Write-Host ""

# Fonction pour vérifier si un port est utilisé
function Test-Port {
    param([int]$Port)
    try {
        $connection = New-Object System.Net.Sockets.TcpClient("127.0.0.1", $Port)
        $connection.Close()
        return $true
    }
    catch {
        return $false
    }
}

# Vérifier si MongoDB est requis
if ($Mode -eq "local") {
    Write-Host "📦 Mode MongoDB Local" -ForegroundColor Yellow
    
    # Vérifier si MongoDB est installé
    $mongoInstalled = Get-Command mongod -ErrorAction SilentlyContinue
    
    if ($null -eq $mongoInstalled) {
        Write-Host "❌ MongoDB n'est pas installé" -ForegroundColor Red
        Write-Host ""
        Write-Host "Options d'installation:" -ForegroundColor Yellow
        Write-Host "1. Télécharger: https://www.mongodb.com/try/download/community"
        Write-Host "2. Chocolatey: choco install mongodb"
        Write-Host "3. Docker: docker run -d -p 27017:27017 --name mongodb mongo:latest"
        Write-Host ""
        exit 1
    }
    
    # Vérifier si MongoDB est déjà en cours d'exécution
    if (!(Test-Port -Port 27017)) {
        Write-Host "▶️  Démarrage de MongoDB..." -ForegroundColor Green
        Start-Process mongod -WindowStyle Hidden
        Start-Sleep -Seconds 3
    } else {
        Write-Host "✅ MongoDB déjà en cours d'exécution" -ForegroundColor Green
    }
    
    # Copier .env.local vers .env
    Copy-Item "backend\.env.local" "backend\.env" -Force
    Write-Host "✅ Configuration MongoDB Local activée" -ForegroundColor Green
} else {
    Write-Host "☁️  Mode MongoDB Atlas" -ForegroundColor Yellow
    Write-Host "⚠️  Assurez-vous d'avoir une connexion Internet" -ForegroundColor Yellow
}

Write-Host ""

# Démarrer le backend
Write-Host "📡 Démarrage du backend (port 3000)..." -ForegroundColor Cyan

$backendPath = Join-Path $PSScriptRoot "backend"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; npm start" -WindowStyle Normal

Start-Sleep -Seconds 3

# Attendre que le backend soit prêt
$maxRetries = 10
$retry = 0
$backendReady = $false

Write-Host "⏳ Attente du démarrage du backend..." -ForegroundColor Yellow

while ($retry -lt $maxRetries -and !$backendReady) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -Method Get -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $backendReady = $true
            Write-Host "✅ Backend démarré avec succès!" -ForegroundColor Green
        }
    }
    catch {
        $retry++
        Start-Sleep -Seconds 2
        Write-Host "." -NoNewline
    }
}

Write-Host ""

if (!$backendReady) {
    Write-Host "⚠️  Le backend prend plus de temps que prévu..." -ForegroundColor Yellow
    Write-Host "   Vérifiez la console du backend pour les erreurs" -ForegroundColor Yellow
}

Write-Host ""

# Démarrer le frontend
Write-Host "🎨 Démarrage du frontend Flutter (port 8080)..." -ForegroundColor Cyan

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot'; flutter run -d chrome --web-port=8080" -WindowStyle Normal

Write-Host ""
Write-Host "✨ Projet démarré!" -ForegroundColor Green
Write-Host ""
Write-Host "URLs:" -ForegroundColor Cyan
Write-Host "  Backend:  http://localhost:3000" -ForegroundColor White
Write-Host "  Frontend: http://localhost:8080" -ForegroundColor White
Write-Host "  Health:   http://localhost:3000/health" -ForegroundColor White
Write-Host ""
Write-Host "📚 Voir GUIDE_DEMARRAGE.md pour plus d'informations" -ForegroundColor Yellow
Write-Host ""
