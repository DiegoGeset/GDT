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
$mainScript = Join-Path $localPath "$repoName-main\gdt.ps1"   # 👈 AQUI ALTERADO

function Download-File($url, $dest) {
    Write-Host "Baixando: $url..."
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

if (!(Test-Path $localPath)) {
    Write-Host "Criando pasta: $localPath"
    New-Item -Path $localPath -ItemType Directory | Out-Null
}

try {
    $remoteVersion = (Invoke-WebRequest -Uri $remoteVersionURL -UseBasicParsing).Content.Trim()
} catch {
    Write-Host "❌ Não foi possível obter a versão remota."
    $remoteVersion = "0.0.0"
}

if (Test-Path $versionFile) {
    $localVersion = Get-Content $versionFile -Raw
} else {
    $localVersion = "0.0.0"
}

Write-Host "Versão local:  $localVersion"
Write-Host "Versão remota: $remoteVersion"

if ($localVersion -ne $remoteVersion) {
    Write-Host "🆕 Nova versão detectada. Atualizando..."
    if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
    
    Download-File $zipDownloadURL $zipFile

    Get-ChildItem -Path $localPath -Exclude "versao.zip" | Remove-Item -Recurse -Force

    Write-Host "Extraindo arquivos..."
    Expand-Archive -Path $zipFile -DestinationPath $localPath -Force

    $remoteVersion | Out-File $versionFile -Encoding UTF8

    Write-Host "✅ Atualização concluída."
} else {
    Write-Host "Nenhuma atualização necessária."
}

if (Test-Path $mainScript) {
    Write-Host "Iniciando script principal (gdt.ps1)..."
    & powershell -ExecutionPolicy Bypass -File $mainScript
} else {
    Write-Host "⚠️ Script principal não encontrado: $mainScript"
}
