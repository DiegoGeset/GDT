# ========================================================
# GESET - Atualizador Automático via GitHub (GDT)
# ========================================================

$ErrorActionPreference = "Stop"

# Configurações
$repoUser   = "DiegoGeset"
$repoName   = "GDT"
$repoBranch = "main"

# Pastas locais
$localPath   = "C:\GESET"
$zipFile     = Join-Path $localPath "versao.zip"
$versionFile = Join-Path $localPath "version.txt"

# URLs
$remoteVersionURL = "https://raw.githubusercontent.com/DiegoGeset/GDT/main/Version.txt"
$zipDownloadURL   = "https://github.com/DiegoGeset/GDT/archive/refs/tags/1.0.0.zip"

# Função de download
function Download-File($url, $dest) {
    Write-Host "Baixando: $url..."
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

# Cria pasta
if (!(Test-Path $localPath)) {
    Write-Host "Criando pasta: $localPath"
    New-Item -Path $localPath -ItemType Directory | Out-Null
}

# Obtém versão remota
$remoteVersion = $null
try {
    $remoteVersion = (Invoke-WebRequest -Uri $remoteVersionURL -UseBasicParsing).Content.Trim()
    if ([string]::IsNullOrWhiteSpace($remoteVersion)) { $remoteVersion = $null }
} catch {
    Write-Host "⚠️ Não foi possível obter a versão remota."
}

# Obtém versão local
$localVersion = $null
if (Test-Path $versionFile) {
    $localVersion = (Get-Content $versionFile -Raw).Trim()
}

# Mostra versões de forma compatível com qualquer PowerShell
$localVerDisplay  = if ($localVersion -and $localVersion -ne '') { $localVersion } else { 'nenhuma' }
$remoteVerDisplay = if ($remoteVersion -and $remoteVersion -ne '') { $remoteVersion } else { 'desconhecida' }

Write-Host "Versão local:  $localVerDisplay"
Write-Host "Versão remota: $remoteVerDisplay"

# Determina se precisa atualizar
$precisaAtualizar = $false
$existingFolder = Get-ChildItem -Path $localPath -Directory | Where-Object { $_.Name -like "$repoName*" }
if (-not $existingFolder) {
    Write-Host "⚙️ Script principal não encontrado. Baixando pacote..."
    $precisaAtualizar = $true
} elseif (-not $remoteVersion) {
    Write-Host "⚙️ Versão remota não disponível. Forçando reinstalação..."
    $precisaAtualizar = $true
} elseif ($localVersion -ne $remoteVersion) {
    Write-Host "🆕 Nova versão detectada."
    $precisaAtualizar = $true
} else {
    Write-Host "Nenhuma atualização necessária."
}

# Atualiza ou instala
if ($precisaAtualizar) {
    try {
        if (Test-Path $zipFile) { Remove-Item $zipFile -Force }

        Write-Host "📦 Baixando nova versão..."
        Download-File $zipDownloadURL $zipFile

        Write-Host "🗑️ Limpando versão anterior..."
        Get-ChildItem -Path $localPath -Exclude "versao.zip" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host "📂 Extraindo arquivos..."
        Expand-Archive -Path $zipFile -DestinationPath $localPath -Force

        if ($remoteVersion) {
            $remoteVersion | Out-File $versionFile -Encoding UTF8
        }

        Write-Host "✅ Instalação/Atualização concluída."
    } catch {
        Write-Host "❌ Erro durante a atualização: $($_.Exception.Message)"
    }
}

# Procura o script principal em qualquer subpasta dentro do localPath
$mainScript = Get-ChildItem -Path $localPath -Filter "gdt.ps1" -Recurse -File | Select-Object -First 1

# Executa script principal
if ($mainScript -and (Test-Path $mainScript.FullName)) {
    Write-Host "🚀 Iniciando script principal (gdt.ps1)..."
    & powershell -ExecutionPolicy Bypass -File $mainScript.FullName
} else {
    Write-Host "❌ ERRO: Script principal não encontrado após atualização."
}
