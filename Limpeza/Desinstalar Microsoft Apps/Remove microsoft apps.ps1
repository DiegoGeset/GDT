# ============================================================
# Script: Desinstalação Interativa de Aplicativos Microsoft (corrigido)
# Autor: Geset
# ============================================================

# --- Verifica se é administrador ---
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Este script precisa ser executado como Administrador." -ForegroundColor Red
    exit
}

Write-Host "🔍 Verificando aplicativos Microsoft instalados..." -ForegroundColor Cyan
Start-Sleep -Seconds 1

# --- Lista de aplicativos Microsoft a verificar/remover ---
$apps = @(
    "Microsoft.Microsoft3DViewer",
    "Microsoft.AppConnector",
    "Microsoft.BingFinance",
    "Microsoft.BingNews",
    "Microsoft.BingSports",
    "Microsoft.BingTranslator",
    "Microsoft.BingWeather",
    "Microsoft.BingFoodAndDrink",
    "Microsoft.BingHealthAndFitness",
    "Microsoft.BingTravel",
    "Microsoft.MinecraftUWP",
    "Microsoft.GamingServices",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Messaging",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.NetworkSpeedTest",
    "Microsoft.News",
    "Microsoft.Office.Lens",
    "Microsoft.Office.Sway",
    "Microsoft.Office.OneNote",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.Wallet",
    "Microsoft.Whiteboard",
    "Microsoft.WindowsAlarms",
    "microsoft.windowscommunicationsapps",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.YourPhone",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.XboxApp",
    "Microsoft.ConnectivityStore",
    "Microsoft.ScreenSketch",
    "Microsoft.XboxTCUI",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGameCallableUI",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.MixedReality.Portal",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.MicrosoftOfficeHub",
    "*Microsoft.Advertising.Xaml*"
)

# --- Função: retorna informações reais dos aplicativos instalados ---
function Get-InstalledApps {
    param([string[]]$AppList)
    $installed = @()
    foreach ($app in $AppList) {
        # AppxPackage
        $pkg = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
        if ($pkg) {
            $installed += [PSCustomObject]@{
                Name = $app
                RealName = $pkg.Name
                Type = "Appx"
            }
            continue
        }

        $pkgAll = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
        if ($pkgAll) {
            $installed += [PSCustomObject]@{
                Name = $app
                RealName = $pkgAll.Name
                Type = "AppxAllUsers"
            }
            continue
        }

        # Registro
        $regEntry = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall,
                                        HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall |
                    Get-ItemProperty | Where-Object { $_.DisplayName -like "*$app*" } | Select-Object -First 1
        if ($regEntry) {
            $installed += [PSCustomObject]@{
                Name = $app
                RealName = $regEntry.DisplayName
                Type = "Registry"
            }
        }
    }
    return $installed
}

# --- Função: remove aplicativo corretamente ---
function Remove-AppFull {
    param($App)
    Write-Host "`n🗑️ Removendo $($App.Name)..." -ForegroundColor Cyan

    switch ($App.Type) {
        "Appx" {
            Get-AppxPackage -Name $App.RealName | Remove-AppxPackage -ErrorAction SilentlyContinue
        }
        "AppxAllUsers" {
            Get-AppxPackage -Name $App.RealName -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        }
        "Registry" {
            $regEntries = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall,
                                            HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall |
                          Get-ItemProperty | Where-Object { $_.DisplayName -eq $App.RealName }

            foreach ($entry in $regEntries) {
                $us = $entry.UninstallString
                if ($us) {
                    $us = ($us.Replace('/I','/uninstall') + ' /quiet').Replace('  ',' ')
                    $FilePath = ($us.Substring(0,$us.IndexOf('.exe')+4).Trim())
                    $ProcessArgs = ($us.Substring($us.IndexOf('.exe')+5).Trim().replace('  ',' '))
                    Start-Process -FilePath $FilePath -Args $ProcessArgs -Wait -ErrorAction SilentlyContinue
                }
            }
        }
    }

    # Remove diretórios locais (Appx)
    $localPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Packages', $App.RealName)
    if (Test-Path $localPath) {
        Remove-Item $localPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "✅ $($App.Name) removido com sucesso!"
}

# --- Passo 1: detectar apps instalados ---
$installedApps = Get-InstalledApps -AppList $apps

if ($installedApps.Count -eq 0) {
    Write-Host "✅ Nenhum aplicativo da lista está instalado neste computador." -ForegroundColor Green
    exit
}

# --- Passo 2: mostrar apps instalados ---
Write-Host "`n📌 Aplicativos Microsoft encontrados instalados:"
for ($i=0; $i -lt $installedApps.Count; $i++) {
    Write-Host "[$i] $($installedApps[$i].Name) - Tipo: $($installedApps[$i].Type)"
}

# --- Passo 3: pedir seleção ---
Write-Host "`nDigite os números separados por vírgula dos aplicativos que deseja desinstalar."
Write-Host "Ou digite 'A' para remover TODOS os aplicativos listados."
$selection = Read-Host "Sua escolha"

$toRemove = @()

if ($selection -match '^[Aa]$') {
    $toRemove = $installedApps
} else {
    $indices = $selection -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }
    foreach ($i in $indices) {
        if ([int]$i -ge 0 -and [int]$i -lt $installedApps.Count) {
            $toRemove += $installedApps[$i]
        }
    }
}

if ($toRemove.Count -eq 0) {
    Write-Host "❎ Nenhum aplicativo selecionado. Encerrando script." -ForegroundColor Red
    exit
}

# --- Passo 4: remover apps selecionados ---
foreach ($app in $toRemove) {
    Remove-AppFull -App $app
}

Write-Host "`n🎉 Processo concluído! Todos os aplicativos selecionados foram removidos." -ForegroundColor Cyan
