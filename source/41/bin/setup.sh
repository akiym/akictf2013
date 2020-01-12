#!/bin/bash

if [ -a pokemon.db ]; then
    rm pokemon.db
fi
sqlite3 pokemon.db < pokemon.sql
chown ctfq41:ctfq41 pokemon.db
