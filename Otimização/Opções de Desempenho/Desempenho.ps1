# ============================================================
# Script: Ajuste de Efeitos Visuais - Somente 3 opções ativas
# Mantém apenas:
#   1. Usar fontes de tela arredondadas (ClearType)
#   2. Mostrar miniaturas em vez de ícones
#   3. Mostrar retângulo de seleção translúcido
# ============================================================

Write-Host "`nAplicando configurações de desempenho visual..." -ForegroundColor Cyan

# --- Lista de configurações de registro ---
$regConfigs = @(
    # ====== Configurações básicas de desempenho ======
    @{ Path="HKCU:\Control Panel\Desktop"; Name="DragFullWindows";      Value="0"; Type="String" },   # Não arrastar janela com conteúdo
    @{ Path="HKCU:\Control Panel\Desktop"; Name="MenuShowDelay";        Value="200"; Type="String" },
    @{ Path="HKCU:\Control Panel\Desktop\WindowMetrics"; Name="MinAnimate"; Value="0"; Type="String" },
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; Name="VisualFXSetting"; Value="3"; Type="DWord" },

    # ====== Efeitos visuais específicos ======
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="ListviewAlphaSelect"; Value="1"; Type="DWord" }, # Retângulo translúcido
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="ListviewShadow"; Value="0"; Type="DWord" },     # Sombra nos rótulos (desativado)
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="Thumbnails"; Value="1"; Type="DWord" },         # Miniaturas em vez de ícones

    # ====== Efeitos desativados ======
    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="TaskbarAnimations"; Value="0"; Type="DWord" },
    @{ Path="HKCU:\Software\Microsoft\Windows\DWM"; Name="EnableAeroPeek"; Value="0"; Type="DWord" }
)

# --- Aplica todas as configurações ---
foreach ($item in $regConfigs) {
    try {
        if (-not (Test-Path $item.Path)) {
            New-Item -Path $item.Path -Force | Out-Null
        }

        if (-not (Get-ItemProperty -Path $item.Path -Name $item.Name -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path $item.Path -Name $item.Name -Value $item.Value -PropertyType $item.Type -Force | Out-Null
        } else {
            Set-ItemProperty -Path $item.Path -Name $item.Name -Value $item.Value -Force
        }
    } catch {
        Write-Host "Falha ao aplicar $($item.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- Ajusta o UserPreferencesMask ---
# Esse valor define quais efeitos estão ativos.
# A combinação abaixo mantém:
#   - Fonte suavizada (ClearType)
#   - Miniaturas em vez de ícones
#   - Retângulo translúcido
# Desativa o resto para desempenho máximo.
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](158,18,7,128,16,0,0,0))

# --- Atualiza a interface ---
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters ,1 ,True

# --- Reinicia o Explorer para aplicar imediatamente ---
Write-Host "Reiniciando o Explorer para aplicar as alterações..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force
Start-Process explorer.exe

Write-Host "`nConfigurações aplicadas com sucesso!" -ForegroundColor Green
Write-Host "Verifique em: Painel de Controle → Sistema → Configurações avançadas → Desempenho → Efeitos Visuais." -ForegroundColor Cyan
