# =========================================================
# Script: Get-Install Java (JRE/JDK) via Winget
# Função: Verifica se o Java está instalado e instala caso não esteja
# =========================================================

$ErrorActionPreference = "Stop"

Write-Host "Verificando instalação do Java..." -ForegroundColor Cyan

# Caminhos comuns de instalação (JRE e JDK)
$javaPaths = @(
    "$Env:ProgramFiles\Java\jre*",
    "$Env:ProgramFiles\Java\jdk*",
    "$Env:ProgramFiles(x86)\Java\jre*",
    "$Env:ProgramFiles(x86)\Java\jdk*"
)

# Procura por java.exe
$javaInstalled = $javaPaths | ForEach-Object { Get-ChildItem -Path $_ -Filter "java.exe" -Recurse -ErrorAction SilentlyContinue } | Select-Object -First 1

if ($javaInstalled) {
    Write-Host "Java já está instalado em:"
    Write-Host "   $($javaInstalled.DirectoryName)"
    try {
        $version = (& "$($javaInstalled.FullName)" -version 2>&1 | Select-String "version").ToString()
        Write-Host "Versão instalada: $version" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Não foi possível detectar a versão." -ForegroundColor DarkYellow
    }
}
else {
    Write-Host "Java não encontrado. Instalando via winget..." -ForegroundColor Red
    try {
        Write-Host "Instalando Java via winget..." -ForegroundColor Cyan
        Start-Process "winget" -ArgumentList "install --id=Oracle.JavaRuntimeEnvironment -e --silent" -Wait
        Start-Sleep -Seconds 5

        # Verifica novamente a instalação
        $javaInstalled = $javaPaths | ForEach-Object { Get-ChildItem -Path $_ -Filter "java.exe" -Recurse -ErrorAction SilentlyContinue } | Select-Object -First 1

        if ($javaInstalled) {
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

# Desabilitar atualizações automáticas do Java
try {
    Write-Host "Configurando Java para desabilitar atualizações automáticas..." -ForegroundColor Cyan

    $regPaths = @(
        "HKLM:\SOFTWARE\JavaSoft\Java Update\Policy",
        "HKLM:\SOFTWARE\WOW6432Node\JavaSoft\Java Update\Policy"
    )

    foreach ($regPath in $regPaths) {
        if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
        New-ItemProperty -Path $regPath -Name "EnableJavaUpdate" -Value 0 -PropertyType DWord -Force | Out-Null
    }

    Write-Host "Atualizações automáticas do Java desabilitadas." -ForegroundColor Green
}
catch {
    Write-Host "Não foi possível desabilitar atualizações automáticas: $_" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "Processo concluído!" -ForegroundColor Cyan
