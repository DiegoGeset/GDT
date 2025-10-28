#=============================
# Script: UACnotify.ps1
# Função: Altera as notificações de permissão administrador do controle de conta de Usuario
# Autor: Diego Geset
#=============================
# Caminho da chave do UAC
$reg = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

# Reduz notificações (UAC ainda ativo)
Set-ItemProperty -Path $reg -Name 'ConsentPromptBehaviorAdmin' -Value 0 -Force
Set-ItemProperty -Path $reg -Name 'ConsentPromptBehaviorUser' -Value 0 -Force

# Aviso visual: notificações desabilitadas
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show(
    "As notificações do Controle de Conta de Usuário (UAC) foram desabilitadas com sucesso." + [Environment]::NewLine + "O UAC ainda está ativo, mas sem solicitações de confirmação para administradores.", 
    "Aviso",
    [System.Windows.MessageBoxButton]::OK,
    [System.Windows.MessageBoxImage]::Information
)
