# =========================================================
# Script: Get-Install 7-Zip via Winget
# Função: Verifica se o 7-Zip está instalado e instala caso não esteja
# =========================================================

$ErrorActionPreference = "Stop"

Write-Host "🔍 Verificando instalação do 7-Zip..." -ForegroundColor Cyan

# Caminhos comuns de instalação
$sevenZipPaths = @(
    "$Env:ProgramFiles\7-Zip\7z.exe",
    "$Env:ProgramFiles(x86)\7-Zip\7z.exe"
)

# Verifica se já está instalado
$sevenZipInstalled = $sevenZipPaths | Where-Object { Test-Path $_ }

if ($sevenZipInstalled) {
    Write-Host "✅ 7-Zip já está instalado em:" -ForegroundColor Green
    $sevenZipInstalled | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }

    try {
        # Obtém a versão instalada
        $version = (& "$($sevenZipInstalled | Select-Object -First 1)" -version 2>&1)
        Write-Host "📦 Versão instalada: $version" -ForegroundColor Yellow
    } catch {
        Write-Host "⚠️ Não foi possível detectar a versão." -ForegroundColor DarkYellow
    }
}
else {
    Write-Host "❌ 7-Zip não encontrado. Instalando via winget..." -ForegroundColor Red

    try {
        # Instala a versão mais recente do 7-Zip silenciosamente
        Write-Host "⬇️ Instalando 7-Zip via winget..." -ForegroundColor Cyan
        Start-Process "winget" -ArgumentList "install --id=7zip.7zip -e --silent" -Wait

        Start-Sleep -Seconds 5

        # Verifica novamente a instalação
        $sevenZipInstalled = $sevenZipPaths | Where-Object { Test-Path $_ }

        if ($sevenZipInstalled) {
            Write-Host "✅ Instalação concluída com sucesso!" -ForegroundColor Green
        }
        else {
            Write-Host "❌ Erro: instalação não detectada após execução." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ Falha durante a instalação via winget: $_" -ForegroundColor Red
    }
}

Write-Host "`n🎯 Processo concluído!" -ForegroundColor Cyan
