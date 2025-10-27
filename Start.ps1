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
try {
    $remoteVersion = (Invoke-WebRequest -Uri $remoteVersionURL -UseBasicParsing).Content.Trim()
} catch {
    Write-Host "⚠️ Não foi possível obter a versão remota."
    $remoteVersion = $null
}

# --- Obtém versão local ---
if (Test-Path $versionFile) {
    $localVersion = Get-Content $versionFile -Raw
} else {
    $localVersion = $null
}

Write-Host "Versão local:  $($localVersion ?? 'nenhuma')"
Write-Host "Versão remota: $($remoteVersion ?? 'desconhecida')"

# --- Determina se deve atualizar ou instalar ---
$precisaAtualizar = $false

if (-not (Test-Path $mainScript)) {
    Write-Host "⚙️ Script principal não encontrado. Será baixado."
    $precisaAtualizar = $true
}
elseif (-not $remoteVersion) {
    Write-Host "⚙️ Não foi possível obter versão remota. Reinstalando por segurança."
    $precisaAtualizar = $true
}
elseif ($localVersion -ne $remoteVersion) {
    Write-Host "🆕 Nova versão detectada."
    $precisaAtualizar = $true
}
else {
    Write-Host "Nenhuma atualização necessária."
}

# --- Processo de atualização ---
if ($precisaAtualizar) {
    if (Test-Path $zipFile) { Remove-Item $zipFile -Force }

    Download-File $zipDownloadURL $zipFile

    Write-Host "Extraindo arquivos..."
    Expand-Archive -Path $zipFile -DestinationPath $localPath -Force

    if ($remoteVersion) {
        $remoteVersion | Out-File $versionFile -Encoding UTF8
    }

    Write-Host "✅ Instalação/Atualização concluída."
}

# --- Executa o script principal ---
if (Test-Path $mainScript) {
    Write-Host "Iniciando script principal (gdt.ps1)..."
    & powershell -ExecutionPolicy Bypass -File $mainScript
} else {
    Write-Host "❌ ERRO: Script principal não encontrado após atualização."
}
