# ===============================
# GESET Launcher - Interface WPF (Tema Escuro + Ocultação e Elevação)
# ===============================

# --- Oculta a janela do PowerShell ---
$signature = @"
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
Add-Type -MemberDefinition $signature -Name "Win32" -Namespace "PInvoke"
$consolePtr = [PInvoke.Win32]::GetConsoleWindow()
[PInvoke.Win32]::ShowWindow($consolePtr, 0)

# --- Garante execução com privilégios de Administrador (sem prompt de aviso) ---
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb = "runas"
    [System.Diagnostics.Process]::Start($psi) | Out-Null
    exit
}

# ===============================
# Dependências principais
# ===============================
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# ===============================
# Funções utilitárias
# ===============================
function Run-ScriptElevated($scriptPath) {
    if (-not (Test-Path $scriptPath)) {
        [System.Windows.MessageBox]::Show("Arquivo não encontrado: $scriptPath", "Erro", "OK", "Error")
        return
    }
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
}

function Get-InfoText($scriptPath) {
    $txtFile = [System.IO.Path]::ChangeExtension($scriptPath, ".txt")
    if (Test-Path $txtFile) { Get-Content $txtFile -Raw }
    else { "Nenhuma documentação encontrada para este script." }
}

function Show-InfoWindow($title, $content) {
    $window = New-Object System.Windows.Window
    $window.Title = "Informações - $title"
    $window.Width = 600
    $window.Height = 400
    $window.WindowStartupLocation = 'CenterScreen'
    $window.Background = "#1E1E1E"
    $window.FontFamily = "Segoe UI"
    $window.Foreground = "White"

    $textBox = New-Object System.Windows.Controls.TextBox
    $textBox.Text = $content
    $textBox.Margin = 15
    $textBox.TextWrapping = "Wrap"
    $textBox.VerticalScrollBarVisibility = "Auto"
    $textBox.IsReadOnly = $true
    $textBox.FontSize = 14

    $window.Content = $textBox
    $window.ShowDialog() | Out-Null
}

function Add-HoverShadow($button) {
    $button.Add_MouseEnter({
        $shadow = New-Object System.Windows.Media.Effects.DropShadowEffect
        $shadow.Color = [System.Windows.Media.Colors]::Black
        $shadow.Opacity = 0.4
        $shadow.BlurRadius = 15
        $shadow.Direction = 320
        $shadow.ShadowDepth = 4
        $this.Effect = $shadow
    })
    $button.Add_MouseLeave({ $this.Effect = $null })
}

# ===============================
# Janela principal
# ===============================
$window = New-Object System.Windows.Window
$window.Title = "Geset Diagnostic Tool"
$window.Width = 780
$window.Height = 600
$window.WindowStartupLocation = 'CenterScreen'
$window.FontFamily = "Segoe UI"
$window.ResizeMode = "NoResize"

$mainGrid = New-Object System.Windows.Controls.Grid
$mainGrid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
$mainGrid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
$mainGrid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
$mainGrid.RowDefinitions[0].Height = "100"
$mainGrid.RowDefinitions[1].Height = "*"
$mainGrid.RowDefinitions[2].Height = "60"
$window.Content = $mainGrid

# ===============================
# Cabeçalho
# ===============================

# Grid com 2 colunas — esquerda: logo + título / direita: botão "i"
$topGrid = New-Object System.Windows.Controls.Grid
$colLeft = New-Object System.Windows.Controls.ColumnDefinition
$colLeft.Width = "*"
$colRight = New-Object System.Windows.Controls.ColumnDefinition
$colRight.Width = "Auto"
$topGrid.ColumnDefinitions.Add($colLeft)
$topGrid.ColumnDefinitions.Add($colRight)

# --- Painel esquerdo: logo + título ---
$topPanel = New-Object System.Windows.Controls.StackPanel
$topPanel.Orientation = "Horizontal"
$topPanel.HorizontalAlignment = "Left"
$topPanel.VerticalAlignment = "Center"
$topPanel.Margin = "20,15,0,15"

$logoPath = Join-Path $BasePath "logo.png"
if (Test-Path $logoPath) {
    $logo = New-Object System.Windows.Controls.Image
    $logo.Source = New-Object System.Windows.Media.Imaging.BitmapImage([Uri]$logoPath)
    $logo.Width = 60
    $logo.Height = 60
    $logo.Margin = "0,0,10,0"
    $topPanel.Children.Add($logo)
}

$titleText = New-Object System.Windows.Controls.TextBlock
$titleText.Text = "Geset Diagnostic Tool"
$titleText.FontSize = 38
$titleText.FontWeight = "Bold"
$titleText.Foreground = "#FFFFFF"
$titleText.VerticalAlignment = "Center"

$shadowEffect = New-Object System.Windows.Media.Effects.DropShadowEffect
$shadowEffect.Color = [System.Windows.Media.Colors]::LightBlue
$shadowEffect.BlurRadius = 10
$shadowEffect.ShadowDepth = 2
$titleText.Effect = $shadowEffect

