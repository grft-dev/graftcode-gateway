$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Show-GraftcodeIntro {
    Clear-Host

    Write-Host @"
   _____            __ _                 _      
  / ____|          / _| |               | |     
 | |  __ _ __ __ _| |_| |_ ___ ___   __| | ___ 
 | | |_ | '__/ _` |  _| __/ __/ _ \ / _` |/ _ \
 | |__| | | | (_| | | | || (_| (_) | (_| |  __/
  \_____|_|  \__,_|_|  \__\___\___/ \__,_|\___|

"@ -ForegroundColor Cyan

    Write-Host "Graftcode helps you generate AI code that integrates through Graftcode." -ForegroundColor White
    Write-Host "It can reduce boilerplate, simplify PRs, and save up to 80% of tokens." -ForegroundColor White
    Write-Host ""
    Write-Host "This installer can:" -ForegroundColor Yellow
    Write-Host "  1. Download Graftcode Rules file for your IDE"
    Write-Host "     - so AI can generate code that integrates everything through Graftcode"
    Write-Host "  2. Download Graftcode Gateway"
    Write-Host "     - gateway for your processor"
    Write-Host ""
}

function Read-MenuChoice {
    param(
        [string]$Prompt,
        [string[]]$AllowedChoices
    )

    while ($true) {
        $Choice = Read-Host $Prompt
        $Choice = $Choice.Trim()

        if ($AllowedChoices -contains $Choice) {
            return $Choice
        }

        Write-Host "Invalid choice. Available options: $($AllowedChoices -join ', ')" -ForegroundColor Red
    }
}

function Download-FileWithSpinner {
    param(
        [string]$Url,
        [string]$OutputPath,
        [string]$Label
    )

    Write-Host "Downloading $Label..."

    $Job = Start-Job {
        param($Url, $OutputPath)
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest $Url -OutFile $OutputPath
    } -ArgumentList $Url, $OutputPath

    $Spinner = '|', '/', '-', '\'
    $Index = 0

    while ($Job.State -eq 'Running') {
        Write-Host -NoNewline "`rDownloading $Label $($Spinner[$Index++ % $Spinner.Count])"
        Start-Sleep -Milliseconds 120
    }

    Receive-Job $Job | Out-Null
    Remove-Job $Job

    Write-Host "`rDownloaded $Label " -ForegroundColor Green
}

function Install-GraftcodeRules {
    Write-Host ""
    Write-Host "Choose IDE:" -ForegroundColor Yellow
    Write-Host "  1. Cursor"
    Write-Host ""

    $IdeChoice = Read-MenuChoice -Prompt "Enter choice [1]" -AllowedChoices @('1')

    switch ($IdeChoice) {
        '1' {
            $RulesDir = Join-Path $PWD ".cursor\rules"

            if (-not (Test-Path $RulesDir)) {
                New-Item -ItemType Directory -Path $RulesDir -Force | Out-Null
            }

            $Rules = @(
                @{
                    Url = "https://raw.githubusercontent.com/grft-dev/graftcode-demos/refs/heads/main/rules/Cursor/.cursor/rules/graftcode-dotnet.mdc"
                    FileName = "graftcode-dotnet.mdc"
                },
                @{
                    Url = "https://raw.githubusercontent.com/grft-dev/graftcode-demos/refs/heads/main/rules/Cursor/.cursor/rules/graftcode-typescript-node-nextjs.mdc"
                    FileName = "graftcode-typescript-node-nextjs.mdc"
                }
            )

            foreach ($Rule in $Rules) {
                $OutputPath = Join-Path $RulesDir $Rule.FileName
                Download-FileWithSpinner -Url $Rule.Url -OutputPath $OutputPath -Label $Rule.FileName
            }

            Write-Host ""
            Write-Host "Installed Graftcode Cursor rules in:" -ForegroundColor Green
            Write-Host $RulesDir
        }
    }
}

function Install-GraftcodeGateway {
    $Repo = 'grft-dev/graftcode-gateway'
    $ExeName = 'gg.exe'
    $OutputPath = Join-Path $PWD $ExeName

    try {
        $OsArch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLowerInvariant()
    }
    catch {
        try {
            $OsArch = [System.Runtime.InteropServices.RuntimeInformation,mscorlib]::OSArchitecture.ToString().ToLowerInvariant()
        }
        catch {
            $OsArch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
        }
    }

    $ArchPattern = switch ($OsArch) {
        'arm64' { 'arm64|aarch64' }
        'x64'   { 'x64|amd64' }
        'x86'   { 'x86|win32|i386' }
        default { throw "Unsupported architecture: $OsArch" }
    }

    Write-Host ""
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
    Download-FileWithSpinner -Url $Asset.browser_download_url -OutputPath $ZipPath -Label $Asset.name

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

    Write-Host ""
    Write-Host "Installed Graftcode Gateway:" -ForegroundColor Green
    Write-Host $OutputPath
}

Show-GraftcodeIntro

Write-Host "What do you want to install?" -ForegroundColor Yellow
Write-Host "  1. Graftcode Rules file"
Write-Host "  2. Graftcode Gateway"
Write-Host ""

$Choice = Read-MenuChoice -Prompt "Enter choice [1/2]" -AllowedChoices @('1', '2')

switch ($Choice) {
    '1' { Install-GraftcodeRules }
    '2' { Install-GraftcodeGateway }
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
