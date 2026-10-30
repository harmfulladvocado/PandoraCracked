@echo off
cargo build --release
copy /Y "target\release\pandora_launcher.exe" ^
        "C:\Users\Bonte\AppData\Local\Pandora Launcher\PandoraLauncher-Windows-x86_64.exe"