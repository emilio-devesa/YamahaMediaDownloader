# Yamaha Media Downloader Setup Script (Windows)
# Author: Emilio Devesa
# Description: Automatically configures the environment for Yamaha Media Downloader

Write-Host "Setting up Yamaha Media Downloader..." -ForegroundColor Cyan

function Install-PythonManual {
    Write-Host "⬇️ Descargando instalador de Python 3.11..." -ForegroundColor Cyan
    $installer = "$env:TEMP\python-installer.exe"
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe" -OutFile $installer
    Start-Process -Wait -FilePath $installer -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_pip=1"
}

# --- Detect Python ---
$python = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command python -ErrorAction SilentlyContinue }
if (-not $pythonCmd) {
    Write-Host "`n⚠️  Python no está instalado o no está en PATH." -ForegroundColor Yellow
    Write-Host "Intentando instalarlo automáticamente..."

    # Intentar con winget
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    $choco = Get-Command choco -ErrorAction SilentlyContinue

    if ($winget) {
        Write-Host "`nUsando winget para instalar Python..." -ForegroundColor Cyan
        try {
            Start-Process -Wait -NoNewWindow -FilePath "winget" -ArgumentList "install --id Python.Python.3.11 -e --source winget -h"
        } catch {
            Write-Host "⚠️  winget falló. Usando instalación directa..." -ForegroundColor Yellow
            Install-PythonManual
        }
    } elseif ($choco) {
        Write-Host "`nUsando Chocolatey para instalar Python..." -ForegroundColor Cyan
        choco install python -y
    } else {
        Write-Host "`n❌ No se encontró ni winget ni choco. Instala Python manualmente desde:" -ForegroundColor Red
        Write-Host "   https://www.python.org/downloads/windows/"
        exit 1
    }

    # Reintentar búsqueda
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCmd) { $pythonCmd = Get-Command py -ErrorAction SilentlyContinue }

    if (-not $pythonCmd) {
        Write-Host "`n❌ No se pudo instalar ni encontrar Python automáticamente." -ForegroundColor Red
        exit 1
    }
}

# --- Create virtual environment ---
if (-not (Test-Path "venv")) {
    Write-Host "Creating virtual environment..." -ForegroundColor Yellow
    & python -m venv venv
} else {
    Write-Host "Virtual environment already exists." -ForegroundColor Green
}

# --- Activate environment ---
Write-Host "Activating environment..."
. .\venv\Scripts\Activate.ps1

# --- Install dependencies ---
Write-Host "Installing dependencies..." -ForegroundColor Yellow
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

# --- Choose browser ---
Write-Host ""
Write-Host "Choose your browser:" -ForegroundColor Cyan
Write-Host "1) Brave"
Write-Host "2) Chrome"
Write-Host "3) Edge"
Write-Host "4) Safari (not supported on Windows)"
$choice = Read-Host "Select an option [1-4]"

switch ($choice) {
    "1" { $browser = "brave"; $defaultPath = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" }
    "2" { $browser = "chrome"; $defaultPath = "C:\Program Files\Google\Chrome\Application\chrome.exe" }
    "3" { $browser = "edge"; $defaultPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" }
    "4" {
        Write-Host "Safari is not available on Windows." -ForegroundColor Red
        deactivate
        exit 1
    }
    default {
        Write-Host "Invalid option." -ForegroundColor Red
        deactivate
        exit 1
    }
}

Write-Host ""
Write-Host "Browser setup for $browser"
$inputPath = Read-Host "Enter the full path to the browser executable [`"$defaultPath`"]"
if (-not $inputPath) { $inputPath = $defaultPath }

if (-not (Test-Path $inputPath)) {
    Write-Host "Could not find browser binary at: $inputPath" -ForegroundColor Red
    exit 1
}

# --- Determine driver path ---
$driverPath = ""
$driverName = ""

switch ($browser) {
    "edge" {
        $driverPath = "C:\Program Files\msedgedriver.exe"
        $driverName = "msedgedriver"
    }
    default {
        $driverPath = "C:\Program Files\chromedriver.exe"
        $driverName = "chromedriver"
    }
}

Write-Host ""
Write-Host "Checking for WebDriver..." -ForegroundColor Cyan

if (-not (Test-Path $driverPath)) {
    Write-Host "Installing webdriver-manager..." -ForegroundColor Yellow
    python -m pip install webdriver-manager
    Write-Host "WebDriver will be managed automatically by WebDriver Manager." -ForegroundColor Green
} else {
    Write-Host "Found $driverName at $driverPath" -ForegroundColor Green
}

# --- Save configuration ---
$envLines = @()
$envLines += "BROWSER=`"$browser`""
$envLines += "BROWSER_PATH=`"$inputPath`""

switch ($browser) {
    "brave" { $envLines += "CHROMEDRIVER_PATH=`"$driverPath`"" }
    "chrome" { $envLines += "CHROMEDRIVER_PATH=`"$driverPath`"" }
    "edge" { $envLines += "EDGEDRIVER_PATH=`"$driverPath`"" }
}

$envLines | Out-File -Encoding UTF8 ".env"

Write-Host ""
Write-Host "Configuration saved to .env file." -ForegroundColor Green

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Cyan
Write-Host "To activate your environment later, run:" -ForegroundColor White
Write-Host "   .\venv\Scripts\Activate.ps1" -ForegroundColor Yellow
