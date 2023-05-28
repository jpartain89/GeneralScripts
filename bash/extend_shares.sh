#!/usr/bin/env bash
set -e

SHARED_DIRECTORIES=(
  General
  CentralShare
  TV
  Movies
  Music
  Downloads
  Porn
)

SYNOSHARE=$(command -v synoshare)

GROUPS=(
  "Domain Admins"
  "Domain Users"
  "Schema Admins"
  "Enterprise Admins"
  "DNS Admins"
  "Group Policy Creator Owners"
)

GROUPS="$(IFS=,; echo "${GROUPS[*]}")"

declare -p GROUPS
declare -p SHARED_DIRECTORIES

while IFS= read -r file; do
  for i in "${SHARED_DIRECTORIES[*]}"; do
  sudo "${SYNOSHARE}" --setuser "/volume2/${i}" RW + "${GROUPS}"
done
