# local-https installer for Windows
# Usage (PowerShell as Administrator):
#   irm https://raw.githubusercontent.com/realwebthings/localhttps/main/install.ps1 | iex

#Requires -RunAsAdministrator

function Log    { Write-Host "[✔] $args" -ForegroundColor Green }
function Warn   { Write-Host "[!] $args" -ForegroundColor Yellow }
function Fail   { Write-Host "[✘] $args" -ForegroundColor Red; exit 1 }
function Info   { Write-Host $args -ForegroundColor Cyan }
function Spacer { Write-Host "" }

Clear-Host
Spacer
Info "╔══════════════════════════════════════════════╗"
Info "║        local-https interactive setup         ║"
Info "╚══════════════════════════════════════════════╝"
Spacer
Write-Host "  This tool will:"
Write-Host "   1. Add your domain to the Windows hosts file"
Write-Host "   2. Install mkcert and generate a trusted SSL certificate"
Write-Host "   3. Save the certificate to a directory you choose"
Write-Host "   4. Optionally configure nginx so you can access your app without a port"
Spacer
Read-Host "  Press Enter to continue or Ctrl+C to cancel"
Spacer

# ── Step 1: Domain ────────────────────────────────────────────────────────────
Info "── Step 1 of 4: Domain"
Spacer
Write-Host "  Choose a local domain name for your app."
Write-Host "  Examples: myapp.local  |  dev.mysite.com  |  api.local"
Spacer
$DOMAIN = Read-Host "  Enter domain"
if (-not $DOMAIN) { Fail "Domain cannot be empty." }
Spacer

# ── Step 2: Port ──────────────────────────────────────────────────────────────
Info "── Step 2 of 4: App Port"
Spacer
Write-Host "  What port is your local app running on?"
Write-Host "  This is the port you normally open in the browser (e.g. http://localhost:3000)."
Spacer
$APP_PORT = Read-Host "  Port [default: 3000]"
if (-not $APP_PORT) { $APP_PORT = "3000" }
Spacer

# ── Step 3: Certificate directory ────────────────────────────────────────────
Info "── Step 3 of 4: Certificate Location"
Spacer
Write-Host "  Where should the SSL certificate files be saved?"
Write-Host "  Tip: keep them outside your project so you never accidentally commit them."
Spacer
$DEFAULT_CERT_DIR = "$env:USERPROFILE\.local-https-certs"
$CERT_DIR = Read-Host "  Directory [default: $DEFAULT_CERT_DIR]"
if (-not $CERT_DIR) { $CERT_DIR = $DEFAULT_CERT_DIR }
Spacer

# ── Step 4: nginx (port-free access) ─────────────────────────────────────────
Info "── Step 4 of 4: Port-free Access (optional)"
Spacer
Write-Host "  By default you access your app at https://${DOMAIN}:${APP_PORT}"
Write-Host "  If you want to access it at https://$DOMAIN (no port), nginx can proxy"
Write-Host "  port 443 -> $APP_PORT for you."
Spacer
$USE_NGINX = Read-Host "  Set up nginx for port-free access? [y/N]"
if (-not $USE_NGINX) { $USE_NGINX = "N" }
Spacer

# ── App protocol question (only if nginx chosen) ──────────────────────────────
$APP_HTTPS = "N"
if ($USE_NGINX -match "^[Yy]$") {
  Write-Host "  nginx will forward incoming HTTPS requests to your app on port $APP_PORT."
  Spacer
  Write-Host "  How does your app listen on port ${APP_PORT}?"
  Write-Host "   [N] Plain HTTP  - most apps (Node, Python, Rails, Go, etc.)  <- default"
  Write-Host "   [Y] HTTPS       - your app loads the cert itself and binds HTTPS"
  Write-Host "                     (e.g. Next.js --experimental-https,"
  Write-Host "                           Node https.createServer with cert,"
  Write-Host "                           uvicorn --ssl-certfile)"
  Spacer
  Write-Host "  Not sure? Answer N. You can always re-run this script."
  Spacer
  $APP_HTTPS = Read-Host "  Does your app itself serve HTTPS on port ${APP_PORT}? [y/N]"
  if (-not $APP_HTTPS) { $APP_HTTPS = "N" }
  Spacer
}

# ── Summary ───────────────────────────────────────────────────────────────────
Spacer
Info "  Summary"
Write-Host "  ───────────────────────────────────────"
Write-Host "  Platform   : Windows"
Write-Host "  Domain     : $DOMAIN"
Write-Host "  App port   : $APP_PORT"
Write-Host "  Cert dir   : $CERT_DIR"
if ($USE_NGINX -match "^[Yy]$") {
  Write-Host "  nginx      : yes (port-free access)"
} else {
  Write-Host "  nginx      : no  (access via port)"
}
Write-Host "  ───────────────────────────────────────"
Spacer
Read-Host "  Looks good? Press Enter to start setup or Ctrl+C to cancel"
Spacer

# ── hosts file ────────────────────────────────────────────────────────────────
$HOSTS_FILE = "C:\Windows\System32\drivers\etc\hosts"
$hostsContent = Get-Content $HOSTS_FILE -Raw
if ($hostsContent -match [regex]::Escape($DOMAIN)) {
  Warn "hosts file already has $DOMAIN - skipping."
} else {
  Add-Content -Path $HOSTS_FILE -Value "127.0.0.1 $DOMAIN"
  Log "Added $DOMAIN to hosts file."
}

