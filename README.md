# XpreSS

⚠️ **Intentionally vulnerable — for education and authorized security testing only. Do not deploy to production or expose to the public internet.**

## Purpose

XpreSS is a deliberately vulnerable PHP web app for learning and practicing Cross-Site Scripting (XSS). Similar in spirit to DVWA, but focused on XSS variants. Use in isolated lab environments for security training, CTF practice, penetration testing, and tool evaluation.

## Current Features


| Type          | File            | Vector                                              |
| ------------- | --------------- | --------------------------------------------------- |
| Reflected XSS | `search.php`    | `$_GET['q']` echoed in HTML body and input `value`  |
| Stored XSS    | `guestbook.php` | POST data stored in MySQL and rendered unsanitized  |
| DOM-based XSS | `profile.php`   | URL params (`user`, `bio`) injected via `innerHTML` |
| Filter bypass | `challenges.php` | Weak blacklists — script, events, nesting, attributes |


**Example payloads:**

```
/search.php?q=<script>alert('XSS')</script>
/profile.php?user=<img src=x onerror=alert('XSS')>
/guestbook.php  →  Name: <img src=x onerror=alert('XSS')>
```



## Quick Setup

**Prerequisites:** Debian/Ubuntu, sudo, remote MySQL at `198.18.4.214` with `xpress_db` / `xpress_user` / `xpress_pass` (see `setup-database.sql`).

```bash
git clone <repository-url> && cd XpreSS
chmod +x setup.sh install.sh
sudo ./setup.sh          # LAMP install + deploy to /var/www/html/xpress
# or
curl -SL https://github.com/CorbanPendrak/XpreSS/releases/latest/download/install.sh | bash
```

Access at `http://localhost/`. DB credentials are set via Apache env vars in `/etc/apache2/conf-available/xpress-env.conf`.

**Deploy to remote server:**

```bash
./deploy.sh   # or rsync via deploy.sh defaults
```



## File Structure

```
XpreSS/
├── index.php           # Landing page
├── search.php          # Reflected XSS
├── guestbook.php       # Stored XSS
├── profile.php         # DOM XSS
├── challenges.php      # Filter bypass challenge hub
├── challenge-*.php     # Individual bypass levels
├── filters.php         # Intentionally weak blacklist filters
├── db_config.php       # PDO config (env vars)
├── setup.sh            # LAMP stack setup
├── install.sh          # Bootstrap installer
├── setup-database.sql  # Remote DB schema
├── setup-users.sh      # Lab user provisioning
├── deploy.sh           # Remote rsync deploy
├── retro-style.css
└── .htaccess
```



## Roadmap

### XSS Scenarios

- [ ] Context-specific XSS (HTML body, attribute, JS string, CSS)
- [ ] Blind XSS (admin review panel)
- [ ] Mutation XSS (mXSS)
- [ ] CSP bypass lab
- [x] Filter bypass challenges
- [ ] JSON/API XSS



### Educational

- [ ] Secure mode toggle (encoded vs vulnerable side-by-side)
- [ ] Difficulty levels and solution hints
- [ ] Attack logging / CTF scoring
- [ ] Cookie/session theft lab



### DevOps & UX

- [ ] Docker Compose for local setup
- [ ] `test-database.sh` connection checker
- [ ] Shared PHP layout (header/footer partials)
- [ ] Guestbook reset endpoint



## Rework Needed

- **Doc/script drift** — README and `deploy.sh` reference `setup-lamp.sh` and `test-database.sh`; actual script is `setup.sh`, test script missing
- **Stale references** — `guestbook_data.txt` in docs; guestbook uses MySQL
- **Hardcoded lab infra** — IPs and credentials scattered across `db_config.php`, `setup.sh`, `deploy.sh`, README
- **Redundant MariaDB install** — `setup.sh` installs local MariaDB but app uses remote DB
- **Duplicated HTML** — forms and layout repeated across `index.php`, `search.php`, `guestbook.php`
- **DB error handling** — `db_config.php` dies on connection failure with exposed error details
- **Plaintext lab passwords** — `setup-users.sh` stores credentials in repo
- `.htaccess` **CORS headers** — require `mod_headers`, not enabled by `setup.sh`
- `info.php` **leak** — setup creates `phpinfo()` page; easy to forget to remove



## Disclaimer

Intentionally insecure. Use only in isolated test environments with no real user data.