# =========================================================
# Script: Get-Install Java (JRE/JDK) via Winget
# Fun��o: Verifica se o Java est� instalado e instala caso n�o esteja
# =========================================================

$ErrorActionPreference = "Stop"

Write-Host "Verificando instala��o do Java..." -ForegroundColor Cyan

# Caminhos comuns de instala��o (JRE e JDK)
$javaPaths = @(
    "$Env:ProgramFiles\Java\jre*",
    "$Env:ProgramFiles\Java\jdk*",
    "$Env:ProgramFiles(x86)\Java\jre*",
    "$Env:ProgramFiles(x86)\Java\jdk*"
)

# Procura por java.exe
$javaInstalled = $javaPaths | ForEach-Object { Get-ChildItem -Path $_ -Filter "java.exe" -Recurse -ErrorAction SilentlyContinue } | Select-Object -First 1

if ($javaInstalled) {
    Write-Host "Java j� est� instalado em:"
    Write-Host "   $($javaInstalled.DirectoryName)"
    try {
        $version = (& "$($javaInstalled.FullName)" -version 2>&1 | Select-String "version").ToString()
        Write-Host "Vers�o instalada: $version" -ForegroundColor Yellow
    }
    catch {
        Write-Host "N�o foi poss�vel detectar a vers�o." -ForegroundColor DarkYellow
    }
}
else {
    Write-Host "Java n�o encontrado. Instalando via winget..." -ForegroundColor Red
    try {
        Write-Host "Instalando Java via winget..." -ForegroundColor Cyan
        Start-Process "winget" -ArgumentList "install --id=Oracle.JavaRuntimeEnvironment -e --silent" -Wait
        Start-Sleep -Seconds 5

        # Verifica novamente a instala��o
        $javaInstalled = $javaPaths | ForEach-Object { Get-ChildItem -Path $_ -Filter "java.exe" -Recurse -ErrorAction SilentlyContinue } | Select-Object -First 1

        if ($javaInstalled) {
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

# Desabilitar atualiza��es autom�ticas do Java
try {
    Write-Host "Configurando Java para desabilitar atualiza��es autom�ticas..." -ForegroundColor Cyan

    $regPaths = @(
        "HKLM:\SOFTWARE\JavaSoft\Java Update\Policy",
        "HKLM:\SOFTWARE\WOW6432Node\JavaSoft\Java Update\Policy"
    )

    foreach ($regPath in $regPaths) {
        if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
        New-ItemProperty -Path $regPath -Name "EnableJavaUpdate" -Value 0 -PropertyType DWord -Force | Out-Null
    }

    Write-Host "Atualiza��es autom�ticas do Java desabilitadas." -ForegroundColor Green
}
catch {
    Write-Host "N�o foi poss�vel desabilitar atualiza��es autom�ticas: $_" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "Processo conclu�do!" -ForegroundColor Cyan
