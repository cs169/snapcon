# SnapCon one-click start script (PowerShell)
# First run: install deps + init DB. Later: just start.

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot
Set-Location $ProjectRoot

$EnvFile = Join-Path $ProjectRoot ".env"
$PlaceholderPassword = "your_postgres_password_here"
$PlaceholderSecret = "development_secret_replace_with_rake_secret_output"

# ---------- 1. Ensure .env exists ----------
if (-not (Test-Path $EnvFile)) {
    @"
OSEM_DB_HOST=localhost
OSEM_DB_PORT=5432
OSEM_DB_USER=postgres
OSEM_DB_PASSWORD=$PlaceholderPassword
OSEM_DB_NAME=osem_development
SECRET_KEY_BASE=$PlaceholderSecret
OSEM_NAME=SnapCon
FULL_CALENDAR_LICENSE_KEY=GPL-My-Project-Is-Open-Source
"@ | Set-Content $EnvFile -Encoding UTF8
}

# If password still placeholder, prompt once
$lines = Get-Content $EnvFile
$pwdLine = $lines | Where-Object { $_ -match "^OSEM_DB_PASSWORD=" }
if ($pwdLine -eq "OSEM_DB_PASSWORD=$PlaceholderPassword") {
    $pwd = Read-Host "Enter PostgreSQL password (user: postgres)"
    $lines = $lines -replace "OSEM_DB_PASSWORD=$PlaceholderPassword", "OSEM_DB_PASSWORD=$pwd"
    $lines | Set-Content $EnvFile -Encoding UTF8
}

# ---------- 2. Node deps ----------
Write-Host ""
Write-Host "[*] npm install..." -ForegroundColor Cyan
& npm install
if ($LASTEXITCODE -ne 0) { throw "npm install failed" }

# ---------- 3. Ruby deps (find pg_config; use path without spaces for gem build) ----------
$pgConfig = $null
$pgRoot = "C:\Program Files\PostgreSQL"
if (Test-Path $pgRoot) {
    $folders = Get-ChildItem -Path $pgRoot -Directory -ErrorAction SilentlyContinue
    foreach ($f in ($folders | Sort-Object Name -Descending)) {
        $p = Join-Path $pgRoot ($f.Name + "\bin\pg_config.exe")
        if (Test-Path $p) {
            $pgConfig = $p -replace '\\Program Files\\', '\Progra~1\'
            if (-not (Test-Path $pgConfig)) { $pgConfig = $p }
            break
        }
    }
}
if ($pgConfig) {
    Write-Host ""
    Write-Host "[*] Using PostgreSQL: $pgConfig" -ForegroundColor Cyan
    $pgConfigForGem = $pgConfig -replace '\\', '/'
    & bundle config set --local build.pg "--with-pg-config=$pgConfigForGem"
    $pgBin = Split-Path $pgConfig
    $env:PATH = "$pgBin;$env:PATH"
} else {
    Write-Host ""
    Write-Host "[!] pg_config not found under $pgRoot - pg gem may fail." -ForegroundColor Yellow
}
Write-Host ""
Write-Host "[*] bundle install..." -ForegroundColor Cyan
& bundle config set --local without production 2>$null
& bundle config set --local path vendor/bundle 2>$null
& bundle install
if ($LASTEXITCODE -ne 0) { throw "bundle install failed" }

# ---------- 4. SECRET_KEY_BASE ----------
$lines = Get-Content $EnvFile
$secretLine = $lines | Where-Object { $_ -match "SECRET_KEY_BASE=" }
if ($secretLine -match $PlaceholderSecret) {
    Write-Host ""
    Write-Host "[*] Generating SECRET_KEY_BASE..." -ForegroundColor Cyan
    $errPref = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    $raw = & bundle exec rake secret 2>&1
    $ErrorActionPreference = $errPref
    if ($raw -is [string]) { $raw = $raw -split "`n" }
    $secret = ($raw | Where-Object { $_ -and ($_ -match '^[a-zA-Z0-9]{50,}$') } | Select-Object -First 1)
    if (-not $secret) { $secret = (($raw | Where-Object { $_.Trim().Length -gt 40 }) -join "`n").Trim() }
    if ($secret) {
        $lines = $lines -replace "SECRET_KEY_BASE=$PlaceholderSecret", "SECRET_KEY_BASE=$secret"
        $lines | Set-Content $EnvFile -Encoding UTF8
    }
}

# ---------- 5. Database ----------
Write-Host ""
Write-Host "[*] Setting up database..." -ForegroundColor Cyan
$errPref = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
bundle exec rake db:create 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "  (db may already exist, continuing)" -ForegroundColor Yellow }
$dbSetupOut = & bundle exec rake db:setup 2>&1
$dbExit = $LASTEXITCODE
$ErrorActionPreference = $errPref
if ($dbExit -ne 0) {
    Write-Host ""
    Write-Host "db:setup failed. Full output below:" -ForegroundColor Red
    $dbSetupOut | ForEach-Object { Write-Host $_ }
    throw "db:setup failed. Check: 1) PostgreSQL is running  2) .env OSEM_DB_PASSWORD is correct for user postgres."
}

# ---------- 6. Start Rails ----------
Write-Host ""
Write-Host "[*] Starting server -> http://localhost:3000" -ForegroundColor Green
$ErrorActionPreference = "SilentlyContinue"
bundle exec rails server
