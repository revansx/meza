# mwclient role

Installs the [mwclient](https://github.com/mwclient/mwclient) Python library,
pinned to `mwclient_version`, into a dedicated virtual environment
(`m_mwclient_venv`, default `/opt/meza-venvs/mwclient`) on app servers.

User documentation: [`manual/MWCLIENT.md`](../../../manual/MWCLIENT.md).

## Behavior

Runs on every deploy (in the "Configure MediaWiki on app servers" play, after
the `mediawiki` role).

When `m_install_mwclient` is true:

1. Installs the Python used for the environment (`package_venv_python`:
   `python3.12` on RedHat-family, `python3` + `python3-venv` on Debian).
2. Rebuilds the environment if it was built with a different Python, then
   installs `mwclient=={{ mwclient_version }}`.
3. Installs helpers in `<venv>/share/meza/`:
   - `createLocalBotPassword.php`: MediaWiki maintenance script that creates a
     bot password restricted to this server's own addresses.
   - `check_mwclient.py`: the deploy check.
4. If `m_install_mezabot` is true, ensures the `Mezabot` account exists and is
   in the `bot` group on every wiki (`mezabot.yml`).
5. Checks the installed mwclient version; if `m_install_mezabot` is true, also
   connects to every wiki over HTTPS through HAProxy, verifying the certificate
   against `m_os_ca_bundle`, and fails the deploy with instructions if that
   fails (`check.yml`).

When `m_install_mwclient` is false, removes the environment (and
`/opt/meza-venvs` if empty). The `Mezabot` account is left in place.

## Variables

| Variable | Defined in | Default |
|---|---|---|
| `m_install_mwclient` | `config/defaults.yml` | `false` |
| `mwclient_version` | `config/defaults.yml` | `"0.11.0"` |
| `m_install_mezabot` | `config/defaults.yml` | `false` |
| `m_mwclient_venv` | `config/paths.yml` | `{{ m_install_dir }}/meza-venvs/mwclient` |
| `package_venv_python`, `m_venv_python`, `m_os_ca_bundle` | `config/RedHat.yml`, `config/Debian.yml` | OS-specific |
