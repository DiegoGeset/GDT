# ============================================================
# Script: Ajuste de Efeitos Visuais - Corrigido
# Mantém apenas:
#   - Mostrar miniaturas em vez de ícones
#   - Mostrar retângulo de seleção translúcido
#   - Usar sombras subjacentes para rótulos de ícones na área de trabalho (DESABILITADO)
# Baseado no JSON fornecido por Geset
# ============================================================

Write-Host "Aplicando configurações de desempenho visual..." -ForegroundColor Cyan

# --- Definições do registro ---
$regConfigs = @(
    @{ Path="HKCU:\Control Panel\Desktop"; Name="DragFullWindows";      Value="0"; Type="String" },
    @{ Path="HKCU:\Control Panel\Desktop"; Name="MenuShowDelay";        Value="200"; Type="String" },
    @{ Path="HKCU:\Control Panel\Desktop\WindowMetrics"; Name="MinAnimate"; Value="0"; Type="String" },
    @{ Path="HKCU:\Control Panel\Keyboard"; Name="KeyboardDelay";       Value="0"; Type="DWord" },
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="TaskbarAnimations"; Value="0"; Type="DWord" },
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="ListviewAlphaSelect"; Value="1"; Type="DWord" },  # Retângulo de seleção translúcido
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="ListviewShadow"; Value="0"; Type="DWord" },       # Sombra nos rótulos de ícones (DESABILITADO)
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="Thumbnails"; Value="1"; Type="DWord" },           # Miniaturas em vez de ícones
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; Name="VisualFXSetting"; Value="3"; Type="DWord" },
    @{ Path="HKCU:\Software\Microsoft\Windows\DWM"; Name="EnableAeroPeek"; Value="0"; Type="DWord" },
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="TaskbarMn"; Value="0"; Type="DWord" },
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="TaskbarDa"; Value="0"; Type="DWord" },
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="ShowTaskViewButton"; Value="0"; Type="DWord" },
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"; Name="SearchboxTaskbarMode"; Value="0"; Type="DWord" }
)

# --- Aplica as configurações do registro ---
foreach ($item in $regConfigs) {
    try {
        # Verifica se o caminho existe antes de tentar criar
        if (-not (Test-Path $item.Path)) {
            New-Item -Path $item.Path -Force | Out-Null
        }

        Set-ItemProperty -Path $item.Path -Name $item.Name -Value $item.Value -Type $item.Type -ErrorAction Stop
    } catch {
        Write-Host "Falha ao aplicar $($item.Name) em $($item.Path): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- Define o UserPreferencesMask ---
# Este valor controla diversos efeitos visuais (fade, animações etc.)
# Ajustado para desempenho + apenas 3 opções ativas.
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](144,18,3,128,16,0,0,0))

# --- Atualiza a interface ---
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters ,1 ,True

Write-Host "Configurações aplicadas com sucesso!" -ForegroundColor Green

# --- Abre o painel Sysdm.cpl ---
Write-Host "Abrindo painel de desempenho para confirmação..." -ForegroundColor Yellow
Start-Process "sysdm.cpl"

Write-Host "`nConcluído! Verifique em: Desempenho → Configurações → Efeitos Visuais." -ForegroundColor Cyan
