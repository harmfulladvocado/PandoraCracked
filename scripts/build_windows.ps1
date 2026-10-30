param(
    [Parameter(Mandatory=$true)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

# Strip leading 'v' if present
$version = $Version.TrimStart('v')
$env:PANDORA_RELEASE_VERSION = $version

# Build
cargo build --release --frozen --target x86_64-pc-windows-msvc

# Create dist folder
New-Item -ItemType Directory -Force -Path dist | Out-Null

# Copy exe to dist
Copy-Item "target\x86_64-pc-windows-msvc\release\pandora_launcher.exe" `
          "dist\PandoraLauncher-Windows-x86_64.exe" -Force

# Install cargo-packager and run it
cargo install cargo-packager

$packagerConfig = @{
    name       = "pandora-launcher"
    outDir     = "./dist"
    productName = "Pandora Launcher"
    version    = $version
    identifier = "com.moulberry.pandoralauncher"
    resources  = @()
    authors    = @("Moulberry")
    binaries   = @(@{ path = "PandoraLauncher-Windows-x86_64.exe"; main = $true })
    icons      = @("package/windows.ico")
} | ConvertTo-Json -Compress

# Remove signing key so packager doesn't require it
$env:CARGO_PACKAGER_SIGN_PRIVATE_KEY = $null
cargo packager --config $packagerConfig

# Rename outputs
Move-Item -Force "dist\PandoraLauncher-Windows-x86_64.exe" `
                 "dist\PandoraLauncher-Windows-x86_64-Portable.exe"
Move-Item -Force "dist\PandoraLauncher-Windows-x86_64_${version}_x64-setup.exe" `
                 "dist\PandoraLauncher-Windows-x86_64-Setup.exe"

Write-Host ""
Write-Host "Done! Output files in .\dist\"
Write-Host "  Portable : dist\PandoraLauncher-Windows-x86_64-Portable.exe"
Write-Host "  Installer: dist\PandoraLauncher-Windows-x86_64-Setup.exe"
