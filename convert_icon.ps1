# Script PowerShell para converter PNG para ICO
# Uso: .\convert_icon.ps1

Write-Host "🎨 Convertendo PNG para ICO..." -ForegroundColor Cyan

# Verifica se o arquivo PNG existe
if (-not (Test-Path "assets\icon\app_icon.png")) {
    Write-Host "❌ Erro: assets\icon\app_icon.png não encontrado!" -ForegroundColor Red
    exit 1
}

# Carrega a imagem
Add-Type -AssemblyName System.Drawing
$png = [System.Drawing.Image]::FromFile((Resolve-Path "assets\icon\app_icon.png"))

# Cria o ícone em vários tamanhos
$sizes = @(16, 32, 48, 64, 128, 256)
$icon = New-Object System.Drawing.Icon($png, 256, 256)

# Salva como ICO
$outputPath = "assets\icon\app_icon.ico"
$stream = [System.IO.File]::Create($outputPath)
$icon.Save($stream)
$stream.Close()

Write-Host "✅ Ícone criado: $outputPath" -ForegroundColor Green

# Limpa recursos
$png.Dispose()
$icon.Dispose()

