#!/bin/bash

if [ -a db/deployment.db ]; then
    rm db/deployment.db
fi
sqlite3 db/deployment.db < sql/sqlite.sql
chown -R ctfq27:ctfq27 db
