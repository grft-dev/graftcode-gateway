# install-gg.ps1
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$u = "https://github.com/grft-dev/graftcode-gateway/releases/latest/download/gg_windows_amd64.zip"
$z = Join-Path $env:TEMP "gg.zip"
$d = Join-Path $env:TEMP "gg"

try {
  # szybkie pobieranie bez progressu
  (New-Object Net.WebClient).DownloadFile($u, $z)

  Expand-Archive $z $d -Force

  $exe = Get-ChildItem $d -Recurse -Filter gg.exe | Select-Object -First 1
  if (-not $exe) { throw "Nie znaleziono gg.exe w rozpakowanym archiwum." }

  Copy-Item $exe.FullName -Destination (Get-Location) -Force
}
finally {
  Remove-Item $z -Force -ErrorAction SilentlyContinue
  Remove-Item $d -Recurse -Force -ErrorAction SilentlyContinue
}
