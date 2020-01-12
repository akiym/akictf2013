#!/bin/bash

if [ -a db/production.db ]; then
    rm db/production.db
fi
sqlite3 db/production.db < sql/sqlite.sql
chown -R ctfq32:ctfq32 db
