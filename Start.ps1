# ========================================================
# GESET - Atualizador Automático via GitHub (GDT)
# ========================================================

$ErrorActionPreference = "Stop"
$repoUser = "DiegoGeset"
$repoName = "GDT"
$repoBranch = "main"
$localPath = "C:\GESET"
$zipFile = Join-Path $localPath "versao.zip"
$versionFile = Join-Path $localPath "version.txt"
$remoteVersionURL = "https://raw.githubusercontent.com/DiegoGeset/GDT/refs/heads/main/Version.txt?token=GHSAT0AAAAAADM5ABLN3HXNLLCTUD5O5VOU2H7VYWQ"
$zipDownloadURL = "https://github.com/DiegoGeset/GDT/archive/refs/tags/1.0.0.zip"
$mainScript = Join-Path $localPath "$repoName-main\gdt.ps1"

function Download-File($url, $dest) {
    Write-Host "Baixando: $url..."
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

# --- Cria pasta se não existir ---
if (!(Test-Path $localPath)) {
    Write-Host "Criando pasta: $localPath"
    New-Item -Path $localPath -ItemType Directory | Out-Null
}

# --- Obtém versão remota ---
$remoteVersion = $null
try {
    $remoteVersion = (Invoke-WebRequest -Uri $remoteVersionURL -UseBasicParsing).Content.Trim()
    if ([string]::IsNullOrWhiteSpace($remoteVersion)) { $remoteVersion = $null }
} catch {
    Write-Host "⚠️ Não foi possível obter a versão remota."
}

# --- Obtém versão local ---
$localVersion = $null
if (Test-Path $versionFile) {
    $localVersion = (Get-Content $versionFile -Raw).Trim()
}

Write-Host "Versão local:  $($localVersion ?? 'nenhuma')"
Write-Host "Versão remota: $($remoteVersion ?? 'desconhecida')"

# --- Determina se precisa atualizar/baixar ---
$precisaAtualizar = $false

if (-not (Test-Path $mainScript)) {
    Write-Host "⚙️ Script principal não encontrado. Baixando pacote..."
    $precisaAtualizar = $true
}
elseif (-not $remoteVersion) {
    Write-Host "⚙️ Versão remota não disponível. Forçando reinstalação..."
    $precisaAtualizar = $true
}
elseif ($localVersion -ne $remoteVersion) {
    Write-Host "🆕 Nova versão detectada."
    $precisaAtualizar = $true
}
else {
    Write-Host "Nenhuma atualização necessária."
}

# --- Atualiza ou instala ---
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
    }
    catch {
        Write-Host "❌ Erro durante a atualização: $($_.Exception.Message)"
    }
}

# --- Executa script principal ---
if (Test-Path $mainScript) {
    Write-Host "🚀 Iniciando script principal (gdt.ps1)..."
    & powershell -ExecutionPolicy Bypass -File $mainScript
} else {
    Write-Host "❌ ERRO: Script principal não encontrado após atualização."
}
