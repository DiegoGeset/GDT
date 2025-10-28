# =========================================================
# Script: Get-Install Google Chrome via Winget
# =========================================================

$ErrorActionPreference = "Stop"

Write-Host "Verificando instalação do Google Chrome..." -ForegroundColor Cyan

# Caminhos comuns de instalação
$chromePaths = @(
    "$Env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "$Env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe",
    "$Env:LocalAppData\Google\Chrome\Application\chrome.exe"
)

# Verifica se já está instalado
$chromeInstalled = $chromePaths | Where-Object { Test-Path $_ }

if ($chromeInstalled) {
    Write-Host "Google Chrome já está instalado em:" -ForegroundColor Green
    $chromeInstalled | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }

    try {
        $version = (& "$($chromeInstalled | Select-Object -First 1)" --version 2>&1)
        Write-Host "Versão instalada: $version" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Não foi possível detectar a versão." -ForegroundColor DarkYellow
    }
}
else {
    Write-Host "Google Chrome não encontrado. Instalando via winget..." -ForegroundColor Red

    try {
        Write-Host "Instalando Google Chrome via winget..." -ForegroundColor Cyan
        Start-Process "winget" -ArgumentList "install --id=Google.Chrome -e --silent" -Wait

        Start-Sleep -Seconds 5

        # Verifica novamente a instalação
        $chromeInstalled = $chromePaths | Where-Object { Test-Path $_ }

        if ($chromeInstalled) {
            Write-Host "Instalação concluída com sucesso!" -ForegroundColor Green
        }
        else {
            Write-Host "Erro: instalação não detectada após execução." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Falha durante a instalação via winget: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Processo concluído!" -ForegroundColor Cyan
