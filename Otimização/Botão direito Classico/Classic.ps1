# ============================================================
# Script: Restaurar Menu Clássico do Windows 11
# Descrição: Altera o registro para restaurar o menu de contexto clássico.
# ============================================================

# --- Função: Ativar menu clássico ---
function Set-ClassicRightClickMenu {
    try {
        Write-Host "Aplicando o menu clássico do Windows 11..." -ForegroundColor Cyan
        
        # Cria a chave de registro necessária
        New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name "InprocServer32" -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(default)" -Value "" -Force

        Write-Host "Reiniciando o Explorer..." -ForegroundColor Yellow
        Stop-Process -Name explorer -Force
        Start-Sleep -Seconds 2
        Start-Process explorer

        Write-Host "✅ Menu clássico ativado com sucesso!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Erro ao aplicar a modificação: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- Função: Desfazer (voltar ao padrão) ---
function Undo-ClassicRightClickMenu {
    try {
        Write-Host "Revertendo para o menu moderno do Windows 11..." -ForegroundColor Cyan
        
        # Remove a chave de registro criada
        Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host "Reiniciando o Explorer..." -ForegroundColor Yellow
        Stop-Process -Name explorer -Force
        Start-Sleep -Seconds 2
        Start-Process explorer

        Write-Host "✅ Menu moderno restaurado com sucesso!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Erro ao desfazer a modificação: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- Menu de execução ---
Write-Host "`n=== Restaurar Menu Clássico do Windows 11 ===" -ForegroundColor White
Write-Host "1 - Ativar menu clássico (Windows 10 style)"
Write-Host "2 - Restaurar menu moderno (Windows 11 padrão)"
$choice = Read-Host "Escolha uma opção (1/2)"

switch ($choice) {
    "1" { Set-ClassicRightClickMenu }
    "2" { Undo-ClassicRightClickMenu }
    default { Write-Host "Opção inválida." -ForegroundColor Red }
}
