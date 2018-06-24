#!/bin/bash -e

ECHO_LOC='/home/jpartain89/git/echofish'
CMD='/usr/bin/mysql --user=jpartain89 --password=lover0778 ETS_echofish'

SCHEMA=(
    schema/00_echofish-schema.sql
    schema/echofish-dataonly.sql
    schema/echofish-functions.sql
    schema/echofish-procedures.mariadb10.sql
    schema/echofish-triggers.sql
    schema/echofish-events.sql
)

for i in "${ECHO_LOC}/${SCHEMA[@]}"; do
    "${CMD} < ${i}"
done

cp htdocs/protected/config/db-sample.php htdocs/protected/config/db.php
