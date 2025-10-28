# =========================================================
# Script: Get-Install Google Chrome via Winget
# =========================================================

$ErrorActionPreference = "Stop"

Write-Host "Verificando instala��o do Google Chrome..." -ForegroundColor Cyan

# Caminhos comuns de instala��o
$chromePaths = @(
    "$Env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "$Env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe",
    "$Env:LocalAppData\Google\Chrome\Application\chrome.exe"
)

# Verifica se j� est� instalado
$chromeInstalled = $chromePaths | Where-Object { Test-Path $_ }

if ($chromeInstalled) {
    Write-Host "Google Chrome j� est� instalado em:" -ForegroundColor Green
    $chromeInstalled | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }

    try {
        $version = (& "$($chromeInstalled | Select-Object -First 1)" --version 2>&1)
        Write-Host "Vers�o instalada: $version" -ForegroundColor Yellow
    }
    catch {
        Write-Host "N�o foi poss�vel detectar a vers�o." -ForegroundColor DarkYellow
    }
}
else {
    Write-Host "Google Chrome n�o encontrado. Instalando via winget..." -ForegroundColor Red

    try {
        Write-Host "Instalando Google Chrome via winget..." -ForegroundColor Cyan
        Start-Process "winget" -ArgumentList "install --id=Google.Chrome -e --silent" -Wait

        Start-Sleep -Seconds 5

        # Verifica novamente a instala��o
        $chromeInstalled = $chromePaths | Where-Object { Test-Path $_ }

        if ($chromeInstalled) {
            Write-Host "Instala��o conclu�da com sucesso!" -ForegroundColor Green
        }
        else {
            Write-Host "Erro: instala��o n�o detectada ap�s execu��o." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Falha durante a instala��o via winget: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Processo conclu�do!" -ForegroundColor Cyan
