# ========================================================
# GESET - Atualizador Automático via GitHub (GDT)
# ========================================================

$ErrorActionPreference = "Stop"

# Configurações
$repoUser   = "DiegoGeset"
$repoName   = "GDT"
$localPath  = "C:\GESET"
$zipFile    = Join-Path $localPath "versao.zip"
$remoteZip  = "https://github.com/DiegoGeset/GDT/archive/refs/tags/1.0.0.zip"

# Função para download
function Download-File($url, $dest) {
    Write-Host "Baixando: $url..."
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

# Cria pasta se não existir
if (!(Test-Path $localPath)) {
    Write-Host "Criando pasta: $localPath"
    New-Item -Path $localPath -ItemType Directory | Out-Null
}

# Baixa e atualiza sempre
try {
    if (Test-Path $zipFile) { Remove-Item $zipFile -Force }

    Write-Host "📦 Baixando nova versão..."
    Download-File $remoteZip $zipFile

    Write-Host "🗑️ Limpando versão anterior..."
    Get-ChildItem -Path $localPath -Exclude "versao.zip" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "📂 Extraindo arquivos..."
    Expand-Archive -Path $zipFile -DestinationPath $localPath -Force

    Write-Host "✅ Instalação/Atualização concluída."
} catch {
    Write-Host "❌ Erro durante a atualização: $($_.Exception.Message)"
}

# Localiza e executa o gdt.ps1
$gdtScript = Get-ChildItem -Path $localPath -Recurse -Filter "gdt.ps1" | Select-Object -First 1

if ($gdtScript) {
    Write-Host "🚀 Iniciando script principal (gdt.ps1)..."
    & powershell -ExecutionPolicy Bypass -File $gdtScript.FullName
} else {
    Write-Host "❌ ERRO: Script principal não encontrado."
}
