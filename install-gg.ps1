$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$Repo = 'grft-dev/graftcode-gateway'
$ExeName = 'gg.exe'
$OutputPath = Join-Path $PWD $ExeName

$OsArch = ([Runtime.InteropServices.RuntimeInformation]::OSArchitecture).ToString().ToLowerInvariant()
$ArchPattern = switch ($OsArch) {
    'arm64' { 'arm64|aarch64' }
    'x64'   { 'x64|amd64' }
    default { throw "Unsupported architecture: $OsArch" }
}

Write-Host "Detected architecture: $OsArch"
Write-Host "Fetching latest release from $Repo..."

$Release = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest"
$Asset = $Release.assets |
    Where-Object {
        $_.name -match '(?i)\.zip$' -and
        $_.name -match '(?i)(win|windows)' -and
        $_.name -match "(?i)($ArchPattern)" -and
        $_.name -notmatch '(?i)sha256|checksum|checksums|signature|sig'
    } |
    Select-Object -First 1

if (-not $Asset) {
    $Available = ($Release.assets | ForEach-Object { $_.name }) -join "`n - "
    throw "Could not find Windows ZIP for architecture '$OsArch'. Available assets:`n - $Available"
}

$ZipPath = Join-Path $env:TEMP $Asset.name

Write-Host "Downloading $($Asset.name)..."

$Job = Start-Job {
    param($Url, $ZipPath)
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest $Url -OutFile $ZipPath
} -ArgumentList $Asset.browser_download_url, $ZipPath

$Spinner = '|', '/', '-', '\'
$Index = 0
while ($Job.State -eq 'Running') {
    Write-Host -NoNewline "`rDownloading $($Asset.name) $($Spinner[$Index++ % $Spinner.Count])"
    Start-Sleep -Milliseconds 120
}

Receive-Job $Job | Out-Null
Remove-Job $Job
Write-Host "`rDownloaded $($Asset.name)                    "

Add-Type -AssemblyName System.IO.Compression.FileSystem

$Zip = [IO.Compression.ZipFile]::OpenRead($ZipPath)
try {
    $Entry = $Zip.Entries |
        Where-Object { $_.Name -ieq $ExeName } |
        Select-Object -First 1

    if (-not $Entry) {
        throw "Could not find $ExeName inside $($Asset.name)"
    }

    if (Test-Path $OutputPath) {
        Remove-Item $OutputPath -Force
    }

    [IO.Compression.ZipFileExtensions]::ExtractToFile($Entry, $OutputPath, $true)
}
finally {
    $Zip.Dispose()
    if (Test-Path $ZipPath) {
        Remove-Item $ZipPath -Force
    }
}

Write-Host "Installed: $OutputPath"
