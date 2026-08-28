# News Digest Service Setup for core-vm-news-01

This file documents the News Digest service integration into core-vm-news-01.

## Changes Made

### 1. Added News Module
- **File**: `hosts/core-vm-news-01/news.nix`
- **Source**: Copied from the News Digest repository (`nixos/news.nix`)
- **Purpose**: Provides all News Digest services (Ollama, API, nginx, timers, etc.)

### 2. Updated Host Configuration
- **File**: `hosts/core-vm-news-01/configuration.nix`
- **Changes**:
  - Added import for `../../hosts/core-vm-news-01/news.nix`
  - Added `nixpkgs.overlays` for CPU-only Ollama
  - Added `services.news` configuration block

## Current Configuration

The News Digest service is configured with:

```nix
services.news = {
  enable = true;
  schedule = "06:30";
  selfUrl = "https://news.nepstad.it";
  apiPort = 8080;
  externalAiTimeoutMinutes = 10;
  keepRawDays = 7;
  keepArchivesYears = 10;
  repoPath = "/var/src/news";
  gitRemote = "origin";
  gitEmail = "news@topheinz.com";
  gitName = "News Digest Bot";
};
```

## Services Created

The module creates the following systemd services and timers:

### Services
- `ollama.service` - CPU-only Ollama for local LLM inference
- `news-api.service` - HTTP API for external AI webhook (port 8080)
- `nginx.service` - Web server for static content
- `news-digest.service` - Main digest processing service
- `news-archival.service` - Nightly git archival

### Timers
- `news-digest.timer` - Daily at 06:30 Europe/Oslo
- `news-archival.timer` - Nightly at 03:00

### Data Directories
- `/var/lib/news/` - All data stored here
  - `raw/` - Raw feed data (7-day retention)
  - `digests/` - Processed digests (10-year retention)
  - `static/` - Static HTML pages
  - `state/` - Service state files
  - `run/` - Runtime files (PIDs, etc.)
  - `pending/` - External AI tracking

### Environment File
- `/etc/news/news.env` - Contains SMTP credentials and other secrets
  - Must be created from `news/sending/.env.example`
  - Must be owned by `news:news` with mode `0600`

## Deployment Steps

### Step 1: Deploy the Configuration

```bash
# On core-vm-news-01 or from your deployment machine:
cd /path/to/nixos-config
sudo nixos-rebuild switch --flake .#core-vm-news-01
```

This will:
- Download and install Ollama and other dependencies
- Create the `news` user and group
- Create all data directories
- Enable all services and timers

**Note**: The first build will take significant time as it downloads packages.

### Step 2: Clone the News Digest Repository

```bash
sudo mkdir -p /var/src/news
sudo git clone https://github.com/HeinzNepe/news /var/src/news
sudo chown -R news:news /var/src/news
```

### Step 3: Set Up Environment File

```bash
sudo mkdir -p /etc/news
sudo cp /var/src/news/sending/.env.example /etc/news/news.env

# Edit with your Fastmail credentials
sudo nano /etc/news/news.env

# Set proper permissions
sudo chmod 600 /etc/news/news.env
sudo chown news:news /etc/news/news.env
```

Required settings in `/etc/news/news.env`:
```bash
SMTP_HOST=smtp.fastmail.com
SMTP_PORT=465
SMTP_USER=news@topheinz.com
SMTP_PASS=your-fastmail-app-password-here
FROM_ADDR=digest@topheinz.com
RECIPIENTS=news@topheinz.com
NEWS_SELF_URL=https://news.nepstad.it
API_PORT=8080
```

### Step 4: Pull the Ollama Model

The model should auto-pull on first boot. To manually verify:

```bash
# Check if model is loaded
sudo -u ollama ollama list

# If not, pull it manually (~9 GB, takes several minutes)
sudo -u ollama ollama pull gemma4:12b

# Verify
sudo -u ollama ollama list
```

### Step 5: Verify Services

```bash
# Check all services are running
systemctl status ollama.service
systemctl status news-api.service
systemctl status nginx.service

# Check timers are enabled
systemctl status news-digest.timer
systemctl status news-archival.timer

# Check news user exists
id news
ls -la /var/lib/news/
```

