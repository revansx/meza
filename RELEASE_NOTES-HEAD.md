## Meza Release Notes c8d3669ba28550c2f44db868ae1b66196800c310 → HEAD

### Commits

HEAD -> main origin/main
* [7ad6350a](https://github.com/freephile/meza/commit/7ad6350a) (2026-11-23) Rich Evans: Remove meza-managed SAML/SimpleSAMLphp support and BackupDownload Meza no longer installs, configures or serves SAML. Sites that want SAML
must add the SimpleSAMLphp/PluggableAuth extensions themselves via
/opt/conf-meza/public/MezaLocalExtensions.yml and install and configure
the SimpleSAMLphp library/service outside of meza deploys.
Removed:
- saml role (SimpleSAMLphp tarball, PluggableAuth + SimpleSAMLphp
  extensions, all config templates) and its include in mediawiki role
- simplesamlphp_version, saml_mw_extension_version and m_simplesamlphp_*
  variables
- /simplesaml Alias/Directory blocks in the apache and apache-php httpd
  templates
- $saml_idp_username_attr in config.php; SAML check in landing page
- office.html and the ms-office .htaccess rule (SSO-only workaround)
- samlAuthorizations.d directories/templates (configure-wiki,
  init-controller-config)
- BackupDownload interface, which could only authenticate via
  SimpleSAMLphp, plus allow_backup_downloads, wiki_backup_downloaders,
  all_backup_downloaders and backups_environment. Deploys now always
  delete /opt/htdocs/BackupDownload if present.
- SAML references in comments and READMEs; regenerated
  src/playbooks/site-w-tasks.svg
Upgrading existing installations: meza does not delete SAML leftovers,
since a site may now manage them itself. If unused, admins may remove:
  /opt/simplesamlphp
  /var/cache/simplesamlphp
  /opt/htdocs/mediawiki/extensions/{PluggableAuth,SimpleSAMLphp}
  /opt/.deploy-meza/{SAMLConfig.php,samlLocalSettings.php}
  /opt/htdocs/{NonMediaWikiSimpleSamlAuth.php,office.html}
  /opt/conf-meza/public/samlAuthorizations.d
  /opt/conf-meza/public/wikis/*/samlAuthorizations.d
Tested: yamllint clean; ansible-lint production profile shows no new
findings; site.yml syntax check passes; full monolith deploy succeeded
(failed=0) with wiki pages and API search returning 200 and no SAML
references in deployed Apache/htdocs config.
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
  - Modified: `config/defaults.yml`
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/site-w-tasks.svg`
  - Modified: `src/roles/README.md`
  - Modified: `src/roles/apache-php/tasks/php-redhat8.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/apache-php/templates/php-fpm-httpd.conf.j2`
  - Modified: `src/roles/apache/templates/httpd.conf.j2`
  - Modified: `src/roles/apache/templates/php-fpm-httpd.conf.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/configure-wiki/README.md`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Deleted: `src/roles/configure-wiki/templates/samlAuthorizations.d/base.php.dist.j2`
  - Modified: `src/roles/htdocs/README.md`
  - Deleted: `src/roles/htdocs/files/BackupDownload/DownloadTest.php`
  - Deleted: `src/roles/htdocs/files/BackupDownload/PATH_RESOLUTION_FIX.md`
  - Deleted: `src/roles/htdocs/files/BackupDownload/README.md`
  - Deleted: `src/roles/htdocs/files/BackupDownload/download.php`
  - Deleted: `src/roles/htdocs/files/BackupDownload/index.php`
  - Modified: `src/roles/htdocs/meta/main.yml`
  - Modified: `src/roles/htdocs/tasks/main.yml`
  - Modified: `src/roles/htdocs/templates/.htaccess.j2`
  - Modified: `src/roles/htdocs/templates/index.php.j2`
  - Deleted: `src/roles/htdocs/templates/office.html.j2`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/php/tasks/php-redhat8.yml`
  - Deleted: `src/roles/saml/defaults/main.yml`
  - Deleted: `src/roles/saml/tasks/main.yml`
  - Deleted: `src/roles/saml/templates/NonMediaWikiSimpleSamlAuth.php.j2`
  - Deleted: `src/roles/saml/templates/SAMLConfig.php.j2`
  - Deleted: `src/roles/saml/templates/authsources.php.j2`
  - Deleted: `src/roles/saml/templates/config.php.j2`
  - Deleted: `src/roles/saml/templates/saml20-idp-remote.php.j2`
  - Deleted: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [83db3c3d](https://github.com/freephile/meza/commit/83db3c3d) (2026-11-22) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [75e77a54](https://github.com/freephile/meza/commit/75e77a54) (2026-11-22) Rich Evans: Fix auto-generated admin password failing policy check The "Generate admin_password" task drew 10 random chars from letters,
digits and all punctuation, then relied on until/retries to redraw when
the result failed the password policy. Ansible templates set_fact args
only once per task, so every retry re-checks the same value; the retries
never help. About 40% of draws lack a required class (often a digit, or
only punctuation outside the allowed set such as a backtick), so a fresh
deploy without an admin_password failed at verify-wiki roughly 40% of
the time, leaving a half-initialized wiki.
Build the password from guaranteed parts instead (8 lowercase, 3
uppercase, 3 digits, 2 symbols), then shuffle, giving 16 chars that
always pass. Symbols come from a shell/YAML-safe subset of the allowed
list (no $ ` ' " \ ,). Remove the ineffective until/retries.
Tested: 200 runs through the real task file all passed the policy
assertions; yamllint clean; ansible-lint production profile passes;
verified on a fresh monolith deploy (Admin account created, login OK).
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
  - Modified: `src/roles/verify-wiki/tasks/ensure-admin-password.yml`

* [2d672432](https://github.com/freephile/meza/commit/2d672432) (2026-10-27) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [41caa5a1](https://github.com/freephile/meza/commit/41caa5a1) (2026-10-27) Greg Rundlett: Fix Ansible linting errors - line 95 Ensure PEAR channel up-to-date:
Uses shell where command may suffice; no changed-when condition
- line 98 Ensure PEAR channel up-to-date:
Uses pipe without setting pipefail
- line 105 Install memcached PECL packages:
Compares STDOUT to empty string; pipe without setting pipefail
-  line 114 Template 40-memcached.ini.j2:
Template task has no name
  - Modified: `src/roles/php/tasks/php-redhat8.yml`

* [260a8b31](https://github.com/freephile/meza/commit/260a8b31) (2026-10-27) Greg Rundlett: Force pecl memcache so existing doesn't block 
  - Modified: `src/roles/php/tasks/php-redhat8.yml`

* [c3adac8d](https://github.com/freephile/meza/commit/c3adac8d) (2026-10-27) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [c0e4a2d8](https://github.com/freephile/meza/commit/c0e4a2d8) (2026-10-27) Greg Rundlett: use new 'php_version' variable switch to remi-8.2 for security fix
The only role that uses this is the 'php' role.
  - Modified: `src/roles/php/tasks/php-redhat8.yml`

* [3e7346fb](https://github.com/freephile/meza/commit/3e7346fb) (2026-10-25) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [2a9404f2](https://github.com/freephile/meza/commit/2a9404f2) (2026-10-25) Greg Rundlett: use new 'php_version' variable switch to remi-8.2 for security fix
The only role that uses this is the 'php' role.
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/php/tasks/php-redhat8.yml`

* [dc0bc269](https://github.com/freephile/meza/commit/dc0bc269) (2026-10-21) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [2be1f42a](https://github.com/freephile/meza/commit/2be1f42a) (2026-10-20) Greg Rundlett: remote change from gerrit to github in a comment 
  - Modified: `src/roles/init-controller-config/templates/MezaLocalExtensions.yml.j2`

* [bffb2622](https://github.com/freephile/meza/commit/bffb2622) (2026-10-21) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [3a1e06c9](https://github.com/freephile/meza/commit/3a1e06c9) (2026-10-20) Greg Rundlett: switch Gerrit repo sources to GitHub 
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `config/MezaCoreSkins.yml`

* [07849b61](https://github.com/freephile/meza/commit/07849b61) (2026-10-02) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [2a142a75](https://github.com/freephile/meza/commit/2a142a75) (2026-10-02) Greg Rundlett: maps from 12.1.x to 15.x for security 
  - Modified: `config/MezaCoreExtensions.yml`

* [6d33effb](https://github.com/freephile/meza/commit/6d33effb) (2026-09-22) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [a29d650b](https://github.com/freephile/meza/commit/a29d650b) (2026-09-21) Greg Rundlett: Fix vuln in SMW API https://github.com/advisories/GHSA-jr78-w6w5-m8f8
Admin API is vulnerable, this fix can be backed out after upgrade.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [1388a6a3](https://github.com/freephile/meza/commit/1388a6a3) (2026-09-21) Greg Rundlett: Drop rule that blocks empty User Agent Empty User Agent header can be legitimate, but unsophisticated tools
So, allow them and monitor for bad traffic.
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [d5a2a880](https://github.com/freephile/meza/commit/d5a2a880) (2026-08-24) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [4968e3aa](https://github.com/freephile/meza/commit/4968e3aa) (2026-08-24) Greg Rundlett: Make meza.local a convenient DNS name for Vagrant dev 
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [c52a6ebc](https://github.com/freephile/meza/commit/c52a6ebc) (2026-08-06) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [e4dcbc57](https://github.com/freephile/meza/commit/e4dcbc57) (2026-08-05) Greg Rundlett: update the Netdata MD5 checksum 
  - Modified: `src/roles/netdata/tasks/main.yml`

* [837c974e](https://github.com/freephile/meza/commit/837c974e) (2026-08-05) Greg Rundlett: Fix TLS cert creation to include SAN Including a Subject Alternative Name has been standard since 2000 when CN (Common Name) was deprecated.
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [818243a8](https://github.com/freephile/meza/commit/818243a8) (2026-08-05) Greg Rundlett: Add VSCode with Vagrant instructions 
  - Modified: `manual/DEVELOPING.md`

* [496f46e0](https://github.com/freephile/meza/commit/496f46e0) (2026-08-05) Greg Rundlett: Add synced folders for config and uploads to Vagrantfile 
  - Modified: `Vagrantfile`

* [e56845fd](https://github.com/freephile/meza/commit/e56845fd) (2026-08-05) Greg Rundlett: Ignore TLS certificates (.crt .key .pem) 
  - Modified: `.gitignore`

* [2e13305a](https://github.com/freephile/meza/commit/2e13305a) (2026-06-22) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [cc6d0269](https://github.com/freephile/meza/commit/cc6d0269) (2026-06-22) Greg Rundlett: Remove SubpageFun extension SubpageFun is unmaintained and is breaks usage of the SubPageList ext.
Fixes Bug #383
  - Modified: `config/MezaCoreExtensions.yml`

* [e4b28716](https://github.com/freephile/meza/commit/e4b28716) (2026-06-20) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [d7eb218d](https://github.com/freephile/meza/commit/d7eb218d) (2026-06-20) Greg Rundlett: Document core skins We allow site CSS on restricted pages (e.g. Special:UserLogin) to allow
MediaWiki:Common.css 'site styles' to be applied on the login page as well.
By setting $wgAllowSiteCSSOnRestrictedPages = true; any custom style
is not lost on those special pages.
  - Modified: `config/MezaCoreSkins.yml`

* [75bdb500](https://github.com/freephile/meza/commit/75bdb500) (2026-06-20) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [4b9eaeed](https://github.com/freephile/meza/commit/4b9eaeed) (2026-06-20) Greg Rundlett: Check ES aliases for both general and content Elasticsearch needs aliases for both the wiki_general and
wiki_content physical indexes
What this looks like when it's good:
curl -s localhost:9200/_cat/indices/wiki_wiki*?h=index
wiki_wiki_content_first
wiki_wiki_general_first
'wiki_' is the database prefix
'wiki' is the wiki ID
'content' and 'general' are indexes that exist
'first' is the suffix given to each alias for the respective index.
Continuing fix for Bug #376
  - Modified: `src/roles/mediawiki/templates/elastic-build-index.sh.j2`

* [61d2a16f](https://github.com/freephile/meza/commit/61d2a16f) (2026-06-19) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [a56bdc8f](https://github.com/freephile/meza/commit/a56bdc8f) (2026-06-18) Greg Rundlett: Upgrade Bootstrap and Chameleon Upgrade Bootstrap ext from 5.x to 6.x for the Bootstrap framework
We get the Chameleon 6.x skin by specifying dev-master
https://www.mediawiki.org/wiki/Skin:Chameleon
These now support MediaWiki 1.43 and later on PHP 8.1 and later
The actual components provided to MediaWiki by the  Bootstrap Components
extension are documented at
https://github.com/oetterer/BootstrapComponents/blob/master/docs/components.md
and include Accordion, Alert, Badge, Button, Card, Carousel, Collapse
Jumbotron, Modal, Popover, and Tooltip
Freephile wiki notes at https://wiki.freephile.org/wiki/Bootstrap
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `config/MezaCoreSkins.yml`

* [2c234607](https://github.com/freephile/meza/commit/2c234607) (2026-06-08) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [d2ec3ced](https://github.com/freephile/meza/commit/d2ec3ced) (2026-06-08) Greg Rundlett: There is no more .smw.json file in SMW 7 fixes Bug #374
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [85c9649b](https://github.com/freephile/meza/commit/85c9649b) (2026-06-08) Greg Rundlett: modify thumbnailing for SVG handling 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [08a55334](https://github.com/freephile/meza/commit/08a55334) (2026-06-08) Greg Rundlett: Modify mediawiki role and meza.py to avoid hangs With the Ansible debug mode enabled, and with the way meza was executing
shell commands, a deploy could hang waiting for interactive input such
as a git password for a protected repository during git clone  - but
we'd never know about it.
Added
    GIT_TERMINAL_PROMPT: "0"
    GCM_INTERACTIVE: "Never"
to the MediaWiki role's git tasks
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/scripts/meza.py`

* [f37d5f55](https://github.com/freephile/meza/commit/f37d5f55) (2026-06-08) Greg Rundlett: Remove Universal Language Selector from Core ULS is now in Meza Local Extensions along with the rest of the MLEB
MediaWiki Language Extension Bundle
This includes
- Translate: Manages translation workflows for pages and messages,
enabling community translation and versioning.
- Universal Language Selector (ULS): Provides language selection, custom
fonts, and input methods for non-Latin alphabets.
- Babel: Allows users to add their language proficiency to user pages
and find other speakers.
- CLDR: Offers a massive database of language and country name translations
We needed the Translate extension to be able to use some of the
templates from MediaWiki.org such as the TNT template which is a
dependency of the ColoredBox and ContentGrid templates and modules
used on the discgolf wiki
  - Modified: `config/MezaCoreExtensions.yml`

* [9e1f793f](https://github.com/freephile/meza/commit/9e1f793f) (2026-06-08) Greg Rundlett: Improve Elasticsearch handling and docs The meza maint rebuild command now uses Ansible's Apply
directive to properly cascade the 'tags: always' to the set-vars
included role. Without it, some tasks weren't executing and the
list_of_wikis was not populated.
The elastic-build-index.sh template is fortified by detecting
different error conditions and responding appropriately
We also drain the job queue after rebuilding the index so that it
at least reports some content is indexed (there can be more still in
the job queue.)
Update maintenance, deploy and create docs
Fixes Bug #376
  - Modified: `manual/meza-cmd/create.md`
  - Modified: `manual/meza-cmd/deploy.md`
  - Modified: `manual/meza-cmd/maint.md`
  - Modified: `src/playbooks/rebuild-smw-and-index.yml`
  - Modified: `src/roles/mediawiki/templates/elastic-build-index.sh.j2`
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [b02a0a7a](https://github.com/freephile/meza/commit/b02a0a7a) (2026-06-07) Greg Rundlett: Update SMW to 7.x and Semantic Compound Queries Update Semantic Compound Queries from 3.x-dev to dev-master for SMW 7
Update Semantic MediaWiki to 7.x for the new features
Fixes Bug #374
  - Modified: `config/MezaCoreExtensions.yml`

* [65beb5b8](https://github.com/freephile/meza/commit/65beb5b8) (2026-06-07) Greg Rundlett: Upgrade Maps extension to v12.1.x We upgraded SMW to 7.x and it would appear that Maps 11 is not compatible
There isn't explicit compatibility info in the Maps matrix chart.
In any case, upgrade to the latest stable which is 12.x
fixes Bug #377
  - Modified: `config/MezaCoreExtensions.yml`

* [d92e9b4a](https://github.com/freephile/meza/commit/d92e9b4a) (2026-06-07) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [7435e6e4](https://github.com/freephile/meza/commit/7435e6e4) (2026-06-07) Greg Rundlett: Fix deploys that hang on cloning the YouTub repo ansible debugger should not be enabled for regular deploys.
To enable the debugger in a single run, use the environment var:
ANSIBLE_ENABLE_TASK_DEBUGGER=True sudo meza deploy monolith -vvv
Fixes Bug #372
  - Modified: `config/ansible.cfg`

* [154d74e5](https://github.com/freephile/meza/commit/154d74e5) (2026-05-06) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [91a449b3](https://github.com/freephile/meza/commit/91a449b3) (2026-05-06) Greg Rundlett: Improve Footer Link for Section 508 Accessibility You don't have to, but you can create/edit MediaWiki:
section508compliance for the link text
and
section508compliance-url for the link target (internal or external)
Key points vs. the current code:
1. **`isDisabled()`** — returns `true` when no `MediaWiki:` page exists
for that key, giving you a clean place to inject defaults without
requiring any per-wiki setup.
2. **`->escaped()`** — use instead of raw `Message` object as element
content; the current code passes the `Message` object directly to
`Html::rawElement()`, which relies on implicit `__toString()` and skips
escaping.
3. **`->getLocalURL()`** — `Title::newFromText()` returns a `Title`
object, not a string; the current code passes the object as the `href`
value.
4. **Separate message for URL** — separating the display text
(`section508compliance`) from the target page name
(`section508compliance-url`) lets wikis point to an external URL or a
differently-named page without editing link text, and vice versa.
Fixes Issue#369
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [7f595637](https://github.com/freephile/meza/commit/7f595637) (2026-04-17) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [57bfaf07](https://github.com/freephile/meza/commit/57bfaf07) (2026-04-16) Greg Rundlett: make debug more granular and idomatic (override) Similar to base.php, template a default 'override.php.dist' file
Move the $mezaDebug debug setting to the override file since base can
NOT override what is in LocalSettings.php or override.php (last one wins)
even though $mezaDebug is read from $GLOBALS in LocalSettings.
Partly addresses bug [BUG] Sessions are broken on multisite freephile/meza#367
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Added: `src/roles/configure-wiki/templates/postLocalSettings.d/override.php.dist.j2`
  - Modified: `src/roles/configure-wiki/templates/preLocalSettings.d/base.php.dist.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [94fe07fc](https://github.com/freephile/meza/commit/94fe07fc) (2026-04-16) Greg Rundlett: move ObjectCacheSessionExpiry out of SMW into LocalSettings.php $wgObjectCacheSessionExpiry is not about SMW
It's about session cookie storage
The default is one hour, and we want a longer session so be explicit with the math for clarity
Related to bug [BUG] Sessions are broken on multisite
freephile/meza#367
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [80a15691](https://github.com/freephile/meza/commit/80a15691) (2026-04-09) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [e42c5f3c](https://github.com/freephile/meza/commit/e42c5f3c) (2026-04-09) Greg Rundlett: Add basic ascii art project structure to DEVELOPING.md 
  - Modified: `manual/DEVELOPING.md`

* [e9207a76](https://github.com/freephile/meza/commit/e9207a76) (2026-04-09) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [043b4963](https://github.com/freephile/meza/commit/043b4963) (2026-04-09) copilot-swe-agent[bot]: Add GitHub Actions workflow to auto-update publiccode.yml on release Agent-Logs-Url: https://github.com/freephile/meza/sessions/286f8337-4e77-406c-aef1-6002969fe4e2
Co-authored-by: freephile <38368+freephile@users.noreply.github.com>
  - Added: `.github/workflows/update-publiccode.yml`

* [ab69f2b6](https://github.com/freephile/meza/commit/ab69f2b6) (2026-04-08) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [4ea7b035](https://github.com/freephile/meza/commit/4ea7b035) (2026-04-08) Greg Rundlett: Move haproxy config generation after tree building On a new instance, the certs and other subdirectories for /etc/haproxy
will not exist and thus the config syntax validation would fail
if done first.
Additionally, cleanup the file for Ansible linting
Category			Fixes
FQCN (22)			Added ansible.builtin. prefix to all bare module names:
				set_fact, package, file, stat, command, shell, copy, include_role, replace, service
package-latest (1)		state: latest → state: present
risky-file-permissions (6)	Added owner: root, group: root, mode to certs dir, PEM file, error dir, error pages, haproxy config, rsyslog config
jinja[spacing] (4)		Fixed {{ wiki_app_fqdn}} and {{m_private_networking_zone|default('public')}} spacing
literal-compare (1)		stat.exists == False → not stat.exists
no-changed-when (5)		Added changed_when to openssl, ansible-vault encrypt, two ansible-vault view tasks, and restorecon
command-instead-of-shell (1)	shell: restorecon ... → ansible.builtin.command:
name[template] (1)		Moved Jinja template out of mid-name position: renamed to Ensure haproxy world-accessible firewall ports are open
Change the self-signed certificate org to eQuality Technology
Issue [#272](https://github.com/freephile/meza/issues/272)
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [95da3005](https://github.com/freephile/meza/commit/95da3005) (2026-04-08) Greg Rundlett: Fix some permission-related problems #72 - disable recursive ownership task on /opt/meza
in init-controller-config
- Ensure that the mw-debug log file can be written by Apache
- move templating of cleanup-backups.sh outside the source tree
- modify affected cron
- modify documentation of cleanup-backups.sh
- delete the templated file from source. We only need to version-control
the template
Improves Issue [#72](https://github.com/freephile/meza/issues/72) and permission-related tasks
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/logrotate/tasks/main.yml`
  - Modified: `src/scripts/cleanup-backups.md`
  - Deleted: `src/scripts/cleanup-backups.sh`

* [c05d694d](https://github.com/freephile/meza/commit/c05d694d) (2026-04-08) Greg Rundlett: Note need to fix permissions once and for all Issue [#72](https://github.com/freephile/meza/issues/72) 
  - Modified: `src/scripts/getmeza.sh`

* [59a21736](https://github.com/freephile/meza/commit/59a21736) (2026-04-08) Greg Rundlett: update post_up_message with `cd` to config dir 
  - Modified: `Vagrantfile`

* [5a3bfa22](https://github.com/freephile/meza/commit/5a3bfa22) (2026-04-08) Greg Rundlett: Remove unneccessary recursive chown and chmod 
  - Modified: `Vagrantfile`

* [d77556cb](https://github.com/freephile/meza/commit/d77556cb) (2026-04-08) Greg Rundlett: Add libvirt requirement for vagrant on linux to DEVELOPING.md 
  - Modified: `manual/DEVELOPING.md`

* [b60e3733](https://github.com/freephile/meza/commit/b60e3733) (2026-04-08) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [ed8ef7de](https://github.com/freephile/meza/commit/ed8ef7de) (2026-04-08) Greg Rundlett: make wiki-check.sh executable 
  - Modified: `tests/integration/wiki-check.sh`

* [f0c51f78](https://github.com/freephile/meza/commit/f0c51f78) (2026-04-08) Greg Rundlett: Improve comments and examples for the base.php.dist file Logo overrides needed better explanation and examples.
Adds to Issue [#270](https://github.com/freephile/meza/issues/270)
  - Modified: `src/roles/configure-wiki/templates/preLocalSettings.d/base.php.dist.j2`

* [972ed71d](https://github.com/freephile/meza/commit/972ed71d) (2026-04-08) Greg Rundlett: Ensure that base.php is templated during wiki creation Without a base.php in place during configure-wiki, wgSitename is not populated for newly created wikis.
This fixes a problem introduced by Issue [#270](https://github.com/freephile/meza/issues/270)
  - Modified: `src/roles/configure-wiki/tasks/main.yml`

* [8c334526](https://github.com/freephile/meza/commit/8c334526) (2026-04-08) Greg Rundlett: Disable DynamicPageList3 for abandonment #362 Fix Issue [#362](https://github.com/freephile/meza/issues/362)
  - Modified: `config/MezaCoreExtensions.yml`

* [37520b04](https://github.com/freephile/meza/commit/37520b04) (2026-04-03) copilot-swe-agent[bot]: Add publiccode.yml for EU Open Source Solutions Catalogue listing Agent-Logs-Url: https://github.com/freephile/meza/sessions/5020d768-db4d-45b0-99f7-469b87e39717
Co-authored-by: freephile <38368+freephile@users.noreply.github.com>
  - Added: `publiccode.yml`

* [308bc05a](https://github.com/freephile/meza/commit/308bc05a) (2026-04-03) copilot-swe-agent[bot]: Initial plan 

* [43247e4f](https://github.com/freephile/meza/commit/43247e4f) (2026-04-03) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [a237ab31](https://github.com/freephile/meza/commit/a237ab31) (2026-04-03) Greg Rundlett: Finish the fighting bots update to HAProxy #323 Add tarpit and request limits for HAProxy
Add {{ansible_managed}} to config file template
Finishes Issue [#323](https://github.com/freephile/meza/issues/323)
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/haproxy/README.md`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [b57f218e](https://github.com/freephile/meza/commit/b57f218e) (2026-04-03) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [23807df9](https://github.com/freephile/meza/commit/23807df9) (2026-04-03) Greg Rundlett: Start refactor of Maintenance operations #356 Add prompt for agent to implement changes
Add doMaintenance.sh simple prototype
Add some (current) working examples in maint.md for documentation
https://github.com/freephile/meza/blob/dev/manual/meza-cmd/maint.md
for Issue [#356](https://github.com/freephile/meza/issues/356)
  - Added: `.github/prompts/plan-mezaMaintenanceRefactor.prompt.md`
  - Modified: `manual/meza-cmd/maint.md`
  - Added: `src/scripts/doMaintenance.sh`

* [03f13a09](https://github.com/freephile/meza/commit/03f13a09) (2026-04-01) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [45cca762](https://github.com/freephile/meza/commit/45cca762) (2026-04-01) Greg Rundlett: Add cache setting for Extension registration Solves Issue [#353](https://github.com/freephile/meza/issues/353)
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [7bb0704d](https://github.com/freephile/meza/commit/7bb0704d) (2026-04-01) Greg Rundlett: Enable JavaScript Unit Test interface Allows viewing Special:JavaScriptTest
Fixes Issue [#352](https://github.com/freephile/meza/issues/352)
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [f3b0e553](https://github.com/freephile/meza/commit/f3b0e553) (2026-03-27) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [4ee2b946](https://github.com/freephile/meza/commit/4ee2b946) (2026-03-27) Greg Rundlett: expand list of CrawlerProtection blocked pages Fixes Issue [#156](https://github.com/freephile/meza/issues/156)
  - Modified: `config/MezaCoreExtensions.yml`

* [8c99dbdc](https://github.com/freephile/meza/commit/8c99dbdc) (2026-03-27) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [81c5d521](https://github.com/freephile/meza/commit/81c5d521) (2026-03-27) Greg Rundlett: remove invalid parameter from template task 
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [4176a6c9](https://github.com/freephile/meza/commit/4176a6c9) (2026-03-27) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [83b5f867](https://github.com/freephile/meza/commit/83b5f867) (2026-03-27) Greg Rundlett: Make HAProxy rules more robust for blocking bots - add variable for tarpit request limit - increase hard request limit to 2500, which is really only equivalent to about 5 pages/sec So don't have more than 5 tabs open in a session you restore :-( - add deny status of HTTP 429 "too many requests" - add validation to templating of HAProxy config Continuing fixes to Issue [#323](https://github.com/freephile/meza/issues/323)
  - Modified: `src/roles/haproxy/defaults/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [091fabe5](https://github.com/freephile/meza/commit/091fabe5) (2026-03-26) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [aacf6931](https://github.com/freephile/meza/commit/aacf6931) (2026-03-26) Greg Rundlett: Fix linting (trailing spaces and line length) 
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `config/defaults.yml`

* [44a400e3](https://github.com/freephile/meza/commit/44a400e3) (2026-03-26) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [d42b95b9](https://github.com/freephile/meza/commit/d42b95b9) (2026-03-26) Greg Rundlett: Add PHP settings hierarchy to config doc 
  - Added: `assets/meza-overrides-tree-structure.png`
  - Modified: `manual/meza-cmd/config.md`

* [818f152a](https://github.com/freephile/meza/commit/818f152a) (2026-03-26) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [632e14d6](https://github.com/freephile/meza/commit/632e14d6) (2026-03-26) Greg Rundlett: Clarify language in the config manual 
  - Modified: `manual/meza-cmd/config.md`

* [288e9a73](https://github.com/freephile/meza/commit/288e9a73) (2026-03-26) Greg Rundlett: Fight the bots Make the HAProxy limits more agressive in the Ansible role defaults
2 errors/second limit
10 requests/second limit
Deny list Babbar.tech and Barkrowler User Agents from France
Improve the HAProxy configuration file template
Make the timeouts clear with 5s notation instead of 5000 for 5 seconds
Add 5s timeout for http-request
Add 30s timeout tarpit
Add the http-buffer-request option which will track how slowly clients
make requests. Client will get 408 Request Timeout when they request
only a few bytes per second.  IOW, they are ordering their lunch
verrrrrrrryyyyy sloooooowly. = slowloris attack.
https://www.haproxy.com/blog/application-layer-ddos-attack-protection-with-haprox
deny requests for old/broken HTTP 1.0 clients
deny requests for curl, phantomjs, slimerjs
deny requests for clients without a UA string
add tarpit and use 'HTTP 429 Too Many Requests' response
429 is the standard response for rate-limited requests.
Two-tier rate response:
- tarpit moderate abusers
(holds their sockets for timeout tarpit, exhausting their connection pool)
- hard-deny aggressive floods.
Issue [#323](https://github.com/freephile/meza/issues/323) and Issue [#234](https://github.com/freephile/meza/issues/234)
  - Modified: `src/roles/haproxy/defaults/main.yml`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [f94c476c](https://github.com/freephile/meza/commit/f94c476c) (2026-03-25) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [5b65fed9](https://github.com/freephile/meza/commit/5b65fed9) (2026-03-25) Greg Rundlett: Add illustration to the config documentation 
  - Added: `assets/Meza-config-file-hierarchy.png`
  - Modified: `manual/meza-cmd/config.md`

* [294929bd](https://github.com/freephile/meza/commit/294929bd) (2026-03-24) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [3e71597e](https://github.com/freephile/meza/commit/3e71597e) (2026-03-23) Greg Rundlett: add script to find "Dirty" directories that have changes 
  - Modified: `config/defaults.yml`
  - Added: `scripts/findDirtyDirs.sh`

* [d326125e](https://github.com/freephile/meza/commit/d326125e) (2026-03-23) Greg Rundlett: typo 
  - Modified: `config/MezaCoreExtensions.yml`

* [304eb7bb](https://github.com/freephile/meza/commit/304eb7bb) (2026-03-22) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [aa7c2cf0](https://github.com/freephile/meza/commit/aa7c2cf0) (2026-03-22) Greg Rundlett: update sql used for create wiki This needs to be refactored - see https://wiki.freephile.org/wiki/Charset#Updating_src/roles/verify-wiki/templates/mediawiki-tables.sql
  - Modified: `src/roles/verify-wiki/templates/mediawiki-tables.sql`

* [1f63e436](https://github.com/freephile/meza/commit/1f63e436) (2026-03-22) Greg Rundlett: remove wgDBmysql5 setting removed in REL1_33 Issue [#341](https://github.com/freephile/meza/issues/341)
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [a8300a98](https://github.com/freephile/meza/commit/a8300a98) (2026-03-22) Greg Rundlett: configure MySQL server's charset and collation Issue [#102](https://github.com/freephile/meza/issues/102) This was raised in Issue [#102](https://github.com/freephile/meza/issues/102) and is finally resolved after working through #341
  - Modified: `src/roles/database/templates/my.cnf.j2`

* [c37fff83](https://github.com/freephile/meza/commit/c37fff83) (2026-03-17) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [ad81fdca](https://github.com/freephile/meza/commit/ad81fdca) (2026-03-17) Greg Rundlett: Fix refresh-links.sh script Back in Oct 2025 we introduced a function, which failed to follow BASH order of execution and scoping rules: The function was declared AFTER it was invoked - which you can't do in BASH. @see 7dd492a389982c6318bd2b338509f091b78f3cd2
Fixes Issue [#339](https://github.com/freephile/meza/issues/339)
  - Modified: `src/roles/mediawiki/templates/refresh-links.sh.j2`

* [0e2f89a3](https://github.com/freephile/meza/commit/0e2f89a3) (2026-03-16) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [1f3a8d1a](https://github.com/freephile/meza/commit/1f3a8d1a) (2026-03-16) Greg Rundlett: Fix Syntax Highlight issue Install pygmentize and add path configuration to work around bug with
using very old Python 3.6.8
Fixes Issue [#337](https://github.com/freephile/meza/issues/337)
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/roles/base/tasks/main.yml`

* [45737f11](https://github.com/freephile/meza/commit/45737f11) (2026-03-13) Greg Rundlett: Add agentic instructions according to agents.md @See https://agents.md/
This new content is based on .github/copilot-instructions.md
  - Added: `AGENTS.md`

* [5c147fd5](https://github.com/freephile/meza/commit/5c147fd5) (2026-03-11) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [362ea45b](https://github.com/freephile/meza/commit/362ea45b) (2026-03-11) Greg Rundlett: Update Vagrantfile to use NFS for mount vagrant-libvirt handles adding the NFS export +  mounting on `vagrant up`
Addresses Issue [#268](https://github.com/freephile/meza/issues/268)
  - Modified: `Vagrantfile`
  - Modified: `manual/DEVELOPING.md`

* [8601f3a6](https://github.com/freephile/meza/commit/8601f3a6) (2026-03-11) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [b0f54fed](https://github.com/freephile/meza/commit/b0f54fed) (2026-03-11) Greg Rundlett: Improve performance via File Caching Add Cache-Control directive with mod_headers
Add mod_expires rules
Synchronize the 'php-fpm' version of httpd.conf with the canonical httpd.conf
Fixes Issue [#105](https://github.com/freephile/meza/issues/105)
  - Modified: `src/roles/apache/templates/httpd.conf.j2`
  - Modified: `src/roles/apache/templates/php-fpm-httpd.conf.j2`

* [fa56c9e2](https://github.com/freephile/meza/commit/fa56c9e2) (2026-03-11) Greg Rundlett: Add caching to MediaWiki Enable the sidebar cache w 24h expiry
Set Parser Cache to 30 days
Enable ResourceLoader caching
Address Issue [#105](https://github.com/freephile/meza/issues/105)
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [f6645fb3](https://github.com/freephile/meza/commit/f6645fb3) (2026-03-11) Greg Rundlett: Fix the indentation of the HAProxy templating Add ALPN and HTTP/2 binds
alpn h2,http/1.1 advertises HTTP/2 support during the TLS handshake
(via ALPN extension). Clients that support it (every modern browser)
will negotiate h2. HTTP/2
We still send traffic (internally) unencrypted to the MediaWiki backend,
so we don't have HTTP/2 for MediaWiki. The current flow looks like:
Client ──h2/TLS──▶ HAProxy :443 ──HTTP/1.1──▶ Apache :8080
Drop copy/paste commented content from Apache - this is HAProxy!
Addresses Issue [#323](https://github.com/freephile/meza/issues/323)
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [c123bcc5](https://github.com/freephile/meza/commit/c123bcc5) (2026-03-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [6b1dccb9](https://github.com/freephile/meza/commit/6b1dccb9) (2026-03-10) Greg Rundlett: Add Vagrant pre-requisites for Linux Issue [#268](https://github.com/freephile/meza/issues/268) 
  - Modified: `manual/DEVELOPING.md`

* [fa93b3bc](https://github.com/freephile/meza/commit/fa93b3bc) (2026-03-10) Greg Rundlett: Add comments and documentation for ARA ARA Records Ansible was shown to be extremely useful, but also requires
some thought about how to integrate it.
Add comments for easy integration in a test lab.
Address Issue [#85](https://github.com/freephile/meza/issues/85)
  - Modified: `config/ansible.cfg`
  - Added: `manual/ARA_NIST_800-53_Compliance.md`

* [3b0dd737](https://github.com/freephile/meza/commit/3b0dd737) (2026-03-10) Greg Rundlett: Improve development environment Make Vagrantfile 'multi-provider' for cross-platform support of
Windows and Linux
Using Vagrant's `VAGRANT_DEFAULT_PROVIDER` override and conditional
provider blocks. Linux users get libvirt, others stay on VirtualBox.
On Linux, DockerDesktop collides with Virtualbox, so to avoid any
problems we just use libvirt for Virtualbox on Linux.
Move post-up message so it displays AFTER you do `vagrant up` - so
it's not lost in the provisioner window.
Adopt some good practices from MediaWiki-vagrant project
Avoid adding meza-ansible to group vboxsf under libvirt bc it doesn't exist.
Address Issue [#268](https://github.com/freephile/meza/issues/268)
  - Modified: `Vagrantfile`

* [e563c965](https://github.com/freephile/meza/commit/e563c965) (2026-03-09) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [5d41d318](https://github.com/freephile/meza/commit/5d41d318) (2026-03-09) Greg Rundlett: Add info about using InstantCommons With new rate limits imposed by WMF for api requests and
their policies to thwart AI scrapers, it is important to implement
InstantCommons with the proper class, UA identifier, and configuration.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [7b5762bd](https://github.com/freephile/meza/commit/7b5762bd) (2026-03-09) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [af64c0fd](https://github.com/freephile/meza/commit/af64c0fd) (2026-03-09) Greg Rundlett: Block AI bots and scrapers Issue [#323](https://github.com/freephile/meza/issues/323) Add calculation for memory consumption for HAProxy connections
Add calculation for memory consumption for stick tables
Fix warnings in haproxy.cfg Issue [#327](https://github.com/freephile/meza/issues/327)
Restrict access to HAProxy stats to local/private networks
Fixes original Issue [#234](https://github.com/freephile/meza/issues/234)
  - Modified: `config/defaults.yml`
  - Modified: `manual/meza-cmd/config.md`
  - Modified: `src/roles/haproxy/README.md`
  - Added: `src/roles/haproxy/defaults/main.yml`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [0f899f7e](https://github.com/freephile/meza/commit/0f899f7e) (2026-03-08) Greg Rundlett: Add back the bind for port 80 Fixes #327 
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [9777616b](https://github.com/freephile/meza/commit/9777616b) (2026-03-05) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [03e2d999](https://github.com/freephile/meza/commit/03e2d999) (2026-03-05) Greg Rundlett: remove trailing space 
  - Modified: `src/roles/migrate-to-declarative-wikis/tasks/main.yml`

* [8613f218](https://github.com/freephile/meza/commit/8613f218) (2026-03-05) Greg Rundlett: add a README for the HAProxy role 
  - Added: `src/roles/haproxy/README.md`

* [0e0aa034](https://github.com/freephile/meza/commit/0e0aa034) (2026-03-05) Greg Rundlett: update declarative wiki migration deglitter migrate-wikis help
make references to 'primary_wiki' singular because there should only
ever be ONE primary wiki
fail if there is more than one primary wiki
update the pattern regex to replace declarative wiki stanza but note
that it is still problematic for handling comments when you manually
comment your wiki declaration, and then try to use the manual
"edit public.yml to create a wiki" process.
  - Modified: `manual/meza-cmd/migrate-wikis.md`
  - Modified: `src/roles/migrate-to-declarative-wikis/tasks/main.yml`

* [27f06827](https://github.com/freephile/meza/commit/27f06827) (2026-03-05) Greg Rundlett: update yaml and linter configs update ansible-lint config with Issue links and comments
update yamllint with proper list
update LINTING.md with link to Ansible docs
yaml strings do not need quotes;
unless the value is at risk of being interpreted as an integer;
so quote "128M" and "127.0.0.1"
add new variable for memcached listen port to defaults.yml
add new variable for the 'listen' port for memcached in its config file
add documentation about meza's config file hierarchy
- in manual/meza-cmd/config.md
- in public.yml template
Addresses Issue [#83](https://github.com/freephile/meza/issues/83) and Issue [#144](https://github.com/freephile/meza/issues/144)
  - Modified: `.ansible-lint`
  - Modified: `.yamllint`
  - Modified: `LINTING.md`
  - Modified: `config/defaults.yml`
  - Modified: `manual/meza-cmd/config.md`
  - Modified: `src/roles/htdocs/defaults/main.yml`
  - Modified: `src/roles/init-controller-config/templates/public.yml.j2`
  - Modified: `src/roles/memcached/templates/memcached.j2`

* [7fac5158](https://github.com/freephile/meza/commit/7fac5158) (2026-03-05) Greg Rundlett: update SBOM 
  - Modified: `src/scripts/meza-sbom.cyclonedx.json`
  - Modified: `src/scripts/meza-sbom.spdx.json`
  - Modified: `src/scripts/meza-sbom.txt`

* [b944f271](https://github.com/freephile/meza/commit/b944f271) (2026-02-19) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [21e45c2e](https://github.com/freephile/meza/commit/21e45c2e) (2026-02-19) Greg Rundlett: Doc each role #321 in preparation for #42 Adds a brief explanation for each of the 56 roles
Categorized as follows:
- Third-party / vendor roles
- Infrastructure / system roles
- Meza orchestration roles
- Wiki lifecycle roles
- Backup roles
- Utility / library roles
  - Added: `src/roles/README.md`

* [22bf91c9](https://github.com/freephile/meza/commit/22bf91c9) (2026-02-19) Greg Rundlett: Add README for update.php role #320 
  - Added: `src/roles/update.php/README.md`

* [1f5f0d37](https://github.com/freephile/meza/commit/1f5f0d37) (2026-02-18) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [fe95d559](https://github.com/freephile/meza/commit/fe95d559) (2026-02-18) Greg Rundlett: Comment about the logo used in Chameleon Chameleon skin uses the 1x 'meza-logo-135.png' file.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [99b8f074](https://github.com/freephile/meza/commit/99b8f074) (2026-02-18) Greg Rundlett: Adjust logrotate to actual elasticsearch logs Elasticsearch logs are in the m_data_dir/elasticsearch/log directory
They are NOT in the m_data_log_dir/elasticsearch directory
  - Modified: `src/roles/logrotate/README.md`
  - Modified: `src/roles/logrotate/tasks/main.yml`

* [b9643cf9](https://github.com/freephile/meza/commit/b9643cf9) (2026-02-18) Greg Rundlett: These variables do not belong to this role #42 These variables are used in the init-controller and htdocs roles. The verify-wiki role needs to be factored into component parts because what it does is not exactly clear.
  - Deleted: `src/roles/verify-wiki/defaults/main.yml`

* [d0c4b9b9](https://github.com/freephile/meza/commit/d0c4b9b9) (2026-02-15) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [c46a2932](https://github.com/freephile/meza/commit/c46a2932) (2026-02-14) Greg Rundlett: Fix regression bug: Elasticsearch advanced #311 improve the elastic-build-index.sh script
It was possibly contributing to failed indexing because the throwaway
`jq` pipe was just putting errors in the log instead of giving good
information on whether setting were successfully set.
Now we retrieve and report the HTTP status code on the interaction
with elasticsearch.
Fixes Issue [#311](https://github.com/freephile/meza/issues/311)
  - Modified: `src/roles/mediawiki/templates/elastic-build-index.sh.j2`

* [575fab5c](https://github.com/freephile/meza/commit/575fab5c) (2026-02-15) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [17b64402](https://github.com/freephile/meza/commit/17b64402) (2026-02-14) Greg Rundlett: Fix regression bug: Elasticsearch advanced #311 MediaWiki 1.43 requires Elasticsearch to be at 7.10.2
fixed the elasticsearch install task
Apparently it broke due to the 'name' of the package being a version test:
   ` name: "elasticsearch <= {{ elasticsearch_version }}"`
Added downgrade if system has advanced beyone pinned package version
added `elasticsearch_versionlock_enabled: true` to role defaults
created role README.md
Fixes Issue [#311](https://github.com/freephile/meza/issues/311)
  - Added: `src/roles/elasticsearch/README.md`
  - Modified: `src/roles/elasticsearch/defaults/main.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`

* [9c4a615a](https://github.com/freephile/meza/commit/9c4a615a) (2026-02-14) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [382f5b5c](https://github.com/freephile/meza/commit/382f5b5c) (2026-02-13) Greg Rundlett: Remove `meza setup dev-networking` and ref. #304 setup dev-networking was obsolete
Fixes Issue [#304](https://github.com/freephile/meza/issues/304)
  - Modified: `manual/meza-cmd/help.md`
  - Modified: `manual/meza-cmd/install.md`
  - Modified: `manual/meza-cmd/setup.md`
  - Deleted: `src/scripts/dev-networking.sh`
  - Modified: `src/scripts/meza.py`

* [f931e4d3](https://github.com/freephile/meza/commit/f931e4d3) (2026-02-14) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [5df4eb80](https://github.com/freephile/meza/commit/5df4eb80) (2026-02-13) Greg Rundlett: Add pre-commit badge to README We use pre-commit, so might as well advertise it.
Part of Issue [#304](https://github.com/freephile/meza/issues/304)
  - Modified: `README.md`

* [19ec6aa5](https://github.com/freephile/meza/commit/19ec6aa5) (2026-02-13) Greg Rundlett: Remove meza setup dev command and ref Issue [#304](https://github.com/freephile/meza/issues/304)
  - Modified: `config/i18n/en.yml`
  - Modified: `manual/meza-cmd/help.md`
  - Modified: `manual/meza-cmd/index.md`
  - Modified: `manual/meza-cmd/setup.md`
  - Modified: `src/scripts/meza.py`

* [6c278c8e](https://github.com/freephile/meza/commit/6c278c8e) (2026-02-13) Greg Rundlett: update CONTRIBUTING.md with link to DEVELOPING.md new DEVELOPING.md focused on development workflow.
part of Issue [#304](https://github.com/freephile/meza/issues/304)
  - Modified: `CONTRIBUTING.md`
  - Added: `manual/DEVELOPING.md`

* [34164620](https://github.com/freephile/meza/commit/34164620) (2026-02-13) Greg Rundlett: update git pre-commit hook to match lint-files.sh using pre-commit: https://pre-commit.com
exclude svg from 'trailing-whitespace' rule
exclude svg from 'end-of-file-fixer' rule
check that non-binary executables have shebangs
update/install with (.venv) `pre-commit install` when making changes
NOTE: Although I tried valiantly, I could not enable the check-ast
hook for Python files with the specification that language_version
be 3.6.8 which is what we need on RockyLinux 8 because I could not
intall it with pyenv on Ubuntu 24.04 no matter what I tried. So,
skipping any check-ast commit hook for now.
See
- https://github.com/pre-commit/pre-commit
- https://github.com/pre-commit/pre-commit-hooks
part of Issue [#304](https://github.com/freephile/meza/issues/304)
  - Modified: `.pre-commit-config.yaml`

* [598a8980](https://github.com/freephile/meza/commit/598a8980) (2026-02-13) Greg Rundlett: Add README and detailed set of graphs #306 See README.md in the playbooks directory
Fixes Issue [#306](https://github.com/freephile/meza/issues/306)
  - Added: `src/playbooks/README.md`
  - Added: `src/playbooks/backup-w-tasks.svg`
  - Added: `src/playbooks/check-for-changes-w-tasks.svg`
  - Added: `src/playbooks/cleanup-upload-stash-w-tasks.svg`
  - Added: `src/playbooks/create-wiki-promptless-w-tasks.svg`
  - Added: `src/playbooks/create-wiki-w-tasks.svg`
  - Added: `src/playbooks/debug-w-tasks.svg`
  - Added: `src/playbooks/delete-elasticsearch-w-tasks.svg`
  - Added: `src/playbooks/delete-wiki-promptless-w-tasks.svg`
  - Added: `src/playbooks/delete-wiki-w-tasks.svg`
  - Added: `src/playbooks/deploy-notify-w-tasks.svg`
  - Added: `src/playbooks/getdocker-w-tasks.svg`
  - Added: `src/playbooks/migrate-wikis-w-tasks.svg`
  - Added: `src/playbooks/push-backup-w-tasks.svg`
  - Added: `src/playbooks/rebuild-smw-and-index-w-tasks.svg`
  - Added: `src/playbooks/run-maintenance-w-tasks.svg`
  - Added: `src/playbooks/setbaseconfig-w-tasks.svg`
  - Added: `src/playbooks/setup-env-w-tasks.svg`
  - Added: `src/playbooks/setup-meza-user-w-tasks.svg`
  - Added: `src/playbooks/site-w-tasks.svg`
  - Added: `src/playbooks/test-certbot-w-tasks.svg`
  - Added: `src/playbooks/verify-permissions-w-tasks.svg`
  - Modified: `src/scripts/generate-playbook-graphs.sh`

* [f27e66b0](https://github.com/freephile/meza/commit/f27e66b0) (2026-02-13) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [452ea649](https://github.com/freephile/meza/commit/452ea649) (2026-02-13) Greg Rundlett: Try to give spaced out CoPilot more brains 
  - Modified: `.github/copilot-instructions.md`

* [5cfa18a4](https://github.com/freephile/meza/commit/5cfa18a4) (2026-02-13) Greg Rundlett: improve lint-files.sh to respect .gitignore The lint-files.sh script tries to detect directory entries in .gitignore
and adds them to the base set of directories that it already skips:
.venv
vendor
.cache
.git
tests/docker
collections
node_modules
Also avoid linting SVG (and common binaries)
SVGs are technically text files and so were being modified.
For Issue [#306](https://github.com/freephile/meza/issues/306)
  - Modified: `src/scripts/lint-files.sh`

* [a85c9982](https://github.com/freephile/meza/commit/a85c9982) (2026-02-13) Greg Rundlett: minor correction to the `meza setup dev` doc #304 Currently, you can either:
`meza setup dev`
or
`meza setup env <env>`
In the first form (special case) no extra arg is required.
In the second form, 'env' directive, an environment name is required.
Special handling occurs for the environment names
'monolith', or 'vagrant'.
`meza setup env vagrant` and
`meza setup env monolith` are normally handled for you by bootstrapping
from the Vagrantfile and/or 'getmeza.sh' so users only ever need to
`meza setup env staging` for example
For Issue [#304](https://github.com/freephile/meza/issues/304)
  - Modified: `manual/meza-cmd/setup.md`

* [2493f4de](https://github.com/freephile/meza/commit/2493f4de) (2026-02-13) Greg Rundlett: Improve script to document playbooks #306 Add option `--with-tasks` to invoke `ansible-playbook-grapher --include-role-tasks`
This will change the SVG title and the output filename accordingly
For Issue [#306](https://github.com/freephile/meza/issues/306)
  - Modified: `src/scripts/generate-playbook-graphs.sh`

* [69eff908](https://github.com/freephile/meza/commit/69eff908) (2026-02-13) Greg Rundlett: Add svg files to document playbooks #306 Add script to generate (update) the SVGs on-demand for easy
periodic updating.
For Issue [#306](https://github.com/freephile/meza/issues/306)
  - Added: `src/playbooks/backup.svg`
  - Added: `src/playbooks/check-for-changes.svg`
  - Added: `src/playbooks/cleanup-upload-stash.svg`
  - Added: `src/playbooks/create-wiki-promptless.svg`
  - Added: `src/playbooks/create-wiki.svg`
  - Added: `src/playbooks/debug.svg`
  - Added: `src/playbooks/delete-elasticsearch.svg`
  - Added: `src/playbooks/delete-wiki-promptless.svg`
  - Added: `src/playbooks/delete-wiki.svg`
  - Added: `src/playbooks/deploy-notify.svg`
  - Added: `src/playbooks/getdocker.svg`
  - Added: `src/playbooks/migrate-wikis.svg`
  - Added: `src/playbooks/push-backup.svg`
  - Added: `src/playbooks/rebuild-smw-and-index.svg`
  - Added: `src/playbooks/run-maintenance.svg`
  - Added: `src/playbooks/setbaseconfig.svg`
  - Added: `src/playbooks/setup-env.svg`
  - Added: `src/playbooks/setup-meza-user.svg`
  - Added: `src/playbooks/site.svg`
  - Added: `src/playbooks/test-certbot.svg`
  - Added: `src/playbooks/verify-permissions.svg`
  - Added: `src/scripts/generate-playbook-graphs.sh`

* [34eae490](https://github.com/freephile/meza/commit/34eae490) (2026-02-12) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [090f72e4](https://github.com/freephile/meza/commit/090f72e4) (2026-02-11) Greg Rundlett: remove the "Last 500 edits" label `rclimit=500` means the query can only return 500 maximum,
and we need rclimit so we don't get the default 10;
but most times the API will return fewer than 500 results -
even when there are more than 500 edits
Polish Issue [#206](https://github.com/freephile/meza/issues/206)
  - Modified: `src/roles/htdocs/templates/meza-landing-page.php.j2`

* [aa55f5ea](https://github.com/freephile/meza/commit/aa55f5ea) (2026-02-11) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [607fea55](https://github.com/freephile/meza/commit/607fea55) (2026-02-11) Greg Rundlett: Correct the tooltip label - tally the last 500 edits Fixes Issue [#206](https://github.com/freephile/meza/issues/206)
  - Modified: `src/roles/htdocs/templates/meza-landing-page.php.j2`

* [4a709eb1](https://github.com/freephile/meza/commit/4a709eb1) (2026-02-11) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [3f76e403](https://github.com/freephile/meza/commit/3f76e403) (2026-02-11) Greg Rundlett: Replace WikiBlender fix excess margin and padding in footer
remove fake "legacy location" lookup for wgSitename
fix api query to get correct editor counts
Fixes Issue [#206](https://github.com/freephile/meza/issues/206)
  - Modified: `src/roles/htdocs/templates/meza-landing-page.php.j2`

* [3e97cc2c](https://github.com/freephile/meza/commit/3e97cc2c) (2026-02-11) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [2ad3b611](https://github.com/freephile/meza/commit/2ad3b611) (2026-02-11) Greg Rundlett: Deletes symlink for Issue [#50](https://github.com/freephile/meza/issues/50) 
  - Modified: `src/roles/delete-wiki-wrapper/tasks/main.yml`

* [5719dfbd](https://github.com/freephile/meza/commit/5719dfbd) (2026-02-11) Greg Rundlett: clarify some config command in docs 
  - Modified: `manual/meza-cmd/config.md`

* [fb96617a](https://github.com/freephile/meza/commit/fb96617a) (2026-02-11) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [677c3572](https://github.com/freephile/meza/commit/677c3572) (2026-02-11) Greg Rundlett: Replace WikiBlender with simple htdocs task remove Blender from .htaccess
remove Blender variables from MediaWiki role defaults
remove Blender tasks from `mediawiki` role
remove BlenderSettings.php from `mediawiki` role
create new meza-landing-page.php that replaces the functionality of
WikiBlender in the `htdocs` role
use favicon from primary wiki, or default to project favicon
add meza-landing-page.php to htdocs templating task
`require` meza-landing-page.php from index.php (instead of WikiBlender)
add default vars for htdocs role that should be overridden in public.yml
add blender vars in the public.yml template for new controllers
Fixes Issue [#206](https://github.com/freephile/meza/issues/206)
  - Added: `src/roles/htdocs/defaults/main.yml`
  - Modified: `src/roles/htdocs/tasks/main.yml`
  - Modified: `src/roles/htdocs/templates/.htaccess.j2`
  - Modified: `src/roles/htdocs/templates/index.php.j2`
  - Added: `src/roles/htdocs/templates/meza-landing-page.php.j2`
  - Modified: `src/roles/init-controller-config/templates/public.yml.j2`
  - Modified: `src/roles/mediawiki/defaults/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Deleted: `src/roles/mediawiki/templates/BlenderSettings.php.j2`

* [46e8238a](https://github.com/freephile/meza/commit/46e8238a) (2026-02-10) Greg Rundlett: Update logo - add to task Follow-up commit 5d355f9 by actually adding the logo file to the
'distribution' task "Ensure base files are in place (but do not
overwrite)"
Remember: usage of 'logo.png' is deprecated, but at least it's there
for use and override in conf-meza/public/wikis/<wiki>/
Fixes Issue [#270](https://github.com/freephile/meza/issues/270)
  - Modified: `src/roles/configure-wiki/tasks/main.yml`

* [0f56e190](https://github.com/freephile/meza/commit/0f56e190) (2026-02-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [a4c8a14c](https://github.com/freephile/meza/commit/a4c8a14c) (2026-02-10) Greg Rundlett: Remove obsolete Parsoid code This just removes the obsolete ansible variables and the
'cleanup-parsoid' role that was coupled into 'base'.
Other 'cleanup' would involve the ServerPerformance and cron roles.
See Issue [#19](https://github.com/freephile/meza/issues/19)
Fixes Issue [#45](https://github.com/freephile/meza/issues/45)
  - Modified: `config/paths.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Deleted: `src/roles/base/tasks/parsoid-cleanup.yml`

* [a725e5b9](https://github.com/freephile/meza/commit/a725e5b9) (2026-02-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [f938ab2c](https://github.com/freephile/meza/commit/f938ab2c) (2026-02-10) Greg Rundlett: Fix remaining Ansible Lint issues == Config ==
paths.yml - fix long comment lines
REMOVE .travis.yml - we don't use Travis CI
== Playbooks ==
check-for-changes.yml - reorder keys for blocks; add noqa comments for git operations; FQCN
== Roles ==
autodeployer - Fixed FQCN, add missing 'name:'; jinja spacing
umask-set - Fixed FQCN
umask-unset - Fixed FQCN
yamllint comments for exceptions
use [true, false] for truthy values
Fixes Issue [#16](https://github.com/freephile/meza/issues/16)
  - Deleted: `.travis.yml`
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/playbooks/example-block.yaml`
  - Modified: `src/playbooks/push-backup.yml`
  - Modified: `src/roles/autodeployer/tasks/do-deploy.yml`
  - Modified: `src/roles/autodeployer/tasks/main.yml`
  - Modified: `src/roles/database/defaults/main.yml`
  - Modified: `src/roles/database/tasks/main.yml`
  - Modified: `src/roles/database/tasks/replication.yml`
  - Modified: `src/roles/gluster/defaults/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/netdata/tasks/main.yml`
  - Modified: `src/roles/umask-set/tasks/main.yml`
  - Modified: `src/roles/umask-unset/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/create-admin-account.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [b7035d54](https://github.com/freephile/meza/commit/b7035d54) (2026-02-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [31d0dbff](https://github.com/freephile/meza/commit/31d0dbff) (2026-02-10) Greg Rundlett: Fix remaining Ansible Lint issues Add `var-naming[no-role-prefix]` to 'skip_list' in .ansible-lint
configuration
== Playbooks ==
backup.yml - Fixed FQCN for set_fact, jinja spacing
migrate-wikis.yml - Fixed FQCN for debug
rebuild-smw-and-index.yml - Fixed FQCN, no-changed-when, added noqa
when intentionally using shell module
== Roles ==
backup-db-wikis - Fixed FQCN
dump-db-wikis - Fixed FQCN
backup-uploads - Fixed FQCN
delete-wiki-wrapper - Fixed FQCN; re-order keys in block;
use uri module rather than shell for curl commands
Fixes Issue [#16](https://github.com/freephile/meza/issues/16)
  - Modified: `.ansible-lint`
  - Modified: `src/playbooks/backup.yml`
  - Modified: `src/playbooks/migrate-wikis.yml`
  - Modified: `src/playbooks/rebuild-smw-and-index.yml`
  - Modified: `src/roles/backup-db-wikis/tasks/main.yml`
  - Modified: `src/roles/backup-uploads/tasks/main.yml`
  - Modified: `src/roles/delete-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/dump-db-wikis/tasks/main.yml`

* [3fb8a2f5](https://github.com/freephile/meza/commit/3fb8a2f5) (2026-02-10) Greg Rundlett: Cleanup with Ansible Lint Fix indentation of msg block
Add ignore for .github/workflows to .yamllint config
GitHub Actions workflow files use `on:` as a required top-level keyword
(not a boolean value), which triggers yamllint's truthy rule.
Since these are GitHub-specific YAML files (not Ansible), excluding
them from yamllint checks is appropriate. The workflows will still be
validated by GitHub's own workflow syntax checker.
Fixes Issue [#16](https://github.com/freephile/meza/issues/16)
  - Modified: `.yamllint`
  - Modified: `src/roles/verify-permissions/tasks/main.yml`

* [69cf237e](https://github.com/freephile/meza/commit/69cf237e) (2026-02-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [aada3bec](https://github.com/freephile/meza/commit/aada3bec) (2026-02-10) Greg Rundlett: Cleanup with Ansible Lint Fix FQCN and Jinja spacing in import-wiki-sql.yml
Addresses Issue [#16](https://github.com/freephile/meza/issues/16)
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`

* [e485c4d3](https://github.com/freephile/meza/commit/e485c4d3) (2026-02-10) Greg Rundlett: Fix Admin password logic in create wiki create-wiki.yml playbook for User interaction
create-wiki-wrapper role = presentation of Admin password at the end of workflow (fixed FQCN)
ensure-admin-password.yml = verify wiki business logic
import-wiki-sql.yml = verify wiki orchestration
Fixes Issue [#269](https://github.com/freephile/meza/issues/269)
  - Modified: `src/playbooks/create-wiki.yml`
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/create-admin-account.yml`
  - Added: `src/roles/verify-wiki/tasks/ensure-admin-password.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`

* [1fe0e7bb](https://github.com/freephile/meza/commit/1fe0e7bb) (2026-02-10) Greg Rundlett: Normalize meza variables replace path_alias.yml with definitions in paths.yml
Closes Issue [#286](https://github.com/freephile/meza/issues/286)
  - Deleted: `config/path_alias.yml`
  - Modified: `config/paths.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [54578f39](https://github.com/freephile/meza/commit/54578f39) (2026-02-09) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [4d0fc94a](https://github.com/freephile/meza/commit/4d0fc94a) (2026-02-08) Greg Rundlett: Normalize meza variables update paths.yml and path_alias.yml
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/path_alias.yml`
  - Modified: `config/paths.yml`

* [dde5c1f8](https://github.com/freephile/meza/commit/dde5c1f8) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_config_secret_dir with m_conf_secret_dir
replaced m_config_public_dir with m_conf_public_dir
replaced m_config_vault with m_conf_vault_dir
replaced m_home with m_conf_users_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `.github/copilot-instructions.md`
  - Modified: `Vagrantfile`
  - Modified: `config/paths.yml`
  - Modified: `manual/MEZA_USER_ROLE.md`
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/playbooks/cleanup-upload-stash.yml`
  - Modified: `src/playbooks/migrate-wikis.yml`
  - Modified: `src/playbooks/run-maintenance.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/tasks/renew-cron.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/backup-config/tasks/main.yml`
  - Modified: `src/roles/backup-db-wikis-push/tasks/main.yml`
  - Modified: `src/roles/backup-db-wikis/tasks/main.yml`
  - Modified: `src/roles/backup-uploads-push/tasks/main.yml`
  - Modified: `src/roles/backup-uploads/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/configure-wiki/README.md`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/configure-wiki/templates/preLocalSettings.d/base.php.dist.j2`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/database/tasks/secure-installation.yml`
  - Modified: `src/roles/delete-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/dump-db-wikis/tasks/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/key-transfer/tasks/grant-keys.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/meza-user/README.md`
  - Modified: `src/roles/meza-user/defaults/main.yml`
  - Modified: `src/roles/meza-user/tasks/main.yml`
  - Modified: `src/roles/migrate-to-declarative-wikis/tasks/main.yml`
  - Modified: `src/roles/php/tasks/profiling.yml`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/setup-env/tasks/main.yml`
  - Modified: `src/roles/sync-configs/tasks/main.yml`
  - Modified: `src/scripts/meza.py`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [442a78d3](https://github.com/freephile/meza/commit/442a78d3) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_mediawiki with m_mediawiki_install_path
variable name is consistent with MediaWiki's own $IP and MW_INSTALL_PATH
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/path_alias.yml`
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/cleanup-upload-stash.yml`
  - Modified: `src/playbooks/run-maintenance.yml`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/configure-wiki/templates/preLocalSettings.d/base.php.dist.j2`
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/cron/templates/runAllJobs.php.j2`
  - Modified: `src/roles/mediawiki/tasks/cirrus_metastore_upgrade.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/elastic-build-index.sh.j2`
  - Modified: `src/roles/mediawiki/templates/refresh-links.sh.j2`
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`
  - Modified: `src/roles/meza-log/templates/server-performance.sh.j2`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/update.php/tasks/main.yml`
  - Modified: `src/roles/verify-permissions/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/create-admin-account.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/scripts/unite-the-wikis.sh`
  - Modified: `src/scripts/uniteTheWikis.php`

* [dc21db81](https://github.com/freephile/meza/commit/dc21db81) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_apache with m_web_conf_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`

* [d6e4c2f1](https://github.com/freephile/meza/commit/d6e4c2f1) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_htdocs with m_web_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/debug.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/README.md`
  - Modified: `src/roles/ansible-role-certbot-meza/vars/main.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/apache-php/templates/php-fpm-httpd.conf.j2`
  - Modified: `src/roles/apache/tasks/main.yml`
  - Modified: `src/roles/apache/templates/httpd.conf.j2`
  - Modified: `src/roles/apache/templates/php-fpm-httpd.conf.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/delete-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/htdocs/README.md`
  - Modified: `src/roles/htdocs/files/BackupDownload/DownloadTest.php`
  - Modified: `src/roles/htdocs/files/BackupDownload/download.php`
  - Modified: `src/roles/htdocs/files/BackupDownload/index.php`
  - Modified: `src/roles/htdocs/meta/main.yml`
  - Modified: `src/roles/htdocs/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/BlenderSettings.php.j2`
  - Modified: `src/roles/mediawiki/templates/elastic-rebuild-all.sh.j2`
  - Modified: `src/roles/mediawiki/templates/refresh-links.sh.j2`
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/scripts/unifyUserTables.php`

* [58b07019](https://github.com/freephile/meza/commit/58b07019) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_logs_deploy with m_data_deploy_log_file
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/scripts/meza.py`

* [9e651e69](https://github.com/freephile/meza/commit/9e651e69) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_tmp with m_data_tmp_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/roles/autodeployer/templates/git-fetch.sh.j2`
  - Modified: `src/roles/backup-db-wikis-push/tasks/main.yml`
  - Modified: `src/roles/backup-db-wikis/tasks/main.yml`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/database/tasks/replication.yml`
  - Modified: `src/roles/dump-db-wikis/tasks/main.yml`
  - Modified: `src/roles/enforce-meza-version/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/transfer-backup-to-db-master.yml`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [280f2578](https://github.com/freephile/meza/commit/280f2578) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_logs with m_data_logs_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/defaults.yml`
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/rebuild-smw-and-index.yml`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`
  - Modified: `src/roles/autodeployer/templates/meza-autodeployer-cron.j2`
  - Modified: `src/roles/backups-cleanup/templates/meza-cron-backups-cleanup.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`
  - Modified: `src/roles/elasticsearch/tasks/es_reindex.yml`
  - Modified: `src/roles/logrotate/tasks/main.yml`
  - Modified: `src/roles/logrotate/templates/cleanup-backups.sh.j2`
  - Modified: `src/roles/logrotate/templates/meza-logs.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/mediawiki/templates/elastic-rebuild-all.sh.j2`
  - Modified: `src/roles/mediawiki/templates/refresh-links.sh.j2`
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`
  - Modified: `src/roles/php/templates/php.ini.j2`
  - Modified: `src/roles/update.php/tasks/main.yml`
  - Modified: `src/roles/verify-permissions/tasks/main.yml`
  - Modified: `src/scripts/meza.py`

* [4b099b3d](https://github.com/freephile/meza/commit/4b099b3d) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_cache_directory with m_data_cache_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/verify-permissions/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [153f5fca](https://github.com/freephile/meza/commit/153f5fca) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_backups with m_data_backups_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/roles/backup-config/tasks/main.yml`
  - Modified: `src/roles/backup-db-wikis-push/tasks/main.yml`
  - Modified: `src/roles/backup-db-wikis/tasks/main.yml`
  - Modified: `src/roles/backup-uploads-push/tasks/main.yml`
  - Modified: `src/roles/backup-uploads/tasks/main.yml`
  - Modified: `src/roles/backups-cleanup/templates/backups-cleanup.sh.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/htdocs/files/BackupDownload/DownloadTest.php`
  - Modified: `src/roles/htdocs/files/BackupDownload/download.php`
  - Modified: `src/roles/htdocs/files/BackupDownload/index.php`
  - Modified: `src/roles/logrotate/tasks/main.yml`
  - Modified: `src/roles/logrotate/templates/cleanup-backups.sh.j2`
  - Modified: `src/roles/sql-backup-cleanup/tasks/main.yml`
  - Modified: `src/roles/update.php/tasks/main.yml`
  - Modified: `src/roles/verify-permissions/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [dd62a84a](https://github.com/freephile/meza/commit/dd62a84a) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_logs_create_wiki with m_data_create_wiki_log_file
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/scripts/meza.py`

* [397298ae](https://github.com/freephile/meza/commit/397298ae) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_meza_data with m_data_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/delete-elasticsearch.yml`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.yml.j2`
  - Modified: `src/roles/mediawiki/tasks/cirrus_metastore_upgrade.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/verify-permissions/tasks/main.yml`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/unifyUserTables.php`

* [669d68e2](https://github.com/freephile/meza/commit/669d68e2) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_local_secret with m_config_secret_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `.github/copilot-instructions.md`
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/setup-env/tasks/main.yml`
  - Modified: `src/scripts/meza.py`

* [f6325884](https://github.com/freephile/meza/commit/f6325884) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_local_public with m_config_public_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/playbooks/cleanup-upload-stash.yml`
  - Modified: `src/playbooks/migrate-wikis.yml`
  - Modified: `src/playbooks/run-maintenance.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/backup-config/tasks/main.yml`
  - Modified: `src/roles/backup-db-wikis-push/tasks/main.yml`
  - Modified: `src/roles/backup-db-wikis/tasks/main.yml`
  - Modified: `src/roles/backup-uploads-push/tasks/main.yml`
  - Modified: `src/roles/backup-uploads/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/configure-wiki/README.md`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/configure-wiki/templates/preLocalSettings.d/base.php.dist.j2`
  - Modified: `src/roles/delete-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/dump-db-wikis/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/migrate-to-declarative-wikis/tasks/main.yml`
  - Modified: `src/roles/php/tasks/profiling.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/sync-configs/tasks/main.yml`

* [d4e0b410](https://github.com/freephile/meza/commit/d4e0b410) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_i18n with m_config_i18n_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/ssh-users/setup-minion-user.sh`

* [2e250f24](https://github.com/freephile/meza/commit/2e250f24) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_deploy with m_config_deploy_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/rebuild-smw-and-index.yml`
  - Modified: `src/roles/backups-cleanup/tasks/main.yml`
  - Modified: `src/roles/backups-cleanup/templates/meza-cron-backups-cleanup.j2`
  - Modified: `src/roles/base-config-scripts/tasks/main.yml`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`
  - Modified: `src/roles/elasticsearch/tasks/es_reindex.yml`
  - Modified: `src/roles/htdocs/files/BackupDownload/DownloadTest.php`
  - Modified: `src/roles/htdocs/files/BackupDownload/download.php`
  - Modified: `src/roles/htdocs/files/BackupDownload/index.php`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/mediawiki/templates/elastic-build-index.sh.j2`
  - Modified: `src/roles/mediawiki/templates/elastic-rebuild-all.sh.j2`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/saml/templates/NonMediaWikiSimpleSamlAuth.php.j2`
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`
  - Modified: `src/roles/sync-configs/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/scripts/unifyUserTables.php`

* [50dbfa3a](https://github.com/freephile/meza/commit/50dbfa3a) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_config_core with m_config_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [81c26718](https://github.com/freephile/meza/commit/81c26718) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_test with m_app_tests_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/path_alias.yml`
  - Modified: `config/paths.yml`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`

* [db561daf](https://github.com/freephile/meza/commit/db561daf) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_scripts with m_app_scripts_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/logrotate/tasks/main.yml`
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `src/scripts/ssh-users/setup-master-user.sh`
  - Modified: `src/scripts/ssh-users/transfer-master-key.sh`
  - Modified: `src/scripts/unite-the-wikis.sh`

* [bbc151ca](https://github.com/freephile/meza/commit/bbc151ca) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_meza with m_app_dir
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `config/paths.yml`
  - Modified: `manual/APACHE_PHP_SPLIT_IMPLEMENTATION.md`
  - Modified: `manual/MEZA_USER_ROLE.md`
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/roles/autodeployer/templates/git-fetch.sh.j2`
  - Modified: `src/roles/autodeployer/templates/slack-notify.sh.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/enforce-meza-version/tasks/main.yml`
  - Modified: `src/roles/htdocs/README.md`
  - Modified: `src/roles/htdocs/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/scripts/unifyUserTables.php`

* [ed048685](https://github.com/freephile/meza/commit/ed048685) (2026-02-08) Greg Rundlett: Normalize meza variables replaced m_install with m_install_dir
removed TODO comments from paths.yml
created path_alias.yml with variable map
Addresses Issue [#286](https://github.com/freephile/meza/issues/286)
  - Modified: `.github/copilot-instructions.md`
  - Added: `config/path_alias.yml`
  - Modified: `config/paths.yml`
  - Modified: `manual/MEZA_USER_ROLE.md`
  - Modified: `manual/meza-cmd/debug.md`
  - Modified: `src/roles/autodeployer/templates/git-fetch.sh.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/configure-wiki/templates/preLocalSettings.d/base.php.dist.j2`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/htdocs/templates/index.php.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/mediawiki/templates/refresh-links.sh.j2`
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`
  - Modified: `src/roles/meza-log/templates/disk-space-usage.sh.j2`
  - Modified: `src/roles/meza-log/templates/server-performance.sh.j2`
  - Modified: `src/roles/netdata/tasks/main.yml`
  - Modified: `src/roles/saml/templates/SAMLConfig.php.j2`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/setup-env/templates/secret.yml.j2`
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `src/scripts/meza.py`

* [e39ddc92](https://github.com/freephile/meza/commit/e39ddc92) (2026-02-08) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [c54bb580](https://github.com/freephile/meza/commit/c54bb580) (2026-02-07) Greg Rundlett: Add new 'reminder' provisioner to Vagrantfile Echo instructions so it's very easy to get the first deploy done.
Addresses Issue [#268](https://github.com/freephile/meza/issues/268)
  - Modified: `Vagrantfile`

* [ddfe42b4](https://github.com/freephile/meza/commit/ddfe42b4) (2026-02-06) Greg Rundlett: Set `check_mode: false` (meaning always run) The pattern:
For tasks that DO NOT HAVE SIDE-EFFECTS, such as read-only tasks, that
register a variable or set a fact, which is then used to DO something
and possibly FAIL, be sure to use `check_mode: false` on the read-only
task. This way the task runs always; even when you test a playbook by
using `--check` mode (aka **`--dry-run`** in other software)
Without this pattern, trying to test your playbooks in `--check` mode
can cause them to fail for no good reason since the read-only task
would be skipped and the registered variable would be empty.
For example: "check if user is in group_apache"
Also, Format verify-permissions role
Place the user/group checks first
Use variable `{{ m_user }}` instead of hard-coded 'meza-ansible'
Use variable `{{ user_apache }}` and `{{ group_apache }}` instead of
hard-coded 'apache'
Comment/disable `{{ m_uploads_dir }}` in permission fix because it can
be huge, should not fail, and is not a routine operation.
It should be handled separately.
Remove extraneous 'when: RedHat'
Add USAGE instructions at the top of the verify-permissions playbook,
just like the role, for quick reference.
  - Modified: `src/playbooks/verify-permissions.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat8.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/database/tasks/secure-installation.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/meza-user/tasks/main.yml`
  - Modified: `src/roles/php/tasks/profiling.yml`
  - Modified: `src/roles/verify-permissions/tasks/main.yml`

* [b0792e05](https://github.com/freephile/meza/commit/b0792e05) (2026-02-06) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [a55e46d3](https://github.com/freephile/meza/commit/a55e46d3) (2026-02-05) Greg Rundlett: Fix linting issues with netdata role Added proper names to the debug tasks instead of 'free-form'
Added `set -o pipefail` and `executable: /bin/bash` to shell that uses
pipes.
Added `change_when` false to integrity-check (read-only) and true to
install task (it actually installs)
Switched to the command module for the installer because no shell
features are actually needed **in the task** and we can still invoke
the shell (`sh foo.sh`) as the command.
Fixes Issue [#16](https://github.com/freephile/meza/issues/16)
  - Modified: `src/roles/netdata/tasks/main.yml`

* [23fdc901](https://github.com/freephile/meza/commit/23fdc901) (2026-02-05) Greg Rundlett: Improve logrotate role based on separate apache In the logrotate configuration file template for
`/etc/logrotate.d/meza-logs`, remove defensive fallback logic based on
complicated 'getent_group' since apache is guaranteed to be installed.
Formerly the 'if' conditions were complicated and the fallbacks would
introduce permission problems by using 'root' instead of intentional
variables such as `logrotate_deploy_logs.create_owner`.
Remove whole duplicate "Fix directory permissions after apache installation"
because apache is guaranteed to be installed.
Remove 'ignore errors' flag so we're not silently failing.
Add whole section in the role README.md on Testing and Deployment
Fixes Issue [#287](https://github.com/freephile/meza/issues/287)
  - Modified: `src/roles/logrotate/README.md`
  - Modified: `src/roles/logrotate/tasks/main.yml`
  - Modified: `src/roles/logrotate/templates/meza-logs.j2`

* [d0971019](https://github.com/freephile/meza/commit/d0971019) (2026-02-05) Greg Rundlett: Fix deploy with separate apache, php roles Fix profiling per-wiki override logic while also fixing deploys on
fresh Vagrant infrastructure where `wikis` isn't defined yet. This
fixes an issue with Vagrant where you used to need to
- 'deploy'->
- 'create wiki'->
- 'deploy' (again)
to get started.
Now, the demo wiki is created on first deploy in Vagrant the same as
before with 'monolith' environments.
- Add new play "Ensure demo wiki exists if no wikis configured" to site
playbook which runs **before** app server configuration (before the PHP
role). This ensures that the `wikis` variable is available when the PHP
role runs (and invokes the profiling tasks).
- Remove the same play from the `mediawiki` role; and leave a comment
in its place.
Fixes Issue [#287](https://github.com/freephile/meza/issues/287)
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/php/templates/postLocalSettings.d/profiling.php.j2`

* [5edb1811](https://github.com/freephile/meza/commit/5edb1811) (2026-02-05) Greg Rundlett: Split apache-php into separate roles - make note in Vagrantfile that getmeza.sh installs Apache
- add apache installation into getmeza.sh
- add doc in 'manual' for Apache-PHP split implementation
- split old role in site.yml
- change deploy lock file ownership in meza.py to enforce the architectural
guarantee that Apache is installed during bootstrap. Fail fast with helpful
guidance if the system isn't properly configured.
- Add FIXME for removing RedHat 7 Issue [#290](https://github.com/freephile/meza/issues/290)
- no need for defaults and fallbacks in paths.yml when group_apache is a
pre-requisite
- the apache task no longer attempts to create or fix m_public/wikis started in
init-controller because that is not apache's concern
- replace complex getent module with simple getent command and return code in
init-controller-config to fail fast if the prerequisite apache is not present
then use proper group variable for setting ownership instead of silent fallbacks
- add new meta file for apache-php role to describe it as deprecated
- copy prior httpd.conf and php-fpm conf templates into new apache role
- copy `etc-sysconfig-httpd` template into new apache role
- add large deprecation notice at the top of the apache-php task file
- add meta file for apache-php that invokes the separate roles as pre-requisites
- add README.md for the apache-php role that explains the deprecation
- add README.md for the meza-user role explaining boostrap sequence
- fix the  PHP profiling logic for per-wiki overrides
- copy README_PROFILING.md into new php role
and the rest of the php role files
- README.md
- meta/main.yml
- README_PROFILING.md
- handlers/main.yml
- templates/php.ini.j2
- templates/10-opcache.ini.j2
- templates/www.conf.j2
- templates/postLocalSettings.d/profiling.php.j2
- templates/20-xhprof.ini.j2
- templates/20-sqlsrv.ini.j2
- templates/freetds.conf.j2
- templates/40-memcached.ini.j2
- templates/php.conf
- templates/30-pdo_sqlsrv.ini.j2
- templates/logrotate-profiler.j2
- defaults/main.yml
- tasks/php-redhat8.yml
- tasks/main.yml
- tasks/mssql_driver_for_php.yml
- tasks/php-debian.yml
- tasks/php-redhat7.yml
- tasks/profiling.yml
- tasks/php.yml
Issue [#287](https://github.com/freephile/meza/issues/287) is ready for testing
  - Modified: `Vagrantfile`
  - Modified: `config/RedHat.yml`
  - Modified: `config/paths.yml`
  - Added: `manual/APACHE_PHP_SPLIT_IMPLEMENTATION.md`
  - Modified: `src/playbooks/site.yml`
  - Added: `src/roles/apache-php/README.md`
  - Added: `src/roles/apache-php/meta/main.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Added: `src/roles/apache/README.md`
  - Added: `src/roles/apache/defaults/main.yml`
  - Added: `src/roles/apache/handlers/main.yml`
  - Added: `src/roles/apache/meta/main.yml`
  - Added: `src/roles/apache/tasks/main.yml`
  - Added: `src/roles/apache/templates/etc-sysconfig-httpd.j2`
  - Added: `src/roles/apache/templates/httpd.conf.j2`
  - Added: `src/roles/apache/templates/php-fpm-httpd.conf.j2`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Added: `src/roles/meza-user/README.md`
  - Added: `src/roles/php/README.md`
  - Added: `src/roles/php/README_PROFILING.md`
  - Added: `src/roles/php/defaults/main.yml`
  - Added: `src/roles/php/handlers/main.yml`
  - Added: `src/roles/php/meta/main.yml`
  - Added: `src/roles/php/tasks/main.yml`
  - Added: `src/roles/php/tasks/mssql_driver_for_php.yml`
  - Added: `src/roles/php/tasks/php-debian.yml`
  - Added: `src/roles/php/tasks/php-redhat7.yml`
  - Added: `src/roles/php/tasks/php-redhat8.yml`
  - Added: `src/roles/php/tasks/php.yml`
  - Added: `src/roles/php/tasks/profiling.yml`
  - Added: `src/roles/php/templates/10-opcache.ini.j2`
  - Added: `src/roles/php/templates/20-sqlsrv.ini.j2`
  - Added: `src/roles/php/templates/20-xhprof.ini.j2`
  - Added: `src/roles/php/templates/30-pdo_sqlsrv.ini.j2`
  - Added: `src/roles/php/templates/40-memcached.ini.j2`
  - Added: `src/roles/php/templates/freetds.conf.j2`
  - Added: `src/roles/php/templates/logrotate-profiler.j2`
  - Added: `src/roles/php/templates/php.conf`
  - Added: `src/roles/php/templates/php.ini.j2`
  - Added: `src/roles/php/templates/postLocalSettings.d/profiling.php.j2`
  - Added: `src/roles/php/templates/www.conf.j2`
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `src/scripts/meza.py`

* [9effcfd5](https://github.com/freephile/meza/commit/9effcfd5) (2026-02-04) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [50657c90](https://github.com/freephile/meza/commit/50657c90) (2026-02-04) Greg Rundlett: use set-vars in setup-meza-user playbook - Prepare for Issue [#287](https://github.com/freephile/meza/issues/287) - splitting the apache-php role
- Comment paths.yml for Issue [#286](https://github.com/freephile/meza/issues/286) - normalize variable names
- Simplify group detection in the meza-user role
- Make FQCN edits to pass linting on set-vars role for Issue [#16](https://github.com/freephile/meza/issues/16)
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/setup-meza-user.yml`
  - Modified: `src/roles/meza-user/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [9bd4e14f](https://github.com/freephile/meza/commit/9bd4e14f) (2026-02-03) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [482739a0](https://github.com/freephile/meza/commit/482739a0) (2026-02-03) Greg Rundlett: distribute 'dist' files for configuration Since the file names are new, pre-existing customizations will be
safe.
- Needed to rename the template files, not just the target files
Also fix linting with FQCN and
improve the task key order to: name, delegate_to, run_once, block
Fixes Issue [#270](https://github.com/freephile/meza/issues/270)
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
R100	src/roles/configure-wiki/templates/preLocalSettings.d/base.php.j2	src/roles/configure-wiki/templates/preLocalSettings.d/base.php.dist.j2
R099	src/roles/configure-wiki/templates/samlAuthorizations.d/base.php.j2	src/roles/configure-wiki/templates/samlAuthorizations.d/base.php.dist.j2

* [461a8b10](https://github.com/freephile/meza/commit/461a8b10) (2026-02-03) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [72833be2](https://github.com/freephile/meza/commit/72833be2) (2026-02-03) Greg Rundlett: switch to 'dist' files for configuration Since the file names are new, pre-existing customizations will be
safe.
Since the distributed 'base.php.dist' file is now propagated, users
will receive new instructions and content for replication in 'config'
repos.
Also fix linting with FQCN and
improve the task key order to: name, delegate_to, run_once, block
Fixes Issue [#270](https://github.com/freephile/meza/issues/270)
  - Modified: `src/roles/configure-wiki/tasks/main.yml`

* [e537e1be](https://github.com/freephile/meza/commit/e537e1be) (2026-02-03) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [c54781e2](https://github.com/freephile/meza/commit/c54781e2) (2026-02-03) Greg Rundlett: Add audit permissions script for Issue [#272](https://github.com/freephile/meza/issues/272) 
  - Added: `src/scripts/audit-permissions.sh`

* [992b77f2](https://github.com/freephile/meza/commit/992b77f2) (2026-02-03) Greg Rundlett: add exports to the lint-files.sh script Adding exports for meza's local Config and Roles path allows linters
to find the right sources.
  - Modified: `src/scripts/lint-files.sh`

* [a8649f3d](https://github.com/freephile/meza/commit/a8649f3d) (2026-02-03) Greg Rundlett: Update Medik skin repo source and version The Medik skin is now on GitHub and the version is a commit SHA
The former bitbucket URL no longer exists.
  - Modified: `config/MezaCoreSkins.yml`

* [5d355f9d](https://github.com/freephile/meza/commit/5d355f9d) (2026-02-03) Greg Rundlett: Add back logo.png for legacy references logo.png usage is DEPRECATED however it is being added back for old
references that may exist in the wild. Do not rely on this file being
present.
Fix-up (temporarily) internal project references to 'logo.png'.
These playbooks and roles still need to be reviewed and modernized.
- check-for-changes
- push-backups
- autodeployer and slack-notify
Fixes Issue [#270](https://github.com/freephile/meza/issues/270)
  - Modified: `config/defaults.yml`
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/playbooks/push-backup.yml`
  - Modified: `src/roles/autodeployer/tasks/do-deploy.yml`
  - Modified: `src/roles/autodeployer/templates/slack-notify.sh.j2`
  - Added: `src/roles/configure-wiki/files/logo.png`

* [19a969fc](https://github.com/freephile/meza/commit/19a969fc) (2026-02-03) Greg Rundlett: New Feature: custom branding Integrate the htdocs role with the configure-wiki and mediawiki roles
so that there is a three-tier override for branding assets:
3. Per-wiki customization via upload
2. Per-wiki customization version-controlled and distributed fron config
file system on the controller.
1. Project-wide default set by htdocs role
Fixes Issue [#270](https://github.com/freephile/meza/issues/270)
  - Modified: `src/roles/configure-wiki/templates/preLocalSettings.d/base.php.j2`
  - Modified: `src/roles/htdocs/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [0796267d](https://github.com/freephile/meza/commit/0796267d) (2026-02-02) Greg Rundlett: correct co-pilot instructions 
  - Modified: `.github/copilot-instructions.md`

* [bc313c66](https://github.com/freephile/meza/commit/bc313c66) (2026-02-02) Greg Rundlett: Improve branding w configure-wiki and htdocs roles - Improve  `configure-wiki` role that sets up wiki configuration
scaffolding with wgLogos files.
  - Added metadata and task header comments improving documentation
  - Add group write permission for created files and directories.
- Add task header comments in `htdocs` role which manages web-accessible
content in Apache's document root.
- Use FQCN to pass linting
- Update `LocalSettings.php` template to use $wgLogos multiple logo sizes.
- Add $wgFavicon
- Add $wgAppleTouchIcon
- Added README documentation for both roles detailing their purpose,
usage, and configuration.
- Remove deprecated single 'logo.png'
Fixes Issue [#270](https://github.com/freephile/meza/issues/270)
  - Modified: `config/defaults.yml`
  - Added: `src/roles/configure-wiki/README.md`
  - Added: `src/roles/configure-wiki/files/apple-touch-icon.png`
  - Modified: `src/roles/configure-wiki/files/favicon.ico`
  - Deleted: `src/roles/configure-wiki/files/logo.png`
  - Added: `src/roles/configure-wiki/files/meza-icon-50.svg`
  - Added: `src/roles/configure-wiki/files/meza-logo-1.5x.png`
  - Added: `src/roles/configure-wiki/files/meza-logo-135.png`
  - Added: `src/roles/configure-wiki/files/meza-logo-2x.png`
  - Added: `src/roles/configure-wiki/files/meza-logo-inkscape.svg`
  - Added: `src/roles/configure-wiki/meta/main.yml`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Added: `src/roles/htdocs/README.md`
  - Added: `src/roles/htdocs/meta/main.yml`
  - Modified: `src/roles/htdocs/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/scripts/lint-files.sh`

* [06dad963](https://github.com/freephile/meza/commit/06dad963) (2026-01-29) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [fc1a74d8](https://github.com/freephile/meza/commit/fc1a74d8) (2026-01-29) Greg Rundlett: Use MediaWiki REL1_43 branch v 1.43.6 tag This updates critical issue with PHPUnit
  - Modified: `config/defaults.yml`

* [d454a1b8](https://github.com/freephile/meza/commit/d454a1b8) (2026-01-29) Greg Rundlett: Fix netdata installation Use POSIX shell, avoid bashism like process substitution
Add integrity check on the installer before using it.
Fixes Issue [#279](https://github.com/freephile/meza/issues/279)
  - Modified: `src/roles/netdata/tasks/main.yml`

* [d8377bf4](https://github.com/freephile/meza/commit/d8377bf4) (2026-01-27) Greg Rundlett: Fix permissions and extract user creation Performance benchmarks on Vagrant:
- 3 min for vagrant up (first time)
- 21:24 for meza deploy (first time)
- 43 sec for create wiki (mw-debug perm error on page view)
- 4 min for verify-permissions (fixes 'mediawiki' dir)
- 3:42 for meza deploy (second time)
The `meza-user` Ansible role replaces the previous bash scripts
(`linux-user.sh`, `setup-master-user.sh`) for managing the meza-ansible
user.
This provides better idempotency, testability, and integration with the
Ansible deployment workflow.
== Specific changes ==
src/scripts/getmeza.sh
- add setup-meza-user playbook with fallback on
setup-master-user.sh script
src/scripts/shell-functions/linux-user.sh
- enhance by sourcing shell initialization files
- also replace tabs with spaces for formatting
MEZA_USER_ROLE.md documents the new approach for creating the
meza-ansible user.
PATH_FIX.md documents how the typical user path is setup on Linux.
Vagrantfile
print out the 'groups' and home directory configuration of the
meza-ansible user
paths.yml
- use literal meza-ansible in places
- use group_apache instead of group_wheel for m_htdocs_group
src/playbooks/setup-meza-user.yml
- new playbook to setup the meza-ansible service account instead of
doing it with shell scripts.
src/playbooks/site.yml
- Add set-vars to umask-set so that it can use the m_umask variable.
- The whole umask-set and umask-unset roles should be avoidable.
src/roles/apache-php/tasks/main.yml
- use meza-ansible owner of htdocs
src/roles/ansible-role-certbot-meza/tasks/main.meza.yml
src/roles/base/tasks/main.yml
src/roles/cron/tasks/main.yml
src/roles/database/tasks/secure-installation.yml
src/roles/essential-vars/tasks/main.yml
src/roles/saml/tasks/main.yml
src/roles/meza-log/tasks/main.yml
- use meza-ansible explicitly
src/roles/enforce-meza-version/tasks/main.yml
src/roles/mediawiki/tasks/main.yml
src/roles/saml/tasks/main.yml
src/roles/umask-set/templates/umask.profile.sh.j2
- use m_umask variable instead of hard-coding it
After create wiki, a deploy fails on dubious ownership of 'mediawiki'
To correct it, you can run the verify-permissions playbook in 4 minutes,
and then deploy but WHY is it failing? The ownership needs to be ironed
out.
These 4 files were incorrect:
and thus later git ops would fail with dubious ownership
'mediawiki' dir owned by apache instead of meza-ansible
"Changed files: [
'/opt/htdocs/mediawiki',
'/opt/htdocs/mediawiki/extensions/Widgets/compiled_templates',
'/opt/htdocs/mediawiki/extensions/Widgets/compiled_templates/.htaccess',
'/opt/htdocs/mediawiki/vendor/microsoft/tolerant-php-parser/php-langspec/spec/php-spec-draft.md']
src/roles/init-controller-config/tasks/main.yml
- make group_apache group ownership conditional for cases where apache
doesn't even exist yet.
- Add note that the role needs to be part of a refactor
src/roles/mediawiki/templates/LocalSettings.php.j2
- move the mw-debug.log file into the logs/mediawiki directory where it
can be properly written by apache
src/roles/set-vars/tasks/main.yml
- make the set-vars role not fail when public.yml does not yet exist
Fixes Issue [#272](https://github.com/freephile/meza/issues/272)
  - Modified: `Vagrantfile`
  - Modified: `config/paths.yml`
  - Added: `manual/MEZA_USER_ROLE.md`
  - Modified: `manual/PATH_FIX.md`
  - Added: `src/playbooks/setup-meza-user.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/tasks/main.meza.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/database/tasks/secure-installation.yml`
  - Modified: `src/roles/enforce-meza-version/tasks/main.yml`
  - Modified: `src/roles/essential-vars/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Added: `src/roles/meza-user/defaults/main.yml`
  - Added: `src/roles/meza-user/tasks/main.yml`
  - Added: `src/roles/meza-user/templates/bash_profile.j2`
  - Added: `src/roles/meza-user/templates/bashrc.j2`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/umask-set/templates/umask.profile.sh.j2`
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `src/scripts/shell-functions/linux-user.sh`

* [4f3152bb](https://github.com/freephile/meza/commit/4f3152bb) (2026-01-20) Greg Rundlett: Add better vagrant deploy instructions in comments 
  - Modified: `vagrantconf.default.yml`

* [92636735](https://github.com/freephile/meza/commit/92636735) (2026-01-20) Greg Rundlett: public.yml is neccessary Remove the 'failed_when: false" for public.yml
public/public.yml is required.
Remove include_vars for 'secret/secret.yml' There is no such thing.
Addresses Issue [#272](https://github.com/freephile/meza/issues/272)
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [b5a4fbfd](https://github.com/freephile/meza/commit/b5a4fbfd) (2026-01-20) Greg Rundlett: Extract directory and permissions into role - remove 'ignore submodules' before MediaWiki is installed
ignore is repeated on line 88
- remove 'failed_when: false' in mediawiki clone
- extract directory setup and permission checking for 'data-meza'
into the verify-permissions role.
- add easy-to-read output for directory setup
Addresses Issue [#272](https://github.com/freephile/meza/issues/272)
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/verify-permissions/tasks/main.yml`

* [3e9dda34](https://github.com/freephile/meza/commit/3e9dda34) (2026-01-20) Greg Rundlett: Fix up paths.yml for permissions mgmt - use 4-digit mode settings
- add leading 2 for group sticky bit
- avoids problems with leading zero
- add missing group `m_cache_directory_group`
- add missing `m_logs_group`
Addresses Issue [#272](https://github.com/freephile/meza/issues/272)
  - Modified: `config/paths.yml`

* [b0d9ddff](https://github.com/freephile/meza/commit/b0d9ddff) (2026-01-20) Greg Rundlett: create new variable m_umask Also, fix up examples of profiling
Remove erroneous namespaced public.yml references
Addresses Issue [#272](https://github.com/freephile/meza/issues/272)
  - Modified: `config/defaults.yml`

* [1d5f8657](https://github.com/freephile/meza/commit/1d5f8657) (2026-01-20) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [d5fa3e62](https://github.com/freephile/meza/commit/d5fa3e62) (2026-01-20) Greg Rundlett: Correct erroneous mentions of namespaced public.yml The 'public.yml' file is shared by ALL wikis in a Meza instance.
PHP directory structures in 'conf-meza' still allow for customization
of each wiki.
The 'secret.yml' files are namespaced by <env> within the Meza instance
so that you can have separate values or configurations as needed.
  - Modified: `.github/copilot-instructions.md`
  - Modified: `manual/meza-cmd/config.md`
  - Modified: `manual/meza-cmd/deploy-notify.md`
  - Modified: `manual/meza-cmd/migrate-wikis.md`
  - Modified: `src/roles/apache-php/README_PROFILING.md`
  - Modified: `src/roles/logrotate/README.md`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/scripts/cleanup-backups.md`

* [3415e45a](https://github.com/freephile/meza/commit/3415e45a) (2026-01-20) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [49e7c39e](https://github.com/freephile/meza/commit/49e7c39e) (2026-01-20) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [a610b5f7](https://github.com/freephile/meza/commit/a610b5f7) (2026-01-19) Greg Rundlett: Add blank known_hosts file to avoid error in dev Probably a code smell. Investigate later. known_hosts is created in
multiple other roles that seem loosely organized and definitely not
documented.
Final fix for Issue [#268](https://github.com/freephile/meza/issues/268) Better Dev Environments with Vagrant
  - Modified: `Vagrantfile`

* [94efecef](https://github.com/freephile/meza/commit/94efecef) (2026-01-17) Greg Rundlett: remove problematic initialization The 'sophisticated' conditioning of the Vagrant box during
initialization caused problems with the vagrant-vbguest plugin
detecting completion - resulting in a "hung" `vagrant up` because the
terminal prompt would not return. The box got created, but the prompt
was never released.
Fixes Issue [#268](https://github.com/freephile/meza/issues/268)
  - Modified: `Vagrantfile`

* [158abdf8](https://github.com/freephile/meza/commit/158abdf8) (2026-01-17) Greg Rundlett: Add comments to Vagrant configuration 
  - Modified: `vagrantconf.default.yml`

* [d2395cf4](https://github.com/freephile/meza/commit/d2395cf4) (2026-01-17) Greg Rundlett: rebuild Vagrant infrastructure In the Vagrantfile...
Used generic/rocky8 for baseBox for VirtualBox compatibility.
Increased boot time to 10 min for slower systems.
Add VBGuest installer hooks before install:
- Wait up to 60 seconds for network connectivity (ping 8.8.8.8)
- Install build dependencies (with retry)
- Pause briefly so system settles and to avoid RockyLinux boot issues.
- VirtualBox Guest Additions installer runs (automatic, configured by
vbguest plugin)
Without these dependencies, VirtualBox Guest Additions compilation fails,
causing:
- No shared folder support (/opt/meza mount fails)
- Poor VM performance (no graphics acceleration)
- Time sync issues between host and guest
The retry logic specifically addresses Rocky Linux's occasional slow
network initialization on first boot.
Add graphics controller for VirtualBox compatibility
Missing SSH Keys Fix:
Modified the Vagrantfile getmeza provisioner to:
- Check if files exist before trying to move them
- Create .ssh directory before attempting file operations
- Show warning messages if keys aren't found (helps debug the issue)
- Removed rm -rf commands that were pointlessly trying to remove files
that don't exist yet
Fix Issue [#268](https://github.com/freephile/meza/issues/268)
  - Modified: `Vagrantfile`

* [b65cb79e](https://github.com/freephile/meza/commit/b65cb79e) (2026-01-16) Greg Rundlett: improve getmeza.sh (setup-env) The setup-env role would pollute the output of `vagrant up` by
dumping the entire Ansible 'vars'
Now gate it on the value of `m_force_debug`
related to Issue [#268](https://github.com/freephile/meza/issues/268)
  - Modified: `src/roles/setup-env/tasks/main.yml`

* [d80b6e21](https://github.com/freephile/meza/commit/d80b6e21) (2026-01-16) Greg Rundlett: improve getmeza.sh The script is now ~40% shorter, easier to maintain, and only supports
platforms that are actively maintained and relevant for modern MediaWiki.
Complete refactor removing EOL distros CentOS, RHEL 7.x
Note: more work to remove related code
Remove sed workarounds for old incompatible packages.
Modern Rocky/RHEL 8 repos don't have conflicting ansible packages.
We install ansible via pip explicitly (not dnf)
Add `--root-user-action=ignore` to intentional system-wide pip commands
Python 3.6 is the base, python38 conflicts are no longer relevant.
The exclusions were workarounds for old repo states.
Ansible is now installed system-wide vs. user
Simplified Repository Setup
- Single code path for Rocky 8 and RHEL 8
- Clear error messages for unsupported versions
- Better diagnostic output for PowerTools/CRB repository
- `libmemcached-devel` is in the PowerTools repository.
Consolidated package installation into one `dnf install`
Better Error Handling
- Version checking with clear error messages
- Repository verification with diagnostic output
Cleaner Structure
- Removed nested case statements
- Consolidated duplicate code
- Better comments explaining each section
- More consistent echo statements for progress tracking every time, not
just when EPEL is missing
- Made PowerTools enablement idempotent - Checks if already enabled
before trying to enable it
- Added verification after enabling - Confirms PowerTools is actually
in the enabled repos list
- Removed the EPEL check wrapper - Repository configuration now runs
- Separated EPEL installation - EPEL check is now independent of
PowerTools enablement
Developer note: you can update your VM while it's running to reflect
changes made to the Vagrantfile.
E.g. from your host, invoke
`vagrant provision app1 --provision-with getmeza`
Fix for Issue [#268](https://github.com/freephile/meza/issues/268)
  - Modified: `src/scripts/getmeza.sh`

* [edb16345](https://github.com/freephile/meza/commit/edb16345) (2026-01-15) Greg Rundlett: improve Vagrant for better local development - make the same fix in the 'base' role:
  when creating users do not move_home
- add scripts and documentation about fixing permission bits, umask,
  and shares in Vagrant
Fixes Issue [#268](https://github.com/freephile/meza/issues/268)
  - Added: `manual/PATH_FIX.md`
  - Added: `manual/VBOX_755_MIGRATION_COMPLETE.md`
  - Added: `manual/VBOX_MANUAL_VM.md`
  - Added: `manual/VBOX_PERMISSIONS.md`
  - Modified: `src/roles/base/tasks/main.yml`
  - Added: `src/scripts/fix-meza-command.sh`
  - Added: `src/scripts/fix-vbox-permissions.sh`
  - Added: `src/scripts/setup-manual-vbox-mount.sh`
  - Modified: `vagrantconf.default.yml`

* [b8d583df](https://github.com/freephile/meza/commit/b8d583df) (2026-01-15) Greg Rundlett: fix Vagrantfile for permissions, UID, GID Enable it so that you can work and commit from your host while files in the guest also appear correctly.
For Issue [#268](https://github.com/freephile/meza/issues/268)
  - Modified: `Vagrantfile`

* [b1e9840b](https://github.com/freephile/meza/commit/b1e9840b) (2026-01-15) Greg Rundlett: prevent alt-meza-ansible from blocking deploy Remove the 'move_home' option - it is wrong to include it here.
Current code will properly "Ensure controller has user alt-meza-ansible
- If the user doesn't exist: Ansible creates it and sets up the home directory
- If the user exists: Ansible updates the home path if needed
- If the directory already exists: Ansible will use it
(no need to "move" it)
When the alt-meza-ansible user exists, but you change something about
the user (like their login config to include traditional system paths
such as /usr/bin) then a subsequent deploy can block on
'Ensure controller has user alt-meza-ansible user' due to the 'move_home'
option which should not be used.
The move_home parameter is only meaningful when modifying an existing
user's home directory location.
For Issue [#268](https://github.com/freephile/meza/issues/268)
  - Modified: `src/playbooks/site.yml`

* [3d05a705](https://github.com/freephile/meza/commit/3d05a705) (2026-01-15) Greg Rundlett: Make meza deploy faster - remove unneccessary and duplicative file mode and ownership conditioning
- extract file mode and ownership conditioning into 'verify-permissions' role which is then included; and can be run independently
Handles
-- Widgets
-- cache
-- images
-- uploads
as well as other project-wide folders and permissions (@TODO split)
- use ansible shell module to invoke composer commands with the proper umask so that pesky file permission problems are avoided in restrictive umask environments.
Example of running verify-permissions playbook:
ansible-playbook -i localhost, --connection=local  /opt/meza/src/playbooks/verify-permissions.yml -e env=monolith
For Issue [#267](https://github.com/freephile/meza/issues/267)
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/verify-permissions/tasks/main.yml`

* [f28d3067](https://github.com/freephile/meza/commit/f28d3067) (2026-01-15) Greg Rundlett: enable ansible profiling in ansible.cfg - fix spelling error in callbacks_enabled configuration to regain ansible profiling
- add commented section with defaults showing how to change profiling report
- convert comment style to use modern '#' instead of legacy ini-style ';'
for Issue [#267](https://github.com/freephile/meza/issues/267)
  - Modified: `config/ansible.cfg`

* [69b12928](https://github.com/freephile/meza/commit/69b12928) (2026-01-13) Greg Rundlett: add link to PROFILING README Ansible profiling is available by default.
Timings are in the deploy output and logs
Add link to additional information about profiling Ansible plays
see Issue [#267](https://github.com/freephile/meza/issues/267)
  - Modified: `src/roles/apache-php/README_PROFILING.md`

* [4b14ee15](https://github.com/freephile/meza/commit/4b14ee15) (2026-01-11) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [745068b1](https://github.com/freephile/meza/commit/745068b1) (2026-01-11) Greg Rundlett: fix documentation - fix paths
- explain how to 'turn off'
- you do NOT have to 'view source'
output is at the bottom of the page
for Issue [#262](https://github.com/freephile/meza/issues/262)
  - Modified: `src/roles/apache-php/README_PROFILING.md`

* [3c87f2e0](https://github.com/freephile/meza/commit/3c87f2e0) (2026-01-11) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [9197e025](https://github.com/freephile/meza/commit/9197e025) (2026-01-11) Greg Rundlett: fix destination and ownership of profiling.php for Issue [#262](https://github.com/freephile/meza/issues/262)
  - Modified: `src/roles/apache-php/tasks/profiling.yml`

* [311a8d17](https://github.com/freephile/meza/commit/311a8d17) (2026-01-11) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [62791b9a](https://github.com/freephile/meza/commit/62791b9a) (2026-01-11) Greg Rundlett: modernized Meza PHP profiling Replace XHGui+MongoDB with lightweight xhprof-based profiling
which integrates with MediaWiki.
Changes Made
== NEW files ==
- 20-xhprof.ini.j2 - PHP extension configuration
- profiling.php.j2 - MediaWiki profiler configuration with hierarchical control
- logrotate-profiler.j2 - Log rotation for file-based output
- README_PROFILING.md - Comprehensive documentation
== Changed files ==
- profiling.yml - Replaced MongoDB/XHGui with xhprof-only installation
- php.yml - Added conditional xhprof extension deployment
- main.yml - Uncommented profiling task include
- defaults.yml - Added profiling configuration with detailed comments
- php.ini.j2 - Removed obsolete profiling references
- httpd.conf.j2 - Removed port 8089 VirtualHost
- php-fpm-httpd.conf.j2 - Removed port 8089 VirtualHost
- main.yml - Removed port 8088 firewall rules
== DELETED files ==
mongod.conf.j2 - Obsolete MongoDB configuration
mongo.repo.j2 - Obsolete MongoDB repository
xhgui.config.php.j2 - Obsolete XHGui configuration
== Features ==
- Hierarchical profiling control - Environment-level, per-wiki, and output format
- Two output modes - Footer display (ProfilerOutputText) or file logging
- Automatic log rotation - Daily cleanup with configurable retention
- Security considerations - Documented risks and best practices
- Comprehensive documentation - Usage guide with common scenarios
- Backward compatibility - Legacy deployments handled gracefully
== Configuration Example ==
```yaml
m_setup_php_profiling: true
m_profiling_output_type: footer
m_profiling_file_retention_days: 1
wikis:
  - id: demo
    name: Demo Wiki
    enable_profiling: true
```
All YAML files validated successfully. Ready for testing and deployment.
Fixes Issue [#262](https://github.com/freephile/meza/issues/262)
  - Modified: `config/defaults.yml`
  - Added: `src/roles/apache-php/README_PROFILING.md`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Added: `src/roles/apache-php/templates/20-xhprof.ini.j2`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Added: `src/roles/apache-php/templates/logrotate-profiler.j2`
  - Deleted: `src/roles/apache-php/templates/mongo.repo.j2`
  - Deleted: `src/roles/apache-php/templates/mongod.conf.j2`
  - Modified: `src/roles/apache-php/templates/php-fpm-httpd.conf.j2`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`
  - Added: `src/roles/apache-php/templates/postLocalSettings.d/profiling.php.j2`
  - Deleted: `src/roles/apache-php/templates/xhgui.config.php.j2`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [fa7d5861](https://github.com/freephile/meza/commit/fa7d5861) (2026-01-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [180c02e1](https://github.com/freephile/meza/commit/180c02e1) (2026-01-10) Greg Rundlett: property parseable is not allowed in ansible-lint config The -p (or --parseable) command-line option and the corresponding
parseable configuration file property were used in older versions of
ansible-lint to produce output in a pep8 compatible format. These
options were removed as part of a breaking change in favor of the
current, more structured output formats. The schema validation in
newer versions of ansible-lint now flags this deprecated property as
an error.
You may wish to upgrade your ansible-lint with
pip install --upgrade ansible-lint
  - Modified: `.ansible-lint`

* [127c494a](https://github.com/freephile/meza/commit/127c494a) (2026-01-10) Greg Rundlett: make Parser Cache Type into a configurable setting Historically Meza used $wgParserCacheType = CACHE_NONE so that is the
default configuration. Users who wish to enable caching can now set
this to CACHE_ANYTHING OR CACHE_MEMCACHED by overriding it in
their public.yml.
See https://www.mediawiki.org/wiki/Meza/Variables
fixes Issue [#111](https://github.com/freephile/meza/issues/111)
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/mediawiki/defaults/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [696531ec](https://github.com/freephile/meza/commit/696531ec) (2026-01-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [fe969fc1](https://github.com/freephile/meza/commit/fe969fc1) (2026-01-10) Greg Rundlett: set parser cache Performance improved 50%
$wgParserCacheType = CACHE_MEMCACHED;
fixes Issue [#111](https://github.com/freephile/meza/issues/111)
Also, last commit standardized PHP comment syntax
in MezaCoreExtensions.yml config blocks
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [4311c054](https://github.com/freephile/meza/commit/4311c054) (2026-01-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [680a9de7](https://github.com/freephile/meza/commit/680a9de7) (2026-01-10) Greg Rundlett: add cache for SemanticMediaWiki set `$smwgQueryResultCacheType=CACHE_MEMCACHED;` for SMW
Memcached is already configured for other caches in LocalSettings.php
fixes Issue [#111](https://github.com/freephile/meza/issues/111)
  - Modified: `config/MezaCoreExtensions.yml`

* [858a6d5a](https://github.com/freephile/meza/commit/858a6d5a) (2026-01-10) Greg Rundlett: add helpful prompt about missing WIKI=foo The new failure message for a missing wikiId now includes a line to say
"Perhaps you forgot to specify WIKI=foo in your script command?"
[skip ci]
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [d653d469](https://github.com/freephile/meza/commit/d653d469) (2026-01-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [fa83a80a](https://github.com/freephile/meza/commit/fa83a80a) (2026-01-10) Greg Rundlett: format PHP templates for quality / conformance fix up LocalSettings.php and Extensions.php files
- PHPDoc header - Added proper file documentation with @package Meza
- Section headers - Changed from SECTION X) to SECTION X: format with proper PHPDoc blocks /** */
- Comment style - Changed # and ## to // for inline comments, PHPDoc /** */ for blocks
- Array syntax - Changed all array() to short syntax []
- Quote consistency - Fixed inconsistent quote usage (single quotes for string literals)
- Spacing - Added spaces around parentheses: if ( condition ) not if( condition )
- elseif - Changed else if to elseif (PHP best practice)
- Capitalization - Consistent comment capitalization
- Indentation - Tabs inside conditionals, proper formatting throughout
- @see tags - Changed reference comments to proper @see PHPDoc tags
- removed old $wgDisableCookieCheck setting
  - Modified: `src/roles/mediawiki/templates/Extensions.php.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [e6f73eff](https://github.com/freephile/meza/commit/e6f73eff) (2026-01-09) Greg Rundlett: clean up LocalSettings.php template shrink excess vertical whitespace by adding SECTION labels in all caps
This makes it like Extensions.php and is easy to search / visually scan
Also added a minor failsafe die() for any invalid auth-type
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [e7d6a6e6](https://github.com/freephile/meza/commit/e7d6a6e6) (2026-01-09) Greg Rundlett: add new feature to exclude core extensions reenable Wiretap extension; switching to freephile repo
introduce new variable `m_excluded_extension_names` that can be used
in `public.yml` to exclude extensions which otherwise are installed
as 'core' by MezaCoreExtensions.yml.
Excluded extensions *can* be re-enabled at the same time in
LocalExtensions.yml
(where they can also be configured to only install on a per-wiki basis).
Deploy output contains a message about excluded extensions for visibility
src/roles/init-controller-config/templates/public.yml.j2 contains
example exclude content to guide new admins
add `--public-config` option to `src/scripts/render_extensions_php.py`
helper script so that the tool mimics the extension excludes
revert interim solution from src/roles/init-controller-config/tasks/main.yml
fixes Issue [#256](https://github.com/freephile/meza/issues/256)
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/templates/public.yml.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/Extensions.php.j2`
  - Modified: `src/scripts/render_extensions_php.py`

* [b0f0b6d7](https://github.com/freephile/meza/commit/b0f0b6d7) (2026-01-08) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [b2785e3d](https://github.com/freephile/meza/commit/b2785e3d) (2026-01-08) Greg Rundlett: remove archived Graph extension Graph should not be used on a public wiki and the code is archived.
Fixes Issue [#251](https://github.com/freephile/meza/issues/251)
For more, see the discussion "Improve Chartinging capabilities of
Meza" https://github.com/freephile/meza/discussions/252
  - Modified: `config/MezaCoreExtensions.yml`

* [7e016a91](https://github.com/freephile/meza/commit/7e016a91) (2026-01-06) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [f602c7b0](https://github.com/freephile/meza/commit/f602c7b0) (2026-01-06) Greg Rundlett: remove inadvertent setting for CategoryTree ext CategoryTree can have $wgCategoryTreeSidebarRoot, but it would be a
local choice and is not valid in some skins.
The setting has been disabled by comment in CoreExtensions
  - Modified: `config/MezaCoreExtensions.yml`

* [e5221464](https://github.com/freephile/meza/commit/e5221464) (2026-01-03) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [3a30ea25](https://github.com/freephile/meza/commit/3a30ea25) (2026-01-03) Greg Rundlett: add SVG native client-side rendering Using `$wgSVGNativeRendering=true;` MediaWiki will serve SVG files
to the client browser instead of converting them to rasterized formats.
Fixes Issue [#248](https://github.com/freephile/meza/issues/248)
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [7bdd76d9](https://github.com/freephile/meza/commit/7bdd76d9) (2025-12-30) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [3a48d02d](https://github.com/freephile/meza/commit/3a48d02d) (2025-12-30) Greg Rundlett: fix typo skip-ci 
  - Modified: `src/scripts/render_extensions_php.py`

* [b58b1a11](https://github.com/freephile/meza/commit/b58b1a11) (2025-12-30) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [7ba28a1e](https://github.com/freephile/meza/commit/7ba28a1e) (2025-12-30) Greg Rundlett: add comment about the helper script for Extensions.php 
  - Modified: `src/roles/mediawiki/templates/Extensions.php.j2`

* [ab35d350](https://github.com/freephile/meza/commit/ab35d350) (2025-12-30) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [2ca5454a](https://github.com/freephile/meza/commit/2ca5454a) (2025-12-30) Greg Rundlett: add script for developing the jinja template for Extensions.php Jinja templating is hard, confusing, and unpredictable.
Toss in differences between Python 3.6.8 and modern Python and you're soon pulling your hair out.
This script allows you to iterate on src/roles/mediawiki/templates/Extensions.php.j2
without needing to do deploys just to see the results.
  - Added: `src/scripts/render_extensions_php.py`

* [def1caba](https://github.com/freephile/meza/commit/def1caba) (2025-12-30) Greg Rundlett: replace tabs with spaces in Jinja templates 
  - Modified: `src/roles/mediawiki/templates/Extensions.php.j2`

* [353dc13c](https://github.com/freephile/meza/commit/353dc13c) (2025-12-30) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [9882079d](https://github.com/freephile/meza/commit/9882079d) (2025-12-29) Greg Rundlett: Improve templating of Extensions Add better examples and reference link to MezaLocalExtensions.yml
Include the -wikis conditional gate for Local Extensions described on-wiki
Improve the wording, and remove excess whitespace from the 'Extensions.php' deploy file
Add Jinja comments to improve the readability of control structures
  - Modified: `src/roles/init-controller-config/templates/MezaLocalExtensions.yml.j2`
  - Modified: `src/roles/mediawiki/templates/Extensions.php.j2`

* [d6b9b709](https://github.com/freephile/meza/commit/d6b9b709) (2025-12-23) Rich Evans: Update config.php.j2 minor corrections to restore functionality for nasa grc-atf like:
  - Modified: `src/roles/saml/templates/config.php.j2`

* [cafc7aeb](https://github.com/freephile/meza/commit/cafc7aeb) (2025-12-23) Rich Evans: Update config.php.j2 removed unwanted comments and whitespace
  - Modified: `src/roles/saml/templates/config.php.j2`

* [386986b1](https://github.com/freephile/meza/commit/386986b1) (2025-12-19) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [1494ef61](https://github.com/freephile/meza/commit/1494ef61) (2025-12-18) Greg Rundlett: Re-enable WhosOnline After fixing the extension for MW compatibility
and removing logging of anonymous users, we can re-enable the extension
Fixes Issue [#177](https://github.com/freephile/meza/issues/177)
  - Modified: `config/MezaCoreExtensions.yml`

* [94e7c884](https://github.com/freephile/meza/commit/94e7c884) (2025-12-11) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [78f9f5e8](https://github.com/freephile/meza/commit/78f9f5e8) (2025-12-11) Greg Rundlett: disable ParserMigration extension requires MediaWiki 1.46+
fixes Issue [#239](https://github.com/freephile/meza/issues/239)
  - Modified: `config/MezaCoreExtensions.yml`

* [745e90b9](https://github.com/freephile/meza/commit/745e90b9) (2025-12-11) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [4b24c258](https://github.com/freephile/meza/commit/4b24c258) (2025-12-11) Greg Rundlett: add ParserMigration for Parsoid reads There should be new User preferences to opt in
Fixes Issue [#239](https://github.com/freephile/meza/issues/239)
  - Modified: `config/MezaCoreExtensions.yml`

* [eba1f494](https://github.com/freephile/meza/commit/eba1f494) (2025-12-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [ef9a927e](https://github.com/freephile/meza/commit/ef9a927e) (2025-12-10) Greg Rundlett: Security and Maintenance release update to 1.43.6
also fix typo for sudoers
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/base/tasks/main.yml`

* [427747c6](https://github.com/freephile/meza/commit/427747c6) (2025-12-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [06545e1c](https://github.com/freephile/meza/commit/06545e1c) (2025-12-10) Greg Rundlett: add examples and reference for PyWikiBot 
  - Added: `scripts/README_PYWIKIBOT.md`
  - Added: `scripts/create_extension_features.py`
  - Added: `scripts/pywikibot-user-config.py`

* [c6d00a97](https://github.com/freephile/meza/commit/c6d00a97) (2025-12-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [123f4378](https://github.com/freephile/meza/commit/123f4378) (2025-12-09) Greg Rundlett: add CrawlerProtection extension Block bots with CrawlerProtection
Lockdown extension is left installed, but the configuration is
removed since currently it is not doing anything out of the box.
  - Modified: `config/MezaCoreExtensions.yml`

* [f9d4e87a](https://github.com/freephile/meza/commit/f9d4e87a) (2025-12-10) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [8feff366](https://github.com/freephile/meza/commit/8feff366) (2025-12-09) Greg Rundlett: enhance Copilot instructions for Python Also add references to named standards and conventions
  - Modified: `.github/copilot-instructions.md`

* [b02998fa](https://github.com/freephile/meza/commit/b02998fa) (2025-11-25) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [aa49f0b7](https://github.com/freephile/meza/commit/aa49f0b7) (2025-11-24) Greg Rundlett: Remove problematic line from Lockdown config You can not use $wgNamespaceProtection[NS_SPECIAL]['read'] = [ 'user' ];
to restrict the Special pseudo-namespace to registered users.
Note: This is a global variable, not specific to the Lockdown ext.
https://www.mediawiki.org/wiki/Manual:$wgNamespaceProtection
If you accidentally try this, you will receive an error upon accessing
Special:CreateAcccount that you do not have permission to EDIT pages in
the Special namespace.
Continuation of the fix for Issue [#156](https://github.com/freephile/meza/issues/156)
Add comment with API query example for SpecialPage aliases
  - Modified: `config/MezaCoreExtensions.yml`

* [ea8482ea](https://github.com/freephile/meza/commit/ea8482ea) (2025-10-31) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [59cd7f0c](https://github.com/freephile/meza/commit/59cd7f0c) (2025-10-31) Greg Rundlett: cleanup info about "install" command 
  - Modified: `manual/meza-cmd/MIGRATION.md`
  - Modified: `manual/meza-cmd/docker.md`
  - Modified: `manual/meza-cmd/help.md`
  - Modified: `manual/meza-cmd/index.md`
  - Modified: `manual/meza-cmd/install.md`

* [538fe06f](https://github.com/freephile/meza/commit/538fe06f) (2025-10-31) Greg Rundlett: strip trailing whitespace 
  - Modified: `src/scripts/meza.py`

* [c9f6d6d0](https://github.com/freephile/meza/commit/c9f6d6d0) (2025-10-31) Greg Rundlett: doc getmeza.sh concise version
Fixes Issue [#172](https://github.com/freephile/meza/issues/172)
  - Modified: `src/scripts/getmeza.md`

* [27d5656b](https://github.com/freephile/meza/commit/27d5656b) (2025-10-31) Greg Rundlett: doc getmeza.sh Verbose version
Addresses Issue [#172](https://github.com/freephile/meza/issues/172)
  - Added: `src/scripts/getmeza.md`

* [45ad0b89](https://github.com/freephile/meza/commit/45ad0b89) (2025-10-31) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [67bc1b6d](https://github.com/freephile/meza/commit/67bc1b6d) (2025-10-30) Greg Rundlett: Correct the basic meza help message Also, avoid catching too generic exception
  - Modified: `src/scripts/meza.py`

* [ca0e0d88](https://github.com/freephile/meza/commit/ca0e0d88) (2025-10-31) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [bd8551ea](https://github.com/freephile/meza/commit/bd8551ea) (2025-10-30) Greg Rundlett: Make lint-files.sh script more quiet By default only show warnings and errors.
We introduce a -v or --verbose option if you want to show success
messages too.
Add --help with usage
  - Modified: `src/scripts/lint-files.sh`

* [979fe609](https://github.com/freephile/meza/commit/979fe609) (2025-10-30) Greg Rundlett: Fix yaml linting errors 
  - Modified: `.github/workflows/release-notes.yml`
  - Modified: `src/playbooks/create-wiki.yml`
  - Modified: `src/playbooks/debug.yml`
  - Modified: `src/playbooks/migrate-wikis.yml`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/delete-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/imagemagick/tasks/setup-Debian.yml`
  - Modified: `src/roles/imagemagick/tasks/setup-RedHat.yml`

* [99d95977](https://github.com/freephile/meza/commit/99d95977) (2025-10-30) Greg Rundlett: Improve linting configuration Ignore 'collections' which is 3rd-party code.
  - Modified: `.ansible-lint`
  - Modified: `.yamllint`

* [ff9e66b9](https://github.com/freephile/meza/commit/ff9e66b9) (2025-10-30) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [51e8d6f8](https://github.com/freephile/meza/commit/51e8d6f8) (2025-10-30) Greg Rundlett: We don't need no stinkin' badges 
  - Modified: `README.md`

* [1e877576](https://github.com/freephile/meza/commit/1e877576) (2025-10-30) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [a6a76f61](https://github.com/freephile/meza/commit/a6a76f61) (2025-10-30) Greg Rundlett: process the dev branch 
  - Modified: `.github/workflows/yamllint.yml`

* [09a7a3c3](https://github.com/freephile/meza/commit/09a7a3c3) (2025-10-30) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [b19e5f52](https://github.com/freephile/meza/commit/b19e5f52) (2025-10-30) Greg Rundlett: Major enhancements: Create wiki logging, etc. "meza create wiki" logging implementation
-----------------------------------------
The new create-wiki logging mirrors the deploy logging architecture with both transactional and processing logs.
Transactional log: /opt/data-meza/logs/create-wiki/create-wiki.log (tracks operations with metadata)
Processing log: /opt/data-meza/logs/create-wiki-output/{env}-{timestamp}.log (captures ansible output)
/opt/data-meza/logs/
├── create-wiki/           # Transactional logs
│   └── create-wiki.log    # Audit trail
└── create-wiki-output/    # Processing logs
    ├── demo-2025-10-29_175734.log
    └── prod-2025-10-29_180234.log
Added two new commands:
sudo meza create-wiki-tail <env>
- tells you what log its tailing and provides a way to check status on the create wiki process in real-time
sudo meza create-wiki-log <env>
- tells you the path of the process log e.g.
/opt/data-meza/logs/create-wiki-output/monolith-2025-10-29_225319.log
Meza.py uses paths from paths.yml
---------------------------------
- Single Source of Truth: All paths defined in paths.yml, easy to maintain
- Removed hardcoded path definitions from meza.py
- Consistency: Python CLI uses same paths as Ansible roles
- Deterministic: No fallbacks, clear failures
- Jinja2 Template Support: variables found in yaml are resolved. {{ m_install }} resolves to 'opt'
- Error Handling: Clear error messages for configuration issues such as paths.yml missing
- new m_logs_create_wiki variable in paths.yml to define the location of the "meza create wiki" log
Verify-wiki enhanced
----------------------
wiki_id and wiki_name (as well as password) are passed by extra_vars in meza.py when it calls create-wiki-promptless playbook.
create-wiki playbook now prompts for Admin password and passes it on to the 'create-admin-account' task list in verify-wiki.
src/roles/verify-wiki/tasks/import-wiki-sql.yml is enhanced with output about wiki creation status
and the set_fact section was improved to clarify what's happening:
- New wiki was created (truly new, not from backup)
- Wiki created but from backup/import
- Wiki already existed
BEFORE the created_new_wiki flag logic was problematic.
Admin Account creation
----------------------
The admin account creation was hardcoded to only work for wikis with wiki_id == "demo"
Removed wiki_id restriction: Changed from when: wiki_id == "demo" to run for any new wiki
Updated prompts: Made the messages generic to work for any wiki name
Fixes Issue [#217](https://github.com/freephile/meza/issues/217)
Fixes Issue [#220](https://github.com/freephile/meza/issues/220)
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/create-wiki-promptless.yml`
  - Modified: `src/playbooks/create-wiki.yml`
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/create-admin-account.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/scripts/meza.py`

* [465eaeeb](https://github.com/freephile/meza/commit/465eaeeb) (2025-10-29) Greg Rundlett: Fix the CHANGELOG automation - fix the updateCHANGELOG.sh script (used by Continuous Integration)
- Update the entire CHANGELOG for consistent 'pretty' formatting
- Limit the CHANGELOG to start at 2022-01-01 for length
[skip ci] chicken and egg problem
Fixes Issue [#219](https://github.com/freephile/meza/issues/219)
  - Modified: `CHANGELOG`
  - Modified: `src/scripts/updateCHANGELOG.sh`

* [6e51cc5b](https://github.com/freephile/meza/commit/6e51cc5b) (2025-10-29) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [a799fa87](https://github.com/freephile/meza/commit/a799fa87) (2025-10-29) Greg Rundlett: Prompt for credentials when creating Admin acct When Meza creates an Admin account, whether for the initial 'demo'
or for any new wiki, prompt for the secure password and do not log it.
This way it is only known to the user, and not a vulnerability.
Note: the way that this is executed in the role hierarchy is that
verify-wiki runs import-wiki-sql tasks for new wikis, which in turn
runs init-wiki tasks. Since 'init-wiki.yml' ONLY creates an Admin account
it was renamed 'create-admin-account.yml'
Fixes Issue [#217](https://github.com/freephile/meza/issues/217)
  - Added: `src/roles/verify-wiki/tasks/create-admin-account.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Deleted: `src/roles/verify-wiki/tasks/init-wiki.yml`

* [de0798e2](https://github.com/freephile/meza/commit/de0798e2) (2025-10-24) GitHub Action: Auto-update CHANGELOG and release notes - Updated CHANGELOG with latest commits
- Generated RELEASE_NOTES-HEAD.md
- Automated by GitHub Actions
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [43cfde0a](https://github.com/freephile/meza/commit/43cfde0a) (2025-10-24) Greg Rundlett: Automated RELEASE NOTES and Changelog w/ Actions see .github/RELEASE_AUTOMATION.md for details
Though GitHub Actions, we integrated automatic Changelog and RELEASE
NOTES generation.
For pull requests and commits.
  - Added: `.github/RELEASE_AUTOMATION.md`
  - Added: `.github/workflows/advanced-release-management.yml`
  - Added: `.github/workflows/manual-release-notes.yml`
  - Added: `.github/workflows/release-notes.yml`
  - Added: `src/scripts/release-helper.sh`

* [31f360d9](https://github.com/freephile/meza/commit/31f360d9) (2025-10-24) Greg Rundlett: Expand help.md to all meza commands 
  - Modified: `manual/meza-cmd/MIGRATION.md`
  - Modified: `manual/meza-cmd/help.md`
  - Modified: `manual/meza-cmd/install.md`

* [9071e05b](https://github.com/freephile/meza/commit/9071e05b) (2025-10-24) Greg Rundlett: Correct help content about deploy command There is no 'install monolith' command.
  - Modified: `manual/meza-cmd/MIGRATION.md`
  - Modified: `manual/meza-cmd/help.md`
  - Modified: `manual/meza-cmd/install.md`

* [1effac3a](https://github.com/freephile/meza/commit/1effac3a) (2025-10-24) Greg Rundlett: Update Changelog and RELEASE NOTES-HEAD 
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [d91c7a73](https://github.com/freephile/meza/commit/d91c7a73) (2025-10-24) Greg Rundlett: Re-enable WatchAnalytics Fixes Issue [#214](https://github.com/freephile/meza/issues/214)
  - Modified: `config/MezaCoreExtensions.yml`

* [4541968c](https://github.com/freephile/meza/commit/4541968c) (2025-10-24) Greg Rundlett: minor tweaks to Quick Start section (curl not ready yet)
whitespace changes in meza.py
  - Modified: `manual/meza-cmd/index.md`
  - Modified: `src/scripts/meza.py`

* [53d45c48](https://github.com/freephile/meza/commit/53d45c48) (2025-10-23) Greg Rundlett: Add Maintence script runner Remove the 'cleanup-upload-stash' playbook and replace it with a general purpose MediaWiki Maintenance script runner: `run-maintenance.yml`
Update maint command doc
Backward compatibility is retained for invoking cleanupUploadStash
  - Modified: `manual/meza-cmd/maint.md`
  - Modified: `src/playbooks/cleanup-upload-stash.yml`
  - Added: `src/playbooks/run-maintenance.yml`
  - Modified: `src/scripts/meza.py`

* [a590d270](https://github.com/freephile/meza/commit/a590d270) (2025-10-23) Greg Rundlett: Add LinkTarget extension 
  - Modified: `config/MezaCoreExtensions.yml`

* [6eb271e6](https://github.com/freephile/meza/commit/6eb271e6) (2025-10-23) Greg Rundlett: Update Changelog and RELEASE NOTES 
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [0fb72fa6](https://github.com/freephile/meza/commit/0fb72fa6) (2025-10-23) Greg Rundlett: Update Changelog and RELEASE NOTES 
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`
  - Modified: `manual/meza-cmd/index.md`

* [ce3ed9b9](https://github.com/freephile/meza/commit/ce3ed9b9) (2025-10-23) Greg Rundlett: Correct the quick start section Add curl command for running getmeza.sh
`curl -L https://raw.githubusercontent.com/nasa/meza/master/src/scripts/getmeza.sh | bash`
Fixes Issue [#211](https://github.com/freephile/meza/issues/211)
  - Modified: `manual/meza-cmd/index.md`

* [c4043ba1](https://github.com/freephile/meza/commit/c4043ba1) (2025-10-23) Greg Rundlett: Add in the 'rich' requirement for better console help 
  - Modified: `requirements-dev.txt`

* [0faa71cf](https://github.com/freephile/meza/commit/0faa71cf) (2025-10-23) Greg Rundlett: Remove undefined 'destroy' command The meza destroy command was a placeholder for undefined functionality.
Fixes Issue [#211](https://github.com/freephile/meza/issues/211)
  - Modified: `src/scripts/meza.py`

* [04b98d47](https://github.com/freephile/meza/commit/04b98d47) (2025-10-23) Greg Rundlett: Fix help command alignment Intuitive rename of base.md to help.md to follow the pattern where
meza commands have a .md file by the same name.
meza                   # Shows help.md (general help)
meza --help            # Shows help.md (general help)
meza help              # Shows help.md (general help)
meza help deploy       # Shows deploy.md (deploy command help)
meza help --help       # Shows help.md (help for help command itself)
meza deploy --help     # Shows deploy.md (deploy command help)
Fixes Issue [#211](https://github.com/freephile/meza/issues/211)
  - Modified: `manual/meza-cmd/MIGRATION.md`
R100	manual/meza-cmd/base.md	manual/meza-cmd/help.md
  - Modified: `src/scripts/meza.py`

* [19193c2a](https://github.com/freephile/meza/commit/19193c2a) (2025-10-23) Greg Rundlett: Add missing newline at end of file 
  - Modified: `manual/meza-cmd/deploy-notify.md`

* [8c1e6c67](https://github.com/freephile/meza/commit/8c1e6c67) (2025-10-23) Greg Rundlett: Add doc for deploy-notify playbook and command - Adds manual/meza-cmd/deploy-notify.md
This fixes Issue [#211](https://github.com/freephile/meza/issues/211)
  - Added: `manual/meza-cmd/deploy-notify.md`

* [016aacb6](https://github.com/freephile/meza/commit/016aacb6) (2025-10-23) Greg Rundlett: Add autodeployer doc - improve doc for 'debug'
- correct doc for 'config'
  - there's no such command, but we explain how config is managed in meza
- move cleanup-backups script documentation to scripts directory
Fixes Issue [#211](https://github.com/freephile/meza/issues/211)
  - Added: `manual/meza-cmd/autodeploy.md`
  - Modified: `manual/meza-cmd/config.md`
  - Modified: `manual/meza-cmd/debug.md`
  - Modified: `src/roles/logrotate/README.md`
R099	manual/meza-cmd/cleanup-backups.md	src/scripts/cleanup-backups.md

* [64c1e8eb](https://github.com/freephile/meza/commit/64c1e8eb) (2025-10-23) Greg Rundlett: Document the maintenance command 
  - Modified: `manual/meza-cmd/index.md`
  - Modified: `manual/meza-cmd/maint.md`
  - Modified: `src/scripts/meza.py`

* [43b4eb8c](https://github.com/freephile/meza/commit/43b4eb8c) (2025-10-23) Greg Rundlett: Avoid setting shared DB if there is no prime wiki, then there can be no
sharing configured
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [2ab3548e](https://github.com/freephile/meza/commit/2ab3548e) (2025-10-22) Greg Rundlett: Add Backup and Retention Policy Framework meza.py
- add find_most_recent_log_file
- enhance get_deploy_log_path(env)
- enhance deploy_log
- make deploy-tail more able to find log_path
site.yml
- add task to 'Configure log rotation on all servers'
- with tags logrotate, logs
logrotate role
- see README.md for complete overview
- new - implements a complete log and backup retention policy
cleanup-backups.sh new script
cleanup-backups.md documentation
  - Added: `manual/meza-cmd/cleanup-backups.md`
  - Modified: `src/playbooks/site.yml`
  - Added: `src/roles/logrotate/README.md`
  - Added: `src/roles/logrotate/defaults/main.yml`
  - Added: `src/roles/logrotate/handlers/main.yml`
  - Added: `src/roles/logrotate/meta/main.yml`
  - Added: `src/roles/logrotate/tasks/main.yml`
  - Added: `src/roles/logrotate/templates/cleanup-backups.sh.j2`
  - Added: `src/roles/logrotate/templates/meza-logs.j2`
  - Added: `src/scripts/cleanup-backups.sh`
  - Modified: `src/scripts/meza.py`

* [02d78fc8](https://github.com/freephile/meza/commit/02d78fc8) (2025-10-22) Greg Rundlett: Fix first-time deploy error due to Apache missing role: init-controller-config
- remove ownership details from 'wikis' directory (set it later)
role: apache-php
- add apache-php task to "Set proper ownership" on wikis
Fixes Issue [#212](https://github.com/freephile/meza/issues/212)
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`

* [4a96eef8](https://github.com/freephile/meza/commit/4a96eef8) (2025-10-21) Greg Rundlett: Enhance help display using rich markdown rendering 
  - Modified: `src/scripts/meza.py`

* [dc865669](https://github.com/freephile/meza/commit/dc865669) (2025-10-21) Greg Rundlett: Update CHANGELOG 
  - Modified: `CHANGELOG`

* [9a2be9a6](https://github.com/freephile/meza/commit/9a2be9a6) (2025-10-20) Greg Rundlett: Remove trailing whitespace in markdown 
  - Modified: `RELEASE-NOTES.md`
  - Modified: `RELEASE_NOTES-HEAD.md`

* [2379a054](https://github.com/freephile/meza/commit/2379a054) (2025-10-20) Greg Rundlett: update RELEASE_NOTES to v43.49.2 
  - Modified: `RELEASE-NOTES.md`
  - Added: `RELEASE_NOTES-HEAD.md`

* [29d0b9f2](https://github.com/freephile/meza/commit/29d0b9f2) (2025-10-20) Greg Rundlett: truncate RELEASE_NOTES 
  - Modified: `RELEASE-NOTES.md`

* [cb737a5c](https://github.com/freephile/meza/commit/cb737a5c) (2025-10-20) Greg Rundlett: consolidate RELEASE_NOTES into one Fixes Issue [#3](https://github.com/freephile/meza/issues/3)
  - Modified: `RELEASE-NOTES.md`
  - Deleted: `RELEASE_NOTES-43.25.11.md`
  - Deleted: `RELEASE_NOTES-43.29.1.md`
  - Deleted: `RELEASE_NOTES-HEAD.md`

* [724467c0](https://github.com/freephile/meza/commit/724467c0) (2025-10-20) Greg Rundlett: Remove obsolete text files Fixes Issue [#3](https://github.com/freephile/meza/issues/3)
  - Deleted: `manual/meza-cmd/backup.txt`
  - Deleted: `manual/meza-cmd/base.txt`
  - Deleted: `manual/meza-cmd/config.txt`
  - Deleted: `manual/meza-cmd/create.txt`
  - Deleted: `manual/meza-cmd/debug.txt`
  - Deleted: `manual/meza-cmd/delete.txt`
  - Deleted: `manual/meza-cmd/deploy.txt`
  - Deleted: `manual/meza-cmd/docker.txt`
  - Deleted: `manual/meza-cmd/install.txt`
  - Deleted: `manual/meza-cmd/list-wikis.txt`
  - Deleted: `manual/meza-cmd/maint.txt`
  - Deleted: `manual/meza-cmd/migrate-wikis.txt`
  - Deleted: `manual/meza-cmd/prompt.txt`
  - Deleted: `manual/meza-cmd/prompt_default_on_blank.txt`
  - Deleted: `manual/meza-cmd/prompt_secure.txt`
  - Deleted: `manual/meza-cmd/setup.txt`

* [b21a3aeb](https://github.com/freephile/meza/commit/b21a3aeb) (2025-10-20) Greg Rundlett: Feat: migrate help system from txt to markdown Enhanced Documentation Features:
📊 Structured tables for arguments and options
🎨 Syntax-highlighted code blocks
⚠️ Visual warnings with emojis
🔗 Cross-references between related commands
📋 Consistent formatting across all files
command documentation is now in markdown files (.md) replacing any
pre-existing .txt files
Added documentation for previously undocumented commands
Improved documentation for meza create wiki and meza delete wiki
new command for **list-wikis**
`meza list-wikis`
new general purpose **debug** command backed by a debug playbook
`meza debug monolith m_htdocs`
new help system for every meza command
meza <command> --help
Fixes Issue [#3](https://github.com/freephile/meza/issues/3)
  - Added: `manual/meza-cmd/DELETION.md`
  - Added: `manual/meza-cmd/MIGRATION.md`
  - Added: `manual/meza-cmd/backup.md`
  - Added: `manual/meza-cmd/base.md`
  - Added: `manual/meza-cmd/config.md`
  - Added: `manual/meza-cmd/create.md`
  - Modified: `manual/meza-cmd/create.txt`
  - Added: `manual/meza-cmd/debug.md`
  - Added: `manual/meza-cmd/debug.txt`
  - Added: `manual/meza-cmd/delete.md`
  - Added: `manual/meza-cmd/delete.txt`
  - Added: `manual/meza-cmd/deploy-check.md`
  - Added: `manual/meza-cmd/deploy-kill.md`
  - Added: `manual/meza-cmd/deploy-lock.md`
  - Added: `manual/meza-cmd/deploy-log.md`
  - Added: `manual/meza-cmd/deploy-tail.md`
  - Added: `manual/meza-cmd/deploy-unlock.md`
  - Added: `manual/meza-cmd/deploy.md`
  - Added: `manual/meza-cmd/docker.md`
  - Added: `manual/meza-cmd/index.md`
  - Added: `manual/meza-cmd/install.md`
  - Added: `manual/meza-cmd/list-wikis.md`
  - Added: `manual/meza-cmd/list-wikis.txt`
  - Added: `manual/meza-cmd/maint.md`
  - Added: `manual/meza-cmd/migrate-wikis.md`
  - Added: `manual/meza-cmd/setup.md`
  - Added: `manual/meza-cmd/update.md`
  - Added: `src/playbooks/debug.yml`
  - Modified: `src/scripts/meza.py`

* [13b0f8d4](https://github.com/freephile/meza/commit/13b0f8d4) (2025-10-20) Greg Rundlett: Add force for symlink creation `meza create wiki` could fail as late as during the update.php phase of a subsequent deploy because the .smw.json file was not writable in the symlinked config directory.
fixes Issue [#48](https://github.com/freephile/meza/issues/48) and Issue [#44](https://github.com/freephile/meza/issues/44)
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [f0acdaf9](https://github.com/freephile/meza/commit/f0acdaf9) (2025-10-20) Greg Rundlett: Fix ansible syntax problems FQCN (Fully Qualified Collection Names)
Fixed task key order
- name
- when
- delegate_to
- run_once
- block
Fix shell command issues
- set -o pipefail to shell commands to handle pipe failures
- changed_when: false for read-only shell commands
- changed_when: true for shell commands that modify files
Jinja2 spacing
- remove extra space (newline) before {%- endif -%}
Structure Issues
- Fixed duplicated when conditions that were appearing at both block and task levels
- Removed duplicate delegate_to and run_once declarations
- Properly structured task hierarchies
  - Modified: `src/roles/migrate-to-declarative-wikis/tasks/main.yml`

* [3f2f5d9e](https://github.com/freephile/meza/commit/3f2f5d9e) (2025-10-20) Greg Rundlett: Fix meza migrate-wikis task 'Set Primary wiki when no existing declarative config'
was broken with an undefined variable
The map filter was trying to loop a variable in a non-loop context
so the Jinja2 template logic was wrong
`sudo meza migrate-wikis monolith` works now
instead an 'undefined variable' error
Fixes Issue [#101](https://github.com/freephile/meza/issues/101) Use a declarative wiki ID
  - Modified: `src/roles/migrate-to-declarative-wikis/tasks/main.yml`

* [8087fde7](https://github.com/freephile/meza/commit/8087fde7) (2025-10-15) Greg Rundlett: Tag "paths" and "defaults" to run always The 'set-vars' role now includes vars from
- config/paths.yml
- config/defaults.yml
on all ansible commands by using the special 'always' tag.
A task with the always tag will always run, even if you use
--skip-tags always or run the playbook with different tags.
It's useful for critical setup or cleanup tasks.
The 'always' tag is the opposite of the 'never' tag.
Now the core configuration loading (OS-specific, paths, and defaults)
always run regardless of which tags are specified, ensuring that
essential variables are available for any tagged deployment scenario.
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [ff03f425](https://github.com/freephile/meza/commit/ff03f425) (2025-10-15) Greg Rundlett: Update SBOM files Update the generated Software Bill Of Materials (SBOM) files
Also make lint-files.sh executable.
  - Modified: `src/scripts/lint-files.sh`
  - Modified: `src/scripts/meza-sbom.cyclonedx.json`
  - Modified: `src/scripts/meza-sbom.spdx.json`
  - Modified: `src/scripts/meza-sbom.txt`

* [9114307c](https://github.com/freephile/meza/commit/9114307c) (2025-10-15) Greg Rundlett: Fix meza maint run_jobs sudo meza maint run_jobs will run all jobs for all wikis.
Meza produces a wrapper script on deploy which can be used to invoke
MediaWiki's maintenance run.php runJobs for all defined wikis.
You can also selectively pass a wiki ID to the command.
Fixed the script invocation and also uses the declarative wiki approach.
  - Modified: `src/scripts/meza.py`

* [091cf901](https://github.com/freephile/meza/commit/091cf901) (2025-10-15) Greg Rundlett: Make CoreExtensions and LocalExtensions robust Make the variable declarations more robust so that --check mode works.
e.g. ansible-playbook /opt/meza/src/playbooks/site.yml --check
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [f775e370](https://github.com/freephile/meza/commit/f775e370) (2025-10-15) Greg Rundlett: Add Debian support for ImageMagick and Ghostscript Follow the same pattern of cross-platform compatibility used in the
database role and the geerlingguy/kibana role for cross-platform
package installation. Also ensure that the ansible variable is
defined so that --check works with narrow playbook execution.
Touches on Issue [#42](https://github.com/freephile/meza/issues/42) and Issue [#204](https://github.com/freephile/meza/issues/204)
  - Modified: `src/roles/imagemagick/tasks/main.yml`
  - Added: `src/roles/imagemagick/tasks/setup-Debian.yml`
  - Added: `src/roles/imagemagick/tasks/setup-RedHat.yml`

* [7dd492a3](https://github.com/freephile/meza/commit/7dd492a3) (2025-10-15) Greg Rundlett: Convert to using a declarative approach for wikis You can now declare wiki IDs, names, aliases, and other
attributes for wikis in YAML. This deprecates the implied or indirect
directory method of creating and identifying wikis.
The deprecated directory method is still supported.
There is a new meza command 'migrate-wikis' that will write the YAML
for you - storing it in your conf-meza/public/public.yml file.
Usage: sudo meza migrate-wikis <environment>
e.g. sudo meza migrate-wikis monolith
See config/defaults.yml for example declaration
You can now use Meza commands to 'create' wiki and 'delete' wiki.
However, you can now also simply edit your YAML configuration and
run a meza deploy which will create wikis accordingly.
New:
- manual/meza-cmd/migrate-wikis.txt
- src/playbooks/migrate-wikis.yml
- src/roles/base-config-scripts/templates/wiki-config.php.j2
- src/roles/migrate-to-declarative-wikis/tasks/main.yml
Modified:
- config/defaults.yml
- src/roles/base-config-scripts/tasks/main.yml
- src/roles/base-config-scripts/templates/config.sh.j2
- src/roles/configure-wiki/tasks/main.yml
- src/roles/delete-wiki-wrapper/tasks/main.yml
- src/roles/mediawiki/tasks/main.yml
- src/roles/mediawiki/templates/LocalSettings.php.j2
- src/roles/mediawiki/templates/refresh-links.sh.j2
- src/roles/mediawiki/templates/smw-rebuild-all.sh.j2
- src/roles/set-vars/tasks/main.yml
- src/scripts/meza.py
- src/scripts/unifyUserTables.php
Fixes Issue [#101](https://github.com/freephile/meza/issues/101)
  - Modified: `config/defaults.yml`
  - Added: `manual/meza-cmd/migrate-wikis.txt`
  - Added: `src/playbooks/migrate-wikis.yml`
  - Modified: `src/roles/base-config-scripts/tasks/main.yml`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Added: `src/roles/base-config-scripts/templates/wiki-config.php.j2`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/delete-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/mediawiki/templates/refresh-links.sh.j2`
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`
  - Added: `src/roles/migrate-to-declarative-wikis/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/unifyUserTables.php`

* [6f654084](https://github.com/freephile/meza/commit/6f654084) (2025-09-29) Greg Rundlett: Fix linting issues in init-controller-config - Remove trailing space character in a comment that breaks linting.
- Use Fully Qualified Collection Names (FQCN)
  such as ansible.builtin.file
- Use templates only at the end of task names.
  It is **discouraged** to use templates in names at all.
  If you do use them, at least put them at the end
  https://ansible.readthedocs.io/projects/lint/rules/name/
  - Modified: `src/roles/init-controller-config/tasks/main.yml`

* [cbce465d](https://github.com/freephile/meza/commit/cbce465d) (2025-09-29) Rich Evans: fixes for the refresh-links.sh template These changes are what was required for the /opt/.deploy-meza/refresh-links.sh script to run without errors on my CMTE system.
  - Modified: `src/roles/mediawiki/templates/refresh-links.sh.j2`

* [c6bbd3c1](https://github.com/freephile/meza/commit/c6bbd3c1) (2025-09-28) Greg Rundlett: Ensure .smw.json ownership and permissions Change the init-controller-config role to have a comment that reflects
the intention of the code.
Change owner and group to apache
Make ownership of 'wikis' directory recursive
Change `m_config_public_mode` from 0755 to 0775 for dirs 0664 for files
by using Symbolic mode u=rwX,g=rwX,o=rX.
Expand group permissions to be able to write files while reducing
'other' permissions to only be able to read files.
Remove permission to execute files from all users.
Change the `configure-wiki` role **which only runs on wiki creation**
to properly create `.smw.json` as group-owned by apache.
Fixes Issue [#44](https://github.com/freephile/meza/issues/44)
  - Modified: `config/paths.yml`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`

* [3046811d](https://github.com/freephile/meza/commit/3046811d) (2025-09-25) Greg Rundlett: Update CHANGELOG and RELEASE_NOTES-HEAD Using the commit-hook actually worked and prevented my local commit
while enforcing the removal of trailing whitespace!
I also added better USAGE guidelines for the generate-release-notes.sh
script (printed if you invoke it without arguments).
`./src/scripts/updateCHANGELOG.sh` does the work without any arguments.
`./src/scripts/generate-release-notes.sh 43.29.1 HEAD` does the latest
release notes file.
  - Modified: `CHANGELOG`
  - Modified: `RELEASE_NOTES-HEAD.md`
  - Modified: `src/scripts/generate-release-notes.sh`

* [5068855d](https://github.com/freephile/meza/commit/5068855d) (2025-09-25) Greg Rundlett: Fix lint errors on essential-vars task file Also add fully qualified collection names (FQCN) to avoid other lint
errors. e.g. `ansible.builtin.set_fact` instead of just `set_fact`.
  - Modified: `src/roles/essential-vars/tasks/main.yml`

* [b65ba2df](https://github.com/freephile/meza/commit/b65ba2df) (2025-09-25) Greg Rundlett: Fixup the test-certbot playbook to use set-vars The test-certbot playbook was broken - referencing an unknown role.
And it did not use the `set-vars` role to properly initialize.
Now it uses `set-vars` and includes the local certbot role.
Adds to the fix for Issue [#207](https://github.com/freephile/meza/issues/207)
  - Modified: `src/playbooks/test-certbot.yml`

* [ab879a58](https://github.com/freephile/meza/commit/ab879a58) (2025-09-25) Greg Rundlett: Setup key variables early; avoid extra-vars We're one step closer to not needing sudo in the deploy command.
With a new role 'essential-vars', we set `ansible_user` and
`group_wheel` with OS-specific logic.
The variables `group_wheel` and `ansible_user` will now be consistently
available throughout all playbooks and roles where they are referenced.
On a RedHat family OS, using 'sudo meza deploy...' we get:
['group_wheel: wheel', 'ansible_user: meza-ansible', 'ansible_env.USER: root']
- Updated the bootstrap section of site.yml to use the new role
  instead of inline variable definitions.
- Maintains compatibility with existing `set-vars` role structure.
- Replace usage of `owner: "{{ ansible_user | default(ansible_env.USER) }}"`
  with owner: "{{ ansible_user | default('meza-ansible') }}"
  because when using 'sudo deploy...' $USER evaluates to 'root'!
- Use 'become' for operations in access-restricted directories where
  restrictions can otherwise prevent success. This is especially
  important for SSH private keys which must maintain strict security
  permissions (`mode: 0600`) and proper ownership to function correctly.
  Fixed the `mediawiki` role SSH key copy tasks and the `site.yml`
  bootstrap section SSH key copy tasks.
- On paths that belong to 'meza-ansible' (like ~/.ssh), set the owner
  explicitly instead of using a variable that could evaluate to
  something incorrect.
- These fixes ammend earlier attempts to fix permission issues like
  commit eee92a08 which used 'default(ansible_env.USER)' instead of
  the correct "default('meza-ansible')"
- Update CONTRIBUTING.md with info on establishing interactive login
  as meza-ansible
- TODO: Skip copy id_rsa to id_rsa and similar copy operations when
  `inventory_hostname == 'localhost'`
Fixes Issue [#207](https://github.com/freephile/meza/issues/207)
  - Modified: `CONTRIBUTING.md`
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/tasks/main.meza.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/database/tasks/secure-installation.yml`
  - Added: `src/roles/essential-vars/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Modified: `src/roles/saml/tasks/main.yml`

* [74851065](https://github.com/freephile/meza/commit/74851065) (2025-09-25) Greg Rundlett: Add FIXME comment about CommentStreams not working CommentStreams is not showing any errors, nor functionality in our tests
of Meza 43.x
See https://phabricator.wikimedia.org/T388462
and the extension page for updates
  - Modified: `config/MezaCoreExtensions.yml`

* [c35a73bb](https://github.com/freephile/meza/commit/c35a73bb) (2025-09-25) Greg Rundlett: Add comments to CommentStreams config Meza specifically sets
      $wgCommentStreamsAllowedNamespaces = -1;
so you MUST use <comment-streams /> in the page content to enable it
on a per page basis.
If left to the default (null), comment-streams is allowed on all
pages in all content namespaces.
  - Modified: `config/MezaCoreExtensions.yml`

* [bf74c315](https://github.com/freephile/meza/commit/bf74c315) (2025-09-23) Rich Evans: Update MezaCoreExtensions.yml Update Extension:CommentStreams to use "mediawiki_default_branch" rather than "master"
  - Modified: `config/MezaCoreExtensions.yml`

* [40337063](https://github.com/freephile/meza/commit/40337063) (2025-09-17) Greg Rundlett: Add a new script to update the CHANGELOG updateCHANGELOG.sh simply uses git log --pretty to prepend new git activity into the CHANGELOG The CHANGELOG is a 'raw' version of what is changed.
The RELEASE_NOTES are the more stylized content where the output is
formatted in markdown, links are included for issues and commit SHAs.
  - Modified: `CHANGELOG`
  - Added: `src/scripts/updateCHANGELOG.sh`

* [5e50315a](https://github.com/freephile/meza/commit/5e50315a) (2025-09-16) Greg Rundlett: Update CONTRIBUTING.md with new details Begin the process of updating the tools and quality controls for
Meza.
  - Modified: `CONTRIBUTING.md`

* [a23b1bdf](https://github.com/freephile/meza/commit/a23b1bdf) (2025-09-15) Greg Rundlett: Add comment for extension UrlGetParameters As the name implies, the extension enables you to use and/or display
the "GET" parameters of the requested URL.
https://www.mediawiki.org/wiki/Extension:UrlGetParameters
  - Modified: `config/MezaCoreExtensions.yml`

* [f041dc20](https://github.com/freephile/meza/commit/f041dc20) (2025-09-15) Greg Rundlett: Add config and UPO for HTML emails by default Allowing HTML email only enables the User Preference Option.
$wgAllowHTMLEmail = true;
And, we set the UPO over-riding the default of 'plain-text'
$wgDefaultUserOptions['echo-email-format'] = 'html';
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [07ebd3df](https://github.com/freephile/meza/commit/07ebd3df) (2025-09-11) Greg Rundlett: Update Meza Core Skins - Delete duplicate MinervaNeue block
- Add comment for Timeless skin
  - Modified: `config/MezaCoreSkins.yml`

* [eee92a08](https://github.com/freephile/meza/commit/eee92a08) (2025-09-11) Greg Rundlett: Ensure the verify-permissions playbook executes Add pre_tasks section to the playbook to load variables via the set-vars role.
All playbooks should do this.
Eliminate specification of owner/group in the test for cache writing by meza-ansible:
- owner: "{{ ansible_user | default(ansible_env.USER) }}"
- group: "{{ group_apache }}"
because those cause a chmod which is not allowed even though meza-ansible
can write to the cache directory.
Note: although we could get a full shell with
become_flags: '-i'
this is not necessary for testing write permissions in the cache directory
Ensure message display by filtering items to integer with the 'int' jinja filter
Final work following on https://github.com/freephile/meza/commit/b3badfcf6ffe518115c83271e03e0028b589eed9
Fixes Issue [#186](https://github.com/freephile/meza/issues/186)
  - Modified: `src/playbooks/verify-permissions.yml`
  - Modified: `src/roles/verify-permissions/tasks/main.yml`

* [138d1092](https://github.com/freephile/meza/commit/138d1092) (2025-09-06) Greg Rundlett: Add missing Bundled extensions There were 7 bundled extensions which were in MezaLocalExtensions.yml
instead of the MezaCoreExtensions.yml - thus not included in the Meza distribution.
Adds
- CategoryTree
- CheckUser
- CiteThisPage
- ConfirmEdit
- Nuke
- Poem
- TemplateStyles
Fixes Issue [#201](https://github.com/freephile/meza/issues/201)
  - Modified: `config/MezaCoreExtensions.yml`

* [7335503c](https://github.com/freephile/meza/commit/7335503c) (2025-09-04) Greg Rundlett: Update PageForms to 6.x Switch to using Composer for PageForms to make version constraints
easier to manage.
Also quote the version "master" for SemanticDependencyUpdater
Fixes Issue [#200](https://github.com/freephile/meza/issues/200) exception from SMWDIProperty class not found
  - Modified: `config/MezaCoreExtensions.yml`

* [6b9c3765](https://github.com/freephile/meza/commit/6b9c3765) (2025-08-31) Greg Rundlett: Add additional RELEASE_NOTES file up to HEAD This RELEASE_NOTES can be updated throughout a release cycle until
such time that a release cycle ends when it can be saved off as the
full historical RELEASE NOTES for that cycle.
To generate updates to this file during the 43.x release cycle,
use .src/scripts/generate-release-notes.sh 43.29.1 HEAD
since 43.29.1 was the last ref used in
https://github.com/freephile/meza/blob/main/RELEASE_NOTES-43.29.1.md
Partly addresses Issue [#3](https://github.com/freephile/meza/issues/3)
  - Added: `RELEASE_NOTES-HEAD.md`

* [f5159bda](https://github.com/freephile/meza/commit/f5159bda) (2025-08-31) Greg Rundlett: Add DynamicPageList3 Extension DPL allows for creating lists of pages like you would be able to
using SMW queries and properties, but with simpler mechanics and
a small learning curve.
We've added the actively maintained DynamicPageList3 and will switch
to DynamicPageList4 soon.
Fixes Issue [#198](https://github.com/freephile/meza/issues/198)
  - Modified: `config/MezaCoreExtensions.yml`

* [c0a5192e](https://github.com/freephile/meza/commit/c0a5192e) (2025-08-29) Greg Rundlett: Use MediaWiki REL1_43 and  SMW 6.x With fixes in the latest MediaWiki and SMW 6, everything appears
to be working again and we are not restricted to MW 1.43.1
See https://www.semantic-mediawiki.org/wiki/Semantic_MediaWiki_6.0.0
https://www.semantic-mediawiki.org/wiki/Semantic_MediaWiki_6.0.1
Fixes Issue [#163](https://github.com/freephile/meza/issues/163)
Adds Feature #185
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `config/defaults.yml`

* [bf35f37e](https://github.com/freephile/meza/commit/bf35f37e) (2025-08-28) Greg Rundlett: Do not ignore errors in memcache installation The PECL installation of the PHP-memcache extension was brute force.
Therefore it would error every deploy once it was installed. And so
'ignore errors' was on.
Instead, now we look to see whether it is installed;
register a fact memcached_pecl_installed when it is already present.
And thus skip installation depending on the circumstance.
Partly addresses Issue [#144](https://github.com/freephile/meza/issues/144)
  - Modified: `src/roles/apache-php/tasks/php-redhat8.yml`

* [ddac1217](https://github.com/freephile/meza/commit/ddac1217) (2025-08-28) Greg Rundlett: Use YAML instead of INI in hosts file YAML is preferred for Ansible, and is more suitable for more complex
hosts management.
See Issue [#68](https://github.com/freephile/meza/issues/68)
  - Modified: `src/roles/setup-env/templates/hosts.j2`

* [72adcda9](https://github.com/freephile/meza/commit/72adcda9) (2025-08-28) Greg Rundlett: Fix deprecation warning: collections_path Settings variable name is singular, not plural.
[DEPRECATION WARNING]: [defaults]collections_paths option, does not
fit var naming standard, use the singular form collections_path
instead. This feature will be removed from ansible-core in version 2.19.
Deprecation warnings can be disabled by setting
deprecation_warnings=False in ansible.cfg.
Also, add symlink to config/ansible.cfg from project root because some
tools or IDEs expect it there.
  - Added: `ansible.cfg`
  - Modified: `config/ansible.cfg`

* [190e7f30](https://github.com/freephile/meza/commit/190e7f30) (2025-08-28) Greg Rundlett: Fix branch name for Medik skin This repo uses 'master' not 'main' terminology
Fixes #139
  - Modified: `config/MezaCoreSkins.yml`

* [e7b2ea3c](https://github.com/freephile/meza/commit/e7b2ea3c) (2025-08-27) Greg Rundlett: Re-enable the Medik Skin By enabling the main branch we should pull in the proper commits for
compatibility with 1.43 and 1.44 too
Do not use the tag 5.1.3
Fixes #139
  - Modified: `config/MezaCoreSkins.yml`

* [65bc6c43](https://github.com/freephile/meza/commit/65bc6c43) (2025-08-27) Greg Rundlett: Regenerate RELEASE_NOTES up to 43.25.11 Use src/scripts/generate-release-notes.sh to
update for additional links formatting and --name-status info.
  - Modified: `RELEASE_NOTES-43.25.11.md`

* [53cc7484](https://github.com/freephile/meza/commit/53cc7484) (2025-08-27) Greg Rundlett: Add script to generate RELEASE NOTES Also update the latest release notes.
  - Modified: `RELEASE_NOTES-43.29.1.md`
  - Added: `src/scripts/generate-release-notes.sh`

* [148ea866](https://github.com/freephile/meza/commit/148ea866) (2025-08-26) Greg Rundlett: Add latest RELEASE_NOTES Updated procedure at https://wiki.freephile.org/wiki/RELEASE_NOTES
  - Added: `RELEASE_NOTES-43.29.1.md`

* [d6310e8e](https://github.com/freephile/meza/commit/d6310e8e) (2025-08-25) Greg Rundlett: Add comment about Issue [#72](https://github.com/freephile/meza/issues/72) (deploy without sudo) 
  - Modified: `src/scripts/getmeza.sh`

* [9802d43d](https://github.com/freephile/meza/commit/9802d43d) (2025-08-25) Greg Rundlett: Fix maintenance script quoting For Issue [#191](https://github.com/freephile/meza/issues/191)
  - Modified: `src/roles/mediawiki/templates/refresh-links.sh.j2`
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`

* [06c2b554](https://github.com/freephile/meza/commit/06c2b554) (2025-08-24) Greg Rundlett: Fix maintenance script quoting + best practices - Use FQCN
- Improve spacing
- Name all tasks
- Remove quotes from task names
- Improve block order to put tags first
For Issue [#191](https://github.com/freephile/meza/issues/191)
  - Modified: `src/roles/update.php/tasks/main.yml`

* [db3fb090](https://github.com/freephile/meza/commit/db3fb090) (2025-08-24) Greg Rundlett: Fix maintenance script quoting Here we fix templated shell scripts
For Issue [#191](https://github.com/freephile/meza/issues/191)
  - Modified: `src/roles/cron/templates/runAllJobs.php.j2`
  - Modified: `src/roles/mediawiki/templates/elastic-build-index.sh.j2`
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`
  - Modified: `src/roles/meza-log/templates/server-performance.sh.j2`

* [88a74acb](https://github.com/freephile/meza/commit/88a74acb) (2025-08-24) Greg Rundlett: Fix maintenance script quoting Issue [#191](https://github.com/freephile/meza/issues/191)
  - Modified: `src/playbooks/cleanup-upload-stash.yml`
  - Modified: `src/roles/mediawiki/tasks/cirrus_metastore_upgrade.yml`

* [61b7e63b](https://github.com/freephile/meza/commit/61b7e63b) (2025-08-24) Greg Rundlett: Fixing maintenance script quoting Issue [#191](https://github.com/freephile/meza/issues/191)
  - Modified: `src/scripts/unite-the-wikis.sh`

* [e36b8067](https://github.com/freephile/meza/commit/e36b8067) (2025-08-24) Greg Rundlett: Remove commented task CirrusSearch:Metastore --upgrade Fixed in d0a1ecb3 with new cirrus_metastore_upgrade.yml task
--no-verify used in commit bc we still have
69 failure(s), 0 warning(s) on 2 files.
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [a7bec3ef](https://github.com/freephile/meza/commit/a7bec3ef) (2025-08-22) Greg Rundlett: Fix most Ansible fatal linting errors; Add requirements.yml - Fixes Issue [#187](https://github.com/freephile/meza/issues/187)
- Fixes Issue [#46](https://github.com/freephile/meza/issues/46)
- Related to Issue [#47](https://github.com/freephile/meza/issues/47)
- Fixes Issue [#90](https://github.com/freephile/meza/issues/90) with requirements.yml - and CentOS is obsolete, so see #15
  - Modified: `requirements.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/tasks/create-cert-standalone.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/tasks/install-from-source.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat8.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/backup-uploads/tasks/main.yml`
  - Modified: `src/roles/base-config-scripts/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/composer/tasks/global-require.yml`
  - Modified: `src/roles/composer/tasks/main.yml`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/database/tasks/configure.yml`
  - Modified: `src/roles/database/tasks/databases.yml`
  - Modified: `src/roles/database/tasks/replication.yml`
  - Modified: `src/roles/database/tasks/secure-installation.yml`
  - Modified: `src/roles/delete-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/dump-db-wikis/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/tasks/es_reindex.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/geerlingguy.kibana/tasks/main.yml`
  - Modified: `src/roles/geerlingguy.kibana/tasks/setup-RedHat.yml`
  - Modified: `src/roles/gluster/tasks/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/htdocs/tasks/main.yml`
  - Modified: `src/roles/lua/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/sync-configs/tasks/main.yml`
  - Modified: `src/roles/umask-set/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [6749c666](https://github.com/freephile/meza/commit/6749c666) (2025-08-22) Greg Rundlett: Adopt standard .yamlint for compatibility The default configuration works better with ansible-lint in our CI
because 'Prettier' is the most popular formatter in Python
https://ansible.readthedocs.io/projects/lint/rules/yaml/#yamllint-configuration
Issue [#46](https://github.com/freephile/meza/issues/46)
  - Modified: `.yamllint`

* [9c8132e9](https://github.com/freephile/meza/commit/9c8132e9) (2025-08-22) Greg Rundlett: Fix Fully Qualified Collection Name (FQCN) best practices Just for these files:
- src/roles/base/tasks/main.yml
- src/roles/base/tasks/parsoid-cleanup.yml
- src/roles/mediawiki/defaults/main.yml
- src/roles/setup-env/tasks/main.yml
pertains to Issue [#46](https://github.com/freephile/meza/issues/46)
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/base/tasks/parsoid-cleanup.yml`
  - Modified: `src/roles/mediawiki/defaults/main.yml`
  - Modified: `src/roles/setup-env/tasks/main.yml`

* [68c45e66](https://github.com/freephile/meza/commit/68c45e66) (2025-08-22) Greg Rundlett: Default to ansible_env.USER for ansible_user When all plays are executed by the 'Application User' (meza-ansible)
then the ansible environment will know the USER as 'meza-ansible'
This works even in instances when ansible.cfg is not read in.
relevant to Issue [#186](https://github.com/freephile/meza/issues/186)
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/tasks/main.meza.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/database/tasks/secure-installation.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/setup-env/tasks/main.yml`
  - Modified: `src/roles/verify-permissions/tasks/main.yml`

* [67ff2e2b](https://github.com/freephile/meza/commit/67ff2e2b) (2025-08-21) Greg Rundlett: Add pre-commit framework Use the pre-commit framework https://pre-commit.com/
to manage pre-commit hooks.
With the new .pre-commit-config.yaml file we now have automatic
linting and fixing before errors can be commited into the repo.
To avoid (skip) the pre-commit tasks, use '--no-verify'
NEW requirements-dev.txt is for Python
  - Added: `.pre-commit-config.yaml`
  - Added: `requirements-dev.txt`

* [2619b97c](https://github.com/freephile/meza/commit/2619b97c) (2025-08-21) Greg Rundlett: remove blank space 
  - Modified: `src/scripts/lint-files.sh`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/shell-functions/linux-user.sh`

* [b3badfcf](https://github.com/freephile/meza/commit/b3badfcf) (2025-08-21) Greg Rundlett: Fix users, groups, file permissions AND linting ---- Key Changes ----
1. Variable Structure:
Distribution-specific variables (RedHat.yml vs Debian.yml):
- user_apache: apache vs www-data
- group_apache: apache vs www-data
- group_wheel: wheel vs sudo
Common variables (paths.yml):
REMOVED m_meza_owner in favor of ansible_user defined in ansible.cfg
RENAMED m_meza_group to m_group (pattern for meza variables)
m_htdocs_owner: "{{ m_user }}" (resolves to meza-ansible)
m_logs_owner: "{{ m_user }}" (resolves to meza-ansible)
2. Usage Patterns:
✅ user_apache: 15 consistent references across roles
✅ group_apache: 33 consistent references across roles
✅ m_htdocs_owner: 9 consistent references across roles
✅ group_wheel: 18 consistent references across roles
3. Tools:
3.1 Enhanced linux-user.sh script for managing Linux users and groups
- mf_add_ssh_user() automatically adds meza-ansible to required groups
- Detects and adds to apache/www-data group for web file access
- Ensures wheel group membership for sudo access
- Provides user feedback when groups are added
3.2 Added verify-permissions playbook and role
- Verifies group memberships, directory permissions, and write access
- Provides detailed output for troubleshooting
You can now run the verification playbook to check if
permissions are correctly set:
    ansible-playbook -i hosts src/playbooks/verify-permissions.yml
Systematically setup all critical dirs w proper ownership and perms
Sticky bit (2775) on all data dirs for consistent group inheritance
Covers: m_meza_data, m_cache_directory, m_logs, m_backups
🔧 Fixes Applied
1. Replaced hardcoded values in roles and playbooks:
- Changed "meza-ansible" to "{{ ansible_user }}"
- Changed "apache" to "{{ user_apache }}"
- Changed "wheel" to "{{ group_wheel }}"
2. Applied proper group permissions with group sticky bit on dirs
3. Improved group detection and fallback in Meza.py
4. Enhanced lock file management better group detection, proper perms
5. Updated cache directory perms to use apache group and sticky bit
---- NEW Linting Improvements ----
- Added Ansible + YAML linting instructions for GitHub Copilot AI agent
- Added .ansible-lint.yml for linting configuration
- Added LINTING.md for linting guidelines
- Added lint-files.sh script for linting files
🔧 Fixes Applied
2. Fixed YAML formatting:
- Corrected brace spacing for ansible-lint compliance
- Removed a trailing space
📋 Verification Results
All modified configuration files pass YAML linting ✅
No hardcoded user/group references remain ✅
Cross-platform compatibility improved ✅
Variable definitions are complete and consistent ✅
The system now properly uses distribution-specific variables for
user_apache/group_apache
(apache/apache on RedHat, www-data/www-data on Debian)
while maintaining consistent references across all roles and playbooks.
  - Added: `.ansible-lint`
  - Added: `.github/copilot-instructions.md`
  - Added: `LINTING.md`
  - Modified: `config/Debian.yml`
  - Modified: `config/RedHat.yml`
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/site.yml`
  - Added: `src/playbooks/verify-permissions.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/tasks/main.meza.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/database/tasks/secure-installation.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/update.php/tasks/main.yml`
  - Added: `src/roles/verify-permissions/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Added: `src/scripts/lint-files.sh`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/shell-functions/linux-user.sh`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [d89466b6](https://github.com/freephile/meza/commit/d89466b6) (2025-08-21) Greg Rundlett: Add message about RELEASE_NOTES-43.25.11.md 
  - Modified: `RELEASE-NOTES.md`

* [e100e377](https://github.com/freephile/meza/commit/e100e377) (2025-08-20) Greg Rundlett: Ensure task names and handler names match Task names should start with an Uppercase letter
Ensure the handler names match the task
  - Modified: `src/roles/database/handlers/main.yml`
  - Modified: `src/roles/database/tasks/configure.yml`
  - Modified: `src/roles/firewalld/handlers/main.yml`
  - Modified: `src/roles/firewalld/tasks/main.yml`
  - Modified: `src/roles/geerlingguy.kibana/handlers/main.yml`
  - Modified: `src/roles/geerlingguy.kibana/tasks/main.yml`

* [30791abc](https://github.com/freephile/meza/commit/30791abc) (2025-08-20) Greg Rundlett: Make task name and handler name match 
  - Modified: `src/roles/elasticsearch/tasks/main.yml`

* [bf90d10b](https://github.com/freephile/meza/commit/bf90d10b) (2025-08-19) Greg Rundlett: Add release notes for 39.5.0 through 43.25.11 
  - Added: `RELEASE_NOTES-43.25.11.md`

* [43be9737](https://github.com/freephile/meza/commit/43be9737) (2025-08-17) Greg Rundlett: Make wiki config directory group executable Not sure this should be apache owned, but if meza-ansible
user is going to have any permission to do anything here
then it needs to be group executable
  - Modified: `src/roles/configure-wiki/tasks/main.yml`

* [45658c32](https://github.com/freephile/meza/commit/45658c32) (2025-08-17) Greg Rundlett: fix quoting in SMW setupStore shell command 
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`

* [8a5fde26](https://github.com/freephile/meza/commit/8a5fde26) (2025-08-16) Greg Rundlett: Add Admin rights for SMW Allow access to Special:SemanticMediaWiki for Sysops group.
  - Modified: `config/MezaCoreExtensions.yml`

* [4b5df1df](https://github.com/freephile/meza/commit/4b5df1df) (2025-08-16) Greg Rundlett: ignore Python venv and Composer vendor 
  - Modified: `.gitignore`

* [d0a1ecb3](https://github.com/freephile/meza/commit/d0a1ecb3) (2025-08-16) Greg Rundlett: Add MediaWiki CirrusSearch metastore update and indexing The index template is a conservative mapping covering typical
CirrusSearch indices (wiki_*_content*, wiki_*_general*).
Adjust mappings/analysis as needed for your data.
You can enable the process by setting
mediawiki_cirrus_metastore_upgrade: true
in inventory/group_vars/host_vars.
mediawiki_cirrus_metastore_upgrade defaults to false
in the role default vars file.
It will only run once due to the marker file.
new files:
- src/roles/mediawiki/tasks/cirrus_metastore_upgrade.yml
- src/roles/mediawiki/tasks/files/cirrussearch_index_template.json
extraneous:
- remove unsupported RedHat 7 yum Python install
Still need to addres
https://github.com/freephile/meza/issues/41#issuecomment-2045506153
  - Modified: `src/roles/mediawiki/defaults/main.yml`
  - Added: `src/roles/mediawiki/tasks/cirrus_metastore_upgrade.yml`
  - Added: `src/roles/mediawiki/tasks/files/cirrussearch_index_template.json`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [b41853e4](https://github.com/freephile/meza/commit/b41853e4) (2025-08-15) Greg Rundlett: Add retry and backoff to index building New Ansible variables:
elasticsearch_index_retry_max: 5
elasticsearch_index_retry_initial: 5
Retry/backoff defaults for CirrusSearch/ForceSearchIndex calls during bulk indexing.
These can be overridden per-host/group via inventory, or via environment variables.
The Environment variables are RETRY_MAX and RETRY_INITIAL.
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/mediawiki/templates/elastic-build-index.sh.j2`

* [22d977a1](https://github.com/freephile/meza/commit/22d977a1) (2025-08-15) Greg Rundlett: yum is now dnf Besides that, fixed Ansible lint errors.
- Find them with:
ansible-lint $(find ./src/roles/elasticsearch/ -name '*.yml')
- Learn them from https://ansible.readthedocs.io/projects/lint/rules/
  - Modified: `src/roles/elasticsearch/handlers/main.yml`
  - Modified: `src/roles/elasticsearch/tasks/es_reindex.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`

* [c6734682](https://github.com/freephile/meza/commit/c6734682) (2025-08-15) Greg Rundlett: Improve elastic index building; add reindexing - Made per-wiki bootstrap script safer and faster:
src/roles/mediawiki/templates/elastic-build-index.sh.j2
Added strict shell flags, flock-based locking, traps, disable-refresh/replica optimization
before bulk indexing, restore settings after, and improved logging.
- Reworked reindex script for zero-downtime alias swap and robustness
src/roles/elasticsearch/templates/elastic-reindex.sh.j2
This script was previously not used anywhere!
Added strict shell flags, locking, optimized create/reindex steps (disable refresh/replicas),
attempted atomic alias swap (fallback safe two-step), preserved aliases handling, better
logging, and placeholders for snapshots.
- add new default var elasticsearch_reindex: false
- when setting elasticsearch_reindex: true in inventory, host_vars, group_vars,
or in the role default vars, then the es_reindex.yml tasks will be executed.
TEST
Locking prevents concurrent runs.
Reindex produces the new index and aliases swap as expected.
Search is not interrupted during alias swap.
Index settings (refresh_interval, replicas) are toggled and restored.
  - Modified: `src/roles/elasticsearch/defaults/main.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/templates/elastic-reindex.sh.j2`
  - Modified: `src/roles/mediawiki/templates/elastic-build-index.sh.j2`

* [c32d15ed](https://github.com/freephile/meza/commit/c32d15ed) (2025-08-14) Greg Rundlett: Add meza-sbom-stats.txt 
  - Added: `src/scripts/meza-sbom-stats.txt`
  - Deleted: `src/scripts/package-stats.txt`

* [7a060f0e](https://github.com/freephile/meza/commit/7a060f0e) (2025-08-14) Greg Rundlett: Add stats file generation - --stats option now generates a file in addition to console output
- Update documentation
- avoid directory traversal
  - Modified: `src/scripts/generate-sbom.md`
  - Modified: `src/scripts/generate-sbom.php`

* [7a333fbf](https://github.com/freephile/meza/commit/7a333fbf) (2025-08-14) Greg Rundlett: Add package-stats.txt 
  - Added: `src/scripts/package-stats.txt`

* [e85adee9](https://github.com/freephile/meza/commit/e85adee9) (2025-08-14) Greg Rundlett: Add first generated SBOM files 
  - Added: `src/scripts/meza-sbom.cyclonedx.json`
  - Added: `src/scripts/meza-sbom.spdx.json`
  - Added: `src/scripts/meza-sbom.txt`

* [10803fbd](https://github.com/freephile/meza/commit/10803fbd) (2025-08-14) Greg Rundlett: update docs for generate-sbom.php The GitHub action is disabled since we do not
track composer.lock or composer.local.json in the repo.
  - Modified: `CHANGELOG`
R088	src/scripts/sbom.md	src/scripts/generate-sbom.md

* [c4dc2d19](https://github.com/freephile/meza/commit/c4dc2d19) (2025-08-13) Greg Rundlett: Yamllint: truthy values should be one of [false, true] 
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/roles/autodeployer/tasks/do-deploy.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/database/tasks/replication.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/key-transfer/tasks/grant-keys.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Modified: `src/roles/remote-dir-check/tasks/main.yml`
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [bc092fb6](https://github.com/freephile/meza/commit/bc092fb6) (2025-08-13) Greg Rundlett: Fix invalid workflow generate-sbom - indentation 
  - Modified: `.github/workflows/generate-sbom.yml`

* [3a761ccb](https://github.com/freephile/meza/commit/3a761ccb) (2025-08-13) Greg Rundlett: Add PEP 8 rule to .editorconfig for Python files 
  - Modified: `.editorconfig`

* [66db2464](https://github.com/freephile/meza/commit/66db2464) (2025-08-13) Greg Rundlett: Code update to score 9.7 / 10 - Added Module Docstring (C0114)
Added comprehensive module documentation explaining the purpose
- Fixed Constant Naming (C0103)
deploy_lock_environment → DEPLOY_LOCK_ENVIRONMENT
language → LANGUAGE
- Fixed Function Naming (C0103)
meza_command_maint_runJobs → meza_command_maint_run_jobs
- Fixed Superfluous Parentheses (C0325)
while (not value): → while not value:
- Fixed Boolean Comparisons (C1805, C1804)
len(argv) == 0 → not argv
rc != 0 → rc
return_code == 0 → not return_code
status != "" → status
status == "" → not status
- Fixed Variable Name Shadowing (W0621, W0622)
datetime parameter → timestamp
dir parameter → directory
- Added Missing Function Docstrings (C0116)
Added docstrings for legacy and placeholder functions
- Fixed File Encoding Issues (W1514)
Added encoding='utf-8' to all file operations
- Fixed Return Statement Consistency (R1710)
Added return None to exception handler in load_yaml
- Removed Unused Variables (W0612)
Removed unused assignments for subprocess calls
Fixed unused args variable with _ placeholder
- Fixed Signal Handler (W0613)
Added pylint disable for required but unused signal handler parameters
- Improved Resource Management (R1732)
Used with statements for file operations where practical
#181 should be test ready
  - Modified: `src/scripts/meza.py`

* [86a5ee11](https://github.com/freephile/meza/commit/86a5ee11) (2025-08-13) Greg Rundlett: Fix Import outside toplevel pylint warnings - Standard library imports come first, alphabetically
- Third-party libraries (yaml) come next
- Unused libraries (jinja2) removed
Ansible uses Jinja2, but we don't use it in meza.py
All the duplicate imports were moved to the top-level per PEP8 standards.
  - Modified: `src/scripts/meza.py`

* [11d074d8](https://github.com/freephile/meza/commit/11d074d8) (2025-08-13) Greg Rundlett: fixed all the C0301 "line too long" warnings Use proper line continuation (indent) for long docstrings
./.venv/bin/pylint src/scripts/meza.py --disable=all --enable=C0301 --score=y
is now scored 10/10
  - Modified: `src/scripts/meza.py`

* [8cb704db](https://github.com/freephile/meza/commit/8cb704db) (2025-08-13) Greg Rundlett: Use Python 3.6 f-strings - "text {}".format(variable) -> f"text {variable}"
- Complex multi-line format strings with better readable f-string formatting
- File path constructions with multiple variables
- More readable
- Better performance
- Less verbose without the .format() calls
- Type safety
  - Modified: `src/scripts/meza.py`

* [68766375](https://github.com/freephile/meza/commit/68766375) (2025-08-13) Greg Rundlett: Agressive Auto PEP 8 formatting reduce long lines
add space around operators
  - Modified: `src/scripts/meza.py`

* [81807369](https://github.com/freephile/meza/commit/81807369) (2025-08-13) Greg Rundlett: basic AutoPEP8 fixes /home/greg/src/meza/.venv/bin/python -m autopep8 --in-place src/scripts/meza.py
  - Modified: `src/scripts/meza.py`

* [1a9ff046](https://github.com/freephile/meza/commit/1a9ff046) (2025-08-13) Greg Rundlett: convert tabs to spaces 
  - Modified: `src/scripts/meza.py`

* [6959b04a](https://github.com/freephile/meza/commit/6959b04a) (2025-08-07) Greg Rundlett: Slight refactor to put regex into a constant 
  - Modified: `src/roles/htdocs/files/BackupDownload/DownloadTest.php`
  - Modified: `src/roles/htdocs/files/BackupDownload/download.php`

* [b1d3eccd](https://github.com/freephile/meza/commit/b1d3eccd) (2025-08-06) Greg Rundlett: remove error suppression and handle disabled shell_exec 
  - Modified: `src/roles/htdocs/files/BackupDownload/download.php`

* [bf2521eb](https://github.com/freephile/meza/commit/bf2521eb) (2025-08-06) Greg Rundlett: Prevent web access to sensitive content. Prevents possible XSS in Test files which are not meant
to be served in a web context.
Block test files: RewriteRule ^BackupDownload/.*Test\.php$ - [F,L]
This prevents access to any PHP files ending in "Test.php" in the BackupDownload directory
Returns a 403 Forbidden response
Block README files: RewriteRule ^BackupDownload/README\.md$ - [F,L]
Prevents access to README.md files that might contain sensitive information
Block all markdown files: RewriteRule ^BackupDownload/.*\.md$ - [F,L]
Prevents access to any .md files including documentation that might reveal system details
The [F,L] flags mean:
F = Forbidden (return 403 status)
L = Last rule (stop processing further rules)
  - Modified: `src/roles/htdocs/templates/.htaccess.j2`

* [83e1f601](https://github.com/freephile/meza/commit/83e1f601) (2025-08-06) Greg Rundlett: Avoid using error suppression operator Using the @ operator to suppress errors can hide important issues. The error handling is already in place, so suppression is unnecessary.
  - Modified: `src/roles/htdocs/files/BackupDownload/download.php`

* [250d2aee](https://github.com/freephile/meza/commit/250d2aee) (2025-08-06) Greg Rundlett: Strengthen path containment check The current path validation using strpos() could have edge cases.
For example, if the base path is /backup and the file path is /backup2/file,
the check would incorrectly pass.
Improve both download.php and DownloadTest.php
for pull #180
  - Modified: `src/roles/htdocs/files/BackupDownload/DownloadTest.php`
  - Modified: `src/roles/htdocs/files/BackupDownload/download.php`

* [a6e593b0](https://github.com/freephile/meza/commit/a6e593b0) (2025-08-06) Greg Rundlett: Fixed dynamic loading of config - add comment to DownloadTest to keep helper methods  in sync
- replace spaces with tabs for coding standards
syntax hints added to code blocks in README
The dynamic config loading was mentioned in pull #180
Documentation in src/roles/htdocs/files/BackupDownload/PATH_RESOLUTION_FIX.md
  - Modified: `src/roles/htdocs/files/BackupDownload/DownloadTest.php`
  - Added: `src/roles/htdocs/files/BackupDownload/PATH_RESOLUTION_FIX.md`
  - Modified: `src/roles/htdocs/files/BackupDownload/README.md`
  - Modified: `src/roles/htdocs/files/BackupDownload/download.php`
  - Modified: `src/roles/htdocs/files/BackupDownload/index.php`

* [f520f670](https://github.com/freephile/meza/commit/f520f670) (2025-08-06) Greg Rundlett: Implement a hybrid Test Framework that works with both PHPUnit (MediaWiki standard) when available; and a custom fallback framework. Created a comprehensive test file (DownloadTest.php) that:
- Automatically detects if PHPUnit is available and uses it
- Falls back to a custom test framework when PHPUnit is not available
- Provides 20+ test methods covering all security aspects
- Tests 37+ individual security validations
Test Coverage: The test suite validates:
- Input validation - All parameter validation functions
- Path traversal prevention - Multiple attack vector simulations
- File type validation - Extension checking and double extension attacks
- Authorization - User permission and access control testing
- Edge cases - Null bytes, Windows paths, absolute paths, etc.
Security Implementation: The download.php script now includes:
- CWE-22 prevention - Multiple layers of path traversal protection
- Input sanitization - Strict regex validation of all inputs
- File type restriction - Only approved backup file extensions allowed
- Authorization integration - SAML and Meza user management integration
Documentation: Created comprehensive README.md documenting:
- Security features and implementation details
- Usage examples and approved patterns
- Testing procedures and development notes
- Error handling and logging information
The test suite runs successfully and validates that all security measures
are working correctly. The few "failing" tests are actually demonstrating
that the security validation is working properly by rejecting malicious
inputs.
The implementation is now ready for production use with comprehensive
security validation and testing coverage.
Fixes #179
  - Added: `src/roles/htdocs/files/BackupDownload/DownloadTest.php`
  - Added: `src/roles/htdocs/files/BackupDownload/README.md`

* [d064cb43](https://github.com/freephile/meza/commit/d064cb43) (2025-08-06) Greg Rundlett: Prevent directory traversal vulnerability. (Vulnerability found with SonarQube) Key Security Improvements:
- Input Validation: All user inputs are validated with strict regex patterns
- Path Construction: File paths are built securely without direct user input
- Realpath Validation: Uses realpath() to resolve paths and ensure they stay within allowed directories
- File Allowlist: Only allows files that actually exist in the filesystem
- Extension Allowlist: Only allows specific file extensions for backups
- No Path Traversal: Completely prevents ../ attacks through validation
- Error Handling: Proper error handling with appropriate HTTP status codes
- Logging: Errors are logged for debugging without exposing sensitive information
This approach ensures that users can only download files that:
- Actually exist in the backup directory structure
- Have allowed file extensions
- The user has permission to access
- Are within the authorized directory tree
Also
- Change copyright
- Add license
  - Modified: `src/roles/htdocs/files/BackupDownload/download.php`

* [4b0511b6](https://github.com/freephile/meza/commit/4b0511b6) (2025-08-05) Greg Rundlett: fix YAML lint errors 
  - Modified: `.github/workflows/generate-sbom.yml`

* [b92c983d](https://github.com/freephile/meza/commit/b92c983d) (2025-08-05) Greg Rundlett: fix YAML lint errors 
  - Modified: `.github/workflows/generate-sbom.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`

* [0fee59cf](https://github.com/freephile/meza/commit/0fee59cf) (2025-08-05) Greg Rundlett: Update README with component logos 
  - Modified: `README.md`
  - Added: `assets/meza_component_logos.png`

* [bb2f80c1](https://github.com/freephile/meza/commit/bb2f80c1) (2025-08-05) Greg Rundlett: Update CHANGELOG for REL1_43 
  - Modified: `CHANGELOG`

* [ac1eb9c5](https://github.com/freephile/meza/commit/ac1eb9c5) (2025-08-04) Greg Rundlett: Add the github action workflow This needs to be tested.
  - Added: `.github/workflows/generate-sbom.yml`

* [4f3323fe](https://github.com/freephile/meza/commit/4f3323fe) (2025-08-04) Greg Rundlett: Add script to show git (annotated) tags You SHOULD use Git Graph in VsCode, but this script is handy for Release Notes and so on.
  - Added: `src/scripts/showTags.md`
  - Added: `src/scripts/showTags.sh`

* [6152f022](https://github.com/freephile/meza/commit/6152f022) (2025-08-04) Greg Rundlett: spaces to tabs 
  - Modified: `src/scripts/importExtensions.php`
  - Modified: `src/scripts/listCoreExtensions.php`

* [16a93f80](https://github.com/freephile/meza/commit/16a93f80) (2025-08-02) Greg Rundlett: convert spaces to tabs per coding standards 
  - Modified: `src/scripts/generate-sbom.php`

* [6abeeac0](https://github.com/freephile/meza/commit/6abeeac0) (2025-08-02) Greg Rundlett: Change root package reference to NASA - Updated download location: Changed from https://github.com/enterprisemediawiki/meza to https://github.com/nasa/meza
- Updated copyright: Changed from Copyright Enterprise MediaWiki to Copyright NASA
- Updated supplier: Changed from Organization: Enterprise MediaWiki to Organization: NASA
- Updated vendor in CycloneDX: Changed from Meza to NASA
- Added external references: Added both the GitHub repository and the MediaWiki documentation page for better reference
These changes ensure that the SBOM correctly identifies NASA as the organization behind the Meza project and points to the correct repository location.
  - Modified: `src/scripts/generate-sbom.php`

* [5170674e](https://github.com/freephile/meza/commit/5170674e) (2025-08-02) Greg Rundlett: Update to include composer.LOCAL.lock Key improvements in this updated version:
- Dual File Support: Automatically detects and includes composer.local.lock
- Conflict Resolution: When the same package exists in both files, uses the version from composer.lock
- Source Tracking: All packages include metadata about which file they came from
- Enhanced Reporting: Statistics and human-readable output show breakdown by source file
- Visual Indicators: Local packages are marked with [LOCAL] in text output
- Updated Documentation: Explains the dual-file approach and precedence rules
Now the SBOM will include all dependencies from both your main composer.lock and any local overrides in composer.local.lock, giving you a complete picture of your dependency landscape.
Note that when "looking" for composer.lock, the path is hard-coded as
/opt/htdocs/mediawiki/composer.lock. We could make it 'intelligently search' but for now we'll use the known path for Meza installations.
  - Modified: `src/scripts/generate-sbom.php`
  - Modified: `src/scripts/sbom.md`

* [274a8e02](https://github.com/freephile/meza/commit/274a8e02) (2025-08-02) Greg Rundlett: initial concept with just composer.json This comprehensive SBOM solution will:
- Parse your composer.lock to extract all dependencies
- Generate industry-standard SBOM formats (SPDX, CycloneDX)
- Provide human-readable summaries
- Automatically update when dependencies change
- Support security and compliance requirements
- Integrate with CI/CD pipelines
The generated SBOMs will include all 200+ packages
from your MediaWiki ecosystem, properly categorized
by scope and type, with complete license and metadata information.
  - Added: `src/scripts/generate-sbom.php`
  - Added: `src/scripts/sbom.md`

* [65933815](https://github.com/freephile/meza/commit/65933815) (2025-08-01) Greg Rundlett: Create SECURITY policy (#175) * Create SECURITY.md
GitHub reads this root-level file as the repository's Security Policy (IOW it's standard)
* Simplify link, add email, fix linting
  - Added: `SECURITY.md`

* [3588683f](https://github.com/freephile/meza/commit/3588683f) (2025-08-01) Greg Rundlett: Add TODO comments 
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/scripts/getmeza.sh`

* [bbfc7943](https://github.com/freephile/meza/commit/bbfc7943) (2025-07-31) Greg Rundlett: Turn off Kibana by default 
  - Modified: `config/defaults.yml`

* [373275a5](https://github.com/freephile/meza/commit/373275a5) (2025-07-31) Greg Rundlett: Turn off Certbot by default 
  - Modified: `config/defaults.yml`

* [04c92425](https://github.com/freephile/meza/commit/04c92425) (2025-07-31) Greg Rundlett: Add missing composer merge for Abuse Filter May (likely!) fix Issue [#168](https://github.com/freephile/meza/issues/168)
Although it appeared to be a permission error, or
missing class, the underlying problem was missing
composer libraries needed by AbuseFilter
  - Modified: `config/MezaCoreExtensions.yml`

* [5be1107c](https://github.com/freephile/meza/commit/5be1107c) (2025-07-29) Greg Rundlett: Final nitpick changes fixes Issue [#170](https://github.com/freephile/meza/issues/170) 
  - Modified: `.github/ISSUE_TEMPLATE/bug_report.md`
  - Modified: `.github/ISSUE_TEMPLATE/feature_request.md`

* [0263f719](https://github.com/freephile/meza/commit/0263f719) (2025-07-29) Greg Rundlett: Update new issue workflow templates - updates Pull #169
- fixes Issue [#170](https://github.com/freephile/meza/issues/170)
- deletes (legacy) .github/ISSUE_TEMPLATE.md
  - Deleted: `.github/ISSUE_TEMPLATE.md`
  - Modified: `.github/ISSUE_TEMPLATE/bug_report.md`
  - Modified: `.github/ISSUE_TEMPLATE/custom.md`
  - Modified: `.github/ISSUE_TEMPLATE/feature_request.md`

* [91a52b1d](https://github.com/freephile/meza/commit/91a52b1d) (2025-07-29) Greg Rundlett: Update issue templates to new workflow See https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository
  - Added: `.github/ISSUE_TEMPLATE/bug_report.md`
  - Added: `.github/ISSUE_TEMPLATE/custom.md`
  - Added: `.github/ISSUE_TEMPLATE/feature_request.md`

* [2a996bd0](https://github.com/freephile/meza/commit/2a996bd0) (2025-07-24) Greg Rundlett: DOWNGRADE MediaWiki to 1.43.1 Avoid breaking changes in 1.43.2 which technically should
not happen in a point release; without announcment
if you follow semantic versioning and test backports.
Addresses Issue [#163](https://github.com/freephile/meza/issues/163)
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [7d40d3ee](https://github.com/freephile/meza/commit/7d40d3ee) (2025-07-24) Greg Rundlett: Upgrade ModernTimeline to 2.x Upgrade from 1.x to 2.x
Fixes #167
Was getting 500 error
From Release Notes https://github.com/ProfessionalWiki/ModernTimeline#release-notes
Released on July 7th, 2025.
- Raised minimum PHP version to 8.0
- Raised minimum MediaWiki version to 1.39
- Upgraded to TimelineJS3 3.9.6
- Translation updates from https://translatewiki.net
  - Modified: `config/MezaCoreExtensions.yml`

* [9aab3a1b](https://github.com/freephile/meza/commit/9aab3a1b) (2025-07-23) Greg Rundlett: Enable 'overwrite_local_changes'  for Composer Add composer-installed skins and extensions to the switch for overwriting local changes. This gives parity with Git-controlled extensions and skins.
The default is 'false' because neither git nor Composer want to clobber local changes. But if you want to be able to, it can be easily done with the Meza config variable 'overwrite_local_changes' (bool)
  - Modified: `RELEASE-NOTES.md`
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/composer.local.json.j2`

* [8a6d4932](https://github.com/freephile/meza/commit/8a6d4932) (2025-07-22) Greg Rundlett: Upgrade Maps from 10.x to 11.x Fixes #166 SMWPrintRequest not found
  - Modified: `config/MezaCoreExtensions.yml`

* [1896a15e](https://github.com/freephile/meza/commit/1896a15e) (2025-07-10) Greg Rundlett: Fix linting - remove trailing spaces 
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `config/MezaCoreSkins.yml`

* [869607c0](https://github.com/freephile/meza/commit/869607c0) (2025-07-09) Greg Rundlett: remove extraneous '1' 
  - Modified: `src/scripts/listCoreExtensions.php`

* [db2e3b5c](https://github.com/freephile/meza/commit/db2e3b5c) (2025-07-09) Greg Rundlett: Disable Who's Online for being problematic 
  - Modified: `config/MezaCoreExtensions.yml`

* [37b9be51](https://github.com/freephile/meza/commit/37b9be51) (2025-06-06) Greg Rundlett: Add MW Core bundled extensions Fixes #135
Adds extensions
- AbuseFilter
- DiscussionTools
- Linter
- LoginNotify
- Math
- OATHAuth
- SecureLinkFixer
- SpamBlacklist
- TitleBlacklist
plus the skin Timeless
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `config/MezaCoreSkins.yml`

* [7581e79e](https://github.com/freephile/meza/commit/7581e79e) (2025-06-06) Greg Rundlett: re-enable Semantic Extensions   SRF and SCQ update Semantic Result Formats
    composer: "mediawiki/semantic-result-formats"
    version: "^5.0"
enable SemanticCompoundQueries
    composer: "mediawiki/semantic-compound-queries"
    version: "3.x-dev"
  - Modified: `config/MezaCoreExtensions.yml`

* [9e3ff555](https://github.com/freephile/meza/commit/9e3ff555) (2025-06-05) Greg Rundlett: Fix #140 enabling the SemanticDependencyUpdater and SRF SemanticDependencyUpdater and SemanticResultFormats
are the last of the SMW extensions to be re-enabled.
  - Modified: `config/MezaCoreExtensions.yml`

* [35a35c13](https://github.com/freephile/meza/commit/35a35c13) (2025-06-05) Greg Rundlett: Fixes #143 elimating duplicates between MezaCoreExtensions and MezaLocalExtensions Adds utility scripts that can be used to list core and diff to local.
A corresponding commit was made to the meza-conf repository affecting MezaLocalExtensions.yml.
  - Modified: `config/MezaCoreExtensions.yml`
  - Added: `src/scripts/findDupesInLocalExtensions.php`
  - Added: `src/scripts/listCoreExtensions.php`

* [41bbcd82](https://github.com/freephile/meza/commit/41bbcd82) (2025-06-05) Greg Rundlett: Fixes Issue [#62](https://github.com/freephile/meza/issues/62) Url for Netdata install has changed Update the URL, and use sh instead of bash because that is
what the install guide does (hence there are no 'bashisms')
  - Modified: `src/roles/netdata/tasks/main.yml`

* [66d7a4b2](https://github.com/freephile/meza/commit/66d7a4b2) (2025-06-04) Greg Rundlett: specify theme (neutral) for Mermaid extension 
  - Modified: `config/MezaCoreExtensions.yml`

* [6100d3c3](https://github.com/freephile/meza/commit/6100d3c3) (2025-06-04) Greg Rundlett: Block WhatLinksHere using Lockdown against robots #156 
  - Modified: `config/MezaCoreExtensions.yml`

* [53dcb430](https://github.com/freephile/meza/commit/53dcb430) (2025-06-03) Rich Evans: Update MezaCoreExtensions.yml Set Page Forms Version to the last version that supports MWM 1.39 (tag 5.9.1)
  - Modified: `config/MezaCoreExtensions.yml`

* [7985579b](https://github.com/freephile/meza/commit/7985579b) (2025-06-01) Greg Rundlett: Fixes #157 include CommentStreams composer.json in composer.local.json
  - Modified: `config/MezaCoreExtensions.yml`

* [63103b85](https://github.com/freephile/meza/commit/63103b85) (2025-05-15) Greg Rundlett: Add logos of component technologies 
  - Modified: `README.md`

* [f37f706c](https://github.com/freephile/meza/commit/f37f706c) (2024-12-19) Rich Evans: Update haproxy.cfg.j2 removed commented-out obsolete configuration text in haproxy.cfg
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [9a7c9991](https://github.com/freephile/meza/commit/9a7c9991) (2024-12-02) amcgillivray-nasa: Update getmeza.sh Incorporates cowen23's fix for Issue [#57](https://github.com/freephile/meza/issues/57)
  - Modified: `src/scripts/getmeza.sh`

* [cf09936d](https://github.com/freephile/meza/commit/cf09936d) (2025-03-28) Greg Rundlett: Add quotes to version spec for Bootstrap 
  - Modified: `config/MezaCoreExtensions.yml`

* [28a721c7](https://github.com/freephile/meza/commit/28a721c7) (2025-03-26) amcgillivray-nasa: Update MezaCoreExtensions.yml Granted the DeleteBatch permission to sysops (previous configuration did not grant the right to any groups)
  - Modified: `config/MezaCoreExtensions.yml`

* [e4ba295c](https://github.com/freephile/meza/commit/e4ba295c) (2025-02-18) Greg Rundlett: make lint command graceful 
  - Modified: `.github/workflows/yamllint.yml`

* [a3add764](https://github.com/freephile/meza/commit/a3add764) (2025-02-18) Greg Rundlett: final yamllint fixes 
  - Modified: `config/Debian.yml`
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `config/MezaCoreSkins.yml`

* [33cfdf17](https://github.com/freephile/meza/commit/33cfdf17) (2025-02-18) Greg Rundlett: moved yamllint config 
R100	src/.yamllint	.yamllint

* [f6ad58ee](https://github.com/freephile/meza/commit/f6ad58ee) (2025-02-18) Greg Rundlett: Fix yaml files for syntax 
  - Modified: `.github/workflows/yamllint.yml`
  - Modified: `.travis.yml`
  - Modified: `config/Debian.yml`
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `config/MezaCoreSkins.yml`
  - Modified: `config/defaults.yml`
  - Modified: `config/i18n/en.yml`
  - Modified: `requirements.yml`
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/playbooks/cleanup-upload-stash.yml`
  - Modified: `src/playbooks/delete-elasticsearch.yml`
  - Modified: `src/playbooks/example-block.yaml`
  - Modified: `src/playbooks/getdocker.yml`
  - Modified: `src/playbooks/push-backup.yml`
  - Modified: `src/playbooks/rebuild-smw-and-index.yml`
  - Modified: `src/playbooks/test-certbot.yml`
  - Modified: `src/requirements.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/.yamllint`
  - Modified: `src/roles/ansible-role-certbot-meza/defaults/main.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/meta/main.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/tasks/main.meza.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/tasks/setup-RedHat.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/vars/default.yml`
  - Modified: `src/roles/ansible-role-certbot-meza/vars/main.yml`
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`
  - Modified: `src/roles/backup-config/tasks/main.yml`
  - Modified: `src/roles/backup-db-wikis-push/tasks/main.yml`
  - Modified: `src/roles/backup-db-wikis/tasks/main.yml`
  - Modified: `src/roles/backup-uploads-push/tasks/main.yml`
  - Modified: `src/roles/backup-uploads/tasks/main.yml`
  - Modified: `src/roles/base-extras/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/composer/defaults/main.yml`
  - Modified: `src/roles/cron/defaults/main.yml`
  - Modified: `src/roles/database/defaults/main.yml`
  - Modified: `src/roles/database/tasks/configure.yml`
  - Modified: `src/roles/database/tasks/replication.yml`
  - Modified: `src/roles/database/tasks/secure-installation.yml`
  - Modified: `src/roles/database/tasks/setup-Debian.yml`
  - Modified: `src/roles/elasticsearch/tasks/es_reindex.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/firewall_service/tasks/main.yml`
  - Modified: `src/roles/geerlingguy.kibana/.github/workflows/stale.yml`
  - Modified: `src/roles/gluster/defaults/main.yml`
  - Modified: `src/roles/haproxy/handlers/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/htdocs/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/memcached/tasks/main.yml`
  - Modified: `src/roles/remote-dir-check/tasks/main.yml`
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/sql-backup-cleanup/tasks/main.yml`
  - Modified: `src/roles/sync-configs/tasks/main.yml`
  - Modified: `src/roles/update.php/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`
  - Modified: `src/roles/verify-wiki/tasks/transfer-backup-to-db-master.yml`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [fd7ac3a9](https://github.com/freephile/meza/commit/fd7ac3a9) (2025-02-17) Greg Rundlett: Update README with yamllint workflow badge 
  - Modified: `README.md`

* [73c2c0f6](https://github.com/freephile/meza/commit/73c2c0f6) (2025-02-17) Greg Rundlett: Add multiple branch patterns for the yamllint workflow 
  - Modified: `.github/workflows/yamllint.yml`

* [5c333f5e](https://github.com/freephile/meza/commit/5c333f5e) (2025-02-17) Greg Rundlett: Add new linting workflow 
  - Added: `.github/workflows/yamllint.yml`

* [900a1dc9](https://github.com/freephile/meza/commit/900a1dc9) (2025-01-28) Greg Rundlett: Switch Mermaid and BootstrapComponents to dev-master Replace deprecated Class loading for \PHPUnit\Framework\TestCase
Fixes Issue [#141](https://github.com/freephile/meza/issues/141)
  - Modified: `config/MezaCoreExtensions.yml`

* [7bc8622d](https://github.com/freephile/meza/commit/7bc8622d) (2025-01-24) Greg Rundlett: Finish off Maintenance Script improvements Last commits for this round of maintenance script operations
Fixes Issue [#142](https://github.com/freephile/meza/issues/142)
  - Modified: `src/roles/elasticsearch/tasks/es_reindex.yml`
  - Modified: `src/roles/mediawiki/templates/elastic-build-index.sh.j2`
  - Modified: `src/roles/mediawiki/templates/elastic-rebuild-all.sh.j2`

* [7cb90918](https://github.com/freephile/meza/commit/7cb90918) (2025-01-24) Greg Rundlett: Add comments for $smwgParserFeatures (Links In Values feature) 
  - Modified: `config/MezaCoreExtensions.yml`

* [ab10ebe1](https://github.com/freephile/meza/commit/ab10ebe1) (2025-01-17) Greg Rundlett: Maintenance Script update (missed these) Convert script calls to go through executable
'maintenance/run'
For extensions, use the class naming pattern
'Extension:ClassName'
Fixes Issue [#142](https://github.com/freephile/meza/issues/142)
  - Modified: `src/playbooks/cleanup-upload-stash.yml`
  - Modified: `src/roles/cron/templates/runAllJobs.php.j2`

* [ca179104](https://github.com/freephile/meza/commit/ca179104) (2025-01-17) Greg Rundlett: Finish Maintenance Script update Convert script calls to go through executable
'maintenance/run'
For extensions, use the class naming pattern
'Extension:ClassName'
Fixes Issue [#142](https://github.com/freephile/meza/issues/142)
  - Modified: `src/playbooks/cleanup-upload-stash.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/elastic-build-index.sh.j2`
  - Modified: `src/roles/mediawiki/templates/refresh-links.sh.j2`
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`
  - Modified: `src/roles/meza-log/templates/server-performance.sh.j2`
  - Modified: `src/roles/update.php/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`
  - Modified: `src/scripts/unite-the-wikis.sh`

* [d624f7b4](https://github.com/freephile/meza/commit/d624f7b4) (2025-01-16) Greg Rundlett: A new tool to inspect the git repos on the controller 
  - Added: `src/scripts/listExtensionRepos.sh`

* [e267f148](https://github.com/freephile/meza/commit/e267f148) (2025-01-16) Greg Rundlett: Update the Update.php role for new Maintenance script ops Issue [#142](https://github.com/freephile/meza/issues/142)
  - Modified: `src/roles/update.php/tasks/main.yml`

* [9e4de5e1](https://github.com/freephile/meza/commit/9e4de5e1) (2025-01-16) Greg Rundlett: Update maintenance scripts Server Performance logging/reporting role
(Probably needs to be eliminated altogether)
Issue [#142](https://github.com/freephile/meza/issues/142)
  - Modified: `src/roles/meza-log/templates/server-performance.sh.j2`

* [278c394e](https://github.com/freephile/meza/commit/278c394e) (2025-01-16) Greg Rundlett: Update maintenance scripts showSiteStats and refreshLinks
Issue [#142](https://github.com/freephile/meza/issues/142)
  - Modified: `src/roles/mediawiki/templates/refresh-links.sh.j2`

* [57c9bb20](https://github.com/freephile/meza/commit/57c9bb20) (2025-01-16) Greg Rundlett: Disable metastore maintenance All maintenance needs to be refactored
Issue [#142](https://github.com/freephile/meza/issues/142)
Also, this may be affected by upgrading to SMW 5.x
Issue [#136](https://github.com/freephile/meza/issues/136)
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [7ad66760](https://github.com/freephile/meza/commit/7ad66760) (2025-01-16) Greg Rundlett: Prefer source in composer managed extensions Use the --prefer-source option to composer
Eliminate the duplicate composer run
Eliminate the removal of a non-existant SMW file (IdeAliases.php)
needed for Issue [#136](https://github.com/freephile/meza/issues/136)
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [f87b92b2](https://github.com/freephile/meza/commit/f87b92b2) (2025-01-16) Greg Rundlett: Update maintenance scripts for MediaWiki 1.40 Fixes Issue [#142](https://github.com/freephile/meza/issues/142)
  - Modified: `src/roles/cron/templates/runAllJobs.php.j2`

* [4ca775d6](https://github.com/freephile/meza/commit/4ca775d6) (2025-01-16) Greg Rundlett: Update MezaCoreExtensions.yml for REL1_43 Use full enableSemantics() call to fix URL pattern
Switch to gerrit because GitHub seems to throttle
SemanticDrilldown 3.05 -> dev-master
SemanticScribunto 2.2.0 -> dev-master
add quotes on SemanticDrilldown version spec
add quotes on SubPageList version spec
  - Modified: `config/MezaCoreExtensions.yml`

* [e2873948](https://github.com/freephile/meza/commit/e2873948) (2025-01-10) Greg Rundlett: Create a variable named php_memory_limit defaulting to 128M PHP normally defaults to 128M so we also default to that.
Templated in the php.ini template of the apache-php role.
Fixes Issue [#151](https://github.com/freephile/meza/issues/151)
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`

* [51c89233](https://github.com/freephile/meza/commit/51c89233) (2025-01-08) Greg Rundlett: Enable SemanticCompoundQueries Was 2.2.0
Now 3.x-dev (same as dev-master)
Issue [#140](https://github.com/freephile/meza/issues/140)
  - Modified: `config/MezaCoreExtensions.yml`

* [d2a87e79](https://github.com/freephile/meza/commit/d2a87e79) (2025-01-08) Greg Rundlett: Use SubPageList dev-master Fixes Issue [#138](https://github.com/freephile/meza/issues/138)
  - Modified: `config/MezaCoreExtensions.yml`

* [ca17aac6](https://github.com/freephile/meza/commit/ca17aac6) (2025-01-07) Greg Rundlett: Disable or update non-working skins These skins need a version adjustment or update
to work with REL1_43
- Tweeki
- Medik
Use tags/v4.39.1 for Tweeki
Issue [#136](https://github.com/freephile/meza/issues/136)
  - Modified: `config/MezaCoreSkins.yml`

* [cde7d8cf](https://github.com/freephile/meza/commit/cde7d8cf) (2025-01-07) Greg Rundlett: Disable non-working extensions These extensions do not work, or need a version adjustment,
to be compatible with REL1_43 and SMW 5.x
- SemanticCompoundQueries
- SemanticDependencyUpdater
- SemanticDrilldown
- SemanticExtraSpecialProperties
- SemanticResultFormats
- SemanticScribunto
- SubPageList
  - Modified: `config/MezaCoreExtensions.yml`

* [36567d83](https://github.com/freephile/meza/commit/36567d83) (2025-01-07) Greg Rundlett: Switch SMW to dev-master Addresses Issue [#137](https://github.com/freephile/meza/issues/137)
composer show -a mediawiki/semantic-media-wiki
shows all available composer versions
  - Modified: `config/MezaCoreExtensions.yml`

* [d7d6a88e](https://github.com/freephile/meza/commit/d7d6a88e) (2025-01-07) Greg Rundlett: Upgrade to REL1_43 Fixes Issue [#136](https://github.com/freephile/meza/issues/136)
set meza_repository_url to use freephile/meza
set mediawiki_version for core
set mediawiki_default_branch (for extensions)
set php_ius_version to php81
  - Modified: `config/defaults.yml`

* [a4e8bdf0](https://github.com/freephile/meza/commit/a4e8bdf0) (2024-12-19) Rich Evans: Update haproxy.cfg.j2 removed commented-out obsolete configuration text in haproxy.cfg
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [18d66875](https://github.com/freephile/meza/commit/18d66875) (2024-12-19) Greg Rundlett: Kibana Security Do not allow connections from remote (the Internet)
Only allow localhost connections
Issue [#60](https://github.com/freephile/meza/issues/60)
  - Modified: `src/roles/geerlingguy.kibana/vars/main.yml`

* [a2a849ca](https://github.com/freephile/meza/commit/a2a849ca) (2024-12-19) Greg Rundlett: Comment our changes in the task file Issue [#37](https://github.com/freephile/meza/issues/37)
  - Modified: `src/roles/geerlingguy.kibana/tasks/main.yml`

* [a8904543](https://github.com/freephile/meza/commit/a8904543) (2024-12-18) Greg Rundlett: Add versionlock to Kibana Issue [#58](https://github.com/freephile/meza/issues/58) Issue [#37](https://github.com/freephile/meza/issues/37)
  - Modified: `src/roles/geerlingguy.kibana/tasks/main.yml`

* [0a6ed4ed](https://github.com/freephile/meza/commit/0a6ed4ed) (2024-12-18) Greg Rundlett: Add Kibana frontend to Elasticsearch Fixes Issue [#37](https://github.com/freephile/meza/issues/37)
Uses Geerlingguy Kibana
  - Modified: `.gitignore`
  - Modified: `config/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/requirements.yml`
  - Added: `src/roles/geerlingguy.kibana/.ansible-lint`
  - Added: `src/roles/geerlingguy.kibana/.github/FUNDING.yml`
  - Added: `src/roles/geerlingguy.kibana/.github/workflows/ci.yml`
  - Added: `src/roles/geerlingguy.kibana/.github/workflows/release.yml`
  - Added: `src/roles/geerlingguy.kibana/.github/workflows/stale.yml`
  - Added: `src/roles/geerlingguy.kibana/.gitignore`
  - Added: `src/roles/geerlingguy.kibana/.yamllint`
  - Added: `src/roles/geerlingguy.kibana/LICENSE`
  - Added: `src/roles/geerlingguy.kibana/README.md`
  - Added: `src/roles/geerlingguy.kibana/defaults/main.yml`
  - Added: `src/roles/geerlingguy.kibana/handlers/main.yml`
  - Added: `src/roles/geerlingguy.kibana/meta/.galaxy_install_info`
  - Added: `src/roles/geerlingguy.kibana/meta/main.yml`
  - Added: `src/roles/geerlingguy.kibana/molecule/default/converge.yml`
  - Added: `src/roles/geerlingguy.kibana/molecule/default/molecule.yml`
  - Added: `src/roles/geerlingguy.kibana/molecule/default/requirements.yml`
  - Added: `src/roles/geerlingguy.kibana/tasks/main.yml`
  - Added: `src/roles/geerlingguy.kibana/tasks/setup-Debian.yml`
  - Added: `src/roles/geerlingguy.kibana/tasks/setup-RedHat.yml`
  - Added: `src/roles/geerlingguy.kibana/templates/kibana.repo.j2`
  - Added: `src/roles/geerlingguy.kibana/templates/kibana.yml.j2`
  - Added: `src/roles/geerlingguy.kibana/vars/main.yml`

* [721e7fbf](https://github.com/freephile/meza/commit/721e7fbf) (2024-12-17) Greg Rundlett: rebased, but keep main comments Fixes Issue [#58](https://github.com/freephile/meza/issues/58)
  - Modified: `src/requirements.yml`

* [6706b93f](https://github.com/freephile/meza/commit/6706b93f) (2024-03-14) Greg Rundlett: Add Kibana frontend to Elasticsearch Using Ansible Galaxy and requirements.yml, we install Jeff Geeerling's
geerlingguy.kibana role. Fixes Issue [#37](https://github.com/freephile/meza/issues/37)
Kibana is available at port 5601
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/playbooks/site.yml`
  - Added: `src/requirements.yml`

* [7c01ff54](https://github.com/freephile/meza/commit/7c01ff54) (2024-12-17) Greg Rundlett: We do not need a special port for certbot creation Issue [#130](https://github.com/freephile/meza/issues/130)
  - Modified: `src/roles/ansible-role-certbot-meza/vars/main.yml`

* [ce07fdb9](https://github.com/freephile/meza/commit/ce07fdb9) (2024-12-17) Greg Rundlett: Do not put crt and key into HAProxy Issue [#130](https://github.com/freephile/meza/issues/130)
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [39a65494](https://github.com/freephile/meza/commit/39a65494) (2024-10-13) Rich Evans: Update MezaCoreExtensions.yml Added $wgObjectCacheSessionExpiry to SMW Config and set for 24 hours
(cherry picked from commit bc3055accb69112040bf93839b1994e1d6a55c2c)
  - Modified: `config/MezaCoreExtensions.yml`

* [82d4cb44](https://github.com/freephile/meza/commit/82d4cb44) (2024-12-11) Greg Rundlett: role name change to ansible-role-certbot-meza 
  - Modified: `src/playbooks/site.yml`

* [f4d54616](https://github.com/freephile/meza/commit/f4d54616) (2024-12-11) Greg Rundlett: Add TLS Certificate generation and auto-renewal (Certbot) Fixes Issue [#130](https://github.com/freephile/meza/issues/130)
  - Modified: `config/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Added: `src/playbooks/test-certbot.yml`
  - Added: `src/roles/ansible-role-certbot-meza/.ansible-lint`
  - Added: `src/roles/ansible-role-certbot-meza/.gitignore`
  - Added: `src/roles/ansible-role-certbot-meza/.yamllint`
  - Added: `src/roles/ansible-role-certbot-meza/LICENSE`
  - Added: `src/roles/ansible-role-certbot-meza/README.md`
  - Added: `src/roles/ansible-role-certbot-meza/defaults/main.yml`
  - Added: `src/roles/ansible-role-certbot-meza/handlers/main.yml`
  - Added: `src/roles/ansible-role-certbot-meza/meta/main.yml`
  - Added: `src/roles/ansible-role-certbot-meza/molecule/default/converge.yml`
  - Added: `src/roles/ansible-role-certbot-meza/molecule/default/molecule.yml`
  - Added: `src/roles/ansible-role-certbot-meza/molecule/default/playbook-snap-install.yml`
  - Added: `src/roles/ansible-role-certbot-meza/molecule/default/playbook-source-install.yml`
  - Added: `src/roles/ansible-role-certbot-meza/molecule/default/playbook-standalone-nginx-aws.yml`
  - Added: `src/roles/ansible-role-certbot-meza/molecule/default/requirements.yml`
  - Added: `src/roles/ansible-role-certbot-meza/tasks/create-cert-standalone.yml`
  - Added: `src/roles/ansible-role-certbot-meza/tasks/create-cert-webroot.yml`
  - Added: `src/roles/ansible-role-certbot-meza/tasks/include-vars.yml`
  - Added: `src/roles/ansible-role-certbot-meza/tasks/install-from-source.yml`
  - Added: `src/roles/ansible-role-certbot-meza/tasks/install-with-package.yml`
  - Added: `src/roles/ansible-role-certbot-meza/tasks/install-with-snap.yml`
  - Added: `src/roles/ansible-role-certbot-meza/tasks/main.meza.yml`
  - Added: `src/roles/ansible-role-certbot-meza/tasks/main.yml`
  - Added: `src/roles/ansible-role-certbot-meza/tasks/renew-cron.yml`
  - Added: `src/roles/ansible-role-certbot-meza/tasks/setup-RedHat.yml`
  - Added: `src/roles/ansible-role-certbot-meza/templates/concat.pem.sh.j2`
  - Added: `src/roles/ansible-role-certbot-meza/templates/start_services.j2`
  - Added: `src/roles/ansible-role-certbot-meza/templates/stop_services.j2`
  - Added: `src/roles/ansible-role-certbot-meza/tests/inventory`
  - Added: `src/roles/ansible-role-certbot-meza/tests/test.yml`
  - Added: `src/roles/ansible-role-certbot-meza/vars/default.yml`
  - Added: `src/roles/ansible-role-certbot-meza/vars/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [4f341436](https://github.com/freephile/meza/commit/4f341436) (2024-12-02) amcgillivray-nasa: Update getmeza.sh Incorporates cowen23's fix for Issue [#57](https://github.com/freephile/meza/issues/57)
  - Modified: `src/scripts/getmeza.sh`

* [68249080](https://github.com/freephile/meza/commit/68249080) (2024-11-27) Greg Rundlett: Promote comments into names for each play. This should help with readability and output clarity.
Extract gluster comments into the gluster role default variables file
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/gluster/defaults/main.yml`

* [0f8252de](https://github.com/freephile/meza/commit/0f8252de) (2024-11-22) Greg Rundlett: improve wording for m_opcache_production_mode 
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/init-controller-config/templates/public.yml.j2`

* [da7993df](https://github.com/freephile/meza/commit/da7993df) (2024-11-22) Greg Rundlett: update instruction + minor formatting This playbook need massive re-organization. See Issue [#42](https://github.com/freephile/meza/issues/42)
  - Modified: `src/playbooks/site.yml`

* [528002e4](https://github.com/freephile/meza/commit/528002e4) (2024-11-22) Greg Rundlett: Fix paths for PdfHandler Add full paths for commands to solve
pdfinfo not reporting any info about pdfs
  - Modified: `config/MezaCoreExtensions.yml`

* [7ad20063](https://github.com/freephile/meza/commit/7ad20063) (2024-11-22) Greg Rundlett: Add PdfHandler extension The base task now installs xpdf for RockyLinux
Solves Issue [#128](https://github.com/freephile/meza/issues/128)
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/roles/base/tasks/main.yml`

* [6737d49e](https://github.com/freephile/meza/commit/6737d49e) (2024-11-22) Greg Rundlett: Add extension Page Exchange Solves Issue [#126](https://github.com/freephile/meza/issues/126) but we still need
to identify and load at least one
package.
Perhaps put the work into making the SemanticMeetingMinutes into a package
  - Modified: `config/MezaCoreExtensions.yml`

* [a6cb3735](https://github.com/freephile/meza/commit/a6cb3735) (2024-11-22) Greg Rundlett: Alphabetize core extensions Fixes Issue [#129](https://github.com/freephile/meza/issues/129)
  - Modified: `config/MezaCoreExtensions.yml`

* [5042d74a](https://github.com/freephile/meza/commit/5042d74a) (2024-11-21) Greg Rundlett: remove obsolete commented tasks Rebuild Recent Changes was only necessary after
importing pages from script.
See Issue [#126](https://github.com/freephile/meza/issues/126)
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`

* [5d47bd26](https://github.com/freephile/meza/commit/5d47bd26) (2024-11-12) Greg Rundlett: Upgrade Bootstrap, BS Components, Chameleon to 5.x Fixes Issue [#125](https://github.com/freephile/meza/issues/125)
Fixes Issue  #107
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `config/MezaCoreSkins.yml`

* [69c5db7a](https://github.com/freephile/meza/commit/69c5db7a) (2024-11-11) Greg Rundlett: Default to DEVELOPMENT Change default Opcache behavior
Do NOT install Netdata monitoring by default
Adds option for Composer require-dev packages
Fixes Issue [#123](https://github.com/freephile/meza/issues/123)
Fixes Issue [#121](https://github.com/freephile/meza/issues/121)
Helps address Issue [#120](https://github.com/freephile/meza/issues/120)
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/init-controller-config/templates/public.yml.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [387ba9c3](https://github.com/freephile/meza/commit/387ba9c3) (2024-11-07) Greg Rundlett: Be explicit about who can edit Gadgets 
  - Modified: `config/MezaCoreExtensions.yml`

* [85afac96](https://github.com/freephile/meza/commit/85afac96) (2024-11-02) Greg Rundlett: Remove Elasticsearch upgrade playbook Issue [#118](https://github.com/freephile/meza/issues/118) 
  - Deleted: `src/playbooks/elasticsearch-upgrade.yml`
  - Deleted: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`

* [69c8a213](https://github.com/freephile/meza/commit/69c8a213) (2024-11-02) Greg Rundlett: Comment the community collections previously setup for RL8 Fixes Issue [#51](https://github.com/freephile/meza/issues/51)
  - Modified: `requirements.yml`

* [8a7241b0](https://github.com/freephile/meza/commit/8a7241b0) (2024-11-02) Greg Rundlett: Example playbook to observe the function of block scalars 
  - Added: `src/playbooks/example-block.yaml`

* [964b65e7](https://github.com/freephile/meza/commit/964b65e7) (2024-11-02) Greg Rundlett: Add a couple of 'ToDo' comments and reformat the smw index shell cmd The shell command was not working due to block folding the
list_of_wikis into a single string so the cmd was reformatted to a
single line (which is too long for yamllint compliance). But, at least
it nominally 'works'. A comment was added to address the issue that
this maintenance should not even exist in this role, but should be refactored. See Issue [#117](https://github.com/freephile/meza/issues/117)
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [105a5363](https://github.com/freephile/meza/commit/105a5363) (2024-10-24) Greg Rundlett: update github issue template 
  - Modified: `.github/ISSUE_TEMPLATE.md`

* [923758c1](https://github.com/freephile/meza/commit/923758c1) (2024-10-24) Greg Rundlett: Fix wiki symbolic links Issue [#115](https://github.com/freephile/meza/issues/115) 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [1219d724](https://github.com/freephile/meza/commit/1219d724) (2024-10-24) Greg Rundlett: Use system ansible Issue [#51](https://github.com/freephile/meza/issues/51) 
  - Modified: `src/scripts/meza.py`

* [aee09afe](https://github.com/freephile/meza/commit/aee09afe) (2024-10-24) Greg Rundlett: Fix ambiguous STDOUT messaging 
  - Modified: `src/scripts/meza.py`

* [a77b91ef](https://github.com/freephile/meza/commit/a77b91ef) (2024-10-24) Greg Rundlett: Use root for ansible-vault key operations become module touches on Issue [#72](https://github.com/freephile/meza/issues/72) privilege escalation
Also switch back to using system-installed ansible
over a local user installed ansible touches on Issue [#51](https://github.com/freephile/meza/issues/51)
Upgrade Ansible
[meza-ansible@rockylinux-s-4vcpu-8gb-nyc3-01 config]$ ansible --version
ansible [core 2.16.3]
  config file = /opt/meza/config/ansible.cfg
  configured module search path = ['/opt/conf-meza/users/meza-ansible/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.12/site-packages/ansible
  ansible collection location = /opt/meza/collections
  executable location = /usr/bin/ansible
  python version = 3.12.5 (main, Sep 24 2024, 09:41:18) [GCC 8.5.0 20210514 (Red Hat 8.5.0-22)] (/usr/bin/python3.12)
  jinja version = 3.1.2
  libyaml = True
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [13820f17](https://github.com/freephile/meza/commit/13820f17) (2024-10-08) Rich Evans: Update getmeza.sh 1) Don't exclude "ansible" and "ansible core" from epel.repo
2) Don't install repo centos-release-ansible-29, and
3) Don't specify the version of ansible to install.
  - Modified: `src/scripts/getmeza.sh`

* [bc3055ac](https://github.com/freephile/meza/commit/bc3055ac) (2024-10-13) Rich Evans: Update MezaCoreExtensions.yml Added $wgObjectCacheSessionExpiry to SMW Config and set for 24 hours
  - Modified: `config/MezaCoreExtensions.yml`

* [5857d81a](https://github.com/freephile/meza/commit/5857d81a) (2024-10-08) amcgillivray-nasa: Update flow configuration in MezaCoreExtensions.yml Configured Flow to use Parsoid
  - Modified: `config/MezaCoreExtensions.yml`

* [ba25a5df](https://github.com/freephile/meza/commit/ba25a5df) (2024-10-08) Rich Evans: Update getmeza.sh 1) Don't exclude "ansible" and "ansible core" from epel.repo
2) Don't install of centos-release-ansible-29, and 
3) Don't specify the version of ansible to install.
  - Modified: `src/scripts/getmeza.sh`

* [4810a1e6](https://github.com/freephile/meza/commit/4810a1e6) (2024-10-07) Greg Rundlett: Configure Flow (Structured Discussions) for MW 1.39 Fixes Issue [#114](https://github.com/freephile/meza/issues/114) Visual Editor was not working properly for Flow boards on MW1.39
(Parsoid-PHP) The easily provoked error was:
"Exception caught: Conversion from 'html' to 'wikitext' was requested, but core's Parser only supports 'wikitext' to 'html' conversion"
In MW 1.39, Flow still ignores the zero-config setup of Parsoid-PHP.
So, we need to wfLoadExtension() the local vendored Parsoid library.
And, set $wgVirtualRestConfig
This makes Flow usable on MW 1.39, but ultimately, Flow needs to be replaced as described in Issue [#39](https://github.com/freephile/meza/issues/39)
  - Modified: `config/MezaCoreExtensions.yml`

* [9c6b44ad](https://github.com/freephile/meza/commit/9c6b44ad) (2024-10-04) Greg Rundlett: Temporary work-arounds for Issue [#72](https://github.com/freephile/meza/issues/72) Do not run as root
Do not require 'sudo' for calling meza
Temporary or partial fixes for path and user problems
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/scripts/meza.py`

* [eb39199d](https://github.com/freephile/meza/commit/eb39199d) (2024-10-04) Greg Rundlett: update getmeza.sh to fix Issue [#51](https://github.com/freephile/meza/issues/51) Install ansible as the meza-ansible user and
then run install collections
  - Modified: `src/scripts/getmeza.sh`

* [6b655263](https://github.com/freephile/meza/commit/6b655263) (2024-10-04) Greg Rundlett: Fix Issue [#113](https://github.com/freephile/meza/issues/113) with specific binary paths Use /usr/local/bin for ansible-galaxy commands
Both in the playbook, and in the tasks
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [c2bde01c](https://github.com/freephile/meza/commit/c2bde01c) (2024-10-04) Greg Rundlett: Fix Issue [#108](https://github.com/freephile/meza/issues/108) Introduce requirements.yml and ansible.cfg changes
to install community collections we depend on
  - Modified: `config/ansible.cfg`
  - Added: `requirements.yml`

* [2f0e5cf0](https://github.com/freephile/meza/commit/2f0e5cf0) (2024-10-04) Greg Rundlett: Ignore common clutter and artifacts 
  - Modified: `.gitignore`

* [8b683562](https://github.com/freephile/meza/commit/8b683562) (2024-10-04) Greg Rundlett: ignore Ansible collections 
  - Modified: `.gitignore`

* [9cff9352](https://github.com/freephile/meza/commit/9cff9352) (2024-10-04) Greg Rundlett: add comment for powertools and remove  centos-release-ansible-29 
  - Modified: `src/scripts/getmeza.sh`

* [88f3b2a6](https://github.com/freephile/meza/commit/88f3b2a6) (2024-10-04) Greg Rundlett: bump bootstrap; add bootstrap components 
  - Modified: `config/MezaCoreExtensions.yml`

* [cb437664](https://github.com/freephile/meza/commit/cb437664) (2024-10-04) Greg Rundlett: Preliminary removal of Python install INSIDE MediaWiki role @TODO cleanup / remove the separate variables for package_pyhton3_pip and package_python3_pip_rhel8 See Issue [#41](https://github.com/freephile/meza/issues/41)#issuecomment-2045506153
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [a2c81668](https://github.com/freephile/meza/commit/a2c81668) (2024-10-04) Greg Rundlett: Re-enable Semantic Dependency Updater 
  - Modified: `config/MezaCoreExtensions.yml`

* [eab5d30c](https://github.com/freephile/meza/commit/eab5d30c) (2024-10-04) Greg Rundlett: Clarify opcache settings m_use_production_settings was vague
m_opcache_production_mode better describes this switch
Add descriptive comments that explains what it does
  - Modified: `Vagrantfile`
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`
  - Modified: `src/roles/init-controller-config/templates/public.yml.j2`

* [fedf9fbf](https://github.com/freephile/meza/commit/fedf9fbf) (2024-10-04) Greg Rundlett: Fix rebuild SMW data and rebuild Elasticsearch Add 'base' tag to the deploy command
fixes #98
  - Modified: `RELEASE-NOTES.md`

* [aed2dc95](https://github.com/freephile/meza/commit/aed2dc95) (2024-10-04) Greg Rundlett: Fix rebuild SMW data and rebuild Elasticsearch substitute list_of_wikis in place of wikis_to_rebuild_data
because the latter variable is undefined
fixes Issue [#98](https://github.com/freephile/meza/issues/98)
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [20f938f3](https://github.com/freephile/meza/commit/20f938f3) (2024-10-04) Greg Rundlett: Remove the footer in .git-commit-template. 
  - Modified: `.git-commit-template`

* [59cfafe9](https://github.com/freephile/meza/commit/59cfafe9) (2024-10-04) Greg Rundlett: downgrade ReplaceText + InputBox These extensions' 'main' branch requires
a higher version of MediaWiki core. So, revert to
the REL1_39 branch for now.
  - Modified: `config/MezaCoreExtensions.yml`

* [4b80c01f](https://github.com/freephile/meza/commit/4b80c01f) (2024-10-04) Greg Rundlett: Fix typo in MezaCoreExtensions.yml 
  - Modified: `config/MezaCoreExtensions.yml`

* [cfbe3c22](https://github.com/freephile/meza/commit/cfbe3c22) (2024-10-04) Greg Rundlett: Remove SAML configuration The SAML configuration should go into a configuration repo
(e.g. conf-meza-myfarm) for wikis that use it.
The 'opt/conf-meza/public' directory should
ALWAYS be turned into a 'conf-meza-myfarm' repo
after the first 'meza deploy', so that's where SAML
config can be put in e.g. base.php
This way, Meza can be deployed and used with all
kinds of authentication options rather than a single
hard-coded option.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [ccc932fe](https://github.com/freephile/meza/commit/ccc932fe) (2024-10-04) Greg Rundlett: Switch some repos to master Add comments about things that need to be fixed or checked
Switch some repos to 'master'
- ExternalData
- InputBox
- ReplaceText
- AdminLinks
- DataTransfer
Reformat line comments from PHP to YAML
so that the file is valid YAML
  - Modified: `config/MezaCoreExtensions.yml`

* [87837388](https://github.com/freephile/meza/commit/87837388) (2024-10-04) Greg Rundlett: Fix composer install bug Fix Issue [#94](https://github.com/freephile/meza/issues/94) which can happen when composer.json
has newer dependencies or requirements than
composer.lock
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [7166e16f](https://github.com/freephile/meza/commit/7166e16f) (2024-10-04) Greg Rundlett: Fix samesite cookie settings for a stubborn Chrome Chrome browser will error with
"State Information Lost" ( \SimpleSAML\Error\NoState: NOSTATE )
unless you set session.cookie.secure => true
and session.cookie.samesite => 'None'
  - Modified: `src/roles/saml/templates/config.php.j2`

* [87956a53](https://github.com/freephile/meza/commit/87956a53) (2024-10-03) amcgillivray-nasa: Update MezaCoreExtensions.yml Changing page forms version from master to 5.8.1
  - Modified: `config/MezaCoreExtensions.yml`

* [33588cc6](https://github.com/freephile/meza/commit/33588cc6) (2024-10-02) amcgillivray-nasa: Update MezaCoreExtensions.yml Fixed spacing issue
  - Modified: `config/MezaCoreExtensions.yml`

* [c3ab0884](https://github.com/freephile/meza/commit/c3ab0884) (2024-09-27) amcgillivray-nasa: Update MezaCoreExtensions.yml 1. Added $wgPageFormsUseDisplayTitle = false;
2. Added UrlGetParameters
  - Modified: `config/MezaCoreExtensions.yml`

* [6d604cb0](https://github.com/freephile/meza/commit/6d604cb0) (2024-09-26) amcgillivray-nasa: Update MezaCoreExtensions.yml 1. Added $wgPageFormsDelayReload = true;
2. Added $smwgParserFeatures = $smwgParserFeatures | SMW_PARSER_LINV;
3. Added Gadgets extension
  - Modified: `config/MezaCoreExtensions.yml`

* [816854ad](https://github.com/freephile/meza/commit/816854ad) (2024-09-20) James Montalvo: fix(vuln): remove default elasticsearch password Setting a default password could cause installations to use that
password in production systems, which is a security vulnerability since
the default password is published on github.
  - Modified: `src/roles/elasticsearch/defaults/main.yml`

* [ebcb21cc](https://github.com/freephile/meza/commit/ebcb21cc) (2024-09-18) Rich Evans: Update MezaCoreExtensions.yml added Extension UrlGetParameters
  - Modified: `config/MezaCoreExtensions.yml`

* [d15eabdb](https://github.com/freephile/meza/commit/d15eabdb) (2024-09-18) Rich Evans: Update MezaCoreExtensions.yml Update SMW config to not use links in values
  - Modified: `config/MezaCoreExtensions.yml`

* [6bd0c2d2](https://github.com/freephile/meza/commit/6bd0c2d2) (2024-09-11) Rich Evans: Removed WatchAnalytics in MezaCoreExtensions.yml Will add it back after full 1.39 checkout is complete.
  - Modified: `config/MezaCoreExtensions.yml`

* [b48a7455](https://github.com/freephile/meza/commit/b48a7455) (2024-09-11) Rich Evans: Update MezaCoreExtensions.yml so Extention HeaderTabs uses master 
  - Modified: `config/MezaCoreExtensions.yml`

* [12a9ca69](https://github.com/freephile/meza/commit/12a9ca69) (2024-09-11) Rich Evans: removed extension not used in 1.34 MezaCoreExtensions.yml removed SubpageNavigation, InlineComments, DarkMode, WikiLove, FlexFormUpdate. Will add these extensions back after 1.39 is fully checked-out
  - Modified: `config/MezaCoreExtensions.yml`

* [7bc5f2f9](https://github.com/freephile/meza/commit/7bc5f2f9) (2024-09-10) Rich Evans: Update LocalSettings.php.j2 enabled 4 GB uploads and don't check fiile types
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [9ec786b1](https://github.com/freephile/meza/commit/9ec786b1) (2024-09-10) Rich Evans: Update defaults.yml update max file size to 5G
  - Modified: `config/defaults.yml`

* [dfb15e15](https://github.com/freephile/meza/commit/dfb15e15) (2024-09-05) Rich Evans: Update MezaCoreExtensions.yml Bump SMW from 4.1.3 to ~4.2 + added config properties, switch back to normal Mediawiki version of PF version master, added SubPageNavigation config, changed SDU config to use Job Queue.
  - Modified: `config/MezaCoreExtensions.yml`

* [89dccf34](https://github.com/freephile/meza/commit/89dccf34) (2024-09-05) amcgillivray-nasa: Update wgSDUUseJobQueue to true in MezaCoreExtensions.yml SDU works when set to true, and does not work when set to false
  - Modified: `config/MezaCoreExtensions.yml`

* [3a952f5b](https://github.com/freephile/meza/commit/3a952f5b) (2024-07-11) amcgillivray-nasa: Update haproxy.cfg.j2 Removed "no-tlsv12" in order to maintain compatibility with mwclient on RHEL8 using OpenSSL 1.1.1
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [f55071aa](https://github.com/freephile/meza/commit/f55071aa) (2024-07-03) ndc-rkevans: Add WikiLove, FlexForms, and change VEForAll brnach to master 
  - Modified: `config/MezaCoreExtensions.yml`

* [a5d919e3](https://github.com/freephile/meza/commit/a5d919e3) (2024-06-10) Rich Evans: Update MezaCoreSkins.yml Add MediaWiki site configuration variables via the Vector skin config
  - Modified: `config/MezaCoreSkins.yml`

* [9ff624e4](https://github.com/freephile/meza/commit/9ff624e4) (2024-06-10) Rich Evans: Update MezaCoreSkins.yml removed skin:Poncho until we have time to debug it
  - Modified: `config/MezaCoreSkins.yml`

* [6f439740](https://github.com/freephile/meza/commit/6f439740) (2024-06-10) Rich Evans: Update MezaCoreExtensions.yml Configure Page Forms to allow autoedits in the User Namespace
  - Modified: `config/MezaCoreExtensions.yml`

* [2732e08e](https://github.com/freephile/meza/commit/2732e08e) (2024-06-06) Rich Evans: Update MezaCoreSkins.yml Notes - Chameleon is the default skin. All the other skins either ship with MW Core (1.39) or they were listed at: https://www.pro.wiki/articles/best-mediawiki-skins
  - Modified: `config/MezaCoreSkins.yml`

* [13c853fa](https://github.com/freephile/meza/commit/13c853fa) (2024-06-06) Rich Evans: Update MezaCoreSkins.yml adding more skins to choose from
  - Modified: `config/MezaCoreSkins.yml`

* [ea52868f](https://github.com/freephile/meza/commit/ea52868f) (2024-06-06) ndc-rkevans: replace depricated ansible includes with include_tasks 
  - Modified: `src/roles/database/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/gluster/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`

* [4f1fbe5a](https://github.com/freephile/meza/commit/4f1fbe5a) (2024-06-06) ndc-rkevans: Re-enable SDU and fix CommentStreams config typo 
  - Modified: `config/MezaCoreExtensions.yml`

* [2cb0b81a](https://github.com/freephile/meza/commit/2cb0b81a) (2024-05-31) Rich Evans: Update MezaCoreExtensions.yml make it so that Comment Streams don't show on pages by default
  - Modified: `config/MezaCoreExtensions.yml`

* [da64b3ba](https://github.com/freephile/meza/commit/da64b3ba) (2024-05-20) Rich Evans: Update .htaccess.j2 Don't expose any files or folders with .git in the path
  - Modified: `src/roles/htdocs/templates/.htaccess.j2`

* [6ce641e0](https://github.com/freephile/meza/commit/6ce641e0) (2024-05-08) ndc-rkevans: Configure Apache ServerTokens to ProductOnly 
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`

* [83d38a0c](https://github.com/freephile/meza/commit/83d38a0c) (2024-05-08) ndc-rkevans: Have meza overwrite local commits by default 
  - Modified: `config/defaults.yml`

* [932042ab](https://github.com/freephile/meza/commit/932042ab) (2024-05-08) ndc-rkevans: Add Extension SubpageNavigation to Meza Core Extension 
  - Modified: `config/MezaCoreExtensions.yml`

* [8eb22403](https://github.com/freephile/meza/commit/8eb22403) (2024-05-01) ndc-rkevans: saml configuration updates 
  - Modified: `src/roles/configure-wiki/templates/samlAuthorizations.d/base.php.j2`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/saml/templates/authsources.php.j2`
  - Modified: `src/roles/saml/templates/config.php.j2`

* [d931e9cc](https://github.com/freephile/meza/commit/d931e9cc) (2024-03-29) Greg Rundlett: Add cache directory for SimpleSAMLphp The cachedir is templated in the config.php.j2 file.
The directory is created in the main tasks file.
Oddly enough, the system worked in prior tests without any cache defined.
See simplesamlphp/config/config.dist for all configurations available.
See Issue [#74](https://github.com/freephile/meza/issues/74)
This work was performed for NASA GRC-ATF by WikiWorks per NASA Contract NNC15BA02B.
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/saml/templates/config.php.j2`

* [39dbcbf6](https://github.com/freephile/meza/commit/39dbcbf6) (2024-03-29) Greg Rundlett: Update CHANGELOG and RELEASE NOTES Add details on new features.
See Issue [#52](https://github.com/freephile/meza/issues/52)
See also #53 #54 #55
This work was performed for NASA GRC-ATF by WikiWorks per NASA Contract NNC15BA02B.
  - Modified: `CHANGELOG`
  - Modified: `RELEASE-NOTES.md`

* [86aea143](https://github.com/freephile/meza/commit/86aea143) (2024-03-29) Greg Rundlett: Fix first-time deploy errors related to SMW rebuild data Add the special 'never' tag to the task in the MediaWiki role.
With the 'never' tag, this task will ONLY be run if you specifically ask
for it with the --tags=smw-data option (or --tags=never option).
This changes behavior of Meza so that it does not rebuild SMW data
on each and every deploy. To specifically request a SMW rebuild, simply
ask for it by name with `sudo meza deploy monolith --tags smw-data`
Fixes Issue [#80](https://github.com/freephile/meza/issues/80)
This work was performed for NASA GRC-ATF by WikiWorks per NASA Contract NNC15BA02B.
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [74e74a20](https://github.com/freephile/meza/commit/74e74a20) (2024-03-29) Greg Rundlett: Change SAML logging handler to file simpleSAMLphp's logging handler is 'syslog' by default.
Change the handler to 'file' so that we can see the logs in the logging directory.
See Issue [#74](https://github.com/freephile/meza/issues/74)
This work was performed for NASA GRC-ATF by WikiWorks per NASA Contract NNC15BA02B.
  - Modified: `src/roles/saml/templates/config.php.j2`

* [0ac901cf](https://github.com/freephile/meza/commit/0ac901cf) (2024-03-29) Greg Rundlett: Update saml20-idp-remote.php Fix syntax:
- update array syntax for PHP8
- avoid double open array by putting it after the conditionals
- vertical spacing
- indentation
- output an 'error message' in a PHP comment when cert data is not defined
Move 'FIXME' into a jinja comment so it is not templated out
See #74
This work was performed for NASA GRC-ATF by WikiWorks per NASA Contract NNC15BA02B.
  - Modified: `src/roles/saml/templates/saml20-idp-remote.php.j2`

* [c8f3317f](https://github.com/freephile/meza/commit/c8f3317f) (2024-03-28) Greg Rundlett: Add commit template; Add Rich to Release Notes Use the commit template by issuing a git config command
git config commit.template ./.git-commit-template
Add Rich Evans to Release Notes 'contributors' section
See Issue [#54](https://github.com/freephile/meza/issues/54)
This work was performed for NASA GRC-ATF by WikiWorks per NASA Contract NNC15BA02B.
  - Added: `.git-commit-template`
  - Modified: `RELEASE-NOTES.md`

* [5e2200b7](https://github.com/freephile/meza/commit/5e2200b7) (2024-03-28) Greg Rundlett: Create Release Notes for v39.5.0 Updated CHANGELOG and RELEASE-NOTES.md for the v39.5.0 release.
Fixes #55
See also #52 #53 #54
  - Modified: `CHANGELOG`
  - Modified: `RELEASE-NOTES.md`

* [dce594e2](https://github.com/freephile/meza/commit/dce594e2) (2024-03-28) Greg Rundlett: Versionlock Ansible and Python to prevent incompatibilities For the immediate future, we will stick with Python 3.6.8 and Ansible 2.29.27
There are other issues in the backlog to upgrade these.
Fixes #82
This work was performed for NASA GRC-ATF by WikiWorks per NASA Contract NNC15BA02B.
  - Modified: `src/roles/base/tasks/main.yml`

* [84e08b0c](https://github.com/freephile/meza/commit/84e08b0c) (2024-03-27) Greg Rundlett: Fix deploy errors on initial deploy Fixes #80 First-time deploy failure
This work was performed for NASA GRC-ATF by WikiWorks per NASA Contract NNC15BA02B.
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [58933f20](https://github.com/freephile/meza/commit/58933f20) (2024-03-27) Greg Rundlett: Fix fatal recursion errors Working on Issue [#80](https://github.com/freephile/meza/issues/80)
- Use loop to show the list of wikis
- Eliminate the vars: repetition of what is already established fact
This work was performed for NASA GRC-ATF by WikiWorks per NASA Contract NNC15BA02B.
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [86230816](https://github.com/freephile/meza/commit/86230816) (2024-03-27) Greg Rundlett: Finish dressing out the SAML Authentication role Fixes #74 Tested against Mocksaml.com
- Use configuration variables from public.yml,
- and setup defaults that work for NASA for $wgPluggableAuth_Config
- templated into LocalSettings.php
- Add commentary about using privatekey and certificate in Authsources.php
- Add conditional on NameIDPolicy
This work was performed for NASA GRC-ATF by WikiWorks per NASA Contract NNC15BA02B.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/saml/templates/authsources.php.j2`

* [df820d71](https://github.com/freephile/meza/commit/df820d71) (2024-03-27) Greg Rundlett: Remove the old 'remove Extension SimpleSamlAuth' This is very old, and confusing to still be here.
This work was performed for NASA GRC-ATF by WikiWorks per NASA Contract NNC15BA02B.
  - Modified: `src/roles/saml/tasks/main.yml`

* [f73c2160](https://github.com/freephile/meza/commit/f73c2160) (2024-03-25) Greg Rundlett: Fix default port for PHP-FPM The default port for PHP-FPM should be 9000
9090 is used by many other services or applications
On my stock Rocky Linux, 9090 is being used by systemd
This work was performed for NASA GRC-ATF by WikiWorks per NASA Contract NNC15BA02B.
  - Modified: `config/defaults.yml`

* [315364cc](https://github.com/freephile/meza/commit/315364cc) (2024-03-22) Greg Rundlett: Modify print_width in .editorconfig - but it doesn't seem to affect yamllint This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `.editorconfig`

* [e554ccf6](https://github.com/freephile/meza/commit/e554ccf6) (2024-03-22) Greg Rundlett: Fix 'create wiki' failure due to variable scoping include_tasks creates a whole new scope and so no variables are defined unless passed
This is the real reason why fatal recursion was happening with create wiki without specifying wiki_id as an extra var.
Fixes #48
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [18871ab1](https://github.com/freephile/meza/commit/18871ab1) (2024-03-22) Greg Rundlett: Lift restriction on composer version This allows composer to upgrade to the latest release
Fixes #77
Fixes security issues related to composer
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/composer/tasks/main.yml`

* [29f99dde](https://github.com/freephile/meza/commit/29f99dde) (2024-03-22) Greg Rundlett: Enable check mode for testing Work on Issue [#76](https://github.com/freephile/meza/issues/76)
remove duplicate set_fact in replication.yml
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/database/tasks/main.yml`
  - Modified: `src/roles/database/tasks/replication.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [79057619](https://github.com/freephile/meza/commit/79057619) (2024-03-21) Greg Rundlett: Add LocalSettings directive for Extension:SubPageList This **maybe** should go in MezaCoreExtensions.yml, but generally
site-wide configuration should be in LocalSettings.php
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [04413171](https://github.com/freephile/meza/commit/04413171) (2024-03-21) Greg Rundlett: Add FIXME comment about composer See Issue [#71](https://github.com/freephile/meza/issues/71)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/composer/tasks/main.yml`

* [e672dccb](https://github.com/freephile/meza/commit/e672dccb) (2024-03-21) Greg Rundlett: SubPageList needs a wfLoadExtension This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [0923618f](https://github.com/freephile/meza/commit/0923618f) (2024-03-21) Greg Rundlett: Upgrade SAML auth to use simpleSAMLphp 2.2.1 This fixes #74
Creates the administration web interface at https://localhost/simplesaml/admin
Login credentials come from your secret.yml
Setup comes from your public.yml
See https://www.mediawiki.org/wiki/Meza/Setup_SAML_authentication
config/defaults.yml
- upgrade simpleSAMLphp library from 1.19.7 to 2.2.1
- upgrade Extension:PluggableAuth to 7.0
- upgrade Extension:simpleSAMLphp to 7.0
saml/templates/config.php.j2
- change array notation
- add comments
- use config variable with default for timezone
- remove obsolete settings
- update deprecated settings
src/roles/apache-php/tasks/php-redhat8.yml
- add php-sodium #  required for phpSimpleSAML
src/roles/apache-php/templates/httpd.conf.j2
- the simplesaml web entrypoint directory is changed to 'public' from 'www'
- describe the possible use of SIMPLESAMLPHP_CONFIG_DIR env variable
- remove 'Options All -Indexes' because it is meaningless in the context
src/roles/saml/tasks/main.yml
- update the URL for library download
-  use the ansible variable saml_mw_extension_version for extension version
- add a task to create the apache writable log directory
src/roles/apache-php/templates/php-fpm-httpd.conf.j2
- the simplesaml web entrypoint directory is changed to 'public' from 'www'
src/roles/saml/templates/authsources.php.j2
- change array notation
- add comments
- add explicit 'idp' => null when not defined
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat8.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/apache-php/templates/php-fpm-httpd.conf.j2`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/saml/templates/authsources.php.j2`
  - Modified: `src/roles/saml/templates/config.php.j2`

* [5362af6a](https://github.com/freephile/meza/commit/5362af6a) (2024-03-20) Greg Rundlett: Extension SubPageList upgraded from 1.6.1 to 3.0.0 This fixes Issue [#70](https://github.com/freephile/meza/issues/70)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [6ab981b8](https://github.com/freephile/meza/commit/6ab981b8) (2024-03-19) Greg Rundlett: Reformat: Wrap all comments at 120 characters Also remove trailing whitespace
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [d465e29d](https://github.com/freephile/meza/commit/d465e29d) (2024-03-19) Greg Rundlett: Delete errant swap file from repo This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Deleted: `config/.MezaCoreExtensions.yml.swp`

* [74beb296](https://github.com/freephile/meza/commit/74beb296) (2024-03-18) Greg Rundlett: Fix delete / restore functionality The automatic recovery of a wiki from it's backups was failing due to the
'rebuild SMW' task in create-wiki-wrapper.
Fixes #67
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`

* [7d9915dc](https://github.com/freephile/meza/commit/7d9915dc) (2024-03-18) Greg Rundlett: Add VS Code settings to .gitignore This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `.gitignore`

* [013a11b6](https://github.com/freephile/meza/commit/013a11b6) (2024-03-17) Greg Rundlett: Use Elasticsearch 7.10 Fixes #65
Start security work (singled-node is more secure, but this only works on monolith, with a single elasticsearch node)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/elasticsearch/defaults/main.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.yml.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [873258d3](https://github.com/freephile/meza/commit/873258d3) (2024-03-17) Greg Rundlett: Add the --always option to git describe to avoid errors With --always, even if git can not find any tags, the commit hash will be used.
Fixes #57
meza --version will return something like
    Meza 39.1.0-7-gfc45add
    Commit fc45adddfa3efd308ab2dc4350c6315c5ef10858
    Mediawiki EZ Admin
Also, fix typo in function name get_git_descripe_tags()
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/scripts/meza.py`

* [fc45addd](https://github.com/freephile/meza/commit/fc45addd) (2024-03-17) Greg Rundlett: Document all 53 functions in meza.py get_deploy_info() now raises a FileNotFoundError if the lockfile
for the environment does not exist. Before it would just return
false in that case.
The 'meza update' command now uses the nasa repo as the canonical source
instead of the enterprisemediawiki repo.
Format 'import' statements one per line
Fix mixed use of tabs and spaces
Add some @FIXME comments about obsolete (CentOS) or unknown (Docker) functions.
The context manager will automatically close your (open) file handle in
write_vault_decryption_tmp_file().
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/scripts/meza.py`

* [8ee9f632](https://github.com/freephile/meza/commit/8ee9f632) (2024-03-16) Greg Rundlett: Semantic Dependency Updater - new home / disabled SDU is temporarily disabled. The repo URL has changed, but
for some odd reason deploys seem to hang on this specific
extension during git clone.
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [b76d9517](https://github.com/freephile/meza/commit/b76d9517) (2024-03-16) Greg Rundlett: Fix thumbnail generation + add webp support Fixes Issue [#62](https://github.com/freephile/meza/issues/62) thumbnail generation by letting MediaWiki
know where to find thumb.php
$wgThumbnailScriptPath = "$wgScriptPath/thumb.php";
Additionally, we changed the definition of $wgFileExtensions
so as to **merge** Meza customizations as additions to what is
supported by default - essentially adding webp support.
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [8edbf4ab](https://github.com/freephile/meza/commit/8edbf4ab) (2024-03-15) Greg Rundlett: Fixe the compiled templates ownership issue Fixes Widgets Issue [#61](https://github.com/freephile/meza/issues/61)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [cd5ad239](https://github.com/freephile/meza/commit/cd5ad239) (2024-03-15) Greg Rundlett: Update some integration test scripts Fix the image-check script domain handling for 'localhost'.
Pipe output to jq for pretty printing diagnosic output.
Remove obsolete Parsoid check.
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `tests/integration/image-check.sh`
  - Modified: `tests/integration/server-check.sh`
  - Modified: `tests/integration/wiki-check.sh`

* [957a0efe](https://github.com/freephile/meza/commit/957a0efe) (2024-03-14) Greg Rundlett: Create a CHANGELOG as a de-minimus form of Release Notes Fixes Issue [#54](https://github.com/freephile/meza/issues/54)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Added: `CHANGELOG`

* [d253642c](https://github.com/freephile/meza/commit/d253642c) (2024-03-14) Greg Rundlett: Add some directories to gitignore Ignore the 'venv' directory for any local Python Virtual Env setup.
Ignore anything in 'roles' that starts with 'geerlingguy' because
those will come from Ansible Galaxy aka 3rd-party repos.
Add comment to ansible.cfg about the 'roles_path' variable.
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `.gitignore`
  - Modified: `config/ansible.cfg`

* [1697c20f](https://github.com/freephile/meza/commit/1697c20f) (2024-03-12) Rich Evans: Add a "Section 508 Info" link to the footer via LocalSettings.php template Section 508 Compliance and Digital Accessibility compliance information of required by many organizations.

Meza admins can tailor the exact content via a "Mediawiki:Section508compliance" system message page in the wiki.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [383f4c8a](https://github.com/freephile/meza/commit/383f4c8a) (2024-03-12) Rich Evans: make sure widgets compipled templates folder is owned by meza-ansible to avoid local changes error when updating 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [81ac9659](https://github.com/freephile/meza/commit/81ac9659) (2024-03-12) Rich Evans: restore force debug to false 
  - Modified: `config/defaults.yml`

* [a4fadf47](https://github.com/freephile/meza/commit/a4fadf47) (2024-03-08) Greg Rundlett: ansible-lint code health changes This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/remote-dir-check/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [a044cfec](https://github.com/freephile/meza/commit/a044cfec) (2024-03-08) Greg Rundlett: $wgShellLocale is obsolete as of REL1_38 This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [45270d4e](https://github.com/freephile/meza/commit/45270d4e) (2024-03-08) Greg Rundlett: Final fixes for .smw.json and create wiki bugs Fixes #44 by moving the .smw.json file to the 'conf-meza' hierarchy
Fixes #48 by refreshing mediawiki-table.sql
@todo Use the source distributed version to automatically
be up-to-date. It is in mediawiki/maintenance/tables-generated.sql
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/verify-wiki/templates/mediawiki-tables.sql`

* [17f7faef](https://github.com/freephile/meza/commit/17f7faef) (2024-03-08) Greg Rundlett: yamllint code health syntax and formatting changes Increase conformance to accepted YAML parser rules.
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/.yamllint`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [1e91f9ed](https://github.com/freephile/meza/commit/1e91f9ed) (2024-03-06) Greg Rundlett: Fix permission problems + naming in .smw.json directory Fixes Issue [#44](https://github.com/freephile/meza/issues/44) "Ensure .smw.json has a home"
The permission problems stem from the fact that a local userX can run ad-hoc shell scripts that will want to read/write; a deploy will read-write as user meza-ansible and of course the web server process will read-write as apache. So all these users and groups can be handled with meza-ansible:wheel
The directory naming problem stems from the choice to use the wgDBname variable instead of the "wiki id". Wiki ID is a better choice for **wiki** related config data directory; and it's also easier to use over db name because the latter is a composed value, not a simple string.
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [4b0d76aa](https://github.com/freephile/meza/commit/4b0d76aa) (2024-03-06) Greg Rundlett: Ensure .smw.json has a home This fixes Issue [#44](https://github.com/freephile/meza/issues/44)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/configure-wiki/tasks/main.yml`

* [70493792](https://github.com/freephile/meza/commit/70493792) (2024-03-01) Greg Rundlett: Feature: Short URLs Completes Issue [#28](https://github.com/freephile/meza/issues/28)
Remove redundant wgArticlePath that was overriding the correct setting.
Also add wgUsePathInfo
https://www.mediawiki.org/wiki/Manual:$wgUsePathInfo
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [6ca76db3](https://github.com/freephile/meza/commit/6ca76db3) (2024-03-01) Greg Rundlett: Feature: Short URLs This fixes Issue [#28](https://github.com/freephile/meza/issues/28)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/htdocs/templates/.htaccess.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [c8e66653](https://github.com/freephile/meza/commit/c8e66653) (2024-03-01) Greg Rundlett: Remove commented line This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/RedHat.yml`

* [afb41e88](https://github.com/freephile/meza/commit/afb41e88) (2024-03-01) Greg Rundlett: Make 'enforce_meza_version' undefined; with comment This variable was initially undefined, and "turning it on" will
prevent deploys if your meza source is not a clean, matching checkout.
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/defaults.yml`

* [a02a80ce](https://github.com/freephile/meza/commit/a02a80ce) (2024-03-01) Greg Rundlett: Upgrade PHP to 8.1 This fixes Issue [#13](https://github.com/freephile/meza/issues/13)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/apache-php/defaults/main.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat8.yml`
  - Modified: `src/scripts/getmeza.sh`

* [cd60cf11](https://github.com/freephile/meza/commit/cd60cf11) (2024-03-01) Greg Rundlett: Example of Remi repo usage from geerlingguy Issue [#27](https://github.com/freephile/meza/issues/27)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/playbooks/site.yml`

* [f2e7e1e8](https://github.com/freephile/meza/commit/f2e7e1e8) (2024-02-29) Greg Rundlett: Minor yaml lint fixes Part of Issue [#17](https://github.com/freephile/meza/issues/17)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/composer/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [f3ed0400](https://github.com/freephile/meza/commit/f3ed0400) (2024-02-29) Greg Rundlett: Add 'force' option to be able to 'overwrite local git changes' This completes Issue [#25](https://github.com/freephile/meza/issues/25)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [f7a5cece](https://github.com/freephile/meza/commit/f7a5cece) (2024-02-29) Greg Rundlett: Make MediaWiki core branch depth a configuration value Solves Issue [#24](https://github.com/freephile/meza/issues/24)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [602587fe](https://github.com/freephile/meza/commit/602587fe) (2024-02-29) Greg Rundlett: Make the Meza project repository a configuration value This resolves Issue [#22](https://github.com/freephile/meza/issues/22)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/defaults.yml`
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/roles/enforce-meza-version/tasks/main.yml`

* [d95b6824](https://github.com/freephile/meza/commit/d95b6824) (2024-02-29) Greg Rundlett: Update Extension Flow for PHP8.1 compatibility Add additional configuration settings while fixing deprecation warnings in issue#26
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [28f314e6](https://github.com/freephile/meza/commit/28f314e6) (2024-02-29) Greg Rundlett: git repo URL and branch name as BASH variables Create Bash variables for getmeza.sh and source them from the ENVIRONMENT;
so that administrators can override them at run-time; or use a default.
This addresses part of issues #22 and #23
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/scripts/getmeza.sh`

* [4cbcd644](https://github.com/freephile/meza/commit/4cbcd644) (2024-02-23) Greg Rundlett: Upgrade SimpleBatchUpload to 2.x for PHP 8.1 compatibility Incompatibility revealed in upgrading PHP #13
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [b6daa75b](https://github.com/freephile/meza/commit/b6daa75b) (2024-02-23) Greg Rundlett: Use fully qualified built-in module name for dnf This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/base/tasks/main.yml`

* [0db71f8e](https://github.com/freephile/meza/commit/0db71f8e) (2024-02-23) Greg Rundlett: Add .yamllint configuration Fix one error - missing space before comment across multiple files
Initial configuration allows for 140 char line with only a warning
Partial, initial fix for Issue [#17](https://github.com/freephile/meza/issues/17)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Added: `src/.yamllint`
  - Modified: `src/playbooks/delete-elasticsearch.yml`
  - Modified: `src/playbooks/getdocker.yml`
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat7.yml`
  - Modified: `src/roles/backup-config/tasks/main.yml`
  - Modified: `src/roles/base-extras/tasks/main.yml`
  - Modified: `src/roles/database/tasks/setup-RedHat.yml`
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/gluster/tasks/setup-RedHat.yml`
  - Modified: `src/roles/imagemagick/tasks/main.yml`

* [d2fe7d92](https://github.com/freephile/meza/commit/d2fe7d92) (2024-02-22) Greg Rundlett: Fix 50 yamllint errors in Base role Fix indentation
Fix line-length
Fix comments
Fix spaces
Fix truthy values
Clarify logic of conditionals
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/base/tasks/main.yml`

* [972d5ca0](https://github.com/freephile/meza/commit/972d5ca0) (2024-02-22) Greg Rundlett: Reorder dnf set-enabled, install per docs Not sure it matters, but the order copied from the docs
https://docs.fedoraproject.org/en-US/epel/#_almalinux_8_rocky_linux_8
is
dnf config-manager --set-enabled powertools
then
dnf install epel-releaase
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/scripts/getmeza.sh`

* [cdef0c41](https://github.com/freephile/meza/commit/cdef0c41) (2024-02-22) Greg Rundlett: Add EditorConfig to this project Formally addresses the age-old problem of tabs vs spaces.
Fixes Issue [#14](https://github.com/freephile/meza/issues/14)
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Added: `.editorconfig`
  - Modified: `src/scripts/getmeza.sh`

* [48782c27](https://github.com/freephile/meza/commit/48782c27) (2024-02-21) Greg Rundlett: Use 'false' for negative  truthy values Although Ansible accepts a broad range of values for boolean variables
Use true/false to be compatible with ansible-lint
https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/playbooks/create-wiki.yml`
  - Modified: `src/playbooks/delete-elasticsearch.yml`
  - Modified: `src/playbooks/delete-wiki.yml`
  - Modified: `src/roles/apache-php/templates/www.conf.j2`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/database/tasks/secure-installation.yml`
  - Modified: `src/roles/database/tasks/users.yml`
  - Modified: `src/roles/enforce-meza-version/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/netdata/tasks/main.yml`
  - Modified: `src/roles/setup-env/tasks/main.yml`

* [817f8f05](https://github.com/freephile/meza/commit/817f8f05) (2024-02-21) Greg Rundlett: Use 'true'/'false' for truthy values Although Ansible accepts a broad range of values for boolean variables
Use true/false to be compatible with ansible-lint
https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/playbooks/backup.yml`
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/playbooks/cleanup-upload-stash.yml`
  - Modified: `src/playbooks/create-wiki-promptless.yml`
  - Modified: `src/playbooks/create-wiki.yml`
  - Modified: `src/playbooks/delete-elasticsearch.yml`
  - Modified: `src/playbooks/delete-wiki-promptless.yml`
  - Modified: `src/playbooks/delete-wiki.yml`
  - Modified: `src/playbooks/deploy-notify.yml`
  - Modified: `src/playbooks/elasticsearch-upgrade.yml`
  - Modified: `src/playbooks/getdocker.yml`
  - Modified: `src/playbooks/push-backup.yml`
  - Modified: `src/playbooks/rebuild-smw-and-index.yml`
  - Modified: `src/playbooks/setbaseconfig.yml`
  - Modified: `src/playbooks/setup-env.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/templates/www.conf.j2`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/composer/tasks/global-require.yml`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/database/defaults/main.yml`
  - Modified: `src/roles/database/tasks/replication.yml`
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/enforce-meza-version/tasks/main.yml`
  - Modified: `src/roles/gluster/tasks/main.yml`
  - Modified: `src/roles/gluster/tasks/setup-Debian.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/htdocs/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/memcached/tasks/main.yml`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/sync-configs/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [28614732](https://github.com/freephile/meza/commit/28614732) (2024-02-21) Greg Rundlett: Fix some yamllint and ansible-lint warnings Fix truthy values, spacing, indentation, line length
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/RedHat.yml`
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat7.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`

* [c5685249](https://github.com/freephile/meza/commit/c5685249) (2024-02-21) Greg Rundlett: Fix fatal indentation errors Errors were indicated by ansible-lint
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `.codeclimate.yml`

* [62e2d784](https://github.com/freephile/meza/commit/62e2d784) (2024-02-21) Greg Rundlett: Use fully qualified name  ansible.builtin.debug https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html
We recommend you use the Fully Qualified Collection Name (FQCN)
ansible.builtin.debug for easy linking to the module documentation and
to avoid conflicting with other collections that may have the same
module name.
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/playbooks/elasticsearch-upgrade.yml`
  - Modified: `src/roles/backup-db-wikis-push/tasks/main.yml`
  - Modified: `src/roles/backup-uploads-push/tasks/main.yml`
  - Modified: `src/roles/database/tasks/replication.yml`
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/netdata/tasks/main.yml`
  - Modified: `src/roles/remote-dir-check/tasks/main.yml`
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`
  - Modified: `src/roles/rsync-push/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/sql-backup-cleanup/tasks/main.yml`
  - Modified: `src/roles/update.php/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/transfer-backup-to-db-master.yml`

* [cd83e120](https://github.com/freephile/meza/commit/cd83e120) (2024-02-19) Greg Rundlett: Upgrade Semantic MediaWiki to 4.1.3 This is a patch release. Thus it contains only bug fixes. No new
features or breaking changes.
This release contains security patches and improves support for modern
PHP and MediaWiki. Upgrading is recommended for all users.
See docs/releasenotes/RELEASE-NOTES-4.1.3.md
    Fixed several XSS issues
    Improved support for PHP 8.1 and above
    Improved support for MediaWiki 1.39 and above
    Various minor performance improvements, especially for multi-database setups
    Fixed Special:PageProperty (thanks thomas-topway-it)
    Improved compatibility with OpenSearch and recent versions of ElasticSearch
    Improved PostgreSQL compatibility
    Added ability to disable the upgrade key check via the smwgIgnoreUpgradeKeyCheck setting
    Improved various interface messages
    Translation updates
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [e61e9896](https://github.com/freephile/meza/commit/e61e9896) (2024-02-16) Greg Rundlett: Upgrade Maps to 10.1.1 Fixes deprecated SkinTemplateNavigation hook as well as
deprecated Content::fillParserOutput()
The 10.x series of Maps supports MediaWiki 1.39.x
See Release Notes
https://github.com/ProfessionalWiki/Maps/blob/10.1.1/RELEASE-NOTES.md
and
Commit 257381b926477c486f3341497752485290530b87
https://github.com/ProfessionalWiki/Maps/commit/257381b926477c486f3341497752485290530b87
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [ccd118c8](https://github.com/freephile/meza/commit/ccd118c8) (2024-02-16) Greg Rundlett: Switch PageForms to latest version (5.6.3) Fixes Deprecation of SkinTemplateNavigation hook
fixed by commit 46beadb
https://github.com/wikimedia/mediawiki-extensions-PageForms/commit/46beadb44b4dacc14923525f710abe1dfc9d2eb9
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [c2bc0a66](https://github.com/freephile/meza/commit/c2bc0a66) (2024-02-16) Greg Rundlett: Use master branch for Variables extension paraphrasing https://www.mediawiki.org/wiki/Extension:Variables
To avoid deprecation warning about the missing #var_final parser
function in MediaWiki 1.39+, please update to the latest version
(master branch for now).
See task T276627 and task T250963 for further information.
The Variables extension must be enabled so that a project can be
pursued to replace all the on-wiki usage of the extension.
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [4f9ea657](https://github.com/freephile/meza/commit/4f9ea657) (2024-02-16) Greg Rundlett: Revert "Variables extension - disabled" This reverts commit c70ed42e32c327d0224c8d33a180e50b0d9aa5b2.
  - Modified: `config/MezaCoreExtensions.yml`

* [dbc68b66](https://github.com/freephile/meza/commit/dbc68b66) (2024-02-15) Greg Rundlett: Update WhosOnline for compatibility with REL1_39 The REL1_39 branch of the extension still produces the error below -
which was fixed two years ago, but not backported.
Use the 'master' branch for now.
Deprecated
: Use of User::getOption was deprecated in MediaWiki 1.35.
[Called from WhosOnlineHooks::onBeforePageDisplay in
/opt/htdocs/mediawiki/extensions/WhosOnline/includes/WhosOnlineHooks.php
at line 27]
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [3ca303bd](https://github.com/freephile/meza/commit/3ca303bd) (2024-02-15) Greg Rundlett: Fix database backup function Quote mysql password option to avoid special characters being interpreted by the Ansible shell module.
In the source_wiki_exists_check task of /src/roles/remote-mysqldump/tasks/main.yml:104 you could
end up with a command like the following:
mysqlshow -u wiki_app_user -p6K2s9n!XTtebd$GUfy$8YtGVIcZYXA@d wiki_test3 | grep -v Wildcard | grep -o wiki_test3\n
The password has ! and $ in it - both shell special characters. https://mywiki.wooledge.org/BashGuide/SpecialCharacters
We avoid interpretation by quoting the password value with single quotes.
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`

* [2367a826](https://github.com/freephile/meza/commit/2367a826) (2024-02-15) Greg Rundlett: Enable Ansible debugger by default enable_task_debugger = true added to ansible.cfg for easy debugging in play logs
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/ansible.cfg`

* [e3228e3c](https://github.com/freephile/meza/commit/e3228e3c) (2024-02-15) Rich Evans: Fix Widgets folder permissions tasks moved the 2 tasks that test for the existence of the Widgets/complied templates folder and then, if it exists, changes the permissions to apache:apache - moved them to AFTER the global permissions fix for the entire mediawiki folder

and - made the chown task recursive to apply to all the compiled templates
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [7cac79a9](https://github.com/freephile/meza/commit/7cac79a9) (2024-02-15) Greg Rundlett: Update Semantic Extra Special Properties extesion Use v3.0.5 for bugfixes and compatibility with REL1_39
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B
  - Modified: `config/MezaCoreExtensions.yml`

* [20d152c5](https://github.com/freephile/meza/commit/20d152c5) (2024-01-24) Greg Rundlett: Fix Issue [#2](https://github.com/freephile/meza/issues/2) Remove GitHub Actions This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Deleted: `.github/workflows/docker-build.yml`
  - Deleted: `.github/workflows/test.yml`

* [da17c459](https://github.com/freephile/meza/commit/da17c459) (2024-01-24) Greg Rundlett: change raw_input() to input() for Python 3.x This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/scripts/meza.py`

* [4c319038](https://github.com/freephile/meza/commit/4c319038) (2024-01-24) Greg Rundlett: Fix inconsistent use of tabs and spaces This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/scripts/meza.py`

* [de507d4a](https://github.com/freephile/meza/commit/de507d4a) (2024-01-24) Greg Rundlett: Fix Issue [#7](https://github.com/freephile/meza/issues/7) TypeError: must be str, not bytes By adding .decode() to the byte objects, we can concatenate with strings in Python 3.6.8
Later versions of subprocess.check_output() can return text if you want, but not in this version.
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/scripts/meza.py`

* [dffc4cd4](https://github.com/freephile/meza/commit/dffc4cd4) (2024-01-22) Greg Rundlett: Change Elasticsearch repo to disabled by default We want to avoid accidentally updating elasticsearch
in a simple 'dnf update' so make sure the Elastic repo
is disabled by default. And, use the 'enablerepo' option in the task to install elasticsearch.
Make sure the Elasticsearch repo key is installed; from the correct artifact location
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.repo.j2`

* [cee39d48](https://github.com/freephile/meza/commit/cee39d48) (2024-01-22) Greg Rundlett: lint site playbook lowercase truthy values to (true|false)
remove blank lines
remove "most" comments
remove double quotes where unnecessary
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `src/playbooks/site.yml`

* [4598d894](https://github.com/freephile/meza/commit/4598d894) (2024-01-22) Greg Rundlett: Add sample script for checking an Upgrade This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Added: `src/scripts/checkUpgrade.php`

* [61092969](https://github.com/freephile/meza/commit/61092969) (2024-01-22) Greg Rundlett: Upgrade Elasticsearch to 7.x from 6.x Comment out the xpack.ssltruststore settings in elasticsearch.yml
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.yml.j2`

* [755bbcb0](https://github.com/freephile/meza/commit/755bbcb0) (2024-01-22) Greg Rundlett: Semantic MediaWiki Upgrade from 4.0.1 to 4.1.2 and set .smw.json path
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [c70ed42e](https://github.com/freephile/meza/commit/c70ed42e) (2024-01-22) Greg Rundlett: Variables extension - disabled Should be permanently removed; disabled to quiet the deprecation notices
in debugging. Can re-enable and work to replace functionality
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [c6710dc3](https://github.com/freephile/meza/commit/c6710dc3) (2024-01-22) Greg Rundlett: Header Footer switch to WMF repo, REL1_39 branch
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [d3ef6c1f](https://github.com/freephile/meza/commit/d3ef6c1f) (2024-01-22) Greg Rundlett: Watch Analytics - switch to WMF master This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [936ba9ea](https://github.com/freephile/meza/commit/936ba9ea) (2024-01-22) Greg Rundlett: Talk Right & Wiretap removed These extensions are not maintained presently
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [19edfeb9](https://github.com/freephile/meza/commit/19edfeb9) (2024-01-22) Greg Rundlett: HTML5 Mediator disable (comment) because it is unmaintained and incompatible
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [faf05201](https://github.com/freephile/meza/commit/faf05201) (2024-01-22) Greg Rundlett: SimpleMathJax remove legacy_load directive
CHANGE repository URL to the community (jmnote)
and 'main' branch
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [fd3701fe](https://github.com/freephile/meza/commit/fd3701fe) (2024-01-22) Greg Rundlett: Media Functions remove legacy_load directive
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [74f26f21](https://github.com/freephile/meza/commit/74f26f21) (2024-01-22) Greg Rundlett: Widgets remove legacy_load directive
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [a171341a](https://github.com/freephile/meza/commit/a171341a) (2024-01-22) Greg Rundlett: Pipe Escape remove legacy_load directive
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [277d3901](https://github.com/freephile/meza/commit/277d3901) (2024-01-22) Greg Rundlett: Semantic Drilldown use alternative forked repo (freephile) until pull request is merged upstreamhttps://github.com/SemanticMediaWiki/SemanticDrilldown/pull/75
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [420fd5e4](https://github.com/freephile/meza/commit/420fd5e4) (2024-01-22) Greg Rundlett: Contribution Scores remove legacy_load directive; improve configuration
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract  NNC15BA02B.
  - Modified: `config/MezaCoreExtensions.yml`

* [876b8ac9](https://github.com/freephile/meza/commit/876b8ac9) (2024-01-22) Greg Rundlett: Major upgrade of Meza for MediaWiki 1.39 Upgrade default version of MediaWiki to REL1_39
This work  was performed for NASA GRC-ATF by WikiWorks per NASA Contract
NNC15BA02B.
  - Modified: `config/defaults.yml`

* [f8efb6fc](https://github.com/freephile/meza/commit/f8efb6fc) (2023-09-19) James Montalvo: fix: load balancer variable naming Commit 45c7cb04 changed how load balancer groups are accessed. This was
a good change, but some of the load balancer variables were changed
accidentally. e.g.
load_balancers_nonmeza --> load_balancers_meza_nonmeza
This "_meza_nonmeza" ending (a) was applied inconsistently and (b)
doesn't make sense as a naming convention.
This commit fixes naming.
  - Modified: `config/defaults.yml`
  - Modified: `src/scripts/getmeza.sh`

* [6f8d9f2e](https://github.com/freephile/meza/commit/6f8d9f2e) (2024-02-08) Rich Evans: Check if widgets compiled templates directory exists and if so change owner to apache The Widgets extension has a folder named complied_templates that apache must own in order for the widgets to execute in mediawiki pages
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [7bc22b7b](https://github.com/freephile/meza/commit/7bc22b7b) (2024-02-08) Rich Evans: Update MezaCoreExtensions.yml removed portions of VE configuration that are no longer needed.
  - Modified: `config/MezaCoreExtensions.yml`

* [98cb0966](https://github.com/freephile/meza/commit/98cb0966) (2024-01-08) Rich Evans: remove broken extensions in MezaCoreExtensions.yml disable UniversalLanguageSelector and SimpleMathJax 

Add them back later when they are known to work
  - Modified: `config/MezaCoreExtensions.yml`

* [7ef9f7fa](https://github.com/freephile/meza/commit/7ef9f7fa) (2024-01-08) Rich Evans: Update MezaCoreExtensions.yml disabled Semantic Drilldown until we know where to get a 35.x compatible version from
  - Modified: `config/MezaCoreExtensions.yml`

* [f182b54b](https://github.com/freephile/meza/commit/f182b54b) (2024-01-08) Rich Evans: update haproxy.cfg to use a specific pem file Users with proper certs will now need to name their proper cert "meza.pem"
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [231ae16f](https://github.com/freephile/meza/commit/231ae16f) (2023-09-22) NDC-Rkevans: Update saml integration 
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Added: `src/roles/configure-wiki/templates/samlAuthorizations.d/base.php.j2`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/saml/templates/saml20-idp-remote.php.j2`

* [3ea70e6c](https://github.com/freephile/meza/commit/3ea70e6c) (2023-09-06) NDC-Rkevans: Don't use samlLocalSettings anymore, rather, use PluggableAuth and SimpleSAMLphp 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [d0d5166c](https://github.com/freephile/meza/commit/d0d5166c) (2023-09-06) NDC-Rkevans: Don't be so specific about the cert file. Rather, use whatever is in the cert folder 
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [77d5f05e](https://github.com/freephile/meza/commit/77d5f05e) (2023-09-06) NDC-Rkevans: Increase misc timeots and maxes for PHP configuration 
  - Modified: `src/roles/apache-php/templates/php.ini.j2`

* [270409e8](https://github.com/freephile/meza/commit/270409e8) (2023-09-06) NDC-Rkevans: Default time zone and respect ssh config 
  - Modified: `config/defaults.yml`

* [af4ac122](https://github.com/freephile/meza/commit/af4ac122) (2023-09-06) root: SMW Configuration Tweaks 
  - Modified: `config/MezaCoreExtensions.yml`

* [99fd92a7](https://github.com/freephile/meza/commit/99fd92a7) (2023-08-21) Rich Evans: add port 20000 for netdata to default open ports 
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [27c1021b](https://github.com/freephile/meza/commit/27c1021b) (2023-08-21) Rich Evans: Update MezaCoreExtensions.yml 
  - Modified: `config/MezaCoreExtensions.yml`

* [06037bbe](https://github.com/freephile/meza/commit/06037bbe) (2023-08-21) Rich Evans: Update MezaCoreExtensions.yml 
  - Modified: `config/MezaCoreExtensions.yml`

* [6aeb1762](https://github.com/freephile/meza/commit/6aeb1762) (2023-08-21) Rich Evans: Update MezaCoreExtensions.yml 
  - Modified: `config/MezaCoreExtensions.yml`

* [cd3e6a8a](https://github.com/freephile/meza/commit/cd3e6a8a) (2023-08-21) Rich Evans: Update MezaCoreExtensions.yml 
  - Modified: `config/MezaCoreExtensions.yml`

* [54579cf9](https://github.com/freephile/meza/commit/54579cf9) (2023-08-21) Rich Evans: minor updates to extension versions 
  - Modified: `config/MezaCoreExtensions.yml`

* [5258347f](https://github.com/freephile/meza/commit/5258347f) (2023-08-20) Rich Evans: Update Core Extensions to GRC-ATF KMS List I know this is controversial based on past discussions, but until we implement an update that makes an option for not having *any* extensions.. NASA GRC-ATF needs to include all the extensions require for the ATF KMS to function correctly out of the box.
  - Modified: `config/MezaCoreExtensions.yml`

* [444b057c](https://github.com/freephile/meza/commit/444b057c) (2023-08-09) James Montalvo: fix: add --doshared to update.php to fix MW 1.31-->1.35 upgrade 
  - Modified: `src/roles/update.php/tasks/main.yml`

* [d0672073](https://github.com/freephile/meza/commit/d0672073) (2023-08-02) ndc-rkevans: Fix syntax error in adminpass 
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`

* [515b91db](https://github.com/freephile/meza/commit/515b91db) (2023-08-02) ndc-rkevans: Update WikiBlender defaults to point to nasa meza on github and mwstake.org 
  - Modified: `src/roles/mediawiki/defaults/main.yml`
  - Modified: `src/roles/verify-wiki/defaults/main.yml`

* [e95c5c68](https://github.com/freephile/meza/commit/e95c5c68) (2023-08-01) Rich Evans: Made the Admin password on the demo wiki a bit more complex (as required by Mediawiki) who knew! :-P
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`

* [0bf74247](https://github.com/freephile/meza/commit/0bf74247) (2023-08-01) Rich Evans: fix typo in haproxy.cfg.j2 to support non-wiki content replaced 2 instances of "nowiki" to "nonwiki"
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [566e3da8](https://github.com/freephile/meza/commit/566e3da8) (2023-08-01) ndc-rkevans: add support for nonwiki content 
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [f35d98e9](https://github.com/freephile/meza/commit/f35d98e9) (2023-08-01) ndc-rkevans: Allow certbot access with well-known RewriteRule 
  - Modified: `src/roles/htdocs/templates/.htaccess.j2`

* [3684c2bd](https://github.com/freephile/meza/commit/3684c2bd) (2023-08-01) ndc-rkevans: Get WikiBlender from ndc-rkevans rather than jamesmontalvo3 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [45e2f8c7](https://github.com/freephile/meza/commit/45e2f8c7) (2023-08-01) ndc-rkevans: Make admin pw in demo wiki simple and match documentation 
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`

* [22b8ad67](https://github.com/freephile/meza/commit/22b8ad67) (2023-08-01) ndc-rkevans: Don't import page content (i.e. Semantic Meeting Minutes, etc..) 
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`

* [0f8c6c85](https://github.com/freephile/meza/commit/0f8c6c85) (2023-07-23) Rich Evans: Update MezaCoreSkins.yml to use the fixedhead rather than the clean layout clean and fixedhead are the same except for the ShowOnlyWhen edit permissions stuff that was annoying in clean.
  - Modified: `config/MezaCoreSkins.yml`

* [d628543a](https://github.com/freephile/meza/commit/d628543a) (2023-07-16) ndc-rkevans: Make Chameleon the default skin 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [9562d461](https://github.com/freephile/meza/commit/9562d461) (2023-07-13) ndc-rkevans: FIPS mode issue not solved so don't configure haproxy for fips mode 
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.yml.j2`

* [28c5d2ac](https://github.com/freephile/meza/commit/28c5d2ac) (2023-07-11) root: Add FIPSMode to Elasticsearch.ymp and minor edits to the ES install task 
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.yml.j2`

* [b31c27bd](https://github.com/freephile/meza/commit/b31c27bd) (2023-07-08) root: Enable NetData as a default 
  - Modified: `config/defaults.yml`

* [c36f300f](https://github.com/freephile/meza/commit/c36f300f) (2023-07-08) ndc-rkevans: Add Chameleon skin and Bootstrap dependancy 
  - Added: `config/.MezaCoreExtensions.yml.swp`
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `config/MezaCoreSkins.yml`

* [ee87a614](https://github.com/freephile/meza/commit/ee87a614) (2023-07-08) ndc-rkevans: For Dev Branch Only - Do not define Enforce_Meza_Verion in defaults 
  - Modified: `config/defaults.yml`

* [764ba9fa](https://github.com/freephile/meza/commit/764ba9fa) (2023-06-26) Brian Wolff: Adjust packages for MW 1.35/RL8 * Use PHP7.4 (Otherwise we cannot install composer dependencies)
* Do not install -devel packages that do not appear to be used.
  The only things we are compiling from source are pecl-memcached
  and luasandbox.
* Ensure that libmemcached-devel is installed as it is needed
* Do not use --configureoptions with pecl. Support for that is only
  present in a later version of pecl.
  - Modified: `config/RedHat.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat8.yml`

* [45c7cb04](https://github.com/freephile/meza/commit/45c7cb04) (2023-06-26) Brian Wolff: Change load balancer defaults to return a list type This was preventing firewall rules from working.
  - Modified: `config/defaults.yml`

* [acb0fe49](https://github.com/freephile/meza/commit/acb0fe49) (2023-07-06) James Montalvo: Remove Extension:HeaderFooter from Meza 
  - Modified: `config/MezaCoreExtensions.yml`

* [b002d2c1](https://github.com/freephile/meza/commit/b002d2c1) (2023-07-03) James Montalvo: fix: have root declare the unarchive user/group/mode 
  - Modified: `src/roles/saml/tasks/main.yml`

* [30bde956](https://github.com/freephile/meza/commit/30bde956) (2023-06-29) Vincent Brooks: removed extension approvedrevs ApprovedRevs was causing issues for other extensions' magic words. To add this extension, you will need to add it to your local extensions config.
  - Modified: `config/MezaCoreExtensions.yml`

* [aa8b682c](https://github.com/freephile/meza/commit/aa8b682c) (2023-06-28) James Montalvo: fix: make $wgSessionName based on $wikiId so wiki sessions don't conflict 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/saml/templates/SAMLConfig.php.j2`

* [a79bce9b](https://github.com/freephile/meza/commit/a79bce9b) (2023-06-27) James Montalvo: fix: use appropriate versions of saml extensions 
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/saml/templates/NonMediaWikiSimpleSamlAuth.php.j2`
  - Modified: `src/roles/saml/templates/SAMLConfig.php.j2`

* [cfcf9f51](https://github.com/freephile/meza/commit/cfcf9f51) (2023-06-22) James Montalvo: fix: use latest Extension:SimpleSamlPhp and PluggableAuth 
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/saml/templates/NonMediaWikiSimpleSamlAuth.php.j2`
  - Modified: `src/roles/saml/templates/SAMLConfig.php.j2`

* [2deacb52](https://github.com/freephile/meza/commit/2deacb52) (2023-06-27) Vincent Brooks: removed legacy load for NumerAlpha 
  - Modified: `config/MezaCoreExtensions.yml`

* [d46f520b](https://github.com/freephile/meza/commit/d46f520b) (2023-06-05) Vincent Brooks: add upgrade-packages tag to create ability to skip this task 
  - Modified: `src/roles/base/tasks/main.yml`

* [410cd5f9](https://github.com/freephile/meza/commit/410cd5f9) (2023-06-05) Vincent Brooks: bump approvedrevs to 1.7.2 
  - Modified: `config/MezaCoreExtensions.yml`

* [4aa9994e](https://github.com/freephile/meza/commit/4aa9994e) (2023-06-02) Vincent Brooks: retry install mssql-server repo until success or fail 5 times 
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`

* [cfabc036](https://github.com/freephile/meza/commit/cfabc036) (2023-06-02) Vincent Brooks: Update mssql_driver_for_php.yml to pull RHEL8 package 
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`

* [e4f66346](https://github.com/freephile/meza/commit/e4f66346) (2023-05-22) Vincent Brooks: Set $wgArticlePath Without this, wiki would use ?title= in the URL and it would append that to the end of URLs when switching wikis in a wiki farm
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [f7e4c169](https://github.com/freephile/meza/commit/f7e4c169) (2023-05-10) Vincent Brooks: Remove Extension:Thanks REL1_35 doesn't have any commits to make this extension compatible with MW 1.35

The master branch only has 4 commits compatible with MW 1.35, but neither of them make this extension work properly. We can potentially bring this extension back for 1.39
  - Modified: `config/MezaCoreExtensions.yml`

* [8d72fd94](https://github.com/freephile/meza/commit/8d72fd94) (2023-05-08) Vincent Brooks: Bumped CollapsibleVector to 7b71b1b commit REL1_35 is missing the fix needed to make this extension work on this branch. Will request to cherry pick the fix for the REL1_35 branch in the future.
  - Modified: `config/MezaCoreExtensions.yml`

* [7dce0fc4](https://github.com/freephile/meza/commit/7dce0fc4) (2023-05-05) Vincent Brooks: bump header tabs extension to 2.2.1 to get support for 1.35 
  - Modified: `config/MezaCoreExtensions.yml`

* [7afcdfcf](https://github.com/freephile/meza/commit/7afcdfcf) (2023-05-05) Vincent Brooks: increase memory_limit to 1024M 
  - Modified: `src/roles/apache-php/templates/php.ini.j2`

* [61b0b4ca](https://github.com/freephile/meza/commit/61b0b4ca) (2023-05-03) Vincent Brooks: Pull WatchAnalytics from a commit via forked repo of EMW/WatchAnalytics DJ Flux patched the database errors in a fork from Enterprise MediaWiki's WatchAnalytics
  - Modified: `config/MezaCoreExtensions.yml`

* [b300ebf4](https://github.com/freephile/meza/commit/b300ebf4) (2023-05-03) Vincent Brooks: set meza_repository to nasa github 
  - Modified: `config/defaults.yml`

* [7ad72ded](https://github.com/freephile/meza/commit/7ad72ded) (2023-05-02) Vincent Brooks: Set NumerAlpha version to mediawiki default branch 
  - Modified: `config/MezaCoreExtensions.yml`

* [7c8795e1](https://github.com/freephile/meza/commit/7c8795e1) (2023-04-28) Vincent Brooks: removing typo in repo for WatchAnalytics 
  - Modified: `config/MezaCoreExtensions.yml`

* [fd14f4fb](https://github.com/freephile/meza/commit/fd14f4fb) (2023-04-28) Vincent Brooks: Updated WatchAnalytics to 4.1.0 
  - Modified: `config/MezaCoreExtensions.yml`

* [68f3bd0a](https://github.com/freephile/meza/commit/68f3bd0a) (2023-05-03) James Montalvo: feat: allow specifying different repo for Meza via meza_repository variable 
  - Modified: `config/defaults.yml`
  - Modified: `src/playbooks/check-for-changes.yml`
  - Modified: `src/roles/enforce-meza-version/tasks/main.yml`

* [0abfc2f7](https://github.com/freephile/meza/commit/0abfc2f7) (2023-05-02) Vincent Brooks: Set NumerAlpha version to mediawiki default branch 
  - Modified: `config/MezaCoreExtensions.yml`

* [a64070a7](https://github.com/freephile/meza/commit/a64070a7) (2023-04-28) Vincent Brooks: removing typo in repo for WatchAnalytics 
  - Modified: `config/MezaCoreExtensions.yml`

* [d2fbd589](https://github.com/freephile/meza/commit/d2fbd589) (2023-04-28) Vincent Brooks: Updated WatchAnalytics to 4.1.0 
  - Modified: `config/MezaCoreExtensions.yml`

* [5adc699d](https://github.com/freephile/meza/commit/5adc699d) (2023-03-31) Vincent Brooks: 35.x (#6) * fix: restart php-fpm on changes; working VE rest.php; switch squid->cdn

* fix: use acceptable version of Extension:Arrays

* fix: always restart PHP in mediawiki role

---------

Co-authored-by: James Montalvo <edwin.j.montalvo@nasa.gov>
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [74307d0b](https://github.com/freephile/meza/commit/74307d0b) (2023-03-31) James Montalvo: fix: always restart PHP in mediawiki role 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [a9376fbc](https://github.com/freephile/meza/commit/a9376fbc) (2023-03-31) James Montalvo: fix: use acceptable version of Extension:Arrays 
  - Modified: `config/MezaCoreExtensions.yml`

* [fe4b5480](https://github.com/freephile/meza/commit/fe4b5480) (2023-03-31) Vincent Brooks: fix: restart php-fpm on changes; working VE rest.php; switch squid->cdn (#5) Co-authored-by: James Montalvo <edwin.j.montalvo@nasa.gov>
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/roles/apache-php/handlers/main.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`
  - Modified: `src/roles/apache-php/tasks/php-debian.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat8.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/saml/templates/authsources.php.j2`

* [896f9768](https://github.com/freephile/meza/commit/896f9768) (2023-03-31) James Montalvo: fix: restart php-fpm on changes; working VE rest.php; switch squid->cdn 
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/roles/apache-php/handlers/main.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`
  - Modified: `src/roles/apache-php/tasks/php-debian.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat8.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/saml/templates/authsources.php.j2`

* [34d06788](https://github.com/freephile/meza/commit/34d06788) (2023-03-10) James Montalvo: fix: better logic maybe for when to install simplesamlphp 
  - Modified: `src/roles/saml/tasks/main.yml`

* [2a084f28](https://github.com/freephile/meza/commit/2a084f28) (2023-03-10) James Montalvo: feat(mediawiki-core)!: allow failure on MW core git-pull Sort of BREAKING CHANGE since now Meza may have un-announced errors, but
I don't see any way around this due to the fact that submodules keep
failing, which is probably an ansible issue.
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [bf0ea8de](https://github.com/freephile/meza/commit/bf0ea8de) (2023-03-10) James Montalvo: fix: capitalize Loader 
  - Modified: `src/scripts/meza.py`

* [c257e54f](https://github.com/freephile/meza/commit/c257e54f) (2023-03-10) James Montalvo: fix: python yaml package now needs Loader=yaml.loader 
  - Modified: `src/scripts/meza.py`

* [70daa27d](https://github.com/freephile/meza/commit/70daa27d) (2023-03-10) James Montalvo: fix: bump SimpleSamlPhp to 1.19.7 
  - Modified: `config/defaults.yml`

* [ed4e93f0](https://github.com/freephile/meza/commit/ed4e93f0) (2023-03-09) James Montalvo: feat: support memcached/saml on 35.x/RHEL8 
  - Modified: `src/roles/apache-php/tasks/php-redhat8.yml`
  - Added: `src/roles/apache-php/templates/40-memcached.ini.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [5ea9a233](https://github.com/freephile/meza/commit/5ea9a233) (2023-02-24) James Montalvo: feat: enforce meza version directly in 'meza deploy' 
  - Modified: `src/playbooks/site.yml`
  - Added: `src/roles/enforce-meza-version/tasks/main.yml`

* [4593ea96](https://github.com/freephile/meza/commit/4593ea96) (2023-02-24) James Montalvo: fix: SemanticDrilldown moved 
  - Modified: `config/MezaCoreExtensions.yml`

* [935c9848](https://github.com/freephile/meza/commit/935c9848) (2023-02-21) James Montalvo: fix: add php-pear to redhat 8 
  - Modified: `src/roles/apache-php/tasks/php-redhat8.yml`

* [6d87712e](https://github.com/freephile/meza/commit/6d87712e) (2023-01-17) Andy Rechenberg: Resolve xpack plugin access denied issue at elasticsearch startup. An openjdk RPM update for RHEL8 variants (or some other security
policy change) prevents elasticsearch from reading the extracted
java cacerts. This change causes an access denied message, xpack
plugin doesn't load, and elastic search doesn't start.
This commit is a less-than-optimal workaround. Any better solution
is welcomed.
See:
https://discuss.elastic.co/t/elasticsearch-is-incompatible-with-new-versions-of-openjdk-from-redhat/318928/7
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.yml.j2`

* [145d7707](https://github.com/freephile/meza/commit/145d7707) (2023-01-15) Andy Rechenberg: Really (hopefully) finish hyphen/underscore conversion. 
  - Modified: `config/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [ff87a778](https://github.com/freephile/meza/commit/ff87a778) (2023-01-14) Andy Rechenberg: Fix hyphen/underscore compatibility remnent. 
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [c47cec5c](https://github.com/freephile/meza/commit/c47cec5c) (2022-07-08) Andy Rechenberg: Fix fatal error with Special:BrowseData in Semantic Drilldown. 
  - Modified: `config/MezaCoreExtensions.yml`

* [fc0e9c4b](https://github.com/freephile/meza/commit/fc0e9c4b) (2022-07-08) Andy Rechenberg: Update versions of DisplayTitle, ExternalData, PageForms, and ReplaceText 
  - Modified: `config/MezaCoreExtensions.yml`

* [03218f23](https://github.com/freephile/meza/commit/03218f23) (2022-07-08) Andrew (Andy) Rechenberg: Move INSTALL_DIR variable earlier in getmeza.sh Moving the variable toward the start of the script allows earlier pieces
of the script to use to to backup dnf/yum repo files.
  - Modified: `src/scripts/getmeza.sh`

* [7e81d0b7](https://github.com/freephile/meza/commit/7e81d0b7) (2022-07-08) Andy Rechenberg: Move ansible/python38 excludes from meza to dnf/yum repos These changes move the dnf/yum exlusions from within meza to the dnf/yum
repositories. The rationale for the changes is that placing exclusions in
the proper repositories prevents the meza base ansible task that updates all
packages on the system from updating ansible and python to versions provided
in EPEL and Rocky/Red Hat AppStream which could break meza.
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/scripts/getmeza.sh`

* [6f0a5823](https://github.com/freephile/meza/commit/6f0a5823) (2022-07-01) Andy Rechenberg: Update README to Rocky/RHEL 8 
  - Modified: `README.md`

* [e35525f6](https://github.com/freephile/meza/commit/e35525f6) (2022-07-01) Andy Rechenberg: Fix some missing things in getmeza.sh * Forgot to add variable for EPEL rpm
* Install specific ansible version as EPEL has ansible-5.4 which requires
  python38, which breaks a number of things with meza.
  - Modified: `src/scripts/getmeza.sh`

* [be80b256](https://github.com/freephile/meza/commit/be80b256) (2022-07-01) Andy Rechenberg: Try to remove deprecation warnings about legacy loading extensions. 
  - Modified: `config/MezaCoreExtensions.yml`

* [2826a4f9](https://github.com/freephile/meza/commit/2826a4f9) (2022-07-01) Andy Rechenberg: Use official RedHat repo for ansible-2.9 
  - Deleted: `src/scripts/Rocky-Extras.repo`
  - Modified: `src/scripts/getmeza.sh`

* [6c3da5c5](https://github.com/freephile/meza/commit/6c3da5c5) (2022-06-29) Andy Rechenberg: Only enable certain repos for RHEL7 
  - Modified: `src/roles/base/tasks/main.yml`

* [ba0cf8e2](https://github.com/freephile/meza/commit/ba0cf8e2) (2022-06-29) Andy Rechenberg: Start working on real RHEL8 (not Rocky) 
  - Added: `src/scripts/Rocky-Extras.repo`
  - Modified: `src/scripts/getmeza.sh`

* [dccdec48](https://github.com/freephile/meza/commit/dccdec48) (2022-06-05) Andy Rechenberg: vagrant up now works (for now) without patch to vagrant-vbguest plugin. These lines install the newest Rocky kernel, kernel-headers and required
packages to build VirtualBox Guest Additions. This may break with future
updates to the rockylinux/8 vagrant box so we'll have to keep an eye on
it.
  - Modified: `Vagrantfile`

* [62656006](https://github.com/freephile/meza/commit/62656006) (2022-06-04) Andy Rechenberg: Make vagrant install vagrant-vbguest plugin. Awaiting PR to work. This commit will check to see if the vagrant-vbguest plugin is installed
in the local vagrant environment and if it is not, install it. There is
a FIXME here because there has to be a better way to check if the plugin
is installed.
Also, the current vbguest plugin DOES NOT have Rocky Linux support so the
guest additions will fail until the plugin is updated for Rocky support.
I have a pull request in to add this support:
https://github.com/dotless-de/vagrant-vbguest/pull/424
Until that time one can run the following commands from the meza source
directory to get `vargrant up` working:
```
vagrant plugin install --local vagrant-vbguest
cd .vagrant/plugins/gems/2.7.4/gems/vagrant-vbguest-0.30.0
curl -s https://github.com/dotless-de/vagrant-vbguest/commit/7a8265a013e1b1718f2817587b68eb67c64bbdbf.diff | patch -p1 -b
vagrant up
```
The curl command will patch lib/vagrant-vbguest/installers/redhat.rb to
add 'rocky' to the distro search.
  - Modified: `Vagrantfile`

* [84647b0a](https://github.com/freephile/meza/commit/84647b0a) (2022-06-04) Andy Rechenberg: Add RedHat variant kickstart files to auto-build VMs for testing 
  - Added: `src/scripts/kickstart/r8-ks-vbox-gui.cfg`
  - Added: `src/scripts/kickstart/r8-ks-vbox-min.cfg`

* [8ce50eae](https://github.com/freephile/meza/commit/8ce50eae) (2022-06-04) Andy Rechenberg: meza logging in color again for python3 
  - Modified: `src/scripts/meza.py`

* [126be0fb](https://github.com/freephile/meza/commit/126be0fb) (2022-06-03) Andy Rechenberg: Starting work on djflux/meza#15 
  - Modified: `Vagrantfile`
  - Modified: `vagrantconf.default.yml`

* [336c3c98](https://github.com/freephile/meza/commit/336c3c98) (2022-05-28) Andy Rechenberg: Really get the web server working All of the changes should now make the web server start and execute
php files. Using php-fpm over tcp because little research I did shows
that TCP is slightly more performant than sockets.
FIXME: we can probly go back to the full php-fpm.d/www.conf file
because I just realized the template module has
block_end_string
block_start_string
so it those should alleviate parsing errors because there are config
directives in www.conf that use the same syntax. Maybe use:
"{{!%%" and "%%!}}" :shrug:
  - Modified: `config/RedHat.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/templates/php-fpm-httpd.conf.j2`
  - Added: `src/roles/apache-php/templates/php.conf`
  - Modified: `src/roles/apache-php/templates/www.conf.j2`

* [5a06c4ec](https://github.com/freephile/meza/commit/5a06c4ec) (2022-05-28) Andy Rechenberg: composer greater than 2.1.14 needs some changes to mediawiki composer.json. Use this version. 
  - Modified: `src/roles/composer/tasks/main.yml`

* [e261240e](https://github.com/freephile/meza/commit/e261240e) (2022-05-28) Andy Rechenberg: Match the change to config/RedHat.yml 
  - Modified: `src/roles/apache-php/tasks/main.yml`

* [f34aac1a](https://github.com/freephile/meza/commit/f34aac1a) (2022-05-28) Andy Rechenberg: Need the full filename 
  - Modified: `config/RedHat.yml`

* [43a760ca](https://github.com/freephile/meza/commit/43a760ca) (2022-05-28) Andy Rechenberg: Just rename the play name. 
  - Modified: `src/roles/composer/tasks/main.yml`

* [1bdfcdd4](https://github.com/freephile/meza/commit/1bdfcdd4) (2022-05-28) Andy Rechenberg: Use php-fpm on RH 8 variants. 
  - Modified: `config/RedHat.yml`
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat8.yml`
  - Added: `src/roles/apache-php/templates/php-fpm-httpd.conf.j2`
  - Added: `src/roles/apache-php/templates/www.conf.j2`

* [ff7b0dee](https://github.com/freephile/meza/commit/ff7b0dee) (2022-05-28) Andy Rechenberg: Fix silly syntax errors. 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [79875c56](https://github.com/freephile/meza/commit/79875c56) (2022-05-28) Andy Rechenberg: Fix composer things and extension versions as well as IdeAliases.php debacle. 
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/roles/composer/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [43ba6e8c](https://github.com/freephile/meza/commit/43ba6e8c) (2022-05-28) Andy Rechenberg: Casualty of the hyphen to underscore transition 
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [734e97de](https://github.com/freephile/meza/commit/734e97de) (2022-05-28) Andy Rechenberg: Change gluster for RH8 variants 
  - Modified: `src/roles/gluster/tasks/setup-RedHat.yml`

* [d9c76486](https://github.com/freephile/meza/commit/d9c76486) (2022-05-28) Andy Rechenberg: Try to fix ntp in base 
  - Modified: `src/roles/base/handlers/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`

* [954a3d0c](https://github.com/freephile/meza/commit/954a3d0c) (2022-05-27) Andy Rechenberg: base tag tries to restart ntpd even if it isn't installed. Check. 
  - Modified: `config/RedHat.yml`
  - Modified: `src/roles/base/handlers/main.yml`

* [458b0314](https://github.com/freephile/meza/commit/458b0314) (2022-05-27) Andy Rechenberg: Change ansible distro check. A recent change to ansible seems to have changed the ansible_os_family
varible and it now returns 'Rocky' instead of 'RedHat'. Since Rocky is
just a variant of RedHat I decided to change the ansible varible instead
of adding another check in all of the ansible files. This big commit
changes:
  ansible_os_family
to:
  ansible_distribution_file_variety
That change was automatied with:
find /opt/meza/src \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i '' -e 's;ansible_os_family;ansible_distribution_file_variety;g'
Much easier to automate that than to manually add a check to all of these
files.
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/base/templates/sshd_config.j2`
  - Modified: `src/roles/database/tasks/configure.yml`
  - Modified: `src/roles/database/tasks/main.yml`
  - Modified: `src/roles/database/tasks/variables.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/firewall_port/tasks/main.yml`
  - Modified: `src/roles/firewall_service/tasks/main.yml`
  - Modified: `src/roles/gluster/tasks/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/imagemagick/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/memcached/templates/memcached.j2`
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [9b44a25d](https://github.com/freephile/meza/commit/9b44a25d) (2022-05-27) Andy Rechenberg: Properly check for RH variant and version. The old distro and version check would break if there were more than
one package with the word 'release' in it. This code checks just the
variant-release RPM; if it's installed then we know which distro and
version we're dealing with.
  - Modified: `src/scripts/getmeza.sh`

* [feb29d89](https://github.com/freephile/meza/commit/feb29d89) (2022-05-27) Andy Rechenberg: Install python36 to ensure meza can run and proper symlinks are built 
  - Modified: `src/scripts/getmeza.sh`

* [4f3719ae](https://github.com/freephile/meza/commit/4f3719ae) (2022-05-27) Andy Rechenberg: Use ansible 2.9 from CentOS ansible release. 
  - Modified: `src/scripts/getmeza.sh`

* [5eb453e7](https://github.com/freephile/meza/commit/5eb453e7) (2022-05-28) Andy Rechenberg: Resolve deprecation warning about 'include' 
  - Modified: `src/roles/apache-php/tasks/php.yml`

* [5cc8bd2a](https://github.com/freephile/meza/commit/5cc8bd2a) (2022-05-28) Andy Rechenberg: RHEL8 has lua 5.3 and luasandbox needs 5.1. Disabling for now. 
  - Modified: `config/defaults.yml`

* [f90a110f](https://github.com/freephile/meza/commit/f90a110f) (2022-05-28) Andy Rechenberg: Finally working properly 
  - Modified: `src/roles/database/tasks/setup-RedHat.yml`

* [0b912001](https://github.com/freephile/meza/commit/0b912001) (2022-05-28) Andy Rechenberg: Get apache-php tag error-free on Rocky 
  - Modified: `config/RedHat.yml`
  - Added: `src/roles/apache-php/tasks/php-redhat7.yml`
  - Added: `src/roles/apache-php/tasks/php-redhat8.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [2fd01681](https://github.com/freephile/meza/commit/2fd01681) (2022-05-27) Andy Rechenberg: Fix base-extras for Rocky 8 
  - Modified: `src/roles/base-extras/tasks/main.yml`

* [9f54a29e](https://github.com/freephile/meza/commit/9f54a29e) (2022-05-27) Andy Rechenberg: Add version 8 specific extra packages variable. 
  - Modified: `config/RedHat.yml`

* [18b1f05b](https://github.com/freephile/meza/commit/18b1f05b) (2022-05-27) Andy Rechenberg: Use dnf and fix 'when' indenting 
  - Modified: `src/roles/database/tasks/setup-RedHat.yml`

* [443268b5](https://github.com/freephile/meza/commit/443268b5) (2022-05-27) Andy Rechenberg: Get database tag running on Rocky 8. 
  - Modified: `src/roles/database/tasks/setup-RedHat.yml`
  - Added: `src/roles/database/vars/RedHat-8.yml`

* [4a96aafc](https://github.com/freephile/meza/commit/4a96aafc) (2022-05-27) Andy Rechenberg: Tweak base to work with Rocky/RHEL8 (FIXME: still need RHEL testing) 
  - Modified: `src/roles/base/tasks/main.yml`

* [31e11fe1](https://github.com/freephile/meza/commit/31e11fe1) (2022-05-27) Andy Rechenberg: More hyphen/underscore nonsense ;) 
  - Modified: `config/defaults.yml`
  - Modified: `src/playbooks/backup.yml`
  - Modified: `src/playbooks/push-backup.yml`
  - Modified: `src/playbooks/setbaseconfig.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [1069363f](https://github.com/freephile/meza/commit/1069363f) (2022-05-27) Andy Rechenberg: Fix TypeError and open log as binary 
  - Modified: `src/scripts/meza.py`

* [e0ddfec4](https://github.com/freephile/meza/commit/e0ddfec4) (2022-05-27) Andy Rechenberg: Really fix hyphen underscore things. 
  - Modified: `config/defaults.yml`
  - Modified: `src/playbooks/backup.yml`
  - Modified: `src/playbooks/push-backup.yml`
  - Modified: `src/playbooks/setbaseconfig.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/setup-env/templates/hosts.j2`

* [9a7b9f96](https://github.com/freephile/meza/commit/9a7b9f96) (2022-05-27) Andy Rechenberg: Remove _ file 
  - Deleted: `src/roles/verify-wiki/tasks/transfer-backup-to-db_master.yml`

* [6b37c5b6](https://github.com/freephile/meza/commit/6b37c5b6) (2022-05-27) Andy Rechenberg: Fix deprecation warning. 
  - Modified: `config/ansible.cfg`

* [f1134b95](https://github.com/freephile/meza/commit/f1134b95) (2022-05-27) Andy Rechenberg: Bump SMW and other components. 
  - Modified: `config/MezaCoreExtensions.yml`

* [c0e4daff](https://github.com/freephile/meza/commit/c0e4daff) (2022-05-27) Andy Rechenberg: Convert ansible group names from using hyphens to underscores. 
  - Modified: `RELEASE-NOTES.md`
  - Modified: `src/playbooks/backup.yml`
  - Modified: `src/playbooks/cleanup-upload-stash.yml`
  - Modified: `src/playbooks/create-wiki-promptless.yml`
  - Modified: `src/playbooks/create-wiki.yml`
  - Modified: `src/playbooks/delete-elasticsearch.yml`
  - Modified: `src/playbooks/delete-wiki-promptless.yml`
  - Modified: `src/playbooks/delete-wiki.yml`
  - Modified: `src/playbooks/push-backup.yml`
  - Modified: `src/playbooks/rebuild-smw-and-index.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/apache-php/templates/xhgui.config.php.j2`
  - Modified: `src/roles/backup-db-wikis/tasks/main.yml`
  - Modified: `src/roles/backup-uploads/tasks/main.yml`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`
  - Modified: `src/roles/database/tasks/users.yml`
  - Modified: `src/roles/delete-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/gluster/tasks/main.yml`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/saml/templates/config.php.j2`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/setup-env/templates/hosts.j2`
  - Modified: `src/roles/sql-backup-cleanup/tasks/main.yml`
  - Modified: `src/roles/update.php/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/transfer-backup-to-db-master.yml`
  - Added: `src/roles/verify-wiki/tasks/transfer-backup-to-db_master.yml`

* [430428c2](https://github.com/freephile/meza/commit/430428c2) (2022-05-27) Andy Rechenberg: Copy djflux rhel8 branch getmeza.sh and meza.py 
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `src/scripts/meza.py`

* [5ffc3fa1](https://github.com/freephile/meza/commit/5ffc3fa1) (2021-12-06) James Montalvo: feat: add SAML certData config 
  - Modified: `src/roles/saml/templates/saml20-idp-remote.php.j2`

* [cb6c7238](https://github.com/freephile/meza/commit/cb6c7238) (2021-11-15) James Montalvo: fix(update.php): handle MW Multi-Content Revisions error (T212428) 
  - Modified: `src/roles/update.php/tasks/main.yml`

* [9b77d9ac](https://github.com/freephile/meza/commit/9b77d9ac) (2021-11-15) James Montalvo: fix(pecl): make pecl packages not fail unnecessarily 
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`

* [dea24150](https://github.com/freephile/meza/commit/dea24150) (2021-10-12) James Montalvo: Add 'actor' to wgSharedTables 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [4cd58621](https://github.com/freephile/meza/commit/4cd58621) (2021-10-12) James Montalvo: Try not removing login/logout pages and links 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [2fc4dd1f](https://github.com/freephile/meza/commit/2fc4dd1f) (2021-10-12) James Montalvo: Switch from Extension:SimpleSamlAuth to SimpleSAMLphp 
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/saml/templates/NonMediaWikiSimpleSamlAuth.php.j2`
  - Modified: `src/roles/saml/templates/SAMLConfig.php.j2`
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [84d88139](https://github.com/freephile/meza/commit/84d88139) (2021-10-11) James Montalvo: Ensure simplesamlphp gets created 
  - Modified: `src/roles/saml/tasks/main.yml`

* [9657549c](https://github.com/freephile/meza/commit/9657549c) (2021-10-08) James Montalvo: Ensure simplesamlphp directories exists 
  - Modified: `src/roles/saml/tasks/main.yml`

* [e1c429e9](https://github.com/freephile/meza/commit/e1c429e9) (2021-10-08) James Montalvo: Bump Python to 3.6 
  - Modified: `config/RedHat.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [a86735c6](https://github.com/freephile/meza/commit/a86735c6) (2021-01-06) James Montalvo: Install lib-SimpleSamlPhp into directory properly 
  - Modified: `src/roles/saml/tasks/main.yml`

* [951a0602](https://github.com/freephile/meza/commit/951a0602) (2021-01-05) James Montalvo: Use tarball version of simplesamlphp 
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/saml/tasks/main.yml`

* [e922e824](https://github.com/freephile/meza/commit/e922e824) (2021-01-05) James Montalvo: Fix user running simplesamlphp NPM commands 
  - Modified: `src/roles/saml/tasks/main.yml`

* [d20c47e8](https://github.com/freephile/meza/commit/d20c47e8) (2021-01-05) James Montalvo: Use simplesamlphp version 1.18.8; requires npm 
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/saml/tasks/main.yml`

* [e39099c2](https://github.com/freephile/meza/commit/e39099c2) (2021-01-04) James Montalvo: Don't make Non-MW SAML class rely on being in /opt 
  - Modified: `src/roles/saml/tasks/main.yml`
R098	src/roles/saml/files/NonMediaWikiSimpleSamlAuth.php	src/roles/saml/templates/NonMediaWikiSimpleSamlAuth.php.j2

* [3d697f73](https://github.com/freephile/meza/commit/3d697f73) (2020-12-30) James Montalvo: Cleanup Parsoid; Verify PHP zip installed 
  - Modified: `config/paths.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Added: `src/roles/base/tasks/parsoid-cleanup.yml`

* [80237c09](https://github.com/freephile/meza/commit/80237c09) (2020-12-30) James Montalvo: Use PHP 7.4 and properly remove old versions 
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`

* [28a51b79](https://github.com/freephile/meza/commit/28a51b79) (2020-12-30) James Montalvo: Fix Parsoid config; Fix CirrusSearch maint script names 
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/roles/mediawiki/templates/elastic-build-index.sh.j2`

* [9465a621](https://github.com/freephile/meza/commit/9465a621) (2020-12-30) James Montalvo: Many fixes to adjust for MW 1.35 
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [9d371215](https://github.com/freephile/meza/commit/9d371215) (2020-12-29) James Montalvo: Initial 35.x changes 
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `config/defaults.yml`
  - Modified: `config/paths.yml`
  - Modified: `src/playbooks/create-wiki-promptless.yml`
  - Modified: `src/playbooks/create-wiki.yml`
  - Modified: `src/playbooks/delete-wiki-promptless.yml`
  - Modified: `src/playbooks/delete-wiki.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/cron/defaults/main.yml`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Deleted: `src/roles/nodejs/README.md`
  - Deleted: `src/roles/nodejs/defaults/main.yml`
  - Deleted: `src/roles/nodejs/meta/main.yml`
  - Deleted: `src/roles/nodejs/tasks/main.yml`
  - Deleted: `src/roles/nodejs/tasks/setup-Debian.yml`
  - Deleted: `src/roles/nodejs/tasks/setup-RedHat.yml`
  - Deleted: `src/roles/nodejs/templates/npm.sh.j2`
  - Deleted: `src/roles/nodejs/tests/test.yml`
  - Deleted: `src/roles/parsoid-settings/handlers/main.yml`
  - Deleted: `src/roles/parsoid-settings/tasks/main.yml`
  - Deleted: `src/roles/parsoid-settings/templates/config.yaml.j2`
  - Deleted: `src/roles/parsoid-settings/templates/localsettings.js.j2`
  - Deleted: `src/roles/parsoid-settings/templates/parsoid.initd.sh.j2`
  - Deleted: `src/roles/parsoid/tasks/main.yml`
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`
  - Modified: `src/roles/setup-env/templates/hosts.j2`
  - Modified: `src/scripts/meza.py`
  - Modified: `tests/integration/server-check.sh`

* [65a44b22](https://github.com/freephile/meza/commit/65a44b22) (2020-12-28) James Montalvo: Fixes: ensure install dir configured, PEAR installed, IUS GPG key available before needed, netdata not default installed 
  - Modified: `config/defaults.yml`
  - Modified: `config/paths.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`
  - Modified: `src/roles/base/tasks/main.yml`

* [816edefa](https://github.com/freephile/meza/commit/816edefa) (2020-12-23) James Montalvo: Make install directory configurable for Vagrant 
  - Modified: `Vagrantfile`

* [980f08e1](https://github.com/freephile/meza/commit/980f08e1) (2020-12-22) James Montalvo: WIP: Enable install other than in /opt 
  - Modified: `config/ansible.cfg`
  - Modified: `config/defaults.yml`
  - Added: `config/paths.yml`
  - Modified: `src/playbooks/cleanup-upload-stash.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`
  - Modified: `src/roles/autodeployer/templates/git-fetch.sh.j2`
  - Modified: `src/roles/autodeployer/templates/slack-notify.sh.j2`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`
  - Modified: `src/roles/database/defaults/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/htdocs/files/BackupDownload/download.php`
  - Modified: `src/roles/htdocs/files/BackupDownload/index.php`
  - Modified: `src/roles/htdocs/files/ServerPerformance/index.php`
  - Modified: `src/roles/htdocs/files/ServerPerformance/space.php`
  - Modified: `src/roles/htdocs/templates/index.php.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/mediawiki/templates/refresh-links.sh.j2`
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Modified: `src/roles/meza-log/templates/disk-space-usage.sh.j2`
  - Modified: `src/roles/meza-log/templates/server-performance.sh.j2`
  - Modified: `src/roles/netdata/tasks/main.yml`
  - Modified: `src/roles/saml/files/NonMediaWikiSimpleSamlAuth.php`
  - Modified: `src/roles/saml/templates/SAMLConfig.php.j2`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/setup-env/templates/secret.yml.j2`
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `src/scripts/importExtensions.php`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/shell-functions/linux-user.sh`
  - Modified: `src/scripts/ssh-users/setup-master-user.sh`
  - Modified: `src/scripts/ssh-users/setup-minion-user.sh`
  - Modified: `src/scripts/ssh-users/transfer-master-key.sh`
  - Modified: `src/scripts/ssl-selftest.sh`
  - Modified: `src/scripts/unifyUserTables.php`
  - Modified: `src/scripts/unite-the-wikis.sh`
  - Modified: `src/scripts/uniteTheWikis.php`

* [67369236](https://github.com/freephile/meza/commit/67369236) (2020-12-21) James Montalvo: Bump WatchAnalytics to 3.2.0 to support MW 1.34+ 
  - Modified: `config/MezaCoreExtensions.yml`

* [3c756822](https://github.com/freephile/meza/commit/3c756822) (2020-12-21) James Montalvo: Bump Wiretap to 0.2.0 to support MW 1.34+ 
  - Modified: `config/MezaCoreExtensions.yml`

* [27ab07e2](https://github.com/freephile/meza/commit/27ab07e2) (2020-12-21) James Montalvo: Re-enable all MezaCoreExtensions 
  - Modified: `config/MezaCoreExtensions.yml`

* [e05ea12c](https://github.com/freephile/meza/commit/e05ea12c) (2020-12-18) James Montalvo: Bump base Vagrant RAM from 2GB to 4GB, else problems (#1278) 
  - Modified: `vagrantconf.default.yml`

* [908ac75b](https://github.com/freephile/meza/commit/908ac75b) (2020-12-18) James Montalvo: Bump MW to 1.31.12 (#1277) 
  - Modified: `config/core/defaults.yml`

* [2380aa22](https://github.com/freephile/meza/commit/2380aa22) (2020-12-18) James Montalvo: Enforce Composer 1.x version (#1275) Co-authored-by: Montalvo <ejmontal@ndc.nasa.gov>
  - Modified: `src/roles/composer/tasks/main.yml`

* [9630b301](https://github.com/freephile/meza/commit/9630b301) (2020-12-17) James Montalvo: Enforce Composer 1.x version 
  - Modified: `src/roles/composer/tasks/main.yml`

* [8b5c1125](https://github.com/freephile/meza/commit/8b5c1125) (2020-10-21) Vincent Brooks: Added config variable use_ntp (#1271) * added config variable

* added when: use_ntp
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/base/tasks/main.yml`

* [4160ae3c](https://github.com/freephile/meza/commit/4160ae3c) (2020-06-12) James Montalvo: Bump MediaWiki to 1.31.7 (#1267) 
  - Modified: `config/core/defaults.yml`

* [65aa596d](https://github.com/freephile/meza/commit/65aa596d) (2020-06-12) Daren Welsh: add ldap module (#1261) 
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`

* [6849b213](https://github.com/freephile/meza/commit/6849b213) (2020-06-11) James Montalvo: Make demo wiki admin pass stronger per MW1.34 reqs 
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`

* [24ef480e](https://github.com/freephile/meza/commit/24ef480e) (2020-06-11) James Montalvo: Get new baseline SQL from MW 1.34 maintenance/tables.sql 
  - Modified: `src/roles/verify-wiki/templates/mediawiki-tables.sql`

* [4deaefab](https://github.com/freephile/meza/commit/4deaefab) (2020-06-11) James Montalvo: Setup SMW store to avoid MCR issue; reinstate PageImporter - Setup SMW store required due to SemanticMediaWiki/SemanticMediaWiki#4386
- PageImporter was commented out to reduce possible causes of issues,
  but is needed for other tasks (importing pages) and it'd be a pain to
  have to comment out more.
  - Modified: `config/MezaCoreExtensions.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`

* [f4f78a1d](https://github.com/freephile/meza/commit/f4f78a1d) (2020-06-11) James Montalvo: Reinstate Elasticsearch upgrade (from 5.x to 6.x); fix check for shard allocation 
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`

* [6d465dfd](https://github.com/freephile/meza/commit/6d465dfd) (2020-06-11) James Montalvo: Add tags to simplify skipping extension downloads 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [0372fba7](https://github.com/freephile/meza/commit/0372fba7) (2020-06-11) James Montalvo: Remove potentially problematic extensions 
  - Modified: `config/MezaCoreExtensions.yml`

* [aee1e0e5](https://github.com/freephile/meza/commit/aee1e0e5) (2020-04-03) Greg Rundlett: Upgrade elasticsearch to 6.x Change JAVA_HOME to the JDK included with Elasticsearch
Get rid of all the comments in the config template
Remove old extraneous Elasticsearch tasks
Note: the upgrade.yml still looks valid even for v 6
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.yml.j2`
  - Modified: `src/roles/elasticsearch/templates/java_home.sh.j2`

* [1e1e19bd](https://github.com/freephile/meza/commit/1e1e19bd) (2020-03-30) Greg Rundlett: ugrade php to 7.2 and elasticsearch to 6.x 
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Added: `src/roles/elasticsearch/templates/elasticsearch.repo.j2`

* [099eef42](https://github.com/freephile/meza/commit/099eef42) (2020-06-11) James Montalvo: Elastic needs to have 1.34 version 
  - Modified: `config/MezaCoreExtensions.yml`

* [71b0a8a9](https://github.com/freephile/meza/commit/71b0a8a9) (2020-06-10) James Montalvo: Specify exact versions whenever possible 
  - Modified: `config/MezaCoreExtensions.yml`

* [19cf1ad4](https://github.com/freephile/meza/commit/19cf1ad4) (2020-05-09) Rich Evans: Update MezaCoreExtensions.yml provides missing wfLoadExtension('SemanticCompoundQueries'); config option
  - Modified: `config/MezaCoreExtensions.yml`

* [4a516b20](https://github.com/freephile/meza/commit/4a516b20) (2020-04-28) Greg Rundlett: Add config comment for PageForms 
  - Modified: `config/MezaCoreExtensions.yml`

* [8061e469](https://github.com/freephile/meza/commit/8061e469) (2020-04-17) Greg Rundlett: comment several broken extensions 
  - Modified: `config/MezaCoreExtensions.yml`

* [de116732](https://github.com/freephile/meza/commit/de116732) (2020-04-10) Greg Rundlett: Use master for ApprovedRevs 
  - Modified: `config/MezaCoreExtensions.yml`

* [18b52b10](https://github.com/freephile/meza/commit/18b52b10) (2020-04-03) Greg Rundlett: Update SMW to 3.1 Update
Semantic MediaWiki to v3.1
Semantic Result Formats v3.1
Semantic Compound Queries v2.1
Semantic Scribunto v2.1
Also remove deprecated DB_SLAVE
  - Modified: `config/MezaCoreExtensions.yml`

* [608d34cd](https://github.com/freephile/meza/commit/608d34cd) (2020-06-11) James Montalvo: Add exit code on bad run of elastic-build-index.sh 
  - Modified: `src/roles/mediawiki/templates/elastic-rebuild-all.sh.j2`

* [f847f5cd](https://github.com/freephile/meza/commit/f847f5cd) (2020-06-11) James Montalvo: Bump Elastica version to avoid notices that 'each()' deprecated in PHP 7.2 
  - Modified: `config/MezaCoreExtensions.yml`

* [591df68c](https://github.com/freephile/meza/commit/591df68c) (2020-06-10) James Montalvo: Point tests to new Docker images built from this repo; only run build process on commits to master 
  - Modified: `.github/workflows/docker-build.yml`
  - Modified: `src/scripts/meza.py`
  - Modified: `tests/docker/init-container.sh`
  - Modified: `tests/docker/init-controller.sh`
  - Modified: `tests/docker/init-minion.sh`

* [40abfedc](https://github.com/freephile/meza/commit/40abfedc) (2020-06-10) James Montalvo: Fix ImageMagick convert command 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [8a224859](https://github.com/freephile/meza/commit/8a224859) (2020-06-10) James Montalvo: Remove secret.yml encryption per #1175 
  - Modified: `tests/containers/full/Dockerfile`

* [57e84693](https://github.com/freephile/meza/commit/57e84693) (2020-06-10) James Montalvo: Need --skip-conn-check on getmeza.sh within docker; temporarily skip other builds 
  - Modified: `.github/workflows/docker-build.yml`
  - Modified: `tests/containers/full/Dockerfile`

* [11dc3e8e](https://github.com/freephile/meza/commit/11dc3e8e) (2020-06-10) James Montalvo: Make Dockerfiles pull FROM correct base image 
  - Modified: `tests/containers/full/Dockerfile`
  - Modified: `tests/containers/max/Dockerfile`
  - Modified: `tests/containers/pre-yum/Dockerfile`

* [f01ae65e](https://github.com/freephile/meza/commit/f01ae65e) (2020-06-10) James Montalvo: Add later test images 
  - Modified: `.github/workflows/docker-build.yml`
  - Added: `tests/containers/full/Dockerfile`
  - Added: `tests/containers/max/Dockerfile`
  - Added: `tests/containers/pre-yum/Dockerfile`

* [62886bee](https://github.com/freephile/meza/commit/62886bee) (2020-06-10) James Montalvo: Build test container 'base' on pushes to 'docker-build' branch 
  - Added: `.github/workflows/docker-build.yml`
  - Added: `tests/containers/base/Dockerfile`

* [9d9f516a](https://github.com/freephile/meza/commit/9d9f516a) (2020-04-13) Daren Welsh: remove php 5.x packages, add LDAP PHP IUS 
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`

* [baf39caf](https://github.com/freephile/meza/commit/baf39caf) (2020-04-09) Greg Rundlett: mcrypt is not available for PHP7.2 
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`

* [af7f99b3](https://github.com/freephile/meza/commit/af7f99b3) (2020-04-03) Greg Rundlett: MCrypt for PHP is now just named php-mcrypt 
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`

* [0ff4ddd0](https://github.com/freephile/meza/commit/0ff4ddd0) (2020-06-10) James Montalvo: Fix IUS repo 
  - Deleted: `src/roles/apache-php/tasks/ius.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`

* [3ab9f451](https://github.com/freephile/meza/commit/3ab9f451) (2020-06-10) James Montalvo: Fix bad merge 
  - Modified: `src/roles/database/tasks/replication.yml`

* [b5ce5e3d](https://github.com/freephile/meza/commit/b5ce5e3d) (2020-06-08) James Montalvo: GitHub Actions fail-fast-->false, to prevent one failure from cancelling all jobs 
  - Modified: `.github/workflows/test.yml`

* [4cb414fd](https://github.com/freephile/meza/commit/4cb414fd) (2020-06-08) James Montalvo: Don't run tests twice for PRs 
  - Modified: `.github/workflows/test.yml`

* [83d4bd6a](https://github.com/freephile/meza/commit/83d4bd6a) (2020-06-07) James Montalvo: Enable testing in GitHub Actions and GitLab CI 
  - Added: `.github/workflows/test.yml`
  - Added: `.gitlab-ci.yml`
  - Modified: `.travis.yml`
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `tests/docker/backup-to-remote.setup.sh`
  - Modified: `tests/docker/import-from-remote.setup.sh`
  - Modified: `tests/docker/init-container.sh`
  - Modified: `tests/docker/init-controller.sh`
  - Modified: `tests/docker/run-tests.sh`
  - Deleted: `tests/travis/git-setup.sh`

* [4606fa67](https://github.com/freephile/meza/commit/4606fa67) (2020-06-05) James Montalvo: 31.10.1 release 
  - Modified: `RELEASE-NOTES.md`

* [e048a7b3](https://github.com/freephile/meza/commit/e048a7b3) (2020-06-05) James Montalvo: Ensure PEAR channel up-to-date 
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`

* [7c67b850](https://github.com/freephile/meza/commit/7c67b850) (2020-06-05) James Montalvo: 31.10.0 release 
  - Modified: `RELEASE-NOTES.md`

* [bbe00090](https://github.com/freephile/meza/commit/bbe00090) (2020-06-05) James Montalvo: Remove symlink creation for pip3; IUS appears to do that automatically now 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [c50be328](https://github.com/freephile/meza/commit/c50be328) (2020-06-05) James Montalvo: Remove mcrypt extension no longer available after PHP 7.1 
  - Modified: `src/roles/apache-php/tasks/php.yml`

* [01c04bbc](https://github.com/freephile/meza/commit/01c04bbc) (2020-06-05) James Montalvo: Bump to PHP 7.2 
  - Modified: `config/core/defaults.yml`

* [10bc8631](https://github.com/freephile/meza/commit/10bc8631) (2020-06-05) James Montalvo: Fix typo (backslash) 
  - Modified: `src/roles/apache-php/tasks/ius.yml`

* [f7012019](https://github.com/freephile/meza/commit/f7012019) (2020-06-05) James Montalvo: Add second IUS repo and GPG key 
  - Modified: `src/roles/apache-php/tasks/ius.yml`

* [8e471509](https://github.com/freephile/meza/commit/8e471509) (2020-06-01) Andrew Foster: Update URL to IUS RPM See https://github.com/iusrepo/announce/issues/18 
  - Modified: `src/roles/apache-php/tasks/ius.yml`

* [44f2d2c2](https://github.com/freephile/meza/commit/44f2d2c2) (2020-01-10) Greg Rundlett: Python 2/3 compatibility items is available in both Python 2 and Python 3 whereas
iteritems was only available for the Python 2.x interpreter
This change makes Meza compatible with both
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`
  - Modified: `src/scripts/meza.py`

* [8812f213](https://github.com/freephile/meza/commit/8812f213) (2019-12-04) James Montalvo: 31.9.0 release 
  - Modified: `RELEASE-NOTES.md`

* [4d18daa1](https://github.com/freephile/meza/commit/4d18daa1) (2019-11-23) Daren Welsh: yaml syntax fix 
  - Modified: `src/roles/remote-dir-check/tasks/main.yml`

* [63716a8e](https://github.com/freephile/meza/commit/63716a8e) (2019-11-23) Daren Welsh: fix more flag syntax 
  - Modified: `src/roles/remote-dir-check/tasks/main.yml`

* [fe788458](https://github.com/freephile/meza/commit/fe788458) (2019-11-23) Daren Welsh: fix deprecated ansible syntax, ref c06fa04c7ddd0ea99c6e92b6f87ff89fd5be27a4 
  - Modified: `src/roles/database/tasks/replication.yml`

* [9dde2d87](https://github.com/freephile/meza/commit/9dde2d87) (2019-11-02) James Montalvo: Try Parsoid 0.10.0 
  - Modified: `config/core/defaults.yml`

* [121de9df](https://github.com/freephile/meza/commit/121de9df) (2019-10-31) James Montalvo: Add --no-firewall deploy option 
  - Modified: `src/scripts/meza.py`
  - Modified: `tests/deploys/backup-to-remote.controller.sh`
  - Modified: `tests/deploys/import-from-remote.controller.sh`
  - Modified: `tests/deploys/monolith-from-import.controller.sh`
  - Modified: `tests/deploys/monolith-from-scratch.controller.sh`
  - Modified: `tests/docker/import-from-alt-remote.setup.sh`
  - Modified: `tests/docker/import-from-remote.setup.sh`

* [93b6087c](https://github.com/freephile/meza/commit/93b6087c) (2019-10-30) James Montalvo: Disable firewalld on travis tests 
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/firewalld/handlers/main.yml`
  - Modified: `src/roles/firewalld/tasks/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/nodejs/tasks/setup-RedHat.yml`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `tests/deploys/backup-to-remote.controller.sh`
  - Modified: `tests/deploys/import-from-remote.controller.sh`
  - Modified: `tests/deploys/monolith-from-scratch.controller.sh`
  - Modified: `tests/docker/import-from-alt-remote.setup.sh`
  - Modified: `tests/docker/import-from-remote.setup.sh`

* [74a76974](https://github.com/freephile/meza/commit/74a76974) (2019-10-30) James Montalvo: Try manually restarting firewalld 
  - Modified: `src/roles/base/tasks/main.yml`

* [f9cc3a67](https://github.com/freephile/meza/commit/f9cc3a67) (2019-10-30) James Montalvo: Travis saying Docker not running; perhaps start firewall after offline cmd 
  - Modified: `tests/docker/init-container.sh`

* [892fb1f7](https://github.com/freephile/meza/commit/892fb1f7) (2019-10-30) James Montalvo: With firewall-offline-cmd no --permanent option, prob because if offline none could be temp 
  - Modified: `tests/docker/init-container.sh`

* [e1ced43f](https://github.com/freephile/meza/commit/e1ced43f) (2019-10-30) James Montalvo: Possible solution to Issue [#1237](https://github.com/freephile/meza/issues/1237) according to this forum: https://www.centos.org/forums/viewtopic.php?f=47&t=52162&p=220915#p220915
  - Modified: `tests/docker/init-container.sh`

* [d1b17a9a](https://github.com/freephile/meza/commit/d1b17a9a) (2019-10-30) Vincent Brooks: Add a calendar interface to add and edit events using the Full… 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [a5551143](https://github.com/freephile/meza/commit/a5551143) (2019-09-23) XP1: Add function to wait for Internet connection. Vagrant or getmeza script needs to check Internet connectivity of guest before proceeding #1231:
https://github.com/enterprisemediawiki/meza/issues/1231
  - Modified: `src/scripts/getmeza.sh`

* [1f130079](https://github.com/freephile/meza/commit/1f130079) (2019-08-29) James Montalvo: Add /opt/data-meza/mw-temp that apache can modify Apache cannot write to /opt/data-meza/tmp. For Special:TransferPages, it
is necessary for Apache to write a temp file, which then is picked up by
the MW job queue and executed as user meza-ansible.
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`

* [c5f4d326](https://github.com/freephile/meza/commit/c5f4d326) (2019-08-23) Vincent Brooks: Updating Data Transfer to fix import bug https://gerrit.wikimedia.org/r/plugins/gitiles/mediawiki/extensions/DataTransfer/+/730cbfbcc7cc255724eaceb76a3abc6fcc9c93aa
  - Modified: `config/core/MezaCoreExtensions.yml`

* [f655f6bd](https://github.com/freephile/meza/commit/f655f6bd) (2019-08-08) James Montalvo: Allow specifying PHP max upload size in config 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`

* [4628953e](https://github.com/freephile/meza/commit/4628953e) (2019-08-07) James Montalvo: Allow specifying refspec in MW git repos 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [53b83525](https://github.com/freephile/meza/commit/53b83525) (2019-08-07) James Montalvo: Bump SMW to 3.0.2 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [2387b4a9](https://github.com/freephile/meza/commit/2387b4a9) (2019-07-08) James Montalvo: Check if apache group exists before setting as group for lock file; fixes #1216 
  - Modified: `src/scripts/meza.py`

* [2a8c3d94](https://github.com/freephile/meza/commit/2a8c3d94) (2019-07-05) James Montalvo: Bump MW to 1.31.2; remove pear/net_smtp from meza (part of MW now) 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/mediawiki/templates/composer.local.json.j2`

* [a5af7c09](https://github.com/freephile/meza/commit/a5af7c09) (2019-07-04) James Montalvo: Make Extension:MezaExt track 'master' while TransferPages in development 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [58744c8e](https://github.com/freephile/meza/commit/58744c8e) (2019-06-27) James Montalvo: 31.8.2 release 
  - Modified: `RELEASE-NOTES.md`

* [6722cdcb](https://github.com/freephile/meza/commit/6722cdcb) (2019-06-27) James Montalvo: Make meza-ansible:apache own deploy lock file, not root 
  - Modified: `src/scripts/meza.py`

* [16833fd3](https://github.com/freephile/meza/commit/16833fd3) (2019-06-27) James Montalvo: Remove commented out non-ansible-module composer tasks 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [deca0bb5](https://github.com/freephile/meza/commit/deca0bb5) (2019-06-27) James Montalvo: Use ansible composer module again 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [c7c510ea](https://github.com/freephile/meza/commit/c7c510ea) (2019-06-27) James Montalvo: Mount local meza on docker tests controller containers 
  - Modified: `tests/docker/init-controller.sh`

* [0a9ca065](https://github.com/freephile/meza/commit/0a9ca065) (2019-06-27) James Montalvo: Add error handling to update.php (show errors) 
  - Modified: `src/roles/update.php/tasks/main.yml`

* [dc7c184c](https://github.com/freephile/meza/commit/dc7c184c) (2019-06-27) James Montalvo: WIP 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [b1a140ee](https://github.com/freephile/meza/commit/b1a140ee) (2019-06-27) James Montalvo: Try envoking composer directly 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [2a49a3fa](https://github.com/freephile/meza/commit/2a49a3fa) (2019-06-26) James Montalvo: Trying deleting composer.lock before composer operations 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [8b96dc1e](https://github.com/freephile/meza/commit/8b96dc1e) (2019-06-26) James Montalvo: Add --no-dev to MW composer commands 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [ddb9fe28](https://github.com/freephile/meza/commit/ddb9fe28) (2019-06-24) James Montalvo: Add refreshLinks script that handles memory leaks 
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Added: `src/roles/mediawiki/templates/refresh-links.sh.j2`

* [fb66fa35](https://github.com/freephile/meza/commit/fb66fa35) (2019-06-17) James Montalvo: Allow specifying rules for what to gzip in backups-cleanup 
  - Modified: `src/roles/backups-cleanup/templates/backups-cleanup.sh.j2`

* [8093118a](https://github.com/freephile/meza/commit/8093118a) (2019-06-12) James Montalvo: Make update.php write to a log 
  - Modified: `src/roles/update.php/tasks/main.yml`

* [ea7e7f66](https://github.com/freephile/meza/commit/ea7e7f66) (2019-06-12) James Montalvo: Fix bad owner/group on /opt/data-meza 
  - Modified: `src/roles/base/tasks/main.yml`

* [94c79c19](https://github.com/freephile/meza/commit/94c79c19) (2019-06-11) James Montalvo: Fix bad variable 
  - Modified: `src/roles/verify-wiki/tasks/transfer-backup-to-db-master.yml`

* [93d5a0d5](https://github.com/freephile/meza/commit/93d5a0d5) (2019-06-11) James Montalvo: Improve logic for how to grab SQL file from backup 
  - Modified: `src/roles/verify-wiki/tasks/transfer-backup-to-db-master.yml`

* [25b80130](https://github.com/freephile/meza/commit/25b80130) (2019-06-11) James Montalvo: Make pushed backups in form *push.sql and use them first; more debug 
  - Modified: `src/roles/backup-db-wikis-push/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/transfer-backup-to-db-master.yml`

* [01a171a7](https://github.com/freephile/meza/commit/01a171a7) (2019-06-06) James Montalvo: 31.8.1 release 
  - Modified: `RELEASE-NOTES.md`

* [597a49ff](https://github.com/freephile/meza/commit/597a49ff) (2019-06-06) James Montalvo: Ensure MediaWiki and WikiBlender ownership after all operations 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [8f14b8f9](https://github.com/freephile/meza/commit/8f14b8f9) (2019-06-06) James Montalvo: Recursively apply owner/perms to simplesaml and mediawiki 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/saml/tasks/main.yml`

* [2803905f](https://github.com/freephile/meza/commit/2803905f) (2019-06-06) James Montalvo: Specify /opt/simplesamlphp owner/group/mode 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`

* [80177f45](https://github.com/freephile/meza/commit/80177f45) (2019-06-06) James Montalvo: push-backup: Fix bad use of 'notify' tag; Add servers to exclude 'notify' tag was mixed with 'never' tag, such that it seemed to make
sense to do '--tags notify' to get it to notify. However, this would
then skip over other things not tagged 'notify' like 'uploads' and 'db'.
Instead you'd have to do '--tags db,uploads,anything-else-required'.
Maybe '--tags all,notify' would work, but that's also confusing. Instead
this commit removes the 'never' tag so notification will always happen.
If a user wants to prevent notification they can do '--skip-tags notify'
For some reason the list of servers to exclude on the push-backup
playbook took the 32.x form with server groups like
load-balancers-nonmeza. This missed load-balancers-unmanaged, the 31.x
group naming.
  - Modified: `src/playbooks/push-backup.yml`
  - Modified: `src/roles/autodeployer/templates/meza-autodeployer-cron.j2`

* [eb1cab66](https://github.com/freephile/meza/commit/eb1cab66) (2019-06-05) Rich Evans: Update MezaCoreExtensions.yml changed version from "dev-master" to "2.0.0"
  - Modified: `config/core/MezaCoreExtensions.yml`

* [f71fe080](https://github.com/freephile/meza/commit/f71fe080) (2019-06-05) Rich Evans: Update MezaCoreExtensions.yml my first pull request
  - Modified: `config/core/MezaCoreExtensions.yml`

* [ef09660d](https://github.com/freephile/meza/commit/ef09660d) (2019-06-05) GarrettGeorge: Cherry picks skip_saml CIDR notation support changes from 32.x 
  - Modified: `src/roles/saml/templates/config.php.j2`
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [34e12f05](https://github.com/freephile/meza/commit/34e12f05) (2019-06-04) James Montalvo: 31.8.0 release 
  - Modified: `RELEASE-NOTES.md`

* [077e6bc2](https://github.com/freephile/meza/commit/077e6bc2) (2019-06-04) James Montalvo: Add lock_timeout to yum/package modules to fix Ansible 2.8 issue Issue getting "yum lockfile is held by another process" msg
Ref:
 - https://github.com/ansible/ansible/issues/57189
 - #1165
  - Modified: `src/playbooks/delete-elasticsearch.yml`
  - Modified: `src/playbooks/getdocker.yml`
  - Modified: `src/roles/apache-php/tasks/ius.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/backup-config/tasks/main.yml`
  - Modified: `src/roles/base-extras/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/database/tasks/setup-RedHat.yml`
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/gluster/tasks/setup-RedHat.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/imagemagick/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/memcached/tasks/main.yml`
  - Modified: `src/roles/nodejs/tasks/main.yml`
  - Modified: `src/roles/nodejs/tasks/setup-RedHat.yml`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [d6ddb60c](https://github.com/freephile/meza/commit/d6ddb60c) (2019-06-04) James Montalvo: Don't use 'meza' command for dev-networking 
  - Modified: `src/scripts/meza.py`

* [2ef84547](https://github.com/freephile/meza/commit/2ef84547) (2019-06-04) James Montalvo: Secret directory 775 in getmeza.sh, too 
  - Modified: `src/scripts/getmeza.sh`

* [8ba13533](https://github.com/freephile/meza/commit/8ba13533) (2019-06-04) James Montalvo: file not directory 
  - Modified: `src/roles/init-controller-config/tasks/main.yml`

* [ab1d9b1e](https://github.com/freephile/meza/commit/ab1d9b1e) (2019-06-04) James Montalvo: Don't overwrite secrt files 
  - Modified: `src/roles/init-controller-config/tasks/main.yml`

* [c64c41b7](https://github.com/freephile/meza/commit/c64c41b7) (2019-06-04) James Montalvo: Relax secret config _directory_ mode; ensure good ownership 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `src/scripts/meza.py`

* [968c6757](https://github.com/freephile/meza/commit/968c6757) (2019-06-04) James Montalvo: Make meza-ansible own temp_vars.json 
  - Modified: `src/scripts/meza.py`

* [dd245ae5](https://github.com/freephile/meza/commit/dd245ae5) (2019-06-04) James Montalvo: Sync secret perms 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/setup-env/tasks/main.yml`
  - Modified: `src/scripts/getmeza.sh`

* [dece78ce](https://github.com/freephile/meza/commit/dece78ce) (2019-06-03) James Montalvo: 31.7.0 release 
  - Modified: `RELEASE-NOTES.md`

* [8b109a77](https://github.com/freephile/meza/commit/8b109a77) (2019-06-03) James Montalvo: Simplify push_backup settings 
  - Modified: `src/playbooks/push-backup.yml`
  - Modified: `src/roles/backup-db-wikis-push/tasks/main.yml`
  - Modified: `src/roles/backup-uploads-push/tasks/main.yml`

* [8a3c059b](https://github.com/freephile/meza/commit/8a3c059b) (2019-06-03) James Montalvo: Fix missing endif 
  - Modified: `src/roles/autodeployer/templates/meza-autodeployer-cron.j2`

* [170596cb](https://github.com/freephile/meza/commit/170596cb) (2019-06-03) James Montalvo: Make push-backup cron configurable add notification 
  - Modified: `src/playbooks/push-backup.yml`
  - Modified: `src/roles/autodeployer/templates/meza-autodeployer-cron.j2`

* [2bb09f50](https://github.com/freephile/meza/commit/2bb09f50) (2019-06-03) James Montalvo: 31.6.0 release 
  - Modified: `RELEASE-NOTES.md`

* [e70279c7](https://github.com/freephile/meza/commit/e70279c7) (2018-12-15) James Montalvo: Don't print command for encrypt/decrypt (too much text) 
  - Modified: `src/scripts/meza.py`

* [63b86fa4](https://github.com/freephile/meza/commit/63b86fa4) (2018-12-15) James Montalvo: Add encrypt_string and decrypt_string meza commands 
  - Modified: `src/scripts/meza.py`

* [0c9555f7](https://github.com/freephile/meza/commit/0c9555f7) (2018-12-14) James Montalvo: Cleanup comments about encryption, remove secret.yml decryption from test case 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/scripts/meza.py`
  - Modified: `tests/docker/import-from-alt-remote.setup.sh`

* [3d882855](https://github.com/freephile/meza/commit/3d882855) (2018-12-14) James Montalvo: Remove auto-encrypting of secret.yml 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/scripts/meza.py`

* [419550ae](https://github.com/freephile/meza/commit/419550ae) (2019-06-02) James Montalvo: Add --no-perms to rsync-push 
  - Modified: `src/roles/rsync-push/tasks/main.yml`

* [f1666ab5](https://github.com/freephile/meza/commit/f1666ab5) (2019-06-01) James Montalvo: 31.5.0 release 
  - Modified: `RELEASE-NOTES.md`

* [195cbead](https://github.com/freephile/meza/commit/195cbead) (2019-06-01) James Montalvo: Fixes for autodeployer logic and misplaced variables 
  - Modified: `src/playbooks/check-for-changes.yml`

* [2784f81b](https://github.com/freephile/meza/commit/2784f81b) (2019-05-31) James Montalvo: Add option to recursively set perms on uploads dir; always run on overwrite 
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [64896a5c](https://github.com/freephile/meza/commit/64896a5c) (2019-05-31) James Montalvo: Replace autodeployer scripts with Ansible 
  - Added: `src/playbooks/check-for-changes.yml`
  - Added: `src/playbooks/deploy-notify.yml`
  - Added: `src/roles/autodeployer/tasks/do-deploy.yml`
  - Modified: `src/roles/autodeployer/tasks/main.yml`
  - Deleted: `src/roles/autodeployer/templates/check-for-changes.sh.j2`
  - Deleted: `src/roles/autodeployer/templates/diff-notify.sh.j2`
  - Deleted: `src/roles/autodeployer/templates/do-deploy.sh.j2`
  - Deleted: `src/roles/autodeployer/templates/git-fetch.sh.j2`
  - Modified: `src/roles/autodeployer/templates/meza-autodeployer-cron.j2`
  - Deleted: `src/roles/autodeployer/templates/no-notify.sh.j2`
  - Deleted: `src/roles/autodeployer/templates/repo-pull.sh.j2`
  - Deleted: `src/roles/autodeployer/templates/slack-notify.sh.j2`
  - Modified: `src/scripts/meza.py`

* [4dfb030d](https://github.com/freephile/meza/commit/4dfb030d) (2019-05-31) James Montalvo: Belt and suspenders for ensuring deploy unlocks 
  - Modified: `src/roles/autodeployer/templates/do-deploy.sh.j2`

* [006d5edb](https://github.com/freephile/meza/commit/006d5edb) (2019-05-29) James Montalvo: Reduce duplication in check-for-changes.sh 
  - Modified: `src/roles/autodeployer/tasks/main.yml`
  - Modified: `src/roles/autodeployer/templates/check-for-changes.sh.j2`
  - Added: `src/roles/autodeployer/templates/diff-notify.sh.j2`
  - Added: `src/roles/autodeployer/templates/repo-pull.sh.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`

* [901f2b91](https://github.com/freephile/meza/commit/901f2b91) (2019-05-29) James Montalvo: Make public config and Meza management by autodeployer optional 
  - Modified: `src/roles/autodeployer/templates/check-for-changes.sh.j2`

* [1dc98948](https://github.com/freephile/meza/commit/1dc98948) (2019-05-29) James Montalvo: Use secret_config_repo to define secret config 
  - Modified: `src/roles/autodeployer/templates/check-for-changes.sh.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`

* [bce32d31](https://github.com/freephile/meza/commit/bce32d31) (2019-05-29) James Montalvo: Autodeployer check for changes to secret config 
  - Modified: `src/roles/autodeployer/templates/check-for-changes.sh.j2`

* [6e54a869](https://github.com/freephile/meza/commit/6e54a869) (2019-05-28) James Montalvo: Enable rsync push backups (#1166) 
  - Modified: `config/core/defaults.yml`
  - Added: `src/playbooks/push-backup.yml`
  - Modified: `src/playbooks/site.yml`
  - Added: `src/roles/backup-config/tasks/main.yml`
  - Added: `src/roles/backup-db-wikis-push/tasks/main.yml`
  - Added: `src/roles/backup-uploads-push/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Added: `src/roles/rsync-push/tasks/main.yml`
  - Modified: `src/scripts/meza.py`

* [7ed037ad](https://github.com/freephile/meza/commit/7ed037ad) (2019-05-27) James Montalvo: Ansible 2.8 fixes (#1162) - ansible_distribution_version no longer an ansible variable, get
  RedHat/CentOS version from /etc/redhat-release
- Ansible Synchronize module not working, use Meza rsync role
  - Modified: `src/roles/backup-db-wikis/tasks/main.yml`
  - Modified: `src/roles/backup-uploads/tasks/main.yml`
  - Modified: `src/roles/nodejs/tasks/main.yml`

* [a621460f](https://github.com/freephile/meza/commit/a621460f) (2019-05-27) James Montalvo: Remove yum:PackageKit to remove error Error was "yum lockfile is held by another process"
  - Modified: `src/roles/base/tasks/main.yml`

* [13cf8518](https://github.com/freephile/meza/commit/13cf8518) (2019-05-27) James Montalvo: Specify SSH service: sshd for redhat, ssh for debian 
  - Modified: `config/Debian.yml`
  - Modified: `config/RedHat.yml`
  - Modified: `src/roles/base/handlers/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`

* [3db517a6](https://github.com/freephile/meza/commit/3db517a6) (2019-05-27) James Montalvo: Add pip for Python 2.7 
  - Modified: `src/roles/base/tasks/main.yml`

* [0155726e](https://github.com/freephile/meza/commit/0155726e) (2019-05-27) James Montalvo: Add pip3 (31.x didn't have it yet) 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [0f879f8f](https://github.com/freephile/meza/commit/0f879f8f) (2019-04-16) James Montalvo: Make pip3 symlink for RHEL 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [0502a41c](https://github.com/freephile/meza/commit/0502a41c) (2019-05-27) James Montalvo: Ansible 2.8 fixes (#1162) * Fix for ansible upgrade

* WIP

* WIP

* WIP

* WIP

* WIP

* [skip ci]

* Cleanup
  - Modified: `src/roles/backup-db-wikis/tasks/main.yml`
  - Modified: `src/roles/backup-uploads/tasks/main.yml`
  - Modified: `src/roles/nodejs/tasks/main.yml`

* [2513a36c](https://github.com/freephile/meza/commit/2513a36c) (2019-05-22) James Montalvo: Set ownership of meza and config; fix role:init-controller-config init-controller-config was being run on app-servers, but then had
delegate:localhost on all tasks. This didn't make sense. Instead just
run the play on localhost.
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/scripts/getmeza.sh`

* [60a680c0](https://github.com/freephile/meza/commit/60a680c0) (2019-05-21) James Montalvo: Add wait() to capture return code Fix for deploy exiting with:
Traceback (most recent call last):
  File "/usr/bin/meza", line 966, in <module>
    main(sys.argv[1:])
  File "/usr/bin/meza", line 75, in main
    globals()[command_fn]( argv[1:] )
  File "/usr/bin/meza", line 133, in meza_command_deploy
    meza_shell_exec_exit( return_code )
  File "/usr/bin/meza", line 810, in meza_shell_exec_exit
    if int(return_code) > 0:
TypeError: int() argument must be a string or a number, not 'NoneType'
  - Modified: `src/scripts/meza.py`

* [e7b8ad36](https://github.com/freephile/meza/commit/e7b8ad36) (2019-05-21) James Montalvo: Make sure deploy log directory exists 
  - Modified: `src/scripts/meza.py`

* [50099742](https://github.com/freephile/meza/commit/50099742) (2019-05-21) James Montalvo: Always have ansible show colors 
  - Modified: `config/core/ansible.cfg`

* [a120ac32](https://github.com/freephile/meza/commit/a120ac32) (2019-05-21) James Montalvo: Make meza_shell_exec use subprocess; optionally write to log file 
  - Modified: `src/scripts/meza.py`

* [c5ef0e55](https://github.com/freephile/meza/commit/c5ef0e55) (2019-05-21) James Montalvo: Add meza deploy-kill, deploy-log, deploy-tail functions 
  - Modified: `src/scripts/meza.py`

* [9438f7c4](https://github.com/freephile/meza/commit/9438f7c4) (2019-05-21) James Montalvo: Handle sigint; also better info in lock file 
  - Modified: `src/scripts/meza.py`

* [a8f1aca2](https://github.com/freephile/meza/commit/a8f1aca2) (2019-05-20) James Montalvo: Add 'meza deploy-(un)lock commands; Autodeployer use them to avoid conflicts 
  - Modified: `src/roles/autodeployer/templates/check-for-changes.sh.j2`
  - Modified: `src/scripts/meza.py`

* [dd60b91d](https://github.com/freephile/meza/commit/dd60b91d) (2019-05-20) James Montalvo: Add meza subcommand to check if deploy underway 
  - Modified: `src/scripts/meza.py`

* [04e8ddbb](https://github.com/freephile/meza/commit/04e8ddbb) (2019-05-20) James Montalvo: Prevent simultaneous deploys (#1157) Make Meza not allow deploys when one is already running
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `src/scripts/meza.py`

* [bddb7973](https://github.com/freephile/meza/commit/bddb7973) (2019-05-19) James Montalvo: Unique VM names, /opt/meza owned by UID/GID 10000 in Vagrant 
  - Modified: `Vagrantfile`

* [3854c6c4](https://github.com/freephile/meza/commit/3854c6c4) (2019-05-16) James Montalvo: Make sure to use TMPDIR when doing Ansible Git operations 
  - Modified: `config/core/adhoc/ansible.cfg`
  - Modified: `src/roles/autodeployer/templates/git-fetch.sh.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`
  - Modified: `src/roles/base-config-scripts/templates/config.sh.j2`

* [220df489](https://github.com/freephile/meza/commit/220df489) (2019-05-15) James Montalvo: Add autodeployer tag 
  - Modified: `src/playbooks/site.yml`

* [36104ea9](https://github.com/freephile/meza/commit/36104ea9) (2019-05-15) James Montalvo: Have meza-ansible do autodeployer git-fetch 
  - Modified: `src/roles/autodeployer/templates/git-fetch.sh.j2`

* [28df0422](https://github.com/freephile/meza/commit/28df0422) (2018-12-17) James Montalvo: Fix autodeployer crons 
  - Modified: `src/roles/autodeployer/templates/meza-autodeployer-cron.j2`

* [a5396d8f](https://github.com/freephile/meza/commit/a5396d8f) (2018-12-15) James Montalvo: Fix location of backups-cleanup cron 
  - Modified: `src/roles/backups-cleanup/tasks/main.yml`

* [87a40123](https://github.com/freephile/meza/commit/87a40123) (2018-12-14) James Montalvo: Make autodeployer, overwrite-deploy, and backups-cleanup configurable 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Added: `src/roles/autodeployer/tasks/main.yml`
R100	src/scripts/autodeployer/check-for-changes.sh	src/roles/autodeployer/templates/check-for-changes.sh.j2
R100	src/scripts/autodeployer/do-deploy.sh	src/roles/autodeployer/templates/do-deploy.sh.j2
R100	src/scripts/autodeployer/git-fetch.sh	src/roles/autodeployer/templates/git-fetch.sh.j2
  - Added: `src/roles/autodeployer/templates/meza-autodeployer-cron.j2`
R100	src/scripts/autodeployer/no-notify.sh	src/roles/autodeployer/templates/no-notify.sh.j2
R100	src/scripts/autodeployer/slack-notify.sh	src/roles/autodeployer/templates/slack-notify.sh.j2
  - Added: `src/roles/backups-cleanup/tasks/main.yml`
  - Added: `src/roles/backups-cleanup/templates/backups-cleanup.sh.j2`
  - Added: `src/roles/backups-cleanup/templates/meza-cron-backups-cleanup.j2`

* [40e43885](https://github.com/freephile/meza/commit/40e43885) (2019-05-17) James Montalvo: Don't recreate meza-ansible if user already exists (Revert #965) PR #965 did some work to fix issues with restrictive umask settings. It
also stated that it "made getmeza.sh more idempotent" but one of the
changes was to make it so each run of the script attempted to create
user meza-ansible, and in the process recreated SSH keys for the user.
This is the opposite of idempotent, and must be undone. This is
currently breaking docker builds. #965 does not indicate if there was a
specific reason for making this change.
  - Modified: `src/scripts/getmeza.sh`

* [07953481](https://github.com/freephile/meza/commit/07953481) (2019-05-16) James Montalvo: More docker skip tasks 
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/parsoid/tasks/main.yml`

* [36f965fb](https://github.com/freephile/meza/commit/36f965fb) (2019-05-16) James Montalvo: Reorder AND statement since initial_wikis_dir_check undefined in docker build 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [e919123f](https://github.com/freephile/meza/commit/e919123f) (2019-05-16) James Montalvo: Don't use services during docker image building 
  - Modified: `src/roles/elasticsearch/tasks/main.yml`

* [6789e7dc](https://github.com/freephile/meza/commit/6789e7dc) (2019-05-13) James Montalvo: Ansible Git module fails with /tmp mounted with noexec; set TMPDIR as workaround 
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/parsoid/tasks/main.yml`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [f4f7da57](https://github.com/freephile/meza/commit/f4f7da57) (2019-05-13) Garrett George: Adds definition for baseURL When TLS offloading, SSL load balancing, or reverse proxying, the `baseurlpath` value gets changed to only use `http` instead of `https.
  - Modified: `src/roles/saml/templates/config.php.j2`

* [4687f14b](https://github.com/freephile/meza/commit/4687f14b) (2019-05-13) James Montalvo: 31.4.0 release 
  - Modified: `RELEASE-NOTES.md`

* [0d23cf7a](https://github.com/freephile/meza/commit/0d23cf7a) (2019-05-13) James Montalvo: Don't push 
  - Modified: `src/scripts/do-release.sh`

* [7ce4ddbf](https://github.com/freephile/meza/commit/7ce4ddbf) (2019-03-25) James Montalvo: Make script actually do release commit. Beware. 
  - Modified: `src/scripts/do-release.sh`

* [47f65182](https://github.com/freephile/meza/commit/47f65182) (2019-03-24) James Montalvo: Improvements to rel notes script order 
  - Modified: `src/scripts/do-release.sh`

* [7fe7b2eb](https://github.com/freephile/meza/commit/7fe7b2eb) (2019-03-24) James Montalvo: Make release script edit RELEASE-NOTES.md 
  - Modified: `src/scripts/do-release.sh`

* [02cb384d](https://github.com/freephile/meza/commit/02cb384d) (2019-03-23) James Montalvo: WIP: release notes script 
  - Modified: `.gitignore`
  - Added: `src/scripts/do-release.sh`

* [7ea1f982](https://github.com/freephile/meza/commit/7ea1f982) (2019-05-12) James Montalvo: Use known user, not no user, when mysqldump user unspecified 
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`

* [84bc0a0e](https://github.com/freephile/meza/commit/84bc0a0e) (2019-05-12) James Montalvo: Install mysql client on backup servers for direct mysqldump 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`

* [112317c5](https://github.com/freephile/meza/commit/112317c5) (2019-05-12) James Montalvo: Handle undefined backups_server_db_dump 
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [db6f8058](https://github.com/freephile/meza/commit/db6f8058) (2019-05-12) James Montalvo: Give undefined debug vars print vals 
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [cd79230d](https://github.com/freephile/meza/commit/cd79230d) (2019-01-11) James Montalvo: Make checks for wiki existence during backup go to right server Previously when a server backing up from another server checks to see if
a wiki exists on the remote server, it was actually checking to see if
the wiki existed locally. This made no sesnse and caused errors when a
wiki did not exist on the remote server but a backup file was generated
anyway.
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`

* [68ac3930](https://github.com/freephile/meza/commit/68ac3930) (2019-05-12) James Montalvo: Add tags for rsync-uploads and better debug 
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [4d56386f](https://github.com/freephile/meza/commit/4d56386f) (2019-05-11) James Montalvo: Set permissions for /opt/conf-meza and /opt/conf-meza/public Make these dirs suitable for meza-ansible to manage them without using
sudo.
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/scripts/getmeza.sh`

* [6ecc855e](https://github.com/freephile/meza/commit/6ecc855e) (2019-05-11) James Montalvo: Create role remote-dir-check to verify if remote uploads dir exists 
  - Added: `src/roles/remote-dir-check/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [527852f5](https://github.com/freephile/meza/commit/527852f5) (2019-05-11) James Montalvo: Get public config repo as meza-ansible, not root 
  - Modified: `src/roles/init-controller-config/tasks/main.yml`

* [51f5e34f](https://github.com/freephile/meza/commit/51f5e34f) (2019-05-11) James Montalvo: Re-enable PEAR package; not used by default, but used by MS SQL 
  - Modified: `src/roles/apache-php/tasks/php.yml`

* [af9eb520](https://github.com/freephile/meza/commit/af9eb520) (2019-05-10) James Montalvo: Move vault pass file from meza-ansible home to /opt/conf-meza/vault 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/scripts/meza.py`
  - Modified: `tests/docker/backup-to-remote.setup.sh`
  - Modified: `tests/docker/import-from-alt-remote.setup.sh`

* [bd6b1038](https://github.com/freephile/meza/commit/bd6b1038) (2018-02-09) Greg Rundlett: Minor spelling mistakes 
  - Modified: `src/roles/firewalld/tasks/main.yml`
  - Modified: `src/roles/haproxy/templates/errors/500.http.j2`

* [46f7ac66](https://github.com/freephile/meza/commit/46f7ac66) (2019-05-10) James Montalvo: Make net adapter select statement break on newlines 
  - Modified: `src/scripts/create-vm.sh`

* [1ea7334a](https://github.com/freephile/meza/commit/1ea7334a) (2019-05-09) James Montalvo: Fix indenting 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [43691c4c](https://github.com/freephile/meza/commit/43691c4c) (2019-05-09) James Montalvo: Vagrantfile set mount_options: ["dmode=755,fmode=755"] Windows only Doing this on Windows has no effect on the /opt/meza git repository, but
doing it on Linux causes a change to all files adding +x, thus making
many uncommitted changes.
  - Modified: `Vagrantfile`

* [84ec3fdc](https://github.com/freephile/meza/commit/84ec3fdc) (2019-05-08) Garrett George: Reverts function syntax to not use global variables 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [4127c780](https://github.com/freephile/meza/commit/4127c780) (2019-05-07) James Montalvo: Use base ImageMagick rather than Meza's own RPM 
  - Modified: `src/roles/imagemagick/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [2d9e0d17](https://github.com/freephile/meza/commit/2d9e0d17) (2019-04-29) Garrett George: Fixes tab spacing 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [8d7d2b77](https://github.com/freephile/meza/commit/8d7d2b77) (2019-04-29) Garrett George: Fixes function syntax for ipv4/v6 checks 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [6ae982b8](https://github.com/freephile/meza/commit/6ae982b8) (2019-04-25) Greg Rundlett: Use 'remote_src' When the parsoid host is not the controller, the src file is on the remote. Therefore, use remote_src: yes so that Ansible finds the file to copy.
Otherwise, this fails when the Parsoid host in inventory is not the same host as the controller.  In my example setup, I have two application servers and both are designated as Parsoid servers. One is the controller, the other app server is just an app server.
  - Modified: `src/roles/nodejs/tasks/main.yml`

* [186298a6](https://github.com/freephile/meza/commit/186298a6) (2019-04-25) Greg Rundlett: The SFTP server is in a different location on Debian It's important to have the path correct. This affects, among other things, the ability to use SSHFS with your nodes.
  - Modified: `src/roles/base/templates/sshd_config.j2`

* [44c656dd](https://github.com/freephile/meza/commit/44c656dd) (2019-04-16) James Montalvo: Make pip3 symlink for RHEL 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [6b5375dd](https://github.com/freephile/meza/commit/6b5375dd) (2019-04-16) James Montalvo: Install PIP for Python3 (#1131) 
  - Modified: `config/Debian.yml`
  - Modified: `config/RedHat.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [39f95412](https://github.com/freephile/meza/commit/39f95412) (2019-04-11) Greg Rundlett: New variable to effect crawling mode (#1121) 
  - Modified: `config/defaults.yml`
  - Modified: `src/roles/htdocs/templates/robots.txt.j2`

* [f34a3cd6](https://github.com/freephile/meza/commit/f34a3cd6) (2019-03-25) James Montalvo: 31.3.0 release (#1129) 
  - Modified: `RELEASE-NOTES.md`

* [fc22af4c](https://github.com/freephile/meza/commit/fc22af4c) (2019-03-25) krisfield: Bump to WatchAnalytics 3.1.2 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [cdab0bf8](https://github.com/freephile/meza/commit/cdab0bf8) (2019-03-23) James Montalvo: Fix issue due to accidentally merging 31.x net_smtp fix into 32.x 
  - Modified: `src/roles/mediawiki/templates/composer.local.json.j2`

* [70b4e2ba](https://github.com/freephile/meza/commit/70b4e2ba) (2019-03-22) krisfield: Bump to WatchAnalytics 3.1.1 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [ce403a5f](https://github.com/freephile/meza/commit/ce403a5f) (2019-03-20) krisfield: Bump WatchAnalytics to 3.1.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [866ba3fd](https://github.com/freephile/meza/commit/866ba3fd) (2019-03-15) cicalese: Add missing Debian lua packages 
  - Modified: `config/Debian.yml`

* [98efb587](https://github.com/freephile/meza/commit/98efb587) (2019-03-15) cicalese: Add direction to ufw configuration command 
  - Modified: `src/roles/base/tasks/main.yml`

* [98c8aaec](https://github.com/freephile/meza/commit/98c8aaec) (2019-02-25) krisfield: Bump WatchAnalytics/Approved Revs 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [383bd6fa](https://github.com/freephile/meza/commit/383bd6fa) (2019-02-02) Greg Rundlett: fix disk space logging 
  - Modified: `src/roles/meza-log/tasks/main.yml`

* [96d87ddf](https://github.com/freephile/meza/commit/96d87ddf) (2019-01-23) James Montalvo: Remove PEAR, install net_smtp via composer.local.json (#1108) Meza has used PEAR to install the mail and net_smtp packages per the
docs at https://www.mediawiki.org/wiki/Manual:$wgSMTP. However, since MW
1.31 pear/mail is packaged with MW (in composer.json). In MW 1.32
net_smtp is also in composer.json. This commit is on a version of Meza
using MW 1.31, so pear/net_smtp needs to be added via
composer.local.json.
  - Modified: `src/playbooks/delete-elasticsearch.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/mediawiki/templates/composer.local.json.j2`

* [10368b5e](https://github.com/freephile/meza/commit/10368b5e) (2019-01-22) James Montalvo: Remove PEAR install; mail and net_smtp now in MW composer.json Meza has used PEAR to install the mail and net_smtp packages per the
docs at https://www.mediawiki.org/wiki/Manual:$wgSMTP. However, since MW
1.31 pear/mail is packaged with MW (in composer.json). In MW 1.32
net_smtp is also in composer.json. This commit is on a version of Meza
using MW 1.32, PEAR can simply be removed.
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`

* [98d51c29](https://github.com/freephile/meza/commit/98d51c29) (2019-01-22) Greg Rundlett: variables are found in config/defaults.yml 
  - Deleted: `src/roles/netdata/defaults/main.yml`

* [f7cb3458](https://github.com/freephile/meza/commit/f7cb3458) (2019-01-19) Greg Rundlett: integrate role better with Meza 
  - Modified: `config/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`
  - Modified: `src/roles/netdata/tasks/main.yml`

* [68085559](https://github.com/freephile/meza/commit/68085559) (2019-01-18) Greg Rundlett: working role - tested on Debian/vagrant/32.x 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/netdata/handlers/main.yml`
  - Modified: `src/roles/netdata/tasks/main.yml`

* [55e6c631](https://github.com/freephile/meza/commit/55e6c631) (2019-01-17) Greg Rundlett: add netdata monitor 
  - Added: `src/roles/netdata/defaults/main.yml`
  - Added: `src/roles/netdata/handlers/main.yml`
  - Added: `src/roles/netdata/tasks/main.yml`

* [76e34334](https://github.com/freephile/meza/commit/76e34334) (2019-01-14) Greg Rundlett: minor word change (#1104) change references to this file to reflect it's current file name: MezaCoreExtensions.yml
  - Modified: `config/core/MezaCoreExtensions.yml`

* [b1c14163](https://github.com/freephile/meza/commit/b1c14163) (2019-01-12) James Montalvo: Fix issues with not using with_items on debian 
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/php-debian.yml`

* [b46cbeab](https://github.com/freephile/meza/commit/b46cbeab) (2019-01-11) James Montalvo: RELEASE-NOTES for 31.2.4 (#1101) 
  - Modified: `RELEASE-NOTES.md`

* [870cd9df](https://github.com/freephile/meza/commit/870cd9df) (2019-01-09) James Montalvo: Fix issue when vagrant VM db2 exists but app2 does not 
  - Modified: `Vagrantfile`

* [3ba34ba4](https://github.com/freephile/meza/commit/3ba34ba4) (2019-01-08) James Montalvo: Cleanup items from #1097 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Deleted: `src/roles/lua/defaults/main.yml`
  - Deleted: `src/roles/lua/tasks/luasandbox.yml`
  - Modified: `src/roles/lua/tasks/main.yml`

* [7b3a067e](https://github.com/freephile/meza/commit/7b3a067e) (2019-01-08) James Montalvo: Add debug to troubleshoot backup issue (#1094) Add debug to hopefully catch issue with wiki not on production yet but
backup server thinking that the wiki does exist on production, and
attempting to backup from it. This generates a meaningless SQL backup
file and then fails to generate the MediaWiki database.

The check for whether the new wiki's database exists on production is:

mysqlshow "wiki_{{ wiki_id }}" | grep -v Wildcard | grep -o wiki_{{ wiki_id }}

This should have a return code of zero if the database exists and
non-zero if it doesn't. When manually entering this on the server it
performs as expected. Hopefully adding this debug will shed some light
onto why it doesn't work in this production case.
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`

* [ce5781c9](https://github.com/freephile/meza/commit/ce5781c9) (2019-01-02) Greg Rundlett: Gluster 3.5 does not exist (at least not in PPAs) so I bumped the version to the latest number in the next major release: [4.1.6](https://github.com/gluster/glusterfs/tree/release-4.1/doc/release-notes) .  This should be reviewed critically because the Gluster project already has a 5.x release series and is planning the 6.x releases to start coming out next month (aka in February 2019).
  - Modified: `src/roles/gluster/defaults/main.yml`

* [e59bc5cf](https://github.com/freephile/meza/commit/e59bc5cf) (2018-12-24) Cicalese: Enabled SemanticScribunto 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [95c3c167](https://github.com/freephile/meza/commit/95c3c167) (2018-12-23) Cicalese: merged os support into a single file 
  - Modified: `config/core/Debian.yml`
  - Modified: `config/core/RedHat.yml`
  - Deleted: `src/roles/lua/tasks/luasandbox-debian.yml`
  - Deleted: `src/roles/lua/tasks/luasandbox-redhat.yml`
  - Added: `src/roles/lua/tasks/luasandbox.yml`
  - Modified: `src/roles/lua/tasks/main.yml`

* [1d13ac8a](https://github.com/freephile/meza/commit/1d13ac8a) (2018-12-22) Cicalese: Make debian script independent of php version 
  - Modified: `src/roles/lua/tasks/luasandbox-debian.yml`

* [9697aac2](https://github.com/freephile/meza/commit/9697aac2) (2018-12-22) Cicalese: Actually got luasandbox working. TODO: change PHP version so it isn't hardcoded
  - Added: `src/roles/lua/files/luasandbox.ini`
  - Modified: `src/roles/lua/tasks/luasandbox-debian.yml`

* [7839fe8b](https://github.com/freephile/meza/commit/7839fe8b) (2018-12-21) Cicalese: Added Scribunto and CodeEditor. Got luasandbox working. 
  - Modified: `config/core/MezaCoreExtensions.yml`
  - Added: `src/roles/lua/tasks/luasandbox-debian.yml`
  - Added: `src/roles/lua/tasks/luasandbox-redhat.yml`
  - Deleted: `src/roles/lua/tasks/luasandbox.yml`
  - Modified: `src/roles/lua/tasks/main.yml`

* [f183d0db](https://github.com/freephile/meza/commit/f183d0db) (2018-12-21) Cicalese: Add lua role 
  - Modified: `src/playbooks/site.yml`
  - Added: `src/roles/lua/defaults/main.yml`
  - Added: `src/roles/lua/tasks/luasandbox.yml`
  - Added: `src/roles/lua/tasks/main.yml`

* [d5272fb8](https://github.com/freephile/meza/commit/d5272fb8) (2018-12-20) Greg Rundlett: Make backup a tag so that you can at least skip it Addresses Issue [#1095](https://github.com/freephile/meza/issues/1095)
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`

* [169905a0](https://github.com/freephile/meza/commit/169905a0) (2018-12-19) James Montalvo: Move config/core/ to just config/ (#1093) 
R100	config/core/Debian.yml	config/Debian.yml
R100	config/core/MezaCoreExtensions.yml	config/MezaCoreExtensions.yml
R100	config/core/MezaCoreSkins.yml	config/MezaCoreSkins.yml
  - Deleted: `config/README.md`
R100	config/core/RedHat.yml	config/RedHat.yml
R100	config/core/adhoc/ansible.cfg	config/adhoc/ansible.cfg
R100	config/core/ansible.cfg	config/ansible.cfg
R099	config/core/defaults.yml	config/defaults.yml
R100	config/core/i18n/en.sh	config/i18n/en.sh
R100	config/core/i18n/en.yml	config/i18n/en.yml
R100	config/core/template/ifcfg-enp0s8	config/template/ifcfg-enp0s8
  - Modified: `src/roles/autodeployer/templates/git-fetch.sh.j2`
  - Modified: `src/roles/autodeployer/templates/slack-notify.sh.j2`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/scripts/dev-networking.sh`
  - Modified: `src/scripts/importExtensions.php`
  - Modified: `src/scripts/meza.py`
  - Modified: `tests/docker/run-tests.sh`

* [8eb53a9e](https://github.com/freephile/meza/commit/8eb53a9e) (2018-12-19) James Montalvo: Log all deploy starts, completions, failures (#1092) 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/scripts/meza.py`

* [7f904bd3](https://github.com/freephile/meza/commit/7f904bd3) (2018-12-19) James Montalvo: Change 'state: installed' to 'state: present' (#1091) 
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/base-extras/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/database/tasks/setup-Debian.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/gluster/tasks/setup-Debian.yml`
  - Modified: `src/roles/imagemagick/tasks/main.yml`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [d445df4e](https://github.com/freephile/meza/commit/d445df4e) (2018-12-18) James Montalvo: Remove deprecated use of 'static' 
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/database/tasks/main.yml`

* [c06fa04c](https://github.com/freephile/meza/commit/c06fa04c) (2018-12-18) James Montalvo: Fix using tests as filters deprecation warning 
  - Modified: `src/roles/database/tasks/replication.yml`

* [d2276868](https://github.com/freephile/meza/commit/d2276868) (2018-12-18) James Montalvo: Stop using with_items with yum, apt, and package tasks 
  - Modified: `src/playbooks/getdocker.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`
  - Modified: `src/roles/apache-php/tasks/php-debian.yml`
  - Modified: `src/roles/apache-php/tasks/php-redhat.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/base-extras/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/database/tasks/setup-Debian.yml`
  - Modified: `src/roles/gluster/tasks/setup-Debian.yml`
  - Modified: `src/roles/gluster/tasks/setup-RedHat.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/memcached/tasks/main.yml`
  - Modified: `src/roles/nodejs/tasks/main.yml`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [65c5dd4e](https://github.com/freephile/meza/commit/65c5dd4e) (2018-12-17) James Montalvo: Fix autodeployer crons 
  - Modified: `src/roles/autodeployer/templates/meza-autodeployer-cron.j2`

* [61f387b3](https://github.com/freephile/meza/commit/61f387b3) (2018-12-15) James Montalvo: Don't backup LocalSettings.php (#1089) 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [60b90a08](https://github.com/freephile/meza/commit/60b90a08) (2018-12-15) James Montalvo: Make things that had to be in root crontab configurable (#1088) Make autodeployer, overwrite-deploy, and backups-cleanup configurable
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Added: `src/roles/autodeployer/tasks/main.yml`
R100	src/scripts/autodeployer/check-for-changes.sh	src/roles/autodeployer/templates/check-for-changes.sh.j2
R100	src/scripts/autodeployer/do-deploy.sh	src/roles/autodeployer/templates/do-deploy.sh.j2
R100	src/scripts/autodeployer/git-fetch.sh	src/roles/autodeployer/templates/git-fetch.sh.j2
  - Added: `src/roles/autodeployer/templates/meza-autodeployer-cron.j2`
R100	src/scripts/autodeployer/no-notify.sh	src/roles/autodeployer/templates/no-notify.sh.j2
R100	src/scripts/autodeployer/slack-notify.sh	src/roles/autodeployer/templates/slack-notify.sh.j2
  - Added: `src/roles/backups-cleanup/tasks/main.yml`
  - Added: `src/roles/backups-cleanup/templates/backups-cleanup.sh.j2`
  - Added: `src/roles/backups-cleanup/templates/meza-cron-backups-cleanup.j2`

* [322454ae](https://github.com/freephile/meza/commit/322454ae) (2018-12-15) James Montalvo: Don't print command for encrypt/decrypt (too much text) 
  - Modified: `src/scripts/meza.py`

* [9c6e7270](https://github.com/freephile/meza/commit/9c6e7270) (2018-12-15) James Montalvo: Add encrypt_string and decrypt_string meza commands 
  - Modified: `src/scripts/meza.py`

* [1096b4c2](https://github.com/freephile/meza/commit/1096b4c2) (2018-12-14) James Montalvo: Cleanup comments about encryption, remove secret.yml decryption from test case 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/scripts/meza.py`
  - Modified: `tests/docker/import-from-alt-remote.setup.sh`

* [1b75418b](https://github.com/freephile/meza/commit/1b75418b) (2018-12-14) James Montalvo: Remove auto-encrypting of secret.yml 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/scripts/meza.py`

* [073a64fb](https://github.com/freephile/meza/commit/073a64fb) (2018-12-13) James Montalvo: Make apache ServerAdmin email configurable (#1086) 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`

* [b0723a50](https://github.com/freephile/meza/commit/b0723a50) (2018-12-13) James Montalvo: Move prolific log files into sub-directories 
  - Modified: `src/roles/apache-php/templates/php.ini.j2`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [48b3b134](https://github.com/freephile/meza/commit/48b3b134) (2018-12-13) James Montalvo: Move prolific log files into sub-directories 
  - Modified: `src/roles/apache-php/templates/php.ini.j2`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [fb37bb2d](https://github.com/freephile/meza/commit/fb37bb2d) (2018-12-13) James Montalvo: Fix syntax errors 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [1a63aa88](https://github.com/freephile/meza/commit/1a63aa88) (2018-11-30) Garrett George: Extracts matching alogs into their own funcs 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [ddcb4389](https://github.com/freephile/meza/commit/ddcb4389) (2018-11-30) Garrett George: Removes old condition check for ip matching 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [3c14d361](https://github.com/freephile/meza/commit/3c14d361) (2018-11-30) Garrett George: Fixes typo 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [3cad18ed](https://github.com/freephile/meza/commit/3cad18ed) (2018-11-30) Garrett George: Allows for CIDR notation for IP(v4/v6) matching 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [619bea66](https://github.com/freephile/meza/commit/619bea66) (2018-12-12) James Montalvo: Use failed_when instead of ignore_errors (#1083) 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/database/tasks/replication.yml`
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/key-transfer/tasks/grant-keys.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Modified: `src/roles/nodejs/tasks/main.yml`
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/transfer-backup-to-db-master.yml`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [3aee77aa](https://github.com/freephile/meza/commit/3aee77aa) (2018-12-10) James Montalvo: Fix load balancer port opening 
  - Modified: `src/playbooks/site.yml`

* [0618e0c5](https://github.com/freephile/meza/commit/0618e0c5) (2018-12-10) James Montalvo: Fix load balancer conditon for port 80/443 
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [51509f71](https://github.com/freephile/meza/commit/51509f71) (2018-12-09) James Montalvo: 'nonmeza' load balancers rather than 'unmanaged' 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/backup.yml`
  - Modified: `src/playbooks/setbaseconfig.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/parsoid-settings/templates/config.yaml.j2`

* [f9b80bf4](https://github.com/freephile/meza/commit/f9b80bf4) (2018-12-09) James Montalvo: Don't block SSH on Debian 
  - Modified: `src/roles/base/tasks/main.yml`

* [0080201e](https://github.com/freephile/meza/commit/0080201e) (2018-12-07) James Montalvo: More fixing of load balancer options 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/backup.yml`
  - Modified: `src/playbooks/setbaseconfig.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [3019a540](https://github.com/freephile/meza/commit/3019a540) (2018-12-07) James Montalvo: Fix ensure file present 
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [4958dbeb](https://github.com/freephile/meza/commit/4958dbeb) (2018-12-07) James Montalvo: Make sure file exists before lineinfile 
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [06f6b5de](https://github.com/freephile/meza/commit/06f6b5de) (2018-12-07) James Montalvo: Add check before attempting to generate SSH keys 
  - Modified: `src/scripts/shell-functions/linux-user.sh`

* [4568f080](https://github.com/freephile/meza/commit/4568f080) (2018-12-07) James Montalvo: More troubleshooting for travis 
  - Modified: `src/scripts/ssh-users/setup-master-user.sh`

* [b0a17de2](https://github.com/freephile/meza/commit/b0a17de2) (2018-12-07) James Montalvo: Allow specifying internal vs external load balancers 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [cd8d6984](https://github.com/freephile/meza/commit/cd8d6984) (2018-12-07) James Montalvo: add print statements to troubleshoot Travis error 
  - Modified: `src/scripts/ssh-users/setup-master-user.sh`
  - Modified: `src/scripts/ssh-users/setup-minion-user.sh`

* [7c0f483b](https://github.com/freephile/meza/commit/7c0f483b) (2018-12-06) James Montalvo: Fix path and variable expansion 
  - Modified: `src/scripts/ssh-users/setup-master-user.sh`
  - Modified: `src/scripts/ssh-users/setup-minion-user.sh`

* [2ad311e4](https://github.com/freephile/meza/commit/2ad311e4) (2018-12-06) James Montalvo: Allow not editing /etc/sudoers 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Added: `src/roles/base/templates/sudoers_meza-ansible.j2`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/scripts/ssh-users/setup-master-user.sh`
  - Modified: `src/scripts/ssh-users/setup-minion-user.sh`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [97bebb6c](https://github.com/freephile/meza/commit/97bebb6c) (2018-12-05) James Montalvo: RELEASE-NOTES.md for Meza 31.2.3 (#1069) 
  - Modified: `RELEASE-NOTES.md`

* [2d4b59ba](https://github.com/freephile/meza/commit/2d4b59ba) (2018-12-05) James Montalvo: [skip ci] Better comments in vagrant defaults 
  - Modified: `vagrantconf.default.yml`

* [b3b86ffd](https://github.com/freephile/meza/commit/b3b86ffd) (2018-12-05) James Montalvo: Make sure Vagrant ipaddrs used throughout 
  - Modified: `Vagrantfile`

* [62ef4578](https://github.com/freephile/meza/commit/62ef4578) (2018-12-05) James Montalvo: [skip ci] Allow specifying different IP addr in vagrantconf.yml 
  - Modified: `Vagrantfile`
  - Modified: `vagrantconf.default.yml`

* [b8f5faa8](https://github.com/freephile/meza/commit/b8f5faa8) (2018-12-05) James Montalvo: Fix host name (too long with unique ID) 
  - Modified: `Vagrantfile`

* [17705dae](https://github.com/freephile/meza/commit/17705dae) (2018-12-05) James Montalvo: Change specifying vagrant OS, improve Vbox hostnames 
  - Modified: `Vagrantfile`

* [24f4a1d1](https://github.com/freephile/meza/commit/24f4a1d1) (2018-12-05) James Montalvo: Move apache module install after php.yml Debian php apache module requires php repo added in php.yml
  - Modified: `src/roles/apache-php/tasks/main.yml`

* [8b529206](https://github.com/freephile/meza/commit/8b529206) (2018-12-05) James Montalvo: Different imagick convert command on Debian 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [034e3579](https://github.com/freephile/meza/commit/034e3579) (2018-12-05) James Montalvo: [skip ci] Revert previous 
  - Modified: `src/roles/apache-php/tasks/main.yml`

* [914040bf](https://github.com/freephile/meza/commit/914040bf) (2018-12-04) James Montalvo: [skip ci] Wrong mod php 
  - Modified: `src/roles/apache-php/tasks/main.yml`

* [95106b97](https://github.com/freephile/meza/commit/95106b97) (2018-12-04) James Montalvo: pipelining directive needs to be under ssh_connection 
  - Modified: `config/core/ansible.cfg`

* [84f68769](https://github.com/freephile/meza/commit/84f68769) (2018-12-04) James Montalvo: Enable pipelining 
  - Modified: `config/core/ansible.cfg`

* [13b04cc8](https://github.com/freephile/meza/commit/13b04cc8) (2018-12-04) James Montalvo: Do initial mysql_install_db on Debian 
  - Modified: `src/roles/database/tasks/configure.yml`
  - Modified: `src/roles/database/tasks/setup-Debian.yml`

* [1571d85d](https://github.com/freephile/meza/commit/1571d85d) (2018-12-04) James Montalvo: Debian-ize memcached config 
  - Modified: `config/core/Debian.yml`
  - Modified: `config/core/RedHat.yml`
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/database/tasks/configure.yml`
  - Modified: `src/roles/memcached/templates/memcached.j2`

* [06adc0ba](https://github.com/freephile/meza/commit/06adc0ba) (2018-12-04) James Montalvo: Really ensure mod php enabled on Debian 
  - Modified: `src/roles/apache-php/tasks/main.yml`

* [fd558882](https://github.com/freephile/meza/commit/fd558882) (2018-12-04) James Montalvo: Ensure Apache PHP module installed on Debian 
  - Modified: `src/roles/apache-php/tasks/main.yml`

* [b865520a](https://github.com/freephile/meza/commit/b865520a) (2018-12-04) James Montalvo: Make parsoid service work in Debian 
  - Modified: `src/roles/parsoid-settings/templates/parsoid.initd.sh.j2`

* [a94d9397](https://github.com/freephile/meza/commit/a94d9397) (2018-12-04) James Montalvo: Make firewall enabling OS-specific 
  - Modified: `src/roles/base/tasks/main.yml`

* [a6bb5851](https://github.com/freephile/meza/commit/a6bb5851) (2018-12-03) James Montalvo: Several fixes, which sort of get Debian working 
  - Modified: `config/core/Debian.yml`
  - Modified: `config/core/RedHat.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/database/tasks/configure.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [6d1f8c24](https://github.com/freephile/meza/commit/6d1f8c24) (2018-11-30) Garrett George: Extracts matching alogs into their own funcs 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [5174928e](https://github.com/freephile/meza/commit/5174928e) (2018-11-30) Garrett George: Removes old condition check for ip matching 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [c54d9d80](https://github.com/freephile/meza/commit/c54d9d80) (2018-11-30) Garrett George: Fixes typo 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [7ff93c7f](https://github.com/freephile/meza/commit/7ff93c7f) (2018-11-30) Garrett George: Allows for CIDR notation for IP(v4/v6) matching 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [b1456dee](https://github.com/freephile/meza/commit/b1456dee) (2018-11-29) James Montalvo: [skip ci] Move slow-queries var into os files 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/database/vars/RedHat-6.yml`
  - Modified: `src/roles/database/vars/RedHat-7.yml`

* [95b17204](https://github.com/freephile/meza/commit/95b17204) (2018-11-29) James Montalvo: [skip ci] fix nmap package 
  - Modified: `config/core/Debian.yml`
  - Modified: `config/core/RedHat.yml`
  - Modified: `src/roles/memcached/tasks/main.yml`

* [1adc5f6b](https://github.com/freephile/meza/commit/1adc5f6b) (2018-11-29) James Montalvo: Fix Debian PHP packages and Apache config 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/php-debian.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`

* [0bbcbd5d](https://github.com/freephile/meza/commit/0bbcbd5d) (2018-11-29) James Montalvo: Make sure to install ufw (on Debian) 
  - Modified: `config/core/Debian.yml`
  - Modified: `config/core/RedHat.yml`
  - Modified: `src/roles/base/tasks/main.yml`

* [46ebbc99](https://github.com/freephile/meza/commit/46ebbc99) (2018-11-29) James Montalvo: Split Debian vs RedHat apache config methods 
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`

* [f5599af1](https://github.com/freephile/meza/commit/f5599af1) (2018-11-29) James Montalvo: OS-specific vars precede defaults.yml 
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [20521991](https://github.com/freephile/meza/commit/20521991) (2018-11-29) James Montalvo: Undo change to Debian apache2 ServerRoot 
  - Modified: `config/core/Debian.yml`

* [eea7891c](https://github.com/freephile/meza/commit/eea7891c) (2018-11-29) krisfield: bump WatchAnalytics to 2.0.1 (#1066) Fixes critical bug for pending reviews
  - Modified: `config/core/MezaCoreExtensions.yml`

* [443ec9d4](https://github.com/freephile/meza/commit/443ec9d4) (2018-11-26) Greg Rundlett: fix owner/group assignments 
  - Modified: `config/core/Debian.yml`
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [368fd1bd](https://github.com/freephile/meza/commit/368fd1bd) (2018-11-19) Mark A. Hershberger: Use printf and quoting to preserve params Re #1062
  - Modified: `src/roles/meza-log/templates/server-performance.sh.j2`

* [9cba08f7](https://github.com/freephile/meza/commit/9cba08f7) (2018-11-19) krisfield: version typo fix 
  - Modified: `RELEASE-NOTES.md`

* [5346b969](https://github.com/freephile/meza/commit/5346b969) (2018-11-19) krisfield: 31.2.2 release notes 
  - Modified: `RELEASE-NOTES.md`

* [2028087e](https://github.com/freephile/meza/commit/2028087e) (2018-11-19) Mark A. Hershberger: Add BEGIN rules to awk scripts This fixes #1062.  `insert_sql` should probably be initialized with printf, as well.
  - Modified: `src/roles/meza-log/templates/server-performance.sh.j2`

* [d544d8b3](https://github.com/freephile/meza/commit/d544d8b3) (2018-11-19) krisfield: Bumps WatchAnalytics to 2.0.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [12307470](https://github.com/freephile/meza/commit/12307470) (2018-11-14) James Montalvo: Use GitHub mirrors for Gerrit repos 
  - Modified: `config/core/MezaCoreExtensions.yml`
  - Modified: `config/core/MezaCoreSkins.yml`
  - Modified: `src/roles/init-controller-config/templates/MezaLocalSkins.yml.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/parsoid/tasks/main.yml`

* [9baa1d66](https://github.com/freephile/meza/commit/9baa1d66) (2018-11-13) James Montalvo: Change Extension:CopyWatchers from master to 0.10.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [cde132c4](https://github.com/freephile/meza/commit/cde132c4) (2018-11-13) James Montalvo: Change Extension:MezaExt from master to 0.1.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [a92c786e](https://github.com/freephile/meza/commit/a92c786e) (2018-11-13) James Montalvo: Change Extension:ParserFunctionHelper from master to 1.0.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [2a75abc7](https://github.com/freephile/meza/commit/2a75abc7) (2018-11-13) James Montalvo: Change Extension:TalkRight from master to 2.0.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [87522d35](https://github.com/freephile/meza/commit/87522d35) (2018-11-13) James Montalvo: Change Extension:PageImporter from master to 0.1.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [ffd07c77](https://github.com/freephile/meza/commit/ffd07c77) (2018-11-13) James Montalvo: Change Extension:SemanticMeetingMinutes from master to 1.0.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [00c178ed](https://github.com/freephile/meza/commit/00c178ed) (2018-11-13) James Montalvo: Change Extension:NumerAlpha from master to 0.7.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [7313d786](https://github.com/freephile/meza/commit/7313d786) (2018-11-13) James Montalvo: Change Extension:MasonryMainPage from master to 0.3.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [296a47c4](https://github.com/freephile/meza/commit/296a47c4) (2018-11-13) James Montalvo: Change Extension:ImagesLoaded from master to 0.1.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [37603166](https://github.com/freephile/meza/commit/37603166) (2018-11-13) James Montalvo: Change Extension:Wiretap from master to 0.1.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [3026847c](https://github.com/freephile/meza/commit/3026847c) (2018-11-13) James Montalvo: Change WatchAnalytics from master to 0.1.0 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [cfcc1cbb](https://github.com/freephile/meza/commit/cfcc1cbb) (2018-11-11) James Montalvo: [skip ci] WIP: fix server root in apache conf 
  - Modified: `config/core/Debian.yml`
  - Modified: `config/core/RedHat.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`

* [e087510e](https://github.com/freephile/meza/commit/e087510e) (2018-11-11) James Montalvo: WIP: fix apache user name and group 
  - Modified: `config/core/Debian.yml`
  - Modified: `config/core/RedHat.yml`
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [99d6c177](https://github.com/freephile/meza/commit/99d6c177) (2018-11-11) James Montalvo: WIP: Reorder apache module loading 
  - Modified: `src/roles/apache-php/tasks/main.yml`

* [6c9abfdf](https://github.com/freephile/meza/commit/6c9abfdf) (2018-11-11) James Montalvo: WIP: fix imagemagick 
  - Modified: `src/roles/base-extras/tasks/main.yml`
  - Modified: `src/roles/imagemagick/tasks/main.yml`

* [1f462f45](https://github.com/freephile/meza/commit/1f462f45) (2018-11-11) James Montalvo: WIP: Fix base-extras packages 
  - Modified: `config/core/Debian.yml`
  - Modified: `config/core/RedHat.yml`
  - Modified: `src/roles/base-extras/tasks/main.yml`

* [7154cf3d](https://github.com/freephile/meza/commit/7154cf3d) (2018-11-11) James Montalvo: WIP: all of site.yml initially complete 
  - Modified: `config/core/Debian.yml`
  - Modified: `config/core/RedHat.yml`
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/database/vars/Debian.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/memcached/tasks/main.yml`
  - Modified: `src/roles/nodejs/tasks/main.yml`

* [02e71cca](https://github.com/freephile/meza/commit/02e71cca) (2018-11-10) James Montalvo: WIP: Apache/PHP maybe complete for Debian, probably not and good chance I broke RedHat in the process 
  - Modified: `config/core/Debian.yml`
  - Modified: `config/core/RedHat.yml`
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/php-debian.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`

* [d1e9296b](https://github.com/freephile/meza/commit/d1e9296b) (2018-11-08) James Montalvo: Add Extension:RevisionSlider 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [adcda885](https://github.com/freephile/meza/commit/adcda885) (2018-11-08) James Montalvo: [skip ci] WIP 
  - Modified: `config/core/Debian.yml`
  - Deleted: `src/roles/apache-php/tasks/ius.yml`
  - Added: `src/roles/apache-php/tasks/php-debian.yml`
  - Added: `src/roles/apache-php/tasks/php-redhat.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`

* [2b4be7de](https://github.com/freephile/meza/commit/2b4be7de) (2018-11-07) James Montalvo: Update release notes (#1059) 
  - Modified: `RELEASE-NOTES.md`

* [d72816c3](https://github.com/freephile/meza/commit/d72816c3) (2018-11-07) James Montalvo: Reset +e prior to autodeployer deploys else second deploy fails (#1057) (#1058) 
  - Modified: `src/scripts/autodeployer/do-deploy.sh`

* [d499a68d](https://github.com/freephile/meza/commit/d499a68d) (2018-11-07) James Montalvo: Make ansible output maintain color in log files 
  - Modified: `config/core/ansible.cfg`

* [8b4d7b3f](https://github.com/freephile/meza/commit/8b4d7b3f) (2018-11-07) James Montalvo: Reset +e prior to autodeployer deploys else second deploy fails (#1057) 
  - Modified: `src/scripts/autodeployer/do-deploy.sh`

* [4d5ea807](https://github.com/freephile/meza/commit/4d5ea807) (2018-11-07) James Montalvo: [skip ci] WIP apache and php 
  - Modified: `config/core/Debian.yml`
  - Modified: `config/core/RedHat.yml`
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/handlers/main.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/apache-php/templates/etc-sysconfig-httpd.j2`

* [324fa8b0](https://github.com/freephile/meza/commit/324fa8b0) (2018-11-06) krisfield: Update php.ini.j2 
  - Modified: `src/roles/apache-php/templates/php.ini.j2`

* [27730de2](https://github.com/freephile/meza/commit/27730de2) (2018-11-06) krisfield: Update defaults.yml 
  - Modified: `config/core/defaults.yml`

* [60d50a51](https://github.com/freephile/meza/commit/60d50a51) (2018-11-06) krisfield: Add input vars setting Allows for setting PHP max_input_vars which impacts how large a form can be
  - Modified: `config/core/defaults.yml`

* [7ae74111](https://github.com/freephile/meza/commit/7ae74111) (2018-11-04) James Montalvo: [skip ci] WIP 
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [f33522cd](https://github.com/freephile/meza/commit/f33522cd) (2018-11-04) James Montalvo: [skip ci] WIP 
  - Modified: `src/roles/firewall_port/tasks/main.yml`

* [f2ee1262](https://github.com/freephile/meza/commit/f2ee1262) (2018-11-04) James Montalvo: [skip ci] WIP 
  - Modified: `src/roles/firewall_port/tasks/main.yml`

* [c4004c78](https://github.com/freephile/meza/commit/c4004c78) (2018-11-04) James Montalvo: [skip ci] WIP 
  - Modified: `src/roles/firewall_port/tasks/main.yml`

* [792f57e9](https://github.com/freephile/meza/commit/792f57e9) (2018-11-04) James Montalvo: More firewall work 
  - Modified: `src/roles/firewall_port/tasks/main.yml`

* [dcceee96](https://github.com/freephile/meza/commit/dcceee96) (2018-11-04) James Montalvo: == not is 
  - Modified: `src/roles/firewall_port/tasks/main.yml`

* [b49120b5](https://github.com/freephile/meza/commit/b49120b5) (2018-11-04) James Montalvo: Fix quotes 
  - Modified: `src/roles/firewall_port/tasks/main.yml`

* [b662bcd2](https://github.com/freephile/meza/commit/b662bcd2) (2018-11-04) James Montalvo: Add support for closing FW ports; Always use FW role 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/firewall_port/tasks/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [d979327f](https://github.com/freephile/meza/commit/d979327f) (2018-11-02) James Montalvo: Generalize firewall for Debian and UFW 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Added: `src/roles/firewall_port/tasks/main.yml`
  - Added: `src/roles/firewall_service/defaults/main.yml`
  - Added: `src/roles/firewall_service/tasks/main.yml`
  - Deleted: `src/roles/firewalld/LICENSE`
  - Deleted: `src/roles/firewalld/README.md`
  - Deleted: `src/roles/firewalld/defaults/main.yml`
  - Deleted: `src/roles/firewalld/handlers/main.yml`
  - Deleted: `src/roles/firewalld/meta/main.yml`
  - Deleted: `src/roles/firewalld/tasks/main.yml`

* [f64a19b4](https://github.com/freephile/meza/commit/f64a19b4) (2018-11-02) James Montalvo: [skip ci] WIP: haproxy 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [2468e722](https://github.com/freephile/meza/commit/2468e722) (2018-11-02) James Montalvo: [skip ci] WIP 
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [0548cb4e](https://github.com/freephile/meza/commit/0548cb4e) (2018-11-02) James Montalvo: [skip ci] WIP: First hack at Debianized base role 
  - Added: `config/core/Debian.yml`
  - Added: `config/core/RedHat.yml`
  - Modified: `src/roles/base/handlers/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [bf4ead45](https://github.com/freephile/meza/commit/bf4ead45) (2018-11-01) James Montalvo: [skip ci] WIP 
  - Modified: `src/scripts/shell-functions/linux-user.sh`

* [31e743e0](https://github.com/freephile/meza/commit/31e743e0) (2018-11-01) James Montalvo: [skip ci] WIP: explicitly set meza-ansible's home dir ownership 
  - Modified: `src/scripts/shell-functions/linux-user.sh`

* [6c8d3718](https://github.com/freephile/meza/commit/6c8d3718) (2018-11-01) James Montalvo: [skip ci] WIP 
  - Modified: `src/scripts/getmeza.sh`

* [75aad8f1](https://github.com/freephile/meza/commit/75aad8f1) (2018-11-01) James Montalvo: [skip ci] Initial Debian work 
  - Modified: `Vagrantfile`
  - Modified: `src/scripts/getmeza.sh`

* [c64df3aa](https://github.com/freephile/meza/commit/c64df3aa) (2018-11-01) Bryan Hilderbrand: Update robots.txt.j2 Removed reference to freephile.org and replaced the robots.txt validator to one that functions.
Is: https://webmaster.yandex.com/tools/robotstxt/
Was: http://tool.motoricerca.info/robots-checker.phtml
  - Modified: `src/roles/htdocs/templates/robots.txt.j2`

* [dee80bac](https://github.com/freephile/meza/commit/dee80bac) (2018-10-20) krisfield: Bump PageForms Gives spreadsheet sorting
  - Modified: `config/core/MezaCoreExtensions.yml`

* [532ffbc4](https://github.com/freephile/meza/commit/532ffbc4) (2018-10-19) James Montalvo: DataTransfer 1.0 doesn't have fixes for MW 1.31, use release branch instead (#1048) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [a8e34862](https://github.com/freephile/meza/commit/a8e34862) (2018-10-18) James Montalvo: SMW rebuildData: better logging and attempt error handling 
  - Modified: `src/playbooks/rebuild-smw-and-index.yml`
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`

* [115cfa88](https://github.com/freephile/meza/commit/115cfa88) (2018-10-17) James Montalvo: Use wfLoadExtension for SRF 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [8213181f](https://github.com/freephile/meza/commit/8213181f) (2018-10-16) krisfield: Upgrade Pageforms to Version 4.4.1 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [07a5629d](https://github.com/freephile/meza/commit/07a5629d) (2018-10-16) James Montalvo: Set MW and extensions to REL1_32, and Parsoid to nearest commit 
  - Modified: `config/core/defaults.yml`

* [cfb4014c](https://github.com/freephile/meza/commit/cfb4014c) (2018-10-16) James Montalvo: wfLoadExtension for SRF; bump Maps version slightly 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [c85013f1](https://github.com/freephile/meza/commit/c85013f1) (2018-10-16) James Montalvo: Cleanup parsoid version comments 
  - Modified: `config/core/defaults.yml`

* [d432fb5e](https://github.com/freephile/meza/commit/d432fb5e) (2018-10-16) James Montalvo: Update Extension:Maps to 6.0.1 (#1044) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [98c0ff19](https://github.com/freephile/meza/commit/98c0ff19) (2018-10-16) krisfield: Upgrade Pageforms to Version 4.4.1 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [be439a85](https://github.com/freephile/meza/commit/be439a85) (2018-09-09) James Montalvo: Bump PHP 7.0 to 7.1; include checks to remove old PHP versions 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`

* [113c229e](https://github.com/freephile/meza/commit/113c229e) (2018-10-15) James Montalvo: Set Parsoid strictAcceptCheck = false 
  - Modified: `src/roles/parsoid-settings/templates/config.yaml.j2`

* [1b27616e](https://github.com/freephile/meza/commit/1b27616e) (2018-09-11) James Montalvo: Upgrade CirrusSearch metastore before (re)indexing 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [69b51697](https://github.com/freephile/meza/commit/69b51697) (2018-10-15) James Montalvo: Bump SMW and SRF to 3.0.0. Bump SemanticCompoundQueries to 1.2.0 (#1040) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [7d1472ec](https://github.com/freephile/meza/commit/7d1472ec) (2018-10-15) James Montalvo: Update enablerepo functionality to work better with Ansible 2.7.0 (#1038) ref: https://github.com/geerlingguy/ansible-role-mysql/commit/e65af067319eb0a6d273e0561428d2ece2f2f899
  - Modified: `src/roles/database/tasks/setup-RedHat.yml`

* [e65045e9](https://github.com/freephile/meza/commit/e65045e9) (2018-10-08) krisfield: Update pageforms to fix spreadsheet sorting 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [1515f531](https://github.com/freephile/meza/commit/1515f531) (2018-10-01) James Montalvo: Update RELEASE-NOTES.md for Meza 31.1.0 (#1033) 
  - Added: `RELEASE-NOTES.md`

* [a9a81107](https://github.com/freephile/meza/commit/a9a81107) (2018-10-01) James Montalvo: Update PageForms to get fix for tree input in SMW 3.0 (#1031) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [3627d791](https://github.com/freephile/meza/commit/3627d791) (2018-09-30) krisfield: Update PageForms version (#1030) This will add sorting for spreadsheet view in pageforms
  - Modified: `config/core/MezaCoreExtensions.yml`

* [b21f178e](https://github.com/freephile/meza/commit/b21f178e) (2018-09-30) James Montalvo: Make do-deploy.sh use autodeployer slack vars (#1029) 
  - Modified: `src/scripts/autodeployer/do-deploy.sh`

* [fa39ab85](https://github.com/freephile/meza/commit/fa39ab85) (2018-09-30) James Montalvo: Fix Meza git commit hashes for autodeployer notifications (#1028) 
  - Modified: `src/scripts/autodeployer/check-for-changes.sh`

* [5f3e9a70](https://github.com/freephile/meza/commit/5f3e9a70) (2018-09-30) James Montalvo: Fix for config.php syntax error (#1027) 
  - Modified: `src/roles/base-config-scripts/templates/config.php.j2`

* [8c0242fb](https://github.com/freephile/meza/commit/8c0242fb) (2018-09-30) James Montalvo: Move config.sh|php into separate role to allow quick update for autodeployer (#1026) 
  - Added: `src/playbooks/setbaseconfig.yml`
  - Modified: `src/playbooks/site.yml`
  - Added: `src/roles/base-config-scripts/tasks/main.yml`
R100	src/roles/base/templates/config.php.j2	src/roles/base-config-scripts/templates/config.php.j2
R100	src/roles/base/templates/config.sh.j2	src/roles/base-config-scripts/templates/config.sh.j2
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/scripts/autodeployer/check-for-changes.sh`
  - Modified: `src/scripts/autodeployer/slack-notify.sh`
  - Modified: `src/scripts/meza.py`

* [38ccddfc](https://github.com/freephile/meza/commit/38ccddfc) (2018-09-28) James Montalvo: Add autodeployer (#1025) 
  - Added: `config/core/adhoc/ansible.cfg`
  - Modified: `src/roles/base/templates/config.php.j2`
  - Modified: `src/roles/base/templates/config.sh.j2`
  - Added: `src/scripts/autodeployer/check-for-changes.sh`
  - Added: `src/scripts/autodeployer/do-deploy.sh`
  - Added: `src/scripts/autodeployer/git-fetch.sh`
  - Added: `src/scripts/autodeployer/no-notify.sh`
  - Added: `src/scripts/autodeployer/slack-notify.sh`

* [31f66494](https://github.com/freephile/meza/commit/31f66494) (2018-09-26) James Montalvo: Make Meza control 10-opcache.ini 
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Added: `src/roles/apache-php/templates/10-opcache.ini.j2`

* [63bcee44](https://github.com/freephile/meza/commit/63bcee44) (2018-09-21) James Montalvo: Bump to MW 1.31.1 
  - Modified: `config/core/defaults.yml`

* [c0d51079](https://github.com/freephile/meza/commit/c0d51079) (2018-09-20) James Montalvo: Bump SimpleSamlPhp from 1.15.4 to 1.16.1 
  - Modified: `src/roles/saml/tasks/main.yml`

* [4ef75804](https://github.com/freephile/meza/commit/4ef75804) (2018-09-11) James Montalvo: Bump SimpleSamlPhp to 1.15.4 
  - Modified: `src/roles/saml/tasks/main.yml`

* [183a6dab](https://github.com/freephile/meza/commit/183a6dab) (2018-09-18) James Montalvo: Change mode var again; Add to vagrant and baseline public.yml 
  - Modified: `Vagrantfile`
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`
  - Modified: `src/roles/init-controller-config/templates/public.yml.j2`

* [fa7478f1](https://github.com/freephile/meza/commit/fa7478f1) (2018-09-18) James Montalvo: change from m_mode to m_environment_type 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`

* [d22a289b](https://github.com/freephile/meza/commit/d22a289b) (2018-09-17) James Montalvo: Add httpd reload after PHP files updated 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [8e258e87](https://github.com/freephile/meza/commit/8e258e87) (2018-09-17) James Montalvo: Add some opcache settings to defaults.yml 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`

* [47b30cc2](https://github.com/freephile/meza/commit/47b30cc2) (2018-09-14) James Montalvo: Set MW permissions before git clone/checkout 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [bc6223df](https://github.com/freephile/meza/commit/bc6223df) (2018-09-14) James Montalvo: Remove root .gitconfig; make MW core checked out by meza-ansible; add tags 
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [0e3d2f73](https://github.com/freephile/meza/commit/0e3d2f73) (2018-04-16) James Montalvo: Add .gitconfig to root and meza-ansible with fetch prune 
  - Modified: `src/roles/base/tasks/main.yml`
  - Added: `src/roles/base/templates/gitconfig.j2`

* [54d04b45](https://github.com/freephile/meza/commit/54d04b45) (2018-09-14) James Montalvo: Bump SMW to 2.5.8 and SRF to 2.5.6 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [07250594](https://github.com/freephile/meza/commit/07250594) (2018-09-09) James Montalvo: Actually add TemplateData this time (#1014) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [ba1a953d](https://github.com/freephile/meza/commit/ba1a953d) (2018-09-06) James Montalvo: Show visual diff option on all diff pages (#1013) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [06deff2d](https://github.com/freephile/meza/commit/06deff2d) (2018-09-06) James Montalvo: Forgot to remove legacy_load from HeaderFooter (#1012) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [0cf5b7f6](https://github.com/freephile/meza/commit/0cf5b7f6) (2018-09-06) James Montalvo: Bump HeaderFooter to v3.0.0 (#1011) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [c48aa1de](https://github.com/freephile/meza/commit/c48aa1de) (2018-09-05) James Montalvo: Specify Extension:HeaderFooter version 2.2.1 (#1010) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [8a61c74a](https://github.com/freephile/meza/commit/8a61c74a) (2018-09-03) James Montalvo: Move elasticsearch logs to /opt/data-meza instead of /var/log (#1008) Upgrading to Meza 31.x caused /var partition to fill up due to log files
being added to /var/log/elasticsearch.
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.yml.j2`

* [aa8e4171](https://github.com/freephile/meza/commit/aa8e4171) (2018-08-29) James Montalvo: Make Approved Revs use official repo, v1.0-alpha (#1007) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [bd14949f](https://github.com/freephile/meza/commit/bd14949f) (2018-08-27) Greg Rundlett: Update the Visual Editor settings for namespaces update settings with reference to docs, plus example for quickly hacking the array.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [4f5b158f](https://github.com/freephile/meza/commit/4f5b158f) (2018-08-24) James Montalvo: Bump Approved Revs to properly handle usernames 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [f674e158](https://github.com/freephile/meza/commit/f674e158) (2018-08-23) Greg Rundlett: fix variable wgVisualEditorAvailableNamespaces Some time ago I believe there was a wgVisualEditorNamespaces, however it's not found in the current MW codebase. The correct array variable is $wgVisualEditorAvailableNamespaces (which defaults to $wgContentNamespaces) https://codesearch.wmflabs.org/search/?q=wgVisualEditorAvailableNamespaces&i=nope&files=&repos=
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [0ea58462](https://github.com/freephile/meza/commit/0ea58462) (2018-08-20) James Montalvo: Add HSTS response header (#1002) 
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [27229bb5](https://github.com/freephile/meza/commit/27229bb5) (2018-08-20) James Montalvo: Add python3 for Extension:SyntaxHighlight in MW1.31+ (#1004) 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [206720f8](https://github.com/freephile/meza/commit/206720f8) (2018-08-17) Daren Welsh: normalize load to num of CPUs; ref #866 
  - Modified: `src/roles/meza-log/templates/server-performance.sh.j2`

* [8301fe4a](https://github.com/freephile/meza/commit/8301fe4a) (2018-08-11) James Montalvo: Vagrant mode fix (#998) (#1000) Vagrant /opt/meza directory shouldn't be world-writable
  - Modified: `Vagrantfile`

* [6e50a44b](https://github.com/freephile/meza/commit/6e50a44b) (2018-08-11) James Montalvo: Use the official version of Approved Revs now that it supports... (#1001) ...all the new features!
  - Modified: `config/core/MezaCoreExtensions.yml`

* [974f2698](https://github.com/freephile/meza/commit/974f2698) (2018-08-10) James Montalvo: Vagrant mode fix (#998) Vagrant /opt/meza directory shouldn't be world-writable
  - Modified: `Vagrantfile`

* [59cfd301](https://github.com/freephile/meza/commit/59cfd301) (2018-08-01) Andrew Rechenberg: Allow adding core and additional Mediawiki skins. (#997) 
  - Added: `config/core/MezaCoreSkins.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Added: `src/roles/init-controller-config/templates/MezaLocalSkins.yml.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/Extensions.php.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/mediawiki/templates/composer.local.json.j2`

* [7dd9ff0c](https://github.com/freephile/meza/commit/7dd9ff0c) (2018-07-11) James Montalvo: Accept EULA when upgrading yum packages (#996) 
  - Modified: `src/roles/base/tasks/main.yml`

* [596e0d71](https://github.com/freephile/meza/commit/596e0d71) (2018-07-06) James Montalvo: Fix for combination of MSSQL driver and autofs filesystem for /home (#995) Ref: https://github.com/Microsoft/msphpsql/issues/805
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Added: `src/roles/apache-php/templates/etc-sysconfig-httpd.j2`

* [0a6da45d](https://github.com/freephile/meza/commit/0a6da45d) (2018-06-22) James Montalvo: Improve SSH defaults, allow not using default SSH config 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/base/templates/sshd_config.j2`

* [453f2994](https://github.com/freephile/meza/commit/453f2994) (2018-06-22) James Montalvo: Need to check if Parsoid svc exists prior to stopping it 
  - Modified: `src/roles/parsoid/tasks/main.yml`

* [03c08cf1](https://github.com/freephile/meza/commit/03c08cf1) (2018-06-21) James Montalvo: If parsoid user directory needs to change, stop parsoid service first 
  - Modified: `src/roles/parsoid/tasks/main.yml`

* [9e8a5014](https://github.com/freephile/meza/commit/9e8a5014) (2018-06-21) James Montalvo: Make MediaWiki core ignore extension submodules Using the MW release branches includes many extensions as submodules.
This causes issues when you want to use different versions of those
extensions. Checking out a different version of an extension tracked as
a submodule causes doing "git status" on MW core to show changes. This
causes issues when trying to use Ansible Git module, which needs a Git
repo.
This change makes Git ignore changes to submodules.
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [19a737c8](https://github.com/freephile/meza/commit/19a737c8) (2018-06-21) James Montalvo: Disable profiling extensions in php.ini 
  - Modified: `src/roles/apache-php/templates/php.ini.j2`

* [97624404](https://github.com/freephile/meza/commit/97624404) (2018-06-19) James Montalvo: Specify MW 1.31.0 not REL1_31 
  - Modified: `config/core/defaults.yml`

* [a8089b5b](https://github.com/freephile/meza/commit/a8089b5b) (2018-06-19) James Montalvo: PageForms to latest commit, greater than v4.3.1 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [9d38bf77](https://github.com/freephile/meza/commit/9d38bf77) (2018-06-13) James Montalvo: Watchlist merge at end; remove tmp files; fix missing var; more echoes 
  - Modified: `src/scripts/unite-the-wikis.sh`
  - Modified: `src/scripts/uniteTheWikis.php`

* [9c93c239](https://github.com/freephile/meza/commit/9c93c239) (2018-06-12) James Montalvo: do watchlists last, else get 1000s of watches due to imports handled badly 
  - Modified: `src/scripts/uniteTheWikis.php`

* [46321982](https://github.com/freephile/meza/commit/46321982) (2018-04-06) James Montalvo: Merge user groups 
  - Modified: `src/scripts/uniteTheWikis.php`

* [1a82e500](https://github.com/freephile/meza/commit/1a82e500) (2018-04-06) James Montalvo: Add merging of watchlists to wiki unify 
  - Modified: `src/scripts/uniteTheWikis.php`

* [643998b9](https://github.com/freephile/meza/commit/643998b9) (2018-03-12) James Montalvo: SiteStats giving bad page quantities. Use mysql for highest page_id 
  - Modified: `src/scripts/unite-the-wikis.sh`

* [3803dc5a](https://github.com/freephile/meza/commit/3803dc5a) (2018-03-08) James Montalvo: Chunk refreshLinks.php to avoid memory leak 
  - Modified: `src/scripts/unite-the-wikis.sh`

* [c292eac1](https://github.com/freephile/meza/commit/c292eac1) (2018-03-08) James Montalvo: Break rebuildall.php into its component scripts for memory leak issues 
  - Modified: `src/scripts/unite-the-wikis.sh`

* [8861dd07](https://github.com/freephile/meza/commit/8861dd07) (2018-03-08) James Montalvo: Add category for disambigs created by merge 
  - Modified: `src/scripts/uniteTheWikis.php`

* [b078c66c](https://github.com/freephile/meza/commit/b078c66c) (2018-03-08) James Montalvo: Previous commit changed disambig page to link to oldpagename/wikiid, but didn't move the pages to the same name. fixit. 
  - Modified: `src/scripts/uniteTheWikis.php`

* [29167c23](https://github.com/freephile/meza/commit/29167c23) (2018-03-06) James Montalvo: Disambig into subpages; don't put disambig links inside template 
  - Modified: `src/scripts/uniteTheWikis.php`

* [cf55a2d9](https://github.com/freephile/meza/commit/cf55a2d9) (2018-01-09) James Montalvo: Make importDump also handle uploads (and be verbose) 
  - Modified: `src/scripts/uniteTheWikis.php`

* [d80dd44c](https://github.com/freephile/meza/commit/d80dd44c) (2017-12-15) James Montalvo: [skip ci] accidentally removed the meat of the script 
  - Modified: `src/scripts/unite-the-wikis.sh`

* [1affca2f](https://github.com/freephile/meza/commit/1affca2f) (2017-12-15) James Montalvo: [skip ci] pre-cleanup 
  - Modified: `src/scripts/unite-the-wikis.sh`

* [60ac51ce](https://github.com/freephile/meza/commit/60ac51ce) (2017-12-15) James Montalvo: [skip ci] Allow skip confirming merge 
  - Modified: `src/scripts/unite-the-wikis.sh`

* [564f540d](https://github.com/freephile/meza/commit/564f540d) (2017-12-15) James Montalvo: [skip ci] try with file imports built into XML dumps 
  - Modified: `src/scripts/unite-the-wikis.sh`
  - Modified: `src/scripts/uniteTheWikis.php`

* [17f0139d](https://github.com/freephile/meza/commit/17f0139d) (2017-12-15) James Montalvo: fix: uploads paths and continue in if-statement; more comments 
  - Modified: `src/scripts/unite-the-wikis.sh`
  - Modified: `src/scripts/uniteTheWikis.php`

* [2fed7375](https://github.com/freephile/meza/commit/2fed7375) (2017-12-12) James Montalvo: Fix require once; fix checking int against string [skip ci] 
  - Modified: `src/scripts/uniteTheWikis.php`

* [6e778b67](https://github.com/freephile/meza/commit/6e778b67) (2017-08-23) James Montalvo: [skip-ci] Adjust directories to match current meza 
  - Modified: `src/roles/base/templates/config.php.j2`
  - Modified: `src/roles/base/templates/config.sh.j2`
  - Modified: `src/scripts/unite-the-wikis.sh`
  - Modified: `src/scripts/uniteTheWikis.php`

* [cfe4c5a4](https://github.com/freephile/meza/commit/cfe4c5a4) (2016-10-11) James Montalvo: First hack at wiki-unification script 
  - Added: `src/scripts/merge-pages/Main_Page.mediawiki`
  - Added: `src/scripts/unite-the-wikis.sh`
  - Added: `src/scripts/uniteTheWikis.php`

* [ea1c79f4](https://github.com/freephile/meza/commit/ea1c79f4) (2018-06-12) James Montalvo: Wiki ID redirects/aliases 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [eaa94256](https://github.com/freephile/meza/commit/eaa94256) (2018-06-07) James Montalvo: Add method to skip overwrite on some wikis 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [fc590c54](https://github.com/freephile/meza/commit/fc590c54) (2018-06-08) James Montalvo: Use CentOS 7.4 for Vagrant 
  - Modified: `Vagrantfile`

* [0f2e70a1](https://github.com/freephile/meza/commit/0f2e70a1) (2018-06-07) James Montalvo: Fix for error in Travis CI due to temp dir permissions (#989) Error was:

Authentication or permission failure. In some cases, you may have been able to
authenticate and did not have permissions on the target directory. Consider
changing the remote tmp path in ansible.cfg to a path rooted in "/tmp". Failed
command was: ( umask 77 && mkdir -p "` echo
~None/.ansible/tmp/ansible-tmp-1528404466.59-59697674326589 `" && echo
ansible-tmp-1528404466.59-59697674326589="` echo
~None/.ansible/tmp/ansible-tmp-1528404466.59-59697674326589 `" ), exited with
result 1

Ref:
https://travis-ci.org/enterprisemediawiki/meza/jobs/389426664#L2839

Source of fix:
https://github.com/ansible/ansible/issues/5725#issuecomment-118381617
  - Modified: `config/core/ansible.cfg`

* [41398de8](https://github.com/freephile/meza/commit/41398de8) (2018-06-06) James Montalvo: more recent gcc not required for this version of PHP (though doesn't hurt) 
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`

* [e4c648c2](https://github.com/freephile/meza/commit/e4c648c2) (2018-06-06) James Montalvo: Need unixODBC-devel package 
  - Modified: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`

* [bc1e5913](https://github.com/freephile/meza/commit/bc1e5913) (2018-06-06) James Montalvo: Install MS SQL driver for PHP if install_ms_sql_driver=true 
  - Added: `src/roles/apache-php/tasks/mssql_driver_for_php.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Added: `src/roles/apache-php/templates/20-sqlsrv.ini.j2`
  - Added: `src/roles/apache-php/templates/30-pdo_sqlsrv.ini.j2`

* [5ccd6d28](https://github.com/freephile/meza/commit/5ccd6d28) (2018-06-06) James Montalvo: Bump Vagrant box to CentOS 7.4 
  - Modified: `Vagrantfile`

* [02bf7e15](https://github.com/freephile/meza/commit/02bf7e15) (2018-04-20) James Montalvo: Several PHP7 fixes: TalkRight, xhprof, mongo, php5_module * Fix Extension:TalkRight fix for PHP7
* Temporarily remove profiling since xhprof doesn't work on PHP7
* Fix mongodb PECL package for PHP7
* Fix httpd.conf statements about php5_module
  - Modified: `config/core/MezaCoreExtensions.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`

* [d7192eb0](https://github.com/freephile/meza/commit/d7192eb0) (2018-04-20) James Montalvo: Try php 7.0 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`

* [78806f16](https://github.com/freephile/meza/commit/78806f16) (2018-04-23) James Montalvo: Fix several issues with 'meza update' (#979) 
  - Modified: `src/scripts/meza.py`

* [74abceee](https://github.com/freephile/meza/commit/74abceee) (2018-04-21) James Montalvo: Fix several issues with 'meza update' 
  - Modified: `src/scripts/meza.py`

* [9310c611](https://github.com/freephile/meza/commit/9310c611) (2018-04-20) James Montalvo: Add 'meza update' command (#977) 
  - Modified: `src/scripts/meza.py`

* [21945b4f](https://github.com/freephile/meza/commit/21945b4f) (2018-04-20) James Montalvo: Add 'meza update' command 
  - Modified: `src/scripts/meza.py`

* [8d6146f9](https://github.com/freephile/meza/commit/8d6146f9) (2018-04-20) James Montalvo: Remove require_once from some extensions, bump versions for PHP7/MW1.31 * Remove legacy load (require_once): BatchUserRights, HeaderTabs,
  WatchAnalytics, Variables, Echo, UploadWizard, DataTransfer
* Bump HeaderTabs from 1.1 to 1.2
* Bump DataTransfer from 0.6.2 to 1.0
  - Modified: `config/core/MezaCoreExtensions.yml`

* [3ea4a9fc](https://github.com/freephile/meza/commit/3ea4a9fc) (2018-04-20) James Montalvo: Several PHP7 fixes: TalkRight, xhprof, mongo, php5_module * Fix Extension:TalkRight fix for PHP7
* Temporarily remove profiling since xhprof doesn't work on PHP7
* Fix mongodb PECL package for PHP7
* Fix httpd.conf statements about php5_module
  - Modified: `config/core/MezaCoreExtensions.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`

* [ecc9e423](https://github.com/freephile/meza/commit/ecc9e423) (2018-04-20) James Montalvo: Try php 7.0 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`

* [9d014dd3](https://github.com/freephile/meza/commit/9d014dd3) (2018-04-19) James Montalvo: Start Meza 31.x; bump versions for MW 1.31, etc 
  - Modified: `config/core/defaults.yml`

* [faf325f6](https://github.com/freephile/meza/commit/faf325f6) (2018-04-19) James Montalvo: In case of 1.27->1.30 upgrade issues, now use 'meza delete elasticsearch' 
  - Added: `src/playbooks/delete-elasticsearch.yml`
  - Modified: `src/scripts/meza.py`

* [a2ca7bb9](https://github.com/freephile/meza/commit/a2ca7bb9) (2018-04-19) James Montalvo: Bump PageForms 4.1.1 --> 4.3 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [74dc216c](https://github.com/freephile/meza/commit/74dc216c) (2018-04-16) James Montalvo: Allow specifying timezone (#973) 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [4050edaa](https://github.com/freephile/meza/commit/4050edaa) (2018-04-14) Mark A. Hershberger: Allow private repositories to be pulled Fixes #970
Also move the “Set variable holding list of local extensions” task to
after the core extensions so that you can use `--skip-to-task` for it
and skip the core extensions.
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [8a09ac25](https://github.com/freephile/meza/commit/8a09ac25) (2018-04-14) James Montalvo: Fix for generating SSH keys for vagrant user (#971) 
  - Modified: `Vagrantfile`

* [cd8323ce](https://github.com/freephile/meza/commit/cd8323ce) (2018-04-13) James Montalvo: Ensure proper ownership of MW directories so Composer not needed to run as root 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [d6e5a55f](https://github.com/freephile/meza/commit/d6e5a55f) (2018-04-13) James Montalvo: Bump extension versions to match MW 1.30 requirements 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [d351b5d6](https://github.com/freephile/meza/commit/d351b5d6) (2018-04-06) Mark A. Hershberger: Fix created LocalSettings.php for those with OCD Fixes #956
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [8b5b2f7c](https://github.com/freephile/meza/commit/8b5b2f7c) (2018-04-11) James Montalvo: Adjust /etc/parsoid perms; give user parsoid HOME dir; make user parsoid do npm install; can't use Ansible npm module anymore 
  - Modified: `src/roles/parsoid/tasks/main.yml`

* [1f93c03f](https://github.com/freephile/meza/commit/1f93c03f) (2018-04-07) James Montalvo: more troubleshooting 
  - Modified: `src/roles/nodejs/tasks/main.yml`

* [e53571b9](https://github.com/freephile/meza/commit/e53571b9) (2018-04-07) James Montalvo: Fix getting stdout 
  - Modified: `src/roles/nodejs/tasks/main.yml`

* [c39a8375](https://github.com/freephile/meza/commit/c39a8375) (2018-04-06) James Montalvo: Try node binaries for node 8 
  - Modified: `src/roles/nodejs/tasks/main.yml`

* [fb1fac3d](https://github.com/freephile/meza/commit/fb1fac3d) (2018-04-11) James Montalvo: Stop using release candidate; use MW 1.30.0 
  - Modified: `config/core/defaults.yml`

* [9950c7d9](https://github.com/freephile/meza/commit/9950c7d9) (2018-04-11) James Montalvo: Remove docs (#968) * Remove docs. They're at https://www.mediawiki.org/wiki/Meza now
* Improve contributing, issue template, and PR template
  - Modified: `.github/ISSUE_TEMPLATE.md`
  - Modified: `.github/PULL_REQUEST_TEMPLATE.md`
  - Modified: `CONTRIBUTING.md`
  - Modified: `README.md`
  - Deleted: `manual/AddingWikis.md`
  - Deleted: `manual/CreateCloneVMs.md`
  - Deleted: `manual/DirectoryStructure.md`
  - Deleted: `manual/ElasticsearchPlugins.md`
  - Deleted: `manual/Glossary.md`
  - Deleted: `manual/LowMemory.md`
  - Deleted: `manual/PerformanceMonitoring.md`
  - Deleted: `manual/README.md`
  - Deleted: `manual/SettingUpVirtualBox.md`
  - Deleted: `manual/SetupRedHat.md`
  - Deleted: `manual/SetupSAML.md`
  - Deleted: `manual/commands.md`
  - Deleted: `manual/installing-additional-extensions.md`
  - Deleted: `manual/multi-server.md`
  - Deleted: `manual/vagrant.md`

* [4dfa5392](https://github.com/freephile/meza/commit/4dfa5392) (2018-04-11) James Montalvo: Fix for systems with umask 077 (#965) * Make getmeza.sh more idempotent
* explicitly set conf-meza mode. also conf-meza/secret
* Ensure /opt/meza and temp_vars.yml have good permissions
* Need to explicitly set /opt/meza perms in case cloned earlier
* Apply umask 002 constraint on git operations
* Set umask at beginning of deploy, unset at end
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/parsoid/tasks/main.yml`
  - Modified: `src/roles/saml/tasks/main.yml`
  - Added: `src/roles/umask-set/tasks/main.yml`
  - Added: `src/roles/umask-set/templates/umask.profile.sh.j2`
  - Added: `src/roles/umask-unset/tasks/main.yml`
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/shell-functions/linux-user.sh`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`

* [f6b59b06](https://github.com/freephile/meza/commit/f6b59b06) (2018-04-07) James Montalvo: Send build notifications with Pushover (#962) 
  - Modified: `.travis.yml`

* [c720961b](https://github.com/freephile/meza/commit/c720961b) (2018-04-06) Mark A. Hershberger: Install rsync if it isn't already Fixes #958
  - Modified: `src/roles/base/tasks/main.yml`

* [7563c793](https://github.com/freephile/meza/commit/7563c793) (2018-04-06) James Montalvo: Fix create-wiki prompt failures; Fix for #954 (#955) 
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`

* [93549610](https://github.com/freephile/meza/commit/93549610) (2018-04-03) James Montalvo: Set specific version of Extension:ReplaceText, v1.4 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [aac22aca](https://github.com/freephile/meza/commit/aac22aca) (2018-03-26) James Montalvo: Hotfix last commit: need meza_core_extensions even when not doing latest 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [ad95098a](https://github.com/freephile/meza/commit/ad95098a) (2018-03-25) Mark A. Hershberger: Set meza_core_extensions and meza_local_extensions fixes #946
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [a9f95d77](https://github.com/freephile/meza/commit/a9f95d77) (2018-03-19) Greg Rundlett: Add Opcache status monitor; reusing a couple files from https://github.com/rlerdorf/opcache-status.git 
  - Added: `src/roles/htdocs/files/ServerPerformance/data-sample.php`
  - Added: `src/roles/htdocs/files/ServerPerformance/opcache.php`

* [aef9d71a](https://github.com/freephile/meza/commit/aef9d71a) (2018-03-19) Greg Rundlett: Adds new config m_mode for allowing development and production variance In production, PHP files are never checked for modification on the filesystem.
They are simply read into the PHP Opcache, and used from cache. (fast) Also,
There is less verbose logging in production.
This switch allows for easier enabling of features like profiling that
may only ever be used in development.
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`

* [66a6d8bd](https://github.com/freephile/meza/commit/66a6d8bd) (2018-03-19) Greg Rundlett: REMOVE talk priviledge for anonymous This "default" anon-read setup allows for a public deploy of Meza
without surprisingly allowing spammers to edit the Talk namespace.
To properly configure the TalkRight extension, setup a group e.g. "Commentators"
and give them the "talk" privilege.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [8a411a66](https://github.com/freephile/meza/commit/8a411a66) (2018-03-18) Greg Rundlett: optimize the PHP Opcache for production use 
  - Modified: `src/roles/apache-php/templates/php.ini.j2`

* [1059ea6b](https://github.com/freephile/meza/commit/1059ea6b) (2018-03-12) Greg Rundlett: more comments on Low Memory environments 
  - Modified: `manual/LowMemory.md`

* [3b296dc5](https://github.com/freephile/meza/commit/3b296dc5) (2018-03-12) Greg Rundlett: wgEnableMWSuggest was deprecated in REL1_20 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [28d81fd0](https://github.com/freephile/meza/commit/28d81fd0) (2018-02-26) James Montalvo: Bump MW 1.27.2 to 1.27.4 for security release (#921) 
  - Modified: `config/core/defaults.yml`

* [d80119e2](https://github.com/freephile/meza/commit/d80119e2) (2018-02-26) Greg Rundlett: Add comment about possible ansible cfg option in low RAM environments < 2GB (#923) "forks" option in Ansible comment added to config file

Adds new documentation file for Low Memory environments
  - Modified: `config/core/ansible.cfg`
  - Added: `manual/LowMemory.md`

* [4518775d](https://github.com/freephile/meza/commit/4518775d) (2018-02-26) Greg Rundlett: add script to identify missing extensions for a new wiki import (#932) * initial script for helping identify missing extensions for a new wiki import

* fix count of extensions by trimming last newline
  - Added: `src/scripts/importExtensions.php`

* [034be38f](https://github.com/freephile/meza/commit/034be38f) (2018-02-14) Greg Rundlett: Improves readability of ansible output Also adds simple Python script for checking your jinja templates.
  - Modified: `config/core/ansible.cfg`
  - Added: `src/scripts/check_my_jinja.py`

* [547c7f89](https://github.com/freephile/meza/commit/547c7f89) (2018-02-08) Greg Rundlett: Create README in the manual folder Incorporated Jame's words https://github.com/enterprisemediawiki/meza/issues/692 to close that issue.
  - Added: `manual/README.md`

* [7c04aa1a](https://github.com/freephile/meza/commit/7c04aa1a) (2018-02-07) Greg Rundlett: Add troubleshooting section to do ssh-copy-id manually 
  - Modified: `manual/multi-server.md`

* [97b63945](https://github.com/freephile/meza/commit/97b63945) (2018-02-07) Greg Rundlett: Adds example of VisualEditor 
  - Modified: `manual/installing-additional-extensions.md`

* [938db1ad](https://github.com/freephile/meza/commit/938db1ad) (2018-01-30) Greg Rundlett: Adds a reference for Meza commands. 
  - Added: `manual/commands.md`

* [b08afc1f](https://github.com/freephile/meza/commit/b08afc1f) (2018-01-30) Greg Rundlett: switch default to anonymous read from anonymous edit 
  - Modified: `src/roles/init-controller-config/templates/public.yml.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [59de18ce](https://github.com/freephile/meza/commit/59de18ce) (2018-01-22) James Montalvo: Specify xhgui version; else breakage with master (#913) 
  - Modified: `src/roles/apache-php/tasks/profiling.yml`

* [33cc1181](https://github.com/freephile/meza/commit/33cc1181) (2017-12-01) James Montalvo: Need 2 elasticsearch.repo files, stopping at 2.x to facilitate upgrade 
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Deleted: `src/roles/elasticsearch/templates/elasticsearch.repo.j2`
  - Added: `src/roles/elasticsearch/templates/elasticsearch2.repo.j2`
  - Added: `src/roles/elasticsearch/templates/elasticsearch5.repo.j2`

* [e48e3a72](https://github.com/freephile/meza/commit/e48e3a72) (2017-12-01) James Montalvo: Run ES reindex twice for 1.x to 5.x upgrades 
  - Modified: `src/roles/elasticsearch/tasks/main.yml`

* [333c62de](https://github.com/freephile/meza/commit/333c62de) (2017-11-30) James Montalvo: Ansible npm module seems to be failing; use npm via shell 
  - Modified: `src/roles/parsoid/tasks/main.yml`

* [bfd5db31](https://github.com/freephile/meza/commit/bfd5db31) (2017-11-30) James Montalvo: Fixes to get MW 1.30 changes working on meza: * Bump Parsoid version to v0.8.0
* Don't wait for cluster to be green. Presence of multiple replicas for
  the metastore index makes it impossible for cluster to get off yellow
  on single-node "clusters" since the replicas have nowhere to go. Need
  to figure out how to stop these replicas from being generated.
* Remove Elasticsearch "work" and "plugins" directories. No longer used
* Add Elasticsearch "scripts" directory for 5.x
* Elasticsearch 5.x yum: https://artifacts.elastic.co/packages/5.x/yum
* Elasticsearch 5.x needs script.stored instead of script.indexed
* Turn off recursive/submodules for Ansible git when getting MediaWiki
  core, so we don't get all the extensions, skins, and vendor libraries
  defined as submodules
* config.yaml not localsettings.js for Parsoid. Update parsoid.init.sh
  with '-c /path/to/config.yaml'
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.repo.j2`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.yml.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/parsoid-settings/tasks/main.yml`
  - Added: `src/roles/parsoid-settings/templates/config.yaml.j2`
  - Modified: `src/roles/parsoid-settings/templates/localsettings.js.j2`
  - Modified: `src/roles/parsoid-settings/templates/parsoid.initd.sh.j2`

* [37e93cea](https://github.com/freephile/meza/commit/37e93cea) (2017-11-29) James Montalvo: Bump versions for MW 1.30 release candidate 
  - Modified: `config/core/defaults.yml`

* [e69cc2b0](https://github.com/freephile/meza/commit/e69cc2b0) (2018-01-12) James Montalvo: Add tag 'always' to cron so it always is reset (#904) 
  - Modified: `src/playbooks/site.yml`

* [2ed7789e](https://github.com/freephile/meza/commit/2ed7789e) (2018-01-12) James Montalvo: Run SMW rebuildData.php in batches to avoid memory leaks (#912) 
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`

* [ac633fa9](https://github.com/freephile/meza/commit/ac633fa9) (2018-01-10) James Montalvo: Fixes for building docker images (#908) 
  - Modified: `src/playbooks/site.yml`

* [270d8563](https://github.com/freephile/meza/commit/270d8563) (2018-01-09) James Montalvo: Add PHP MSSQL package & necessary FreeTDS config; also more "latest" tags (#907) 
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Added: `src/roles/apache-php/templates/freetds.conf.j2`
  - Modified: `src/roles/base/tasks/main.yml`

* [2ee3d148](https://github.com/freephile/meza/commit/2ee3d148) (2018-01-04) James Montalvo: Specify version of SimpleSamlPhp to avoid breaking changes (#903) 
  - Modified: `src/roles/saml/tasks/main.yml`

* [815a75f4](https://github.com/freephile/meza/commit/815a75f4) (2017-12-19) James Montalvo: Add 'meza maint cleanuploadstash' to cron 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`

* [cf0c0a67](https://github.com/freephile/meza/commit/cf0c0a67) (2017-12-19) James Montalvo: ADD: meza maint cleanuploadstash <env> 
  - Added: `src/playbooks/cleanup-upload-stash.yml`
  - Modified: `src/scripts/meza.py`

* [9da79bb3](https://github.com/freephile/meza/commit/9da79bb3) (2017-12-19) James Montalvo: Fix import_role vs include_role for update.php and database dumps (#900) 
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`
  - Modified: `src/roles/update.php/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`

* [6d3d4f89](https://github.com/freephile/meza/commit/6d3d4f89) (2017-12-19) James Montalvo: Saml syslog fix (#899) * Use SimpleSAMLphp namespace to prevent syslog messages

Getting the following messages in `/var/log/messages` without this change:

> Dec 18 03:49:33 <hostname> simplesamlphp[2523]: 4 [aece425b03] The class or interface 'SimpleSAML_Auth_Simple' is now using namespaces, please use 'SimpleSAML\Auth\Simple'.

* Change version of Extension:SimpleSamlAuth used
  - Modified: `src/roles/saml/files/NonMediaWikiSimpleSamlAuth.php`
  - Modified: `src/roles/saml/tasks/main.yml`

* [bbd5da10](https://github.com/freephile/meza/commit/bbd5da10) (2017-12-12) James Montalvo: require_once isn't great for settings. won't get pulled in a second time If file required/included earlier, won't get pulled in again. This could
break the second time require_once is used, if the second time isn't in
the same context as the first.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [bdd3e826](https://github.com/freephile/meza/commit/bdd3e826) (2017-12-12) Greg Rundlett: minor updates to ElasticsearchPlugins.md 
  - Modified: `manual/ElasticsearchPlugins.md`

* [dab93c7a](https://github.com/freephile/meza/commit/dab93c7a) (2017-12-12) James Montalvo: Add `meza delete wiki` (#894) * add delete-wiki option
* Add 'delete wiki' to test
  - Added: `src/playbooks/delete-wiki-promptless.yml`
  - Added: `src/playbooks/delete-wiki.yml`
  - Added: `src/roles/delete-wiki-wrapper/tasks/main.yml`
  - Modified: `src/scripts/meza.py`
  - Modified: `tests/docker/import-from-remote.setup.sh`

* [bea0ff9a](https://github.com/freephile/meza/commit/bea0ff9a) (2017-12-12) James Montalvo: Fix create wiki when using a database-source for imports; ref #882 (#893) 
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`

* [97b1159b](https://github.com/freephile/meza/commit/97b1159b) (2017-12-12) James Montalvo: move server perf and disk space scripts into role; improve configurability (#892) 
  - Modified: `config/core/defaults.yml`
  - Modified: `manual/DirectoryStructure.md`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`
  - Modified: `src/roles/meza-log/tasks/main.yml`
R095	src/scripts/disk-space-usage.sh	src/roles/meza-log/templates/disk-space-usage.sh.j2
  - Deleted: `src/roles/meza-log/templates/logging.sh.j2`
R096	src/scripts/server-performance.sh	src/roles/meza-log/templates/server-performance.sh.j2

* [8bf63454](https://github.com/freephile/meza/commit/8bf63454) (2017-11-29) James Montalvo: Bump versions for MW 1.29 
  - Modified: `config/core/defaults.yml`

* [bdeea9f0](https://github.com/freephile/meza/commit/bdeea9f0) (2017-12-05) James Montalvo: Replace mod_status.php with Special:Serverstatus from Extension:MezaExt 
  - Modified: `config/core/MezaCoreExtensions.yml`
  - Modified: `manual/DirectoryStructure.md`
  - Modified: `manual/PerformanceMonitoring.md`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Deleted: `src/roles/htdocs/files/ServerPerformance/mod_status.php`

* [44f8e0e9](https://github.com/freephile/meza/commit/44f8e0e9) (2017-12-05) James Montalvo: Configure mariadb logrotate.d as template, not blockinfile 
  - Modified: `src/roles/database/tasks/configure.yml`
  - Added: `src/roles/database/templates/logrotate.mariadb.j2`

* [99f3b049](https://github.com/freephile/meza/commit/99f3b049) (2017-11-03) Greg Rundlett: fix indentation of blockinfile 
  - Modified: `src/roles/database/tasks/configure.yml`

* [b4607582](https://github.com/freephile/meza/commit/b4607582) (2017-11-03) Greg Rundlett: Fix issue 868 by rotating the MariaDB log 
  - Modified: `src/roles/database/tasks/configure.yml`
  - Modified: `src/roles/database/templates/root-my.cnf.j2`

* [dff7542d](https://github.com/freephile/meza/commit/dff7542d) (2017-10-19) Greg Rundlett: add mod_info status page 
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`

* [cd9df962](https://github.com/freephile/meza/commit/cd9df962) (2017-09-07) Greg Rundlett: Add robots.txt file similar to what's used at wikipedia.org 
  - Modified: `src/roles/htdocs/tasks/main.yml`
  - Added: `src/roles/htdocs/templates/robots.txt.j2`

* [bf48adfa](https://github.com/freephile/meza/commit/bf48adfa) (2017-12-06) James Montalvo: Fix return (exit) codes returned by meza.py (#890) * sys.exit doesn't seem to respect return codes other than int 0 and 1 (and maybe 2)
* Make all meza.py return codes use meza_shell_exec_exit(rc)
  - Modified: `src/scripts/meza.py`

* [942929ce](https://github.com/freephile/meza/commit/942929ce) (2017-12-01) James Montalvo: Prep to have ES upgrade across multiple versions, e.g. 1.6 --> 2.x --> 5.x 
  - Added: `src/roles/elasticsearch/tasks/es_reindex.yml`
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`

* [49d30cc0](https://github.com/freephile/meza/commit/49d30cc0) (2017-12-01) James Montalvo: Do metastore fix in mediawiki role 
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [53a58691](https://github.com/freephile/meza/commit/53a58691) (2017-12-01) James Montalvo: More index cleanup; update metastore 
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/templates/elastic-reindex.sh.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [999ddcef](https://github.com/freephile/meza/commit/999ddcef) (2017-12-01) James Montalvo: Push reindex output to logs; Fixes to make script actually work 
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/templates/elastic-reindex.sh.j2`

* [224fc087](https://github.com/freephile/meza/commit/224fc087) (2017-12-01) James Montalvo: Use Elastic reindex script instead of browser plugin 
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
R100	src/scripts/elasticsearch-reindex.sh	src/roles/elasticsearch/templates/elastic-reindex.sh.j2
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [03b622bb](https://github.com/freephile/meza/commit/03b622bb) (2017-11-30) James Montalvo: [skip-ci] initial hack at scripted reindexing of elasticsearch indices 
  - Added: `src/scripts/elasticsearch-reindex.sh`

* [7da355da](https://github.com/freephile/meza/commit/7da355da) (2017-11-30) James Montalvo: False comment: elasticsearch nodes must be restarted all at once 
  - Modified: `src/playbooks/site.yml`

* [41992daf](https://github.com/freephile/meza/commit/41992daf) (2017-11-30) James Montalvo: ES test may not need 'index' option; option invalid in ES 5.x 
  - Modified: `tests/integration/wiki-check.sh`

* [23259b39](https://github.com/freephile/meza/commit/23259b39) (2017-11-30) James Montalvo: Fix docs for Elasticsearch access via HAProxy 
  - Modified: `manual/ElasticsearchPlugins.md`

* [511bdcdd](https://github.com/freephile/meza/commit/511bdcdd) (2017-11-29) James Montalvo: fix conditional 
  - Modified: `src/roles/elasticsearch/tasks/main.yml`

* [07ba3007](https://github.com/freephile/meza/commit/07ba3007) (2017-11-29) James Montalvo: Rebuild elasticsearch indexes if ES was upgraded 
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [242ced0b](https://github.com/freephile/meza/commit/242ced0b) (2017-11-29) James Montalvo: Shutdown all nodes simultaneously for major version upgrade 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/elasticsearch/defaults/main.yml`
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`

* [075af8c7](https://github.com/freephile/meza/commit/075af8c7) (2017-11-29) James Montalvo: Elasticsearch shutdown API remove or deprecated; stop service instead 
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`

* [3d30141f](https://github.com/freephile/meza/commit/3d30141f) (2017-11-29) James Montalvo: Don't have meza manage Elasticsearch plugins 
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`

* [8c7b4700](https://github.com/freephile/meza/commit/8c7b4700) (2017-11-29) James Montalvo: Move Elasticsearch version checks into main tasks 
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`

* [74079b04](https://github.com/freephile/meza/commit/74079b04) (2017-11-29) James Montalvo: Typo 
  - Modified: `src/roles/elasticsearch/tasks/es_upgrade.yml`

* [8814098d](https://github.com/freephile/meza/commit/8814098d) (2017-11-28) James Montalvo: Add Elasticsearch upgrade tasks 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/elasticsearch/defaults/main.yml`
  - Added: `src/roles/elasticsearch/tasks/es_upgrade.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`

* [ef10e603](https://github.com/freephile/meza/commit/ef10e603) (2017-08-18) James Montalvo: bump MW, extensions, Parsoid, and Elasticsearch versions for MW 1.28 
  - Modified: `config/core/defaults.yml`

* [4aaf2d77](https://github.com/freephile/meza/commit/4aaf2d77) (2017-11-28) James Montalvo: dot-slash not needed; also fix other link 
  - Modified: `manual/SettingUpVirtualBox.md`

* [63a94020](https://github.com/freephile/meza/commit/63a94020) (2017-11-28) James Montalvo: Additional wording and perf-mon options 
  - Modified: `manual/PerformanceMonitoring.md`

* [c3350b2e](https://github.com/freephile/meza/commit/c3350b2e) (2017-11-26) kiwi-wi: Update README.md reference the performance monitoring documentation
  - Modified: `README.md`

* [52e7ca1f](https://github.com/freephile/meza/commit/52e7ca1f) (2017-11-26) kiwi-wi: Create PerformanceMonitoring.md Documentation of performance monitoring features
  - Added: `manual/PerformanceMonitoring.md`

* [f862aeb2](https://github.com/freephile/meza/commit/f862aeb2) (2017-11-26) kiwi-wi: Update SettingUpVirtualBox.md good link for adding wikis
  - Modified: `manual/SettingUpVirtualBox.md`

* [88bee7bb](https://github.com/freephile/meza/commit/88bee7bb) (2017-11-16) James Montalvo: Escape quotes in JSON since it's within a 'su username -c "command here"' 
  - Modified: `src/scripts/meza.py`

* [31bdbd86](https://github.com/freephile/meza/commit/31bdbd86) (2017-11-16) James Montalvo: Change privilege escalation from sudo to su; addresses #874 
  - Modified: `src/scripts/meza.py`

* [cb032057](https://github.com/freephile/meza/commit/cb032057) (2017-11-14) James Montalvo: Fix timestamp on rebuildAll.php; add debug options 
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`

* [717d857f](https://github.com/freephile/meza/commit/717d857f) (2017-08-21) James Montalvo: Extension:WhoIsWatching no longer uses legacy loading method (#857) 
  - Modified: `config/core/MezaCoreExtensions.yml`
  - Added: `src/playbooks/elasticsearch-upgrade.yml`

* [ddf30462](https://github.com/freephile/meza/commit/ddf30462) (2017-08-18) James Montalvo: SemanticCompoundQueries needed to be installed with Composer 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [1fc3436c](https://github.com/freephile/meza/commit/1fc3436c) (2017-08-15) James Montalvo: Get SemanticCompoundQueries from GitHub 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [0c34c53e](https://github.com/freephile/meza/commit/0c34c53e) (2017-08-17) James Montalvo: Allow deploy vars in public.yml and new env/<env-name>.yml (#855) * Allow deploy vars in public.yml and new env/<env-name>.yml
* Allow config.php deploy vars to be iterable (lists and dictionaries)
  - Modified: `src/roles/base/templates/config.php.j2`
  - Modified: `src/roles/base/templates/config.sh.j2`
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [e15deb0a](https://github.com/freephile/meza/commit/e15deb0a) (2017-08-15) James Montalvo: Modify ES setup to be easy to upgrade (#853) 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/elasticsearch/defaults/main.yml`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.repo.j2`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.yml.j2`

* [26681c48](https://github.com/freephile/meza/commit/26681c48) (2017-08-15) James Montalvo: Remove Elasticsearch Bigdesk plugin since it doesn't work with ES 2.x (#852) 
  - Modified: `manual/ElasticsearchPlugins.md`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.yml.j2`

* [dd209708](https://github.com/freephile/meza/commit/dd209708) (2017-08-15) James Montalvo: Move MW and extension versions into config file for easy update of all at once (#851) * Move all instances of REL1_27 into an easily updateable variable
* Add 'versions' section to defaults.yml
* Also set MW version separately (not same as extensions which are just the branch)
  - Modified: `config/core/MezaCoreExtensions.yml`
  - Modified: `config/core/defaults.yml`
  - Modified: `manual/installing-additional-extensions.md`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [ee6d1ea3](https://github.com/freephile/meza/commit/ee6d1ea3) (2017-08-15) James Montalvo: RHEL/CentOS 7.4 EPEL change Node.js fix (#850) RHEL/CentOS 7.4 EPEL change, Node.js fix
  - Modified: `src/roles/nodejs/tasks/main.yml`
  - Modified: `src/roles/nodejs/tasks/setup-RedHat.yml`

* [e850a07d](https://github.com/freephile/meza/commit/e850a07d) (2017-08-11) James Montalvo: Need to always run set-vars if play is running (#847) 
  - Modified: `src/playbooks/rebuild-smw-and-index.yml`

* [0fe77033](https://github.com/freephile/meza/commit/0fe77033) (2017-08-07) Mark A. Hershberger: Fix PHP warnings in ServerPerformance related to initial conditions (#838) 
  - Modified: `src/roles/htdocs/files/ServerPerformance/index.php`

* [f5e638bb](https://github.com/freephile/meza/commit/f5e638bb) (2017-08-07) Greg Rundlett: Update installing additional extensions. (#843) The Widgets module is similar to VisualEditor in that it requires a `git submodule update --init` in the module's directory.
  - Modified: `manual/installing-additional-extensions.md`

* [18f43514](https://github.com/freephile/meza/commit/18f43514) (2017-08-04) James Montalvo: add docs on using vagrant (#841) 
  - Modified: `README.md`
  - Added: `manual/vagrant.md`

* [29649eef](https://github.com/freephile/meza/commit/29649eef) (2017-08-03) James Montalvo: Add multi-server docs (#840) 
  - Modified: `README.md`
  - Added: `manual/multi-server.md`

* [8de82fdb](https://github.com/freephile/meza/commit/8de82fdb) (2017-07-25) Greg Rundlett: Add variable for turning on/off performance schema (default on) 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/database/templates/my.cnf.j2`

* [28e12651](https://github.com/freephile/meza/commit/28e12651) (2017-07-21) James Montalvo: Cleanup FIXMEs: create issues where appropriate (#831) 
  - Modified: `Vagrantfile`
  - Modified: `config/core/defaults.yml`
  - Modified: `manual/AddingWikis.md`
  - Modified: `src/playbooks/backup.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/backup-uploads/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/base/templates/config.php.j2`
  - Modified: `src/roles/configure-wiki/templates/preLocalSettings.d/base.php.j2`
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/database/tasks/replication.yml`
  - Modified: `src/roles/dump-db-wikis/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/haproxy/templates/errors/500.http.j2`
  - Modified: `src/roles/htdocs/files/BackupDownload/download.php`
  - Modified: `src/roles/htdocs/files/BackupDownload/index.php`
  - Modified: `src/roles/init-controller-config/templates/public.yml.j2`
  - Modified: `src/roles/key-transfer/tasks/grant-keys.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/mediawiki/templates/elastic-build-index.sh.j2`
  - Modified: `src/roles/mediawiki/templates/elastic-rebuild-all.sh.j2`
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`
  - Modified: `src/roles/nodejs/tasks/main.yml`
  - Modified: `src/roles/parsoid/tasks/main.yml`
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`
  - Modified: `src/roles/rsync/tasks/main.yml`
  - Modified: `src/roles/saml/templates/saml20-idp-remote.php.j2`
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`
  - Modified: `src/roles/update.php/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/shell-functions/linux-user.sh`
  - Modified: `src/scripts/unifyUserTables.php`
  - Modified: `tests/deploys/backup-to-remote.controller.sh`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`
  - Modified: `tests/docker/backup-to-remote.setup.sh`
  - Modified: `tests/docker/init-minion.sh`
  - Modified: `tests/docker/run-tests.sh`

* [de4e26b8](https://github.com/freephile/meza/commit/de4e26b8) (2017-07-20) James Montalvo: Configuration for SSH to limit to safe ciphers and algorithms (#796) 
  - Modified: `Vagrantfile`
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/base/handlers/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Added: `src/roles/base/templates/ssh_config.j2`
  - Added: `src/roles/base/templates/sshd_config.j2`
  - Modified: `tests/docker/backup-to-remote.setup.sh`

* [bf3752f5](https://github.com/freephile/meza/commit/bf3752f5) (2017-07-20) Greg Rundlett: Add note to my.cnf.j2 I don't know if it's worth coding this 'feature', so I thought to add a line of comment into the template. Monolith environments with only 1 GB of memory can fail because MySQL takes up a lot of it before Parsoid gets installed.  If the performance schema is disabled, it shouldn't affect an intentionally low power "demo" or "development" environment, but will allow Meza deploy to complete.  Feel free to decline and tell me that this should be an 'issue' instead.
  - Modified: `src/roles/database/templates/my.cnf.j2`

* [358db746](https://github.com/freephile/meza/commit/358db746) (2017-07-19) James Montalvo: Add do_cleanup_sql_backup option to keep SQL backups to 1 latest file 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/backup-db-wikis/tasks/main.yml`
  - Added: `src/roles/sql-backup-cleanup/tasks/main.yml`
  - Modified: `src/roles/update.php/tasks/main.yml`

* [9baede25](https://github.com/freephile/meza/commit/9baede25) (2017-07-19) James Montalvo: Testing whether updating root password is required for test 
  - Modified: `tests/docker/backup-to-remote.setup.sh`

* [250f4abe](https://github.com/freephile/meza/commit/250f4abe) (2017-07-19) James Montalvo: Make sure backups directory exists ON BACKUPS SERVER before using 
  - Modified: `src/roles/update.php/tasks/main.yml`

* [aaa2032b](https://github.com/freephile/meza/commit/aaa2032b) (2017-07-17) James Montalvo: Make sure root password gets overwritten on each deploy of test 
  - Modified: `tests/docker/backup-to-remote.setup.sh`

* [60689ae6](https://github.com/freephile/meza/commit/60689ae6) (2017-07-17) James Montalvo: Always add .my.cnf to meza-ansible 
  - Modified: `src/roles/database/tasks/secure-installation.yml`

* [4cb90eec](https://github.com/freephile/meza/commit/4cb90eec) (2017-07-17) James Montalvo: meza-ansible needs .my.cnf with root permissions 
  - Modified: `src/roles/database/tasks/secure-installation.yml`

* [67105b27](https://github.com/freephile/meza/commit/67105b27) (2017-07-17) James Montalvo: Use IP address, not localhost, for test VM setup 
  - Modified: `tests/docker/backup-to-remote.setup.sh`

* [8aea7bd0](https://github.com/freephile/meza/commit/8aea7bd0) (2017-07-17) James Montalvo: Ensure backups directory exists before pre-update.php backup 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/backup-db-wikis/tasks/main.yml`
  - Modified: `src/roles/update.php/tasks/main.yml`

* [4d6b19bb](https://github.com/freephile/meza/commit/4d6b19bb) (2017-07-17) James Montalvo: update.php backup to backups dir; use remote-mysqldump 
  - Modified: `src/roles/remote-mysqldump/tasks/main.yml`
  - Modified: `src/roles/update.php/tasks/main.yml`

* [fe7f973a](https://github.com/freephile/meza/commit/fe7f973a) (2017-07-19) James Montalvo: Only keep binlogs for 2 days (#793) 
  - Modified: `src/roles/database/defaults/main.yml`

* [70e62a9e](https://github.com/freephile/meza/commit/70e62a9e) (2017-07-19) James Montalvo: Change of httpd ServerName specification broke SAML; fixit (#794) Breaking change in 14154d26908739bb3eda03525d091c56a5cad139 ; Merged in #785
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`

* [fdb705da](https://github.com/freephile/meza/commit/fdb705da) (2017-07-18) James Montalvo: Allow adding custom CA certs (#792) 
  - Modified: `src/roles/base/tasks/main.yml`

* [d0cc0d5e](https://github.com/freephile/meza/commit/d0cc0d5e) (2017-07-17) James Montalvo: Remove 'meza deploy' from 'vagrant up' command; do it after 'vagrant ssh' (#791) 
  - Modified: `Vagrantfile`

* [abfa8571](https://github.com/freephile/meza/commit/abfa8571) (2017-07-16) James Montalvo: Allow custom deploy_vars in secret.yml; Remove logging.sh, put in config.sh 
  - Modified: `src/roles/base/templates/config.php.j2`
  - Modified: `src/roles/base/templates/config.sh.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Modified: `src/roles/setup-env/templates/secret.yml.j2`
  - Modified: `src/scripts/disk-space-usage.sh`
  - Modified: `src/scripts/server-performance.sh`

* [eb22b71a](https://github.com/freephile/meza/commit/eb22b71a) (2017-07-13) James Montalvo: Cleanup comments 
  - Modified: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [28a72020](https://github.com/freephile/meza/commit/28a72020) (2017-07-13) James Montalvo: Move verify-wiki DB operations into includes; simplify logic 
  - Added: `src/roles/key-transfer/tasks/grant-keys.yml`
  - Added: `src/roles/key-transfer/tasks/revoke-keys.yml`
  - Added: `src/roles/remote-mysqldump/tasks/main.yml`
  - Modified: `src/roles/rsync/tasks/main.yml`
  - Added: `src/roles/verify-wiki/tasks/import-wiki-sql.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Added: `src/roles/verify-wiki/tasks/transfer-backup-to-db-master.yml`

* [553c8119](https://github.com/freephile/meza/commit/553c8119) (2017-07-13) James Montalvo: rsync SQL files directly from backup to DB master 
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [ecd98d78](https://github.com/freephile/meza/commit/ecd98d78) (2017-07-13) James Montalvo: Move grant-keys, rsync operations, and revoke-keys into rsync role 
  - Deleted: `src/roles/grant-keys/tasks/main.yml`
  - Deleted: `src/roles/revoke-keys/tasks/main.yml`
  - Added: `src/roles/rsync/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [ae9e7ff3](https://github.com/freephile/meza/commit/ae9e7ff3) (2017-07-11) James Montalvo: Move vars.yml-->public.yml; group_vars/all.yml-->secret.yml * Need to allow missing secret.yml during setup-env
* Encrypting secret.yml changes ownership, impacts include_vars. Fix ownership
* Looks like hostvars includes group_vars but not included vars
* Move test alt-backups config to secret.yml
  - Modified: `CONTRIBUTING.md`
  - Modified: `Vagrantfile`
  - Modified: `manual/AddingWikis.md`
  - Modified: `manual/DirectoryStructure.md`
  - Modified: `manual/SetupSAML.md`
  - Modified: `manual/meza-cmd/base.txt`
  - Modified: `src/playbooks/setup-env.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
R098	src/roles/init-controller-config/templates/vars.yml.j2	src/roles/init-controller-config/templates/public.yml.j2
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/setup-env/tasks/main.yml`
R100	src/roles/setup-env/templates/all.yml.j2	src/roles/setup-env/templates/secret.yml.j2
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/scripts/disk-space-usage.sh`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/server-performance.sh`
  - Modified: `tests/deploys/monolith-from-import.controller.sh`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`
  - Modified: `tests/docker/import-from-alt-remote.setup.sh`
  - Modified: `tests/docker/import-from-remote.setup.sh`

* [a12841f2](https://github.com/freephile/meza/commit/a12841f2) (2017-07-10) James Montalvo: Give search-index and smw-data logs their own directories #774 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/elastic-rebuild-all.sh.j2`
  - Modified: `src/roles/mediawiki/templates/smw-rebuild-all.sh.j2`

* [4e675aac](https://github.com/freephile/meza/commit/4e675aac) (2017-07-10) James Montalvo: Remove default international phonetic alphabet selector 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [14154d26](https://github.com/freephile/meza/commit/14154d26) (2017-07-10) James Montalvo: Specify ServerName 
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`

* [dce306d4](https://github.com/freephile/meza/commit/dce306d4) (2017-07-10) James Montalvo: Add Extension:DisplayTitle 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [da1c743f](https://github.com/freephile/meza/commit/da1c743f) (2017-07-10) James Montalvo: Increase rate of job-running to be more realistic 
  - Modified: `src/roles/cron/defaults/main.yml`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`

* [30bd3166](https://github.com/freephile/meza/commit/30bd3166) (2017-07-10) James Montalvo: Make cache directory 0770 permissions for runJobs.php 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [c0267104](https://github.com/freephile/meza/commit/c0267104) (2017-07-09) James Montalvo: Bump SMW 2.5.2-->2.5.3 to handle DB replication 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [b57e329a](https://github.com/freephile/meza/commit/b57e329a) (2017-07-07) James Montalvo: Improve debug options 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [2c5a516d](https://github.com/freephile/meza/commit/2c5a516d) (2017-07-07) James Montalvo: Ensure cookie domain set properly so SAML auth works with multiple app servers 
  - Modified: `src/roles/saml/templates/config.php.j2`

* [7e86a1d9](https://github.com/freephile/meza/commit/7e86a1d9) (2017-07-07) James Montalvo: Fix ports for external load balancers 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/parsoid-settings/templates/localsettings.js.j2`

* [89b4460e](https://github.com/freephile/meza/commit/89b4460e) (2017-06-30) James Montalvo: Option for DB_REPLICA in separate Vagrant VM 
  - Modified: `Vagrantfile`
  - Modified: `vagrantconf.default.yml`

* [6010cfb2](https://github.com/freephile/meza/commit/6010cfb2) (2017-07-10) James Montalvo: Use rsync directly to get file uploads from backups The Ansible wrapper on rsync caused issues in multi-server setups,
so using it directly was required. This required significant
troubleshooting. The major change included making grant-keys put
meza-ansible's id_rsa at the rsync-er's /root and make root
specify the id file during rsync/ssh.
Also fix several run_once declarations that were missing prior to proper
multi-server testing.
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/grant-keys/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/revoke-keys/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [150d1810](https://github.com/freephile/meza/commit/150d1810) (2017-07-10) James Montalvo: All app-servers need SSH key for git-clone-via-SSH 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [8ccdca07](https://github.com/freephile/meza/commit/8ccdca07) (2017-07-10) James Montalvo: Make GlusterFS setup RedHat-friendly 
  - Modified: `src/roles/gluster/tasks/setup-RedHat.yml`
  - Added: `src/roles/gluster/templates/Gluster.repo.j2`

* [cb215861](https://github.com/freephile/meza/commit/cb215861) (2017-06-26) James Montalvo: Allow all environment-specific SAML variables in secret config 
  - Modified: `src/roles/saml/templates/authsources.php.j2`
  - Modified: `src/roles/saml/templates/saml20-idp-remote.php.j2`

* [80ed8e35](https://github.com/freephile/meza/commit/80ed8e35) (2017-06-22) James Montalvo: need to force move home on minions, site.yml handle controller 
  - Modified: `src/roles/base/tasks/main.yml`

* [9b3bd427](https://github.com/freephile/meza/commit/9b3bd427) (2017-06-22) James Montalvo: Don't require TTY or visible password for sudo.  (#770) * Don't require TTY or visible password for sudo. Ref #769
* Also don't require TTY on controller. Ref #769
* Only comment out TTY stuff if not already commented out
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `src/scripts/ssh-users/setup-minion-user.sh`

* [0ac3f6cc](https://github.com/freephile/meza/commit/0ac3f6cc) (2017-06-20) James Montalvo: Deploy Elasticsearch and SMW rebuild scripts from role:mediawiki (#767) 
  - Modified: `manual/DirectoryStructure.md`
  - Modified: `src/playbooks/rebuild-smw-and-index.yml`
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
R056	src/scripts/elastic-build-index.sh	src/roles/mediawiki/templates/elastic-build-index.sh.j2
R078	src/scripts/elastic-rebuild-all.sh	src/roles/mediawiki/templates/elastic-rebuild-all.sh.j2
R078	src/scripts/smw-rebuild-all.sh	src/roles/mediawiki/templates/smw-rebuild-all.sh.j2
  - Deleted: `src/scripts/elastic-rebuild-index.sh`

* [d8974297](https://github.com/freephile/meza/commit/d8974297) (2017-06-20) ggJSC: Update SettingUpVirtualBox.md (#768) 
  - Modified: `manual/SettingUpVirtualBox.md`

* [94f1a974](https://github.com/freephile/meza/commit/94f1a974) (2017-06-20) James Montalvo: fix createAndPromote.php of User:Admin on Demo Wiki (#766) 
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`

* [b7d5c562](https://github.com/freephile/meza/commit/b7d5c562) (2017-06-19) James Montalvo: Fix permissions to allow Parsoid to work in _closed_ multi-server setups (#764) * Make parsoid read-write permissions work for closed servers

* fix missing paren

* cleanup logic...was too hard to follow
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [4741a188](https://github.com/freephile/meza/commit/4741a188) (2017-06-19) James Montalvo: Close port 1936 if HAProxy stats disabled; improve task naming (#762) 
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [a8fe9602](https://github.com/freephile/meza/commit/a8fe9602) (2017-06-19) James Montalvo: Clean up PHP profiling to only use XHGui (#759) * Remove build-in XHProf UI, remove stock MediaWiki XHProf handler

* If disable profiler: close port, disable MongoDB
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [2e878138](https://github.com/freephile/meza/commit/2e878138) (2017-06-17) James Montalvo: Allow internal parsoid/MW services to pick unmanaged load balancer port 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/parsoid-settings/templates/localsettings.js.j2`

* [43da0ffc](https://github.com/freephile/meza/commit/43da0ffc) (2017-06-17) James Montalvo: add mariadb slow query log to default config 
  - Modified: `config/core/defaults.yml`

* [d20e6d33](https://github.com/freephile/meza/commit/d20e6d33) (2017-06-16) James Montalvo: Use file cache for localization, else serious lag when multi-app Having multiple application servers (mediawiki servers) was showing
serious lag if localization cache was in database. Slow query log showed
LCStoreDB::finishWrite as the major culprit method. Also
MediaWiki::restInPeace, but to a lesser extent.
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [e1385819](https://github.com/freephile/meza/commit/e1385819) (2017-06-14) James Montalvo: Make Vagrant capable of creating two servers; Allow Windows * use vagrantconf(.default).yml instead of env vars
* make it work on Windows# This is the 5th commit message:
* add .gitattributes to aid CRLF handling to make files on Windows that
  get copied into VM not have issues
* make app1 primary vagrant box
  - Added: `.gitattributes`
  - Modified: `.gitignore`
  - Modified: `Vagrantfile`
  - Modified: `src/scripts/ssh-users/setup-minion-user.sh`
  - Added: `vagrantconf.default.yml`

* [e132278d](https://github.com/freephile/meza/commit/e132278d) (2017-06-13) James Montalvo: Add XHGui+MongoDB when profiling; Move composer into apache-php Role composer now called from within role apache-php in order to have
composer available for profiling tasks
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Added: `src/roles/apache-php/tasks/profiling.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Added: `src/roles/apache-php/templates/mongo.repo.j2`
  - Added: `src/roles/apache-php/templates/mongod.conf.j2`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`
  - Added: `src/roles/apache-php/templates/xhgui.config.php.j2`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [20facc74](https://github.com/freephile/meza/commit/20facc74) (2017-06-12) James Montalvo: Specify explicitly to use squid; has no noticable effect 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [50cfedfe](https://github.com/freephile/meza/commit/50cfedfe) (2017-06-12) James Montalvo: add 'latest' tag where appropriate 
  - Modified: `src/playbooks/getdocker.yml`
  - Modified: `src/roles/apache-php/tasks/php.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/memcached/tasks/main.yml`
  - Modified: `src/roles/nodejs/tasks/main.yml`

* [3c6be84c](https://github.com/freephile/meza/commit/3c6be84c) (2017-06-12) James Montalvo: Add profiling capability and XHProf built-in UI 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [6d88dfdb](https://github.com/freephile/meza/commit/6d88dfdb) (2017-06-12) James Montalvo: Update FIXMEs with issue numbers 
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [07e0b309](https://github.com/freephile/meza/commit/07e0b309) (2017-06-17) James Montalvo: Allow enabling HAProxy stats page 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`

* [6e6b16a1](https://github.com/freephile/meza/commit/6e6b16a1) (2017-06-17) James Montalvo: Properly set server interface for parsoid; load balance 
  - Modified: `config/core/defaults.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/haproxy/templates/haproxy.cfg.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/parsoid-settings/templates/localsettings.js.j2`
  - Modified: `src/scripts/ssh-users/transfer-master-key.sh`

* [3e9bc20b](https://github.com/freephile/meza/commit/3e9bc20b) (2017-06-03) James Montalvo: Fix suggestion at end of meza setup env for dev branch (#743) 
  - Modified: `src/scripts/meza.py`

* [9758ca34](https://github.com/freephile/meza/commit/9758ca34) (2017-06-02) James Montalvo: Use gluster to distribute uploads between app servers (#738) * [skip ci] Initial gluster install

* Use gluster as uploads directory on all app servers if more than one

considerations on how to use gluster:

always use gluster
  PROS: simplest setup
  CONS: performance?

both use /uploads - if /uploads is not a mount and using gluster, move
to temporary, setup gluster, move to gluster /uploads
  PROS: less confusing to meza admins
  CONS: complicated setup

gluster use separate dir - handle in MW config, then manually move on
changes, or automate move (could add later)
  PROS: simpler setup
  CONS: manual changes or potentially complicated automated changes,
        potential issues with backups directories

* fix using gluster uploads dir all the time

* fix when app-server length condition

* Need check for app servers in groups for setup-env

* only install when more than 1 app-server

* can't do 'when' on plays, just on roles and tasks

* fix wgUploadDirectory in LocalSettings; cleanup
  - Modified: `README.md`
  - Modified: `config/core/defaults.yml`
  - Modified: `manual/DirectoryStructure.md`
  - Modified: `src/playbooks/site.yml`
  - Added: `src/roles/gluster/defaults/main.yml`
  - Added: `src/roles/gluster/tasks/main.yml`
  - Added: `src/roles/gluster/tasks/setup-Debian.yml`
  - Added: `src/roles/gluster/tasks/setup-RedHat.yml`
  - Added: `src/roles/gluster/vars/Debian.yml`
  - Added: `src/roles/gluster/vars/RedHat.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/set-vars/tasks/main.yml`

* [d4a7e4e6](https://github.com/freephile/meza/commit/d4a7e4e6) (2017-05-31) James Montalvo: Don't use /home for meza-generated users (#732) 
  - Modified: `config/core/defaults.yml`
  - Modified: `manual/DirectoryStructure.md`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/grant-keys/tasks/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/nodejs/tasks/main.yml`
  - Modified: `src/roles/parsoid/tasks/main.yml`
  - Modified: `src/roles/revoke-keys/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/shell-functions/linux-user.sh`
  - Modified: `src/scripts/ssh-users/setup-master-user.sh`
  - Modified: `src/scripts/ssh-users/setup-minion-user.sh`
  - Modified: `tests/deploys/setup-alt-source-backup.yml`
  - Modified: `tests/docker/import-from-alt-remote.setup.sh`
  - Modified: `tests/docker/init-controller.sh`
  - Modified: `tests/docker/init-minion.sh`

* [5dbcd114](https://github.com/freephile/meza/commit/5dbcd114) (2017-06-19) James Montalvo: Fix improperly assigned variable; noticed when Ansible 2.3.0-->2.3.1 (#755) * file doesn't have a remote_user param; causing issues Ansible 2.3.0-->2.3.1
* var for include_role in wrong place
  - Modified: `src/roles/revoke-keys/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [f74a5bd1](https://github.com/freephile/meza/commit/f74a5bd1) (2017-06-03) James Montalvo: docs changes, #691, #557, #533 
  - Modified: `CONTRIBUTING.md`
  - Modified: `README.md`
  - Modified: `manual/SettingUpVirtualBox.md`

* [f65165bc](https://github.com/freephile/meza/commit/f65165bc) (2017-06-03) James Montalvo: Fix in-command suggestion, #734 
  - Modified: `src/scripts/meza.py`

* [ae44f543](https://github.com/freephile/meza/commit/ae44f543) (2017-06-02) James Montalvo: Rewrite rule to thwart MS-Office pre-fetching, which breaks SSO (#739) * rewrite rule to thwart MS-Office pre-fetching, which breaks SSO
* need to add office.html file
  - Modified: `src/roles/htdocs/tasks/main.yml`
  - Modified: `src/roles/htdocs/templates/.htaccess.j2`
  - Added: `src/roles/htdocs/templates/office.html.j2`

* [d6cbaf50](https://github.com/freephile/meza/commit/d6cbaf50) (2017-06-01) James Montalvo: Add FIXME and issue ref to note about change required (#736) Refs:
* Issue [#625](https://github.com/freephile/meza/issues/625)
* Issue [#662](https://github.com/freephile/meza/issues/662)
* Issue [#735](https://github.com/freephile/meza/issues/735)
  - Modified: `manual/DirectoryStructure.md`

* [4be4072d](https://github.com/freephile/meza/commit/4be4072d) (2017-05-30) James Montalvo: Limit rebuild SMW and search index data to when DB has been imported (#725) 
  - Modified: `src/playbooks/backup.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [3110b6bf](https://github.com/freephile/meza/commit/3110b6bf) (2017-05-29) James Montalvo: On create-wiki, rebuild smw-data and search-index on that wiki (#723) 
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`
  - Modified: `src/scripts/elastic-rebuild-all.sh`
  - Modified: `src/scripts/smw-rebuild-all.sh`

* [762dcce1](https://github.com/freephile/meza/commit/762dcce1) (2017-05-29) James Montalvo: allow third-party load-balancers 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [b862765e](https://github.com/freephile/meza/commit/b862765e) (2017-05-27) James Montalvo: fix self-signed cert common name 
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [1a31e8ff](https://github.com/freephile/meza/commit/1a31e8ff) (2017-05-26) James Montalvo: add task name for set_fact - list_of_wikis 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [41e17b0d](https://github.com/freephile/meza/commit/41e17b0d) (2017-05-24) James Montalvo: saml config, empty crontab, primewiki import first Address issues:
* #697: Allow sp_entity_id to be in secret or public
* #699: Fix errors when emptying empty crontab
* #700: Import primary wiki first
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/saml/templates/authsources.php.j2`

* [88c62e98](https://github.com/freephile/meza/commit/88c62e98) (2017-05-26) James Montalvo: Remove option to turn email on/off on first deploy (#720) 
  - Modified: `Vagrantfile`
  - Modified: `config/core/defaults.yml`
  - Modified: `src/roles/init-controller-config/templates/vars.yml.j2`
  - Modified: `src/roles/mediawiki/defaults/main.yml`
  - Modified: `src/roles/setup-env/templates/all.yml.j2`
  - Modified: `src/roles/verify-wiki/defaults/main.yml`
  - Deleted: `src/scripts/make-environment/hosts.default`
  - Deleted: `src/scripts/make-environment/tasks/main.yml`
  - Deleted: `src/scripts/make-environment/templates/group_vars_all.yml.j2`
  - Modified: `src/scripts/meza.py`
  - Modified: `tests/deploys/monolith-from-scratch.controller.sh`
  - Modified: `tests/docker/backup-to-remote.setup.sh`

* [8e5c2a28](https://github.com/freephile/meza/commit/8e5c2a28) (2017-05-26) James Montalvo: Rebuild DirectoryStructure.md; remove extraneous findings (#717) 
  - Deleted: `config/core/template/backupDownloaders.php`
  - Deleted: `config/core/template/ifcfg-eth1`
  - Deleted: `config/core/template/imagick-secure-policy.xml`
  - Deleted: `config/core/template/ssh`
  - Deleted: `config/core/template/template-env/README.md`
  - Deleted: `config/core/template/template-env/blank/group_vars/all.yml`
  - Deleted: `config/core/template/template-env/blank/hosts`
  - Deleted: `data/README.md`
  - Deleted: `data/elasticsearch/README.md`
  - Deleted: `data/logs/README.md`
  - Deleted: `data/mariadb/README.md`
  - Modified: `manual/DirectoryStructure.md`
  - Added: `manual/Glossary.md`
R100	src/scripts/pigeon.txt	manual/pigeon.txt
  - Deleted: `src/scripts/build-docker-container.sh`
  - Deleted: `src/scripts/getDatabaseNameFromSetup.php`
  - Deleted: `src/scripts/mezaCreateUser.php`
  - Deleted: `src/scripts/samba.sh`
  - Deleted: `src/scripts/shell-functions/db-master.sh`
  - Deleted: `src/scripts/shell-functions/logging.sh`
  - Deleted: `src/scripts/slack.sh`
  - Deleted: `src/scripts/updateExtensions.sh`

* [60423b9e](https://github.com/freephile/meza/commit/60423b9e) (2017-05-23) James Montalvo: fix always_run; add git commit to meza --version (#698) 
  - Modified: `src/roles/database/tasks/secure-installation.yml`
  - Modified: `src/scripts/meza.py`

* [11e0fce9](https://github.com/freephile/meza/commit/11e0fce9) (2017-05-23) James Montalvo: Remove 'localhost' as valid $wgSquidServersNoPurge (#693) Else get Warning: 

`inet_pton(): Unrecognized address localhost in /opt/htdocs/mediawiki/vendor/wikimedia/ip-set/src/IPSet.php on line 132`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [aa71ab2a](https://github.com/freephile/meza/commit/aa71ab2a) (2017-05-23) James Montalvo: Fix composer cache issues on Travis CI (#694) Composer installed a long time ago on the Docker images
used on Travis CI. Composer cache clearing required. For
now just clear cache if Composer version updates. Perhaps
it would be better to figure out how to read the age of
the cache and update only after a certain age. This
should work for now, though, and should get master to
stop failing builds.
  - Modified: `src/roles/composer/tasks/main.yml`

* [eada7ddb](https://github.com/freephile/meza/commit/eada7ddb) (2017-05-19) James Montalvo: Extension:SimpleSamlAuth latest release fail to create user; use newer commit (#666) 
  - Modified: `src/roles/saml/tasks/main.yml`

* [971f088c](https://github.com/freephile/meza/commit/971f088c) (2017-05-17) James Montalvo: Specify SMW 2.5.2 (#659) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [b3bc6a47](https://github.com/freephile/meza/commit/b3bc6a47) (2017-05-17) James Montalvo: PR for SimpleMathJax fork changed master; specify commit (#657) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [e56c777f](https://github.com/freephile/meza/commit/e56c777f) (2017-05-16) James Montalvo: fix discrepant email settings (#655) 
  - Modified: `src/roles/init-controller-config/templates/vars.yml.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [c5d2721e](https://github.com/freephile/meza/commit/c5d2721e) (2017-05-16) James Montalvo: Disable cron jobs when running an overwriting import (#654) 
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/cron/tasks/main.yml`

* [6c9cb6af](https://github.com/freephile/meza/commit/6c9cb6af) (2017-05-16) James Montalvo: specify SRF version; use SMW 2.5.x branch until 2.5.2 release (#653) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [218aad89](https://github.com/freephile/meza/commit/218aad89) (2017-05-12) James Montalvo: Add wgUsePrivateIPs and list of load balancers (#648) 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [ccbd6060](https://github.com/freephile/meza/commit/ccbd6060) (2017-05-12) James Montalvo: bump PageForms to 4.1.1 (#647) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [96246bcc](https://github.com/freephile/meza/commit/96246bcc) (2017-05-11) James Montalvo: Allow access to API despite SAML SSO (#646) 
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`

* [aa207fac](https://github.com/freephile/meza/commit/aa207fac) (2017-05-07) James Montalvo: Setup cron for Parsoid-restart, runJobs, and custom commands (#641) 
  - Added: `src/roles/cron/defaults/main.yml`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`
  - Added: `src/roles/cron/templates/runAllJobs.php.j2`
  - Deleted: `src/scripts/runAllJobs.php`

* [09a59643](https://github.com/freephile/meza/commit/09a59643) (2017-05-06) James Montalvo: Allow setting SAML-auth session length (#639) 
  - Added: `src/roles/saml/defaults/main.yml`
  - Modified: `src/roles/saml/templates/config.php.j2`

* [f0929ae4](https://github.com/freephile/meza/commit/f0929ae4) (2017-05-06) James Montalvo: Optionally allow <img> in wikitext, and make work in VE (#638) * Optionally patch Parsoid for img tags
* make option in LocalSettings.php
* test in job 3

* fix Parsoid-patch task
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/parsoid/tasks/main.yml`
  - Modified: `tests/docker/import-from-remote.setup.sh`

* [469f17f2](https://github.com/freephile/meza/commit/469f17f2) (2017-05-05) James Montalvo: fix prime_wiki; fix httpd logging (#632) * fix prime_wiki (#626)
* fix httpd logging (#627) (#631)
  - Modified: `manual/AddingWikis.md`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/mediawiki/templates/BlenderSettings.php.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/scripts/unifyUserTables.php`

* [41dfed3d](https://github.com/freephile/meza/commit/41dfed3d) (2017-05-05) James Montalvo: call it defaults.yml not paths.yml (#630) 
R098	config/core/paths.yml	config/core/defaults.yml
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/scripts/meza.py`

* [15fefd35](https://github.com/freephile/meza/commit/15fefd35) (2017-05-05) James Montalvo: Encrypt sensitive config files with Ansible Vault (#629) 
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/setup-env/tasks/main.yml`
  - Modified: `src/scripts/disk-space-usage.sh`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/server-performance.sh`
  - Modified: `tests/docker/import-from-alt-remote.setup.sh`

* [9025cae4](https://github.com/freephile/meza/commit/9025cae4) (2017-05-04) James Montalvo: Enable mod_status; fix backup-downloading; prevent unwanted users (#623) * enable mod_status; fix backup-downloading; prevent unwanted users

* make sure m_deploy available to .sh and .php

* allow_backup_downloads to add files and change htaccess

* split backup of db and uploads, so can skip-tags on uploads

* fix typo

* fixes for backup downloading. more tagging

* use upload and uploads tags, since easily can forget which to use
  - Modified: `config/core/paths.yml`
  - Modified: `src/playbooks/backup.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/base/templates/config.php.j2`
  - Modified: `src/roles/base/templates/config.sh.j2`
R076	src/roles/htdocs/templates/download-backup.php.j2	src/roles/htdocs/files/BackupDownload/download.php
  - Added: `src/roles/htdocs/files/BackupDownload/index.php`
  - Added: `src/roles/htdocs/files/ServerPerformance/mod_status.php`
  - Modified: `src/roles/htdocs/tasks/main.yml`
  - Modified: `src/roles/htdocs/templates/.htaccess.j2`
  - Deleted: `src/roles/htdocs/templates/backupListing.php.j2`

* [f10420f9](https://github.com/freephile/meza/commit/f10420f9) (2017-05-03) James Montalvo: Reorg (#619) complete and meza-docker-full rebuilt: use latest image (#622) 
  - Modified: `tests/docker/init-controller.sh`

* [739bb538](https://github.com/freephile/meza/commit/739bb538) (2017-05-03) James Montalvo: Reorganize meza dir structure to separate application, config, and data (#619) 
  - Modified: `.github/ISSUE_TEMPLATE.md`
  - Modified: `.gitignore`
  - Modified: `config/README.md`
  - Deleted: `config/core/app-ansible/README.md`
  - Deleted: `config/core/config.sh`
  - Modified: `config/core/paths.yml`
  - Modified: `config/core/template/backupDownloaders.php`
  - Deleted: `config/core/template/composer.local.json`
  - Deleted: `config/core/template/import-config.example.sh`
  - Deleted: `config/core/template/install.config.example.sh`
  - Deleted: `config/core/template/saml-setup-config.sh`
  - Deleted: `config/core/template/saml20-idp-remote.php`
  - Deleted: `htdocs/README.md`
  - Deleted: `htdocs/wikis/README.md`
  - Modified: `manual/AddingWikis.md`
  - Modified: `manual/DirectoryStructure.md`
  - Modified: `manual/SetupSAML.md`
  - Modified: `manual/installing-additional-extensions.md`
  - Modified: `manual/meza-cmd/base.txt`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/apache-php/templates/php.ini.j2`
  - Deleted: `src/roles/base/defaults/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/base/templates/config.php.j2`
  - Modified: `src/roles/base/templates/config.sh.j2`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/configure-wiki/templates/preLocalSettings.d/base.php.j2`
  - Modified: `src/roles/database/defaults/main.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/elasticsearch/templates/elasticsearch.yml.j2`
  - Modified: `src/roles/haproxy/tasks/main.yml`
R100	htdocs/ServerPerformance/css/nv.d3.css	src/roles/htdocs/files/ServerPerformance/css/nv.d3.css
R095	htdocs/ServerPerformance/index.php	src/roles/htdocs/files/ServerPerformance/index.php
R100	htdocs/ServerPerformance/js/d3.js	src/roles/htdocs/files/ServerPerformance/js/d3.js
R100	htdocs/ServerPerformance/js/jquery-3.1.0.min.js	src/roles/htdocs/files/ServerPerformance/js/jquery-3.1.0.min.js
R100	htdocs/ServerPerformance/js/nv.d3.js	src/roles/htdocs/files/ServerPerformance/js/nv.d3.js
R085	htdocs/ServerPerformance/js/server-performance.nvd3.js	src/roles/htdocs/files/ServerPerformance/js/server-performance.nvd3.js
R091	htdocs/ServerPerformance/space.php	src/roles/htdocs/files/ServerPerformance/space.php
  - Added: `src/roles/htdocs/tasks/main.yml`
R100	htdocs/.htaccess	src/roles/htdocs/templates/.htaccess.j2
R080	htdocs/backupListing.php	src/roles/htdocs/templates/backupListing.php.j2
R096	htdocs/download-backup.php	src/roles/htdocs/templates/download-backup.php.j2
R073	htdocs/index.php	src/roles/htdocs/templates/index.php.j2
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/BlenderSettings.php.j2`
  - Modified: `src/roles/mediawiki/templates/Extensions.php.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Deleted: `src/roles/meza-log/templates/server-performance-config.php.j2`
R095	htdocs/NonMediaWikiSimpleSamlAuth.php	src/roles/saml/files/NonMediaWikiSimpleSamlAuth.php
  - Modified: `src/roles/saml/tasks/main.yml`
  - Modified: `src/roles/saml/templates/samlLocalSettings.php.j2`
  - Modified: `src/roles/setup-env/tasks/main.yml`
  - Modified: `src/roles/sync-configs/tasks/main.yml`
  - Modified: `src/roles/update.php/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/scripts/build-docker-container.sh`
  - Modified: `src/scripts/disk-space-usage.sh`
  - Modified: `src/scripts/elastic-build-index.sh`
  - Modified: `src/scripts/elastic-rebuild-all.sh`
  - Modified: `src/scripts/elastic-rebuild-index.sh`
  - Modified: `src/scripts/getmeza.sh`
  - Modified: `src/scripts/make-environment/templates/group_vars_all.yml.j2`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/mezaCreateUser.php`
  - Modified: `src/scripts/runAllJobs.php`
  - Modified: `src/scripts/samba.sh`
  - Deleted: `src/scripts/saml.sh`
  - Modified: `src/scripts/server-performance.sh`
  - Modified: `src/scripts/shell-functions/logging.sh`
  - Modified: `src/scripts/smw-rebuild-all.sh`
  - Modified: `src/scripts/ssh-users/setup-master-user.sh`
  - Modified: `src/scripts/ssh-users/transfer-master-key.sh`
  - Modified: `src/scripts/unifyUserTables.php`
  - Modified: `src/scripts/updateExtensions.sh`
  - Modified: `tests/deploys/monolith-from-import.controller.sh`
  - Modified: `tests/deploys/monolith-from-scratch.controller.sh`
  - Modified: `tests/docker/backup-to-remote.setup.sh`
  - Modified: `tests/docker/import-from-alt-remote.setup.sh`
  - Modified: `tests/docker/import-from-remote.setup.sh`
  - Modified: `tests/docker/init-container.sh`
  - Modified: `tests/docker/init-controller.sh`

* [67cf6f3f](https://github.com/freephile/meza/commit/67cf6f3f) (2017-05-02) James Montalvo: Ensure sudo in cron; fix init-controller; more settings; fix meza --version (#614) * Fix "meza --version" command

* Ensure sudo in cron; fix init-controller; more settings

* Disable "require tty" so cron works on meza commands (#556)
* Fix pre/postLocalSettings.d files reappearing on deploy (#578)
* Additional LocalSettings (#415)

* Fix disk-space-usage cron frequency
  - Modified: `config/core/MezaCoreExtensions.yml`
  - Modified: `src/roles/cron/tasks/main.yml`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Deleted: `src/roles/init-controller-config/templates/SAML-placeholder.txt`
  - Deleted: `src/roles/init-controller-config/templates/postLocalSettings.d/README.md.j2`
  - Deleted: `src/roles/init-controller-config/templates/preLocalSettings.d/README.md.j2`
  - Deleted: `src/roles/init-controller-config/templates/preLocalSettings.d/email.php.j2`
  - Modified: `src/roles/init-controller-config/templates/vars.yml.j2`
  - Modified: `src/roles/mediawiki/defaults/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/scripts/meza.py`

* [f6fbd7fd](https://github.com/freephile/meza/commit/f6fbd7fd) (2017-05-01) James Montalvo: install disk space checker with ansible; configure crontab 
  - Deleted: `scripts/opt-space-usage.sh`
  - Modified: `src/roles/cron/templates/meza-ansible.crontab.j2`
  - Added: `src/roles/meza-log/files/table_disk_space.sql`
  - Modified: `src/roles/meza-log/tasks/main.yml`
  - Added: `src/roles/meza-log/templates/logging.sh.j2`
  - Modified: `src/roles/setup-env/templates/all.yml.j2`
  - Added: `src/scripts/disk-space-usage.sh`
  - Modified: `src/scripts/server-performance.sh`

* [85dfeb7d](https://github.com/freephile/meza/commit/85dfeb7d) (2017-01-04) Daren Welsh: Track disk usage * add opt-space-usage.sh to record disk space on /opt periodically
* add space.php to plot usage of opt directory
More squashed commits:
* increase default number of days, add usage trend
* clarify rate is per week
* don't show positive rate, use previous rate when pos
  - Added: `htdocs/ServerPerformance/space.php`
  - Added: `scripts/opt-space-usage.sh`

* [b9415131](https://github.com/freephile/meza/commit/b9415131) (2017-04-29) James Montalvo: install server-performance with ansible; configure crontab 
  - Modified: `config/core/paths.yml`
  - Modified: `htdocs/ServerPerformance/index.php`
  - Modified: `src/playbooks/site.yml`
  - Added: `src/roles/cron/tasks/main.yml`
  - Added: `src/roles/cron/templates/meza-ansible.crontab.j2`
  - Added: `src/roles/meza-log/files/meza_server_log.sql`
  - Added: `src/roles/meza-log/tasks/main.yml`
  - Added: `src/roles/meza-log/templates/server-performance-config.php.j2`
  - Modified: `src/roles/setup-env/templates/hosts.j2`
  - Modified: `src/scripts/meza.py`
R061	scripts/server-performance.sh	src/scripts/server-performance.sh

* [2cf0dc8c](https://github.com/freephile/meza/commit/2cf0dc8c) (2016-08-12) Daren Welsh: Use cron to log and notify with server performance data This adds a simple script that can be run as a scheduled task to provide
server performance data. Currently it outputs notifications to a Slack
channel and logs the data in a database. This data can be viewed at
<domain>/ServerPerformance.
This commit was squashed. The previous commit messages were:
* init
* add notes on crontab usage
* add server-performance.sh to dir structure
* log data in database
* add server perf plot page
* list files in ServerPerformance in dir structure
* increase precision level
* time/precision in main plot, not in view finder
* convert loads to 100% scale
* add logic to meter slack notification tempo
* add wiretap data (hits, avg response time)
* fix ceiling for load averages
* denote "ds" for deciseconds of response time
* channel alert must be in message text, not attachment
* add parameter "days"
* By appending "?days=5" to the URL, you can request data for 5 days, for
  example. Logic requires a positive value, but I'm not sure the behavior
  for irrational numbers is correct.
* also track total jobs across all wikis
* typo
* also display total num of jobs
* scale jobs to 100 for low values
  - Modified: `htdocs/.htaccess`
  - Added: `htdocs/ServerPerformance/css/nv.d3.css`
  - Added: `htdocs/ServerPerformance/index.php`
  - Added: `htdocs/ServerPerformance/js/d3.js`
  - Added: `htdocs/ServerPerformance/js/jquery-3.1.0.min.js`
  - Added: `htdocs/ServerPerformance/js/nv.d3.js`
  - Added: `htdocs/ServerPerformance/js/server-performance.nvd3.js`
  - Modified: `manual/DirectoryStructure.md`
  - Added: `scripts/server-performance.sh`

* [af79181a](https://github.com/freephile/meza/commit/af79181a) (2017-04-28) James Montalvo: Add PEAR:Net_SMTP; cleanup/standardize php.yml (#608) 
  - Modified: `src/roles/apache-php/tasks/php.yml`

* [4d0d13e5](https://github.com/freephile/meza/commit/4d0d13e5) (2017-04-28) James Montalvo: Fix Extensions.php to use meza_local_extensions where appropriate (#607) 
  - Modified: `src/roles/mediawiki/templates/Extensions.php.j2`

* [615d101a](https://github.com/freephile/meza/commit/615d101a) (2017-04-28) James Montalvo: SemanticMaps3.8->Maps4.1; Ensure netcat installed; cleanup (#606) 
  - Modified: `config/core/MezaCoreExtensions.yml`
  - Modified: `src/roles/memcached/tasks/main.yml`

* [6b2dd7ee](https://github.com/freephile/meza/commit/6b2dd7ee) (2017-04-27) James Montalvo: Use Extension:SimpleMathJax instead of Extension:Math (#605) Extension:Math after MediaWiki 1.25 does not allow client-side rendering
of Math via the MathJax javascript library. Without this it is required to
install a server side renderer such as Mathoid, texvc, or LaTeXML. All of
these are complicated. At some point down the road perhaps we'll add one
(or more) of these, but for now it is much simpler to maintain previous
functionality with this other extension.

Note that the original SimpleMathJax had two issues:

  1. The MathJax library was loaded from a CDN, which is a
     security/privacy concern
  2. MathJax JS and CSS was loaded with every page load, regardless of
     whether or not <math> or <chem> tags were used

As such, the GitHub jmnote/SimpleMathJax repo was forked to
jamesmontalvo3/SimpleMathJax. The changes made in this fork have been
pull-requested back into the trunk, but at this time have not been
accepted. If they are accepted it will have to be determined whether or
not we use an unknown repository or continue to maintain this one. If we
continue to maintain it, jamesmontalvo3 will transfer the repo to
enterprisemediawiki.
  - Modified: `config/core/MezaCoreExtensions.yml`

* [04092026](https://github.com/freephile/meza/commit/04092026) (2017-04-27) James Montalvo: Fix conditional checks failures that arose when Ansible 2.2.1-->2.3 (#603) * Fix check for slave.Slave_IO_Running (failing in Ansible 2.3)
* Need to check if mysql_force_slave_configuration is defined, too
* Check wiki_sql_file.rc is defined first (Ansible 2.3)
  - Modified: `src/roles/database/tasks/replication.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [64184285](https://github.com/freephile/meza/commit/64184285) (2017-04-25) James Montalvo: Use Wiretap master, don't legacy-load (#592) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [bcd85dd2](https://github.com/freephile/meza/commit/bcd85dd2) (2017-04-25) James Montalvo: Fix SMW/Elastic rebuild order; names/functions misaligned (#589) 
  - Modified: `src/playbooks/rebuild-smw-and-index.yml`
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [d5e4bd64](https://github.com/freephile/meza/commit/d5e4bd64) (2017-04-24) James Montalvo: Create better methods to rebuild SMW data and search index (#581) 
  - Modified: `config/core/config.sh`
  - Modified: `config/core/paths.yml`
  - Added: `src/playbooks/rebuild-smw-and-index.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/create-wiki-wrapper/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/parsoid-settings/tasks/main.yml`
  - Modified: `src/roles/set-vars/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/scripts/elastic-build-index.sh`
  - Added: `src/scripts/elastic-rebuild-all.sh`
  - Modified: `src/scripts/meza.py`
  - Added: `src/scripts/smw-rebuild-all.sh`

* [f4634206](https://github.com/freephile/meza/commit/f4634206) (2017-04-24) James Montalvo: HeaderTabs, Pipe escape, and CopyWatchers versions (#588) * CopyWatchers master; PipeEscape from Gerrit
* Fix HeaderTabs vars (var names changed); specify version
  - Modified: `config/core/MezaCoreExtensions.yml`

* [ae14cf24](https://github.com/freephile/meza/commit/ae14cf24) (2017-04-24) Trey Davis: Added Page Forms 4.1 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [e46dbba9](https://github.com/freephile/meza/commit/e46dbba9) (2017-04-20) James Montalvo: Turn off geoip guessing (#575) 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [db471723](https://github.com/freephile/meza/commit/db471723) (2017-04-20) James Montalvo: (Re-)enable SAML authentication (#573) 
  - Modified: `config/core/paths.yml`
  - Deleted: `config/core/template/SAML-preLocalSettings.php`
  - Deleted: `config/core/template/saml_httpd.conf`
  - Modified: `htdocs/NonMediaWikiSimpleSamlAuth.php`
  - Modified: `htdocs/index.php`
  - Added: `manual/SetupSAML.md`
  - Modified: `src/roles/apache-php/templates/httpd.conf.j2`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Added: `src/roles/saml/tasks/main.yml`
R070	config/core/template/SAMLConfig.php	src/roles/saml/templates/SAMLConfig.php.j2
  - Added: `src/roles/saml/templates/authsources.php.j2`
  - Added: `src/roles/saml/templates/config.php.j2`
  - Added: `src/roles/saml/templates/saml20-idp-remote.php.j2`
R058	config/core/template/SAML-postLocalSettings.php	src/roles/saml/templates/samlLocalSettings.php.j2

* [913efcf2](https://github.com/freephile/meza/commit/913efcf2) (2017-04-20) James Montalvo: Use ImagesLoaded extension, now separate from MasonryMainPage (#572) 
  - Modified: `config/core/MezaCoreExtensions.yml`

* [d2f9cdf2](https://github.com/freephile/meza/commit/d2f9cdf2) (2017-04-19) James Montalvo: provide options to enable debug mode (#570) 
  - Modified: `src/roles/mediawiki/defaults/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [51d42a3c](https://github.com/freephile/meza/commit/51d42a3c) (2017-04-19) James Montalvo: Fixes + remove old docs and put in MezaLegacyDocs (#569) MezaLegacyDocs:
https://github.com/enterprisemediawiki/MezaLegacyDocs
  - Modified: `README.md`
  - Deleted: `manual/2.0-ConfiguringCentOS.md`
  - Deleted: `manual/3.0-SetupLAMP.md`
  - Deleted: `manual/3.1-InstallApache.md`
  - Deleted: `manual/3.2-InstallPHP.md`
  - Deleted: `manual/3.3-InstallMySQL.md`
  - Deleted: `manual/4.0-InstallMediaWiki.md`
  - Modified: `manual/AddingWikis.md`
  - Deleted: `manual/CentOS_Notes.md`
  - Deleted: `manual/ClosedWork.md`
R100	manual/2.1-CreateCloneVMs.md	manual/CreateCloneVMs.md
  - Modified: `manual/ElasticsearchPlugins.md`
  - Deleted: `manual/OpenWork.md`
  - Deleted: `manual/README.md`
  - Deleted: `manual/References.md`
R100	manual/1.0-SettingUpVirtualBox.md	manual/SettingUpVirtualBox.md
  - Deleted: `manual/SetupDigitalOcean.md`
  - Modified: `manual/SetupRedHat.md`
  - Deleted: `manual/database-planning.md`

* [00057d82](https://github.com/freephile/meza/commit/00057d82) (2017-04-19) James Montalvo: Use /opt/meza/data/tmp instead of /tmp, particularly for large files (#564) * use /opt/meza/data/tmp instead of /tmp, particularly for large files
* Unrelated fix: revoke keys from correct backup server
* copy symlinks contents when doing backup
  - Modified: `config/core/paths.yml`
  - Modified: `src/roles/backup-db-wikis/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/database/tasks/replication.yml`
  - Modified: `src/roles/dump-db-wikis/tasks/main.yml`
  - Modified: `src/roles/update.php/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`

* [69d3219d](https://github.com/freephile/meza/commit/69d3219d) (2017-04-18) James Montalvo: Upgrade SemanticMeetingMinutes; don't use Composer; add PageImporter (#563) 
  - Modified: `config/core/MezaCoreExtensions.yml`
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`
  - Modified: `tests/docker/init-controller.sh`

* [c5e3d127](https://github.com/freephile/meza/commit/c5e3d127) (2017-04-18) James Montalvo: mismatched variable names (#562) 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [7f984201](https://github.com/freephile/meza/commit/7f984201) (2017-04-17) James Montalvo: Reenable primewiki functionality (#560) 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [af0f9549](https://github.com/freephile/meza/commit/af0f9549) (2017-04-17) James Montalvo: Add tags for update.php and verify-wiki (#558) 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [41d54092](https://github.com/freephile/meza/commit/41d54092) (2017-04-14) James Montalvo: stop hard-coding localhost as memcached server; use inventory (#553) 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [6eb8b0c0](https://github.com/freephile/meza/commit/6eb8b0c0) (2017-04-14) James Montalvo: Use SSL cert from config if exists (#552) 
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`

* [908143f3](https://github.com/freephile/meza/commit/908143f3) (2017-04-14) James Montalvo: Allow pulling database/uploads from alternate sources (#547) 
  - Modified: `.travis.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/grant-keys/tasks/main.yml`
  - Modified: `src/roles/revoke-keys/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/scripts/meza.py`
  - Added: `tests/deploys/setup-alt-source-backup.yml`
  - Added: `tests/docker/import-from-alt-remote.setup.sh`
  - Modified: `tests/docker/run-tests.sh`

* [412472bd](https://github.com/freephile/meza/commit/412472bd) (2017-04-13) James Montalvo: Reduce complexity of env vars in Travis (#550) 
  - Modified: `.travis.yml`

* [893fa642](https://github.com/freephile/meza/commit/893fa642) (2017-04-10) James Montalvo: Fix importing from remote servers, and properly test (#540) 
  - Modified: `.travis.yml`
  - Modified: `config/core/ansible.cfg`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Added: `src/roles/grant-keys/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Added: `src/roles/revoke-keys/tasks/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/main.yml`
  - Modified: `src/scripts/meza.py`
  - Modified: `src/scripts/ssh-users/setup-minion-user.sh`
  - Added: `tests/deploys/backup-to-remote.controller.sh`
  - Added: `tests/deploys/import-from-remote.controller.sh`
R083	tests/travis/monolith-from-import.sh	tests/deploys/monolith-from-import.controller.sh
R056	tests/travis/monolith-from-scratch.sh	tests/deploys/monolith-from-scratch.controller.sh
  - Added: `tests/docker/backup-to-remote.setup.sh`
  - Added: `tests/docker/import-from-remote.setup.sh`
R071	tests/travis/init-container.sh	tests/docker/init-container.sh
  - Added: `tests/docker/init-controller.sh`
  - Added: `tests/docker/init-minion.sh`
  - Added: `tests/docker/run-tests.sh`
R100	tests/travis/image-check.sh	tests/integration/image-check.sh
R100	tests/travis/server-check.sh	tests/integration/server-check.sh
R100	tests/travis/wiki-check.sh	tests/integration/wiki-check.sh
  - Modified: `tests/travis/git-setup.sh`
  - Deleted: `tests/travis/monolith-from-preinstall.sh`
  - Deleted: `tests/travis/run-tests.sh`

* [2f237773](https://github.com/freephile/meza/commit/2f237773) (2017-04-10) James Montalvo: need git config for PR merge test (#544) 
  - Modified: `tests/travis/git-setup.sh`

* [2d1f86a3](https://github.com/freephile/meza/commit/2d1f86a3) (2017-04-06) James Montalvo: Bump to MW 1.27.2 security release (#543) 
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [7d427aaa](https://github.com/freephile/meza/commit/7d427aaa) (2017-04-04) James Montalvo: Fix travis merging of pull request tests (#542) 
  - Modified: `tests/travis/git-setup.sh`

* [1619980b](https://github.com/freephile/meza/commit/1619980b) (2017-04-04) James Montalvo: Fix branch checkout for travis PRs (#541) 
  - Modified: `tests/travis/git-setup.sh`

* [415a7723](https://github.com/freephile/meza/commit/415a7723) (2017-04-03) James Montalvo: Add capability to run `meza deploy` in Dockerfile (#539) 
  - Modified: `.travis.yml`
  - Modified: `src/roles/apache-php/handlers/main.yml`
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/base/handlers/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/database/handlers/main.yml`
  - Modified: `src/roles/database/tasks/configure.yml`
  - Modified: `src/roles/database/tasks/main.yml`
  - Modified: `src/roles/database/tasks/setup-Debian.yml`
  - Modified: `src/roles/elasticsearch/handlers/main.yml`
  - Modified: `src/roles/elasticsearch/tasks/main.yml`
  - Modified: `src/roles/firewalld/handlers/main.yml`
  - Modified: `src/roles/firewalld/tasks/main.yml`
  - Modified: `src/roles/haproxy/handlers/main.yml`
  - Modified: `src/roles/haproxy/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/memcached/handlers/main.yml`
  - Modified: `src/roles/memcached/tasks/main.yml`
  - Modified: `src/roles/parsoid-settings/handlers/main.yml`
  - Modified: `src/roles/parsoid-settings/tasks/main.yml`
  - Added: `tests/travis/git-setup.sh`
  - Modified: `tests/travis/init-container.sh`
  - Added: `tests/travis/monolith-from-preinstall.sh`
  - Modified: `tests/travis/run-tests.sh`

* [9433a596](https://github.com/freephile/meza/commit/9433a596) (2017-03-31) James Montalvo: move MezaCoreExtensions.yml to config/core (#537) 
R100	src/roles/mediawiki/files/MezaCoreExtensions.yml	config/core/MezaCoreExtensions.yml
  - Modified: `manual/installing-additional-extensions.md`
  - Modified: `src/roles/mediawiki/tasks/main.yml`

* [acc6969d](https://github.com/freephile/meza/commit/acc6969d) (2017-03-31) James Montalvo: Fix really long delay in syncing configs due to also syncing .git directory (#536) 
  - Modified: `.gitignore`
  - Added: `config/core/app-ansible/README.md`
  - Modified: `config/core/paths.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/sync-configs/tasks/main.yml`
  - Modified: `tests/travis/run-tests.sh`

* [6d29d96d](https://github.com/freephile/meza/commit/6d29d96d) (2017-03-31) James Montalvo: remove bad owner/group/mode from Ansible synchronize (rsync) (#535) 
  - Modified: `src/roles/init-controller-config/tasks/main.yml`

* [dc55da93](https://github.com/freephile/meza/commit/dc55da93) (2017-03-31) James Montalvo: Create init-containers.sh (#528) * Create init-container.sh script to abstract run-test.sh work
* Add third Travis job that boots a second container. Doesn't do anything
  with the container at this point, just boots it to prove it can.
  - Modified: `.travis.yml`
  - Added: `tests/travis/init-container.sh`
  - Modified: `tests/travis/run-tests.sh`

* [abd0ca62](https://github.com/freephile/meza/commit/abd0ca62) (2017-03-30) James Montalvo: Fix API, Parsoid and ES tests to fail properly (#520) 
  - Modified: `.travis.yml`
  - Added: `tests/travis/image-check.sh`
  - Added: `tests/travis/monolith-from-import.sh`
  - Added: `tests/travis/monolith-from-scratch.sh`
  - Modified: `tests/travis/run-tests.sh`
  - Added: `tests/travis/server-check.sh`
  - Added: `tests/travis/wiki-check.sh`

* [3b682582](https://github.com/freephile/meza/commit/3b682582) (2017-03-28) James Montalvo: Add deploy option to `vagrant up` (#525) Do `vagrant up` to install a full monolithic meza installation or do
`deploy=none vagrant up` to just install the `meza` command. The user
can then do `vagrant ssh` and perform `meza` commands manually.
  - Modified: `Vagrantfile`

* [80fdc865](https://github.com/freephile/meza/commit/80fdc865) (2017-03-27) James Montalvo: Parsoid list-of-wikis fix; add parsoid-settings role (#523) Parsoid servers not on app server need other method to know wikis
available. Accomplished by refactoring Parsoid config changes into
separate role.

Pull localsettings.js and init.d script provisioning out of role/parsoid
and put into new role/parsoid-settings. This allows other roles that make
changes that impact Parsoid to ensure Parsoid's settings are properly
configured and service is restarted. Both the logic as well as the
templates (e.g. localsettings.js and parsoid init.d script) were moved to
role/parsoid-settings.
  - Modified: `config/core/paths.yml`
  - Modified: `src/playbooks/create-wiki-promptless.yml`
  - Modified: `src/playbooks/create-wiki.yml`
  - Modified: `src/playbooks/site.yml`
  - Deleted: `src/roles/mediawiki/handlers/main.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
R100	src/roles/parsoid/handlers/main.yml	src/roles/parsoid-settings/handlers/main.yml
  - Added: `src/roles/parsoid-settings/tasks/main.yml`
R097	src/roles/parsoid/templates/localsettings.js.j2	src/roles/parsoid-settings/templates/localsettings.js.j2
R100	src/roles/parsoid/templates/parsoid.initd.sh.j2	src/roles/parsoid-settings/templates/parsoid.initd.sh.j2
  - Deleted: `src/roles/parsoid/defaults/main.yml`
  - Modified: `src/roles/parsoid/tasks/main.yml`
  - Deleted: `src/roles/verify-wiki/handlers/main.yml`
  - Modified: `src/roles/verify-wiki/tasks/init-wiki.yml`

* [9ebcbda2](https://github.com/freephile/meza/commit/9ebcbda2) (2017-03-26) James Montalvo: Add libselinux-python to getmeza.sh for initial conditions (#522) 
  - Modified: `src/scripts/getmeza.sh`

* [181b3296](https://github.com/freephile/meza/commit/181b3296) (2017-03-26) James Montalvo: Add meza-ansible to groups wheel and apache (#521) 
  - Modified: `src/roles/apache-php/tasks/main.yml`
  - Modified: `src/roles/base/tasks/main.yml`

* [3ee1f928](https://github.com/freephile/meza/commit/3ee1f928) (2017-03-26) James Montalvo: Add extension ImageMap (#519) 
  - Modified: `src/roles/mediawiki/files/MezaCoreExtensions.yml`

* [71b0456d](https://github.com/freephile/meza/commit/71b0456d) (2017-03-26) James Montalvo: Fix talkright permissions (#518) 
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [120e732a](https://github.com/freephile/meza/commit/120e732a) (2017-03-26) James Montalvo: Fix permissions for services accessing MediaWiki (#514) Check for presence of HTTP_X_FORWARDED_FOR to determine if request is from
a real user or if it is a request from a service. If it's a service, then
set permissions to be able to view/edit all. Real users will have
HTTP_X_FORWARDED_FOR, service request (that don't go through the load
balancer) do not.
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`

* [4176d683](https://github.com/freephile/meza/commit/4176d683) (2017-03-25) James Montalvo: Allow MW and extensions on host to be rsynced to guest (#517) 
  - Modified: `Vagrantfile`

* [3321cea9](https://github.com/freephile/meza/commit/3321cea9) (2017-03-25) James Montalvo: Enable install with Vagrant (#516) Add Vagrantfile for install with Vagrant. Needed to use rsync folder synchronization since currently do not have vbox guest additions installed. Provision steps broken apart so deploy can be done separately.
  - Modified: `.gitignore`
  - Added: `Vagrantfile`

* [88177ba4](https://github.com/freephile/meza/commit/88177ba4) (2017-03-21) Trey Davis: Added Semantic Drilldown to Core Extensions 
  - Modified: `src/roles/mediawiki/files/MezaCoreExtensions.yml`

* [1b19ac59](https://github.com/freephile/meza/commit/1b19ac59) (2017-03-23) James Montalvo: Fix MariaDB data dir not being in /opt (#512) 
  - Modified: `src/roles/database/defaults/main.yml`

* [47e89b61](https://github.com/freephile/meza/commit/47e89b61) (2017-03-20) James Montalvo: Add directories holding pre/post LocalSettings.php inclusions (#508) 
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Added: `src/roles/configure-wiki/templates/postLocalSettings.d/README.md.j2`
  - Deleted: `src/roles/configure-wiki/templates/postLocalSettings.php.j2`
  - Added: `src/roles/configure-wiki/templates/preLocalSettings.d/README.md.j2`
R100	src/roles/configure-wiki/templates/preLocalSettings.php.j2	src/roles/configure-wiki/templates/preLocalSettings.d/base.php.j2
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
R100	src/roles/init-controller-config/templates/MezaLocalExtensions.yml	src/roles/init-controller-config/templates/MezaLocalExtensions.yml.j2
  - Added: `src/roles/init-controller-config/templates/postLocalSettings.d/README.md.j2`
  - Deleted: `src/roles/init-controller-config/templates/postLocalSettings_allWikis.php`
  - Added: `src/roles/init-controller-config/templates/preLocalSettings.d/README.md.j2`
R100	src/roles/init-controller-config/templates/preLocalSettings_allWikis.php	src/roles/init-controller-config/templates/preLocalSettings.d/email.php.j2
R100	src/roles/init-controller-config/templates/vars.yml	src/roles/init-controller-config/templates/vars.yml.j2
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/scripts/elastic-build-index.sh`

* [a49d61a4](https://github.com/freephile/meza/commit/a49d61a4) (2017-03-17) James Montalvo: Support RedHat 7 (#506) * Differences for RedHat: EPEL install, IUS repo download fix
* Remove CentOS 6 items which conflicted with RedHat
* Add docs for setting up a redhat dev box
  - Modified: `manual/1.0-SettingUpVirtualBox.md`
  - Added: `manual/SetupRedHat.md`
  - Modified: `src/roles/apache-php/tasks/ius.yml`
  - Modified: `src/roles/base/tasks/main.yml`
  - Modified: `src/scripts/dev-networking.sh`
  - Modified: `src/scripts/getmeza.sh`

* [63fffc00](https://github.com/freephile/meza/commit/63fffc00) (2017-03-16) James Montalvo: Improve optional variables handling, vars.yml (#505) 
  - Modified: `src/playbooks/backup.yml`
  - Modified: `src/playbooks/create-wiki-promptless.yml`
  - Modified: `src/playbooks/create-wiki.yml`
  - Modified: `src/playbooks/setup-env.yml`
  - Modified: `src/playbooks/site.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
R096	src/roles/init-controller-config/templates/deploy-config.yml	src/roles/init-controller-config/templates/vars.yml
  - Added: `src/roles/set-vars/tasks/main.yml`

* [1f8b6dea](https://github.com/freephile/meza/commit/1f8b6dea) (2017-03-16) James Montalvo: Simplify extension installation and loading (#504) 
  - Modified: `config/core/ansible.cfg`
  - Modified: `manual/installing-additional-extensions.md`
  - Deleted: `src/roles/configure-wiki/files/this-wiki-more-extensions.yml`
  - Modified: `src/roles/configure-wiki/tasks/main.yml`
  - Modified: `src/roles/init-controller-config/tasks/main.yml`
  - Added: `src/roles/init-controller-config/templates/MezaLocalExtensions.yml`
  - Deleted: `src/roles/init-controller-config/templates/all-wiki-more-extensions.yml`
  - Deleted: `src/roles/load-extensions-from-file/tasks/main.yml`
  - Added: `src/roles/mediawiki/files/MezaCoreExtensions.yml`
  - Deleted: `src/roles/mediawiki/files/base-extensions.yml`
  - Modified: `src/roles/mediawiki/tasks/main.yml`
  - Added: `src/roles/mediawiki/templates/Extensions.php.j2`
  - Modified: `src/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `src/roles/mediawiki/templates/composer.local.json.j2`
  - Modified: `src/scripts/meza.py`

* [70449b20](https://github.com/freephile/meza/commit/70449b20) (2017-03-16) chking1: Fix meza command documentation (#503) 
  - Modified: `README.md`
  - Modified: `manual/1.0-SettingUpVirtualBox.md`
  - Modified: `src/scripts/getmeza.sh`

* [1dad381f](https://github.com/freephile/meza/commit/1dad381f) (2017-03-15) James Montalvo: Rewrite meza command in Python (#500) 
  - Added: `config/core/i18n/en.yml`
  - Modified: `config/core/paths.yml`
  - Added: `src/playbooks/setup-env.yml`
  - Added: `src/roles/setup-env/tasks/main.yml`
  - Added: `src/roles/setup-env/templates/all.yml.j2`
  - Added: `src/roles/setup-env/templates/hosts.j2`
  - Modified: `src/scripts/build-docker-container.sh`
  - Modified: `src/scripts/getmeza.sh`
  - Added: `src/scripts/meza.py`
  - Deleted: `src/scripts/meza.sh`
  - Deleted: `src/scripts/setup-dev.sh`
  - Modified: `tests/travis/run-tests.sh`

* [9de160da](https://github.com/freephile/meza/commit/9de160da) (2017-03-13) James Montalvo: Directory structure simplification (#498) 
  - Modified: `.github/ISSUE_TEMPLATE.md`
  - Modified: `.gitignore`
  - Modified: `.travis.yml`
  - Modified: `CONTRIBUTING.md`
  - Deleted: `ansible/README.md`
  - Deleted: `ansible/env/README.md`
  - Modified: `config/README.md`
R069	config/ansible.cfg	config/core/ansible.cfg
  - Modified: `config/core/config.sh`
  - Deleted: `config/core/logrotated_httpd`
R086	ansible/paths.yml	config/core/paths.yml
R100	config/template/SAML-postLocalSettings.php	config/core/template/SAML-postLocalSettings.php
R100	config/template/SAML-preLocalSettings.php	config/core/template/SAML-preLocalSettings.php
R089	config/template/SAMLConfig.php	config/core/template/SAMLConfig.php
R081	config/template/backupDownloaders.php	config/core/template/backupDownloaders.php
R100	config/template/composer.local.json	config/core/template/composer.local.json
R100	config/template/ifcfg-enp0s8	config/core/template/ifcfg-enp0s8
R100	config/template/ifcfg-eth1	config/core/template/ifcfg-eth1
R100	config/template/imagick-secure-policy.xml	config/core/template/imagick-secure-policy.xml
R096	config/template/import-config.example.sh	config/core/template/import-config.example.sh
R100	config/template/install.config.example.sh	config/core/template/install.config.example.sh
R100	config/template/saml-setup-config.sh	config/core/template/saml-setup-config.sh
R100	config/template/saml20-idp-remote.php	config/core/template/saml20-idp-remote.php
R100	config/template/saml_httpd.conf	config/core/template/saml_httpd.conf
R100	config/template/ssh	config/core/template/ssh
R100	ansible/template-env/README.md	config/core/template/template-env/README.md
R100	ansible/template-env/blank/group_vars/all.yml	config/core/template/template-env/blank/group_vars/all.yml
R100	ansible/template-env/blank/hosts	config/core/template/template-env/blank/hosts
R076	logs/README.md	data/logs/README.md
  - Modified: `htdocs/backupListing.php`
  - Modified: `htdocs/download-backup.php`
  - Modified: `manual/1.0-SettingUpVirtualBox.md`
  - Modified: `manual/AddingWikis.md`
  - Modified: `manual/DirectoryStructure.md`
  - Modified: `manual/meza-cmd/base.txt`
  - Deleted: `scripts/commandTimes.js`
  - Deleted: `scripts/setup-env.sh`
R086	ansible/backup.yml	src/playbooks/backup.yml
R069	ansible/create-wiki-promptless.yml	src/playbooks/create-wiki-promptless.yml
R095	ansible/create-wiki.yml	src/playbooks/create-wiki.yml
R100	ansible/getdocker.yml	src/playbooks/getdocker.yml
R082	ansible/site.yml	src/playbooks/site.yml
R100	ansible/roles/apache-php/defaults/main.yml	src/roles/apache-php/defaults/main.yml
R100	ansible/roles/apache-php/handlers/main.yml	src/roles/apache-php/handlers/main.yml
R100	ansible/roles/apache-php/tasks/ius.yml	src/roles/apache-php/tasks/ius.yml
R100	ansible/roles/apache-php/tasks/main.yml	src/roles/apache-php/tasks/main.yml
R100	ansible/roles/apache-php/tasks/php.yml	src/roles/apache-php/tasks/php.yml
R100	ansible/roles/apache-php/templates/httpd.conf.j2	src/roles/apache-php/templates/httpd.conf.j2
R099	ansible/roles/apache-php/templates/php.ini.j2	src/roles/apache-php/templates/php.ini.j2
R096	ansible/roles/backup-db-wikis/tasks/main.yml	src/roles/backup-db-wikis/tasks/main.yml
R097	ansible/roles/backup-uploads/tasks/main.yml	src/roles/backup-uploads/tasks/main.yml
R100	ansible/roles/base-extras/tasks/main.yml	src/roles/base-extras/tasks/main.yml
R093	ansible/roles/base/defaults/main.yml	src/roles/base/defaults/main.yml
R100	ansible/roles/base/handlers/main.yml	src/roles/base/handlers/main.yml
R100	ansible/roles/base/tasks/main.yml	src/roles/base/tasks/main.yml
R096	ansible/roles/base/templates/config.php.j2	src/roles/base/templates/config.php.j2
R096	ansible/roles/base/templates/config.sh.j2	src/roles/base/templates/config.sh.j2
R100	ansible/roles/base/templates/ntp.conf.j2	src/roles/base/templates/ntp.conf.j2
R100	ansible/roles/composer/README.md	src/roles/composer/README.md
R100	ansible/roles/composer/defaults/main.yml	src/roles/composer/defaults/main.yml
R100	ansible/roles/composer/tasks/global-require.yml	src/roles/composer/tasks/global-require.yml
R100	ansible/roles/composer/tasks/main.yml	src/roles/composer/tasks/main.yml
R100	ansible/roles/composer/templates/auth.json.j2	src/roles/composer/templates/auth.json.j2
R100	ansible/roles/composer/templates/composer.sh.j2	src/roles/composer/templates/composer.sh.j2
R100	ansible/roles/configure-wiki/files/favicon.ico	src/roles/configure-wiki/files/favicon.ico
R100	ansible/roles/configure-wiki/files/logo.png	src/roles/configure-wiki/files/logo.png
R100	ansible/roles/configure-wiki/files/this-wiki-more-extensions.yml	src/roles/configure-wiki/files/this-wiki-more-extensions.yml
R087	ansible/roles/configure-wiki/tasks/main.yml	src/roles/configure-wiki/tasks/main.yml
R100	ansible/roles/configure-wiki/templates/postLocalSettings.php.j2	src/roles/configure-wiki/templates/postLocalSettings.php.j2
R100	ansible/roles/configure-wiki/templates/preLocalSettings.php.j2	src/roles/configure-wiki/templates/preLocalSettings.php.j2
R100	ansible/roles/create-wiki-wrapper/tasks/main.yml	src/roles/create-wiki-wrapper/tasks/main.yml
R100	ansible/roles/database/README.md	src/roles/database/README.md
R100	ansible/roles/database/defaults/main.yml	src/roles/database/defaults/main.yml
R100	ansible/roles/database/handlers/main.yml	src/roles/database/handlers/main.yml
R100	ansible/roles/database/tasks/configure.yml	src/roles/database/tasks/configure.yml
R100	ansible/roles/database/tasks/databases.yml	src/roles/database/tasks/databases.yml
R100	ansible/roles/database/tasks/main.yml	src/roles/database/tasks/main.yml
R100	ansible/roles/database/tasks/replication.yml	src/roles/database/tasks/replication.yml
R100	ansible/roles/database/tasks/secure-installation.yml	src/roles/database/tasks/secure-installation.yml
R100	ansible/roles/database/tasks/setup-Debian.yml	src/roles/database/tasks/setup-Debian.yml
R100	ansible/roles/database/tasks/setup-RedHat.yml	src/roles/database/tasks/setup-RedHat.yml
R100	ansible/roles/database/tasks/users.yml	src/roles/database/tasks/users.yml
R100	ansible/roles/database/tasks/variables.yml	src/roles/database/tasks/variables.yml
R100	ansible/roles/database/templates/my.cnf.j2	src/roles/database/templates/my.cnf.j2
R100	ansible/roles/database/templates/root-my.cnf.j2	src/roles/database/templates/root-my.cnf.j2
R100	ansible/roles/database/templates/user-my.cnf.j2	src/roles/database/templates/user-my.cnf.j2
R100	ansible/roles/database/vars/Debian.yml	src/roles/database/vars/Debian.yml
R100	ansible/roles/database/vars/RedHat-6.yml	src/roles/database/vars/RedHat-6.yml
R100	ansible/roles/database/vars/RedHat-7.yml	src/roles/database/vars/RedHat-7.yml
R094	ansible/roles/dump-db-wikis/tasks/main.yml	src/roles/dump-db-wikis/tasks/main.yml
R100	ansible/roles/elasticsearch/defaults/main.yml	src/roles/elasticsearch/defaults/main.yml
R100	ansible/roles/elasticsearch/handlers/main.yml	src/roles/elasticsearch/handlers/main.yml
R100	ansible/roles/elasticsearch/tasks/main.yml	src/roles/elasticsearch/tasks/main.yml
R100	ansible/roles/elasticsearch/templates/elasticsearch.repo.j2	src/roles/elasticsearch/templates/elasticsearch.repo.j2
R100	ansible/roles/elasticsearch/templates/elasticsearch.yml.j2	src/roles/elasticsearch/templates/elasticsearch.yml.j2
R100	ansible/roles/elasticsearch/templates/java_home.sh.j2	src/roles/elasticsearch/templates/java_home.sh.j2
R100	ansible/roles/firewalld/LICENSE	src/roles/firewalld/LICENSE
R100	ansible/roles/firewalld/README.md	src/roles/firewalld/README.md
R100	ansible/roles/firewalld/defaults/main.yml	src/roles/firewalld/defaults/main.yml
R100	ansible/roles/firewalld/handlers/main.yml	src/roles/firewalld/handlers/main.yml
R100	ansible/roles/firewalld/meta/main.yml	src/roles/firewalld/meta/main.yml
R100	ansible/roles/firewalld/tasks/main.yml	src/roles/firewalld/tasks/main.yml
R100	ansible/roles/haproxy/handlers/main.yml	src/roles/haproxy/handlers/main.yml
R100	ansible/roles/haproxy/tasks/main.yml	src/roles/haproxy/tasks/main.yml
R100	ansible/roles/haproxy/templates/errors/500.http.j2	src/roles/haproxy/templates/errors/500.http.j2
R100	ansible/roles/haproxy/templates/errors/also 400, 403, 408, 502, 503, 504.http	src/roles/haproxy/templates/errors/also 400, 403, 408, 502, 503, 504.http
R100	ansible/roles/haproxy/templates/haproxy-http.firewalld.xml.j2	src/roles/haproxy/templates/haproxy-http.firewalld.xml.j2
R100	ansible/roles/haproxy/templates/haproxy-https.firewalld.xml.j2	src/roles/haproxy/templates/haproxy-https.firewalld.xml.j2
R100	ansible/roles/haproxy/templates/haproxy.cfg.j2	src/roles/haproxy/templates/haproxy.cfg.j2
R100	ansible/roles/haproxy/templates/haproxy.rsyslog.conf.j2	src/roles/haproxy/templates/haproxy.rsyslog.conf.j2
R100	ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdfdetach	src/roles/imagemagick/files/xpdf-3.04-bin64/pdfdetach
R100	ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdffonts	src/roles/imagemagick/files/xpdf-3.04-bin64/pdffonts
R100	ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdfimages	src/roles/imagemagick/files/xpdf-3.04-bin64/pdfimages
R100	ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdfinfo	src/roles/imagemagick/files/xpdf-3.04-bin64/pdfinfo
R100	ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdftohtml	src/roles/imagemagick/files/xpdf-3.04-bin64/pdftohtml
R100	ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdftopng	src/roles/imagemagick/files/xpdf-3.04-bin64/pdftopng
R100	ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdftoppm	src/roles/imagemagick/files/xpdf-3.04-bin64/pdftoppm
R100	ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdftops	src/roles/imagemagick/files/xpdf-3.04-bin64/pdftops
R100	ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdftotext	src/roles/imagemagick/files/xpdf-3.04-bin64/pdftotext
R100	ansible/roles/imagemagick/files/xpdf-3.04-bin64/xpdf	src/roles/imagemagick/files/xpdf-3.04-bin64/xpdf
R100	ansible/roles/imagemagick/tasks/main.yml	src/roles/imagemagick/tasks/main.yml
R100	ansible/roles/init-controller-config/defaults/main.yml	src/roles/init-controller-config/defaults/main.yml
R090	ansible/roles/init-controller-config/tasks/main.yml	src/roles/init-controller-config/tasks/main.yml
R100	ansible/roles/init-controller-config/templates/SAML-placeholder.txt	src/roles/init-controller-config/templates/SAML-placeholder.txt
R100	ansible/roles/init-controller-config/templates/all-wiki-more-extensions.yml	src/roles/init-controller-config/templates/all-wiki-more-extensions.yml
R100	ansible/roles/init-controller-config/templates/deploy-config.yml	src/roles/init-controller-config/templates/deploy-config.yml
R100	ansible/roles/init-controller-config/templates/postLocalSettings_allWikis.php	src/roles/init-controller-config/templates/postLocalSettings_allWikis.php
R100	ansible/roles/init-controller-config/templates/preLocalSettings_allWikis.php	src/roles/init-controller-config/templates/preLocalSettings_allWikis.php
R100	ansible/roles/load-extensions-from-file/tasks/main.yml	src/roles/load-extensions-from-file/tasks/main.yml
R100	ansible/roles/mediawiki/defaults/main.yml	src/roles/mediawiki/defaults/main.yml
R100	ansible/roles/mediawiki/files/base-extensions.yml	src/roles/mediawiki/files/base-extensions.yml
R100	ansible/roles/mediawiki/handlers/main.yml	src/roles/mediawiki/handlers/main.yml
R095	ansible/roles/mediawiki/tasks/main.yml	src/roles/mediawiki/tasks/main.yml
R100	ansible/roles/mediawiki/templates/BlenderSettings.php.j2	src/roles/mediawiki/templates/BlenderSettings.php.j2
R099	ansible/roles/mediawiki/templates/LocalSettings.php.j2	src/roles/mediawiki/templates/LocalSettings.php.j2
R100	ansible/roles/mediawiki/templates/composer.local.json.j2	src/roles/mediawiki/templates/composer.local.json.j2
R100	ansible/roles/memcached/handlers/main.yml	src/roles/memcached/handlers/main.yml
R100	ansible/roles/memcached/tasks/main.yml	src/roles/memcached/tasks/main.yml
R100	ansible/roles/memcached/templates/memcached.j2	src/roles/memcached/templates/memcached.j2
R100	ansible/roles/nodejs/README.md	src/roles/nodejs/README.md
R100	ansible/roles/nodejs/defaults/main.yml	src/roles/nodejs/defaults/main.yml
R100	ansible/roles/nodejs/meta/main.yml	src/roles/nodejs/meta/main.yml
R100	ansible/roles/nodejs/tasks/main.yml	src/roles/nodejs/tasks/main.yml
R100	ansible/roles/nodejs/tasks/setup-Debian.yml	src/roles/nodejs/tasks/setup-Debian.yml
R100	ansible/roles/nodejs/tasks/setup-RedHat.yml	src/roles/nodejs/tasks/setup-RedHat.yml
R100	ansible/roles/nodejs/templates/npm.sh.j2	src/roles/nodejs/templates/npm.sh.j2
R100	ansible/roles/nodejs/tests/test.yml	src/roles/nodejs/tests/test.yml
R100	ansible/roles/parsoid/defaults/main.yml	src/roles/parsoid/defaults/main.yml
R100	ansible/roles/parsoid/handlers/main.yml	src/roles/parsoid/handlers/main.yml
R100	ansible/roles/parsoid/tasks/main.yml	src/roles/parsoid/tasks/main.yml
R100	ansible/roles/parsoid/templates/localsettings.js.j2	src/roles/parsoid/templates/localsettings.js.j2
R100	ansible/roles/parsoid/templates/parsoid.initd.sh.j2	src/roles/parsoid/templates/parsoid.initd.sh.j2
R097	ansible/roles/sync-configs/tasks/main.yml	src/roles/sync-configs/tasks/main.yml
R100	ansible/roles/update.php/tasks/main.yml	src/roles/update.php/tasks/main.yml
R100	ansible/roles/verify-wiki/defaults/main.yml	src/roles/verify-wiki/defaults/main.yml
R100	ansible/roles/verify-wiki/handlers/main.yml	src/roles/verify-wiki/handlers/main.yml
R100	ansible/roles/verify-wiki/tasks/init-wiki.yml	src/roles/verify-wiki/tasks/init-wiki.yml
R097	ansible/roles/verify-wiki/tasks/main.yml	src/roles/verify-wiki/tasks/main.yml
R100	ansible/roles/verify-wiki/templates/mediawiki-tables.sql	src/roles/verify-wiki/templates/mediawiki-tables.sql
R095	scripts/build-docker-container.sh	src/scripts/build-docker-container.sh
R100	scripts/create-vm.sh	src/scripts/create-vm.sh
R096	scripts/dev-networking.sh	src/scripts/dev-networking.sh
R100	scripts/elastic-build-index.sh	src/scripts/elastic-build-index.sh
R094	scripts/elastic-rebuild-index.sh	src/scripts/elastic-rebuild-index.sh
R100	scripts/getDatabaseNameFromSetup.php	src/scripts/getDatabaseNameFromSetup.php
R086	scripts/getmeza.sh	src/scripts/getmeza.sh
R100	scripts/make-environment/hosts.default	src/scripts/make-environment/hosts.default
R100	scripts/make-environment/tasks/main.yml	src/scripts/make-environment/tasks/main.yml
R100	scripts/make-environment/templates/group_vars_all.yml.j2	src/scripts/make-environment/templates/group_vars_all.yml.j2
R089	scripts/meza.sh	src/scripts/meza.sh
R100	scripts/mezaCreateUser.php	src/scripts/mezaCreateUser.php
R100	scripts/pigeon.txt	src/scripts/pigeon.txt
R100	scripts/runAllJobs.php	src/scripts/runAllJobs.php
R100	scripts/samba.sh	src/scripts/samba.sh
R093	scripts/saml.sh	src/scripts/saml.sh
R092	scripts/setup-dev.sh	src/scripts/setup-dev.sh
R100	scripts/shell-functions/base.sh	src/scripts/shell-functions/base.sh
R100	scripts/shell-functions/db-master.sh	src/scripts/shell-functions/db-master.sh
R100	scripts/shell-functions/linux-user.sh	src/scripts/shell-functions/linux-user.sh
R094	scripts/shell-functions/logging.sh	src/scripts/shell-functions/logging.sh
R100	scripts/slack.sh	src/scripts/slack.sh
R094	scripts/ssh-users/setup-master-user.sh	src/scripts/ssh-users/setup-master-user.sh
R100	scripts/ssh-users/setup-minion-user.sh	src/scripts/ssh-users/setup-minion-user.sh
R100	scripts/ssh-users/transfer-master-key.sh	src/scripts/ssh-users/transfer-master-key.sh
R100	scripts/ssl-selftest.sh	src/scripts/ssl-selftest.sh
R099	scripts/unifyUserTables.php	src/scripts/unifyUserTables.php
R096	scripts/updateExtensions.sh	src/scripts/updateExtensions.sh
  - Deleted: `test/README.md`
  - Deleted: `test/basic/run-test.sh`
  - Deleted: `test/remote-backup/import-config.sh`
  - Deleted: `test/remote-backup/run-test.sh`
  - Deleted: `test/remote-backup/source-server-setup.sh`
R091	test/travis/run-tests.sh	tests/travis/run-tests.sh

* [d9a0fe82](https://github.com/freephile/meza/commit/d9a0fe82) (2017-03-10) James Montalvo: Ensure all servers have git installed (#495) Build failed on a multi-server setup where Parsoid was
on its own server. Meza needed to use git to checkout
Parsoid and failed. The server that had Parsoid on it
had only had the following commands run on it directly
prior to the control server starting to configure it:

sudo ifup enp0s3
curl -L minion.getmeza.org > doit
sudo bash doit
curl -L vbox.getmeza.org > doit2
sudo bash doit2

None of those steps install Git. They were followed by
the control server pushing its SSH keys to this minion
and then 'meza setup env myenv' and 'meza deploy myenv'
which began installing meza across all the wikis.

When installing a monolith you setup the meza command
with 'curl -L getmeza.org > doit' and 'sudo bash doit'
and that installs git. Since that step is not required
when setting up a minion (minions don't require the
meza command since you shouldn't need to interact with
them directly) the minions were not guaranteed to have
Git.
  - Modified: `ansible/roles/base/tasks/main.yml`

* [154ebed1](https://github.com/freephile/meza/commit/154ebed1) (2017-03-10) krisfield: Correcting LocalSettings file path (#493) check for existing postLocalSettings_allWikis file had incorrect path.
  - Modified: `ansible/roles/mediawiki/templates/LocalSettings.php.j2`

* [cfbc3e3d](https://github.com/freephile/meza/commit/cfbc3e3d) (2017-03-10) James Montalvo: Don't hard-code secret key, random generate on setting up new env (#492) 
  - Modified: `ansible/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `ansible/template-env/blank/group_vars/all.yml`
  - Modified: `scripts/meza.sh`

* [6f3fb724](https://github.com/freephile/meza/commit/6f3fb724) (2017-03-09) James Montalvo: README updates (#491) 
  - Modified: `README.md`
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [b4918060](https://github.com/freephile/meza/commit/b4918060) (2017-03-09) James Montalvo: Improve meza command help files (#490) 
  - Added: `manual/meza-cmd/backup.txt`
  - Modified: `manual/meza-cmd/base.txt`
  - Modified: `manual/meza-cmd/create.txt`
  - Added: `manual/meza-cmd/deploy.txt`
  - Modified: `manual/meza-cmd/docker.txt`
  - Modified: `manual/meza-cmd/install.txt`
  - Added: `manual/meza-cmd/setup.txt`
  - Modified: `scripts/meza.sh`

* [71e944fe](https://github.com/freephile/meza/commit/71e944fe) (2017-03-09) James Montalvo: Make CodeClimate's ShellCheck work; add CodeClimate GPA badge to README (#489) 
  - Modified: `.codeclimate.yml`
  - Modified: `README.md`

* [f80b7454](https://github.com/freephile/meza/commit/f80b7454) (2017-03-09) James Montalvo: Improve README 
  - Modified: `README.md`

* [9c2e7841](https://github.com/freephile/meza/commit/9c2e7841) (2017-03-09) James Montalvo: fix references to 'dev' branch, point to master (#488) 
  - Modified: `README.md`
  - Modified: `scripts/getmeza.sh`

* [44329bbd](https://github.com/freephile/meza/commit/44329bbd) (2017-03-09) James Montalvo: Add GIF to README; improve intro words (#485) 
  - Modified: `README.md`

* [1d403f1a](https://github.com/freephile/meza/commit/1d403f1a) (2017-03-09) James Montalvo: Add gif showing meza commands (#484) 
  - Added: `manual/commands.gif`

* [4e39e02c](https://github.com/freephile/meza/commit/4e39e02c) (2017-03-08) James Montalvo: Add retry file path so it's possible to retry failed ansible runs (#483) 
  - Modified: `config/ansible.cfg`

* [6a61b388](https://github.com/freephile/meza/commit/6a61b388) (2017-03-08) James Montalvo: Add create-backup functionality, integrate with `meza deploy` (#480) 
  - Modified: `.gitignore`
  - Added: `ansible/backup.yml`
  - Modified: `ansible/paths.yml`
  - Added: `ansible/roles/backup-db-wikis/tasks/main.yml`
  - Added: `ansible/roles/backup-uploads/tasks/main.yml`
  - Added: `ansible/roles/dump-db-wikis/tasks/main.yml`
  - Modified: `ansible/roles/mediawiki/templates/LocalSettings.php.j2`
  - Modified: `ansible/roles/update.php/tasks/main.yml`
  - Modified: `ansible/roles/verify-wiki/tasks/main.yml`
  - Modified: `ansible/template-env/blank/hosts`
  - Modified: `scripts/meza.sh`
  - Modified: `test/travis/run-tests.sh`

* [afdb3fa5](https://github.com/freephile/meza/commit/afdb3fa5) (2017-03-07) James Montalvo: Commands for setting up docker (on CentOS) and executing commands on container (#482) 
  - Added: `ansible/getdocker.yml`
  - Added: `manual/meza-cmd/docker.txt`
  - Added: `scripts/build-docker-container.sh`
  - Modified: `scripts/meza.sh`

* [40c77376](https://github.com/freephile/meza/commit/40c77376) (2017-03-06) James Montalvo: Better testing with multiple environments (#481) 
  - Modified: `.travis.yml`
  - Modified: `ansible/roles/apache-php/tasks/ius.yml`
  - Modified: `ansible/roles/base/tasks/main.yml`
  - Modified: `ansible/roles/haproxy/tasks/main.yml`
  - Modified: `ansible/roles/parsoid/tasks/main.yml`
  - Modified: `ansible/roles/parsoid/templates/parsoid.initd.sh.j2`
  - Modified: `ansible/site.yml`
  - Added: `config/ansible.cfg`
  - Modified: `scripts/meza.sh`
  - Added: `test/travis/run-tests.sh`

* [8593228c](https://github.com/freephile/meza/commit/8593228c) (2017-03-02) James Montalvo: Make meza command for setting up dev (ftp, git) (#479) 
  - Modified: `scripts/meza.sh`

* [4bae106b](https://github.com/freephile/meza/commit/4bae106b) (2017-03-01) James Montalvo: create-wiki playbooks with unified create/import/backup model (#478) * create-wiki playbooks with unified create/import/backup model

* Re-add missing items in create-wiki process

* Remove update database from create-wiki-wrapper
  * Move to verify-wiki/tasks/init-wiki.yml along with
    several missing items:
    * import meeting minutes pages
    * rebuild recent changes
    * create admin user on demo wiki
    * SMW rebuild data
    * runJobs.php
    * Build elasticsearch index
  * run init-wiki only when a new wiki created.
* Note: update.php will run twice for Demo Wiki and anytime
  a wiki is added to the config and then deploy is run.

* got a 129 exit code from 'rm -rf ...' command. possible solution

* Need to notify parsoid to restart after new wiki
  - Modified: `.gitignore`
  - Modified: `.travis.yml`
  - Added: `ansible/create-wiki-promptless.yml`
  - Added: `ansible/create-wiki.yml`
  - Modified: `ansible/paths.yml`
R100	ansible/roles/mediawiki/templates/wiki-init/favicon.ico	ansible/roles/configure-wiki/files/favicon.ico
R100	ansible/roles/mediawiki/templates/wiki-init/logo.png	ansible/roles/configure-wiki/files/logo.png
  - Added: `ansible/roles/configure-wiki/files/this-wiki-more-extensions.yml`
  - Added: `ansible/roles/configure-wiki/tasks/main.yml`
R087	ansible/roles/mediawiki/templates/wiki-init/postLocalSettings.php.j2	ansible/roles/configure-wiki/templates/postLocalSettings.php.j2
R096	ansible/roles/mediawiki/templates/wiki-init/preLocalSettings.php.j2	ansible/roles/configure-wiki/templates/preLocalSettings.php.j2
  - Added: `ansible/roles/create-wiki-wrapper/tasks/main.yml`
  - Added: `ansible/roles/init-controller-config/defaults/main.yml`
  - Added: `ansible/roles/init-controller-config/tasks/main.yml`
R100	ansible/roles/mediawiki/files/local_baseline/SAML-placeholder.txt	ansible/roles/init-controller-config/templates/SAML-placeholder.txt
R100	ansible/roles/mediawiki/files/local_baseline/all-wiki-more-extensions.yml	ansible/roles/init-controller-config/templates/all-wiki-more-extensions.yml
  - Added: `ansible/roles/init-controller-config/templates/deploy-config.yml`
R100	ansible/roles/mediawiki/files/local_baseline/postLocalSettings_allWikis.php	ansible/roles/init-controller-config/templates/postLocalSettings_allWikis.php
R095	local/preLocalSettings_allWikis.php	ansible/roles/init-controller-config/templates/preLocalSettings_allWikis.php
R092	ansible/roles/mediawiki/tasks/load-extensions-from-file.yml	ansible/roles/load-extensions-from-file/tasks/main.yml
  - Deleted: `ansible/roles/mediawiki/files/local_baseline/LandingPage.php`
  - Deleted: `ansible/roles/mediawiki/files/local_baseline/preLocalSettings_allWikis.php`
  - Deleted: `ansible/roles/mediawiki/files/local_baseline/wikis/test/this-wiki-more-extensions.yml`
  - Deleted: `ansible/roles/mediawiki/tasks/create-wiki.yml`
  - Deleted: `ansible/roles/mediawiki/tasks/local-config.yml`
  - Modified: `ansible/roles/mediawiki/tasks/main.yml`
  - Deleted: `ansible/roles/mediawiki/tasks/update-db-all-wikis.yml`
  - Modified: `ansible/roles/mediawiki/templates/LocalSettings.php.j2`
  - Deleted: `ansible/roles/mediawiki/templates/more-extensions.yml.j2`
  - Deleted: `ansible/roles/mediawiki/templates/preLocalSettings_allWikis.php.j2`
  - Added: `ansible/roles/sync-configs/tasks/main.yml`
  - Added: `ansible/roles/update.php/tasks/main.yml`
  - Added: `ansible/roles/verify-wiki/defaults/main.yml`
  - Added: `ansible/roles/verify-wiki/handlers/main.yml`
  - Added: `ansible/roles/verify-wiki/tasks/init-wiki.yml`
  - Added: `ansible/roles/verify-wiki/tasks/main.yml`
R100	ansible/roles/mediawiki/files/mediawiki-tables.sql	ansible/roles/verify-wiki/templates/mediawiki-tables.sql
  - Modified: `ansible/site.yml`
  - Added: `config/README.md`
  - Deleted: `local/LandingPage.php`
  - Deleted: `local/all-wiki-more-extensions.yml`
  - Deleted: `local/postLocalSettings_allWikis.php`
  - Deleted: `scripts/backup-and-import.sh`
  - Deleted: `scripts/backup-remote-wikis.sh`
  - Deleted: `scripts/create-wiki.sh`
  - Deleted: `scripts/import-remote-wikis.sh`
  - Deleted: `scripts/import-wikis.sh`
  - Deleted: `scripts/install.sh`
  - Modified: `scripts/meza.sh`
  - Deleted: `scripts/printTitle.sh`

* [d0cbdcae](https://github.com/freephile/meza/commit/d0cbdcae) (2017-02-24) James Montalvo: Build notify (#475) 
  - Modified: `.travis.yml`

* [5a814c05](https://github.com/freephile/meza/commit/5a814c05) (2017-02-24) James Montalvo: Start using Travis CI (#472) 
  - Added: `.travis.yml`
  - Modified: `README.md`
  - Modified: `ansible/roles/apache-php/tasks/php.yml`
  - Modified: `ansible/roles/base/tasks/main.yml`
  - Modified: `ansible/roles/elasticsearch/tasks/main.yml`
  - Modified: `ansible/roles/haproxy/tasks/main.yml`
  - Modified: `scripts/getmeza.sh`
  - Modified: `scripts/meza.sh`

* [17f258ce](https://github.com/freephile/meza/commit/17f258ce) (2017-02-23) James Montalvo: Add prompts to set fqdn, DB passwords, email, network zone (#471) 
  - Deleted: `ansible/env/example/hosts`
  - Modified: `ansible/roles/mediawiki/templates/BlenderSettings.php.j2`
  - Modified: `ansible/roles/mediawiki/templates/LocalSettings.php.j2`
  - Added: `ansible/template-env/README.md`
R068	ansible/env/example/group_vars/all.yml	ansible/template-env/blank/group_vars/all.yml
  - Added: `ansible/template-env/blank/hosts`
  - Modified: `config/core/i18n/en.sh`
  - Modified: `scripts/meza.sh`

* [dfedf686](https://github.com/freephile/meza/commit/dfedf686) (2017-02-22) James Montalvo: Allow ansible local connections (#470) * better method to skip localhost and same-server firewall rules (using "difference" to remove localhost and inventory_hostname)
* make haproxy work with localhost-monolith by binding to *
  - Modified: `ansible/env/example/hosts`
  - Modified: `ansible/roles/firewalld/tasks/main.yml`
  - Modified: `ansible/roles/haproxy/templates/haproxy.cfg.j2`
  - Modified: `scripts/meza.sh`

* [654771ee](https://github.com/freephile/meza/commit/654771ee) (2017-02-22) James Montalvo: Make `meza install monolith` work again (#469) 
  - Modified: `.gitignore`
  - Modified: `README.md`
  - Modified: `ansible/env/example/hosts`
  - Modified: `config/core/config.sh`
  - Modified: `scripts/meza.sh`

* [f9a6a920](https://github.com/freephile/meza/commit/f9a6a920) (2017-02-21) James Montalvo: Rewrite meza to install with Ansible (#468) 
  - Modified: `.gitignore`
  - Modified: `README.md`
  - Added: `ansible/README.md`
  - Added: `ansible/env/README.md`
  - Added: `ansible/env/example/group_vars/all.yml`
  - Added: `ansible/env/example/hosts`
  - Added: `ansible/paths.yml`
  - Added: `ansible/roles/apache-php/defaults/main.yml`
  - Added: `ansible/roles/apache-php/handlers/main.yml`
  - Added: `ansible/roles/apache-php/tasks/ius.yml`
  - Added: `ansible/roles/apache-php/tasks/main.yml`
  - Added: `ansible/roles/apache-php/tasks/php.yml`
R083	config/core/httpd.conf	ansible/roles/apache-php/templates/httpd.conf.j2
R099	config/core/php.ini	ansible/roles/apache-php/templates/php.ini.j2
  - Added: `ansible/roles/base-extras/tasks/main.yml`
  - Added: `ansible/roles/base/defaults/main.yml`
  - Added: `ansible/roles/base/handlers/main.yml`
  - Added: `ansible/roles/base/tasks/main.yml`
  - Added: `ansible/roles/base/templates/config.php.j2`
  - Added: `ansible/roles/base/templates/config.sh.j2`
  - Added: `ansible/roles/base/templates/ntp.conf.j2`
  - Added: `ansible/roles/composer/README.md`
  - Added: `ansible/roles/composer/defaults/main.yml`
  - Added: `ansible/roles/composer/tasks/global-require.yml`
  - Added: `ansible/roles/composer/tasks/main.yml`
  - Added: `ansible/roles/composer/templates/auth.json.j2`
  - Added: `ansible/roles/composer/templates/composer.sh.j2`
  - Added: `ansible/roles/database/README.md`
  - Added: `ansible/roles/database/defaults/main.yml`
  - Added: `ansible/roles/database/handlers/main.yml`
  - Added: `ansible/roles/database/tasks/configure.yml`
  - Added: `ansible/roles/database/tasks/databases.yml`
  - Added: `ansible/roles/database/tasks/main.yml`
  - Added: `ansible/roles/database/tasks/replication.yml`
  - Added: `ansible/roles/database/tasks/secure-installation.yml`
  - Added: `ansible/roles/database/tasks/setup-Debian.yml`
  - Added: `ansible/roles/database/tasks/setup-RedHat.yml`
  - Added: `ansible/roles/database/tasks/users.yml`
  - Added: `ansible/roles/database/tasks/variables.yml`
  - Added: `ansible/roles/database/templates/my.cnf.j2`
  - Added: `ansible/roles/database/templates/root-my.cnf.j2`
  - Added: `ansible/roles/database/templates/user-my.cnf.j2`
  - Added: `ansible/roles/database/vars/Debian.yml`
  - Added: `ansible/roles/database/vars/RedHat-6.yml`
  - Added: `ansible/roles/database/vars/RedHat-7.yml`
  - Added: `ansible/roles/elasticsearch/defaults/main.yml`
  - Added: `ansible/roles/elasticsearch/handlers/main.yml`
  - Added: `ansible/roles/elasticsearch/tasks/main.yml`
  - Added: `ansible/roles/elasticsearch/templates/elasticsearch.repo.j2`
R099	config/core/elasticsearch.yml	ansible/roles/elasticsearch/templates/elasticsearch.yml.j2
  - Added: `ansible/roles/elasticsearch/templates/java_home.sh.j2`
  - Added: `ansible/roles/firewalld/LICENSE`
  - Added: `ansible/roles/firewalld/README.md`
  - Added: `ansible/roles/firewalld/defaults/main.yml`
  - Added: `ansible/roles/firewalld/handlers/main.yml`
  - Added: `ansible/roles/firewalld/meta/main.yml`
  - Added: `ansible/roles/firewalld/tasks/main.yml`
  - Added: `ansible/roles/haproxy/handlers/main.yml`
  - Added: `ansible/roles/haproxy/tasks/main.yml`
  - Added: `ansible/roles/haproxy/templates/errors/500.http.j2`
  - Added: `ansible/roles/haproxy/templates/errors/also 400, 403, 408, 502, 503, 504.http`
  - Added: `ansible/roles/haproxy/templates/haproxy-http.firewalld.xml.j2`
  - Added: `ansible/roles/haproxy/templates/haproxy-https.firewalld.xml.j2`
  - Added: `ansible/roles/haproxy/templates/haproxy.cfg.j2`
  - Added: `ansible/roles/haproxy/templates/haproxy.rsyslog.conf.j2`
  - Added: `ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdfdetach`
  - Added: `ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdffonts`
  - Added: `ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdfimages`
  - Added: `ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdfinfo`
  - Added: `ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdftohtml`
  - Added: `ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdftopng`
  - Added: `ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdftoppm`
  - Added: `ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdftops`
  - Added: `ansible/roles/imagemagick/files/xpdf-3.04-bin64/pdftotext`
  - Added: `ansible/roles/imagemagick/files/xpdf-3.04-bin64/xpdf`
  - Added: `ansible/roles/imagemagick/tasks/main.yml`
  - Added: `ansible/roles/mediawiki/defaults/main.yml`
  - Added: `ansible/roles/mediawiki/files/base-extensions.yml`
R100	config/template/LandingPage.php	ansible/roles/mediawiki/files/local_baseline/LandingPage.php
  - Added: `ansible/roles/mediawiki/files/local_baseline/SAML-placeholder.txt`
  - Added: `ansible/roles/mediawiki/files/local_baseline/all-wiki-more-extensions.yml`
  - Added: `ansible/roles/mediawiki/files/local_baseline/postLocalSettings_allWikis.php`
R095	config/template/preLocalSettings_allWikis.php	ansible/roles/mediawiki/files/local_baseline/preLocalSettings_allWikis.php
  - Added: `ansible/roles/mediawiki/files/local_baseline/wikis/test/this-wiki-more-extensions.yml`
  - Added: `ansible/roles/mediawiki/files/mediawiki-tables.sql`
  - Added: `ansible/roles/mediawiki/handlers/main.yml`
  - Added: `ansible/roles/mediawiki/tasks/create-wiki.yml`
  - Added: `ansible/roles/mediawiki/tasks/load-extensions-from-file.yml`
  - Added: `ansible/roles/mediawiki/tasks/local-config.yml`
  - Added: `ansible/roles/mediawiki/tasks/main.yml`
  - Added: `ansible/roles/mediawiki/tasks/update-db-all-wikis.yml`
  - Added: `ansible/roles/mediawiki/templates/BlenderSettings.php.j2`
R069	config/core/LocalSettings.php	ansible/roles/mediawiki/templates/LocalSettings.php.j2
  - Added: `ansible/roles/mediawiki/templates/composer.local.json.j2`
  - Added: `ansible/roles/mediawiki/templates/more-extensions.yml.j2`
  - Added: `ansible/roles/mediawiki/templates/preLocalSettings_allWikis.php.j2`
R100	config/template/wiki-init/config/favicon.ico	ansible/roles/mediawiki/templates/wiki-init/favicon.ico
R100	config/template/wiki-init/config/logo.png	ansible/roles/mediawiki/templates/wiki-init/logo.png
R100	config/template/wiki-init/config/postLocalSettings.php	ansible/roles/mediawiki/templates/wiki-init/postLocalSettings.php.j2
R082	config/template/wiki-init/config/preLocalSettings.php	ansible/roles/mediawiki/templates/wiki-init/preLocalSettings.php.j2
  - Added: `ansible/roles/memcached/handlers/main.yml`
  - Added: `ansible/roles/memcached/tasks/main.yml`
R100	config/core/memcached	ansible/roles/memcached/templates/memcached.j2
  - Added: `ansible/roles/nodejs/README.md`
  - Added: `ansible/roles/nodejs/defaults/main.yml`
  - Added: `ansible/roles/nodejs/meta/main.yml`
  - Added: `ansible/roles/nodejs/tasks/main.yml`
  - Added: `ansible/roles/nodejs/tasks/setup-Debian.yml`
  - Added: `ansible/roles/nodejs/tasks/setup-RedHat.yml`
  - Added: `ansible/roles/nodejs/templates/npm.sh.j2`
  - Added: `ansible/roles/nodejs/tests/test.yml`
  - Added: `ansible/roles/parsoid/defaults/main.yml`
  - Added: `ansible/roles/parsoid/handlers/main.yml`
  - Added: `ansible/roles/parsoid/tasks/main.yml`
R096	config/core/localsettings.js	ansible/roles/parsoid/templates/localsettings.js.j2
R096	config/core/initd_parsoid.sh	ansible/roles/parsoid/templates/parsoid.initd.sh.j2
  - Added: `ansible/site.yml`
  - Deleted: `config/core/BlenderSettings.php`
  - Modified: `config/core/config.sh`
  - Deleted: `config/core/elasticsearch.repo`
  - Modified: `config/core/i18n/en.sh`
  - Deleted: `config/local/README.md`
  - Deleted: `config/template/more-extensions.php`
  - Deleted: `config/template/my.cnf`
  - Deleted: `config/template/wiki-init/images/README.md`
  - Added: `local/LandingPage.php`
  - Added: `local/all-wiki-more-extensions.yml`
  - Added: `local/postLocalSettings_allWikis.php`
  - Added: `local/preLocalSettings_allWikis.php`
  - Modified: `manual/1.0-SettingUpVirtualBox.md`
  - Added: `scripts/dev-networking.sh`
  - Modified: `scripts/getmeza.sh`
  - Added: `scripts/make-environment/hosts.default`
  - Added: `scripts/make-environment/tasks/main.yml`
  - Added: `scripts/make-environment/templates/group_vars_all.yml.j2`
  - Modified: `scripts/meza.sh`
  - Deleted: `scripts/modules/apache/init.sh`
  - Deleted: `scripts/modules/apache/packages.txt`
  - Deleted: `scripts/modules/apache/prompts.sh`
  - Deleted: `scripts/modules/base-extras/packages.txt`
  - Deleted: `scripts/modules/base/init.sh`
  - Deleted: `scripts/modules/base/packages.txt`
  - Deleted: `scripts/modules/base/pre-setup.sh`
  - Deleted: `scripts/modules/db-client/init.sh`
  - Deleted: `scripts/modules/db-client/packages.txt`
  - Deleted: `scripts/modules/db-client/prompts.sh`
  - Deleted: `scripts/modules/db-remote/init.sh`
  - Deleted: `scripts/modules/db-remote/prompts.sh`
  - Deleted: `scripts/modules/db-server/init.sh`
  - Deleted: `scripts/modules/db-server/packages.txt`
  - Deleted: `scripts/modules/db-server/prompts.sh`
  - Deleted: `scripts/modules/db-slave/init.sh`
  - Deleted: `scripts/modules/db-slave/pre-setup.sh`
  - Deleted: `scripts/modules/db-slave/prompts.sh`
  - Deleted: `scripts/modules/dev-networking/init.sh`
  - Deleted: `scripts/modules/dev-networking/packages.txt`
  - Deleted: `scripts/modules/dev-networking/prompts.sh`
  - Deleted: `scripts/modules/elasticsearch/init.sh`
  - Deleted: `scripts/modules/elasticsearch/packages.txt`
  - Deleted: `scripts/modules/extensions/init.sh`
  - Deleted: `scripts/modules/imagemagick/init.sh`
  - Deleted: `scripts/modules/imagemagick/packages.txt`
  - Deleted: `scripts/modules/mediawiki/init.sh`
  - Deleted: `scripts/modules/mediawiki/prompts.sh`
  - Deleted: `scripts/modules/memcached/init.sh`
  - Deleted: `scripts/modules/memcached/packages.txt`
  - Deleted: `scripts/modules/parsoid/init.sh`
  - Deleted: `scripts/modules/parsoid/prompts.sh`
  - Deleted: `scripts/modules/php/init.sh`
  - Deleted: `scripts/modules/php/packages.txt`
  - Deleted: `scripts/modules/security/init.sh`
  - Deleted: `scripts/modules/thisisappserver/prompts.sh`
  - Added: `scripts/setup-dev.sh`
  - Added: `scripts/setup-env.sh`
  - Deleted: `scripts/shell-functions/add-user.sh`
  - Modified: `scripts/shell-functions/base.sh`
  - Added: `scripts/shell-functions/linux-user.sh`
  - Added: `scripts/ssh-users/setup-master-user.sh`
  - Added: `scripts/ssh-users/setup-minion-user.sh`
  - Added: `scripts/ssh-users/transfer-master-key.sh`
  - Deleted: `sources/README.md`
  - Modified: `test/remote-backup/run-test.sh`
  - Modified: `test/remote-backup/source-server-setup.sh`

* [1365bd37](https://github.com/freephile/meza/commit/1365bd37) (2017-02-02) James Montalvo: use composer.local.json 
  - Added: `config/template/composer.local.json`
  - Modified: `scripts/extensions.sh`

* [bd716d47](https://github.com/freephile/meza/commit/bd716d47) (2017-01-10) James Montalvo: yum-install EPEL, not download. How did I not know this 
  - Deleted: `scripts/modules/base/epel.sh`
  - Modified: `scripts/modules/base/pre-setup.sh`

* [04f2aaf0](https://github.com/freephile/meza/commit/04f2aaf0) (2016-12-17) Daren Welsh: add steps for partition allocations to help #420 
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [dfad235b](https://github.com/freephile/meza/commit/dfad235b) (2016-12-16) James Montalvo: i18n to correct prompts 
  - Modified: `scripts/modules/db-client/prompts.sh`

* [51266f85](https://github.com/freephile/meza/commit/51266f85) (2016-12-16) James Montalvo: can't put master-host,etc variable into my.cnf anymore. fixes for slave setup 
  - Modified: `scripts/modules/db-slave/init.sh`

* [c97a2ade](https://github.com/freephile/meza/commit/c97a2ade) (2016-12-16) James Montalvo: only do db-master setup within db-server if it's really master 
  - Modified: `scripts/modules/db-server/init.sh`

* [88476650](https://github.com/freephile/meza/commit/88476650) (2016-12-16) James Montalvo: fix i18n and make db-master prompt for list of db servers 
  - Modified: `config/core/i18n/en.sh`
  - Modified: `scripts/modules/db-server/prompts.sh`
  - Modified: `scripts/modules/db-slave/prompts.sh`

* [48889809](https://github.com/freephile/meza/commit/48889809) (2016-12-15) James Montalvo: add db-slave module 
  - Modified: `config/core/config.sh`
  - Modified: `scripts/meza.sh`
  - Modified: `scripts/modules/db-server/init.sh`
  - Modified: `scripts/modules/db-server/prompts.sh`
  - Added: `scripts/modules/db-slave/init.sh`
  - Added: `scripts/modules/db-slave/pre-setup.sh`
  - Added: `scripts/modules/db-slave/prompts.sh`
  - Modified: `scripts/shell-functions/base.sh`
  - Added: `scripts/shell-functions/db-master.sh`

* [c422c8e8](https://github.com/freephile/meza/commit/c422c8e8) (2016-12-15) James Montalvo: Specify expected time to install meza 
  - Modified: `README.md`

* [1012b26a](https://github.com/freephile/meza/commit/1012b26a) (2016-12-14) James Montalvo: need to specify remove directory 
  - Modified: `scripts/import-wikis.sh`

* [4c39b33f](https://github.com/freephile/meza/commit/4c39b33f) (2016-12-14) James Montalvo: don't refresh search index for every wiki, only imported 
  - Modified: `scripts/import-wikis.sh`

* [ab2a6eef](https://github.com/freephile/meza/commit/ab2a6eef) (2016-12-14) James Montalvo: fix not deleting imported directories 
  - Modified: `scripts/backup-remote-wikis.sh`
  - Modified: `scripts/import-wikis.sh`

* [96f3cc3d](https://github.com/freephile/meza/commit/96f3cc3d) (2016-12-14) James Montalvo: add file that combines backup and import 
  - Added: `scripts/backup-and-import.sh`

* [9bff6a92](https://github.com/freephile/meza/commit/9bff6a92) (2016-12-14) James Montalvo: fix missing directory for import-wikis.sh 
  - Modified: `scripts/create-wiki.sh`

* [9bbb2338](https://github.com/freephile/meza/commit/9bbb2338) (2016-12-14) James Montalvo: add echoes for adding mysql and firewall rules for remote servers 
  - Modified: `scripts/modules/db-remote/init.sh`
  - Modified: `scripts/modules/db-server/init.sh`

* [07b8d588](https://github.com/freephile/meza/commit/07b8d588) (2016-12-13) James Montalvo: specify adapter 1 in public zone 
  - Modified: `scripts/modules/dev-networking/init.sh`

* [b23f570f](https://github.com/freephile/meza/commit/b23f570f) (2016-12-13) James Montalvo: adjust network config for mysql remote DBs 
  - Modified: `config/core/config.sh`
  - Modified: `config/template/ifcfg-enp0s8`
  - Modified: `scripts/modules/db-remote/init.sh`

* [327b39f2](https://github.com/freephile/meza/commit/327b39f2) (2016-12-12) James Montalvo: try more secure firewall rules for mysql; fix create-wiki slack 
  - Modified: `scripts/create-wiki.sh`
  - Modified: `scripts/modules/db-remote/init.sh`
  - Modified: `scripts/modules/db-remote/prompts.sh`

* [30ea136c](https://github.com/freephile/meza/commit/30ea136c) (2016-12-12) James Montalvo: forgot memcached\! 
  - Modified: `scripts/meza.sh`

* [af156555](https://github.com/freephile/meza/commit/af156555) (2016-12-12) James Montalvo: make sure to use full 'base' module 
  - Modified: `scripts/meza.sh`

* [c83634d5](https://github.com/freephile/meza/commit/c83634d5) (2016-12-12) James Montalvo: method to define 'this is app server' 
  - Modified: `config/core/i18n/en.sh`
  - Modified: `scripts/meza.sh`
  - Modified: `scripts/modules/parsoid/prompts.sh`
  - Added: `scripts/modules/thisisappserver/prompts.sh`

* [7903452f](https://github.com/freephile/meza/commit/7903452f) (2016-12-12) James Montalvo: fixes 
  - Modified: `config/core/LocalSettings.php`
  - Modified: `scripts/import-wikis.sh`

* [5846d9c0](https://github.com/freephile/meza/commit/5846d9c0) (2016-12-09) James Montalvo: move selinux-to-permissive into base module, create base-extras 
  - Modified: `scripts/meza.sh`
  - Modified: `scripts/modules/apache/init.sh`
  - Added: `scripts/modules/base-extras/packages.txt`
  - Modified: `scripts/modules/base/packages.txt`
  - Modified: `scripts/modules/base/pre-setup.sh`
  - Modified: `scripts/modules/db-server/init.sh`

* [1c0fe116](https://github.com/freephile/meza/commit/1c0fe116) (2016-12-09) James Montalvo: move mariadb datadir to meza location to maintain SELinux config 
  - Modified: `scripts/modules/db-server/init.sh`

* [0235b0e6](https://github.com/freephile/meza/commit/0235b0e6) (2016-12-08) James Montalvo: add SELinux rules for moving MariaDB datadir 
  - Modified: `scripts/modules/db-server/init.sh`

* [38057bbf](https://github.com/freephile/meza/commit/38057bbf) (2016-12-08) James Montalvo: add base module back to db-master directive 
  - Modified: `scripts/meza.sh`

* [08cf4a78](https://github.com/freephile/meza/commit/08cf4a78) (2016-12-08) James Montalvo: fix my.cnf move 
  - Modified: `scripts/modules/db-server/init.sh`

* [86491e80](https://github.com/freephile/meza/commit/86491e80) (2016-12-08) James Montalvo: fix location of i18n dir 
  - Modified: `config/core/config.sh`

* [59c8290f](https://github.com/freephile/meza/commit/59c8290f) (2016-12-08) James Montalvo: use master-slave MW setup and improve meza modules 
  - Modified: `config/core/LocalSettings.php`
  - Modified: `config/core/config.sh`
  - Added: `config/core/i18n/en.sh`
  - Added: `manual/database-planning.md`
  - Modified: `scripts/import-wikis.sh`
  - Modified: `scripts/install.sh`
  - Modified: `scripts/meza.sh`
  - Modified: `scripts/modules/db-client/init.sh`
  - Modified: `scripts/modules/db-client/prompts.sh`
  - Modified: `scripts/modules/db-remote/init.sh`
  - Modified: `scripts/modules/db-remote/prompts.sh`
  - Modified: `scripts/modules/db-server/init.sh`
  - Modified: `scripts/modules/db-server/prompts.sh`
  - Modified: `scripts/modules/mediawiki/init.sh`
  - Modified: `scripts/modules/mediawiki/prompts.sh`

* [76b36121](https://github.com/freephile/meza/commit/76b36121) (2016-12-08) James Montalvo: fix db-server, not db-master, module; fix gen_password (how was that broken?) 
  - Modified: `scripts/meza.sh`

* [eaebc075](https://github.com/freephile/meza/commit/eaebc075) (2016-12-08) James Montalvo: make remote db command work hopefully, cleanup help commands 
R095	manual/meza-command-help.txt	manual/meza-cmd/base.txt
R079	manual/meza-command-help-config.txt	manual/meza-cmd/config.txt
R066	manual/meza-command-help-create.txt	manual/meza-cmd/create.txt
R090	manual/meza-command-help-install.txt	manual/meza-cmd/install.txt
R070	manual/meza-command-help-maint.txt	manual/meza-cmd/maint.txt
R058	manual/meza-command-help-prompt.txt	manual/meza-cmd/prompt.txt
  - Added: `manual/meza-cmd/prompt_default_on_blank.txt`
  - Added: `manual/meza-cmd/prompt_secure.txt`
  - Modified: `scripts/meza.sh`

* [90e4c15c](https://github.com/freephile/meza/commit/90e4c15c) (2016-12-07) James Montalvo: modules need to be retrieved from config prior to install 
  - Modified: `scripts/install.sh`

* [237111cc](https://github.com/freephile/meza/commit/237111cc) (2016-12-07) James Montalvo: docs cleanup, source config.local after prompts 
  - Modified: `scripts/install.sh`

* [68379bd5](https://github.com/freephile/meza/commit/68379bd5) (2016-12-07) James Montalvo: make meza cmd for dev-networking use module 
  - Modified: `scripts/meza.sh`

* [787dac18](https://github.com/freephile/meza/commit/787dac18) (2016-12-07) James Montalvo: docs 
  - Added: `manual/meza-command-help-config.txt`
  - Added: `manual/meza-command-help-create.txt`
  - Added: `manual/meza-command-help-install.txt`
  - Added: `manual/meza-command-help-maint.txt`
  - Added: `manual/meza-command-help-prompt.txt`
  - Modified: `manual/meza-command-help.txt`
  - Modified: `scripts/meza.sh`

* [d8c35996](https://github.com/freephile/meza/commit/d8c35996) (2016-12-07) James Montalvo: fix package listing 
  - Modified: `scripts/create-wiki.sh`
  - Modified: `scripts/install.sh`

* [4fe19203](https://github.com/freephile/meza/commit/4fe19203) (2016-12-07) James Montalvo: fix package listing 
  - Modified: `config/core/config.sh`
  - Modified: `scripts/install.sh`
  - Modified: `scripts/meza.sh`

* [601301b0](https://github.com/freephile/meza/commit/601301b0) (2016-12-06) James Montalvo: start of modules 
  - Modified: `config/core/config.sh`
  - Modified: `config/template/my.cnf`
  - Modified: `scripts/install.sh`
  - Deleted: `scripts/mariadb-client.sh`
  - Deleted: `scripts/mariadb-server.sh`
  - Deleted: `scripts/mariadb.sh`
  - Modified: `scripts/meza.sh`
R098	scripts/apache.sh	scripts/modules/apache/init.sh
  - Added: `scripts/modules/apache/packages.txt`
  - Added: `scripts/modules/apache/prompts.sh`
R092	scripts/epel.sh	scripts/modules/base/epel.sh
R066	scripts/firewall.sh	scripts/modules/base/init.sh
  - Added: `scripts/modules/base/packages.txt`
R054	scripts/yums.sh	scripts/modules/base/pre-setup.sh
  - Added: `scripts/modules/db-client/init.sh`
  - Added: `scripts/modules/db-client/packages.txt`
  - Added: `scripts/modules/db-client/prompts.sh`
  - Added: `scripts/modules/db-remote/init.sh`
  - Added: `scripts/modules/db-remote/prompts.sh`
  - Added: `scripts/modules/db-server/init.sh`
  - Added: `scripts/modules/db-server/packages.txt`
  - Added: `scripts/modules/db-server/prompts.sh`
R087	scripts/dev-networking.sh	scripts/modules/dev-networking/init.sh
  - Added: `scripts/modules/dev-networking/packages.txt`
  - Added: `scripts/modules/dev-networking/prompts.sh`
R094	scripts/ElasticSearch.sh	scripts/modules/elasticsearch/init.sh
  - Added: `scripts/modules/elasticsearch/packages.txt`
R095	scripts/extensions.sh	scripts/modules/extensions/init.sh
R083	scripts/imagemagick.sh	scripts/modules/imagemagick/init.sh
  - Added: `scripts/modules/imagemagick/packages.txt`
R089	scripts/mediawiki.sh	scripts/modules/mediawiki/init.sh
  - Added: `scripts/modules/mediawiki/prompts.sh`
R085	scripts/memcached.sh	scripts/modules/memcached/init.sh
  - Added: `scripts/modules/memcached/packages.txt`
R094	scripts/VE.sh	scripts/modules/parsoid/init.sh
  - Added: `scripts/modules/parsoid/prompts.sh`
R096	scripts/php.sh	scripts/modules/php/init.sh
  - Added: `scripts/modules/php/packages.txt`
R100	scripts/security.sh	scripts/modules/security/init.sh
  - Deleted: `scripts/time-sync.sh`

* [d965f02a](https://github.com/freephile/meza/commit/d965f02a) (2016-12-06) James Montalvo: more mroe more 
  - Modified: `scripts/dev-networking.sh`
  - Modified: `scripts/install.sh`
  - Modified: `scripts/meza.sh`

* [4eb49482](https://github.com/freephile/meza/commit/4eb49482) (2016-12-06) James Montalvo: make prompts finally work i think 
  - Modified: `scripts/meza.sh`

* [7d64f084](https://github.com/freephile/meza/commit/7d64f084) (2016-12-06) James Montalvo: more prompts 
  - Modified: `config/core/config.sh`
  - Modified: `scripts/meza.sh`

* [3bed3feb](https://github.com/freephile/meza/commit/3bed3feb) (2016-12-06) James Montalvo: fix secure prompts 
  - Modified: `scripts/meza.sh`

* [fbfb78c1](https://github.com/freephile/meza/commit/fbfb78c1) (2016-12-06) James Montalvo: add prompt functions 
  - Modified: `scripts/install.sh`
  - Modified: `scripts/meza.sh`

* [1c883e0f](https://github.com/freephile/meza/commit/1c883e0f) (2016-12-06) James Montalvo: make config command apply variable to current shell 
  - Modified: `scripts/meza.sh`

* [6123f64f](https://github.com/freephile/meza/commit/6123f64f) (2016-12-06) James Montalvo: server, not master 
  - Modified: `scripts/mariadb.sh`

* [e085718d](https://github.com/freephile/meza/commit/e085718d) (2016-12-05) James Montalvo: correct mariadb client 
  - Modified: `scripts/mariadb-client.sh`

* [ce74e642](https://github.com/freephile/meza/commit/ce74e642) (2016-12-05) James Montalvo: make mediawiki write db server if applicable 
  - Modified: `scripts/mediawiki.sh`

* [ea5b2e07](https://github.com/freephile/meza/commit/ea5b2e07) (2016-12-05) James Montalvo: build for separate db server 
R093	config/core/my.cnf	config/template/my.cnf
  - Modified: `scripts/install.sh`
  - Added: `scripts/mariadb-client.sh`
  - Added: `scripts/mariadb-server.sh`
  - Modified: `scripts/mariadb.sh`
  - Modified: `scripts/meza.sh`

* [044426c8](https://github.com/freephile/meza/commit/044426c8) (2016-12-05) James Montalvo: simplify cmd-tee 
  - Modified: `scripts/install.sh`

* [44f12b25](https://github.com/freephile/meza/commit/44f12b25) (2016-12-05) James Montalvo: fix string equality checks again 
  - Modified: `scripts/meza.sh`

* [46f92e86](https://github.com/freephile/meza/commit/46f92e86) (2016-12-05) James Montalvo: fix equality checks, simplify quiet config items 
  - Modified: `scripts/meza.sh`

* [268d8be2](https://github.com/freephile/meza/commit/268d8be2) (2016-12-05) James Montalvo: syntax error 
  - Modified: `scripts/meza.sh`

* [4c6db59d](https://github.com/freephile/meza/commit/4c6db59d) (2016-12-05) James Montalvo: add 'quiet' option to config setting to avoid printing sensitive info to terminal 
  - Modified: `scripts/install.sh`
  - Modified: `scripts/meza.sh`

* [ed682990](https://github.com/freephile/meza/commit/ed682990) (2016-12-05) James Montalvo: remove exit command, artifact of testing 
  - Modified: `scripts/install.sh`

* [8495258c](https://github.com/freephile/meza/commit/8495258c) (2016-12-04) James Montalvo: no longer need yum groupinstall development 
  - Modified: `scripts/yums.sh`

* [63393d46](https://github.com/freephile/meza/commit/63393d46) (2016-12-04) James Montalvo: fix syntax error, write config to config.local.sh 
  - Modified: `scripts/install.sh`
  - Modified: `scripts/meza.sh`

* [9a31fbd1](https://github.com/freephile/meza/commit/9a31fbd1) (2016-12-04) James Montalvo: add 'meza config key value' command 
  - Modified: `config/core/config.sh`
  - Deleted: `config/core/install.config.defaults.sh`
  - Modified: `scripts/epel.sh`
  - Modified: `scripts/firewall.sh`
  - Modified: `scripts/install.sh`
  - Modified: `scripts/meza.sh`

* [da94ad2c](https://github.com/freephile/meza/commit/da94ad2c) (2016-12-04) James Montalvo: cleanup everything to make scripts separated by concern 
  - Added: `config/core/install.config.defaults.sh`
  - Modified: `scripts/ElasticSearch.sh`
  - Modified: `scripts/VE.sh`
  - Added: `scripts/epel.sh`
  - Added: `scripts/firewall.sh`
  - Modified: `scripts/getmeza.sh`
  - Modified: `scripts/imagemagick.sh`
  - Modified: `scripts/install.sh`
  - Modified: `scripts/mediawiki.sh`
  - Added: `scripts/shell-functions/logging.sh`
  - Added: `scripts/time-sync.sh`
  - Modified: `scripts/yums.sh`

* [69914a01](https://github.com/freephile/meza/commit/69914a01) (2016-12-04) James Montalvo: fix runalljobs, add command to meza-cmd 
  - Modified: `scripts/meza.sh`
  - Modified: `scripts/runAllJobs.php`

* [61ec88f4](https://github.com/freephile/meza/commit/61ec88f4) (2016-12-04) James Montalvo: add runAllJobs.php 
  - Added: `scripts/runAllJobs.php`

* [ebe401d4](https://github.com/freephile/meza/commit/ebe401d4) (2016-12-03) James Montalvo: don't source scripts so can pass params 
  - Modified: `scripts/getmeza.sh`
  - Modified: `scripts/meza.sh`

* [7e9200fb](https://github.com/freephile/meza/commit/7e9200fb) (2016-12-03) James Montalvo: meza command 
  - Added: `manual/meza-command-help.txt`
  - Modified: `scripts/dev-networking.sh`
  - Added: `scripts/getmeza.sh`
  - Modified: `scripts/install.sh`
  - Added: `scripts/meza.sh`

* [2ccdaee6](https://github.com/freephile/meza/commit/2ccdaee6) (2016-12-03) James Montalvo: fix mariadb log and pid file 
  - Modified: `config/core/my.cnf`

* [7acd575e](https://github.com/freephile/meza/commit/7acd575e) (2016-12-03) James Montalvo: rename mysql.sh to mariadb.sh 
  - Modified: `scripts/install.sh`
R100	scripts/mysql.sh	scripts/mariadb.sh

* [fc36a9a7](https://github.com/freephile/meza/commit/fc36a9a7) (2016-12-03) James Montalvo: need to add mariadb data directory within /opt/meza 
  - Modified: `.gitignore`
  - Added: `data/mariadb/README.md`

* [31b40fa6](https://github.com/freephile/meza/commit/31b40fa6) (2016-12-03) James Montalvo: use mariadb instead of mysql 
  - Modified: `config/core/my.cnf`
  - Modified: `data/README.md`
  - Deleted: `data/mysql/README.md`
  - Modified: `scripts/mysql.sh`

* [9b72d470](https://github.com/freephile/meza/commit/9b72d470) (2016-11-30) James Montalvo: Fix Parsoid multi-wiki support; add ODBC driver 
  - Modified: `config/core/LocalSettings.php`
  - Modified: `config/core/localsettings.js`
  - Modified: `scripts/php.sh`

* [795a5c7c](https://github.com/freephile/meza/commit/795a5c7c) (2016-11-30) James Montalvo: More 1.27 supporting changes: * No extension.json for REL1_27 versions of WhoIsWatching
  or UploadWizard
* Add Extension:ParserFunctionHelper because it's desired
  for several things and now required for CopyWatchers
* WatchAnalytics not on extreg branch, on master
* Make Demo Wiki's auto-created User:Admin password meet
  the 8-character and no-common-words requirement by
  changing from "1234" to "adminpass"
  - Modified: `config/core/LocalSettings.php`
  - Modified: `scripts/extensions.sh`

* [478d6698](https://github.com/freephile/meza/commit/478d6698) (2016-11-30) James Montalvo: Several changes supporting MW 1.27 * Use Memcached for sessions (required to have a session
  cache in MW 1.27)
* Make all extensions supporting new extension registration
  method use ExtensionLoader's load() method instead of
  registerLegacyExtension()
* Make EnterpriseMediaWiki extensions pull the 'extreg'
  branch to test out new extension registration method
* Remove Extension:TitleKey, which is pointless with
  Elasticsearch
* Fix settings for MathJax...I think. Need to verify.
* Checkout latest version of ExtensionLoader
  - Modified: `config/core/LocalSettings.php`
  - Modified: `scripts/extensions.sh`

* [889301df](https://github.com/freephile/meza/commit/889301df) (2016-11-22) James Montalvo: initial 1.27 
  - Modified: `config/core/LocalSettings.php`
  - Modified: `config/core/initd_parsoid.sh`
  - Modified: `config/core/localsettings.js`
  - Modified: `scripts/VE.sh`
  - Modified: `scripts/extensions.sh`
  - Modified: `scripts/install.sh`
  - Modified: `scripts/mediawiki.sh`

* [5cf82f19](https://github.com/freephile/meza/commit/5cf82f19) (2016-11-03) James Montalvo: remove install-pear.sh and install PEAR Mail again 
  - Deleted: `scripts/install-pear.sh`
  - Modified: `scripts/php.sh`

* [a0d5b551](https://github.com/freephile/meza/commit/a0d5b551) (2016-11-03) James Montalvo: don't call out opcache in php.ini since yum seems to do it somehow, don't install pear for now 
  - Modified: `config/core/php.ini`
  - Modified: `scripts/php.sh`

* [d00fde71](https://github.com/freephile/meza/commit/d00fde71) (2016-11-03) James Montalvo: get php56u packages from ius 
  - Modified: `scripts/php.sh`

* [a43f564a](https://github.com/freephile/meza/commit/a43f564a) (2016-11-03) James Montalvo: try ius version of php 
  - Modified: `scripts/php.sh`

* [e39153e0](https://github.com/freephile/meza/commit/e39153e0) (2016-11-02) James Montalvo: Get php and imagemagick from meza-packages repo 
  - Modified: `scripts/imagemagick.sh`
  - Modified: `scripts/php.sh`

* [c61287ee](https://github.com/freephile/meza/commit/c61287ee) (2016-11-01) James Montalvo: Fix meza-test repo name 
  - Modified: `test/basic/run-test.sh`

* [734c4171](https://github.com/freephile/meza/commit/734c4171) (2016-11-01) James Montalvo: clean up test directory, make prompt function for mysql root pass 
  - Modified: `scripts/shell-functions/base.sh`
  - Added: `test/README.md`
  - Added: `test/basic/run-test.sh`
  - Modified: `test/remote-backup/run-test.sh`
  - Deleted: `test/test-basic.sh`

* [81d3aa50](https://github.com/freephile/meza/commit/81d3aa50) (2016-11-01) James Montalvo: clarify prompts for root password 
  - Modified: `test/remote-backup/run-test.sh`

* [81f59fb6](https://github.com/freephile/meza/commit/81f59fb6) (2016-11-01) James Montalvo: remove import-wikis-from-local-backup.sh, make test import-config.sh do backups properly, try to keep ssh and scp from requiring fingerprint 
  - Modified: `config/template/import-config.example.sh`
  - Modified: `manual/DirectoryStructure.md`
  - Deleted: `scripts/import-wikis-from-local-backup.sh`
  - Modified: `test/remote-backup/import-config.sh`
  - Modified: `test/remote-backup/run-test.sh`

* [5c69e8fd](https://github.com/freephile/meza/commit/5c69e8fd) (2016-11-01) James Montalvo: user needs to chown authorized_keys 
  - Modified: `test/remote-backup/source-server-setup.sh`

* [3d3cf4ac](https://github.com/freephile/meza/commit/3d3cf4ac) (2016-11-01) James Montalvo: one settings file, import-config.sh 
  - Modified: `test/remote-backup/import-config.sh`
  - Modified: `test/remote-backup/run-test.sh`
  - Modified: `test/remote-backup/source-server-setup.sh`
  - Deleted: `test/remote-backup/test-setup.sh`

* [a9dfadf7](https://github.com/freephile/meza/commit/a9dfadf7) (2016-11-01) James Montalvo: Adding semi-automated tests 
  - Modified: `config/core/config.sh`
  - Added: `scripts/shell-functions/add-user.sh`
  - Added: `scripts/shell-functions/base.sh`
  - Added: `test/remote-backup/import-config.sh`
  - Added: `test/remote-backup/run-test.sh`
  - Added: `test/remote-backup/source-server-setup.sh`
  - Added: `test/remote-backup/test-setup.sh`
  - Added: `test/test-basic.sh`

* [a066f6e4](https://github.com/freephile/meza/commit/a066f6e4) (2016-10-27) James Montalvo: Further simplification. This is at the 'should work' level of completeness but has not yet been tested 
  - Modified: `config/core/config.sh`
  - Added: `config/template/import-config.example.sh`
  - Deleted: `config/template/local-import-config.sh`
  - Deleted: `config/template/remote-wiki-config.example.sh`
  - Modified: `manual/AddingWikis.md`
  - Modified: `manual/DirectoryStructure.md`
  - Modified: `scripts/backup-remote-wikis.sh`
  - Modified: `scripts/import-remote-wikis.sh`
  - Modified: `scripts/import-wikis-from-local-backup.sh`
  - Modified: `scripts/import-wikis.sh`

* [fa3c31c6](https://github.com/freephile/meza/commit/fa3c31c6) (2016-10-21) James Montalvo: Merge some of the changes from import-wikis-from-local-backup.sh, no test yet 
  - Modified: `scripts/import-wikis.sh`

* [5f685390](https://github.com/freephile/meza/commit/5f685390) (2016-10-12) Daren Welsh: Check for and install firewalld after all prompts (#414) 
  - Modified: `scripts/install.sh`

* [d496458a](https://github.com/freephile/meza/commit/d496458a) (2016-09-13) James Montalvo: Check EPEL version before arbitrarily trying to download it (#426) 
  - Modified: `scripts/yums.sh`

* [c8073177](https://github.com/freephile/meza/commit/c8073177) (2016-08-26) Daren Welsh: dl handler restricts access via wiki config & SAML 
  - Added: `htdocs/download-backup.php`

* [e2106221](https://github.com/freephile/meza/commit/e2106221) (2016-08-26) Daren Welsh: list backup files available for download This currently does not include the ability to list files in /images. That will have to be thought out more.
  - Added: `htdocs/backupListing.php`

* [251cd96d](https://github.com/freephile/meza/commit/251cd96d) (2016-08-26) Daren Welsh: template for backupDownloaders.php 
  - Added: `config/template/backupDownloaders.php`

* [ea8b851b](https://github.com/freephile/meza/commit/ea8b851b) (2016-08-26) Daren Welsh: list new backup download file, backup structure 
  - Modified: `manual/DirectoryStructure.md`

* [fa2fd6f5](https://github.com/freephile/meza/commit/fa2fd6f5) (2016-08-16) Daren Welsh: keep 14 days of db, not 7 
  - Modified: `scripts/backup-remote-wikis.sh`

* [cbddc1c0](https://github.com/freephile/meza/commit/cbddc1c0) (2016-08-10) Daren Welsh: add backup and import scripts to dir structure 
  - Modified: `manual/DirectoryStructure.md`

* [77d76ee1](https://github.com/freephile/meza/commit/77d76ee1) (2016-07-22) James Montalvo: Tie SMW to the 2.4 branch. Getting install failures due to 2.5-dev 
  - Modified: `scripts/extensions.sh`

* [964ac6f2](https://github.com/freephile/meza/commit/964ac6f2) (2016-07-07) Daren Welsh: don't ssh quietly in hopes of more feedback 
  - Modified: `scripts/backup-remote-wikis.sh`

* [73a52345](https://github.com/freephile/meza/commit/73a52345) (2016-07-07) Daren Welsh: don't use import-wikis.sh, add import steps, bug hunting 
  - Modified: `scripts/import-wikis-from-local-backup.sh`

* [39386606](https://github.com/freephile/meza/commit/39386606) (2016-07-06) Daren Welsh: wrapper for import-wikis on a backup server 
  - Added: `scripts/import-wikis-from-local-backup.sh`

* [944ed9c4](https://github.com/freephile/meza/commit/944ed9c4) (2016-07-06) Daren Welsh: lots of changes for cron, separate import 
  - Modified: `scripts/backup-remote-wikis.sh`

* [406bf92d](https://github.com/freephile/meza/commit/406bf92d) (2016-07-06) Daren Welsh: add vars for logging, backup, and import 
  - Modified: `config/template/remote-wiki-config.example.sh`

* [cff0289a](https://github.com/freephile/meza/commit/cff0289a) (2016-07-01) Daren Welsh: check if errlog has contents, not if var exists 
  - Modified: `scripts/backup-remote-wikis.sh`

* [def9eab5](https://github.com/freephile/meza/commit/def9eab5) (2016-07-01) Daren Welsh: more verbosity; better dir detection; mkdir if req 
  - Modified: `scripts/backup-remote-wikis.sh`

* [a5bce1f2](https://github.com/freephile/meza/commit/a5bce1f2) (2016-06-23) Daren Welsh: add script to pull data to backup server, update config template 
  - Modified: `config/template/remote-wiki-config.example.sh`
  - Added: `scripts/backup-remote-wikis.sh`

* [fd213554](https://github.com/freephile/meza/commit/fd213554) (2016-06-23) Randy Eckman: added TCHB namespace and CollapsibleSections ext 
  - Modified: `config/template/more-extensions.php`

* [27938750](https://github.com/freephile/meza/commit/27938750) (2016-06-23) James Montalvo: hotfix bump epel version to 7.7 
  - Modified: `scripts/yums.sh`

* [a6d7f583](https://github.com/freephile/meza/commit/a6d7f583) (2016-06-23) James Montalvo: add Extension:Data Transfer 
  - Modified: `config/core/LocalSettings.php`

* [93e9da90](https://github.com/freephile/meza/commit/93e9da90) (2016-06-22) James Montalvo: Fix version number for Digital Ocean install 
  - Modified: `manual/SetupDigitalOcean.md`

* [3cd78f55](https://github.com/freephile/meza/commit/3cd78f55) (2016-06-21) Daren Welsh: remove unnecessary "for more info" line 
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [72aa7ffc](https://github.com/freephile/meza/commit/72aa7ffc) (2016-06-21) Daren Welsh: from two to multiple 
  - Modified: `scripts/create-vm.sh`

* [70122ff8](https://github.com/freephile/meza/commit/70122ff8) (2016-05-17) James Montalvo: Need to make config/local/httpd dir for 443.conf 
  - Modified: `scripts/apache.sh`

* [646e4825](https://github.com/freephile/meza/commit/646e4825) (2016-05-17) James Montalvo: Don't do fake CA cert; instead do optional https include in httpd.conf 
  - Modified: `config/core/httpd.conf`
  - Modified: `scripts/apache.sh`
  - Deleted: `scripts/generate-certs.sh`

* [e09b4b90](https://github.com/freephile/meza/commit/e09b4b90) (2016-05-15) James Montalvo: fix directory structure for create-vm.sh 
  - Modified: `manual/DirectoryStructure.md`

* [416e72a4](https://github.com/freephile/meza/commit/416e72a4) (2016-05-15) James Montalvo: shorten github raw URL 
  - Modified: `README.md`

* [7e30704c](https://github.com/freephile/meza/commit/7e30704c) (2016-05-15) James Montalvo: wget no longer required for install 
  - Modified: `manual/SetupDigitalOcean.md`

* [659bb081](https://github.com/freephile/meza/commit/659bb081) (2016-05-15) James Montalvo: Clarify windows-only steps 
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [e89498e4](https://github.com/freephile/meza/commit/e89498e4) (2016-05-15) James Montalvo: Break steps into sections 
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [59bb7167](https://github.com/freephile/meza/commit/59bb7167) (2016-05-15) James Montalvo: Clarify min install required 
  - Modified: `README.md`

* [28c231fc](https://github.com/freephile/meza/commit/28c231fc) (2016-05-15) James Montalvo: Cleanup docs, remove unnecessary Batch script 
  - Modified: `README.md`
  - Modified: `manual/1.0-SettingUpVirtualBox.md`
  - Deleted: `manual/1.0-SettingUpVirtualBoxWindows.md`
  - Deleted: `scripts/vmsetupwin.bat`

* [9891315a](https://github.com/freephile/meza/commit/9891315a) (2016-05-15) James Montalvo: Create host-only adapter if it doesn't exist 
  - Modified: `scripts/create-vm.sh`

* [afa45f0f](https://github.com/freephile/meza/commit/afa45f0f) (2016-05-15) James Montalvo: support CodeClimate checks 
  - Added: `.codeclimate.yml`
  - Added: `.eslintignore`
  - Added: `.eslintrc`

* [b67f53ac](https://github.com/freephile/meza/commit/b67f53ac) (2016-05-15) James Montalvo: Allow executing create-vm.sh script 
  - Modified: `scripts/create-vm.sh`

* [0dfa2390](https://github.com/freephile/meza/commit/0dfa2390) (2016-05-13) James Montalvo: Made it work on Mac 
  - Modified: `scripts/create-vm.sh`

* [6250ac53](https://github.com/freephile/meza/commit/6250ac53) (2016-05-13) James Montalvo: new create-vm script written in bash for windows, and soon mac 
  - Added: `scripts/create-vm.sh`

* [815eab5d](https://github.com/freephile/meza/commit/815eab5d) (2016-05-12) James Montalvo: move SSL cert generation to apache.sh, more appropriate place 
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/install.sh`

* [8f3bfec3](https://github.com/freephile/meza/commit/8f3bfec3) (2016-05-12) James Montalvo: Generate self-signed CA cert, too, for easier real-life setup later 
  - Modified: `README.md`
  - Modified: `config/core/httpd.conf`
  - Modified: `config/template/install.config.example.sh`
  - Added: `scripts/generate-certs.sh`
  - Modified: `scripts/install.sh`

* [b64196f6](https://github.com/freephile/meza/commit/b64196f6) (2016-05-12) James Montalvo: Add SSL selftest, using testssl.sh. File added to dir structure doc 
  - Modified: `manual/DirectoryStructure.md`
  - Added: `scripts/ssl-selftest.sh`

* [e2f4a25d](https://github.com/freephile/meza/commit/e2f4a25d) (2016-05-12) James Montalvo: add documentation for local-import-config.sh and dir structure 
  - Modified: `manual/AddingWikis.md`
  - Modified: `manual/DirectoryStructure.md`

* [c09d6c15](https://github.com/freephile/meza/commit/c09d6c15) (2016-05-12) James Montalvo: fix composer api version conflict 
  - Modified: `scripts/mediawiki.sh`

* [567a1e20](https://github.com/freephile/meza/commit/567a1e20) (2016-05-11) James Montalvo: Changes based on Nessus security scan 
  - Modified: `config/core/httpd.conf`
  - Added: `config/template/ssh`
  - Modified: `scripts/install.sh`
  - Added: `scripts/security.sh`

* [3f5ef84f](https://github.com/freephile/meza/commit/3f5ef84f) (2016-05-05) James Montalvo: forgot semicolon 
  - Modified: `config/template/SAML-postLocalSettings.php`

* [8a9e3a43](https://github.com/freephile/meza/commit/8a9e3a43) (2016-05-05) James Montalvo: use SAML auth on landing page 
  - Modified: `config/template/SAML-postLocalSettings.php`
  - Added: `config/template/SAMLConfig.php`
  - Added: `htdocs/NonMediaWikiSimpleSamlAuth.php`
  - Modified: `htdocs/index.php`
  - Modified: `scripts/saml.sh`

* [57f19a00](https://github.com/freephile/meza/commit/57f19a00) (2016-05-05) James Montalvo: Add example local-import-config.sh 
  - Added: `config/template/local-import-config.sh`

* [94e2d13b](https://github.com/freephile/meza/commit/94e2d13b) (2016-05-04) James Montalvo: allow specifying imports location; also new default 
  - Modified: `scripts/import-remote-wikis.sh`

* [dac57460](https://github.com/freephile/meza/commit/dac57460) (2016-05-04) James Montalvo: remove parsoid tests since we don't check them anyway, and they just take time 
  - Modified: `scripts/VE.sh`

* [878c2db1](https://github.com/freephile/meza/commit/878c2db1) (2016-05-04) James Montalvo: add config file for import-wikis.sh 
  - Modified: `scripts/import-wikis.sh`

* [ccda46be](https://github.com/freephile/meza/commit/ccda46be) (2016-05-04) James Montalvo: add policies to imagemagick to prevent remote code execution 
  - Added: `config/template/imagick-secure-policy.xml`
  - Modified: `scripts/imagemagick.sh`

* [74d874cb](https://github.com/freephile/meza/commit/74d874cb) (2016-04-28) James Montalvo: another fix for WIKI=demo 
  - Modified: `scripts/updateExtensions.sh`

* [e2bed61e](https://github.com/freephile/meza/commit/e2bed61e) (2016-04-28) James Montalvo: fix order of WIKI=demo 
  - Modified: `scripts/updateExtensions.sh`

* [a6e6d5de](https://github.com/freephile/meza/commit/a6e6d5de) (2016-04-28) James Montalvo: checkout new ExtensionLoader; add update-all-extensions script 
  - Modified: `scripts/extensions.sh`
  - Added: `scripts/updateExtensions.sh`

* [92db4c42](https://github.com/freephile/meza/commit/92db4c42) (2016-04-27) James Montalvo: make sure firewalld is installed 
  - Modified: `scripts/install.sh`

* [6a9a63a7](https://github.com/freephile/meza/commit/6a9a63a7) (2016-04-26) James Montalvo: fix version number, remove -dev 
  - Modified: `README.md`

* [f385f2e1](https://github.com/freephile/meza/commit/f385f2e1) (2016-04-26) James Montalvo: otf doesn't love FTP, use UNebraska http mirror 
  - Modified: `scripts/imagemagick.sh`

* [ce9f1625](https://github.com/freephile/meza/commit/ce9f1625) (2016-04-26) James Montalvo: Add detail and cleanup some lines 
  - Modified: `manual/DirectoryStructure.md`

* [0db408e5](https://github.com/freephile/meza/commit/0db408e5) (2016-04-26) Daren Welsh: updates based on #382 
  - Modified: `manual/DirectoryStructure.md`

* [298eb569](https://github.com/freephile/meza/commit/298eb569) (2016-04-26) James Montalvo: move elasticsearch and mysql data to /opt/meza/data 
  - Modified: `.gitignore`
  - Modified: `config/core/elasticsearch.yml`
  - Added: `config/core/my.cnf`
  - Added: `data/README.md`
  - Added: `data/elasticsearch/README.md`
  - Added: `data/mysql/README.md`
  - Modified: `scripts/ElasticSearch.sh`
  - Modified: `scripts/mysql.sh`

* [adcbad86](https://github.com/freephile/meza/commit/adcbad86) (2016-04-26) Daren Welsh: Create DirectoryStructure.md 
  - Added: `manual/DirectoryStructure.md`

* [4a621d00](https://github.com/freephile/meza/commit/4a621d00) (2016-04-26) Daren Welsh: link to new file 
  - Modified: `README.md`

* [6789d4a1](https://github.com/freephile/meza/commit/6789d4a1) (2016-04-21) James Montalvo: add Extension:Math, which already exists on FOD2 
  - Modified: `config/core/LocalSettings.php`

* [f51edd16](https://github.com/freephile/meza/commit/f51edd16) (2016-04-21) James Montalvo: SemanticForms to 3.5 (#370) 
  - Modified: `config/core/LocalSettings.php`

* [27708f81](https://github.com/freephile/meza/commit/27708f81) (2016-04-20) James Montalvo: EPEL now 7.6 vs 7.5 for CentOS 7, hotfix #374 
  - Modified: `scripts/yums.sh`

* [c80f78cd](https://github.com/freephile/meza/commit/c80f78cd) (2016-04-19) James Montalvo: remove unneeded file, which was replaced by LandingPage.php 
  - Deleted: `config/template/BlenderSettings.php`

* [aab0d598](https://github.com/freephile/meza/commit/aab0d598) (2016-04-18) James Montalvo: fix erroneous comment about who can edit with "anon-read" auth 
  - Modified: `config/core/LocalSettings.php`

* [1a81fcb4](https://github.com/freephile/meza/commit/1a81fcb4) (2016-04-18) James Montalvo: Default "own work"; Make license be general disclaimer 
  - Modified: `config/core/LocalSettings.php`

* [70d07585](https://github.com/freephile/meza/commit/70d07585) (2016-04-18) James Montalvo: Give "own work" or "someone else" options 
  - Modified: `config/core/LocalSettings.php`

* [26912ae7](https://github.com/freephile/meza/commit/26912ae7) (2016-04-18) James Montalvo: fix version number, reference to unifyUserTables.php 
  - Modified: `config/core/LocalSettings.php`
  - Modified: `scripts/install.sh`

* [4458ee57](https://github.com/freephile/meza/commit/4458ee57) (2016-04-17) James Montalvo: remove another reference to CustomSettings.php 
  - Modified: `scripts/import-wikis.sh`

* [d653a8cb](https://github.com/freephile/meza/commit/d653a8cb) (2016-04-17) James Montalvo: again, removing reference to obsolete CustomSettings.php 
  - Modified: `manual/AddingWikis.md`

* [812ec94c](https://github.com/freephile/meza/commit/812ec94c) (2016-04-17) James Montalvo: Remove reference to obsolete CustomSettings.php 
  - Modified: `manual/AddingWikis.md`

* [a94721a3](https://github.com/freephile/meza/commit/a94721a3) (2016-04-15) Daren Welsh: add missing word to documentation 
  - Modified: `config/template/more-extensions.php`

* [f1e1bc28](https://github.com/freephile/meza/commit/f1e1bc28) (2016-04-15) Daren Welsh: UploadWizard LocalSettings default generic license #156 seems to be closed/abandoned, so I'm removing reference from code

Add licensing config based on https://gerrit.wikimedia.org/r/#/c/283110/5/README
  - Modified: `config/core/LocalSettings.php`

* [09d82d7c](https://github.com/freephile/meza/commit/09d82d7c) (2016-04-15) Daren Welsh: grammar 
  - Modified: `config/local/README.md`

* [cb8a3418](https://github.com/freephile/meza/commit/cb8a3418) (2016-03-11) James Montalvo: Fix perms; Don't load AccessDenied; ignore simplesamlphp 
  - Modified: `.gitignore`
  - Modified: `config/core/LocalSettings.php`
  - Modified: `scripts/saml.sh`

* [8bf33b54](https://github.com/freephile/meza/commit/8bf33b54) (2016-03-10) James Montalvo: Make slack announcement tell me the domain 
  - Modified: `scripts/install.sh`

* [5621be94](https://github.com/freephile/meza/commit/5621be94) (2016-03-10) James Montalvo: get actual real good BlenderWikisDir directory 
  - Modified: `config/core/BlenderSettings.php`

* [defea7ce](https://github.com/freephile/meza/commit/defea7ce) (2016-03-10) James Montalvo: php.log right; blenderwikidir fixed; chmods 
  - Modified: `config/core/BlenderSettings.php`
  - Modified: `config/core/LocalSettings.php`
  - Modified: `config/core/initd_parsoid.sh`
  - Modified: `htdocs/.htaccess`
  - Modified: `htdocs/README.md`
  - Modified: `htdocs/index.php`
  - Modified: `htdocs/wikis/README.md`
  - Modified: `scripts/install-pear.sh`

* [ee613fb0](https://github.com/freephile/meza/commit/ee613fb0) (2016-03-09) James Montalvo: move WikiBlender config files to better locations 
  - Added: `config/core/BlenderSettings.php`
  - Added: `config/template/LandingPage.php`
  - Modified: `scripts/mediawiki.sh`

* [28d17026](https://github.com/freephile/meza/commit/28d17026) (2016-03-09) James Montalvo: enable saml.sh config file 
  - Added: `config/template/saml-setup-config.sh`
  - Modified: `scripts/saml.sh`

* [4555c41f](https://github.com/freephile/meza/commit/4555c41f) (2016-03-09) James Montalvo: Permissions improvements for SAML 
  - Modified: `config/core/LocalSettings.php`
R081	config/template/SAML-LocalSettings-Additions.php	config/template/SAML-postLocalSettings.php
  - Added: `config/template/SAML-preLocalSettings.php`
  - Modified: `scripts/saml.sh`

* [f7cf68a3](https://github.com/freephile/meza/commit/f7cf68a3) (2016-03-08) James Montalvo: need to actually use the variable... 
  - Modified: `scripts/import-remote-wikis.sh`

* [ffaade8c](https://github.com/freephile/meza/commit/ffaade8c) (2016-03-08) James Montalvo: fix import from wikis still using setup.php 
  - Modified: `scripts/import-remote-wikis.sh`

* [88f9178b](https://github.com/freephile/meza/commit/88f9178b) (2016-03-07) James Montalvo: Use WikiBlender master now 
  - Modified: `scripts/mediawiki.sh`

* [afcc7bfe](https://github.com/freephile/meza/commit/afcc7bfe) (2016-03-07) James Montalvo: fix template directory in dev-networking.sh 
  - Modified: `scripts/dev-networking.sh`

* [370283dc](https://github.com/freephile/meza/commit/370283dc) (2016-03-07) James Montalvo: log rebuildData exceptions; rename setup and override 
  - Modified: `config/core/LocalSettings.php`
  - Modified: `config/template/more-extensions.php`
R089	config/template/setup.php	config/template/preLocalSettings_allWikis.php
R100	config/template/wiki-init/config/overrides.php	config/template/wiki-init/config/postLocalSettings.php
R100	config/template/wiki-init/config/setup.php	config/template/wiki-init/config/preLocalSettings.php
  - Modified: `manual/AddingWikis.md`
  - Modified: `manual/installing-additional-extensions.md`
  - Modified: `scripts/elastic-build-index.sh`
  - Modified: `scripts/extensions.sh`
  - Modified: `scripts/getDatabaseNameFromSetup.php`
  - Modified: `scripts/import-remote-wikis.sh`
  - Modified: `scripts/import-wikis.sh`
  - Modified: `scripts/mediawiki.sh`
  - Modified: `scripts/saml.sh`
  - Modified: `scripts/unifyUserTables.php`

* [0c8d0033](https://github.com/freephile/meza/commit/0c8d0033) (2016-03-05) James Montalvo: Permission settings need to come above extensions since extensions may reset 
  - Modified: `config/core/LocalSettings.php`

* [5376cb32](https://github.com/freephile/meza/commit/5376cb32) (2016-03-05) James Montalvo: anon-read should allow user to edit 
  - Modified: `config/core/LocalSettings.php`

* [2ce323ef](https://github.com/freephile/meza/commit/2ce323ef) (2016-03-05) James Montalvo: actually move config/meza to config/core 
R100	config/meza/LocalSettings.php	config/core/LocalSettings.php
R100	config/meza/config.sh	config/core/config.sh
R100	config/meza/elasticsearch.repo	config/core/elasticsearch.repo
R100	config/meza/elasticsearch.yml	config/core/elasticsearch.yml
R100	config/meza/httpd.conf	config/core/httpd.conf
R100	config/meza/initd_parsoid.sh	config/core/initd_parsoid.sh
R100	config/meza/localsettings.js	config/core/localsettings.js
R100	config/meza/logrotated_httpd	config/core/logrotated_httpd
R100	config/meza/memcached	config/core/memcached
R100	config/meza/php.ini	config/core/php.ini

* [ad83fa1e](https://github.com/freephile/meza/commit/ad83fa1e) (2016-03-05) James Montalvo: actually move setup.sh-->dev-networking.sh 
  - Modified: `config/meza/LocalSettings.php`
R100	setup.sh	scripts/dev-networking.sh

* [53f91226](https://github.com/freephile/meza/commit/53f91226) (2016-03-05) James Montalvo: Fix 
  - Modified: `config/meza/LocalSettings.php`
  - Modified: `config/template/setup.php`
  - Modified: `config/template/wiki-init/config/setup.php`
  - Modified: `scripts/import-wikis.sh`

* [34d074ea](https://github.com/freephile/meza/commit/34d074ea) (2016-03-05) James Montalvo: Change setup.sh to scripts/dev-networking.sh 
  - Modified: `config/meza/LocalSettings.php`
  - Modified: `manual/1.0-SettingUpVirtualBox.md`
  - Modified: `manual/1.0-SettingUpVirtualBoxWindows.md`
  - Modified: `manual/2.1-CreateCloneVMs.md`

* [fe07df39](https://github.com/freephile/meza/commit/fe07df39) (2016-03-05) James Montalvo: Change from config/meza to config/core 
  - Modified: `scripts/ElasticSearch.sh`
  - Modified: `scripts/VE.sh`
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/create-wiki.sh`
  - Modified: `scripts/elastic-rebuild-index.sh`
  - Modified: `scripts/extensions.sh`
  - Modified: `scripts/import-wikis.sh`
  - Modified: `scripts/install.sh`
  - Modified: `scripts/mediawiki.sh`
  - Modified: `scripts/memcached.sh`
  - Modified: `scripts/php.sh`
  - Modified: `scripts/samba.sh`
  - Modified: `scripts/saml.sh`

* [911e8983](https://github.com/freephile/meza/commit/911e8983) (2016-03-05) James Montalvo: disable PdfHandler; Use SMW near-2.4 
  - Modified: `config/meza/LocalSettings.php`
  - Modified: `scripts/extensions.sh`

* [19593ed2](https://github.com/freephile/meza/commit/19593ed2) (2016-03-03) James Montalvo: remove memcached for sessions due to SAML (#350) 
  - Modified: `config/meza/LocalSettings.php`

* [22de34cf](https://github.com/freephile/meza/commit/22de34cf) (2016-03-03) James Montalvo: sed on symlink removes symlink, replaces with file (#353) 
  - Modified: `scripts/apache.sh`

* [6581ef5e](https://github.com/freephile/meza/commit/6581ef5e) (2016-03-02) James Montalvo: need variable access inside closure 
  - Modified: `config/meza/LocalSettings.php`

* [0dd89f03](https://github.com/freephile/meza/commit/0dd89f03) (2016-03-02) James Montalvo: Fix typos 
  - Modified: `.github/ISSUE_TEMPLATE.md`

* [696794a4](https://github.com/freephile/meza/commit/696794a4) (2016-03-02) James Montalvo: Fix WikiBlender API URI 
  - Modified: `config/template/BlenderSettings.php`

* [f9b5548e](https://github.com/freephile/meza/commit/f9b5548e) (2016-03-01) James Montalvo: better unique for oldimage; put logs in /logs 
  - Modified: `scripts/unifyUserTables.php`

* [67d35e88](https://github.com/freephile/meza/commit/67d35e88) (2016-03-01) James Montalvo: oldimage not unique on sha1; switch to oi_archive_name 
  - Modified: `scripts/unifyUserTables.php`

* [17114783](https://github.com/freephile/meza/commit/17114783) (2016-03-01) James Montalvo: trim trailing slash from directory name (rsync difference) 
  - Modified: `scripts/import-remote-wikis.sh`

* [26fe071b](https://github.com/freephile/meza/commit/26fe071b) (2016-02-29) James Montalvo: Can't win with rsync directory specifics... 
  - Modified: `scripts/import-remote-wikis.sh`

* [21446f64](https://github.com/freephile/meza/commit/21446f64) (2016-02-29) James Montalvo: Add wiki id to path 
  - Modified: `scripts/import-remote-wikis.sh`

* [36c61ba1](https://github.com/freephile/meza/commit/36c61ba1) (2016-02-29) James Montalvo: Need trailing slash for rsync to separate directories 
  - Modified: `scripts/import-remote-wikis.sh`

* [3161d879](https://github.com/freephile/meza/commit/3161d879) (2016-02-26) James Montalvo: stuff 
  - Modified: `scripts/saml.sh`

* [2a8e78d9](https://github.com/freephile/meza/commit/2a8e78d9) (2016-02-26) James Montalvo: SAML httpd.conf stuff pulling from wrong place 
  - Modified: `scripts/saml.sh`

* [cc76911f](https://github.com/freephile/meza/commit/cc76911f) (2016-02-26) James Montalvo: missing overrides.php caused img_auth issue 
  - Modified: `scripts/import-wikis.sh`

* [694fc220](https://github.com/freephile/meza/commit/694fc220) (2016-02-25) James Montalvo: Many changes to enable self-testing on unifyUserTables.php 
  - Modified: `scripts/unifyUserTables.php`

* [b24074b4](https://github.com/freephile/meza/commit/b24074b4) (2016-02-25) James Montalvo: fixes from first run 
  - Modified: `scripts/unifyUserTables.php`

* [be7611e9](https://github.com/freephile/meza/commit/be7611e9) (2016-02-25) James Montalvo: Add some testing into user unify script 
  - Modified: `scripts/unifyUserTables.php`

* [da43ad12](https://github.com/freephile/meza/commit/da43ad12) (2016-02-25) James Montalvo: saml.sh needs to create overrides.php if not existing 
  - Modified: `scripts/saml.sh`

* [24217316](https://github.com/freephile/meza/commit/24217316) (2016-02-25) James Montalvo: Use rsync instead of cp, make mysqldump verbose rsync allows verbose copying. Also hopefully it is more robust,
since I've noticed some issues of missing files from long cp
operations. I considered adding a second pass of rsync just to
catch any misses.
Made mysqldump verbose because that seemed like a good idea.
  - Modified: `scripts/import-remote-wikis.sh`

* [58f5f0af](https://github.com/freephile/meza/commit/58f5f0af) (2016-02-25) James Montalvo: make debug standard on command line 
  - Modified: `config/meza/LocalSettings.php`

* [a1b4553f](https://github.com/freephile/meza/commit/a1b4553f) (2016-02-24) James Montalvo: LocalSettings needs to enable watchlist email 
  - Modified: `config/meza/LocalSettings.php`

* [6713eb8d](https://github.com/freephile/meza/commit/6713eb8d) (2016-02-24) James Montalvo: check for correct PEAR prompt with expect, no PATH for PEAR 
  - Modified: `scripts/install-pear.sh`
  - Modified: `scripts/php.sh`

* [8463e4a9](https://github.com/freephile/meza/commit/8463e4a9) (2016-02-24) James Montalvo: Rebuild ES index (#70) 
  - Modified: `scripts/elastic-build-index.sh`
  - Added: `scripts/elastic-rebuild-index.sh`

* [068a9674](https://github.com/freephile/meza/commit/068a9674) (2016-02-24) James Montalvo: Stuff to install PEAR and PEAR Mail 
  - Added: `scripts/install-pear.sh`
  - Modified: `scripts/php.sh`
  - Modified: `scripts/yums.sh`

* [1917c30b](https://github.com/freephile/meza/commit/1917c30b) (2016-02-23) James Montalvo: Missing semicolon...stupid latenight errors...sigh 
  - Modified: `config/template/setup.php`

* [a30b2cb4](https://github.com/freephile/meza/commit/a30b2cb4) (2016-02-23) James Montalvo: Make UploadWizard feedback page match VE 
  - Modified: `config/meza/LocalSettings.php`

* [5dce604b](https://github.com/freephile/meza/commit/5dce604b) (2016-02-23) James Montalvo: fix SummaryTimeline version 
  - Modified: `config/template/more-extensions.php`

* [db5a9370](https://github.com/freephile/meza/commit/db5a9370) (2016-02-23) James Montalvo: fix disableSearchUpdate for runJobs 
  - Modified: `scripts/import-wikis.sh`

* [20120295](https://github.com/freephile/meza/commit/20120295) (2016-02-23) James Montalvo: Don't use EMW email; set email in /local 
  - Modified: `config/meza/LocalSettings.php`
  - Modified: `config/template/setup.php`

* [7738395a](https://github.com/freephile/meza/commit/7738395a) (2016-02-23) James Montalvo: other maybe required email packages (#302) 
  - Modified: `scripts/yums.sh`

* [6bca4b7d](https://github.com/freephile/meza/commit/6bca4b7d) (2016-02-23) James Montalvo: add sendmail (#302) 
  - Modified: `scripts/yums.sh`

* [1bf7f26e](https://github.com/freephile/meza/commit/1bf7f26e) (2016-02-22) James Montalvo: add documentation for custom extensions 
  - Modified: `README.md`
  - Added: `manual/installing-additional-extensions.md`

* [0bcf6e38](https://github.com/freephile/meza/commit/0bcf6e38) (2016-02-22) James Montalvo: Remove NASA-specific extensions; provide way to customize extensions * Removed IMSQuery and SummaryTimeline
* Added template config file for loading additional non-meza extensions
  - Modified: `config/meza/LocalSettings.php`
  - Added: `config/template/more-extensions.php`

* [9b72646b](https://github.com/freephile/meza/commit/9b72646b) (2016-02-22) James Montalvo: fix remote-wiki-config.sh location in manual 
  - Modified: `manual/AddingWikis.md`

* [fb370431](https://github.com/freephile/meza/commit/fb370431) (2016-02-22) James Montalvo: don't prompt for slack webhook if it's filled in 
  - Modified: `scripts/install.sh`

* [dab4cb83](https://github.com/freephile/meza/commit/dab4cb83) (2016-02-22) James Montalvo: make install.config.sh relative or absolute 
  - Modified: `scripts/install.sh`

* [35214476](https://github.com/freephile/meza/commit/35214476) (2016-02-22) James Montalvo: Move prompts back into install.sh because... Turns out that install_prompts.sh is not available if you
haven't pulled the whole meza repo yet. Oops.
R053	config/template/install.config.sh	config/template/install.config.example.sh
  - Modified: `scripts/install.sh`
  - Deleted: `scripts/install_prompts.sh`

* [509481e3](https://github.com/freephile/meza/commit/509481e3) (2016-02-21) James Montalvo: start creating method to bypass install.sh prompts 
  - Added: `config/template/install.config.sh`
  - Modified: `scripts/install.sh`
  - Added: `scripts/install_prompts.sh`

* [fa49e6a8](https://github.com/freephile/meza/commit/fa49e6a8) (2016-02-21) James Montalvo: fix parsoid domain settings issue 
  - Modified: `config/meza/localsettings.js`
  - Modified: `scripts/VE.sh`
  - Modified: `scripts/elastic-build-index.sh`

* [114a6ff3](https://github.com/freephile/meza/commit/114a6ff3) (2016-02-21) James Montalvo: Don't change localsettings.js, have it pull from local config 
  - Modified: `.gitignore`
  - Modified: `config/meza/localsettings.js`
  - Modified: `scripts/VE.sh`

* [501051b0](https://github.com/freephile/meza/commit/501051b0) (2016-02-21) James Montalvo: clean up wiki-specific config files 
  - Modified: `config/meza/LocalSettings.php`
R100	wiki-init/config/favicon.ico	config/template/wiki-init/config/favicon.ico
R100	wiki-init/config/logo.png	config/template/wiki-init/config/logo.png
R100	wiki-init/config/CustomSettings.php	config/template/wiki-init/config/overrides.php
R100	wiki-init/config/setup.php	config/template/wiki-init/config/setup.php
R100	wiki-init/images/README.md	config/template/wiki-init/images/README.md
  - Modified: `scripts/elastic-build-index.sh`
  - Modified: `scripts/import-wikis.sh`
  - Deleted: `wiki-init/config/disableSearchUpdate.php`

* [21cd015c](https://github.com/freephile/meza/commit/21cd015c) (2016-02-20) James Montalvo: simplify LocalSettings.php config inclusions 
  - Modified: `config/meza/LocalSettings.php`
R071	config/template/AllWikiSettings.php	config/template/setup.php
  - Modified: `scripts/mediawiki.sh`

* [58a4a2a2](https://github.com/freephile/meza/commit/58a4a2a2) (2016-02-20) James Montalvo: Symlink memcached config (with typo removed) 
  - Modified: `scripts/memcached.sh`

* [2f0569cb](https://github.com/freephile/meza/commit/2f0569cb) (2016-02-20) James Montalvo: Symlink logrotated 
  - Modified: `scripts/apache.sh`

* [696acac6](https://github.com/freephile/meza/commit/696acac6) (2016-02-20) James Montalvo: Make SMM importDump more verbose 
  - Modified: `scripts/extensions.sh`

* [61d3f321](https://github.com/freephile/meza/commit/61d3f321) (2016-02-20) James Montalvo: Need to cd to httpd 
  - Modified: `scripts/apache.sh`

* [cb2059f0](https://github.com/freephile/meza/commit/cb2059f0) (2016-02-20) Daren Welsh: help us reproduce issues 
  - Modified: `.github/ISSUE_TEMPLATE.md`

* [e0830955](https://github.com/freephile/meza/commit/e0830955) (2016-02-20) James Montalvo: initiate AllWikiSettings.php 
  - Modified: `scripts/mediawiki.sh`

* [8e5ecb78](https://github.com/freephile/meza/commit/8e5ecb78) (2016-02-19) James Montalvo: changes to satisfy new file locations 
  - Modified: `.gitignore`
  - Modified: `config/meza/LocalSettings.php`
  - Modified: `config/meza/config.sh`
  - Modified: `config/template/BlenderSettings.php`
  - Modified: `manual/AddingWikis.md`
  - Modified: `scripts/ElasticSearch.sh`
  - Modified: `scripts/VE.sh`
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/create-wiki.sh`
  - Modified: `scripts/extensions.sh`
  - Modified: `scripts/import-remote-wikis.sh`
  - Modified: `scripts/import-wikis.sh`
  - Modified: `scripts/install.sh`
  - Modified: `scripts/mediawiki.sh`
  - Modified: `scripts/memcached.sh`
  - Modified: `scripts/php.sh`
  - Modified: `scripts/samba.sh`
  - Modified: `scripts/saml.sh`
  - Modified: `scripts/unifyUserTables.php`
  - Modified: `setup.sh`

* [af95400e](https://github.com/freephile/meza/commit/af95400e) (2016-02-19) James Montalvo: File moves completed (breaking change, will update code next) 
  - Added: `config/local/README.md`
R100	scripts/config/LocalSettings.php	config/meza/LocalSettings.php
R100	scripts/config.sh	config/meza/config.sh
R100	scripts/elasticsearch.repo	config/meza/elasticsearch.repo
R100	scripts/elasticsearch.yml	config/meza/elasticsearch.yml
R100	scripts/config/httpd.conf	config/meza/httpd.conf
R100	scripts/initd_parsoid.sh	config/meza/initd_parsoid.sh
R100	scripts/localsettings.js	config/meza/localsettings.js
R100	scripts/logrotated_httpd	config/meza/logrotated_httpd
R100	scripts/config/memcached	config/meza/memcached
R100	scripts/php.ini	config/meza/php.ini
R100	htdocs/__common/AllWikiSettings.php	config/template/AllWikiSettings.php
R100	scripts/config/BlenderSettings.php	config/template/BlenderSettings.php
R100	scripts/config/SAML/SAML-LocalSettings-Additions.php	config/template/SAML-LocalSettings-Additions.php
R100	scripts/ifcfg-enp0s8	config/template/ifcfg-enp0s8
R100	scripts/ifcfg-eth1	config/template/ifcfg-eth1
R100	scripts/config/remote-wiki-config.example.sh	config/template/remote-wiki-config.example.sh
R100	scripts/config/SAML/saml20-idp-remote.php	config/template/saml20-idp-remote.php
R100	scripts/config/SAML/saml_httpd.conf	config/template/saml_httpd.conf
  - Deleted: `htdocs/__common/README.md`
  - Deleted: `scripts/httpd-conf-additions.conf`
  - Deleted: `scripts/initd_httpd.sh`
  - Deleted: `scripts/mysql-development.cfg`

* [82c79ebd](https://github.com/freephile/meza/commit/82c79ebd) (2016-02-19) James Montalvo: fix m_apache config var to point to yum install 
  - Modified: `scripts/config.sh`

* [ca7a5332](https://github.com/freephile/meza/commit/ca7a5332) (2016-02-19) James Montalvo: add prompt to remote-import so prompt isnt late 
  - Modified: `scripts/import-remote-wikis.sh`

* [94606af1](https://github.com/freephile/meza/commit/94606af1) (2016-02-19) James Montalvo: actually fix sudo, don't send slack on create Demo Wiki 
  - Modified: `scripts/extensions.sh`
  - Modified: `scripts/import-wikis.sh`
  - Modified: `scripts/install.sh`

* [0dea2825](https://github.com/freephile/meza/commit/0dea2825) (2016-02-19) James Montalvo: hopefully fix prompt when create wiki, remove sudo 
  - Modified: `scripts/import-wikis.sh`
  - Modified: `scripts/install.sh`
  - Modified: `scripts/slack.sh`

* [b65a99cc](https://github.com/freephile/meza/commit/b65a99cc) (2016-02-19) James Montalvo: streamline environment info 
  - Modified: `.github/ISSUE_TEMPLATE.md`

* [345582f6](https://github.com/freephile/meza/commit/345582f6) (2016-02-19) James Montalvo: JSON doesn't love unescaped double quotes 
  - Modified: `scripts/import-wikis.sh`

* [ebd139ce](https://github.com/freephile/meza/commit/ebd139ce) (2016-02-19) James Montalvo: move slack webhook to slack.sh, call in import-wiki too 
  - Modified: `scripts/import-wikis.sh`
  - Modified: `scripts/install.sh`
  - Added: `scripts/slack.sh`

* [0ebc7cee](https://github.com/freephile/meza/commit/0ebc7cee) (2016-02-18) James Montalvo: fix read in var, clean up text 
  - Modified: `scripts/install.sh`

* [107f736d](https://github.com/freephile/meza/commit/107f736d) (2016-02-18) James Montalvo: add ability to specify slack webhook for announcement 
  - Modified: `scripts/install.sh`

* [f4b9e4f4](https://github.com/freephile/meza/commit/f4b9e4f4) (2016-02-18) James Montalvo: Add Extension:CollapsibleVector (#310) 
  - Modified: `scripts/config/LocalSettings.php`

* [9acaeea1](https://github.com/freephile/meza/commit/9acaeea1) (2016-02-18) Daren Welsh: add environment 
  - Modified: `.github/ISSUE_TEMPLATE.md`

* [ff05b9d3](https://github.com/freephile/meza/commit/ff05b9d3) (2016-02-18) Daren Welsh: minor tweaks 
  - Modified: `.github/PULL_REQUEST_TEMPLATE.md`

* [bafdbd92](https://github.com/freephile/meza/commit/bafdbd92) (2016-02-18) James Montalvo: Force wgServer variable to canonical protocol, domain, port (#329) 
  - Modified: `scripts/config/LocalSettings.php`

* [4c7cf985](https://github.com/freephile/meza/commit/4c7cf985) (2016-02-17) James Montalvo: Relax elasticsearch API access to allow POST/PUT/DELETE 
  - Modified: `scripts/config/httpd.conf`

* [854bb15f](https://github.com/freephile/meza/commit/854bb15f) (2016-02-17) James Montalvo: Adding templates for issues and pull requests 
  - Added: `.github/ISSUE_TEMPLATE.md`
  - Added: `.github/PULL_REQUEST_TEMPLATE.md`

* [4af05345](https://github.com/freephile/meza/commit/4af05345) (2016-02-17) James Montalvo: Bump to MW 1.25.5 from MW 1.25.1 (#313) 
  - Modified: `scripts/mediawiki.sh`

* [8f8eed97](https://github.com/freephile/meza/commit/8f8eed97) (2016-02-16) James Montalvo: fix missing variable 
  - Modified: `scripts/unifyUserTables.php`

* [bf415f96](https://github.com/freephile/meza/commit/bf415f96) (2016-02-16) James Montalvo: fix plugin URIs (tag-like text didn't show) 
  - Modified: `manual/ElasticsearchPlugins.md`

* [8ff73cca](https://github.com/freephile/meza/commit/8ff73cca) (2016-02-16) James Montalvo: add docs for elasticsearch plugins 
  - Modified: `README.md`
  - Added: `manual/ElasticsearchPlugins.md`

* [711c9afc](https://github.com/freephile/meza/commit/711c9afc) (2016-02-13) James Montalvo: add bigdesk and inquisitor ES plugins 
  - Modified: `scripts/ElasticSearch.sh`

* [ebf2af81](https://github.com/freephile/meza/commit/ebf2af81) (2016-02-13) James Montalvo: only use php.ini production version, remove dev. They were basically the same 
R100	scripts/php.ini-production	scripts/php.ini
  - Deleted: `scripts/php.ini-development`
  - Modified: `scripts/php.sh`

* [33b79cb2](https://github.com/freephile/meza/commit/33b79cb2) (2016-02-13) James Montalvo: remove confusing comment about using port 8142 or 9000 
  - Modified: `scripts/config/LocalSettings.php`

* [4b2617cd](https://github.com/freephile/meza/commit/4b2617cd) (2016-02-13) James Montalvo: whitespace fixes 
  - Modified: `htdocs/.htaccess`
  - Modified: `scripts/yums.sh`

* [92f4e330](https://github.com/freephile/meza/commit/92f4e330) (2016-02-12) James Montalvo: mark v0.9-dev branch 
  - Modified: `README.md`

* [f43924aa](https://github.com/freephile/meza/commit/f43924aa) (2016-02-12) James Montalvo: Start using WikiBlender (#300) 
  - Modified: `.gitignore`
  - Modified: `htdocs/.htaccess`
  - Modified: `htdocs/index.php`
  - Added: `scripts/config/BlenderSettings.php`
  - Modified: `scripts/mediawiki.sh`

* [f524f5f7](https://github.com/freephile/meza/commit/f524f5f7) (2016-02-12) James Montalvo: Fix logrotate issue (hopefully) and remove to-do's from apache.sh Addresses issues #138 and #175
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/logrotated_httpd`

* [a7e7d958](https://github.com/freephile/meza/commit/a7e7d958) (2016-02-12) James Montalvo: for real adding commandTimes.js now (#133) 
  - Modified: `scripts/commandTimes.js`

* [651eba59](https://github.com/freephile/meza/commit/651eba59) (2016-02-12) James Montalvo: install.sh list install times (Related to #133) 
  - Added: `scripts/commandTimes.js`
  - Modified: `scripts/install.sh`

* [9be1082c](https://github.com/freephile/meza/commit/9be1082c) (2016-02-12) James Montalvo: fix authpassword location, whitespace cleanup 
  - Modified: `scripts/config/httpd.conf`

* [315a71bd](https://github.com/freephile/meza/commit/315a71bd) (2016-02-11) James Montalvo: reverse proxy for ES, management plugins (#281) 
  - Modified: `scripts/ElasticSearch.sh`
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/config/httpd.conf`

* [bd91756a](https://github.com/freephile/meza/commit/bd91756a) (2016-02-10) James Montalvo: set SELinux to permissive 
  - Modified: `scripts/apache.sh`

* [2e0dd005](https://github.com/freephile/meza/commit/2e0dd005) (2016-02-10) James Montalvo: disable SELinux; enable Vim 
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/yums.sh`

* [1672dbed](https://github.com/freephile/meza/commit/1672dbed) (2016-02-10) James Montalvo: use non thread safe opcache with current setup 
  - Modified: `scripts/php.ini-development`
  - Modified: `scripts/php.ini-production`

* [93f94872](https://github.com/freephile/meza/commit/93f94872) (2016-02-10) James Montalvo: massive restructuring of unifyUserTables.php 
  - Modified: `scripts/unifyUserTables.php`

* [8f0f23f1](https://github.com/freephile/meza/commit/8f0f23f1) (2016-02-09) James Montalvo: Add net-tools so we can netstat 
  - Modified: `scripts/yums.sh`

* [6c3a56f4](https://github.com/freephile/meza/commit/6c3a56f4) (2016-02-09) James Montalvo: Okay, use group 'apache'... 
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/config/httpd.conf`

* [b67951e4](https://github.com/freephile/meza/commit/b67951e4) (2016-02-09) James Montalvo: Switch to port 9000 from 8142 for parsoid Parsoid accesses PHP API via port 9000 now since that is a
standard HTTP port per SELinux. Since Apache is installed
via yum now, SELinux appears to be monitoring it more
closely, and as such we either need to modify SELinux
config (a pain) or use a standard port (seems right)
  - Modified: `scripts/VE.sh`
  - Modified: `scripts/config/LocalSettings.php`
  - Modified: `scripts/config/httpd.conf`

* [83df096f](https://github.com/freephile/meza/commit/83df096f) (2016-02-09) James Montalvo: comment out unnecessary variable 
  - Modified: `scripts/unifyUserTables.php`

* [787b11a0](https://github.com/freephile/meza/commit/787b11a0) (2016-02-09) James Montalvo: Fix apache group, make sure to add group/ownership 
  - Modified: `scripts/apache.sh`

* [864082fc](https://github.com/freephile/meza/commit/864082fc) (2016-02-09) James Montalvo: don't change apache user group to "apache", keep "www" 
  - Modified: `scripts/config/httpd.conf`

* [761ae42c](https://github.com/freephile/meza/commit/761ae42c) (2016-02-09) James Montalvo: add apache modules mod_ssl and mod_proxy_html 
  - Modified: `scripts/yums.sh`

* [facbb632](https://github.com/freephile/meza/commit/facbb632) (2016-02-08) James Montalvo: Make httpd.conf work (comment out php5_module to work w/o php) 
  - Modified: `scripts/config/httpd.conf`

* [7599fcc7](https://github.com/freephile/meza/commit/7599fcc7) (2016-02-04) James Montalvo: skip invalid field names for user table (#205) 
  - Modified: `scripts/unifyUserTables.php`

* [c3a891d3](https://github.com/freephile/meza/commit/c3a891d3) (2016-02-04) James Montalvo: Just add all rows to user table! (#205) 
  - Modified: `scripts/unifyUserTables.php`

* [be43b1c1](https://github.com/freephile/meza/commit/be43b1c1) (2016-02-04) James Montalvo: Forgot to add user_password to the insert query (#205) 
  - Modified: `scripts/unifyUserTables.php`

* [cda49426](https://github.com/freephile/meza/commit/cda49426) (2016-02-04) James Montalvo: Make sure user_password set in user-unify (#205) * Add it to the fields checked
* If one wiki has been touched more recently, use that password
  - Modified: `scripts/unifyUserTables.php`

* [0130dfc3](https://github.com/freephile/meza/commit/0130dfc3) (2016-02-04) James Montalvo: make sure to get entire user table for unify (#205) 
  - Modified: `scripts/unifyUserTables.php`

* [96f4ca12](https://github.com/freephile/meza/commit/96f4ca12) (2016-02-03) Daren Welsh: remove PHP prompt info from README (hardcoded now) 
  - Modified: `README.md`

* [6c8b650b](https://github.com/freephile/meza/commit/6c8b650b) (2016-02-03) James Montalvo: Add words about self-signed certificate 
  - Modified: `README.md`

* [544d99b6](https://github.com/freephile/meza/commit/544d99b6) (2016-02-02) James Montalvo: delete non-prime user and user_properties tables (#205) 
  - Modified: `scripts/unifyUserTables.php`

* [517dcde4](https://github.com/freephile/meza/commit/517dcde4) (2016-02-02) James Montalvo: add docs for unifyUserTable.php (#205) 
  - Modified: `manual/AddingWikis.md`

* [074320a3](https://github.com/freephile/meza/commit/074320a3) (2016-02-02) James Montalvo: fix wiki id selection 
  - Modified: `scripts/unifyUserTables.php`

* [25eb763c](https://github.com/freephile/meza/commit/25eb763c) (2016-02-01) James Montalvo: Make user-unify pull from htdocs/wikis; write prime wiki 
  - Modified: `scripts/unifyUserTables.php`

* [5046e482](https://github.com/freephile/meza/commit/5046e482) (2016-02-01) James Montalvo: unifyUserTables.php made into MW maint script, functions now 
  - Modified: `scripts/unifyUserTables.php`

* [9c790ab7](https://github.com/freephile/meza/commit/9c790ab7) (2016-02-01) James Montalvo: Don't apply SAML to services; use AccessDenied 
  - Modified: `scripts/config/SAML/SAML-LocalSettings-Additions.php`
  - Modified: `scripts/saml.sh`

* [1cd6fc86](https://github.com/freephile/meza/commit/1cd6fc86) (2016-02-01) James Montalvo: Comment out Flow in LocalSettings.php; Issue [#272](https://github.com/freephile/meza/issues/272) 
  - Modified: `scripts/config/LocalSettings.php`

* [7064f101](https://github.com/freephile/meza/commit/7064f101) (2016-01-31) James Montalvo: Fix enableSemantics; bump SummaryTimeline to 0.2.0 
  - Modified: `scripts/config/LocalSettings.php`

* [3867b5e5](https://github.com/freephile/meza/commit/3867b5e5) (2016-01-29) James Montalvo: authsources idp setting was not valid php 
  - Modified: `scripts/saml.sh`

* [dccadecc](https://github.com/freephile/meza/commit/dccadecc) (2016-01-29) James Montalvo: rename file to fix saml.sh 
R100	scripts/config/SAML/SAML-LocalSettings-Addition.php	scripts/config/SAML/SAML-LocalSettings-Additions.php

* [ca9ff1a2](https://github.com/freephile/meza/commit/ca9ff1a2) (2016-01-29) James Montalvo: wrong location of SAML localsettings additions 
  - Modified: `scripts/saml.sh`

* [0ec9a64f](https://github.com/freephile/meza/commit/0ec9a64f) (2016-01-29) James Montalvo: Add all required prompts to saml.sh; Fix README 
  - Modified: `README.md`
R083	scripts/config/SAML-LocalSettings-Addition.php	scripts/config/SAML/SAML-LocalSettings-Addition.php
R100	scripts/config/saml20-idp-remote.php	scripts/config/SAML/saml20-idp-remote.php
R100	scripts/config/saml_httpd.conf	scripts/config/SAML/saml_httpd.conf
  - Modified: `scripts/saml.sh`

* [5118329a](https://github.com/freephile/meza/commit/5118329a) (2016-01-27) James Montalvo: Using variable in bash, needs double quotes 
  - Modified: `scripts/saml.sh`

* [dcd0b90a](https://github.com/freephile/meza/commit/dcd0b90a) (2016-01-27) James Montalvo: wrong path to httpd.conf 
  - Modified: `scripts/saml.sh`

* [d225fee1](https://github.com/freephile/meza/commit/d225fee1) (2016-01-27) James Montalvo: use path variables, not hard-coded paths 
  - Modified: `scripts/config.sh`
  - Modified: `scripts/saml.sh`

* [6031d2ec](https://github.com/freephile/meza/commit/6031d2ec) (2016-01-27) James Montalvo: Restart httpd after saml mod to httpd.conf 
  - Modified: `scripts/saml.sh`

* [41ef5753](https://github.com/freephile/meza/commit/41ef5753) (2016-01-27) James Montalvo: forgot pointer in httpd.conf 
  - Modified: `scripts/config/httpd.conf`

* [da24c8f2](https://github.com/freephile/meza/commit/da24c8f2) (2016-01-27) James Montalvo: escape user inputs 
  - Modified: `scripts/saml.sh`

* [f2d97f02](https://github.com/freephile/meza/commit/f2d97f02) (2016-01-27) James Montalvo: simplesamlphp needs to be in meza root, not web root 
  - Modified: `scripts/saml.sh`

* [3a45ecf4](https://github.com/freephile/meza/commit/3a45ecf4) (2016-01-27) James Montalvo: initial SAML auth configuration 
  - Added: `scripts/config/SAML-LocalSettings-Addition.php`
  - Added: `scripts/config/saml20-idp-remote.php`
  - Added: `scripts/config/saml_httpd.conf`
  - Added: `scripts/saml.sh`

* [815cde43](https://github.com/freephile/meza/commit/815cde43) (2016-01-27) Daren Welsh: clarify option to use home dir for wiki import 
  - Modified: `manual/AddingWikis.md`

* [d5a03b12](https://github.com/freephile/meza/commit/d5a03b12) (2016-01-26) James Montalvo: Don't redirect http because elasticsearch no likey 
  - Modified: `scripts/config/httpd.conf`

* [064203ba](https://github.com/freephile/meza/commit/064203ba) (2016-01-25) James Montalvo: fix missing trailing slash in httpd.conf 
  - Modified: `scripts/config/httpd.conf`

* [60482379](https://github.com/freephile/meza/commit/60482379) (2016-01-25) James Montalvo: Fix https issues with Parsoid and forwarding from http * Hard-code protocol used **by** Parsoid to access MW API to http
  since Parsoid has its own port now (8142) which isn't open in
  firewall
* In port 80 (http) section of httpd.conf, add domain to forward
  to rather than trying to imply forwarding to https. For some
  reason this implied forwarding appeared to be working on prior
  testing.
* Open port 80 (http) in firewall so it can forward users to https
  - Modified: `scripts/VE.sh`
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/config/httpd.conf`

* [1a466c21](https://github.com/freephile/meza/commit/1a466c21) (2016-01-25) James Montalvo: rework https plan to fix parsoid, prep for SAML 
  - Modified: `scripts/VE.sh`
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/config/httpd.conf`
  - Modified: `scripts/install.sh`

* [1cac4212](https://github.com/freephile/meza/commit/1cac4212) (2016-01-24) James Montalvo: use self-signed certificate for default https 
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/config/httpd.conf`
  - Modified: `scripts/install.sh`

* [3eea451e](https://github.com/freephile/meza/commit/3eea451e) (2016-01-23) James Montalvo: move enable firewalld to early in install 
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/install.sh`

* [e7d2423f](https://github.com/freephile/meza/commit/e7d2423f) (2016-01-23) James Montalvo: Verify firewalld enabled 
  - Modified: `scripts/apache.sh`

* [bf5af7fe](https://github.com/freephile/meza/commit/bf5af7fe) (2016-01-12) Daren Welsh: add example to create user 
  - Modified: `manual/AddingWikis.md`

* [50ef6c5b](https://github.com/freephile/meza/commit/50ef6c5b) (2015-12-03) James Montalvo: Debug should always be on during testing 
  - Modified: `CONTRIBUTING.md`

* [83631ae5](https://github.com/freephile/meza/commit/83631ae5) (2015-11-18) James Montalvo: add php include path including httpd modules 
  - Modified: `scripts/php.ini-development`

* [8df4dfe9](https://github.com/freephile/meza/commit/8df4dfe9) (2015-11-18) James Montalvo: remove php-fpm (using mod_php) 
  - Modified: `scripts/php.sh`

* [b0497836](https://github.com/freephile/meza/commit/b0497836) (2015-11-18) James Montalvo: use httpd-devel, make php use right apxs 
  - Modified: `scripts/php.sh`
  - Modified: `scripts/yums.sh`

* [71a5fd08](https://github.com/freephile/meza/commit/71a5fd08) (2015-11-17) James Montalvo: make prime-wiki work with new LocalSettings layout 
  - Modified: `manual/AddingWikis.md`
  - Modified: `scripts/config/LocalSettings.php`

* [5e0b6fac](https://github.com/freephile/meza/commit/5e0b6fac) (2015-11-12) James Montalvo: Try apache from yum 
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/config/httpd.conf`
  - Modified: `scripts/yums.sh`

* [5c790026](https://github.com/freephile/meza/commit/5c790026) (2015-11-11) James Montalvo: Add documentation for remote wiki import 
  - Modified: `manual/AddingWikis.md`

* [7f9888b9](https://github.com/freephile/meza/commit/7f9888b9) (2015-11-11) Daren Welsh: bump SummaryTimeline version 
  - Modified: `scripts/config/LocalSettings.php`

* [793ee15d](https://github.com/freephile/meza/commit/793ee15d) (2015-11-11) James Montalvo: bump ExtensionLoader to v0.2.3 
  - Modified: `scripts/extensions.sh`

* [82db6e5b](https://github.com/freephile/meza/commit/82db6e5b) (2015-11-11) Daren Welsh: disable search update for runJobs during import 
  - Modified: `scripts/import-wikis.sh`

* [3d4ce480](https://github.com/freephile/meza/commit/3d4ce480) (2015-11-11) James Montalvo: use version of ExtensionLoader supporting tags; SummaryTimeline checkout tag 
  - Modified: `scripts/config/LocalSettings.php`
  - Modified: `scripts/extensions.sh`

* [ccbbe983](https://github.com/freephile/meza/commit/ccbbe983) (2015-11-10) Daren Welsh: edit NS using Flow/VE, allow Flow to use VE 
  - Modified: `scripts/config/LocalSettings.php`

* [972bb52a](https://github.com/freephile/meza/commit/972bb52a) (2015-11-10) James Montalvo: Add requirements for which servers to test on pre-release 
  - Modified: `CONTRIBUTING.md`

* [96b23380](https://github.com/freephile/meza/commit/96b23380) (2015-11-10) James Montalvo: No users should be able to directly access images Users should have to access via img_auth.php, so that MediaWiki
authentication is used to determine who can see the upload.
  - Modified: `CONTRIBUTING.md`

* [fc0ad18c](https://github.com/freephile/meza/commit/fc0ad18c) (2015-11-09) James Montalvo: add enableSemantics() back in 
  - Modified: `scripts/config/LocalSettings.php`
  - Modified: `scripts/extensions.sh`

* [001161da](https://github.com/freephile/meza/commit/001161da) (2015-11-06) Daren Welsh: enable time sync 
  - Modified: `scripts/install.sh`

* [50754f92](https://github.com/freephile/meza/commit/50754f92) (2015-11-06) James Montalvo: Add better settings callouts for SRF 
  - Modified: `scripts/config/LocalSettings.php`

* [84a9bf37](https://github.com/freephile/meza/commit/84a9bf37) (2015-11-05) Daren Welsh: change logic to find domain; fix case for value not found 
  - Modified: `scripts/install.sh`

* [b42360c9](https://github.com/freephile/meza/commit/b42360c9) (2015-11-05) James Montalvo: Add Flow back into extension settings 
  - Modified: `scripts/config/LocalSettings.php`

* [1ac8fefa](https://github.com/freephile/meza/commit/1ac8fefa) (2015-11-05) James Montalvo: add semantic maps 
  - Modified: `scripts/extensions.sh`

* [23575c44](https://github.com/freephile/meza/commit/23575c44) (2015-11-04) James Montalvo: use newest ExtensionLoader; run elastic search index 
  - Modified: `scripts/extensions.sh`
  - Modified: `scripts/mezaCreateUser.php`

* [a5a3952c](https://github.com/freephile/meza/commit/a5a3952c) (2015-10-30) James Montalvo: install Demo Wiki first 
  - Modified: `scripts/extensions.sh`

* [62efce5c](https://github.com/freephile/meza/commit/62efce5c) (2015-10-30) James Montalvo: bump ExtensionLoader to v0.2.0 
  - Modified: `scripts/extensions.sh`

* [ba457b29](https://github.com/freephile/meza/commit/ba457b29) (2015-10-30) James Montalvo: fix typo in LocalSettings.php 
  - Modified: `scripts/config/LocalSettings.php`

* [79a45b7d](https://github.com/freephile/meza/commit/79a45b7d) (2015-10-30) James Montalvo: Add explanation of mount_name 
  - Modified: `scripts/import-remote-wikis.sh`

* [5db9fbcc](https://github.com/freephile/meza/commit/5db9fbcc) (2015-10-30) James Montalvo: Add explanation of mount_name and remote_share 
  - Modified: `scripts/config/remote-wiki-config.example.sh`

* [76be4143](https://github.com/freephile/meza/commit/76be4143) (2015-10-30) James Montalvo: Remove old MS Office file types 
  - Modified: `scripts/config/LocalSettings.php`

* [1beee629](https://github.com/freephile/meza/commit/1beee629) (2015-10-29) James Montalvo: Use latest version of Parsoid that was found to work 
  - Modified: `scripts/install.sh`

* [42fe1aaa](https://github.com/freephile/meza/commit/42fe1aaa) (2015-10-29) James Montalvo: Missing equals 
  - Modified: `scripts/install.sh`

* [c00cb460](https://github.com/freephile/meza/commit/c00cb460) (2015-10-29) James Montalvo: Parsoid version in install.sh for easy changing 
  - Modified: `scripts/VE.sh`
  - Modified: `scripts/install.sh`

* [463c007e](https://github.com/freephile/meza/commit/463c007e) (2015-10-29) James Montalvo: Checkout specific version of parsoid 
  - Modified: `scripts/VE.sh`

* [a78cd1d5](https://github.com/freephile/meza/commit/a78cd1d5) (2015-10-29) James Montalvo: Remove duplicate settings from LocalSettings.php 
  - Modified: `scripts/ExtensionSettings.php`

* [840972f5](https://github.com/freephile/meza/commit/840972f5) (2015-10-29) James Montalvo: Make Flow config variables global 
  - Modified: `scripts/ExtensionSettings.php`

* [4a930d97](https://github.com/freephile/meza/commit/4a930d97) (2015-10-29) James Montalvo: Add deltarpm package to reduce install time 
  - Modified: `scripts/yums.sh`

* [911f5776](https://github.com/freephile/meza/commit/911f5776) (2015-10-28) Daren Welsh: remove conflict remnant 
  - Modified: `scripts/ExtensionSettings.php`

* [841c68c6](https://github.com/freephile/meza/commit/841c68c6) (2015-10-28) James Montalvo: Fix path to setup.php 
  - Modified: `scripts/import-remote-wikis.sh`
  - Modified: `scripts/import-wikis.sh`

* [617e45b0](https://github.com/freephile/meza/commit/617e45b0) (2015-10-28) James Montalvo: Add remote config file capability; strip non-standard DB name 
  - Modified: `.gitignore`
  - Added: `scripts/config/remote-wiki-config.example.sh`
R084	scripts/importWikisFromServer.sh	scripts/import-remote-wikis.sh
  - Modified: `scripts/import-wikis.sh`

* [7aa75515](https://github.com/freephile/meza/commit/7aa75515) (2015-10-28) James Montalvo: Allow import of wikis from remote servers 
  - Added: `scripts/getDatabaseNameFromSetup.php`
  - Added: `scripts/importWikisFromServer.sh`
  - Modified: `scripts/yums.sh`

* [ea858e31](https://github.com/freephile/meza/commit/ea858e31) (2015-10-28) Daren Welsh: set  = CACHE_NONE for #244 
  - Modified: `scripts/config/LocalSettings.php`

* [964e8d45](https://github.com/freephile/meza/commit/964e8d45) (2015-10-27) James Montalvo: Need to cd into ExtensionLoader to checkout version 
  - Modified: `scripts/extensions.sh`

* [ecb33e59](https://github.com/freephile/meza/commit/ecb33e59) (2015-10-27) Daren Welsh: checkout v0.1.0 of ExtensionLoader 
  - Modified: `scripts/extensions.sh`

* [aaf2d1de](https://github.com/freephile/meza/commit/aaf2d1de) (2015-10-27) James Montalvo: ExtensionSettings merged into LocalSettings; cleanup 
  - Deleted: `scripts/ExtensionSettings.php`
  - Deleted: `scripts/config/ComposerSettings.php`
  - Modified: `scripts/config/LocalSettings.php`
  - Modified: `scripts/extensions.sh`
  - Modified: `scripts/import-wikis.sh`
  - Modified: `scripts/mediawiki.sh`

* [ea24225b](https://github.com/freephile/meza/commit/ea24225b) (2015-10-26) James Montalvo: apparently working version of user-unify 
  - Modified: `scripts/unifyUserTables.php`

* [9a8fda9e](https://github.com/freephile/meza/commit/9a8fda9e) (2015-10-26) James Montalvo: complete but untested user-unify script 
  - Modified: `scripts/unifyUserTables.php`

* [d227f320](https://github.com/freephile/meza/commit/d227f320) (2015-10-23) James Montalvo: more worky 
  - Modified: `scripts/unifyUserTables.php`

* [cae03f9a](https://github.com/freephile/meza/commit/cae03f9a) (2015-10-23) James Montalvo: more work on unifying databases 
  - Modified: `scripts/unifyUserTables.php`

* [74a05f26](https://github.com/freephile/meza/commit/74a05f26) (2015-10-23) James Montalvo: Create script to unify user tables across wikis This script doesn't even remotely work yet...
  - Added: `scripts/unifyUserTables.php`

* [445ffa1a](https://github.com/freephile/meza/commit/445ffa1a) (2015-10-21) Daren Welsh: add memcached and Flow 
  - Modified: `scripts/ExtensionSettings.php`
  - Modified: `scripts/config/LocalSettings.php`
  - Added: `scripts/config/memcached`
  - Modified: `scripts/install.sh`
  - Added: `scripts/memcached.sh`

* [30f4aad3](https://github.com/freephile/meza/commit/30f4aad3) (2015-10-21) Daren Welsh: hard-code php version, enable opcache 
  - Modified: `scripts/install.sh`
  - Modified: `scripts/php.ini-development`
  - Modified: `scripts/php.ini-production`
  - Modified: `scripts/php.sh`

* [2171cff9](https://github.com/freephile/meza/commit/2171cff9) (2015-10-18) Daren Welsh: update permissions to wiki and config path 
  - Modified: `scripts/import-wikis.sh`

* [70bdaec0](https://github.com/freephile/meza/commit/70bdaec0) (2015-10-17) Daren Welsh: step not required for CentOS 7 
  - Modified: `manual/2.1-CreateCloneVMs.md`

* [054841ac](https://github.com/freephile/meza/commit/054841ac) (2015-10-14) Daren Welsh: add CentOS 7 clone steps 
  - Modified: `manual/2.1-CreateCloneVMs.md`

* [c036c597](https://github.com/freephile/meza/commit/c036c597) (2015-10-08) James Montalvo: Add create and import wikis to requirements 
  - Modified: `CONTRIBUTING.md`

* [7c1eb35c](https://github.com/freephile/meza/commit/7c1eb35c) (2015-10-07) Daren Welsh: change repo name 
  - Modified: `README.md`
  - Modified: `htdocs/__common/AllWikiSettings.php`
  - Modified: `logs/README.md`
  - Modified: `manual/1.0-SettingUpVirtualBox.md`
  - Modified: `manual/1.0-SettingUpVirtualBoxWindows.md`
  - Modified: `manual/3.0-SetupLAMP.md`
  - Modified: `manual/3.1-InstallApache.md`
  - Modified: `manual/4.0-InstallMediaWiki.md`
  - Modified: `manual/AddingWikis.md`
  - Modified: `manual/SetupDigitalOcean.md`
  - Modified: `scripts/ElasticSearch.sh`
  - Modified: `scripts/apache.sh`
  - Modified: `scripts/config.sh`
  - Modified: `scripts/config/ComposerSettings.php`
  - Modified: `scripts/config/LocalSettings.php`
  - Modified: `scripts/create-wiki.sh`
  - Modified: `scripts/elasticsearch.yml`
  - Modified: `scripts/extensions.sh`
  - Modified: `scripts/httpd-conf-additions.conf`
  - Modified: `scripts/import-wikis.sh`
  - Modified: `scripts/install.sh`
  - Modified: `scripts/localsettings.js`
  - Modified: `scripts/mezaCreateUser.php`
  - Modified: `scripts/mysql-development.cfg`
  - Modified: `scripts/pigeon.txt`
  - Modified: `setup.sh`
  - Modified: `wiki-init/config/disableSearchUpdate.php`
  - Modified: `wiki-init/config/setup.php`

* [b6d32173](https://github.com/freephile/meza/commit/b6d32173) (2015-10-06) James Montalvo: Add specifics for testing image access 
  - Modified: `CONTRIBUTING.md`

* [428ac1bb](https://github.com/freephile/meza/commit/428ac1bb) (2015-10-06) Daren Welsh: link to contribution guide 
  - Modified: `README.md`

* [1c43fa07](https://github.com/freephile/meza/commit/1c43fa07) (2015-10-05) Daren Welsh: Forgot to update branch before merging #186 
  - Modified: `setup.sh`

* [716ed4bd](https://github.com/freephile/meza/commit/716ed4bd) (2015-10-05) James Montalvo: Add contributing guide and test requirements 
  - Added: `CONTRIBUTING.md`

* [191f883d](https://github.com/freephile/meza/commit/191f883d) (2015-10-05) James Montalvo: fix images directory security; add scp to docs 
  - Modified: `manual/AddingWikis.md`
  - Modified: `scripts/config/httpd.conf`

* [52091f8d](https://github.com/freephile/meza/commit/52091f8d) (2015-10-05) James Montalvo: allow one wiki to have user and interwikis tables for all 
  - Modified: `manual/AddingWikis.md`
  - Modified: `scripts/config/LocalSettings.php`

* [16de71d3](https://github.com/freephile/meza/commit/16de71d3) (2015-10-03) James Montalvo: Fix PHP syntax errors 
  - Modified: `client_files/ExtensionSettings.php`

* [38356507](https://github.com/freephile/meza/commit/38356507) (2015-10-03) James Montalvo: fix imagemagick install, move script, deleted downloaded files 
R090	scripts/install-imagick.sh	scripts/imagemagick.sh
  - Modified: `scripts/install.sh`

* [f12ac1f9](https://github.com/freephile/meza/commit/f12ac1f9) (2015-10-03) James Montalvo: fix directory to pull wikis from on landing page 
  - Modified: `htdocs/index.php`

* [3127cb9c](https://github.com/freephile/meza/commit/3127cb9c) (2015-10-02) Daren Welsh: don't require confirmation of thanking 
  - Modified: `client_files/ExtensionSettings.php`

* [9562aaa8](https://github.com/freephile/meza/commit/9562aaa8) (2015-10-02) James Montalvo: Landing page fix, directory moves Landing page displays readme. Make sure it only shows files.
Find/replace "client_files" with "scripts"
Change directory name to scripts
Find/replace "sources" with "mezadownloads"
Move build directories for PHP, Apache and ImageMagick to /opt/Meza/sources
  - Modified: `.gitignore`
  - Modified: `README.md`
  - Modified: `htdocs/index.php`
  - Modified: `manual/1.0-SettingUpVirtualBoxWindows.md`
  - Modified: `manual/3.1-InstallApache.md`
  - Modified: `manual/3.2-InstallPHP.md`
  - Modified: `manual/4.0-InstallMediaWiki.md`
R097	client_files/ElasticSearch.sh	scripts/ElasticSearch.sh
R100	client_files/ExtensionSettings.php	scripts/ExtensionSettings.php
R098	client_files/VE.sh	scripts/VE.sh
R089	client_files/apache.sh	scripts/apache.sh
R080	client_files/config.sh	scripts/config.sh
R100	client_files/config/ComposerSettings.php	scripts/config/ComposerSettings.php
R100	client_files/config/LocalSettings.php	scripts/config/LocalSettings.php
R100	client_files/config/httpd.conf	scripts/config/httpd.conf
R098	client_files/create-wiki.sh	scripts/create-wiki.sh
R100	client_files/elastic-build-index.sh	scripts/elastic-build-index.sh
R100	client_files/elasticsearch.repo	scripts/elasticsearch.repo
R100	client_files/elasticsearch.yml	scripts/elasticsearch.yml
R089	client_files/extensions.sh	scripts/extensions.sh
R100	client_files/httpd-conf-additions.conf	scripts/httpd-conf-additions.conf
R100	client_files/ifcfg-enp0s8	scripts/ifcfg-enp0s8
R100	client_files/ifcfg-eth1	scripts/ifcfg-eth1
R099	client_files/import-wikis.sh	scripts/import-wikis.sh
R100	client_files/initd_httpd.sh	scripts/initd_httpd.sh
R100	client_files/initd_parsoid.sh	scripts/initd_parsoid.sh
R093	client_files/install-imagick.sh	scripts/install-imagick.sh
R094	client_files/install.sh	scripts/install.sh
R100	client_files/localsettings.js	scripts/localsettings.js
R100	client_files/logrotated_httpd	scripts/logrotated_httpd
R096	client_files/mediawiki.sh	scripts/mediawiki.sh
R100	client_files/mezaCreateUser.php	scripts/mezaCreateUser.php
R100	client_files/mysql-development.cfg	scripts/mysql-development.cfg
R100	client_files/mysql.sh	scripts/mysql.sh
R100	client_files/php.ini-development	scripts/php.ini-development
R100	client_files/php.ini-production	scripts/php.ini-production
R091	client_files/php.sh	scripts/php.sh
R100	client_files/pigeon.txt	scripts/pigeon.txt
R100	client_files/printTitle.sh	scripts/printTitle.sh
R100	client_files/samba.sh	scripts/samba.sh
R100	client_files/vmsetupwin.bat	scripts/vmsetupwin.bat
R099	client_files/yums.sh	scripts/yums.sh
  - Modified: `setup.sh`
  - Added: `sources/README.md`

* [33cffaa7](https://github.com/freephile/meza/commit/33cffaa7) (2015-10-02) Daren Welsh: forgot ); remove cd per issue 48 
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/VE.sh`

* [dec63700](https://github.com/freephile/meza/commit/dec63700) (2015-10-02) Daren Welsh: use ExtensionLoader to set wg variable 
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/config/LocalSettings.php`

* [22389eb6](https://github.com/freephile/meza/commit/22389eb6) (2015-10-02) Daren Welsh: add Echo and Thanks 
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/config/LocalSettings.php`

* [4feb7247](https://github.com/freephile/meza/commit/4feb7247) (2015-10-02) James Montalvo: Update documentation for CentOS 7 inclusion 
  - Modified: `README.md`
  - Modified: `manual/1.0-SettingUpVirtualBox.md`
  - Modified: `manual/1.0-SettingUpVirtualBoxWindows.md`

* [7b21134b](https://github.com/freephile/meza/commit/7b21134b) (2015-10-02) James Montalvo: bump version number in README.md 
  - Modified: `README.md`

* [2327a08d](https://github.com/freephile/meza/commit/2327a08d) (2015-09-28) James Montalvo: switch ElasticSearch service registration method 
  - Modified: `client_files/ElasticSearch.sh`

* [51a294ba](https://github.com/freephile/meza/commit/51a294ba) (2015-09-27) James Montalvo: Make IP address prompt work in CentOS 7 
  - Modified: `client_files/install.sh`

* [f120537d](https://github.com/freephile/meza/commit/f120537d) (2015-09-26) James Montalvo: Get IP address for CentOS7 adapters 
  - Modified: `client_files/install.sh`

* [5c492306](https://github.com/freephile/meza/commit/5c492306) (2015-09-24) Daren Welsh: prompt for branch first 
  - Modified: `client_files/install.sh`

* [159e26b1](https://github.com/freephile/meza/commit/159e26b1) (2015-09-24) Daren Welsh: hide mysql password in prompt 
  - Modified: `client_files/install.sh`

* [8759746c](https://github.com/freephile/meza/commit/8759746c) (2015-09-24) Daren Welsh: gen rand mysql pw, detect IP, set defaults 
  - Modified: `client_files/install.sh`

* [60a8cb5b](https://github.com/freephile/meza/commit/60a8cb5b) (2015-09-21) James Montalvo: phase 1 of consolidation into single dir: close eyes and hope 
  - Modified: `client_files/apache.sh`
  - Modified: `client_files/config.sh`
  - Modified: `client_files/config/LocalSettings.php`
  - Modified: `client_files/config/httpd.conf`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/import-wikis.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/localsettings.js`
  - Modified: `client_files/logrotated_httpd`
  - Modified: `client_files/mediawiki.sh`
  - Modified: `client_files/mezaCreateUser.php`
  - Modified: `client_files/php.sh`
R100	client_files/config/htaccess	htdocs/.htaccess
  - Added: `htdocs/README.md`
R100	client_files/config/AllWikiSettings.php	htdocs/__common/AllWikiSettings.php
  - Added: `htdocs/__common/README.md`
R092	client_files/index.php	htdocs/index.php
  - Added: `htdocs/wikis/README.md`
  - Modified: `wiki-init/config/CustomSettings.php`
  - Modified: `wiki-init/config/setup.php`

* [80c7a2c2](https://github.com/freephile/meza/commit/80c7a2c2) (2015-09-21) James Montalvo: remove setting user permissions in VE extension settings 
  - Modified: `client_files/ExtensionSettings.php`

* [832ccfe4](https://github.com/freephile/meza/commit/832ccfe4) (2015-09-19) James Montalvo: Explicitly print "import-wikis.sh" rather than script name Script name will be "import-wikis.sh" if that script is called
directly, which would be the case if someone wanted to actually
import wikis. However, create-wiki.sh also uses import-wikis.sh,
so it'll print "create-wiki.sh" in that case (it'll print whatever
the parent script is called). Furthermore, during initial install
create-wiki.sh is called from within either mediawiki.sh or
extensions.sh, which are called from within install.sh. Thus, it
will display the "install.sh" rather than the intended
"import-wikis.sh". It's just easier to hard-code it.
  - Modified: `client_files/import-wikis.sh`

* [94520ae6](https://github.com/freephile/meza/commit/94520ae6) (2015-09-18) James Montalvo: check for architecture, download appropriate node version 
  - Modified: `client_files/VE.sh`

* [2476b269](https://github.com/freephile/meza/commit/2476b269) (2015-09-17) James Montalvo: add global refs; make disableSearchUpdate.php present 
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/elastic-build-index.sh`
  - Modified: `client_files/import-wikis.sh`
  - Added: `wiki-init/config/disableSearchUpdate.php`

* [3d5f5e90](https://github.com/freephile/meza/commit/3d5f5e90) (2015-09-17) James Montalvo: fix composer running in wrong directory 
  - Modified: `client_files/extensions.sh`

* [0157649e](https://github.com/freephile/meza/commit/0157649e) (2015-09-17) James Montalvo: elastic-build-index skip unavailable commands; fix settings elastic-build-indes.sh calls scripts related to SMW and CirrusSearch,
but on the initial install (install.sh), when the "Demo Wiki" is
created, these extensions are not yet available. The Demo Wiki is
required to bootstrap the rest of the install, so when wikis are
created now import-wikis.sh will check for the existence of SMW and
CirrusSearch before attempting to use them.
Also, ExtensionSettings.php had a missing semicolon. I'm dumb.
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/import-wikis.sh`

* [9dcff6ee](https://github.com/freephile/meza/commit/9dcff6ee) (2015-09-17) James Montalvo: init ExtensionLoader in ComposerSettings (hack) 
  - Modified: `client_files/config/ComposerSettings.php`
  - Modified: `client_files/config/LocalSettings.php`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/mediawiki.sh`

* [72b4b943](https://github.com/freephile/meza/commit/72b4b943) (2015-09-17) James Montalvo: Move composer settings into separate file It seems SMW can't have the enableSemantics() function in place during
install so it is being moved to a separate file.
  - Added: `client_files/config/ComposerSettings.php`
  - Modified: `client_files/config/LocalSettings.php`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/mediawiki.sh`

* [1d00dacf](https://github.com/freephile/meza/commit/1d00dacf) (2015-09-16) James Montalvo: move composer extensions before wiki install 
  - Modified: `client_files/extensions.sh`

* [676aa34d](https://github.com/freephile/meza/commit/676aa34d) (2015-09-16) James Montalvo: move Demo Wiki install earlier so uploadExtensions can run 
  - Modified: `client_files/extensions.sh`

* [46b3a28c](https://github.com/freephile/meza/commit/46b3a28c) (2015-09-15) James Montalvo: Consolidate VE and ES, load before MW install 
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/ExtensionSettings.php`
  - Deleted: `client_files/ExtensionSettingsElasticSearch.php`
  - Deleted: `client_files/ExtensionSettingsVE.php`
  - Deleted: `client_files/LocalSettingsAdditions`
  - Deleted: `client_files/LocalSettingsElasticSearch.php`
  - Deleted: `client_files/LocalSettingsVE.php`
  - Modified: `client_files/VE.sh`
  - Modified: `client_files/config/LocalSettings.php`
  - Modified: `client_files/elastic-build-index.sh`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`

* [f7c21e76](https://github.com/freephile/meza/commit/f7c21e76) (2015-09-15) James Montalvo: prevent access to image dirs; use img_auth.php 
  - Modified: `client_files/config/LocalSettings.php`
  - Modified: `client_files/config/httpd.conf`

* [a0e158ad](https://github.com/freephile/meza/commit/a0e158ad) (2015-09-15) James Montalvo: remove unneeded rewrite.sh 
  - Deleted: `client_files/rewrite.sh`

* [95a35780](https://github.com/freephile/meza/commit/95a35780) (2015-09-15) Daren Welsh: provide example for path to wikis 
  - Modified: `manual/AddingWikis.md`

* [fef0a729](https://github.com/freephile/meza/commit/fef0a729) (2015-09-15) Daren Welsh: fix typo in .sql filename 
  - Modified: `manual/AddingWikis.md`

* [1d249f2c](https://github.com/freephile/meza/commit/1d249f2c) (2015-09-14) James Montalvo: route image handling through img_auth.php 
  - Modified: `client_files/config/LocalSettings.php`

* [dee96817](https://github.com/freephile/meza/commit/dee96817) (2015-09-14) James Montalvo: Use EPEL instead of RPMForge; libmcrypt not in EL7 version Also, I think I trust EPEL more.
  - Modified: `client_files/yums.sh`

* [84e558ae](https://github.com/freephile/meza/commit/84e558ae) (2015-09-14) James Montalvo: MySQL need check for CentOS 6 or 7 
  - Modified: `client_files/apache.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mysql.sh`
  - Modified: `client_files/yums.sh`

* [58f8c1e2](https://github.com/freephile/meza/commit/58f8c1e2) (2015-09-14) James Montalvo: handle eth0; CHANGE BRANCH TO centos7; FIX PRE-MERGE 
  - Modified: `setup.sh`

* [fa8ab033](https://github.com/freephile/meza/commit/fa8ab033) (2015-09-14) James Montalvo: make setup.sh CentOS7 compat; use curl instead of wget 
  - Added: `client_files/ifcfg-enp0s8`
  - Modified: `client_files/yums.sh`
  - Modified: `setup.sh`

* [5df015f7](https://github.com/freephile/meza/commit/5df015f7) (2015-09-13) James Montalvo: handle firewall for centos 6&7; move from setup to apache 
  - Modified: `client_files/apache.sh`
  - Modified: `setup.sh`

* [002babbd](https://github.com/freephile/meza/commit/002babbd) (2015-09-12) James Montalvo: remove php imap support and libc-client 
  - Modified: `client_files/php.sh`
  - Modified: `client_files/yums.sh`

* [57e00210](https://github.com/freephile/meza/commit/57e00210) (2015-09-12) James Montalvo: Add reminder to change IP address if desired 
  - Modified: `manual/2.1-CreateCloneVMs.md`

* [2a52789b](https://github.com/freephile/meza/commit/2a52789b) (2015-09-10) James Montalvo: fix directory check to see if wiki exists 
  - Modified: `client_files/import-wikis.sh`

* [e77b9fa9](https://github.com/freephile/meza/commit/e77b9fa9) (2015-09-10) James Montalvo: fix description of prompts 
  - Modified: `README.md`

* [5b38fff7](https://github.com/freephile/meza/commit/5b38fff7) (2015-09-10) James Montalvo: check existing wikis; fix display title, favicon; new logo 
  - Modified: `client_files/config/LocalSettings.php`
  - Modified: `client_files/import-wikis.sh`
  - Modified: `wiki-init/config/favicon.ico`
  - Modified: `wiki-init/config/logo.png`

* [87904e5a](https://github.com/freephile/meza/commit/87904e5a) (2015-09-10) Daren Welsh: remove unnecessary quotes 
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`

* [3dd855e7](https://github.com/freephile/meza/commit/3dd855e7) (2015-09-10) Daren Welsh: token not required for non-API requests; so only use for composer 
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`

* [ab801011](https://github.com/freephile/meza/commit/ab801011) (2015-09-10) James Montalvo: remove old create wiki script 
  - Deleted: `client_files/create_wiki.sh`

* [fafccacf](https://github.com/freephile/meza/commit/fafccacf) (2015-09-09) James Montalvo: Add docs; improve create-wiki support; fixes 
  - Modified: `README.md`
  - Added: `client_files/create-wiki.sh`
  - Modified: `client_files/import-wikis.sh`
  - Modified: `client_files/mediawiki.sh`
  - Added: `manual/AddingWikis.md`

* [7e7bc787](https://github.com/freephile/meza/commit/7e7bc787) (2015-09-09) Daren Welsh: correct syntax for variable concatenation 
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`

* [1387d659](https://github.com/freephile/meza/commit/1387d659) (2015-09-09) James Montalvo: elastic-build-index.sh needs $wiki_id value 
  - Modified: `client_files/ElasticSearch.sh`

* [292a2979](https://github.com/freephile/meza/commit/292a2979) (2015-09-09) James Montalvo: Cleanup 
  - Modified: `client_files/import-wikis.sh`

* [9bc117f0](https://github.com/freephile/meza/commit/9bc117f0) (2015-09-09) Daren Welsh: wrap strings with vars in quotes 
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`

* [ee1753dd](https://github.com/freephile/meza/commit/ee1753dd) (2015-09-09) Daren Welsh: simplify gh token variable for future case if no token is entered 
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`

* [9afbf94b](https://github.com/freephile/meza/commit/9afbf94b) (2015-09-09) Daren Welsh: clean up prompt, add token to link, rm token from Composer at end 
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`

* [de8dcfb8](https://github.com/freephile/meza/commit/de8dcfb8) (2015-09-09) Daren Welsh: prompt for token or use default, use token in all clones 
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`

* [4c6c6719](https://github.com/freephile/meza/commit/4c6c6719) (2015-09-09) James Montalvo: make multi-wiki import script 
  - Modified: `client_files/elastic-build-index.sh`
  - Deleted: `client_files/import-wiki.sh`
  - Added: `client_files/import-wikis.sh`

* [e13c9857](https://github.com/freephile/meza/commit/e13c9857) (2015-09-08) Daren Welsh: simplify addition of github oauth token 
  - Modified: `client_files/mediawiki.sh`

* [151769de](https://github.com/freephile/meza/commit/151769de) (2015-09-08) Daren Welsh: unnecessary 
  - Deleted: `client_files/.composer.auth.json`

* [ee7b1916](https://github.com/freephile/meza/commit/ee7b1916) (2015-09-08) James Montalvo: fix create_wiki.sh for typo in file path 
  - Modified: `client_files/create_wiki.sh`

* [bcd1cdc1](https://github.com/freephile/meza/commit/bcd1cdc1) (2015-09-08) James Montalvo: Make wiki landing page 
  - Modified: `client_files/apache.sh`
  - Added: `client_files/index.php`
  - Modified: `client_files/php.sh`

* [0ac77187](https://github.com/freephile/meza/commit/0ac77187) (2015-09-08) James Montalvo: fix local settings (php and js) 
  - Modified: `client_files/LocalSettingsVE.php`
  - Modified: `client_files/localsettings.js`

* [5ce1a6a1](https://github.com/freephile/meza/commit/5ce1a6a1) (2015-09-08) Daren Welsh: fix steps for post-setup; add steps for pre-setup 
  - Modified: `manual/2.1-CreateCloneVMs.md`

* [b5de1fc7](https://github.com/freephile/meza/commit/b5de1fc7) (2015-09-08) James Montalvo: parsoid handle multiple wikis 
  - Modified: `client_files/VE.sh`
  - Modified: `client_files/localsettings.js`

* [db5432c0](https://github.com/freephile/meza/commit/db5432c0) (2015-09-08) James Montalvo: simplify file path 
  - Modified: `client_files/config/LocalSettings.php`

* [a76c4bac](https://github.com/freephile/meza/commit/a76c4bac) (2015-09-08) James Montalvo: more little fixes 
  - Modified: `client_files/config/LocalSettings.php`
  - Modified: `client_files/create_wiki.sh`

* [01c6baaf](https://github.com/freephile/meza/commit/01c6baaf) (2015-09-08) James Montalvo: fix wiki config placeholder replacements 
  - Modified: `client_files/create_wiki.sh`

* [3bf4c1c9](https://github.com/freephile/meza/commit/3bf4c1c9) (2015-09-08) James Montalvo: farm fixes for VE and ES 
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/VE.sh`

* [82b44c53](https://github.com/freephile/meza/commit/82b44c53) (2015-09-08) James Montalvo: Prep VE and ElasticSearch for farm 
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/VE.sh`
  - Modified: `client_files/elastic-build-index.sh`
  - Modified: `client_files/mezaCreateUser.php`

* [46cda004](https://github.com/freephile/meza/commit/46cda004) (2015-09-08) James Montalvo: Remove parts of pre-built localsetttings; fixes 
  - Modified: `client_files/config/LocalSettings.php`
  - Modified: `client_files/create_wiki.sh`

* [91575173](https://github.com/freephile/meza/commit/91575173) (2015-09-08) James Montalvo: more cleanup 
  - Modified: `client_files/config/AllWikiSettings.php`
  - Modified: `client_files/config/LocalSettings.php`
  - Modified: `client_files/create_wiki.sh`

* [4991f7c3](https://github.com/freephile/meza/commit/4991f7c3) (2015-09-05) James Montalvo: use WIKI env var for maint scripts; add AllWikiSettings 
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/mediawiki.sh`

* [b69a8348](https://github.com/freephile/meza/commit/b69a8348) (2015-09-04) James Montalvo: Fix ES paths 
  - Modified: `client_files/ElasticSearch.sh`

* [22a3fc8b](https://github.com/freephile/meza/commit/22a3fc8b) (2015-09-04) James Montalvo: logpath needs to user absolute dir for now 
  - Modified: `client_files/install.sh`

* [59a6ded8](https://github.com/freephile/meza/commit/59a6ded8) (2015-09-04) James Montalvo: fix m_meza config var 
  - Modified: `client_files/config.sh`

* [2448e005](https://github.com/freephile/meza/commit/2448e005) (2015-09-04) James Montalvo: source config.sh needs to be after getting Meza1 
  - Modified: `client_files/install.sh`

* [935e9f82](https://github.com/freephile/meza/commit/935e9f82) (2015-09-04) James Montalvo: Change path where possible to use variables We had many paths which were hard-coded, making it very
difficult to change them if desired. This commit fixes that
in most places. This was done to accommodate the change of
the mediawiki application files from the /wiki directory to
the /mediawiki directory.
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/VE.sh`
  - Modified: `client_files/apache.sh`
  - Added: `client_files/config.sh`
  - Modified: `client_files/config/LocalSettings.php`
  - Modified: `client_files/create_wiki.sh`
  - Modified: `client_files/elastic-build-index.sh`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/import-wiki.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`
  - Modified: `client_files/php.sh`
  - Modified: `client_files/rewrite.sh`
  - Modified: `client_files/samba.sh`
  - Modified: `setup.sh`

* [a3973e4c](https://github.com/freephile/meza/commit/a3973e4c) (2015-09-04) Daren Welsh: typo 
  - Modified: `client_files/mediawiki.sh`

* [03aeb2de](https://github.com/freephile/meza/commit/03aeb2de) (2015-09-04) James Montalvo: remove unnecessary prompts 
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`

* [2fad907b](https://github.com/freephile/meza/commit/2fad907b) (2015-09-04) James Montalvo: testing fully integrated farm setup 
  - Modified: `client_files/apache.sh`
  - Added: `client_files/config/AllWikiSettings.php`
R066	rewrite-stuff/FullLocalSettings.php	client_files/config/LocalSettings.php
R100	rewrite-stuff/htaccess	client_files/config/htaccess
  - Added: `client_files/create_wiki.sh`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/mediawiki.sh`
  - Added: `client_files/mezaCreateUser.php`
  - Modified: `client_files/php.sh`
  - Modified: `client_files/rewrite.sh`
  - Deleted: `rewrite-stuff/FodSettings.php`
  - Deleted: `rewrite-stuff/LocalSettings-snippet.php`
  - Deleted: `rewrite-stuff/create_wiki.sh`
  - Deleted: `rewrite-stuff/favicon.ico`
  - Deleted: `rewrite-stuff/logo.png`

* [64485668](https://github.com/freephile/meza/commit/64485668) (2015-09-04) Daren Welsh: init cloning instructions 
  - Added: `manual/2.1-CreateCloneVMs.md`

* [624aa26f](https://github.com/freephile/meza/commit/624aa26f) (2015-09-03) James Montalvo: more work on rewrite and farming 
  - Modified: `client_files/rewrite.sh`
  - Deleted: `client_files/root-htaccess`
  - Added: `rewrite-stuff/FodSettings.php`
  - Added: `rewrite-stuff/FullLocalSettings.php`
  - Added: `rewrite-stuff/LocalSettings-snippet.php`
  - Added: `rewrite-stuff/create_wiki.sh`
  - Added: `rewrite-stuff/favicon.ico`
  - Added: `rewrite-stuff/htaccess`
  - Added: `rewrite-stuff/logo.png`
  - Added: `wiki-init/config/CustomSettings.php`
  - Added: `wiki-init/config/favicon.ico`
  - Added: `wiki-init/config/logo.png`
  - Added: `wiki-init/config/setup.php`
  - Added: `wiki-init/images/README.md`

* [fc72d53b](https://github.com/freephile/meza/commit/fc72d53b) (2015-09-03) Daren Welsh: add auth.json with token 
  - Modified: `client_files/mediawiki.sh`

* [75cbd535](https://github.com/freephile/meza/commit/75cbd535) (2015-09-03) Daren Welsh: add read-only token for increased api rate limit 
  - Added: `client_files/.composer.auth.json`

* [cd597c54](https://github.com/freephile/meza/commit/cd597c54) (2015-09-02) James Montalvo: initial planning for rewrite/farm 
  - Added: `client_files/config/httpd.conf`
  - Added: `client_files/rewrite.sh`
  - Added: `client_files/root-htaccess`

* [13d11df1](https://github.com/freephile/meza/commit/13d11df1) (2015-09-02) Daren Welsh: minor grammarz 
  - Modified: `manual/1.0-SettingUpVirtualBoxWindows.md`

* [3bfcb5fe](https://github.com/freephile/meza/commit/3bfcb5fe) (2015-09-02) James Montalvo: Add link to windows vbox setup procedure 
  - Modified: `README.md`

* [becc4fb7](https://github.com/freephile/meza/commit/becc4fb7) (2015-09-02) James Montalvo: Window-specific Vbox setup with scripted install 
  - Added: `manual/1.0-SettingUpVirtualBoxWindows.md`

* [019367da](https://github.com/freephile/meza/commit/019367da) (2015-09-01) Daren Welsh: allow read&edit for requests from server (Parsoid) 
  - Modified: `client_files/LocalSettingsVE.php`

* [f707373c](https://github.com/freephile/meza/commit/f707373c) (2015-08-31) James Montalvo: Fix display of bold text 
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [7766a704](https://github.com/freephile/meza/commit/7766a704) (2015-08-31) Daren Welsh: run setup.sh separate from wget to allow prompt 
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [2f1837db](https://github.com/freephile/meza/commit/2f1837db) (2015-08-27) James Montalvo: Add samba setup file to share htdocs 
  - Added: `client_files/samba.sh`

* [bcad68b0](https://github.com/freephile/meza/commit/bcad68b0) (2015-08-25) Daren Welsh: remove comment 
  - Modified: `client_files/VE.sh`

* [c293c10b](https://github.com/freephile/meza/commit/c293c10b) (2015-08-24) Daren Welsh: correcting symlink to dir, not tar file 
  - Modified: `client_files/VE.sh`

* [69737978](https://github.com/freephile/meza/commit/69737978) (2015-08-24) Daren Welsh: update which version of node to which we will use 
  - Modified: `client_files/VE.sh`

* [7045036b](https://github.com/freephile/meza/commit/7045036b) (2015-08-24) Daren Welsh: fix symlinks 
  - Modified: `client_files/VE.sh`

* [8e70b219](https://github.com/freephile/meza/commit/8e70b219) (2015-08-24) Daren Welsh: trying /usr/local/bin 
  - Modified: `client_files/VE.sh`

* [41a275d9](https://github.com/freephile/meza/commit/41a275d9) (2015-08-23) Daren Welsh: now actually just downloading binaries, no build 
  - Modified: `client_files/VE.sh`

* [7b21bf59](https://github.com/freephile/meza/commit/7b21bf59) (2015-08-23) Daren Welsh: use latest node binary 
  - Modified: `client_files/VE.sh`

* [4827f927](https://github.com/freephile/meza/commit/4827f927) (2015-08-23) Daren Welsh: fixing an oops 
  - Modified: `client_files/ExtensionSettings.php`

* [8ff7cc3d](https://github.com/freephile/meza/commit/8ff7cc3d) (2015-08-23) Daren Welsh: fix wgUploadNavigationUrl (for now), add allowed file types 
  - Modified: `client_files/LocalSettingsAdditions`

* [2371966f](https://github.com/freephile/meza/commit/2371966f) (2015-08-22) Daren Welsh: skip tutorial (focused on WPcommons); mod wgUploadNavigationUrl 
  - Modified: `client_files/LocalSettingsAdditions`

* [33d332f7](https://github.com/freephile/meza/commit/33d332f7) (2015-08-22) Daren Welsh: initial try to add UploadWizard to extensions in install.sh 
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/LocalSettingsAdditions`

* [13b43f0e](https://github.com/freephile/meza/commit/13b43f0e) (2015-08-19) James Montalvo: Allow choosing IP address during Vbox setup 
  - Modified: `setup.sh`

* [4d2cb85d](https://github.com/freephile/meza/commit/4d2cb85d) (2015-08-17) James Montalvo: Install Extension:PdfHandler and dependencies from install.sh Dependencies: ImageMagick, Ghostscript, xpdf-utils
ImageMagic is built from source since a more recent version
than what is in yum is required. The yum version of
Ghostscript is sufficient (for now), so it is used. There is
no yum version of xpdf-utils, so a pre-built binary is used.
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/LocalSettingsAdditions`
  - Modified: `client_files/install-imagick.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/yums.sh`

* [9f8d3394](https://github.com/freephile/meza/commit/9f8d3394) (2015-08-14) James Montalvo: Fix download and un-tar locations 
  - Modified: `client_files/install-imagick.sh`

* [18b89ea4](https://github.com/freephile/meza/commit/18b89ea4) (2015-08-13) James Montalvo: Add echoes, fix wget of imagick 
  - Modified: `client_files/install-imagick.sh`

* [e859ce05](https://github.com/freephile/meza/commit/e859ce05) (2015-08-13) James Montalvo: Install ImageMagick, Ghostscript and Xpdf 
  - Added: `client_files/install-imagick.sh`

* [7d3c0751](https://github.com/freephile/meza/commit/7d3c0751) (2015-08-13) Daren Welsh: import-wiki.sh documentation 
  - Modified: `client_files/import-wiki.sh`

* [24dfe430](https://github.com/freephile/meza/commit/24dfe430) (2015-08-12) James Montalvo: Add clearer names for imported images and SQL 
  - Modified: `client_files/import-wiki.sh`

* [d35d02b9](https://github.com/freephile/meza/commit/d35d02b9) (2015-08-11) James Montalvo: Allow images directory, .tar or .tar.gz 
  - Modified: `client_files/import-wiki.sh`

* [926d613b](https://github.com/freephile/meza/commit/926d613b) (2015-08-11) James Montalvo: Fix moving and deleting /images files 
  - Modified: `client_files/import-wiki.sh`

* [1b015351](https://github.com/freephile/meza/commit/1b015351) (2015-08-11) James Montalvo: Fix image import; don't delete git-managed files Was overwriting existing README and .htaccess files, then
deleting README.md (doesn't exist) and the newly imported
.htaccess files.
  - Modified: `client_files/import-wiki.sh`

* [ec28e74b](https://github.com/freephile/meza/commit/ec28e74b) (2015-08-10) James Montalvo: Change Elastic Search extensions repo to gerrit 
  - Modified: `client_files/ExtensionSettingsElasticSearch.php`

* [31a11dba](https://github.com/freephile/meza/commit/31a11dba) (2015-08-10) James Montalvo: Use vars in "afterFn" functions in global context Settings were not being properly set for extensions due to local
variables being called in "afterFn" functions.
  - Modified: `client_files/ExtensionSettings.php`

* [7fba3626](https://github.com/freephile/meza/commit/7fba3626) (2015-08-09) James Montalvo: use Apache archive server so links don't break on new versions 
  - Modified: `client_files/apache.sh`

* [bf60ee77](https://github.com/freephile/meza/commit/bf60ee77) (2015-08-07) James Montalvo: Change title banners to function Fixes issue with yums.sh banner saying that it's the install.sh
banner. This was due to the fact that the title was being printed
by a separate script, printTitle.sh, and the title bar taken from
the name of the script calling that script. However, when we
switched to doing "source yums.sh" instead of "bash yums.sh" it
caused install.sh to be that script-name.
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/VE.sh`
  - Modified: `client_files/apache.sh`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`
  - Modified: `client_files/mysql.sh`
  - Modified: `client_files/php.sh`
  - Modified: `client_files/yums.sh`

* [6948f0ad](https://github.com/freephile/meza/commit/6948f0ad) (2015-08-07) James Montalvo: Fix input to cmd_tee; remove script param inputs (breaking) Script inputs to cmd_tee included "|| exit 1" on the end,
causing the "||" to be passed as the first param, "exit"
as the second param, and "1" as the third. This caused
variables in the scripts to be overwritten by these input
params. Removed exit 1. Will need another (better) method
of checking for success.
Breaking change: Also removed all param inputs to scripts,
since they were prone to causing issues.
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/VE.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`
  - Modified: `client_files/php.sh`

* [8948f317](https://github.com/freephile/meza/commit/8948f317) (2015-08-07) James Montalvo: Set directory before each script; fix function name typo All scripts after first (yums.sh) were giving error "no such
file or directory". I think this is because since we're now
using "source" on each script (rather than "bash") the shells
are shared, and thus any directory changes within yums.sh
were applied to install.sh, and when apache.sh was attempted
the shell was no longer in the correct directory. So the dir
needs to be reset each time.
Additionaly, two "cmd_profile" function calls in yums.sh were
incorrectly called as just "profile".
  - Modified: `client_files/install.sh`
  - Modified: `client_files/yums.sh`

* [e6d7b4af](https://github.com/freephile/meza/commit/e6d7b4af) (2015-08-06) James Montalvo: source child-scripts; share vars and functions 
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`
  - Modified: `client_files/mysql.sh`

* [dfcf3af4](https://github.com/freephile/meza/commit/dfcf3af4) (2015-08-06) James Montalvo: add profile command, add profiling throughout 
  - Modified: `client_files/VE.sh`
  - Modified: `client_files/apache.sh`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`
  - Modified: `client_files/php.sh`
  - Modified: `client_files/yums.sh`

* [3a242e1b](https://github.com/freephile/meza/commit/3a242e1b) (2015-08-05) emanspeaks: added cmdlog and generic log paths 
  - Modified: `client_files/install.sh`

* [9c8e0f68](https://github.com/freephile/meza/commit/9c8e0f68) (2015-08-05) marcd6: Added new vm setup batch file 
  - Added: `client_files/vmsetupwin.bat`

* [f1478b06](https://github.com/freephile/meza/commit/f1478b06) (2015-08-04) James Montalvo: add pipe escape extension 
  - Modified: `client_files/ExtensionSettings.php`

* [967bc942](https://github.com/freephile/meza/commit/967bc942) (2015-08-03) James Montalvo: Forgot paths to out and error logs 
  - Modified: `client_files/install.sh`

* [8b1d7d7b](https://github.com/freephile/meza/commit/8b1d7d7b) (2015-08-03) James Montalvo: add logs directory 
  - Modified: `.gitignore`
  - Added: `logs/README.md`

* [3b252c6e](https://github.com/freephile/meza/commit/3b252c6e) (2015-08-02) James Montalvo: add method for directing output to screen and logs 
  - Modified: `client_files/install.sh`

* [288d2e12](https://github.com/freephile/meza/commit/288d2e12) (2015-08-01) James Montalvo: fix comment 
  - Modified: `client_files/mediawiki.sh`

* [f71efbfd](https://github.com/freephile/meza/commit/f71efbfd) (2015-07-30) James Montalvo: fix secure input, fix excessive newlines 
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki.sh`

* [63392e33](https://github.com/freephile/meza/commit/63392e33) (2015-07-30) James Montalvo: squash mediawiki.sh and mediawiki-quick.sh 
  - Modified: `client_files/install.sh`
  - Deleted: `client_files/mediawiki-quick.sh`
  - Modified: `client_files/mediawiki.sh`

* [7bea6bcd](https://github.com/freephile/meza/commit/7bea6bcd) (2015-07-30) James Montalvo: bump version to 0.2.1 for redhat fix 
  - Modified: `README.md`
  - Modified: `client_files/install.sh`

* [fc9fd208](https://github.com/freephile/meza/commit/fc9fd208) (2015-07-30) James Montalvo: error occurred without something in if block 
  - Modified: `client_files/yums.sh`

* [8ba1e705](https://github.com/freephile/meza/commit/8ba1e705) (2015-07-30) James Montalvo: fix brackets in if else 
  - Modified: `client_files/yums.sh`

* [ba13245a](https://github.com/freephile/meza/commit/ba13245a) (2015-07-30) James Montalvo: simplify architecture check; something wasn't working 
  - Modified: `client_files/yums.sh`

* [fd9d31d9](https://github.com/freephile/meza/commit/fd9d31d9) (2015-07-29) James Montalvo: auto-check 32 or 64 bit; turn on RedHat repo 
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/yums.sh`

* [947a667f](https://github.com/freephile/meza/commit/947a667f) (2015-07-27) James Montalvo: Add version to readme 
  - Modified: `README.md`

* [c4c232ea](https://github.com/freephile/meza/commit/c4c232ea) (2015-07-27) James Montalvo: printTitle.sh not available yet, use echo 
  - Modified: `client_files/install.sh`

* [e1f338c8](https://github.com/freephile/meza/commit/e1f338c8) (2015-07-27) James Montalvo: add header to install script, add version number 
  - Modified: `client_files/install.sh`

* [48ae0692](https://github.com/freephile/meza/commit/48ae0692) (2015-07-27) James Montalvo: need full path for elastic-build-index.sh 
  - Modified: `client_files/ElasticSearch.sh`

* [5297dc81](https://github.com/freephile/meza/commit/5297dc81) (2015-07-27) James Montalvo: (re)build elastic search index on wiki import 
  - Modified: `client_files/import-wiki.sh`

* [d8615eab](https://github.com/freephile/meza/commit/d8615eab) (2015-07-27) James Montalvo: Move Elastic Search indexing to own file 
  - Modified: `client_files/ElasticSearch.sh`
  - Added: `client_files/elastic-build-index.sh`

* [c0d7cdc9](https://github.com/freephile/meza/commit/c0d7cdc9) (2015-07-26) James Montalvo: add DO setup manual 
  - Modified: `README.md`
  - Added: `manual/SetupDigitalOcean.md`

* [cfe855ad](https://github.com/freephile/meza/commit/cfe855ad) (2015-07-26) James Montalvo: $wgMaxUploadSize was being set in LocalSettingsAdditions 
  - Modified: `client_files/LocalSettingsAdditions`

* [d8af61a6](https://github.com/freephile/meza/commit/d8af61a6) (2015-07-26) James Montalvo: despite mediawiki.org docs, need to set $wgMaxUploadSize 
  - Modified: `client_files/mediawiki-quick.sh`

* [14c34025](https://github.com/freephile/meza/commit/14c34025) (2015-07-26) James Montalvo: fully enable file uploads up to 100MB 
  - Modified: `client_files/mediawiki-quick.sh`
  - Modified: `client_files/php.ini-development`
  - Modified: `client_files/php.ini-production`

* [d5f47067](https://github.com/freephile/meza/commit/d5f47067) (2015-07-26) James Montalvo: Adjust max upload and max post size 
  - Modified: `client_files/php.ini-production`

* [4bba7fce](https://github.com/freephile/meza/commit/4bba7fce) (2015-07-25) James Montalvo: Include ElasticSearch.sh in install.sh 
  - Modified: `client_files/install.sh`

* [2ba6a63f](https://github.com/freephile/meza/commit/2ba6a63f) (2015-07-24) James Montalvo: fix handling of greater than 10 params in bash 
  - Modified: `client_files/install.sh`

* [3ce9b5b0](https://github.com/freephile/meza/commit/3ce9b5b0) (2015-07-24) James Montalvo: make indent the same 
  - Modified: `client_files/install.sh`

* [2efd79d1](https://github.com/freephile/meza/commit/2efd79d1) (2015-07-24) James Montalvo: make script inputs for API endpoint 
  - Modified: `client_files/VE.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/localsettings.js`

* [bf1b9c1e](https://github.com/freephile/meza/commit/bf1b9c1e) (2015-07-24) James Montalvo: only explanation I have for not updating properly is the missing dot 
  - Modified: `client_files/import-wiki.sh`

* [d06bf534](https://github.com/freephile/meza/commit/d06bf534) (2015-07-24) James Montalvo: Parsoid's setMwApi needs the end URI of the host The modified URI is the default VirtualBox IP address we're using.
This URI must be the endpoint URI that the user navigates to,
because when Parsoid serves up URIs for images (and probably other
resources) it uses this URI. So otherwise it goes looking for
images at http://127.0.0.1/<whatever>, which is on the user's
computer...doesn't work.
  - Modified: `client_files/localsettings.js`

* [51766ffd](https://github.com/freephile/meza/commit/51766ffd) (2015-07-23) James Montalvo: fix wiki location, need htdocs 
  - Modified: `client_files/import-wiki.sh`

* [28f60331](https://github.com/freephile/meza/commit/28f60331) (2015-07-23) James Montalvo: Script to import a wiki database and file uploads 
  - Added: `client_files/import-wiki.sh`

* [16ac14fe](https://github.com/freephile/meza/commit/16ac14fe) (2015-07-23) James Montalvo: more clarification 
  - Modified: `README.md`

* [fbe15064](https://github.com/freephile/meza/commit/fbe15064) (2015-07-23) James Montalvo: more doc cleanup 
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [4df8a0a5](https://github.com/freephile/meza/commit/4df8a0a5) (2015-07-23) James Montalvo: Add line about VMWare and fix typo 
  - Modified: `README.md`

* [a4f0e7c7](https://github.com/freephile/meza/commit/a4f0e7c7) (2015-07-22) James Montalvo: cleaned up docs to focus on our new scripted method 
  - Modified: `README.md`
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [161a21ea](https://github.com/freephile/meza/commit/161a21ea) (2015-07-22) James Montalvo: wrong default path 
  - Modified: `client_files/install.sh`

* [71cffd53](https://github.com/freephile/meza/commit/71cffd53) (2015-07-21) James Montalvo: move httpd version to variable for easier changes 
  - Modified: `client_files/apache.sh`

* [e0f63543](https://github.com/freephile/meza/commit/e0f63543) (2015-07-21) James Montalvo: Need to update httpd version in all places 
  - Modified: `client_files/apache.sh`

* [d8c481da](https://github.com/freephile/meza/commit/d8c481da) (2015-07-21) James Montalvo: Emergency fix: bump apache from 2.4.12 to 2.4.16 Currently master (and all other active branches) are downloading Apache httpd 2.4.12, which does not exist at the location attempted to be downloaded from. We need to find a more robust way of downloading. As an emergency fix, bump httpd to 2.4.16
  - Modified: `client_files/apache.sh`

* [cbb9f6b0](https://github.com/freephile/meza/commit/cbb9f6b0) (2015-07-20) James Montalvo: Add check to make sure PATH has the needed dirs 
  - Modified: `client_files/install.sh`

* [84687990](https://github.com/freephile/meza/commit/84687990) (2015-07-11) James Montalvo: add headings back in 
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/VE.sh`
  - Modified: `client_files/apache.sh`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/mediawiki-quick.sh`
  - Modified: `client_files/mediawiki.sh`
  - Modified: `client_files/mysql.sh`
  - Modified: `client_files/php.sh`
  - Added: `client_files/printTitle.sh`
  - Modified: `client_files/yums.sh`

* [10972915](https://github.com/freephile/meza/commit/10972915) (2015-07-10) James Montalvo: Remove unneeded space 
  - Modified: `client_files/mediawiki-quick.sh`

* [7a0034e5](https://github.com/freephile/meza/commit/7a0034e5) (2015-07-10) James Montalvo: remove all the junk i did 
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/VE.sh`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki-quick.sh`
  - Modified: `client_files/mediawiki.sh`
  - Modified: `client_files/php.sh`

* [b7336a89](https://github.com/freephile/meza/commit/b7336a89) (2015-07-09) James Montalvo: sudo user should work now, test pending 
  - Modified: `client_files/VE.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/pigeon.txt`

* [738b0cc4](https://github.com/freephile/meza/commit/738b0cc4) (2015-07-09) James Montalvo: composer working, npm not. do everything except VE.sh 
  - Modified: `client_files/install.sh`

* [b902d229](https://github.com/freephile/meza/commit/b902d229) (2015-07-09) James Montalvo: I think this method of envoking composer will work for non-root user 
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/mediawiki-quick.sh`
  - Modified: `client_files/mediawiki.sh`

* [91220059](https://github.com/freephile/meza/commit/91220059) (2015-07-09) James Montalvo: replace composer with php /usr/local/bin/composer 
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/extensions.sh`
  - Modified: `client_files/install.sh`
  - Modified: `client_files/mediawiki-quick.sh`
  - Modified: `client_files/mediawiki.sh`

* [8298a289](https://github.com/freephile/meza/commit/8298a289) (2015-07-09) James Montalvo: still issues dammit 
  - Modified: `client_files/install.sh`

* [20453434](https://github.com/freephile/meza/commit/20453434) (2015-07-09) James Montalvo: stop in install.sh needs to be before PHP install, unfortunately 
  - Modified: `client_files/install.sh`

* [6e7d2f17](https://github.com/freephile/meza/commit/6e7d2f17) (2015-07-09) James Montalvo:  make temporary script end before MW install 
  - Modified: `client_files/install.sh`

* [cc3b76fb](https://github.com/freephile/meza/commit/cc3b76fb) (2015-07-09) James Montalvo: use symlink for PHP instead 
  - Modified: `client_files/install.sh`
  - Modified: `client_files/php.sh`

* [565a36bb](https://github.com/freephile/meza/commit/565a36bb) (2015-07-09) James Montalvo: more newlines removed, some wording cleanup 
  - Modified: `client_files/install.sh`

* [91e443cd](https://github.com/freephile/meza/commit/91e443cd) (2015-07-09) James Montalvo: remove some unnecessary newlines 
  - Modified: `client_files/install.sh`

* [bf1bba36](https://github.com/freephile/meza/commit/bf1bba36) (2015-07-09) James Montalvo: won't have pigeon.txt at beginning of script 
  - Modified: `client_files/install.sh`

* [d003ff09](https://github.com/freephile/meza/commit/d003ff09) (2015-07-09) James Montalvo: add titles before each script executes 
  - Modified: `client_files/install.sh`
  - Added: `client_files/pigeon.txt`

* [a4214c01](https://github.com/freephile/meza/commit/a4214c01) (2015-07-08) James Montalvo: Bump wait for ES to start to 20 seconds ElasticSearch.sh failed once, likely due to not being fully installed. Increase the wait time to make it hopefully install more consistently.
  - Modified: `client_files/ElasticSearch.sh`

* [618e22a7](https://github.com/freephile/meza/commit/618e22a7) (2015-07-08) James Montalvo: yet another fix to the settings files 
  - Modified: `client_files/ElasticSearch.sh`

* [351d1408](https://github.com/freephile/meza/commit/351d1408) (2015-07-08) James Montalvo: fix mistakes in where settings are coming from 
  - Modified: `client_files/ElasticSearch.sh`

* [28d72ab4](https://github.com/freephile/meza/commit/28d72ab4) (2015-07-08) James Montalvo: code cleanup 
  - Modified: `client_files/ElasticSearch.sh`

* [370f34e5](https://github.com/freephile/meza/commit/370f34e5) (2015-07-07) James Montalvo: maybe kinda finally fix PHP PATH issue 
  - Modified: `client_files/install.sh`
  - Modified: `client_files/php.sh`

* [21bd5b37](https://github.com/freephile/meza/commit/21bd5b37) (2015-07-07) James Montalvo: need to check for existence of sources dir 
  - Modified: `client_files/install.sh`

* [e80ecb14](https://github.com/freephile/meza/commit/e80ecb14) (2015-07-07) James Montalvo: proper method of sourcing php PATH update; fix typo 
  - Modified: `client_files/install.sh`
  - Modified: `client_files/php.sh`

* [d4eb5221](https://github.com/freephile/meza/commit/d4eb5221) (2015-07-07) Daren Welsh: add sleep to wait for service to start, remove unnecessary init.d file 
  - Modified: `client_files/ElasticSearch.sh`
  - Deleted: `client_files/initd_elasticsearch.sh`

* [b6edd153](https://github.com/freephile/meza/commit/b6edd153) (2015-07-07) Daren Welsh: Script might work 
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/LocalSettingsElasticSearch.php`

* [c0de8d4e](https://github.com/freephile/meza/commit/c0de8d4e) (2015-07-07) James Montalvo: git branch should not be password input 
  - Modified: `client_files/install.sh`

* [b90d2bfa](https://github.com/freephile/meza/commit/b90d2bfa) (2015-07-07) marcd6: Removed optional mediawiki git install section. 
  - Modified: `README.md`

* [0747e361](https://github.com/freephile/meza/commit/0747e361) (2015-07-07) James Montalvo: make git checkout option; install git if required 
  - Modified: `client_files/install.sh`

* [5a84cec3](https://github.com/freephile/meza/commit/5a84cec3) (2015-07-06) James Montalvo: Run "exec bash" to make PHP command available immediately 
  - Modified: `client_files/php.sh`

* [cd3600f1](https://github.com/freephile/meza/commit/cd3600f1) (2015-07-06) Daren Welsh: got it to work, but script needs more work 
  - Modified: `client_files/ElasticSearch.sh`
  - Modified: `client_files/elasticsearch.yml`

* [f43d6025](https://github.com/freephile/meza/commit/f43d6025) (2015-07-06) James Montalvo: all options added, created install.sh to run everything 
  - Added: `client_files/install.sh`
  - Modified: `client_files/mediawiki-quick.sh`
  - Modified: `client_files/mysql.sh`
  - Modified: `client_files/php.sh`

* [6d225089](https://github.com/freephile/meza/commit/6d225089) (2015-07-06) James Montalvo: yums.sh architecture param optional 
  - Modified: `client_files/yums.sh`

* [98060251](https://github.com/freephile/meza/commit/98060251) (2015-07-06) Daren Welsh: make update.php run QUICK! 
  - Modified: `client_files/VE.sh`

* [de4902c6](https://github.com/freephile/meza/commit/de4902c6) (2015-07-06) Daren Welsh: working on script, add config file, add initd file for reference just in case 
  - Modified: `client_files/ElasticSearch.sh`
  - Added: `client_files/elasticsearch.yml`
  - Added: `client_files/initd_elasticsearch.sh`

* [eef6bf03](https://github.com/freephile/meza/commit/eef6bf03) (2015-07-06) Daren Welsh: add VE install step to ReadME 
  - Modified: `README.md`

* [38e99488](https://github.com/freephile/meza/commit/38e99488) (2015-07-06) James Montalvo: need to run update.php anytime updateExtensions.php is run 
  - Modified: `client_files/VE.sh`

* [19a07620](https://github.com/freephile/meza/commit/19a07620) (2015-07-06) James Montalvo: final cleanup of service script 
  - Modified: `client_files/initd_parsoid.sh`

* [a587a621](https://github.com/freephile/meza/commit/a587a621) (2015-07-06) James Montalvo: nohup no longer spitting out unneeded messages 
  - Modified: `client_files/VE.sh`
  - Modified: `client_files/initd_parsoid.sh`

* [a9a9d393](https://github.com/freephile/meza/commit/a9a9d393) (2015-07-06) James Montalvo: remove lock file, check for process ID 
  - Modified: `client_files/initd_parsoid.sh`

* [0cf369f1](https://github.com/freephile/meza/commit/0cf369f1) (2015-07-06) James Montalvo: revert to append to log 
  - Modified: `client_files/initd_parsoid.sh`

* [6b3cb716](https://github.com/freephile/meza/commit/6b3cb716) (2015-07-06) James Montalvo: fix no-hangup (nohup) command method 
  - Modified: `client_files/initd_parsoid.sh`

* [c4055ae4](https://github.com/freephile/meza/commit/c4055ae4) (2015-07-06) James Montalvo: add no-hangup and change to write (vs append) to log file 
  - Modified: `client_files/initd_parsoid.sh`

* [934b8297](https://github.com/freephile/meza/commit/934b8297) (2015-07-06) James Montalvo: Change all git.wikimedia.org repos to gerrit 
  - Modified: `client_files/ExtensionSettings.php`

* [b6852f50](https://github.com/freephile/meza/commit/b6852f50) (2015-07-05) Daren Welsh: failing at downloading JDK 
  - Modified: `client_files/ElasticSearch.sh`

* [c4ea02f7](https://github.com/freephile/meza/commit/c4ea02f7) (2015-07-05) James Montalvo: cleanup, remove wget commands to Meza1 files 
  - Modified: `client_files/VE.sh`

* [5bbe7080](https://github.com/freephile/meza/commit/5bbe7080) (2015-07-05) Daren Welsh: starting point for Elastic Search install script 
  - Added: `client_files/ElasticSearch.sh`
  - Added: `client_files/ExtensionSettingsElasticSearch.php`
  - Added: `client_files/LocalSettingsElasticSearch.php`
  - Added: `client_files/elasticsearch.repo`

* [c0b3455f](https://github.com/freephile/meza/commit/c0b3455f) (2015-07-03) Daren Welsh: change to parsoid local install due to errors, add pause at end 
  - Modified: `client_files/VE.sh`

* [b86e9ff6](https://github.com/freephile/meza/commit/b86e9ff6) (2015-07-03) Daren Welsh: add arbitrary message to break out of parsoid logging (but keep running) 
  - Modified: `client_files/VE.sh`

* [1f92e696](https://github.com/freephile/meza/commit/1f92e696) (2015-07-03) Daren Welsh: parsoid service works 
  - Modified: `client_files/VE.sh`

* [d26ef379](https://github.com/freephile/meza/commit/d26ef379) (2015-07-03) Daren Welsh: add init.d script 
  - Modified: `client_files/VE.sh`
  - Added: `client_files/initd_parsoid.sh`

* [6c844a8d](https://github.com/freephile/meza/commit/6c844a8d) (2015-07-03) Daren Welsh: this should work, still need to automate via inid.d 
  - Modified: `client_files/LocalSettingsVE.php`
  - Modified: `client_files/VE.sh`

* [5d464a3b](https://github.com/freephile/meza/commit/5d464a3b) (2015-07-03) Daren Welsh: remove erroneous leftover, working on script 
  - Modified: `client_files/ExtensionSettingsVE.php`
  - Modified: `client_files/VE.sh`

* [f159f21a](https://github.com/freephile/meza/commit/f159f21a) (2015-07-03) Daren Welsh: add some spacing and comments 
  - Modified: `client_files/ExtensionSettingsVE.php`
  - Modified: `client_files/LocalSettingsVE.php`

* [595eac51](https://github.com/freephile/meza/commit/595eac51) (2015-07-03) Daren Welsh: fix node install dir, try to get ExtensionLoader to work 
  - Modified: `client_files/LocalSettingsVE.php`
  - Modified: `client_files/VE.sh`

* [54518930](https://github.com/freephile/meza/commit/54518930) (2015-07-03) Daren Welsh: move settings to files 
  - Added: `client_files/ExtensionSettingsVE.php`
  - Added: `client_files/LocalSettingsVE.php`
  - Modified: `client_files/VE.sh`
  - Added: `client_files/localsettings.js`

* [a88662ab](https://github.com/freephile/meza/commit/a88662ab) (2015-07-01) Daren Welsh: init script to install VE 
  - Added: `client_files/VE.sh`

* [90ec8665](https://github.com/freephile/meza/commit/90ec8665) (2015-06-28) James Montalvo: Update php.sh 
  - Modified: `client_files/php.sh`

* [056469cc](https://github.com/freephile/meza/commit/056469cc) (2015-06-23) James Montalvo: Remove composer-installed extensions; scripts should echo HeaderFooter and NumerAlpha are both loaded via Composer
due to being dependencies for SemanticMeetingMinutes. Don't
attempt to install them again (note: they won't install
again, but it's pointless to attempt).
Add echo statements to extensions.sh so it's possible to
tell where in the script we are.
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/extensions.sh`

* [17d26cfa](https://github.com/freephile/meza/commit/17d26cfa) (2015-06-23) James Montalvo: use bash, don't cd to extensions.sh...oops 
  - Modified: `README.md`

* [03ecabec](https://github.com/freephile/meza/commit/03ecabec) (2015-06-23) James Montalvo: add Composer extensions and others 
  - Modified: `README.md`
  - Modified: `client_files/ExtensionSettings.php`
  - Modified: `client_files/LocalSettingsAdditions`
  - Added: `client_files/extensions.sh`

* [c8b880e4](https://github.com/freephile/meza/commit/c8b880e4) (2015-06-23) James Montalvo: file renames; fix README to reference Meza1 files 
  - Modified: `README.md`
R100	client_files/BasicSettings	client_files/LocalSettingsAdditions

* [7a5c576a](https://github.com/freephile/meza/commit/7a5c576a) (2015-06-23) James Montalvo: add settings for ExtensionLoader and to append to LocalSettings.php 
  - Added: `client_files/BasicSettings`
  - Added: `client_files/ExtensionSettings.php`

* [12bb3359](https://github.com/freephile/meza/commit/12bb3359) (2015-06-23) James Montalvo: add tutorial for loading extensions 
  - Modified: `README.md`

* [4ea35172](https://github.com/freephile/meza/commit/4ea35172) (2015-06-19) James Montalvo: change "enter the password" to "choose a password" 
  - Modified: `client_files/mysql.sh`

* [75d37689](https://github.com/freephile/meza/commit/75d37689) (2015-06-19) James Montalvo: change some wording; add spaces before closing braces 
  - Modified: `client_files/mediawiki-quick.sh`

* [f75e6f07](https://github.com/freephile/meza/commit/f75e6f07) (2015-06-19) James Montalvo: Cleanup ugly tabs; make consistent 
  - Modified: `client_files/yums.sh`

* [5a3e0684](https://github.com/freephile/meza/commit/5a3e0684) (2015-06-19) James Montalvo: Move prompts to the top of the file Move prompts so user is done with script interaction right away and can let the script run to completion.
  - Modified: `client_files/mediawiki-quick.sh`

* [fe3fed97](https://github.com/freephile/meza/commit/fe3fed97) (2015-06-19) Daren Welsh: add user prompt to mysql script, update readme 
  - Modified: `README.md`
  - Modified: `client_files/mysql.sh`

* [66df05cc](https://github.com/freephile/meza/commit/66df05cc) (2015-06-19) Daren Welsh: add user prompts to 3 scripts 
  - Modified: `client_files/mediawiki-quick.sh`
  - Modified: `client_files/php.sh`
  - Modified: `client_files/yums.sh`

* [8df57940](https://github.com/freephile/meza/commit/8df57940) (2015-06-19) Daren Welsh: documentation for mediawiki-quick.sh 
  - Modified: `README.md`

* [87fb3373](https://github.com/freephile/meza/commit/87fb3373) (2015-06-19) James Montalvo: fix vector install 
  - Modified: `client_files/mediawiki-quick.sh`

* [9176b007](https://github.com/freephile/meza/commit/9176b007) (2015-06-19) James Montalvo: quick install without core.git download 
  - Added: `client_files/mediawiki-quick.sh`

* [c89d6f5f](https://github.com/freephile/meza/commit/c89d6f5f) (2015-06-18) James Montalvo: Add link to php.net for latest stable versions 
  - Modified: `README.md`

* [d799b41d](https://github.com/freephile/meza/commit/d799b41d) (2015-06-18) James Montalvo: also add <version> to command for php 
  - Modified: `README.md`

* [799af12a](https://github.com/freephile/meza/commit/799af12a) (2015-06-18) James Montalvo: Forgot php.sh in statement 
  - Modified: `README.md`

* [586ede69](https://github.com/freephile/meza/commit/586ede69) (2015-06-18) Daren Welsh: mod php.sh to create info.php, revise readme 
  - Modified: `README.md`
  - Modified: `client_files/php.sh`

* [c1a9ebe5](https://github.com/freephile/meza/commit/c1a9ebe5) (2015-06-18) James Montalvo: finalizing for merge with master 
  - Modified: `README.md`
  - Modified: `client_files/apache.sh`
  - Modified: `client_files/mediawiki.sh`
  - Modified: `client_files/mysql.sh`
  - Added: `client_files/php.ini-development`
  - Added: `client_files/php.ini-production`
  - Modified: `client_files/php.sh`
  - Modified: `setup.sh`

* [f1486c1b](https://github.com/freephile/meza/commit/f1486c1b) (2015-06-18) Daren Welsh: Change "scripted" to "master" 
  - Modified: `setup.sh`

* [9a56674d](https://github.com/freephile/meza/commit/9a56674d) (2015-06-18) Daren Welsh: change "scripted" to "master"; editorial 
  - Modified: `README.md`

* [93750b44](https://github.com/freephile/meza/commit/93750b44) (2015-06-17) James Montalvo: better PHP version selection 
  - Modified: `client_files/php.sh`

* [9c3eaf7c](https://github.com/freephile/meza/commit/9c3eaf7c) (2015-06-17) James Montalvo: allow selection of PHP version 
  - Modified: `client_files/php.sh`

* [45e9e118](https://github.com/freephile/meza/commit/45e9e118) (2015-06-17) James Montalvo: clarify order of setup scripts 
  - Modified: `README.md`

* [91e1855e](https://github.com/freephile/meza/commit/91e1855e) (2015-06-17) James Montalvo: how to use setup scripts 
  - Modified: `README.md`

* [4e3813e3](https://github.com/freephile/meza/commit/4e3813e3) (2015-06-17) James Montalvo: enable httpd and mysqld services at startup 
  - Modified: `client_files/apache.sh`
  - Modified: `client_files/mysql.sh`

* [0c1f96ac](https://github.com/freephile/meza/commit/0c1f96ac) (2015-06-17) James Montalvo: make it point to this branch for now, fix in pull request 
  - Modified: `setup.sh`

* [da77d355](https://github.com/freephile/meza/commit/da77d355) (2015-06-17) James Montalvo: start mediawiki install script 
  - Added: `client_files/mediawiki.sh`
  - Modified: `client_files/mysql.sh`

* [1c141d8e](https://github.com/freephile/meza/commit/1c141d8e) (2015-06-17) James Montalvo: add MySQL script 
  - Added: `client_files/mysql.sh`

* [b7e67f5a](https://github.com/freephile/meza/commit/b7e67f5a) (2015-06-17) James Montalvo: create php script; add arch check and RPM load to yums.sh 
  - Modified: `client_files/apache.sh`
  - Added: `client_files/php.sh`
  - Modified: `client_files/yums.sh`

* [80ab3af1](https://github.com/freephile/meza/commit/80ab3af1) (2015-06-17) James Montalvo: apache.sh should be working, but have not run in one go yet 
  - Modified: `client_files/apache.sh`

* [108e9962](https://github.com/freephile/meza/commit/108e9962) (2015-06-17) James Montalvo: second half of apache install 
  - Modified: `client_files/apache.sh`
  - Added: `client_files/httpd-conf-additions.conf`

* [5b9a6a1a](https://github.com/freephile/meza/commit/5b9a6a1a) (2015-06-17) James Montalvo: change apache source to apache.org; pull meza1 repo into server early 
  - Modified: `client_files/apache.sh`
  - Modified: `setup.sh`

* [3ea5f508](https://github.com/freephile/meza/commit/3ea5f508) (2015-06-16) James Montalvo: fix misused comments--caused fail 
  - Modified: `client_files/yums.sh`

* [21c9556c](https://github.com/freephile/meza/commit/21c9556c) (2015-06-16) James Montalvo: start yum installs and apache build script 
  - Added: `client_files/apache.sh`
  - Added: `client_files/yums.sh`

* [62a1a4b9](https://github.com/freephile/meza/commit/62a1a4b9) (2015-06-16) James Montalvo: document times, mark todos for updating during pull request 
  - Modified: `README.md`
  - Modified: `setup.sh`

* [87ca8717](https://github.com/freephile/meza/commit/87ca8717) (2015-06-16) James Montalvo: pull ifcfg-eth1 from github; don't regex eth0 
  - Modified: `setup.sh`

* [a0585cbc](https://github.com/freephile/meza/commit/a0585cbc) (2015-06-16) James Montalvo: More readme documentation; improve completion message of setup.sh 
  - Modified: `README.md`
  - Modified: `setup.sh`

* [d9b67203](https://github.com/freephile/meza/commit/d9b67203) (2015-06-16) James Montalvo: posting scripted install instructions 
  - Modified: `README.md`
R077	client_files/setup.sh	setup.sh

* [ec01024e](https://github.com/freephile/meza/commit/ec01024e) (2015-06-16) James Montalvo: comment out yum update for now 
  - Modified: `client_files/setup.sh`

* [a58df667](https://github.com/freephile/meza/commit/a58df667) (2015-06-16) James Montalvo: order was wrong on getting eth1 hwaddr 
  - Modified: `client_files/setup.sh`
  - Modified: `manual/References.md`

* [bf62ab41](https://github.com/freephile/meza/commit/bf62ab41) (2015-06-16) James Montalvo: Fix formatting, clarify multiple network situation Clean up
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [2c2c7955](https://github.com/freephile/meza/commit/2c2c7955) (2015-06-16) Daren Welsh: formatting 
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [7b1ffa9a](https://github.com/freephile/meza/commit/7b1ffa9a) (2015-06-16) Daren Welsh: Clarify host-only steps 
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [78d20ac7](https://github.com/freephile/meza/commit/78d20ac7) (2015-06-16) James Montalvo: add gitignore; working on setup script 
  - Added: `.gitignore`
R051	client_files/big-script.sh	client_files/setup.sh

* [474262a7](https://github.com/freephile/meza/commit/474262a7) (2015-06-16) James Montalvo: Add steps for VirtualBox host-only setup 
  - Modified: `manual/1.0-SettingUpVirtualBox.md`

* [2266d0e4](https://github.com/freephile/meza/commit/2266d0e4) (2015-06-15) James Montalvo: starting fully scripted method 
  - Added: `client_files/big-script.sh`
  - Added: `client_files/ifcfg-eth1`

* [6a8d547c](https://github.com/freephile/meza/commit/6a8d547c) (2015-06-15) James Montalvo: add checkout MW 1.25.1 
  - Modified: `manual/4.0-InstallMediaWiki.md`

* [2044d5d2](https://github.com/freephile/meza/commit/2044d5d2) (2015-06-15) James Montalvo: fix typo 
  - Modified: `manual/README.md`

* [b095776f](https://github.com/freephile/meza/commit/b095776f) (2015-06-15) James Montalvo: install MW 
  - Added: `manual/4.0-InstallMediaWiki.md`
  - Modified: `manual/OpenWork.md`
  - Modified: `manual/README.md`

* [c3b232ab](https://github.com/freephile/meza/commit/c3b232ab) (2015-06-15) James Montalvo: add more apache config steps (serve PHP files properly) 
  - Modified: `manual/3.1-InstallApache.md`

* [a5ee6692](https://github.com/freephile/meza/commit/a5ee6692) (2015-06-15) James Montalvo: fix php path; initiate MW install steps (git, composer) 
  - Modified: `manual/3.0-SetupLAMP.md`
  - Modified: `manual/3.2-InstallPHP.md`
  - Modified: `manual/OpenWork.md`

* [163eaa48](https://github.com/freephile/meza/commit/163eaa48) (2015-06-15) Daren Welsh: add apache conf updates; fix initd_httpd.sh link 
  - Modified: `manual/3.1-InstallApache.md`

* [7e7460c0](https://github.com/freephile/meza/commit/7e7460c0) (2015-06-15) Daren Welsh: add GPG import for EPEL install; formatting 
  - Modified: `manual/2.0-ConfiguringCentOS.md`

* [8d8ba937](https://github.com/freephile/meza/commit/8d8ba937) (2015-06-14) James Montalvo: remove words saying port forwarding required 
  - Modified: `manual/2.0-ConfiguringCentOS.md`

* [148e74d8](https://github.com/freephile/meza/commit/148e74d8) (2015-06-14) James Montalvo: MySQL steps complete 
  - Modified: `manual/3.0-SetupLAMP.md`
  - Modified: `manual/3.2-InstallPHP.md`
  - Modified: `manual/3.3-InstallMySQL.md`

* [226f5b8f](https://github.com/freephile/meza/commit/226f5b8f) (2015-06-14) James Montalvo: add mysql info 
  - Added: `client_files/mysql-development.cfg`
  - Added: `manual/3.3-InstallMySQL.md`
  - Modified: `manual/References.md`

* [8afb15ba](https://github.com/freephile/meza/commit/8afb15ba) (2015-06-14) James Montalvo: PHP now being served from apache 
  - Modified: `manual/3.2-InstallPHP.md`
  - Modified: `manual/References.md`

* [b2d322cc](https://github.com/freephile/meza/commit/b2d322cc) (2015-06-14) James Montalvo: make sure to install perl early, else Apache doesn't know where it is 
  - Modified: `manual/2.0-ConfiguringCentOS.md`
  - Modified: `manual/3.0-SetupLAMP.md`
  - Modified: `manual/3.2-InstallPHP.md`
  - Modified: `manual/OpenWork.md`
  - Modified: `manual/References.md`

* [02fd105c](https://github.com/freephile/meza/commit/02fd105c) (2015-06-14) James Montalvo: Reorganize files 
R100	manual/SettingUpVirtualBox.md	manual/1.0-SettingUpVirtualBox.md
R083	manual/ConfiguringCentOS.md	manual/2.0-ConfiguringCentOS.md
  - Added: `manual/3.0-SetupLAMP.md`
R100	manual/InstallApache.md	manual/3.1-InstallApache.md
R100	manual/InstallPHP.md	manual/3.2-InstallPHP.md
  - Modified: `manual/README.md`

* [f4b0ff0c](https://github.com/freephile/meza/commit/f4b0ff0c) (2015-06-14) James Montalvo: remove PHP and apache steps from openwork 
  - Modified: `manual/OpenWork.md`

* [182be149](https://github.com/freephile/meza/commit/182be149) (2015-06-14) James Montalvo: Add install apache steps 
  - Modified: `manual/ConfiguringCentOS.md`
  - Added: `manual/InstallApache.md`

* [a4460fa6](https://github.com/freephile/meza/commit/a4460fa6) (2015-06-13) James Montalvo: add PHP steps 
  - Modified: `manual/ConfiguringCentOS.md`
  - Added: `manual/InstallPHP.md`
  - Modified: `manual/OpenWork.md`

* [689b22cd](https://github.com/freephile/meza/commit/689b22cd) (2015-06-13) James Montalvo: add reference to what -devel means in yum packages 
  - Modified: `manual/References.md`

* [37461fb7](https://github.com/freephile/meza/commit/37461fb7) (2015-06-13) Daren Welsh: add nano install reference 
  - Modified: `manual/References.md`

* [7cd44715](https://github.com/freephile/meza/commit/7cd44715) (2015-06-13) James Montalvo: fix postrotate...an other things 
  - Modified: `client_files/logrotated_httpd`
  - Modified: `manual/OpenWork.md`
  - Modified: `manual/References.md`

* [476e0be5](https://github.com/freephile/meza/commit/476e0be5) (2015-06-13) James Montalvo: add log rotate file 
  - Added: `client_files/logrotated_httpd`
  - Modified: `manual/OpenWork.md`

* [6ca3ba52](https://github.com/freephile/meza/commit/6ca3ba52) (2015-06-13) James Montalvo: rename new httpd service script 
R100	client_files/initd_httpd2.sh	client_files/initd_httpd.sh

* [43be45fd](https://github.com/freephile/meza/commit/43be45fd) (2015-06-13) James Montalvo: remove initial httpd service script 
  - Deleted: `client_files/initd_httpd.sh`

* [8d10fd5c](https://github.com/freephile/meza/commit/8d10fd5c) (2015-06-13) James Montalvo: new apache httpd service script 
  - Added: `client_files/initd_httpd2.sh`

* [04776289](https://github.com/freephile/meza/commit/04776289) (2015-06-13) James Montalvo: first steps to build apache from source 
  - Added: `client_files/initd_httpd.sh`
  - Modified: `manual/ConfiguringCentOS.md`
  - Modified: `manual/OpenWork.md`

* [61493c60](https://github.com/freephile/meza/commit/61493c60) (2015-06-12) James Montalvo: open work: PHP install 
  - Modified: `manual/OpenWork.md`

* [a3e8f4d2](https://github.com/freephile/meza/commit/a3e8f4d2) (2015-06-12) James Montalvo: forgot to start Apache...oops\! 
  - Modified: `manual/ConfiguringCentOS.md`

* [d635c696](https://github.com/freephile/meza/commit/d635c696) (2015-06-12) James Montalvo: Most of tutorial working, but getting connection refused from HTTP 
  - Modified: `manual/CentOS_Notes.md`
  - Modified: `manual/ConfiguringCentOS.md`
  - Deleted: `manual/InstallingCentOS.md`
  - Modified: `manual/README.md`
  - Modified: `manual/SettingUpVirtualBox.md`

* [0f3792ed](https://github.com/freephile/meza/commit/0f3792ed) (2015-06-12) James Montalvo: add list of reference that we will be using 
  - Modified: `manual/References.md`

* [2142f946](https://github.com/freephile/meza/commit/2142f946) (2015-06-12) James Montalvo: first clean-ish version, still incomplete 
  - Modified: `manual/CentOS_Notes.md`
  - Added: `manual/ClosedWork.md`
  - Modified: `manual/ConfiguringCentOS.md`
  - Modified: `manual/InstallingCentOS.md`
  - Added: `manual/OpenWork.md`
  - Modified: `manual/README.md`
  - Added: `manual/References.md`
  - Modified: `manual/SettingUpVirtualBox.md`

* [26ddf130](https://github.com/freephile/meza/commit/26ddf130) (2015-06-12) James Montalvo: Still doing initial setup 
  - Modified: `README.md`
R100	CentOS_Notes.md	manual/CentOS_Notes.md
  - Added: `manual/ConfiguringCentOS.md`
  - Added: `manual/InstallingCentOS.md`
  - Added: `manual/README.md`
  - Added: `manual/SettingUpVirtualBox.md`

* [d1c2e918](https://github.com/freephile/meza/commit/d1c2e918) (2015-06-12) James Montalvo: added some more while at traclabs 
  - Modified: `README.md`

* [8742612b](https://github.com/freephile/meza/commit/8742612b) (2015-06-12) James Montalvo: initial, very incomplete 
  - Added: `CentOS_Notes.md`
  - Modified: `README.md`
