#!/usr/bin/env bash


cd ~/git/echofish || exit

CMD='mysql --user=jpartain89 --password=lover0778 ETS_echofish'

SCHEMA=(
    schema/00_echofish-schema.sql
    schema/echofish-dataonly.sql
    schema/echofish-functions.sql
    schema/echofish-procedures.mariadb10.sql
    schema/echofish-triggers.sql
    schema/echofish-events.sql
)

for i in "${SCHEMA[@]}"; do
    "${CMD} < ${i}"
done

cp htdocs/protected/config/db-sample.php htdocs/protected/config/db.php
