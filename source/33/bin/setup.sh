#!/bin/bash

if [ -a db/production.db ]; then
    rm db/production.db
fi
sqlite3 db/production.db < sql/sqlite.sql
chown -R ctfq33:ctfq33 db
