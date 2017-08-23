#!/bin/bash


# for wiki in demo
for wiki in base cod collegiate csgo fgc halo ow smite
  do
  # config, on the controller
  sudo rm -rf "/opt/conf-meza/public/wikis/${wiki}"
  # web dir
  sudo rm -rf "/opt/htdocs/wikis/${wiki}"
  # the "images" folder
  sudo rm -rf "/opt/data-meza/uploads-gluster/$wiki"
  # the storage brick
  sudo rm -rf "/opt/data-meza/gluster/brick/$wiki"
  curl -XDELETE 'http://localhost:9200/mediawiki_cirrussearch_frozen_indexes/'
  curl -XDELETE "http://localhost:9200/wiki_${wiki}_general_first/"
  curl -XDELETE 'http://localhost:9200/mw_cirrus_versions/'
  curl -XDELETE "http://localhost:9200/wiki_${wiki}_content_first/"
  curl -XDELETE "http://localhost:9200/wiki_${wiki}_general/"
  curl 'localhost:9200/_cat/indices?v';
  done
