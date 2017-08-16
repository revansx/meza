Meza configuration directories
==============================

/opt/conf-meza/secret
---------------------

Contains secret information about environments managed by meza. This includes the list of hosts for each environment (IP addresses and what they're assigned to) as well as passwords and other secret information.

* `monolith`: This is the only special name with any real significance. It means a single server configured with all groups on the controlling machine. It is special because attempting to deploy a `monolith` environment if one doesn't already exist will generate the monolith environment. All other environments need to be set up prior to attempting to deploy them
* `prod`: Production environment
* `stage`: Staging environment
* `test`: Test environment
* `dev`: A


/opt/conf-meza/public
---------------------

This contains non-secret information about environments. This is where you should make customizations which override defaults found in various roles.  So for example, you should make a `public.yml` file here.  Here are sample contents of what you can put in that file:

```
---
# public.yml
#
# Config file for putting non-secure items needed for configuration during
# deploy of the application

blenderServer: https://wiki.example.com

primary_wiki_id: engineering

# Set a default authentication method for all wikis that don't specify one
# FIXME #763: List types, and descriptions
# meza_auth_type: "viewer-read"

blender_landing_page_title: ACME Rockets Wikis

# Email senders
# Refs:
#   https://www.mediawiki.org/wiki/Manual:$wgPasswordSender
#   https://www.mediawiki.org/wiki/Manual:$wgEmergencyContact
wgPasswordSender: "Rocky <rocky@example.com"
# wgEmergencyContact = "another.email@example.com" # defaults to wgPassword Sender

# blender_header_wiki_title: Top row wikis

blender_header_wikis:
  - engineering
  - budget
  - mission
```

/opt/.deploy-meza/public
------------------------

A copy of `/opt/conf-meza/public` (confirm perfect copy? Doesn't include `.git` for speed purposes) which is accessible to app servers regardless of whether the app server is the controller (`/opt/conf-meza/public` is only present on the controller).


/opt/meza/config/core
---------------------

Core configuration for meza. This shouldn't be edited, but can be overridden in the above directories. May get renamed `/opt/meza/config` or `/opt/meza/core.conf` or something since there's not really anything else in `/opt/meza/config` currently (besides this file).