# ── Install mkcert ────────────────────────────────────────────────────────────
if (-not (Get-Command mkcert -ErrorAction SilentlyContinue)) {
  if (Get-Command choco -ErrorAction SilentlyContinue) {
    Log "Installing mkcert via Chocolatey..."
    choco install mkcert -y
  } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
    Log "Installing mkcert via Scoop..."
    scoop bucket add extras
    scoop install mkcert
  } else {
    Fail "Neither Chocolatey nor Scoop found. Install one from https://chocolatey.org or https://scoop.sh then re-run."
  }
} else {
  Warn "mkcert already installed - skipping."
}

mkcert -install
Log "mkcert CA trusted by your system."

# ── Generate certificate ──────────────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path $CERT_DIR | Out-Null
if ((Test-Path "$CERT_DIR\$DOMAIN.pem") -and (Test-Path "$CERT_DIR\$DOMAIN-key.pem")) {
  Warn "Certificates already exist in $CERT_DIR - skipping generation."
} else {
  mkcert -cert-file "$CERT_DIR\$DOMAIN.pem" -key-file "$CERT_DIR\$DOMAIN-key.pem" $DOMAIN
  Log "Certificates saved to $CERT_DIR"
}

# ── nginx setup ───────────────────────────────────────────────────────────────
$NGINX_DIR  = "C:\nginx"
$NGINX_CONF = "$NGINX_DIR\conf\$DOMAIN.conf"

if ($USE_NGINX -match "^[Yy]$") {
  if (-not (Test-Path "$NGINX_DIR\nginx.exe")) {
    $INSTALL_NGINX = Read-Host "nginx not found. Download and install it now? [y/N]"
    if ($INSTALL_NGINX -notmatch "^[Yy]$") { Fail "nginx is required for port-free access. Aborting." }

    $NGINX_VERSION = "1.26.2"
    $NGINX_ZIP     = "$env:TEMP\nginx.zip"
    $NGINX_URL     = "https://nginx.org/download/nginx-$NGINX_VERSION.zip"

    Log "Downloading nginx $NGINX_VERSION..."
    Invoke-WebRequest -Uri $NGINX_URL -OutFile $NGINX_ZIP
    Expand-Archive -Path $NGINX_ZIP -DestinationPath "C:\" -Force
    Rename-Item "C:\nginx-$NGINX_VERSION" $NGINX_DIR -Force
    Log "nginx extracted to $NGINX_DIR"
  } else {
    Warn "nginx already exists at $NGINX_DIR - skipping download."
  }

  $CERT_PATH = "$CERT_DIR\$DOMAIN.pem"     -replace "\\", "/"
  $KEY_PATH  = "$CERT_DIR\$DOMAIN-key.pem" -replace "\\", "/"

  if ($APP_HTTPS -match "^[Yy]$") {
    $PROXY_LINE = "proxy_pass https://localhost:${APP_PORT};`n        proxy_ssl_verify off;"
  } else {
    $PROXY_LINE = "proxy_pass http://localhost:${APP_PORT};"
  }

  $nginxConf = @"
server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate     $CERT_PATH;
    ssl_certificate_key $KEY_PATH;

    location / {
        $PROXY_LINE
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
    }
}
"@

  Set-Content -Path $NGINX_CONF -Value $nginxConf

  $mainConf         = Get-Content "$NGINX_DIR\conf\nginx.conf" -Raw
  $includeDirective = "include $DOMAIN.conf;"
  if ($mainConf -notmatch [regex]::Escape($includeDirective)) {
    $mainConf = $mainConf -replace "http \{", "http {`n    include $DOMAIN.conf;"
    Set-Content "$NGINX_DIR\conf\nginx.conf" $mainConf
    Log "Included $DOMAIN.conf in nginx.conf"
  }

  Log "nginx config written to $NGINX_CONF"
  Set-Location $NGINX_DIR
  Start-Process "nginx.exe"
  Log "nginx started."
}

# ── Done ──────────────────────────────────────────────────────────────────────
Spacer
Info "╔══════════════════════════════════════════════╗"
Info "║               Setup complete!                ║"
Info "╚══════════════════════════════════════════════╝"
Spacer
Write-Host "  Certificate : $CERT_DIR\$DOMAIN.pem"
Write-Host "  Key         : $CERT_DIR\$DOMAIN-key.pem"
Spacer

if ($USE_NGINX -match "^[Yy]$") {
  Write-Host "  Access your app at: https://$DOMAIN"
} else {
  Write-Host "  Access your app at: https://${DOMAIN}:${APP_PORT}"
  Spacer
  Write-Host "  To use the certificate with your app, pass these flags to your start command:"
  Spacer
  Write-Host "    Node/Express  : --cert `"$CERT_DIR\$DOMAIN.pem`" --key `"$CERT_DIR\$DOMAIN-key.pem`""
  Write-Host "    Next.js       : --experimental-https-cert `"$CERT_DIR\$DOMAIN.pem`" ``"
  Write-Host "                    --experimental-https-key `"$CERT_DIR\$DOMAIN-key.pem`""
  Write-Host "    Python/uvicorn: --ssl-certfile `"$CERT_DIR\$DOMAIN.pem`" ``"
  Write-Host "                    --ssl-keyfile `"$CERT_DIR\$DOMAIN-key.pem`""
}
Spacer
