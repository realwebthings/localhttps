# local-https

Map any local port to any custom domain with a trusted HTTPS certificate — no browser warnings.

Works on macOS, Linux, and Windows using [mkcert](https://github.com/FiloSottile/mkcert) and optionally nginx.

## Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/realwebthings/localhttps/main/install.sh | bash
```

### Windows (PowerShell as Administrator)

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
irm https://raw.githubusercontent.com/realwebthings/localhttps/main/install.ps1 | iex
```

---

## The `localhttps` CLI

The installer also puts a global `localhttps` command on your PATH. Use it from any
project, any time, to serve a port on a trusted HTTPS domain — no manual cert,
hosts file, or nginx config editing, ever:

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

---

## What the installer does

The installer (macOS/Linux) only sets up the `localhttps` command — it does not ask
any questions. All actual setup (mkcert, nginx, `/etc/hosts`, certificates) happens
lazily, automatically, the first time you run `localhttps use`.

---

## Security

- Certificate files are cached outside any project, in `~/.localhttps/certs`
- Never commit certificate files — add `*.pem` to your `.gitignore`
- The mkcert CA is only trusted on your local machine
