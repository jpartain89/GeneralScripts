#!/usr/bin/env bash
set -e

SSDC=$(command -v ssdc)

"${SSDC} backup"

sudo mariadb-dump -ujpartain89 -plover0778 --all-databases --flush-privileges -f > /docker/mariadb/backup/$(date +%F_%R).sql 2>/dev/null
