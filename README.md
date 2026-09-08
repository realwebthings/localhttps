# localhttps

Map any local port to any custom domain with a trusted HTTPS certificate — no browser warnings.

Works on macOS, Linux, and Windows using [mkcert](https://github.com/FiloSottile/mkcert) and either
nginx or Apache as the reverse proxy.

## Install

### macOS / Linux / Linux variants

```bash
curl -fsSL https://raw.githubusercontent.com/realwebthings/localhttps/main/install.sh | bash
```

This only installs the `localhttps` command onto your PATH — it does not ask any
questions. All actual setup (mkcert, nginx/Apache, `/etc/hosts`, certificates) happens
lazily and automatically the first time you run `localhttps use`.

### Windows (PowerShell as Administrator)

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
irm https://raw.githubusercontent.com/realwebthings/localhttps/main/install.ps1 | iex
```

Windows does not have the `localhttps` CLI yet. `install.ps1` is a one-shot
interactive wizard: it asks for a domain, port, certificate location, and whether
to set up nginx, then configures exactly that. To change domain or port later,
re-run the wizard.

---

## The `localhttps` CLI (macOS / Linux)

Use it from any project, any time, to serve a port on a trusted HTTPS domain — no
manual cert, hosts file, or web server config editing, ever:

```bash
localhttps use local.thesqua.re 3000   # serve https://local.thesqua.re -> :3000
localhttps use api.local 4000          # add another domain/port at the same time
localhttps use api.local 4000 --http2  # enable HTTP/2 for this domain
localhttps use api.local 4000 --apache # force Apache as the backend for this domain
localhttps use api.local 4000 --nginx  # force nginx as the backend for this domain
localhttps stop                        # stop everything
localhttps stop api.local              # stop just one domain
localhttps list                        # show active domains, ports, and backend
localhttps update                      # update the CLI itself to the latest version
localhttps help                        # show usage
```

### Which web server does it use?

`localhttps use` picks a backend automatically, per domain, so you rarely need to think
about it:

- Only nginx installed → nginx
- Only Apache installed → Apache
- Neither installed → installs and uses nginx (the default)
- Both installed → asks once, unless you pass `--apache`/`--nginx` to skip the prompt
  (handy for scripts, or CI)

Passing `--apache` or `--nginx` explicitly installs that backend if it isn't already
present — nothing is installed that you didn't ask for or that isn't required to serve
the domain.

`localhttps use` automatically: installs mkcert and the chosen web server if missing,
adds the domain to `/etc/hosts`, generates the certificate (cached in
`~/.localhttps/certs`), writes a reverse-proxy config for that backend, and reloads it.
Switching port, backend, or project is just running the command again with new values —
nothing to edit by hand.

`localhttps stop` reverses `use` fully: it removes the domain's reverse-proxy config,
removes the `/etc/hosts` entry it added, and reloads whichever backend(s) were affected
— nothing is left behind.

If the backend's config is broken (e.g. a stale conf file left over from manual setup),
`localhttps use` fails loudly with the real nginx/Apache error and, when it can identify
the offending file, a suggested fix or `rm` command — it never silently leaves the
web server stopped.

---

## Security

- Certificate files are cached outside any project, in `~/.localhttps/certs`
  (macOS/Linux) — never commit certificate files; add `*.pem` to your `.gitignore`
- The mkcert CA is only trusted on your local machine
- `sudo` is used only where the OS requires it: editing `/etc/hosts`, installing
  system packages (mkcert, nginx, Apache), trusting the mkcert CA, and managing the
  nginx/Apache service on Linux. On macOS, nginx and Apache are run as your normal
  user, matching how Homebrew expects them to be managed
- Only the web server localhttps is actively serving is ever auto-stopped to free
  port 80/443 — an unrelated, independently-run nginx or Apache instance is left
  alone and reported as a conflict instead
- Releases are cut by a GitHub Actions workflow ([release.yml](.github/workflows/release.yml))
  that runs only on pushes to `main`. `main` requires a pull request to merge; the
  workflow's own changelog/tag push uses a scoped `RELEASE_PAT` (repo-only,
  `Contents: Read and write`) stored as an Actions secret, since branch protection
  blocks the default `GITHUB_TOKEN` from pushing directly
