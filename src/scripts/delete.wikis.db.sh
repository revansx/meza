#!/bin/bash

for wiki in base cod collegiate csgo fgc halo ow smite
  do
    sudo mysql -e "drop database wiki_${wiki};"
  done