$topPanel.Children.Add($titleText)
[System.Windows.Controls.Grid]::SetColumn($topPanel, 0)
$topGrid.Children.Add($topPanel)

# --- Botão "i" (direita) com estilo arredondado igual aos botões do launcher ---
$infoHeaderBtn = New-Object System.Windows.Controls.Button
$infoHeaderBtn.Content = "i"
$infoHeaderBtn.Width = 40
$infoHeaderBtn.Height = 35
$infoHeaderBtn.HorizontalAlignment = "Right"
$infoHeaderBtn.VerticalAlignment = "Center"
$infoHeaderBtn.Margin = "0,0,20,0"
$infoHeaderBtn.Style = $roundedButtonStyle
$infoHeaderBtn.Background = "#1E90FF"
$infoHeaderBtn.Foreground = "White"
$infoHeaderBtn.FontWeight = "Bold"
$infoHeaderBtn.FontSize = 14

# Glow azul e hover shadow
$glowEffect = New-Object System.Windows.Media.Effects.DropShadowEffect
$glowEffect.Color = [System.Windows.Media.Colors]::LightBlue
$glowEffect.BlurRadius = 12
$glowEffect.ShadowDepth = 0
$glowEffect.Opacity = 0.8
$infoHeaderBtn.Effect = $glowEffect
Add-HoverShadow $infoHeaderBtn

# Clique executa o script HardwareInfo.ps1 com elevação
$infoHeaderBtn.Add_Click({
    $hardwareScript = Join-Path $BasePath "HardwareInfo.ps1"
    Run-ScriptElevated $hardwareScript
})

[System.Windows.Controls.Grid]::SetColumn($infoHeaderBtn, 1)
$topGrid.Children.Add($infoHeaderBtn)

[System.Windows.Controls.Grid]::SetRow($topGrid, 0)
$mainGrid.Children.Add($topGrid)

# ===============================
# Estilos dos Tabs e Botões
# ===============================
$tabControl = New-Object System.Windows.Controls.TabControl
$tabControl.Margin = "15,0,15,0"

$tabStyleXaml = @"
<ResourceDictionary xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                    xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'>
    <Style TargetType='TabControl'>
        <Setter Property='BorderThickness' Value='0'/>
        <Setter Property='Background' Value='#102A4D'/>
    </Style>
    <Style TargetType='TabItem'>
        <Setter Property='Background' Value='#163B70'/>
        <Setter Property='Foreground' Value='White'/>
        <Setter Property='FontWeight' Value='Bold'/>
        <Setter Property='Padding' Value='14,7'/>
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
$tabControl.Resources = [Windows.Markup.XamlReader]::Load($tabReader)
[System.Windows.Controls.Grid]::SetRow($tabControl, 1)
$mainGrid.Children.Add($tabControl)

# --- Estilo arredondado dos botões ---
$roundedStyle = @"
<Style xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' TargetType='Button'>
    <Setter Property='Background' Value='#2E5D9F'/>
    <Setter Property='Foreground' Value='White'/>
    <Setter Property='FontWeight' Value='SemiBold'/>
    <Setter Property='FontSize' Value='13'/>
    <Setter Property='Margin' Value='5,5,5,5'/>
    <Setter Property='Padding' Value='8,4'/>
    <Setter Property='BorderThickness' Value='0'/>
    <Setter Property='BorderBrush' Value='Transparent'/>
    <Setter Property='Cursor' Value='Hand'/>
    <Setter Property='Template'>
        <Setter.Value>
            <ControlTemplate TargetType='Button'>
                <Border Background='{TemplateBinding Background}' CornerRadius='8'>
                    <ContentPresenter HorizontalAlignment='Center' VerticalAlignment='Center'/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property='IsMouseOver' Value='True'>
                        <Setter Property='Background' Value='#3F7AE0'/>
                    </Trigger>
                    <Trigger Property='IsPressed' Value='True'>
                        <Setter Property='Background' Value='#2759B0'/>
                    </Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>
"@
$styleReader = (New-Object System.Xml.XmlNodeReader ([xml]$roundedStyle))
$roundedButtonStyle = [Windows.Markup.XamlReader]::Load($styleReader)

# ===============================
# Tema escuro padrão
# ===============================
$window.Background = "#0A1A33"
$tabControl.Background = "#102A4D"

