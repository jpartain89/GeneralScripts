#!/bin/bash
set -e

INVOICE="/home/jpartain89/git/invoiceninja"

cd $INVOICE || exit
git pull
php7.4 $(which composer) install
php7.4 $(which composer) dump-autoload --optimize
php7.4 artisan optimize
php7.4 artisan migrate
php7.4 artisan db:seed --class=UpdateSeeder
