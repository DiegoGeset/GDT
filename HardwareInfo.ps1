# ============================================================
# Script: HardwareInfo.ps1
# Função: Lista informações detalhadas do sistema em WPF com abas
# Autor : Adaptado para Diego Geset
# ============================================================

# ===============================
# Oculta a janela do PowerShell (somente GUI)
# ===============================
if (-not ([System.Management.Automation.PSTypeName]'PInvoke.Win32').Type) {
    $signature = @"
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
    Add-Type -MemberDefinition $signature -Name "Win32" -Namespace "PInvoke" | Out-Null
}

$consolePtr = [PInvoke.Win32]::GetConsoleWindow()
[void][PInvoke.Win32]::ShowWindow($consolePtr, 0)

# ===============================
# Função para detectar pasta do script
# ===============================
function Get-ScriptDirectory {
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    Split-Path -Parent $Invocation.MyCommand.Definition
}

$ScriptDir = Get-ScriptDirectory

# ===============================
# Coleta das informações do sistema
# ===============================
$LogContent = @{}

function Write-Log {
    param (
        [string]$Category,
        [string]$Text
    )
    if (-not $LogContent.ContainsKey($Category)) { $LogContent[$Category] = @() }
    $LogContent[$Category] += $Text
    return $null  # evita saída no console
}

# --- Sistema ---
$CS = Get-WmiObject -Class Win32_ComputerSystem
Write-Log "Sistema" "===== SISTEMA ====="
Write-Log "Sistema" "Hostname: $($CS.Name)"
Write-Log "Sistema" "Proprietário Principal: $($CS.PrimaryOwnerName)"
Write-Log "Sistema" "Fabricante: $($CS.Manufacturer)"
Write-Log "Sistema" "Modelo: $($CS.Model)"
Write-Log "Sistema" "Tipo do Sistema: $($CS.SystemType)"
Write-Log "Sistema" "Domínio: $($CS.Domain)"
Write-Log "Sistema" "Usuário Conectado: $($CS.UserName)"

# --- CPU ---
$CPU = Get-WmiObject -Class Win32_Processor
Write-Log "CPU" "===== CPU ====="
Write-Log "CPU" "Nome: $($CPU.Name)"
Write-Log "CPU" "Fabricante: $($CPU.Manufacturer)"
Write-Log "CPU" "Cores Físicos: $($CPU.NumberOfCores)"
Write-Log "CPU" "Processadores Lógicos: $($CPU.NumberOfLogicalProcessors)"
Write-Log "CPU" "Clock Máximo (GHz): $([math]::Round($CPU.MaxClockSpeed / 1000, 2))"
Write-Log "CPU" "Uso Atual (%): $((Get-WmiObject Win32_Processor).LoadPercentage | Out-Null)"
Write-Log "CPU" ""

# --- RAM ---
$MemModules = Get-WmiObject -Class Win32_PhysicalMemory
$TotalRAMGB = [math]::Round(($MemModules | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)
Write-Log "RAM" "===== MEMÓRIA RAM ====="
Write-Log "RAM" "Total RAM (GB): $TotalRAMGB"
Write-Log "RAM" "Quantidade de Pentes: $($MemModules.Count)"
$i = 1
foreach ($mod in $MemModules) {
    $capGB = [math]::Round($mod.Capacity / 1GB, 2)
    Write-Log "RAM" "Pente ${i}: $capGB GB, Velocidade: $($mod.Speed) MHz, Fabricante: $($mod.Manufacturer)"
    $i++
}
Write-Log "RAM" ""

# --- Discos ---
$Disks = Get-WmiObject -Class Win32_DiskDrive
Write-Log "Discos" "===== DISPOSITIVOS DE ARMAZENAMENTO ====="
foreach ($disk in $Disks) {
    Write-Log "Discos" "Nome: $($disk.DeviceID)"
    Write-Log "Discos" "Modelo: $($disk.Model)"
    Write-Log "Discos" "Tamanho (GB): $([math]::Round($disk.Size / 1GB, 2))"
    Write-Log "Discos" "Tipo: $($disk.MediaType)"
    Write-Log "Discos" "-----------------------------"
}

# ===============================
# Janela WPF
# ===============================
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase | Out-Null

$window = New-Object System.Windows.Window
$window.Title = "Informações de Hardware - $env:COMPUTERNAME"
$window.Width = 780
$window.Height = 600
$window.WindowStartupLocation = 'CenterScreen'
$window.FontFamily = "Segoe UI"
$window.ResizeMode = "NoResize"
$window.Background = "#0A1A33"

# ===============================
# Grid principal
# ===============================
$mainGrid = New-Object System.Windows.Controls.Grid
$mainGrid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition)) # Tabs
$mainGrid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition)) # Rodapé
$mainGrid.RowDefinitions[0].Height = "*"
$mainGrid.RowDefinitions[1].Height = "60"
$null = $window.Content = $mainGrid

