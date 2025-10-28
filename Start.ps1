# ========================================================
# GESET - Atualizador Automático via GitHub (GDT)
# ========================================================

$ErrorActionPreference = "Stop"

# Configurações
$repoUser   = "DiegoGeset"
$repoName   = "GDT"
$localPath  = "C:\GESET"
$zipFile    = Join-Path $localPath "versao.zip"
$remoteZip  = ""  # Será definido dinamicamente

# Função para download
function Download-File($url, $dest) {
    Write-Host "Baixando: $url..."
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

# Função para obter última versão do GitHub
function Get-LatestRelease {
    try {
        $apiUrl = "https://api.github.com/repos/$repoUser/$repoName/releases/latest"
        $release = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
        return $release.tag_name
    } catch {
        Write-Host "⚠️ Não foi possível obter a versão mais recente. Usando valor padrão."
        return "1.0.1"  # fallback caso a API falhe
    }
}

# Detecta última versão
$latestVersion = Get-LatestRelease
$remoteZip = "https://github.com/$repoUser/$repoName/archive/refs/tags/$latestVersion.zip"

# Cria pasta se não existir
if (!(Test-Path $localPath)) {
    Write-Host "Criando pasta: $localPath"
    New-Item -Path $localPath -ItemType Directory | Out-Null
}

# Baixa e atualiza sempre
try {
    if (Test-Path $zipFile) { Remove-Item $zipFile -Force }

    Write-Host "📦 Baixando nova versão ($latestVersion)..."
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