### Step 6: Run Benchmarks (P0 Acceptance)

Run the benchmark script from the News Digest repository:

```bash
# Run comprehensive benchmarks
python3 /var/src/news/docs/00-deploy-p0.md

# Or use the quick benchmark commands from that file
```

**Critical**: Document results in `/var/src/news/docs/benchmarks.md`

Target acceptance criteria:
- Generation rate > 3 tok/s
- Full synthetic run < 75 minutes
- Cold model load < 5 minutes

### Step 7: Test Digest Run

```bash
# Trigger a manual digest
sudo systemctl start news-digest.service

# View logs
journalctl -u news-digest -f

# Check if digest was created
ls -la /var/lib/news/digests/$(date +%Y)/$(date +%Y-%m-%d).json

# Validate the digest
python3 /var/src/news/processing/validate.py --date $(date +%Y-%m-%d)
```

### Step 8: Test API Endpoint

```bash
# Check API is running
systemctl status news-api.service

# Test config endpoint
curl http://localhost:8080/api/config

# Test with authentication (if configured)
curl -H "X-API-Key: your-key" http://localhost:8080/api/config
```

## Reverse Proxy Configuration

Since `core-vm-news-01` is behind a reverse proxy at `news.nepstad.it`, ensure your gateway is configured to forward traffic.

### Caddy Example (Recommended)

On your gateway/reverse proxy host:

```caddy
news.nepstad.it {
    reverse_proxy http://<core-vm-news-01-ip>:80 {
        header_up Host news.nepstad.it
        header_up X-Forwarded-Host news.nepstad.it
        header_up X-Forwarded-Proto {scheme}
        header_up X-Real-IP {remote_host}
    }
}
```

### Nginx Example

```nginx
server {
    listen 80;
    server_name news.nepstad.it;
    
    location / {
        proxy_pass http://<core-vm-news-01-ip>:80;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## Troubleshooting

### Model Pull Fails

```bash
# Check logs
journalctl -u ollama -f

# Check disk space
df -h /var/lib/ollama

# Manual pull
sudo -u ollama ollama pull gemma4:12b
```

### Services Fail to Start

```bash
# Check all service logs
journalctl -u news-digest -u news-api -u ollama -u nginx --since "1 hour ago"

# Test configuration
sudo nixos-rebuild test
```

### Digest Not Created

```bash
# Test fetch
sudo -u news python3 /var/src/news/run-digest.py --date $(date +%Y-%m-%d) --fetch-only

# Test process
sudo -u news python3 /var/src/news/run-digest.py --date $(date +%Y-%m-%d) --process-only

# Check raw data
ls -la /var/lib/news/raw/$(date +%Y-%m-%d)/
```

### Permission Errors

```bash
# Check ownership
ls -la /var/lib/news/
ls -la /var/src/news/
ls -la /etc/news/

# Fix permissions
sudo chown -R news:news /var/lib/news/
sudo chmod 600 /etc/news/news.env
sudo chown news:news /etc/news/news.env
```

## Next Steps After P0

Once P0 is complete (benchmarks documented, services verified):

1. **Update news repo**: Commit benchmark results to `docs/benchmarks.md`
2. **P2**: Implement AI integration (Ollama client in processing module)
3. **P3**: Implement webpage rendering
4. **P4**: Implement email sending

See the News Digest repository [docs/07-roadmap.md](https://github.com/HeinzNepe/news/blob/main/docs/07-roadmap.md) for full phase tracking.

## Files Modified

- `hosts/core-vm-news-01/news.nix` - News Digest NixOS module (NEW)
- `hosts/core-vm-news-01/configuration.nix` - Updated with news service config

## Useful Commands

```bash
# View service logs
journalctl -u news-digest -f
journalctl -u news-api -f
journalctl -u ollama -f

# Trigger manual digest
sudo systemctl start news-digest.service

# Restart all news services
sudo systemctl restart ollama.service news-api.service nginx.service

# Check timer status
systemctl list-timers | grep news

# Check disk usage
du -sh /var/lib/ollama/models
df -h /var/lib/ollama

# Check memory usage
free -h
```
