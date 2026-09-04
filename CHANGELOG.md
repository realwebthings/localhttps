# Changelog

All notable changes to this project are documented in this file.

## [0.0.17] - 2026-09-04

- fix: improve error handling for stale nginx configurations and enhance symlink management
- Auto-heal now names the specific domain removed and how to re-add it, instead of a generic message
- Recreate the sites-enabled symlink when it's missing or stale, not just when absent

## [0.0.16] - 2026-09-04

- fix: improve port management and error handling for nginx startup
- Extend Apache/httpd port-conflict detection and auto-stop to macOS (previously Linux-only)
- Auto-retry nginx start on Linux after clearing a detected port conflict
- Auto-remove a stale/broken localhttps-managed nginx config (from a previous failed run) and retry, instead of leaving nginx unable to start for any domain
- Guard several `sudo ...` calls that could silently kill the script under `set -e` if they failed

## [0.0.15] - 2026-09-04

- feat: enhance localhttps CLI to support HTTP/2 and improve port management
- `--http2` is now an opt-in flag on `localhttps use`; HTTP/1.1 is the default
- Fixed a long-standing bug where a bare `return` (instead of `return 0`) after a failed test, combined with `set -e`, silently killed `localhttps use`/`stop` on the common/expected path on both macOS and Linux

## [0.0.14] - 2026-09-04

- Merge pull request #6 from realwebthings/abhishesh-laptop
- feat: add port ownership checks and ensure port is free for nginx (Linux)
- Detect Apache/httpd holding port 80/443 and prompt to stop it before nginx starts
- Surface the actual bind failure from journalctl with a hint on how to resolve it

## [0.0.13] - 2026-08-21

- revert: restore bin/localhttps to v0.0.7
- Reverted the HTTP/2 flag and HTTP→HTTPS redirect experiments after they caused a port 80 bind conflict with Apache on a user's machine

## [0.0.12] - 2026-08-19

- feat: remove HTTP server block from configuration for cleaner HTTPS setup

## [0.0.11] - 2026-08-19

- feat: enhance nginx reload handling to ensure configuration is applied
- Added a forced `nginx -s reload` follow-up after `systemctl`/`service` reload, since some setups reported success without actually applying the new config

## [0.0.10] - 2026-08-19

- feat: add HTTP to HTTPS redirection in server configuration

## [0.0.9] - 2026-08-19

- feat: remove HTTP/2 support from 'use' command and update usage instructions

## [0.0.8] - 2026-08-19

- feat: enhance 'use' command to support HTTP/2 option and update usage instructions

## [0.0.7] - 2026-08-19

- docs: update installation instructions for macOS/Linux to include Linux variants

## [0.0.6] - 2026-08-19

- Merge branch 'main' of github_realwebthings:realwebthings/localhttps

## [0.0.5] - 2026-08-19

- Merge pull request #5 from realwebthings/setup-pr-required

## [0.0.4] - 2026-08-11

- Merge pull request #4 from realwebthings/setup-pr-required

## [0.0.3] - 2026-08-11

- Merge pull request #3 from realwebthings/setup-pr-required

## [0.0.2] - 2026-08-10

- Merge pull request #2 from realwebthings/setup-pr-required

## [0.0.1] - 2026-08-10

- feat: add initial implementation of local-https installer and CLI tool

## [1.0.1] - 2026-08-09

- fix: read prompts from /dev/tty so curl|bash install works, correct install.ps1 repo URL

## [1.0.0] - 2026-08-07

Initial release.

- Interactive installer (`install.sh`, `install.ps1`) for macOS, Linux, and Windows
- Adds a local domain to `/etc/hosts`
- Installs mkcert and generates a trusted SSL certificate
- Optional nginx setup for port-free HTTPS access
- Setup guides for Linux, Windows, and macOS