# ===============================
# TabControl
# ===============================
$tabControl = New-Object System.Windows.Controls.TabControl
$tabControl.Margin = "15,15,15,0"
$tabControl.Background = "#102A4D"
$tabControl.Height = 500
$null = [System.Windows.Controls.Grid]::SetRow($tabControl, 0)
$null = $mainGrid.Children.Add($tabControl)

# ===============================
# Estilo TabItem (arredondado)
# ===============================
$tabStyleXaml = @"
<ResourceDictionary xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                    xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'>
    <Style TargetType='TabItem'>
        <Setter Property='Background' Value='#163B70'/>
        <Setter Property='Foreground' Value='White'/>
        <Setter Property='FontWeight' Value='Bold'/>
        <Setter Property='Padding' Value='12,6'/>
        <Setter Property='Margin' Value='2,2,2,0'/>
        <Setter Property='Template'>
            <Setter.Value>
                <ControlTemplate TargetType='TabItem'>
                    <Border x:Name='Bd' Background='{TemplateBinding Background}' CornerRadius='12,12,0,0' Padding='{TemplateBinding Padding}' SnapsToDevicePixels='True'>
                        <Border.Effect>
                            <DropShadowEffect BlurRadius='8' ShadowDepth='3' Opacity='0.35' Color='#000000'/>
                        </Border.Effect>
                        <ContentPresenter x:Name='Content' ContentSource='Header' HorizontalAlignment='Center' VerticalAlignment='Center'/>
                    </Border>
                    <ControlTemplate.Triggers>
                        <Trigger Property='IsSelected' Value='True'>
                            <Setter TargetName='Bd' Property='Background' Value='#1E90FF'/>
                            <Setter TargetName='Bd' Property='Effect'>
                                <Setter.Value>
                                    <DropShadowEffect BlurRadius='12' ShadowDepth='3' Opacity='0.55' Color='#1E90FF'/>
                                </Setter.Value>
                            </Setter>
                            <Setter Property='Panel.ZIndex' Value='10'/>
                        </Trigger>
                        <Trigger Property='IsMouseOver' Value='True'>
                            <Setter TargetName='Bd' Property='Background' Value='#2B579A'/>
                        </Trigger>
                    </ControlTemplate.Triggers>
                </ControlTemplate>
            </Setter.Value>
        </Setter>
    </Style>
</ResourceDictionary>
"@

$tabXml = [xml]$tabStyleXaml
$tabReader = New-Object System.Xml.XmlNodeReader($tabXml)
$tabItemStyle = [Windows.Markup.XamlReader]::Load($tabReader)
$null = $tabControl.Resources.MergedDictionaries.Add($tabItemStyle)

