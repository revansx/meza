# mwclient: Python scripts on the app server

Meza can install [mwclient](https://github.com/mwclient/mwclient), a Python
client for the MediaWiki API, so that unattended scripts running **on the app
server** can read and edit the wikis. This is intended for **monolith**
deployments (HAProxy, Apache and MediaWiki on one server).

The approach keeps meza out of authentication:

- Scripts log in with a **bot password** that is restricted to this server's
  own IP addresses, so the credentials are useless from anywhere else.
- Bot passwords are separate from interactive login. If you install SSO
  (for example PluggableAuth with `$wgPluggableAuth_EnableLocalLogin = false`),
  people still log in through SSO while scripts keep using bot passwords.
  *Confirm this on your SSO configuration before relying on it.*

## Settings

Set these in `/opt/conf-meza/public/public.yml` and run `meza deploy <env>`.

| Setting | Default | Effect |
|---|---|---|
| `m_install_mwclient` | `false` | `true` installs mwclient into `/opt/meza-venvs/mwclient`. Setting it back to `false` removes that environment on the next deploy. |
| `mwclient_version` | `"0.11.0"` | Exact mwclient version installed. 0.11.0 supports MediaWiki 1.16 and later. |
| `m_install_mezabot` | `false` | `true` also creates the `Mezabot` account on every wiki and checks, at the end of each deploy, that mwclient can reach every wiki over HTTPS. Ignored unless `m_install_mwclient` is `true`. |

The environment uses Python 3.12 on RHEL/Rocky and the system `python3` on
Debian. Use it by running scripts with `/opt/meza-venvs/mwclient/bin/python`
(or that path as the script's `#!` line).

### Certificate requirement

Scripts connect to `https://<wiki_app_fqdn>/<wiki_id>/` exactly like a browser
does, through HAProxy. **This requires a certificate for `wiki_app_fqdn`
signed by a CA in the OS trust store** (a public CA such as Let's Encrypt, or an
internal CA installed into the OS trust store). Meza's self-signed certificate
is not supported.

With `m_install_mezabot: true`, every deploy checks this. If verification
fails, the deploy stops with a message explaining how to continue:

```yaml
m_install_mezabot: false   # keep mwclient, skip the Mezabot account and HTTPS check
m_install_mwclient: false  # skip all mwclient tasks (removes the mwclient environment)
```

Python's `requests` library does **not** use the OS trust store by default; it
uses its own bundle of public CAs (`certifi`). Point your scripts at the OS
bundle so internal CAs work too:

- RHEL/Rocky: `/etc/pki/tls/certs/ca-bundle.crt`
- Debian: `/etc/ssl/certs/ca-certificates.crt`

## The Mezabot account

With `m_install_mezabot: true`, each deploy makes sure an account named
`Mezabot` exists and is in the `bot` group on every wiki (including wikis
created later). Notes:

- **Groups:** only `bot`. A bot password can never grant more than its account
  has, so if a script needs more (for example `sysop` to delete pages), add
  that group to `Mezabot` on that wiki yourself
  (`createAndPromote --force --sysop Mezabot`, or Special:UserRights).
- **Password:** set to a random 32-character value when the account is created,
  and never stored or shown. `Mezabot` is meant to be used only through bot
  passwords. If you ever need an interactive login, reset it with
  `WIKI=<id> /opt/htdocs/mediawiki/maintenance/run changePassword --user Mezabot --password ...`.
- **Name:** MediaWiki capitalizes the first letter, so the account is
  `Mezabot`.
- **Existing account with the same name:** if a wiki (for example an imported
  one) already has a user named `Mezabot`, the deploy adds that account to the
  `bot` group. Check before enabling `m_install_mezabot` on imported wikis.
- **Turning it off:** setting `m_install_mezabot` or `m_install_mwclient` to
  `false` leaves `Mezabot` in place, because MediaWiki cannot cleanly delete
  accounts and its edits should stay attributed. To disable it, revoke its bot
  passwords (below) and/or block it with Special:Block.

You can also use any other account by passing `--user` to the helper below.

## Creating a bot password for a script

Bot passwords are stored **per wiki** (meza shares the user table, not the
`bot_passwords` table), so create one on each wiki the script uses. Use a
separate app ID per script, and grant only what it needs.

Meza installs a helper that creates the bot password with the right IP
restrictions:

```bash
# List valid grants
sudo WIKI=demo /opt/htdocs/mediawiki/maintenance/run \
  /opt/meza-venvs/mwclient/share/meza/createLocalBotPassword.php --showgrants

# Create (or replace) the bot password "nightly-report" for Mezabot on wiki "demo"
sudo WIKI=demo /opt/htdocs/mediawiki/maintenance/run \
  /opt/meza-venvs/mwclient/share/meza/createLocalBotPassword.php \
  --appid nightly-report --grants basic,highvolume,editpage
```

It prints the login name (`Mezabot@nightly-report`) and a generated password,
**once**. Running it again with the same app ID replaces the old password.

### Which addresses are allowed, and why

When a script on the server connects to the wiki's public hostname, Linux uses
the server's own address (the one the hostname resolves to) as the source, not
`127.0.0.1`. HAProxy passes that address to MediaWiki, so that is the address
the bot password must allow. The helper sets **Allowed IP ranges** to:

- `127.0.0.1/32` and `::1/128`
- every address the wiki's hostname resolves to **that belongs to this
  server's network interfaces** (taken from `$wgServer`)

If the hostname resolves to an address this server does not own (typical
behind NAT or an external load balancer), the helper stops. In that setup the
address MediaWiki sees may be shared with other machines, so a bot password
limited to it would not be limited to this server. If you understand and accept
that, add the address explicitly:

```bash
... createLocalBotPassword.php --appid nightly-report --grants basic \
    --allow-ip 203.0.113.10
```

### Storing the bot password

Store it in a file readable only by the account that runs the script, outside
the web root, for example:

```bash
install -d -m 700 ~/.config/nightly-report
install -m 600 /dev/null ~/.config/nightly-report/botpassword
# paste the password into that file
```

Never put bot passwords in `/opt/conf-meza/public`, in the wiki, or in version
control.

## Example script

```python
#!/opt/meza-venvs/mwclient/bin/python
import time
from pathlib import Path

import mwclient

HOST = 'wiki.example.com'          # wiki_app_fqdn
WIKI = 'demo'                      # wiki ID
CA_BUNDLE = '/etc/pki/tls/certs/ca-bundle.crt'   # Debian: /etc/ssl/certs/ca-certificates.crt
BOT_LOGIN = 'Mezabot@nightly-report'
PASSWORD = (Path.home() / '.config/nightly-report/botpassword').read_text().strip()

site = mwclient.Site(
    HOST,
    path='/{}/'.format(WIKI),
    scheme='https',
    connection_options={'verify': CA_BUNDLE, 'timeout': 60},
    # Identify the script and a contact (MediaWiki API etiquette)
    clients_useragent='nightly-report/1.0 (ops@example.com)',
    max_retries=5,
    retry_timeout=10,
)
site.login(BOT_LOGIN, PASSWORD)

page = site.pages['Project:Nightly report']
page.edit('Report generated at ' + time.strftime('%Y-%m-%d %H:%M'),
          summary='Nightly report')
```

Use `site.login()` (bot passwords), not `site.clientlogin()` (interactive
accounts).

## Slow down: HAProxy rate limits apply to scripts too

All scripts on the server share one source address, and HAProxy rate-limits
per address over a 10-second window (defaults in
`src/roles/haproxy/defaults/main.yml`):

| Requests in 10 s | Result |
|---|---|
| more than 900 | requests are delayed (tarpit) |
| more than 2500 | requests are refused with HTTP 429 |
| more than **10 HTTP errors** | requests are refused |

The error limit is the easiest to hit: a loop that keeps getting 4xx responses
locks every script on the server out for the rest of the window. So:

- keep scripts to a few requests per second (`time.sleep()` between edits);
- use the API's batching (`limit=`/generators) instead of many small calls;
- stop on repeated errors instead of retrying in a tight loop.

## Revoking access

```bash
# Invalidate all of Mezabot's bot passwords on one wiki
sudo WIKI=demo /opt/htdocs/mediawiki/maintenance/run invalidateBotPasswords --user Mezabot
```

Repeat for each wiki. To replace a single bot password, run the helper again
with the same `--appid`. Users who can log in as the owning account can also
manage bot passwords in Special:BotPasswords.
