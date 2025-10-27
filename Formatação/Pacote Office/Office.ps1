# ============================================
# Script de Instalação do Pacote Office
# Autor: Diego Geset
# ============================================

# --- Diretório Temporário ---
$tempDir = "$env:TEMP\Instaladores"
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir | Out-Null }

# --- Função de Download usando BITS ---
function Download-Com-Progresso {
    param (
        [string]$url,
        [string]$destino
    )

    try {
        Write-Host "⬇️  Baixando $(Split-Path $destino -Leaf)..." -ForegroundColor Cyan
        Import-Module BitsTransfer -ErrorAction SilentlyContinue

        if (Test-Path $destino) { Remove-Item -Path $destino -Force -ErrorAction SilentlyContinue }

        Start-BitsTransfer -Source $url -Destination $destino -DisplayName "Baixando $(Split-Path $destino -Leaf)"
        Write-Host "✅ Download concluído: $destino" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "`n❌ Falha ao baixar $(Split-Path $destino -Leaf): $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# --- Função para selecionar versão do Office ---
function Escolhe-VersaoOffice {
    Write-Host "`n💡 Escolha a versão do Office que deseja instalar:" -ForegroundColor Cyan
    Write-Host "1. Office 2024 Pro Plus 64 bits"
    Write-Host "2. Office 2021 Pro Plus 64 bits"
    Write-Host "3. Office 2019 Pro Plus 64 bits"
    Write-Host "4. Office 2016 Pro Plus 64 bits"

    do {
        $opcao = Read-Host "Digite o número da opção desejada (1-4)"
    } while ($opcao -notin '1','2','3','4')

    switch ($opcao) {
        '1' { return @("Office 2024 Pro Plus", "https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/pt-br/ProPlus2024Retail.img") }
        '2' { return @("Office 2021 Pro Plus", "https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/pt-br/ProPlus2021Retail.img") }
        '3' { return @("Office 2019 Pro Plus", "https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/pt-br/ProPlus2019Retail.img") }
        '4' { return @("Office 2016 Pro Plus", "http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/pt-BR/ProfessionalRetail.img") }
    }
}

# --- Função para Instalar o Office Pro Plus ---
function Instala-OfficeProPlus {
    param (
        [string]$nome,
        [string]$url
    )

    $imgPath = Join-Path $tempDir "$nome.img"

    Write-Host "`n⚙️  Verificando ${nome}..." -ForegroundColor Yellow

    $officeInstall = $false
    $officeExePaths = @(
        "$env:ProgramFiles\Microsoft Office\root\Office16\WINWORD.EXE",
        "$env:ProgramFiles(x86)\Microsoft Office\root\Office16\WINWORD.EXE"
    )
    foreach ($exe in $officeExePaths) { if (Test-Path $exe) { $officeInstall = $true; break } }

    if ($officeInstall) {
        Write-Host "⚠️  Detectado Office existente. Remova manualmente se quiser reinstalar." -ForegroundColor DarkYellow
        return
    }

    if (-not (Download-Com-Progresso -url $url -destino $imgPath)) { return }

    Write-Host "🗂️  Montando a imagem do Office..." -ForegroundColor Cyan
    try {
        $disk = Mount-DiskImage -ImagePath $imgPath -PassThru

        $driveLetter = $null
        $timeout = 30
        $elapsed = 0
        while (-not $driveLetter -and $elapsed -lt $timeout) {
            $volume = $disk | Get-Volume -ErrorAction SilentlyContinue
            if ($volume) { $driveLetter = $volume.DriveLetter + ":" }
            Start-Sleep -Seconds 1
            $elapsed++
        }

        if (-not $driveLetter) {
            Write-Host "❌ Não foi possível obter a letra da unidade montada." -ForegroundColor Red
            return
        }

        Write-Host "✅ Imagem montada em ${driveLetter}" -ForegroundColor Green

        $arquitetura = if ([Environment]::Is64BitOperatingSystem) { "64" } else { "32" }
        $setupFile = "Setup$arquitetura.exe"
        $setupPath = Join-Path $driveLetter "Office\$setupFile"

        if (Test-Path $setupPath) {
            Write-Host "⬇️  Iniciando instalação do ${nome} ($arquitetura-bit)..." -ForegroundColor Cyan
            Start-Process -FilePath $setupPath -Wait -Verb RunAs
            Write-Host "✅ Instalação concluída!" -ForegroundColor Green
        } else {
            Write-Host "❌ $setupFile não encontrado na imagem." -ForegroundColor Red
        }

    } catch {
        Write-Host "❌ Falha ao instalar ${nome}: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        Write-Host "🗑️  Desmontando imagem..." -ForegroundColor Yellow
        Dismount-DiskImage -ImagePath $imgPath -ErrorAction SilentlyContinue
        Remove-Item $imgPath -Force -ErrorAction SilentlyContinue
        Write-Host "🧹 Arquivos temporários removidos." -ForegroundColor Green
    }
}

# --- Função para criar atalhos do Office ---
function Criar-AtalhosOffice {
    Write-Host "`n💡 Criando atalhos do Office na Área de Trabalho Pública..." -ForegroundColor Cyan

    $systemDrive = $env:SystemDrive
    $startMenuPath = Join-Path $systemDrive "ProgramData\Microsoft\Windows\Start Menu\Programs"
    $desktopPublic = Join-Path $systemDrive "Users\Public\Desktop"

    $officeAtalhos = @("Word.lnk","Excel.lnk","PowerPoint.lnk","Outlook.lnk")
    foreach ($atalho in $officeAtalhos) {
        $atalhoCompleto = Get-ChildItem -Path $startMenuPath -Filter $atalho -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($atalhoCompleto) {
            Copy-Item -Path $atalhoCompleto.FullName -Destination $desktopPublic -Force
            Write-Host "✅ Atalho $atalho copiado." -ForegroundColor Green
        } else {
            Write-Host "⚠️ Atalho $atalho não encontrado." -ForegroundColor Yellow
        }
    }
}

# --- Função para remover atalhos indesejados ---
function Remover-AtalhosIndesejados {
    Write-Host "`n🗑️ Removendo atalhos indesejados da Área de Trabalho Pública..." -ForegroundColor Cyan

    $systemDrive = $env:SystemDrive
    $desktopPublic = Join-Path $systemDrive "Users\Public\Desktop"
    $atalhosRemover = @("Adobe Acrobat.lnk", "Ccleaner 7.lnk")

    foreach ($atalho in $atalhosRemover) {
        $caminhoCompleto = Join-Path $desktopPublic $atalho
        if (Test-Path $caminhoCompleto) {
            Remove-Item -Path $caminhoCompleto -Force
            Write-Host "✅ Atalho $atalho removido." -ForegroundColor Green
        } else {
            Write-Host "⚠️ Atalho $atalho não encontrado." -ForegroundColor Yellow
        }
    }
}

# --- Fluxo de instalação do Office ---
Write-Host "`n🚀 Iniciando instalação do Pacote Office..." -ForegroundColor Cyan

$officeEscolhido = Escolhe-VersaoOffice
Instala-OfficeProPlus -nome $officeEscolhido[0] -url $officeEscolhido[1]

Criar-AtalhosOffice
Remover-AtalhosIndesejados

# --- Limpeza final ---
Write-Host "`n🧹 Limpando arquivos temporários..." -ForegroundColor Yellow
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "✅ Processo concluído. Sistema pronto para uso!" -ForegroundColor Green
