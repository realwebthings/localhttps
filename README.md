# local-https

Map any local port to any custom domain with a trusted HTTPS certificate — no browser warnings.

Works on macOS, Linux, and Windows using [mkcert](https://github.com/FiloSottile/mkcert) and optionally nginx.

## Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/realwebthings/localhttps/main/install.sh | bash
```

This only installs the `localhttps` command onto your PATH — it does not ask any
questions. All actual setup (mkcert, nginx, `/etc/hosts`, certificates) happens
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
manual cert, hosts file, or nginx config editing, ever:

```bash
localhttps use local.thesqua.re 3000   # serve https://local.thesqua.re -> :3000
localhttps use api.local 4000          # add another domain/port at the same time
localhttps stop                        # stop everything
localhttps stop api.local              # stop just one domain
localhttps list                        # show active domains
```

`localhttps use` automatically: installs mkcert/nginx if missing, adds the domain to
`/etc/hosts`, generates the certificate (cached in `~/.localhttps/certs`), writes an
nginx reverse-proxy config, and reloads nginx. Switching port or project is just
running the command again with new values — nothing to edit by hand.

If nginx's config is broken (e.g. a stale conf file left over from manual setup),
`localhttps use` fails loudly with the real nginx error and, when it can identify
the offending file, a suggested fix or `rm` command — it never silently leaves
nginx stopped.

---

## Security

- Certificate files are cached outside any project, in `~/.localhttps/certs`
  (macOS/Linux) — never commit certificate files; add `*.pem` to your `.gitignore`
- The mkcert CA is only trusted on your local machine
- `sudo` is used only where the OS requires it: editing `/etc/hosts`, installing
  system packages (mkcert, nginx), trusting the mkcert CA, and managing the nginx
  service on Linux. On macOS, nginx itself is run as your normal user, matching how
  Homebrew expects it to be managed
- Releases are cut by a GitHub Actions workflow ([release.yml](.github/workflows/release.yml))
  that runs only on pushes to `main`, using the default `GITHUB_TOKEN` scoped to
  `contents: write` — no long-lived secrets or personal tokens are used
