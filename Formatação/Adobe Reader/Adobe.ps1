# =========================================================
# Script: Get-Install Adobe Acrobat Reader DC via Winget
# =========================================================

$ErrorActionPreference = "Stop"

Write-Host "Verificando instalação do Adobe Acrobat Reader..." -ForegroundColor Cyan

# Caminhos padrão de instalação
$readerPaths = @(
    "$Env:ProgramFiles\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe",
    "$Env:ProgramFiles(x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe"
)

# Verifica se já está instalado
$readerInstalled = $readerPaths | Where-Object { Test-Path $_ }

if ($readerInstalled) {
    Write-Host "✅ Adobe Acrobat Reader já está instalado em:" -ForegroundColor Green
    $readerInstalled | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
}
else {
    Write-Host "❌ Adobe Acrobat Reader não encontrado. Instalando via winget..." -ForegroundColor Red

    try {
        # Instala a versão mais recente do Adobe Acrobat Reader DC
        Write-Host "⬇️ Instalando via winget..." -ForegroundColor Cyan
        Start-Process "winget" -ArgumentList "install --id=Adobe.Acrobat.Reader.64-bit -e --silent" -Wait

        Start-Sleep -Seconds 5

        # Verifica novamente a instalação
        $readerInstalled = $readerPaths | Where-Object { Test-Path $_ }

        if ($readerInstalled) {
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

# =========================================================
# Definir Adobe Reader como padrão para PDFs
# =========================================================
try {
    $acroPath = ($readerPaths | Where-Object { Test-Path $_ } | Select-Object -First 1)
    if ($acroPath) {
        Write-Host "📂 Definindo Adobe Reader como padrão para arquivos .PDF..." -ForegroundColor Cyan

        $assocCmd = 'assoc .pdf=AcroExch.Document.DC'
        $ftypeCmd = "ftype AcroExch.Document.DC=`"$acroPath`" `"%1`""

        cmd /c $assocCmd | Out-Null
        cmd /c $ftypeCmd | Out-Null

        Write-Host "✅ Adobe Reader definido como aplicativo padrão para PDF." -ForegroundColor Green
    }
}
catch {
    Write-Host "⚠️ Não foi possível aplicar a associação de arquivos: $_" -ForegroundColor DarkYellow
}

Write-Host "`n🎯 Processo concluído!" -ForegroundColor Cyan