# ===============================
# Função para criar abas
# ===============================
function Add-Tab($header, $lines) {
    $tab = New-Object System.Windows.Controls.TabItem
    $tab.Header = $header

    $border = New-Object System.Windows.Controls.Border
    $border.BorderThickness = "1"
    $border.BorderBrush = "#3A6FB0"
    $border.Background = "#12294C"
    $border.CornerRadius = "10"
    $border.Margin = "10"
    $border.Padding = "10"
    $border.Effect = New-Object System.Windows.Media.Effects.DropShadowEffect
    $border.Effect.BlurRadius = 8
    $border.Effect.Opacity = 0.25
    $border.Effect.ShadowDepth = 3
    $border.Effect.Color = [System.Windows.Media.Colors]::Black

    $scrollViewer = New-Object System.Windows.Controls.ScrollViewer
    $scrollViewer.VerticalScrollBarVisibility = "Auto"

    $textBox = New-Object System.Windows.Controls.TextBox
    $textBox.Text = ($lines -join "`r`n")
    $textBox.Background = "#12294C"
    $textBox.Foreground = "White"
    $textBox.FontSize = 14
    $textBox.Margin = "0"
    $textBox.Padding = "5"
    $textBox.TextWrapping = "Wrap"
    $textBox.IsReadOnly = $true
    $textBox.VerticalScrollBarVisibility = "Auto"
    $textBox.HorizontalScrollBarVisibility = "Auto"

    $scrollViewer.Content = $textBox
    $border.Child = $scrollViewer
    $tab.Content = $border
    $null = $tabControl.Items.Add($tab)
}

# Adiciona abas na ordem Sistema, CPU, RAM, Discos
foreach ($category in @("Sistema","CPU","RAM","Discos")) {
    if ($LogContent.ContainsKey($category)) {
        Add-Tab -header $category -lines $LogContent[$category]
    }
}

# ===============================
# Rodapé com botão Fechar
# ===============================
$footerGrid = New-Object System.Windows.Controls.Grid
$footerGrid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition))
$footerGrid.HorizontalAlignment = "Right"
$footerGrid.Margin = "15,0,15,10"

$BtnExit = New-Object System.Windows.Controls.Button
$BtnExit.Content = "❌ Fechar"
$BtnExit.Width = 90
$BtnExit.Height = 35

# Estilo arredondado
$exitStyleXaml = @"
<Style xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' TargetType='Button'>
    <Setter Property='Background' Value='#FF5C5C'/>
    <Setter Property='Foreground' Value='White'/>
    <Setter Property='FontWeight' Value='Bold'/>
    <Setter Property='Padding' Value='5,2'/>
    <Setter Property='BorderThickness' Value='0'/>
    <Setter Property='BorderBrush' Value='Transparent'/>
    <Setter Property='Cursor' Value='Hand'/>
    <Setter Property='Template'>
        <Setter.Value>
            <ControlTemplate TargetType='Button'>
                <Border Background='{TemplateBinding Background}' CornerRadius='5' SnapsToDevicePixels='True'>
                    <ContentPresenter HorizontalAlignment='Center' VerticalAlignment='Center'/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property='IsMouseOver' Value='True'>
                        <Setter Property='Background' Value='#FF2A2A'/>
                    </Trigger>
                    <Trigger Property='IsPressed' Value='True'>
                        <Setter Property='Background' Value='#CC0000'/>
                    </Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>
"@

$exitStyleXml = [xml]$exitStyleXaml
$exitStyleReader = New-Object System.Xml.XmlNodeReader($exitStyleXml)
$BtnExit.Style = [Windows.Markup.XamlReader]::Load($exitStyleReader)
$BtnExit.Add_Click({ $window.Close() })

$null = $footerGrid.Children.Add($BtnExit)
$null = [System.Windows.Controls.Grid]::SetRow($footerGrid, 1)
$null = $mainGrid.Children.Add($footerGrid)

# ===============================
# Exibe a janela somente GUI, silenciosa
# ===============================
$null = $window.ShowDialog()
