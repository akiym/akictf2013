#!/bin/bash

if [ -a q20.db ]; then
    rm q20.db
fi
sqlite3 q20.db < q20.sql
chown ctfq20:ctfq20 q20.db
