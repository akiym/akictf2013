#!/bin/bash

if [ -a db/production.db ]; then
    rm db/production.db
fi
sqlite3 db/production.db < sql/sqlite.sql
chown -R ctfq24:ctfq24 db

find dat -name 'flag.png' -o -name 'welcome.png' -prune -o -type f -prune -print0 | xargs -0 rm -f
chown -R ctfq24:ctfq24 dat
