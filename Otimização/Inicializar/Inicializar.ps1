# ============================================================
# Script: Gerenciador de Programas de Inicialização
# Função: Lista, ativa, desativa e recupera programas de inicialização (Startup)
# Autor: Geset (adaptado por GPT-5)
# Compatível com Windows 10 e 11
# ============================================================

# --- Verifica se está rodando como administrador ---
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "⛔ Este script precisa ser executado como administrador!" -ForegroundColor Red
    exit
}

# --- Caminhos de registro ---
$runUser = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$runSystem = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"

# --- Determina diretório base do script (ou diretório atual) ---
if ($MyInvocation.MyCommand.Definition) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
} else {
    $ScriptDir = Get-Location
}

$BackupDir = Join-Path $ScriptDir "Startup_Backup"

# --- Função para criar backup das chaves ---
function Backup-StartupRegistry {
    if (!(Test-Path $BackupDir)) { New-Item -Path $BackupDir -ItemType Directory | Out-Null }

    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $backupUser = Join-Path $BackupDir "Startup_User_$timestamp.reg"
    $backupSystem = Join-Path $BackupDir "Startup_System_$timestamp.reg"

    reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "$backupUser" /y | Out-Null
    reg export "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "$backupSystem" /y | Out-Null

    Write-Host "`n💾 Backup criado automaticamente em:" -ForegroundColor Green
    Write-Host " • Usuário: $backupUser"
    Write-Host " • Sistema: $backupSystem`n"
}

