# =========================================================
# Script: Get-Install CCleaner via Winget
# Função: Verifica se o CCleaner está instalado e instala caso não esteja
# =========================================================

# --- Reinicia elevado se necessário ---
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Este script precisa ser executado como Administrador. Reiniciando com privilégios elevados..."
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$ErrorActionPreference = "Stop"

Write-Host "Verificando instalação do CCleaner..." 

# Caminhos comuns de instalação
$ccleanerPaths = @(
    "$Env:ProgramFiles\CCleaner\CCleaner.exe",
    "$Env:ProgramFiles(x86)\CCleaner\CCleaner.exe"
)

# Verifica instalação
$ccleanerInstalled = $ccleanerPaths | Where-Object { Test-Path $_ }

if ($ccleanerInstalled) {
    Write-Host "CCleaner já está instalado em:"
    $ccleanerInstalled | ForEach-Object { Write-Host "   $_" }

    try {
        $exe = $ccleanerInstalled | Select-Object -First 1
        $version = (Get-Item $exe).VersionInfo.ProductVersion
        Write-Host "Versão instalada: $version"
    }
    catch {
        Write-Host "Não foi possível detectar a versão: $_"
    }
}
else {
    Write-Host "CCleaner não encontrado. Instalando via winget..."

    try {
        Write-Host "Executando: winget install --id=Piriform.CCleaner -e --silent"
        Start-Process "winget" -ArgumentList "install --id=Piriform.CCleaner -e --silent" -Wait

        Start-Sleep -Seconds 5

        # Verifica novamente
        $ccleanerInstalled = $ccleanerPaths | Where-Object { Test-Path $_ }

        if ($ccleanerInstalled) {
            Write-Host "Instalação concluída com sucesso!"
            try {
                $exe = $ccleanerInstalled | Select-Object -First 1
                $version = (Get-Item $exe).VersionInfo.ProductVersion
                Write-Host "Versão instalada: $version"
            } catch {
                Write-Host "Instalação detectada, mas não foi possível obter a versão: $_"
            }
        }
        else {
            Write-Host "Erro: instalação não detectada após execução do winget."
            Write-Host "Você pode tentar executar manualmente: winget install --id=Piriform.CCleaner -e --silent"
        }
    }
    catch {
        Write-Host "Falha durante a instalação via winget: $_"
    }
}

Write-Host ""
Write-Host "Processo concluído."