# ===============================
# Função para carregar categorias e scripts
# ===============================
$ScriptCheckBoxes = @{}
function Load-Tabs {
    $tabControl.Items.Clear()
    $ScriptCheckBoxes.Clear()

    $categories = Get-ChildItem -Path $BasePath -Directory | Where-Object { $_.Name -notin @("Logs") }

    foreach ($category in $categories) {
        $tab = New-Object System.Windows.Controls.TabItem
        $tab.Header = $category.Name

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
        $scrollViewer.Margin = "5"
        $panel = New-Object System.Windows.Controls.StackPanel
        $scrollViewer.Content = $panel
        $border.Child = $scrollViewer

        $subfolders = Get-ChildItem -Path $category.FullName -Directory
        foreach ($sub in $subfolders) {
            $scriptFile = Get-ChildItem -Path $sub.FullName -Filter *.ps1 -File | Select-Object -First 1
            if ($scriptFile) {
                $sp = New-Object System.Windows.Controls.StackPanel
                $sp.Orientation = "Horizontal"
                $sp.Margin = "0,0,0,8"
                $sp.VerticalAlignment = "Top"
                $sp.HorizontalAlignment = "Left"

                $innerGrid = New-Object System.Windows.Controls.Grid
                $innerGrid.Margin = "0"
                $innerGrid.VerticalAlignment = "Center"
                $innerGrid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition))
                $innerGrid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition))
                $innerGrid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition))

                $chk = New-Object System.Windows.Controls.CheckBox
                $chk.VerticalAlignment = "Center"
                $chk.Margin = "0,0,8,0"
                $chk.Tag = $scriptFile.FullName
                $ScriptCheckBoxes[$scriptFile.FullName] = $chk
                [System.Windows.Controls.Grid]::SetColumn($chk, 0)

                $btn = New-Object System.Windows.Controls.Button
                $btn.Content = $sub.Name
                $btn.Width = 200
                $btn.Height = 32
                $btn.Style = $roundedButtonStyle
                $btn.Tag = $scriptFile.FullName
                $btn.VerticalAlignment = "Center"
                Add-HoverShadow $btn
                [System.Windows.Controls.Grid]::SetColumn($btn, 1)

                $infoBtn = New-Object System.Windows.Controls.Button
                $infoBtn.Content = "?"
                $infoBtn.Width = 28
                $infoBtn.Height = 28
                $infoBtn.Margin = "8,0,0,0"
                $infoBtn.Style = $roundedButtonStyle
                $infoBtn.Background = "#1E90FF"
                $infoBtn.Tag = $scriptFile.FullName
                $infoBtn.VerticalAlignment = "Center"
                Add-HoverShadow $infoBtn
                [System.Windows.Controls.Grid]::SetColumn($infoBtn, 2)

                $innerGrid.Children.Add($chk)
                $innerGrid.Children.Add($btn)
                $innerGrid.Children.Add($infoBtn)
                $sp.Children.Add($innerGrid)
                $panel.Children.Add($sp)

                $btn.Add_Click({ Run-ScriptElevated $this.Tag })
                $infoBtn.Add_Click({
                    $infoText = Get-InfoText $this.Tag
                    Show-InfoWindow -title $sub.Name -content $infoText
                })
            }
        }

        $tab.Content = $border
        $tabControl.Items.Add($tab)
    }
}

# ===============================
# Rodapé
# ===============================
$footerGrid = New-Object System.Windows.Controls.Grid
$footerGrid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition))
$footerGrid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition))
$footerGrid.Margin = "15,0,15,10"

$footerPanel = New-Object System.Windows.Controls.StackPanel
$footerPanel.Orientation = "Horizontal"
$footerPanel.HorizontalAlignment = "Left"

$BtnExec = New-Object System.Windows.Controls.Button
$BtnExec.Content = "▶ Executar"
$BtnExec.Width = 110
$BtnExec.Height = 35
$BtnExec.Style = $roundedButtonStyle
$BtnExec.Background = "#1E90FF"
Add-HoverShadow $BtnExec

$BtnRefresh = New-Object System.Windows.Controls.Button
$BtnRefresh.Content = "🔄 Atualizar"
$BtnRefresh.Width = 110
$BtnRefresh.Height = 35
$BtnRefresh.Style = $roundedButtonStyle
$BtnRefresh.Background = "#E0E6ED"
$BtnRefresh.Foreground = "#0057A8"
Add-HoverShadow $BtnRefresh

$BtnExit = New-Object System.Windows.Controls.Button
$BtnExit.Content = "❌ Sair"
$BtnExit.Width = 90
$BtnExit.Height = 35
$BtnExit.Style = $roundedButtonStyle
$BtnExit.Background = "#FF5C5C"
$BtnExit.Foreground = "White"
Add-HoverShadow $BtnExit

$footerPanel.Children.Add($BtnExec)
$footerPanel.Children.Add($BtnRefresh)
$footerPanel.Children.Add($BtnExit)

[System.Windows.Controls.Grid]::SetColumn($footerPanel, 0)
$footerGrid.Children.Add($footerPanel)
[System.Windows.Controls.Grid]::SetRow($footerGrid, 2)
$mainGrid.Children.Add($footerGrid)

# ===============================
# Ações dos botões de rodapé
# ===============================
$BtnExec.Add_Click({
    $checked = $ScriptCheckBoxes.Values | Where-Object { $_.IsChecked }
    foreach ($cb in $checked) {
        Run-ScriptElevated $cb.Tag
    }
})

$BtnRefresh.Add_Click({ Load-Tabs })
$BtnExit.Add_Click({ $window.Close() })

# ===============================
# Inicialização
# ===============================
Load-Tabs
$window.ShowDialog() | Out-Null