# --- Função para restaurar backup ---
function Restore-StartupRegistry {
    if (!(Test-Path $BackupDir)) {
        Write-Host "❌ Nenhum backup encontrado no diretório: $BackupDir" -ForegroundColor Red
        return
    }

    $backups = Get-ChildItem -Path $BackupDir -Filter "*.reg" | Sort-Object LastWriteTime -Descending
    if (-not $backups) {
        Write-Host "⚠️ Nenhum arquivo de backup encontrado para restaurar." -ForegroundColor Yellow
        return
    }

    Write-Host "`n=== Backups Disponíveis ===" -ForegroundColor Cyan
    $i = 1
    foreach ($b in $backups) {
        Write-Host "$i - $($b.Name)"
        $i++
    }

    $choice = Read-Host "Escolha o número do backup para restaurar"
    if ($choice -match '^\d+$' -and [int]$choice -le $backups.Count) {
        $selected = $backups[[int]$choice - 1]
        Write-Host "`n♻️ Restaurando backup: $($selected.FullName)" -ForegroundColor Yellow
        # Correção: executa reg import de forma silenciosa sem conflito de parâmetros
        Start-Process -FilePath "reg.exe" -ArgumentList "import `"$($selected.FullName)`"" -Wait -WindowStyle Hidden
        Write-Host "✅ Backup restaurado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "❌ Escolha inválida." -ForegroundColor Red
    }
}

# --- Função para listar programas de inicialização e criar backup ---
function Get-StartupPrograms {
    Write-Host "`n===== Programas de Inicialização =====`n" -ForegroundColor Cyan

    $userItems = @()
    $systemItems = @()

    if (Test-Path $runUser) {
        $userItems = Get-ItemProperty $runUser | ForEach-Object {
            $_.PSObject.Properties | Where-Object { $_.Name -notin @('PSPath','PSParentPath','PSChildName','PSDrive','PSProvider') } |
            ForEach-Object { [PSCustomObject]@{ Nome = $_.Name; Valor = $_.Value; Origem = "Usuário" } }
        }
    }
    if (Test-Path $runSystem) {
        $systemItems = Get-ItemProperty $runSystem | ForEach-Object {
            $_.PSObject.Properties | Where-Object { $_.Name -notin @('PSPath','PSParentPath','PSChildName','PSDrive','PSProvider') } |
            ForEach-Object { [PSCustomObject]@{ Nome = $_.Name; Valor = $_.Value; Origem = "Sistema" } }
        }
    }

    Write-Host "🧍 Usuário atual:" -ForegroundColor Yellow
    if ($userItems) {
        $userItems | ForEach-Object { Write-Host " • $($_.Nome): $($_.Valor)" }
    } else { Write-Host "Nenhum item encontrado." }

    Write-Host "`n💻 Sistema (Todos os Usuários):" -ForegroundColor Yellow
    if ($systemItems) {
        $systemItems | ForEach-Object { Write-Host " • $($_.Nome): $($_.Valor)" }
    } else { Write-Host "Nenhum item encontrado." }

    # Cria backup automático após listar
    Backup-StartupRegistry

    Write-Host ""
}

# --- Função para desativar (remover) um programa com busca parcial ---
function Disable-StartupProgram {
    param([string]$searchTerm)

    $found = @()

    # Busca em HKCU
    if (Test-Path $runUser) {
        $userProps = Get-ItemProperty -Path $runUser
        foreach ($prop in $userProps.PSObject.Properties) {
            if ($prop.Name -notin @('PSPath','PSParentPath','PSChildName','PSDrive','PSProvider')) {
                if ($prop.Name -like "*$searchTerm*") {
                    $found += [PSCustomObject]@{ Name = $prop.Name; Path = $runUser }
                }
            }
        }
    }

    # Busca em HKLM
    if (Test-Path $runSystem) {
        $sysProps = Get-ItemProperty -Path $runSystem
        foreach ($prop in $sysProps.PSObject.Properties) {
            if ($prop.Name -notin @('PSPath','PSParentPath','PSChildName','PSDrive','PSProvider')) {
                if ($prop.Name -like "*$searchTerm*") {
                    $found += [PSCustomObject]@{ Name = $prop.Name; Path = $runSystem }
                }
            }
        }
    }

    if (-not $found) {
        Write-Host "⚠️ Nenhum programa encontrado contendo '$searchTerm'." -ForegroundColor Yellow
        return
    }

    Write-Host "`n📝 Programas encontrados:" -ForegroundColor Cyan
    $i = 1
    foreach ($f in $found) {
        Write-Host "$i - $($f.Name) (Local: $($f.Path))"
        $i++
    }

    $choice = Read-Host "Digite o número do programa que deseja desativar (ou 't' para todos)"
    if ($choice -eq 't') {
        foreach ($f in $found) {
            Remove-ItemProperty -Path $f.Path -Name $f.Name -ErrorAction SilentlyContinue
            Write-Host "✅ '$($f.Name)' desativado." -ForegroundColor Green
        }
    } elseif ($choice -match '^\d+$' -and [int]$choice -le $found.Count) {
        $f = $found[[int]$choice - 1]
        Remove-ItemProperty -Path $f.Path -Name $f.Name -ErrorAction SilentlyContinue
        Write-Host "✅ '$($f.Name)' desativado." -ForegroundColor Green
    } else {
        Write-Host "❌ Opção inválida." -ForegroundColor Red
    }
}

# --- Função para ativar (adicionar) um programa ---
function Enable-StartupProgram {
    param(
        [string]$name,
        [string]$path,
        [switch]$SystemLevel
    )

    if (!(Test-Path $path)) {
        Write-Host "❌ Caminho inválido: $path" -ForegroundColor Red
        return
    }

    if ($SystemLevel) {
        Set-ItemProperty -Path $runSystem -Name $name -Value $path
        Write-Host "✅ Programa '$name' ativado no sistema." -ForegroundColor Green
    } else {
        Set-ItemProperty -Path $runUser -Name $name -Value $path
        Write-Host "✅ Programa '$name' ativado para o usuário atual." -ForegroundColor Green
    }
}

# --- Menu interativo ---
function Show-Menu {
    do {
        Write-Host "`n============================"
        Write-Host "     GERENCIADOR DE STARTUP"
        Write-Host "============================"
        Write-Host "1 - Listar programas de inicialização (gera backup automático)"
        Write-Host "2 - Desativar programa (busca parcial)"
        Write-Host "3 - Ativar programa"
        Write-Host "4 - Recuperar backup das pastas"
        Write-Host "0 - Sair"
        Write-Host "============================"
        $opt = Read-Host "Escolha uma opção"

        switch ($opt) {
            1 { Get-StartupPrograms }
            2 {
                $term = Read-Host "Digite parte do nome do programa a desativar"
                Disable-StartupProgram -searchTerm $term
            }
            3 {
                $name = Read-Host "Nome do programa a adicionar"
                $path = Read-Host "Caminho completo do executável"
                $sys = Read-Host "Adicionar para todos os usuários? (s/n)"
                if ($sys -eq 's') {
                    Enable-StartupProgram -name $name -path $path -SystemLevel
                } else {
                    Enable-StartupProgram -name $name -path $path
                }
            }
            4 { Restore-StartupRegistry }
            0 { Write-Host "Saindo..." -ForegroundColor Yellow; break }
            default { Write-Host "Opção inválida!" -ForegroundColor Red }
        }
    } while ($opt -ne 0)
}

# --- Execução principal ---
Show-Menu
