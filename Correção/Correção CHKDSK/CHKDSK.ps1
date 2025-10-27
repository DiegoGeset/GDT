# ============================================================
# Script: Correção CHKDSK.ps1
# Função: Lista a quantidade de disco rigido, da opção de escolha em qual é para executar o codigo
# Autor : Adaptado para Diego Geset
# ============================================================
# --- Caminho do log ---
$logPath = "$PSScriptRoot\CHKDSK_Log_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"

# Função para escrever mensagens no PowerShell e log
function Write-Log {
    param(
        [string]$Message,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $logPath -Value $Message
}

# --- Lista todos os volumes disponíveis ---
$volumes = Get-Volume | Where-Object {$_.DriveLetter -ne $null} | Select-Object DriveLetter, FileSystemLabel, Size, SizeRemaining

Write-Log "================ CHKDSK - Início $(Get-Date) ================" Cyan
Write-Log "Discos e volumes disponíveis:" Cyan

# Exibe informações de forma organizada
$volumes | ForEach-Object {
    $sizeGB = [math]::Round($_.Size / 1GB, 2)
    $freeGB = [math]::Round($_.SizeRemaining / 1GB, 2)
    Write-Log ("Letra: {0} | Nome: {1} | Tamanho: {2} GB | Livre: {3} GB" -f $_.DriveLetter, $_.FileSystemLabel, $sizeGB, $freeGB) Yellow
}

# --- Solicita que o usuário escolha uma unidade ---
$selected = Read-Host "Digite a letra da unidade que deseja verificar (ex: C)"

# --- Valida a letra informada ---
if (-not ($volumes | Where-Object {$_.DriveLetter -eq $selected.ToUpper()})) {
    Write-Log "Letra de unidade inválida!" Red
    exit
}

# --- Confirmação ---
$confirm = Read-Host "Você quer executar CHKDSK na unidade ${selected}: ? (S/N)"
if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Log "Operação cancelada pelo usuário." Red
    exit
}

# --- Informa que o CHKDSK está sendo executado ---
Write-Log "Executando CHKDSK na unidade ${selected}: ..." Cyan

# --- Comando para abrir CMD, executar CHKDSK e salvar saída no log ---
# Mantém a janela aberta com pause
$cmdArguments = "/c chkdsk ${selected}:/f /r /x > `"$logPath`" 2>&1 & echo.`nPressione qualquer tecla para fechar esta janela... & pause"

Start-Process -FilePath "cmd.exe" -ArgumentList $cmdArguments -WindowStyle Normal -Wait

Write-Log "CHKDSK finalizado para a unidade ${selected}." Green
Write-Log "Log completo salvo em: $logPath" Cyan
Write-Host "`nExecução finalizada. Log completo: $logPath" -ForegroundColor Yellow
