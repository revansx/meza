# Help
Once installed, if you run the `meza` command all by itself, it will display *help* like the following:
```bash
Mediawiki EZ Admin

Usage: meza COMMAND [directives]

To setup a multi-server environment, do:

$ meza setup env # Setup the environment, following prompts
# Edit config as required:
$ sudo vi /opt/conf-meza/secret/<env-name>/hosts
$ sudo vi /opt/conf-meza/secret/<env-name>/secret.yml
$ sudo meza deploy <env-name>

Commands    Directives           Description
---------------------------------------------------------------
install     dev-networking       Setup networking on VM
            monolith             Install server on this machine
            docker               Install Docker (CentOS only)
deploy      <environment name>   Deploy your server
setup       env                  Setup an environment
            dev                  Setup dev features (Git, FTP)
create      wiki                 Create a wiki
            wiki-promptless      Create a wiki without prompts
backup      <environment name>   Create a backup of an env
docker      run                  (experimental) Start container
            exec                 Execute command on container

Every command has directives. If you run any command without
directives it will provide help for that command.
```

# Passthru
Meza ultimately passes through options and arguments to [Ansible](https://www.ansible.com/quick-start-video)'s `ansible-playbook` command.  
So, if there are `ansible-playbook` options that you wish to use, you can do so.  Particularly useful for getting to know **Meza** are the
`--list-tags`, `--list-tasks`; `--tags` and `--skip-tags` options.  The first two are options that do not actually run the playbook, but 
rather they tell you more about it. 

## Tags

`sudo meza deploy monolith --list-tags` ('monolith' is any suitable environment name such as 'dev', 'staging', 'production')
Will output something like the following:

First it shows you the actual invocation of `ansible-playbook` that is run:
sudo -u meza-ansible ansible-playbook /opt/meza/src/playbooks/site.yml -i /opt/conf-meza/secret/monolith/hosts --vault-password-file /opt/conf-meza/users/meza-ansible/.vault-pass-monolith.txt --extra-vars '{"env": "monolith"}' --list-tags

Followed by the number of plays, and the tags associated with each:
```
playbook: /opt/meza/src/playbooks/site.yml

  play #1 (localhost): localhost        TAGS: []
      TASK TAGS: []

  play #2 (app-servers): app-servers    TAGS: []
      TASK TAGS: []

  play #3 (all:!exclude-all:!load-balancers-unmanaged): all:!exclude-all:!load-balancers-unmanaged      TAGS: [base]
      TASK TAGS: [base, latest]

  play #4 (load-balancers): load-balancers      TAGS: [load-balancer]
      TASK TAGS: [load-balancer]

  play #5 (app-servers): app-servers    TAGS: [apache-php]
      TASK TAGS: [apache-php, latest]

  play #6 (app-servers): app-servers    TAGS: [gluster]
      TASK TAGS: [gluster]

  play #7 (memcached-servers): memcached-servers        TAGS: [memcached]
      TASK TAGS: [latest, memcached]

  play #8 (db-master): db-master        TAGS: [database]
      TASK TAGS: [database]

  play #9 (db-slaves): db-slaves        TAGS: [database]
      TASK TAGS: [database]

  play #10 (elastic-servers): elastic-servers   TAGS: [elasticsearch]
      TASK TAGS: [elasticsearch]

  play #11 (app-servers): app-servers   TAGS: [mediawiki]
      TASK TAGS: [composer-extensions, git-core-extensions, git-extensions, git-local-extensions, git-submodules, latest, mediawiki, search-index, smw-data, update.php, verify-wiki]

  play #12 (parsoid-servers): parsoid-servers   TAGS: [parsoid]
      TASK TAGS: [latest, parsoid, parsoid-deps]

  play #13 (logging-servers): logging-servers   TAGS: [logging]
      TASK TAGS: [logging]

  play #14 (all:!exclude-all:!load-balancers-unmanaged): all:!exclude-all:!load-balancers-unmanaged     TAGS: [cron]
      TASK TAGS: [cron]
  ```
  
## Tasks
There is a lot of detail in the **list-tasks** output.  This is for reference only, and will change constantly as development is ongoing.

In the task list, you can see **tags** that are associated at the task level.  Again, this command will **not** execute a deploy.
It will only show you the tasks that would be run.

`sudo meza deploy monolith --list-tasks`
Will output something like the following:
```
playbook: /opt/meza/src/playbooks/site.yml

  play #1 (localhost): localhost        TAGS: []
    tasks:
      Ensure no password on meza-ansible user on controller     TAGS: []
      Ensure controller has user alt-meza-ansible       TAGS: []
      Ensure user alt-meza-ansible .ssh dir configured  TAGS: []
      Copy meza-ansible keys to alt-meza-ansible        TAGS: []
      Copy meza-ansible known_hosts to alt-meza-ansible TAGS: []
      Ensure secret.yml encrypted       TAGS: []
      Ensure secret.yml owned by meza-ansible   TAGS: []

  play #2 (app-servers): app-servers    TAGS: []
    tasks:
      set-vars : Set meza-core path variables   TAGS: []
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: []
      set-vars : Set meza local public variables        TAGS: []
      set-vars : Get individual wikis dirs from localhost       TAGS: []
      set_fact  TAGS: []
      set-vars : Set meza local secret variables        TAGS: []
      init-controller-config : Does controller have local config        TAGS: []
      init-controller-config : Get local config repo if set     TAGS: []
      init-controller-config : Does controller have local config        TAGS: []
      init-controller-config : Ensure m_local_public configured on controller   TAGS: []
      init-controller-config : Ensure m_local_public/wikis exists       TAGS: []
      init-controller-config : Ensure pre/post settings directories exists in config    TAGS: []
      init-controller-config : Ensure base files present, do NOT overwrite      TAGS: []

<<<<<<< HEAD
```
And so on...
=======
  play #3 (all:!exclude-all:!load-balancers-unmanaged): all:!exclude-all:!load-balancers-unmanaged      TAGS: [base]
    tasks:
      set-vars : Set meza-core path variables   TAGS: [base]
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: [base]
      set-vars : Set meza local public variables        TAGS: [base]
      set-vars : Get individual wikis dirs from localhost       TAGS: [base]
      set_fact  TAGS: [base]
      set-vars : Set meza local secret variables        TAGS: [base]
      base : Ensure user's meza-ansible and alt-meza-ansible in group "wheel"   TAGS: [base]
      base : Ensure user alt-meza-ansible .ssh dir configured   TAGS: [base]
      base : Copy meza-ansible authorized_keys to alt-meza-ansible      TAGS: [base]
      base : Ensure user meza-ansible and alt-meza-ansible authorized_keys configured   TAGS: [base]
      base : Set authorized key for alt-meza-ansible    TAGS: [base]
      base : Ensure no password on alt-meza-ansible user        TAGS: [base]
      base : Ensure alt-meza-ansible is passwordless sudoer     TAGS: [base]
      base : ensure deltarpm is installed and latest    TAGS: [base, latest]
      base : upgrade all packages       TAGS: [base, latest]
      base : ensure EPEL installed      TAGS: [base]
      base : Check if EPEL repo is already configured.  TAGS: [base]
      base : Install EPEL repo. TAGS: [base]
      base : Import EPEL GPG key.       TAGS: [base]
      base : Ensure optional repos enabled      TAGS: [base]
      base : ensure libselinux-python installed prior to SELinux        TAGS: [base]
      base : Install base packages      TAGS: [base]
      base : put SELinux in permissive mode     TAGS: [base]
      base : ensure firewalld is running (and enable it at boot)        TAGS: [base]
      base : Ensure sshd is running and enabled TAGS: [base]
      base : Ensure SSH client and SSH Daemon configs in place  TAGS: [base]
      base : Ensure SSH client and SSH Daemon configs in place  TAGS: [base]
      base : Install NTP        TAGS: [base]
      base : Ensure NTP is running and enabled as configured.   TAGS: [base]
      base : Copy the ntp.conf template file    TAGS: [base]
      base : Ensure deploy directory in place   TAGS: [base]
      base : Ensure config variables available in PHP and shell files   TAGS: [base]
      base : Ensure {{ m_tmp }} exists  TAGS: [base]
      base : Ensure {{ m_logs }} exists TAGS: [base]
      base : Ensure crontab empty for meza-ansible when overwriting wikis       TAGS: [base]                                                                                                                                                               
      base : Copy any custom PEM-format CA certs into place     TAGS: [base]                                                                                                                                                                               
      base : Copy any custom OpenSSL extended-format CA certs into place        TAGS: [base]                                                                                                                                                               
      base : Update CA trust if certs changed   TAGS: [base]                                                                                                                                                                                               
                                                                                                                                                                                                                                                           
  play #4 (load-balancers): load-balancers      TAGS: [load-balancer]                                                                                                                                                                                      
    tasks:                                                                                                                                                                                                                                                 
      set-vars : Set meza-core path variables   TAGS: [load-balancer]                                                                                                                                                                                      
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: [load-balancer]                                                                                                                                                      
      set-vars : Set meza local public variables        TAGS: [load-balancer]                                                                                                                                                                              
      set-vars : Get individual wikis dirs from localhost       TAGS: [load-balancer]                                                                                                                                                                      
      set_fact  TAGS: [load-balancer]                                                                                                                                                                                                                      
      set-vars : Set meza local secret variables        TAGS: [load-balancer]                                                                                                                                                                              
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [load-balancer]                                                                                                                                              
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [load-balancer]                                                                                                                                              
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [load-balancer]                                                                                                                                              
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [load-balancer]                                                                                                                                              
      haproxy : Install haproxy packages        TAGS: [load-balancer]                                                                                                                                                                                      
      haproxy : Ensure haproxy certs directory exists   TAGS: [load-balancer]                                                                                                                                                                              
      haproxy : Check if secret config on CONTROLLER has SSL keys       TAGS: [load-balancer]                                                                                                                                                              
      haproxy : Ensure config SSL directory exists      TAGS: [load-balancer]                                                                                                                                                                              
      haproxy : If not exists, create self-signed SSL cert on CONTROLLER        TAGS: [load-balancer]
      haproxy : Ensure SSL cert and key are encrypted   TAGS: [load-balancer]
      haproxy : Read SSL key into variable      TAGS: [load-balancer]
      haproxy : Read SSL cert into variable     TAGS: [load-balancer]
      haproxy : Ensure SSL cert on load balancers       TAGS: [load-balancer]
      haproxy : Ensure SSL key on load balancers        TAGS: [load-balancer]
      haproxy : Ensure cert and key assembled into into pem file        TAGS: [load-balancer]
      haproxy : Ensure haproxy certs have secure permissions    TAGS: [load-balancer]
      haproxy : write the haproxy config file   TAGS: [load-balancer]
      haproxy : Ensure error files directory in place   TAGS: [load-balancer]
      haproxy : Ensure error pages in place     TAGS: [load-balancer]
      haproxy : Ensure firewalld haproxy service files in place TAGS: [load-balancer]
      haproxy : Ensure SELinux context for firewalld haproxy service files      TAGS: [load-balancer]
      haproxy : Configure firewalld for haproxy via port 80 and 443     TAGS: [load-balancer]
      haproxy : Ensure firewalld port 1936 OPEN when haproxy stats ENABLED      TAGS: [load-balancer]
      haproxy : Ensure firewalld port 1936 CLOSED when haproxy stats DISABLED   TAGS: [load-balancer]
      haproxy : Ensure firewalld port 8088 OPEN when PHP profiling ENABLED      TAGS: [load-balancer]
      haproxy : Ensure firewalld port 8088 CLOSED when PHP profiling DISABLED   TAGS: [load-balancer]
      haproxy : Uncomment '$ModLoad imudp' in /etc/rsyslog.conf TAGS: [load-balancer]
      haproxy : Uncomment '$UDPServerRun 514' in /etc/rsyslog.conf      TAGS: [load-balancer]
      haproxy : Ensure /etc/rsyslog.d/haproxy.conf configured   TAGS: [load-balancer]
      haproxy : ensure haproxy is running (and enable it at boot)       TAGS: [load-balancer]

  play #5 (app-servers): app-servers    TAGS: [apache-php]
    tasks:
      set-vars : Set meza-core path variables   TAGS: [apache-php]
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: [apache-php]
      set-vars : Set meza local public variables        TAGS: [apache-php]
      set-vars : Get individual wikis dirs from localhost       TAGS: [apache-php]
      set_fact  TAGS: [apache-php]
      set-vars : Set meza local secret variables        TAGS: [apache-php]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [apache-php]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [apache-php]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [apache-php]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [apache-php]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [apache-php]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [apache-php]
      base-extras : Install base-extras packages        TAGS: [apache-php]
      imagemagick : Ensure ghostscript installed        TAGS: [apache-php]
      imagemagick : Install Imagemagick from meza repo  TAGS: [apache-php]
      imagemagick : Copy xpdf bin64 files to /usr/local/bin     TAGS: [apache-php]
      apache-php : Install apache packages      TAGS: [apache-php]
      apache-php : Make apache own htdocs directory     TAGS: [apache-php]
      apache-php : Ensure user meza-ansible and alt-meza-ansible in group "apache"      TAGS: [apache-php]
      apache-php : write the apache config file TAGS: [apache-php]
      apache-php : Install php dependency packages      TAGS: [apache-php]
      apache-php : Install IUS (CentOS) repo.   TAGS: [apache-php]
      apache-php : Install IUS (RHEL) repo.     TAGS: [apache-php]
      apache-php : Import IUS Community Project GPG key TAGS: [apache-php]
      apache-php : Ensure PHP IUS packages installed    TAGS: [apache-php]
      apache-php : Write php.ini file   TAGS: [apache-php]
      apache-php : Ensure PEAR Mail and Net_SMTP packages installed     TAGS: [apache-php, latest]
      composer : Set php_executable variable to a default if not defined.       TAGS: [apache-php]
      composer : Check if Composer is installed.        TAGS: [apache-php]
      composer : Download Composer installer.   TAGS: [apache-php]
      composer : Run Composer installer.        TAGS: [apache-php]
      composer : Move Composer into globally-accessible location.       TAGS: [apache-php]
      composer : Update Composer to latest version (if configured).     TAGS: [apache-php]
      composer : Ensure composer cache is clear TAGS: [apache-php]
      composer : Ensure composer directory exists.      TAGS: [apache-php]
      composer : Add GitHub OAuth token for Composer (if configured).   TAGS: [apache-php]
      composer : Install configured globally-required packages. TAGS: [apache-php]
      composer : Add composer_home_path bin directory to global $PATH.  TAGS: [apache-php]
      apache-php : add mongo repo file  TAGS: [apache-php]
      apache-php : Install mongodb-org package  TAGS: [apache-php]
      apache-php : Ensure MongoDB conf file in place    TAGS: [apache-php]
      apache-php : run mongodb  TAGS: [apache-php]
      apache-php : Install XHProf and mongo PECL packages for profiling TAGS: [apache-php]
      apache-php : Ensure XHGui present TAGS: [apache-php]
      apache-php : Ensure XHGui directory owned by Apache       TAGS: [apache-php]
      apache-php : Ensure XHGui packages present        TAGS: [apache-php]
      apache-php : Ensure XHGui using correct Mongo DB instance (on first app server)   TAGS: [apache-php]
      apache-php : Ensure XHGui cache directory configured      TAGS: [apache-php]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [apache-php]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [apache-php]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [apache-php]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [apache-php]
      apache-php : Check if MongoDB service exists      TAGS: [apache-php]
      apache-php : Stop MongoDB service if profiling is disabled        TAGS: [apache-php]
      apache-php : ensure apache is running (and enable it at boot)     TAGS: [apache-php]

  play #6 (app-servers): app-servers    TAGS: [gluster]
    tasks:
      set-vars : Set meza-core path variables   TAGS: [gluster]
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: [gluster]
      set-vars : Set meza local public variables        TAGS: [gluster]
      set-vars : Get individual wikis dirs from localhost       TAGS: [gluster]
      set_fact  TAGS: [gluster]
      set-vars : Set meza local secret variables        TAGS: [gluster]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [gluster]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [gluster]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [gluster]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [gluster]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [gluster]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [gluster]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [gluster]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [gluster]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [gluster]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [gluster]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [gluster]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [gluster]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [gluster]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [gluster]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [gluster]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [gluster]
      gluster : Include OS-specific variables.  TAGS: [gluster]
      gluster : Ensure repo in place for RHEL   TAGS: [gluster]
      gluster : Ensure CentOS prerequisites in place    TAGS: [gluster]
      gluster : Install Packages        TAGS: [gluster]
      gluster : Add PPA for GlusterFS.  TAGS: [gluster]
      gluster : Ensure GlusterFS will reinstall if the PPA was just added.      TAGS: [gluster]
      gluster : Ensure GlusterFS is installed.  TAGS: [gluster]
      gluster : Ensure GlusterFS is started and enabled at boot.        TAGS: [gluster]
      gluster : Ensure Gluster brick and mount directories exist.       TAGS: [gluster]
      gluster : Configure Gluster volume.       TAGS: [gluster]
      gluster : Ensure Gluster volume is mounted.       TAGS: [gluster]

  play #7 (memcached-servers): memcached-servers        TAGS: [memcached]
    tasks:
      set-vars : Set meza-core path variables   TAGS: [memcached]
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: [memcached]
      set-vars : Set meza local public variables        TAGS: [memcached]
      set-vars : Get individual wikis dirs from localhost       TAGS: [memcached]
      set_fact  TAGS: [memcached]
      set-vars : Set meza local secret variables        TAGS: [memcached]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [memcached]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [memcached]
      memcached : Ensure memcached and netcat packages latest   TAGS: [latest, memcached]
      memcached : Write the memcached config file       TAGS: [memcached]
      memcached : Ensure memcached is running (and enable it at boot)   TAGS: [memcached]

  play #8 (db-master): db-master        TAGS: [database]
    tasks:
      set-vars : Set meza-core path variables   TAGS: [database]
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: [database]
      set-vars : Set meza local public variables        TAGS: [database]
      set-vars : Get individual wikis dirs from localhost       TAGS: [database]
      set_fact  TAGS: [database]
      set-vars : Set meza local secret variables        TAGS: [database]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [database]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [database]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [database]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [database]
      database : Include OS-specific variables. TAGS: [database]
      database : Include OS-specific variables (RedHat).        TAGS: [database]
      database : Define mysql_packages. TAGS: [database]
      database : Define mysql_daemon.   TAGS: [database]
      database : Define mysql_slow_query_log_file.      TAGS: [database]
      database : Define mysql_log_error.        TAGS: [database]
      database : Define mysql_syslog_tag.       TAGS: [database]
      database : Define mysql_pid_file. TAGS: [database]
      database : Define mysql_config_file.      TAGS: [database]
      database : Define mysql_config_include_dir.       TAGS: [database]
      database : Define mysql_socket.   TAGS: [database]
      database : Define mysql_supports_innodb_large_prefix.     TAGS: [database]
      include   TAGS: [database]
      include   TAGS: [database]
      database : Check if MySQL packages were installed.        TAGS: [database]
      database : Copy my.cnf global MySQL configuration.        TAGS: [database]
      database : Verify mysql include directory exists. TAGS: [database]
      database : Copy my.cnf override files into include directory.     TAGS: [database]
      database : Create slow query log file (if configured).    TAGS: [database]
      database : Create datadir if it does not exist    TAGS: [database]
      database : Set ownership on slow query log file (if configured).  TAGS: [database]
      database : Create error log file (if configured). TAGS: [database]
      database : Set ownership on error log file (if configured).       TAGS: [database]
      database : Ensure MySQL is started and enabled on boot.   TAGS: [database]
      database : Get MySQL version.     TAGS: [database]
      database : Ensure default user is present.        TAGS: [database]
      database : Copy user-my.cnf file with password credentials.       TAGS: [database]
      database : Disallow root login remotely   TAGS: [database]
      database : Get list of hosts for the root user.   TAGS: [database]
      database : Update MySQL root password for localhost root account (5.7.x). TAGS: [database]
      database : Update MySQL root password for localhost root account (< 5.7.x).       TAGS: [database]
      database : Copy .my.cnf file with root password credentials       TAGS: [database]
      database : Copy .my.cnf file with root password credentials       TAGS: [database]
      database : Get list of hosts for the anonymous user.      TAGS: [database]
      database : Remove anonymous MySQL users.  TAGS: [database]
      database : Remove MySQL test database.    TAGS: [database]
      database : Ensure MySQL databases are present.    TAGS: [database]
      database : Ensure meza application MySQL users are present        TAGS: [database]
      database : If this DB-server is an app server, include localhost as a valid host for application user     TAGS: [database]
      database : Ensure additional MySQL users are present.     TAGS: [database]
      database : Check if valid slave   TAGS: [database]
      database : Check if valid master  TAGS: [database]
      database : Ensure replication user exists on master.      TAGS: [database]
      database : Check slave replication status.        TAGS: [database]
      debug     TAGS: [database]
      database : Check if slave needs configuration     TAGS: [database]
      debug     TAGS: [database]
      database : Check master replication status.       TAGS: [database]
      debug     TAGS: [database]
      database : fetch list of wikis on master  TAGS: [database]
      database : export dump file on master     TAGS: [database]
      database : fetch dump file        TAGS: [database]
      database : put dump file  TAGS: [database]
      database : Import dump on slave(s)        TAGS: [database]
      mysql_replication TAGS: [database]
      database : Configure replication on the slave.    TAGS: [database]
      database : Start replication.     TAGS: [database]

  play #9 (db-slaves): db-slaves        TAGS: [database]
    tasks:
      set-vars : Set meza-core path variables   TAGS: [database]
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: [database]
      set-vars : Set meza local public variables        TAGS: [database]
      set-vars : Get individual wikis dirs from localhost       TAGS: [database]
      set_fact  TAGS: [database]
      set-vars : Set meza local secret variables        TAGS: [database]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [database]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [database]
      database : Include OS-specific variables. TAGS: [database]
      database : Include OS-specific variables (RedHat).        TAGS: [database]
      database : Define mysql_packages. TAGS: [database]
      database : Define mysql_daemon.   TAGS: [database]
      database : Define mysql_slow_query_log_file.      TAGS: [database]
      database : Define mysql_log_error.        TAGS: [database]
      database : Define mysql_syslog_tag.       TAGS: [database]
      database : Define mysql_pid_file. TAGS: [database]
      database : Define mysql_config_file.      TAGS: [database]
      database : Define mysql_config_include_dir.       TAGS: [database]
      database : Define mysql_socket.   TAGS: [database]
      database : Define mysql_supports_innodb_large_prefix.     TAGS: [database]
      include   TAGS: [database]
      include   TAGS: [database]
      database : Check if MySQL packages were installed.        TAGS: [database]
      database : Copy my.cnf global MySQL configuration.        TAGS: [database]
      database : Verify mysql include directory exists. TAGS: [database]
      database : Copy my.cnf override files into include directory.     TAGS: [database]
      database : Create slow query log file (if configured).    TAGS: [database]
      database : Create datadir if it does not exist    TAGS: [database]
      database : Set ownership on slow query log file (if configured).  TAGS: [database]
      database : Create error log file (if configured). TAGS: [database]
      database : Set ownership on error log file (if configured).       TAGS: [database]
      database : Ensure MySQL is started and enabled on boot.   TAGS: [database]
      database : Get MySQL version.     TAGS: [database]
      database : Ensure default user is present.        TAGS: [database]
      database : Copy user-my.cnf file with password credentials.       TAGS: [database]
      database : Disallow root login remotely   TAGS: [database]
      database : Get list of hosts for the root user.   TAGS: [database]
      database : Update MySQL root password for localhost root account (5.7.x). TAGS: [database]
      database : Update MySQL root password for localhost root account (< 5.7.x).       TAGS: [database]
      database : Copy .my.cnf file with root password credentials       TAGS: [database]
      database : Copy .my.cnf file with root password credentials       TAGS: [database]
      database : Get list of hosts for the anonymous user.      TAGS: [database]
      database : Remove anonymous MySQL users.  TAGS: [database]
      database : Remove MySQL test database.    TAGS: [database]
      database : Ensure MySQL databases are present.    TAGS: [database]
      database : Ensure meza application MySQL users are present        TAGS: [database]
      database : If this DB-server is an app server, include localhost as a valid host for application user     TAGS: [database]
      database : Ensure additional MySQL users are present.     TAGS: [database]
      database : Check if valid slave   TAGS: [database]
      database : Check if valid master  TAGS: [database]
      database : Ensure replication user exists on master.      TAGS: [database]
      database : Check slave replication status.        TAGS: [database]
      debug     TAGS: [database]
      database : Check if slave needs configuration     TAGS: [database]
      debug     TAGS: [database]
      database : Check master replication status.       TAGS: [database]
      debug     TAGS: [database]
      database : fetch list of wikis on master  TAGS: [database]
      database : export dump file on master     TAGS: [database]
      database : fetch dump file        TAGS: [database]
      database : put dump file  TAGS: [database]
      database : Import dump on slave(s)        TAGS: [database]
      mysql_replication TAGS: [database]
      database : Configure replication on the slave.    TAGS: [database]
      database : Start replication.     TAGS: [database]

  play #10 (elastic-servers): elastic-servers   TAGS: [elasticsearch]
    tasks:
      set-vars : Set meza-core path variables   TAGS: [elasticsearch]
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: [elasticsearch]
      set-vars : Set meza local public variables        TAGS: [elasticsearch]
      set-vars : Get individual wikis dirs from localhost       TAGS: [elasticsearch]
      set_fact  TAGS: [elasticsearch]
      set-vars : Set meza local secret variables        TAGS: [elasticsearch]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [elasticsearch]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [elasticsearch]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [elasticsearch]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [elasticsearch]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [elasticsearch]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [elasticsearch]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [elasticsearch]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [elasticsearch]
      elasticsearch : Ensure Java is installed. TAGS: [elasticsearch]
      elasticsearch : Set JAVA_HOME if configured.      TAGS: [elasticsearch]
      elasticsearch : Add Elasticsearch GPG key.        TAGS: [elasticsearch]
      elasticsearch : Add Elasticsearch repository.     TAGS: [elasticsearch]
      elasticsearch : Install Elasticsearch.    TAGS: [elasticsearch]
      elasticsearch : Check whether /etc/hosts contains "127.0.0.1"     TAGS: [elasticsearch]
      elasticsearch : Add localhost to /etc/hosts if needed     TAGS: [elasticsearch]
      elasticsearch : Ensure dirs from elasticsearch.yml exist and set ownership        TAGS: [elasticsearch]
      elasticsearch : Configure Elasticsearch.  TAGS: [elasticsearch]
      elasticsearch : Start Elasticsearch.      TAGS: [elasticsearch]
      elasticsearch : Make sure Elasticsearch is running before proceeding.     TAGS: [elasticsearch]
      elasticsearch : Install elasticsearch plugin Kopf TAGS: [elasticsearch]
      elasticsearch : Install elasticsearch plugin Head TAGS: [elasticsearch]
      elasticsearch : Install elasticsearch plugin Bigdesk      TAGS: [elasticsearch]

  play #11 (app-servers): app-servers   TAGS: [mediawiki]
    tasks:
      set-vars : Set meza-core path variables   TAGS: [mediawiki]
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: [mediawiki]
      set-vars : Set meza local public variables        TAGS: [mediawiki]
      set-vars : Get individual wikis dirs from localhost       TAGS: [mediawiki]
      set_fact  TAGS: [mediawiki]
      set-vars : Set meza local secret variables        TAGS: [mediawiki]
      htdocs : Ensure ServerPerformance configured      TAGS: [mediawiki]
      htdocs : Ensure BackupDownload configured TAGS: [mediawiki]
      htdocs : Ensure BackupDownload NOT configured     TAGS: [mediawiki]
      htdocs : Ensure files configured  TAGS: [mediawiki]
      sync-configs : Ensure app servers have local config directory     TAGS: [mediawiki]
      sync-configs : Ensure app servers have config from controller     TAGS: [mediawiki]
      sync-configs : Ensure app servers local config directory and contents configured  TAGS: [mediawiki]
      mediawiki : Ensure user meza-ansible .ssh dir configured  TAGS: [mediawiki]
      mediawiki : Copy meza-ansible keys to app servers TAGS: [mediawiki]
      mediawiki : Copy meza-ansible known_hosts to app-servers  TAGS: [mediawiki]
      mediawiki : Ensure proper MediaWiki git version installed TAGS: [latest, mediawiki]
      mediawiki : Ensure Vector skin installed  TAGS: [mediawiki]
      mediawiki : Set variable holding list of core extensions  TAGS: [mediawiki]
      mediawiki : Set variable holding list of local extensions TAGS: [mediawiki]
      mediawiki : Ensure core meza extensions installed (non-Composer)  TAGS: [git-core-extensions, git-extensions, latest, mediawiki]
      mediawiki : Ensure local meza extensions installed (non-Composer) TAGS: [git-extensions, git-local-extensions, latest, mediawiki]
      mediawiki : Ensure Extensions.php in place        TAGS: [mediawiki]
      mediawiki : Ensure composer.local.json in place to load composer-based extensions TAGS: [mediawiki]
      mediawiki : Run composer install on MediaWiki for dependencies    TAGS: [composer-extensions, latest, mediawiki]
      mediawiki : Run composer update on MediaWiki for extensions       TAGS: [composer-extensions, latest, mediawiki]
      mediawiki : Ensure Git submodule requirements met for core meza extensions        TAGS: [git-submodules, latest, mediawiki]
      mediawiki : Ensure Git submodule requirements met for local meza extensions       TAGS: [git-submodules, latest, mediawiki]
      mediawiki : Ensure LocalSettings.php in place     TAGS: [mediawiki]
      mediawiki : Ensure WikiBlender installed  TAGS: [mediawiki]
      mediawiki : Ensure BlenderSettings.php in place   TAGS: [mediawiki]
      saml : Ensure SimpleSamlPhp (PHP SAML library) installed  TAGS: [latest, mediawiki]
      saml : Ensure SimpleSamlAuth (MediaWiki extension) installed      TAGS: [latest, mediawiki]
      saml : Ensure simplesamlphp dependencies in place TAGS: [mediawiki]
      saml : Ensure config files in place       TAGS: [mediawiki]
      saml : Ensure NonMediaWikiSimpleSamlAuth.php in place     TAGS: [mediawiki]
      mediawiki : Ensure localization cache root directory exists (each wiki with sub-directory)        TAGS: [mediawiki]
      mediawiki : Ensure root uploads dir configured    TAGS: [mediawiki]
      mediawiki : Check if any wikis exist      TAGS: [mediawiki]
      configure-wiki : Ensure wiki directory exists in config   TAGS: [mediawiki]
      configure-wiki : Ensure base files are in place (but do not overwrite)    TAGS: [mediawiki]
      configure-wiki : Ensure wiki pre/post settings directories exists in config       TAGS: [mediawiki]
      configure-wiki : Ensure base templates are present (but do not overwrite) TAGS: [mediawiki]
      sync-configs : Ensure app servers have local config directory     TAGS: [mediawiki]
      sync-configs : Ensure app servers have config from controller     TAGS: [mediawiki]
      sync-configs : Ensure app servers local config directory and contents configured  TAGS: [mediawiki]
      mediawiki : Get individual wikis dirs from localhost      TAGS: [mediawiki]
      mediawiki : Set fact - list of wikis      TAGS: [mediawiki]
      mediawiki : Set fact - list of wikis ordered with primary wiki first (if primary_wiki_id set)     TAGS: [mediawiki]
      debug     TAGS: [mediawiki]
      mediawiki : Set fact - initiate empty list of wikis to rebuild smw and search data        TAGS: [mediawiki]
      mediawiki : Ensure defined wikis exist    TAGS: [mediawiki, verify-wiki]
      debug     TAGS: [mediawiki]
      mediawiki : Ensure data rebuilding scripts in place on app servers        TAGS: [mediawiki]
      mediawiki : Ensure data rebuilding logs directories exist TAGS: [mediawiki]
      mediawiki : (Re-)build search index for: {{ wikis_to_rebuild_data | join(', ') }} TAGS: [mediawiki, search-index]
      mediawiki : (Re-)build SemanticMediaWiki data for: {{ wikis_to_rebuild_data | join(', ') }}       TAGS: [mediawiki, smw-data]
      include_role      TAGS: [mediawiki, update.php]

  play #12 (parsoid-servers): parsoid-servers   TAGS: [parsoid]
    tasks:
      set-vars : Set meza-core path variables   TAGS: [parsoid]
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: [parsoid]
      set-vars : Set meza local public variables        TAGS: [parsoid]
      set-vars : Get individual wikis dirs from localhost       TAGS: [parsoid]
      set_fact  TAGS: [parsoid]
      set-vars : Set meza local secret variables        TAGS: [parsoid]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [parsoid]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [parsoid]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [parsoid]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [parsoid]
      firewalld : set firewalld allow {{ firewalld_service }} for list of servers       TAGS: [parsoid]
      firewalld : set firewalld allow port {{ firewalld_port }} for list of servers     TAGS: [parsoid]
      nodejs : Ensure Node.js and npm are installed.    TAGS: [parsoid]
      nodejs : Define nodejs_install_npm_user   TAGS: [parsoid]
      nodejs : Add node.js/npm user group: {{ nodejs_install_npm_user }}        TAGS: [parsoid]
      nodejs : Add node.js/npm user: {{ nodejs_install_npm_user }}      TAGS: [parsoid]
      nodejs : Create npm global directory      TAGS: [parsoid]
      nodejs : Add npm_config_prefix bin directory to global $PATH.     TAGS: [parsoid]
      nodejs : Ensure npm global packages are installed.        TAGS: [parsoid]
      nodejs : Ensure npm global packages are at the latest release.    TAGS: [latest, parsoid]
      parsoid : Get Parsoid repository  TAGS: [parsoid]
      parsoid : Patch Parsoid so it allows image tags   TAGS: [parsoid]
      parsoid : Ensure parsoid group exists     TAGS: [parsoid]
      parsoid : Ensure parsoid user exists      TAGS: [parsoid]
      parsoid : Ensure parsoid directory permissions    TAGS: [parsoid]
      parsoid : Ensure Parsoid dependencies are latest  TAGS: [latest, parsoid, parsoid-deps]
      parsoid-settings : Ensure localsettings.js present and up-to-date TAGS: [parsoid]
      parsoid-settings : Ensure /etc/init.d/parsoid configured  TAGS: [parsoid]
      parsoid-settings : Enable parsoid service TAGS: [parsoid]

  play #13 (logging-servers): logging-servers   TAGS: [logging]
    tasks:
      set-vars : Set meza-core path variables   TAGS: [logging]
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: [logging]
      set-vars : Set meza local public variables        TAGS: [logging]
      set-vars : Get individual wikis dirs from localhost       TAGS: [logging]
      set_fact  TAGS: [logging]
      set-vars : Set meza local secret variables        TAGS: [logging]
      meza-log : Check if server log database exists    TAGS: [logging]
      meza-log : Set fact if server log database DOES exist     TAGS: [logging]
      meza-log : Set fact if server log database DOES NOT exist TAGS: [logging]
      meza-log : Import server log database structure   TAGS: [logging]
      meza-log : Check if disk_space table exists       TAGS: [logging]
      meza-log : Set fact if disk_space table DOES exist        TAGS: [logging]
      meza-log : Set fact if disk_space table DOES NOT exist    TAGS: [logging]
      meza-log : Create table disk_space if not exists  TAGS: [logging]

  play #14 (all:!exclude-all:!load-balancers-unmanaged): all:!exclude-all:!load-balancers-unmanaged     TAGS: [cron]
    tasks:
      set-vars : Set meza-core path variables   TAGS: [cron]
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: [cron]
      set-vars : Set meza local public variables        TAGS: [cron]
      set-vars : Get individual wikis dirs from localhost       TAGS: [cron]
      set_fact  TAGS: [cron]
      set-vars : Set meza local secret variables        TAGS: [cron]
      cron : Ensure cron is running (and enable it at boot)     TAGS: [cron]
      cron : Ensure crontab file up-to-date     TAGS: [cron]
      cron : Ensure runAllJobs.php in place     TAGS: [cron]
      lineinfile        TAGS: [cron]
      lineinfile        TAGS: [cron]
      cron : Ensure crontab up-to-date from file        TAGS: [cron]
```

At the very end of output, it shows you the underlying ansible command:

`sudo -u meza-ansible ansible-playbook /opt/meza/src/playbooks/site.yml -i /opt/conf-meza/secret/monolith/hosts --vault-password-file /opt/conf-meza/users/meza-ansible/.vault-pass-monolith.txt --extra-vars '{"env": "monolith"}' --list-tasks`

As a side note, you can use the 'aha' utility to easily create [an HTML file for reference](https://freephile.org/wiki/Aha).

`sudo meza deploy production --list-tasks | sudo tee > >(aha --black --title "Production Deploy Tasks" > /tmp/deploy.tasks.html)`

# Using Tags and Skipping Tags

To be written.  In our next update, we'll show you how to use and skip tags.  You can even combine listing and skipping.

`sudo meza deploy monolith --list-tasks --skip-tags cron` Will show you all the tasks that would be executed if you skipped the 
cron tasks.









